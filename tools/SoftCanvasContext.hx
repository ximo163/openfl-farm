package;

/**
 * T2 资产渲染对拍——node 端软件 canvas 2D（issue #57）。
 *
 * 为什么存在（// issue #57 探路结论）：容器里没有浏览器、没有 canvas npm 包，
 * web-smoke 的 playwright 通道只在 CI 有；本地唯一可行的截图通道就是在 node
 * 里自己实现一份 canvas 2D 语义，让 openfl/lime 的 html5 canvas 渲染路径
 * （CanvasGraphics/CanvasShape/CanvasBitmap/CanvasTextField）无改动地跑进
 * 我们的可控帧缓冲。所以本类实现的是「openfl 实际用到的 canvas 2D 子集」，
 * 按规范语义（不是随便近似）：路径段在构造时被当时的 CTM 烘进设备坐标、
 * 渐变/图案在 fill 时用当时 CTM 的逆矩阵采样、描边几何在用户空间算完再经
 * 构造 CTM 变换——CanvasGraphics 的 translate(-bounds)/fill 序列依赖这些
 * 语义才对得上。
 *
 * 与真浏览器的刻意差异（自回归立场可接受，报告如实计）：
 * - 无抗锯齿：像素中心采样（确定性优先——同一输入两次跑逐字节一致，基线
 *   哈希才稳；浏览器 AA 逐版本漂移，本来就不能当基线）。
 * - imageSmoothingEnabled 收下但始终最近邻（同一确定性理由）。
 * - 位图源无解码通道时退化为黑瓦（run-openfl-node.js 的 FakeImage 路径）；
 *   PNG 真解码在 RenderProbe 的 DecodingImage 做（format.png）。
 * - 文本字形形状画确定性实心盒（fillTextCalls 计数）；布局（字宽/换行/
 *   位置）由本类的确定性度量驱动，仍受基线保护。
 *
 * 环境安装：SoftCanvas.installNode() 把 document.createElement("canvas")
 * 引到本类工厂，并把 SoftPath2D/SoftDOMMatrix 挂上 globalThis（openfl 的
 * 非 PAD 线性渐分与位图描边矩阵用 new Path2D()/new DOMMatrix()，node 没有）。
 * 必须在任何 canvas 创建之前调用（openfl 静态字段不在模块加载期建 canvas，
 * main() 开头装即可）。js 目标专用；eval 下仅为可编译（供单测纯逻辑）。
 */

import haxe.io.Bytes;
import SoftCanvasElement;
import SoftGradient;
import SoftImageData;
import SoftPattern;
import SoftDOMMatrix;
import SoftPath2D;
import SoftTypes.ColorSample;
import SoftTypes.CtxState;
import SoftTypes.Edge;
import SoftTypes.Mat6;
import SoftTypes.SubPath;
import SoftTypes.SoftSurface;

/**
 * 软件渲染上下文——canvas 2D ctx 语义子集。像素存储为预乘 RGBA（canvas
 * 合成按预乘空间定义；getImageData/putImageData 出入直色）。逐像素中心
 * 采样、无 AA。公开成员签名对应 js.html.CanvasRenderingContext2D 的
 * openfl 实际用量（调用方全是 extern/Dynamic，不做类型执法）。
 */
@:keep
class SoftCanvasContext {
	public var fillStyle:Dynamic;
	public var strokeStyle:Dynamic;
	public var globalAlpha:Float;
	public var globalCompositeOperation:String;
	public var lineWidth:Float;
	public var lineCap:String;
	public var lineJoin:String;
	public var miterLimit:Float;
	public var imageSmoothingEnabled:Bool;
	public var font:String;
	public var textBaseline:String;
	public var canvas:SoftCanvasElement;
	public var lineDashOffset:Float;

	/** 覆盖盲区计数（gate 汇总进报告）：无解码位图源数、fillText 调用数
	 * （字形形状盲区；布局/颜色仍受基线保护）。 */
	public static var fallbackImageSources:Int = 0;
	public static var fillTextCalls:Int = 0;

	/** 帧缓冲（预乘 RGBA），宽高只经 resize 变。 */
	var data:Bytes;
	public var width(default, null):Int;
	public var height(default, null):Int;
	var opaque:Bool;

	var a:Float;
	var b:Float;
	var c:Float;
	var d:Float;
	var e:Float;
	var f:Float;
	var states:Array<CtxState>;
	var clipMask:Bytes;
	var subpaths:Array<SubPath>;
	/** 描边几何复用掩码/覆盖缓冲（一条 path 一次 stroke，避免逐边分配）。 */
	var scratchA:Bytes;
	var scratchB:Bytes;

	public function new(canvas:SoftCanvasElement, opaque:Bool) {
		this.canvas = canvas;
		this.opaque = opaque;
		width = 0;
		height = 0;
		data = Bytes.alloc(0);
		scratchA = Bytes.alloc(0);
		scratchB = Bytes.alloc(0);
		fillStyle = "#000000";
		strokeStyle = "#000000";
		globalAlpha = 1;
		globalCompositeOperation = "source-over";
		lineWidth = 1;
		lineCap = "butt";
		lineJoin = "miter";
		miterLimit = 10;
		imageSmoothingEnabled = true;
		font = "10px sans-serif";
		textBaseline = "alphabetic";
		lineDashOffset = 0;
		resetTransformInternal();
		states = [];
		subpaths = [];
		clipMask = null;
	}

	// ---- 生命周期 ----

	public function resize(w:Int, h:Int):Void {
		if (w < 0) w = 0;
		if (h < 0) h = 0;
		width = w;
		height = h;
		var fresh = Bytes.alloc(w * h * 4);
		if (opaque && w > 0 && h > 0) {
			for (i in 0...w * h) {
				fresh.set(i * 4 + 3, 255);
			}
		}
		data = fresh;
		scratchA = Bytes.alloc(w * h);
		scratchB = Bytes.alloc(w * h);
	}

	public function setOpaque(value:Bool):Void {
		if (opaque == value) return;
		opaque = value;
		if (value) {
			for (i in 0...width * height) {
				var o = i * 4;
				if (data.get(o + 3) == 0) {
					data.set(o + 3, 255); // rgb 已为 0 → 不透明黑
				}
			}
		}
	}

	/** 直色 RGBA 像素（探针转 ShotImage 用；等价全画布 getImageData）。 */
	public function readPixelsStraight():Bytes {
		return unpremultiplyRegion(0, 0, width, height);
	}

	// ---- 状态栈 ----

	public function save():Void {
		states.push({
			a: a,
			b: b,
			c: c,
			d: d,
			e: e,
			f: f,
			alpha: globalAlpha,
			composite: globalCompositeOperation,
			fillStyle: fillStyle,
			strokeStyle: strokeStyle,
			lineWidth: lineWidth,
			lineCap: lineCap,
			lineJoin: lineJoin,
			miterLimit: miterLimit,
			font: font,
			clipMask: clipMask == null ? null : clipMask.sub(0, clipMask.length)
		});
	}

	public function restore():Void {
		if (states.length == 0) return;
		var s = states.pop();
		a = s.a;
		b = s.b;
		c = s.c;
		d = s.d;
		e = s.e;
		f = s.f;
		globalAlpha = s.alpha;
		globalCompositeOperation = s.composite;
		fillStyle = s.fillStyle;
		strokeStyle = s.strokeStyle;
		lineWidth = s.lineWidth;
		lineCap = s.lineCap;
		lineJoin = s.lineJoin;
		miterLimit = s.miterLimit;
		font = s.font;
		clipMask = s.clipMask;
	}

	// ---- 变换 ----

	public function setTransform(a2:Float, b2:Float, c2:Float, d2:Float, e2:Float, f2:Float):Void {
		a = a2;
		b = b2;
		c = c2;
		d = d2;
		e = e2;
		f = f2;
	}

	public function transform(a2:Float, b2:Float, c2:Float, d2:Float, e2:Float, f2:Float):Void {
		var na = a * a2 + c * b2;
		var nb = b * a2 + d * b2;
		var nc = a * c2 + c * d2;
		var nd = b * c2 + d * d2;
		var ne = a * e2 + c * f2 + e;
		var nf = b * e2 + d * f2 + f;
		a = na;
		b = nb;
		c = nc;
		d = nd;
		e = ne;
		f = nf;
	}

	public function translate(x:Float, y:Float):Void {
		transform(1, 0, 0, 1, x, y);
	}

	public function scale(x:Float, y:Float):Void {
		transform(x, 0, 0, y, 0, 0);
	}

	public function rotate(angle:Float):Void {
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		transform(cos, sin, -sin, cos, 0, 0);
	}

	function resetTransformInternal():Void {
		a = 1;
		b = 0;
		c = 0;
		d = 1;
		e = 0;
		f = 0;
	}

	inline function toDeviceX(x:Float, y:Float):Float {
		return a * x + c * y + e;
	}

	inline function toDeviceY(x:Float, y:Float):Float {
		return b * x + d * y + f;
	}

	function invertMatrix():Mat6 {
		return inv6({a: a, b: b, c: c, d: d, e: e, f: f});
	}

	static function inv6(m:Mat6):Mat6 {
		var det = m.a * m.d - m.b * m.c;
		if (det == 0) return {a: 1.0, b: 0.0, c: 0.0, d: 1.0, e: 0.0, f: 0.0};
		var ia = m.d / det, ib = -m.b / det, ic = -m.c / det, id = m.a / det;
		return {
			a: ia,
			b: ib,
			c: ic,
			d: id,
			e: -(m.e * ia + m.f * ic),
			f: -(m.e * ib + m.f * id)
		};
	}

	static function matApply(m:Mat6, x:Float, y:Float):{x:Float, y:Float} {
		return {x: m.a * x + m.c * y + m.e, y: m.b * x + m.d * y + m.f};
	}

	// ---- 路径构造（构造时烘 CTM；用户坐标另存供描边几何） ----

	public function beginPath():Void {
		subpaths = [];
	}

	public function closePath():Void {
		if (subpaths.length > 0) subpaths[subpaths.length - 1].closed = true;
	}

	public function moveTo(x:Float, y:Float):Void {
		subpaths.push(mkSub(x, y));
	}

	public function lineTo(x:Float, y:Float):Void {
		if (subpaths.length == 0) {
			moveTo(x, y);
			return;
		}
		appendPoint(currentSub(), x, y);
	}

	public function rect(x:Float, y:Float, w:Float, h:Float):Void {
		var sp = mkSub(x, y);
		subpaths.push(sp);
		appendPoint(sp, x + w, y);
		appendPoint(sp, x + w, y + h);
		appendPoint(sp, x, y + h);
		sp.closed = true;
	}

	public function quadraticCurveTo(cx:Float, cy:Float, x:Float, y:Float):Void {
		if (subpaths.length == 0) moveTo(0, 0);
		var sp = currentSub();
		var p = sp.usr.length;
		var x0 = sp.usr[p - 2], y0 = sp.usr[p - 1];
		// 二次→三次提升（标准公式）后走三次压平
		flattenCubic(sp, x0, y0, x0 + 2.0 / 3.0 * (cx - x0), y0 + 2.0 / 3.0 * (cy - y0), x + 2.0 / 3.0 * (cx - x), y + 2.0
			/ 3.0 * (cy - y), x, y, 0);
	}

	public function bezierCurveTo(c1x:Float, c1y:Float, c2x:Float, c2y:Float, x:Float, y:Float):Void {
		if (subpaths.length == 0) moveTo(0, 0);
		var sp = currentSub();
		var p = sp.usr.length;
		var x0 = sp.usr[p - 2], y0 = sp.usr[p - 1];
		flattenCubic(sp, x0, y0, c1x, c1y, c2x, c2y, x, y, 0);
	}

	public function arc(x:Float, y:Float, radius:Float, startAngle:Float, endAngle:Float, ?counterclockwise:Bool):Void {
		if (radius < 0) radius = 0;
		var ccw = counterclockwise == true;
		var span = endAngle - startAngle;
		if (span == 0) return;
		// 全圆判定两个方向都收（WHATWG 只认 cw 方向的 end-start≥2π / ccw 方向的
		// start-end≥2π，(0,2π,true) 按规范字面是零弧），但 openfl 的唯一调用形态
		// 就是 arc(x,y,r,0,2π,true)（CanvasGraphics.hx:1092/2405，Cairo 后端同位
		// 传 false——意图明确是整圆），Chrome 把它渲染成整圆（openfl html5 圆形
		// 因此能显示）：跟 Chrome，否则资产里所有圆全部消失。
		if (Math.abs(span) >= Math.PI * 2 - 1e-9) {
			span = ccw ? -Math.PI * 2 : Math.PI * 2;
		} else if (ccw && span > 0) {
			span -= Math.PI * 2;
		} else if (!ccw && span < 0) {
			span += Math.PI * 2;
		}
		var n = Math.ceil(Math.abs(span) * Math.max(radius, 1) / 0.5);
		if (n < 6) n = 6;
		if (n > 128) n = 128;
		var startX = x + radius * Math.cos(startAngle);
		var startY = y + radius * Math.sin(startAngle);
		if (subpaths.length > 0) {
			lineTo(startX, startY); // 有当前点先连线到弧起点（规范）
		} else {
			moveTo(startX, startY);
		}
		var sp = currentSub();
		for (i in 1...n + 1) {
			var ang = startAngle + span * (i / n);
			appendPoint(sp, x + radius * Math.cos(ang), y + radius * Math.sin(ang));
		}
	}

	function mkSub(x:Float, y:Float):SubPath {
		return {
			usr: [x, y],
			dev: [toDeviceX(x, y), toDeviceY(x, y)],
			closed: false,
			m: {a: a, b: b, c: c, d: d, e: e, f: f}
		};
	}

	function currentSub():SubPath {
		return subpaths[subpaths.length - 1];
	}

	function appendPoint(sp:SubPath, x:Float, y:Float):Void {
		sp.usr.push(x);
		sp.usr.push(y);
		sp.dev.push(toDeviceX(x, y));
		sp.dev.push(toDeviceY(x, y));
	}

	/** 三次曲线压平：flatness 在设备空间测（用户空间小曲线可能被 CTM 放
	 * 大），分点在用户空间（de Casteljau），深度封顶 16 保确定终止。 */
	function flattenCubic(sp:SubPath, x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, depth:Int):Void {
		var flat = distToSeg(toDeviceX(x1, y1), toDeviceY(x1, y1), toDeviceX(x0, y0), toDeviceY(x0, y0), toDeviceX(x3, y3), toDeviceY(x3, y3))
			+ distToSeg(toDeviceX(x2, y2), toDeviceY(x2, y2), toDeviceX(x0, y0), toDeviceY(x0, y0), toDeviceX(x3, y3), toDeviceY(x3, y3));
		if (depth >= 16 || flat < 0.15) {
			appendPoint(sp, x3, y3);
			return;
		}
		var m01x = (x0 + x1) / 2, m01y = (y0 + y1) / 2;
		var m12x = (x1 + x2) / 2, m12y = (y1 + y2) / 2;
		var m23x = (x2 + x3) / 2, m23y = (y2 + y3) / 2;
		var ax = (m01x + m12x) / 2, ay = (m01y + m12y) / 2;
		var bx = (m12x + m23x) / 2, by = (m12y + m23y) / 2;
		var cx = (ax + bx) / 2, cy = (ay + by) / 2;
		flattenCubic(sp, x0, y0, m01x, m01y, ax, ay, cx, cy, depth + 1);
		flattenCubic(sp, cx, cy, bx, by, m23x, m23y, x3, y3, depth + 1);
	}

	static function distToSeg(px:Float, py:Float, x1:Float, y1:Float, x2:Float, y2:Float):Float {
		var dx = x2 - x1, dy = y2 - y1;
		var len = dx * dx + dy * dy;
		var t = len == 0 ? 0 : ((px - x1) * dx + (py - y1) * dy) / len;
		if (t < 0) t = 0;
		if (t > 1) t = 1;
		var qx = x1 + t * dx, qy = y1 + t * dy;
		return Math.sqrt((px - qx) * (px - qx) + (py - qy) * (py - qy));
	}

	// ---- 填充/描边/裁剪 ----

	public function fill(?ruleOrPath:Dynamic):Void {
		var polys = polysFor(ruleOrPath);
		var rule = Std.isOfType(ruleOrPath, String) ? cast(ruleOrPath, String) : "nonzero";
		paintPolys(polys, rule, fillStyle);
	}

	public function stroke():Void {
		if (width <= 0 || height <= 0) return;
		var mask = scratchB;
		mask.fill(0, mask.length, 0);
		for (sp in subpaths) {
			strokeSubpath(sp, mask);
		}
		var inv = invertMatrix();
		paintMask(mask, strokeStyle, inv);
	}

	public function clip(?ruleOrPath:Dynamic):Void {
		var polys = polysFor(ruleOrPath);
		var rule = Std.isOfType(ruleOrPath, String) ? cast(ruleOrPath, String) : "nonzero";
		var cov = Bytes.alloc(width * height);
		rasterize(polys, rule, cov, 255);
		clipMask = clipMask == null ? cov : andMask(clipMask, cov);
	}

	public function isPointInPath(x:Float, y:Float, ?rule:String):Bool {
		return windingAt(polysFor(null), toDeviceX(x, y), toDeviceY(x, y), rule == null ? "nonzero" : rule);
	}

	function polysFor(ruleOrPath:Dynamic):Array<Array<Float>> {
		if (Std.isOfType(ruleOrPath, SoftPath2D)) {
			// fill(path)：path 的用户坐标按当前 CTM 变换（规范）
			var p2:SoftPath2D = cast ruleOrPath;
			var out = [];
			for (sp in p2.subpaths) {
				var pts:Array<Float> = [];
				var i = 0;
				while (i + 1 < sp.usr.length) {
					pts.push(toDeviceX(sp.usr[i], sp.usr[i + 1]));
					pts.push(toDeviceY(sp.usr[i], sp.usr[i + 1]));
					i += 2;
				}
				if (pts.length >= 4) out.push(pts);
			}
			return out;
		}
		var out = [];
		for (sp in subpaths) {
			if (sp.dev.length >= 4) out.push(sp.dev);
		}
		return out;
	}

	/** 多边形集合 → 覆盖缓冲（value 写入；掩码/裁剪两用）。 */
	function rasterize(polys:Array<Array<Float>>, rule:String, cov:Bytes, value:Int):Void {
		if (width <= 0 || height <= 0) return;
		var edges = edgesOf(polys);
		scanlineFill(edges, rule, function(xa:Float, xb:Float, y:Int) {
			var x0 = Math.ceil(xa - 0.5);
			var x1 = Math.ceil(xb - 0.5) - 1;
			if (x0 < 0) x0 = 0;
			if (x1 >= width) x1 = width - 1;
			var base = y * width;
			while (x0 <= x1) {
				cov.set(base + x0, value);
				x0++;
			}
		});
	}

	function edgesOf(polys:Array<Array<Float>>):Array<Edge> {
		var edges:Array<Edge> = [];
		for (pts in polys) {
			var n = Std.int(pts.length / 2);
			if (n < 2) continue;
			for (i in 0...n) {
				var j = (i + 1) % n;
				addEdge(edges, pts[i * 2], pts[i * 2 + 1], pts[j * 2], pts[j * 2 + 1]);
			}
		}
		return edges;
	}

	static function addEdge(edges:Array<Edge>, x1:Float, y1:Float, x2:Float, y2:Float):Void {
		if (y1 == y2) return; // 水平边不参与扫描
		edges.push({x1: x1, y1: y1, x2: x2, y2: y2, dir: y2 > y1 ? 1 : -1});
	}

	/** 扫描线填充：像素中心 (x+0.5, y+0.5) 求交、按 x 排序、环绕计数切区间。 */
	function scanlineFill(edges:Array<Edge>, rule:String, paintRun:Float->Float->Int->Void):Void {
		if (edges.length == 0 || height <= 0 || width <= 0) return;
		for (y in 0...height) {
			var yt = y + 0.5;
			var xs:Array<Float> = [];
			var dirs:Array<Int> = [];
			for (ed in edges) {
				var hit = (ed.y1 <= yt && yt < ed.y2) || (ed.y2 <= yt && yt < ed.y1);
				if (!hit) continue;
				var t = (yt - ed.y1) / (ed.y2 - ed.y1);
				var x = ed.x1 + (ed.x2 - ed.x1) * t;
				var k = 0;
				var n = xs.length;
				while (k < n && (xs[k] < x || (xs[k] == x && dirs[k] <= ed.dir))) k++;
				xs.insert(k, x);
				dirs.insert(k, ed.dir);
			}
			if (xs.length < 2) continue;
			var winding = 0;
			var even = 0;
			var i = 0;
			while (i < xs.length - 1) {
				winding += dirs[i];
				even++;
				var inside = rule == "evenodd" ? (even % 2 == 1) : (winding != 0);
				if (inside && xs[i] < xs[i + 1]) {
					paintRun(xs[i], xs[i + 1], y);
				}
				i++;
			}
		}
	}

	/** 多边形上色：样式采样 + 合成（clip 生效）。 */
	function paintPolys(polys:Array<Array<Float>>, rule:String, style:Dynamic):Void {
		if (width <= 0 || height <= 0 || polys.length == 0) return;
		var edges = edgesOf(polys);
		if (edges.length == 0) return;
		var inv = invertMatrix();
		var sampler = styleSampler(style, inv);
		scanlineFill(edges, rule, function(xa:Float, xb:Float, y:Int) {
			var x0 = Math.ceil(xa - 0.5);
			var x1 = Math.ceil(xb - 0.5) - 1;
			if (x0 < 0) x0 = 0;
			if (x1 >= width) x1 = width - 1;
			var col = sampler(y);
			while (x0 <= x1) {
				blendPixel(x0, y, col(x0));
				x0++;
			}
		});
	}

	/** 掩码上色（描边整笔一次绘）：掩码非零像素 → 样式采样合成。 */
	function paintMask(mask:Bytes, style:Dynamic, inv:Mat6):Void {
		if (width <= 0 || height <= 0) return;
		var solid = tryParseColor(style);
		if (solid != null) {
			var c = solid;
			for (y in 0...height) {
				var base = y * width;
				for (x in 0...width) {
					if (mask.get(base + x) != 0) blendPixel(x, y, c);
				}
			}
			return;
		}
		var sampler = styleSampler(style, inv);
		for (y in 0...height) {
			var base = y * width;
			var rowOn = false;
			for (x in 0...width) {
				if (mask.get(base + x) != 0) {
					rowOn = true;
					break;
				}
			}
			if (!rowOn) continue;
			var col = sampler(y);
			for (x in 0...width) {
				if (mask.get(base + x) != 0) blendPixel(x, y, col(x));
			}
		}
	}

	/** 样式采样器：纯色行内零开销；渐变/图案逐像素经逆 CTM 采用户坐标。 */
	function styleSampler(style:Dynamic, inv:Mat6):(Int->(Int->ColorSample)) {
		var solid = tryParseColor(style);
		if (solid != null) {
			var c = solid;
			return function(y:Int) {
				return function(x:Int) {
					return c;
				};
			};
		}
		if (Std.isOfType(style, SoftGradient)) {
			var g:SoftGradient = cast style;
			return function(y:Int) {
				var v = y + 0.5;
				return function(x:Int) {
					var pt = matApply(inv, x + 0.5, v);
					return g.sample(pt.x, pt.y);
				};
			};
		}
		if (Std.isOfType(style, SoftPattern)) {
			var p:SoftPattern = cast style;
			var surf = surfaceOf(p.source);
			var pm:Mat6 = p.matrix == null ? {a: 1.0, b: 0.0, c: 0.0, d: 1.0, e: 0.0, f: 0.0} : {
				a: p.matrix.a,
				b: p.matrix.b,
				c: p.matrix.c,
				d: p.matrix.d,
				e: p.matrix.e,
				f: p.matrix.f
			};
			// 图案采样：用户坐标 → 图案矩阵逆 → 瓦片坐标
			var ipm = inv6(pm);
			return function(y:Int) {
				var v = y + 0.5;
				return function(x:Int) {
					var pt = matApply(inv, x + 0.5, v);
					var tp = matApply(ipm, pt.x, pt.y);
					return sampleSurface(surf, tp.x, tp.y, p.repetition);
				};
			};
		}
		// 无法识别（含 null——openfl 用 null 当「无填充」哨兵）：不绘制
		var none:ColorSample = {r: 0, g: 0, b: 0, a: 0};
		return function(y:Int) {
			return function(x:Int) {
				return none;
			};
		};
	}

	/** 位图源 → 采样面：canvas 元素用其帧缓冲；解码图（__softPixels）用
	 * 解码像素；其它（FakeImage 等无解码源）黑瓦 + 计数（每对象计一次）。 */
	function surfaceOf(source:Dynamic):SoftSurface {
		if (source == null) return blackTile();
		if (Std.isOfType(source, SoftCanvasElement)) {
			var el:SoftCanvasElement = cast source;
			var cc = el.ctx;
			if (cc == null || cc.width <= 0 || cc.height <= 0) return blackTile();
			return {w: cc.width, h: cc.height, rgba: cc.readPixelsStraight()};
		}
		var sp:Dynamic = Reflect.field(source, "__softPixels");
		if (sp != null) {
			return {w: sp.width, h: sp.height, rgba: sp.bytes};
		}
		if (Reflect.field(source, "__softFallback") != true) {
			Reflect.setField(source, "__softFallback", true);
			fallbackImageSources++;
		}
		return blackTile();
	}

	function blackTile():SoftSurface {
		var b = Bytes.alloc(4);
		b.set(3, 255);
		return {w: 1, h: 1, rgba: b};
	}

	function sampleSurface(surf:SoftSurface, u:Float, v:Float, repetition:String):ColorSample {
		if (surf.w <= 0 || surf.h <= 0) return {r: 0, g: 0, b: 0, a: 0};
		var x = Math.floor(u);
		var y = Math.floor(v);
		if (repetition != "no-repeat") {
			x = x % surf.w;
			if (x < 0) x += surf.w;
			y = y % surf.h;
			if (y < 0) y += surf.h;
		} else {
			if (x < 0 || x >= surf.w || y < 0 || y >= surf.h) return {r: 0, g: 0, b: 0, a: 0};
		}
		var o = (y * surf.w + x) * 4;
		return {r: surf.rgba.get(o), g: surf.rgba.get(o + 1), b: surf.rgba.get(o + 2), a: surf.rgba.get(o + 3)};
	}

	// ---- 描边几何 ----

	function strokeSubpath(sp:SubPath, mask:Bytes):Void {
		var n = Std.int(sp.usr.length / 2);
		if (n == 0) return;
		var half = lineWidth / 2;
		if (half <= 0) return;
		var cap = lineCap == null ? "butt" : lineCap;
		var join = lineJoin == null ? "miter" : lineJoin;

		if (n == 1) {
			// 单点子路径：butt 无、round/square 画点
			if (cap != "butt") fillDisk(mask, sp.usr[0], sp.usr[1], half, sp);
			return;
		}

		var closed = sp.closed;
		for (i in 0...n - 1) {
			edgeQuad(mask, sp, i, i + 1, half);
		}
		if (closed) {
			edgeQuad(mask, sp, n - 1, 0, half);
		}
		var jointCount = closed ? n : n - 1;
		for (i in 0...jointCount) {
			var prev = (i == 0) ? (closed ? n - 1 : i) : i - 1;
			joinEdge(mask, sp, prev, i, (i + 1) % n, half, join);
		}
		if (!closed) {
			if (cap == "round") {
				fillDisk(mask, sp.usr[0], sp.usr[1], half, sp);
				var last = (n - 1) * 2;
				fillDisk(mask, sp.usr[last], sp.usr[last + 1], half, sp);
			} else if (cap == "square") {
				capSquare(mask, sp, 0, 1, half);
				capSquare(mask, sp, n - 1, n - 2, half);
			}
		}
	}

	/** 边四边形（用户空间 ± 法向偏移 → 顶点经子路径构造 CTM 变换进设备）。 */
	function edgeQuad(mask:Bytes, sp:SubPath, i:Int, j:Int, half:Float):Void {
		var x0 = sp.usr[i * 2], y0 = sp.usr[i * 2 + 1];
		var x1 = sp.usr[j * 2], y1 = sp.usr[j * 2 + 1];
		var dx = x1 - x0, dy = y1 - y0;
		var len = Math.sqrt(dx * dx + dy * dy);
		if (len <= 0) return;
		var nx = -dy / len * half, ny = dx / len * half;
		fillPolyMask(mask, sp, [x0 - nx, y0 - ny, x1 - nx, y1 - ny, x1 + nx, y1 + ny, x0 + nx, y0 + ny]);
	}

	function fillPolyMask(mask:Bytes, sp:SubPath, usrPts:Array<Float>):Void {
		var dev:Array<Float> = [];
		var m = sp.m;
		var i = 0;
		while (i + 1 < usrPts.length) {
			var x = usrPts[i], y = usrPts[i + 1];
			dev.push(m.a * x + m.c * y + m.e);
			dev.push(m.b * x + m.d * y + m.f);
			i += 2;
		}
		var cov = scratchA;
		cov.fill(0, cov.length, 0);
		rasterize([dev], "nonzero", cov, 255);
		orMask(mask, cov);
	}

	function fillDisk(mask:Bytes, ux:Float, uy:Float, radius:Float, sp:SubPath):Void {
		var n = Math.ceil(Math.PI * radius / 1.0);
		if (n < 8) n = 8;
		if (n > 64) n = 64;
		var dev:Array<Float> = [];
		var m = sp.m;
		for (i in 0...n) {
			var ang = Math.PI * 2 * i / n;
			var x = ux + radius * Math.cos(ang);
			var y = uy + radius * Math.sin(ang);
			dev.push(m.a * x + m.c * y + m.e);
			dev.push(m.b * x + m.d * y + m.f);
		}
		var cov = scratchA;
		cov.fill(0, cov.length, 0);
		rasterize([dev], "nonzero", cov, 255);
		orMask(mask, cov);
	}

	function capSquare(mask:Bytes, sp:SubPath, endIdx:Int, innerIdx:Int, half:Float):Void {
		var ex = sp.usr[endIdx * 2], ey = sp.usr[endIdx * 2 + 1];
		var ix = sp.usr[innerIdx * 2], iy = sp.usr[innerIdx * 2 + 1];
		var dx = ex - ix, dy = ey - iy;
		var len = Math.sqrt(dx * dx + dy * dy);
		if (len <= 0) return;
		var tx = dx / len * half, ty = dy / len * half;
		var nx = -ty, ny = tx;
		fillPolyMask(mask, sp, [ex - nx, ey - ny, ex + nx, ey + ny, ex + nx + tx, ey + ny + ty, ex - nx + tx, ey - ny + ty]);
	}

	function joinEdge(mask:Bytes, sp:SubPath, prev:Int, joint:Int, next:Int, half:Float, join:String):Void {
		var pjx = sp.usr[joint * 2], pjy = sp.usr[joint * 2 + 1];
		var ppx = sp.usr[prev * 2], ppy = sp.usr[prev * 2 + 1];
		var pnx = sp.usr[next * 2], pny = sp.usr[next * 2 + 1];
		var tax = pjx - ppx, tay = pjy - ppy;
		var tbx = pnx - pjx, tby = pny - pjy;
		var la = Math.sqrt(tax * tax + tay * tay);
		var lb = Math.sqrt(tbx * tbx + tby * tby);
		if (la <= 0 || lb <= 0) return;
		tax /= la;
		tay /= la;
		tbx /= lb;
		tby /= lb;
		var cross = tax * tby - tay * tbx;
		if (Math.abs(cross) < 1e-12) return; // 共线无接头
		// 外侧法向：左转（cross>0）取切线右侧
		var side = cross > 0 ? 1.0 : -1.0;
		var nax = tay * side, nay = -tax * side;
		var nbx = tby * side, nby = -tbx * side;
		var pax = pjx + nax * half, pay = pjy + nay * half;
		var pbx = pjx + nbx * half, pby = pjy + nby * half;
		if (join == "round") {
			fillDisk(mask, pjx, pjy, half, sp);
			return;
		}
		if (join == "bevel") {
			fillPolyMask(mask, sp, [pax, pay, pbx, pby, pjx, pjy]);
			return;
		}
		// miter：两外侧偏置线交点；miter 长宽比超 miterLimit 降级 bevel
		var denom = tax * (-tby) - tay * (-tbx);
		if (Math.abs(denom) < 1e-12) {
			fillPolyMask(mask, sp, [pax, pay, pbx, pby, pjx, pjy]);
			return;
		}
		var qx = pbx - pax, qy = pby - pay;
		var s = (qx * (-tby) - qy * (-tbx)) / denom;
		var mx = pax + tax * s, my = pay + tay * s;
		var miterLen = Math.sqrt((mx - pjx) * (mx - pjx) + (my - pjy) * (my - pjy));
		var limit = miterLimit <= 0 ? 10.0 : miterLimit;
		if (miterLen / lineWidth > limit) {
			fillPolyMask(mask, sp, [pax, pay, pbx, pby, pjx, pjy]);
			return;
		}
		fillPolyMask(mask, sp, [pax, pay, mx, my, pbx, pby, pjx, pjy]);
	}

	function orMask(dst:Bytes, src:Bytes):Void {
		var n = width * height;
		for (i in 0...n) {
			if (src.get(i) != 0) dst.set(i, 255);
		}
	}

	function andMask(a:Bytes, b:Bytes):Bytes {
		var out = Bytes.alloc(width * height);
		var n = width * height;
		for (i in 0...n) {
			out.set(i, a.get(i) != 0 && b.get(i) != 0 ? 255 : 0);
		}
		return out;
	}

	// ---- 像素合成 ----

	function blendPixel(x:Int, y:Int, col:ColorSample):Void {
		if (x < 0 || x >= width || y < 0 || y >= height) return;
		if (clipMask != null && clipMask.get(y * width + x) == 0) return;
		var ga = globalAlpha;
		if (ga < 0) ga = 0;
		if (ga > 1) ga = 1;
		var alpha = col.a / 255.0 * ga;
		if (alpha <= 0) return;
		if (alpha > 1) alpha = 1;
		var o = (y * width + x) * 4;
		if (globalCompositeOperation == "lighter") {
			// 相加（预乘空间逐通道饱和截断）
			data.set(o, clamp255(data.get(o) + Math.round(col.r * alpha)));
			data.set(o + 1, clamp255(data.get(o + 1) + Math.round(col.g * alpha)));
			data.set(o + 2, clamp255(data.get(o + 2) + Math.round(col.b * alpha)));
			data.set(o + 3, clamp255(data.get(o + 3) + Math.round(alpha * 255)));
			return;
		}
		if (alpha >= 1) {
			data.set(o, col.r);
			data.set(o + 1, col.g);
			data.set(o + 2, col.b);
			data.set(o + 3, 255);
			return;
		}
		// source-over（预乘）
		var ai = Math.round(alpha * 255);
		var keep = 255 - ai;
		data.set(o, clamp255(Math.round(col.r * alpha) + Math.round(data.get(o) * keep / 255.0)));
		data.set(o + 1, clamp255(Math.round(col.g * alpha) + Math.round(data.get(o + 1) * keep / 255.0)));
		data.set(o + 2, clamp255(Math.round(col.b * alpha) + Math.round(data.get(o + 2) * keep / 255.0)));
		data.set(o + 3, clamp255(ai + Math.round(data.get(o + 3) * keep / 255.0)));
	}

	static function clamp255(v:Int):Int {
		return v < 0 ? 0 : (v > 255 ? 255 : v);
	}

	// ---- 矩形直绘 ----

	public function clearRect(x:Float, y:Float, w:Float, h:Float):Void {
		// 规范：受 CTM 影响、不受 clip 限制（openfl/lime 只在恒等 CTM 用）
		var dev = transformPts([x, y, x + w, y, x + w, y + h, x, y + h]);
		var edges = edgesOf([dev]);
		scanlineFill(edges, "nonzero", function(xa:Float, xb:Float, y:Int) {
			var x0 = Math.ceil(xa - 0.5);
			var x1 = Math.ceil(xb - 0.5) - 1;
			if (x0 < 0) x0 = 0;
			if (x1 >= width) x1 = width - 1;
			while (x0 <= x1) {
				var o = (y * width + x0) * 4;
				data.set(o, 0);
				data.set(o + 1, 0);
				data.set(o + 2, 0);
				data.set(o + 3, opaque ? 255 : 0);
				x0++;
			}
		});
	}

	public function fillRect(x:Float, y:Float, w:Float, h:Float):Void {
		paintPolys([transformPts([x, y, x + w, y, x + w, y + h, x, y + h])], "nonzero", fillStyle);
	}

	function transformPts(pts:Array<Float>):Array<Float> {
		var out = [];
		var i = 0;
		while (i + 1 < pts.length) {
			out.push(toDeviceX(pts[i], pts[i + 1]));
			out.push(toDeviceY(pts[i], pts[i + 1]));
			i += 2;
		}
		return out;
	}

	// ---- drawImage ----

	public function drawImage(source:Dynamic, a1:Float, a2:Float, ?a3:Float, ?a4:Float, ?a5:Float, ?a6:Float, ?a7:Float, ?a8:Float):Void {
		var sx:Float, sy:Float, sw:Float, sh:Float, dx:Float, dy:Float, dw:Float, dh:Float;
		if (a3 == null) {
			dx = a1;
			dy = a2;
			var dim = sourceDims(source);
			sx = 0;
			sy = 0;
			sw = dim.w;
			sh = dim.h;
			dw = sw;
			dh = sh;
		} else if (a5 == null) {
			dx = a1;
			dy = a2;
			dw = a3;
			dh = a4;
			var dim = sourceDims(source);
			sx = 0;
			sy = 0;
			sw = dim.w;
			sh = dim.h;
		} else {
			sx = a1;
			sy = a2;
			sw = a3;
			sh = a4;
			dx = a5;
			dy = a6;
			dw = a7;
			dh = a8;
		}
		if (dw == 0 || dh == 0 || sw == 0 || sh == 0) return;
		var surf = surfaceOf(source);
		if (surf.w <= 0 || surf.h <= 0) return;
		var inv = invertMatrix();
		var corners = transformPts([dx, dy, dx + dw, dy, dx + dw, dy + dh, dx, dy + dh]);
		var minX = corners[0], maxX = corners[0], minY = corners[1], maxY = corners[1];
		var i = 2;
		while (i < 8) {
			if (corners[i] < minX) minX = corners[i];
			if (corners[i] > maxX) maxX = corners[i];
			if (corners[i + 1] < minY) minY = corners[i + 1];
			if (corners[i + 1] > maxY) maxY = corners[i + 1];
			i += 2;
		}
		var x0 = Math.floor(minX);
		var x1 = Math.ceil(maxX);
		var y0 = Math.floor(minY);
		var y1 = Math.ceil(maxY);
		for (py in y0...y1) {
			if (py < 0 || py >= height) continue;
			var v = py + 0.5;
			for (px in x0...x1) {
				if (px < 0 || px >= width) continue;
				var u = px + 0.5;
				var ux = inv.a * u + inv.c * v + inv.e;
				var uy = inv.b * u + inv.d * v + inv.f;
				var t = (ux - dx) / dw;
				var s = (uy - dy) / dh;
				if (t < 0 || t >= 1 || s < 0 || s >= 1) continue;
				var fx = Math.floor(sx + t * sw);
				var fy = Math.floor(sy + s * sh);
				if (fx < 0 || fx >= surf.w || fy < 0 || fy >= surf.h) continue;
				var o = (fy * surf.w + fx) * 4;
				blendPixel(px, py, {r: surf.rgba.get(o), g: surf.rgba.get(o + 1), b: surf.rgba.get(o + 2), a: surf.rgba.get(o + 3)});
			}
		}
	}

	function sourceDims(source:Dynamic):{w:Float, h:Float} {
		if (Std.isOfType(source, SoftCanvasElement)) {
			var el:SoftCanvasElement = cast source;
			return {w: el.ctx.width, h: el.ctx.height};
		}
		var w:Dynamic = Reflect.field(source, "width");
		var h:Dynamic = Reflect.field(source, "height");
		return {w: w == null ? 0 : w, h: h == null ? 0 : h};
	}

	// ---- 工厂 ----

	public function createPattern(source:Dynamic, repetition:String):SoftPattern {
		return new SoftPattern(source, repetition);
	}

	public function createLinearGradient(x0:Float, y0:Float, x1:Float, y1:Float):SoftGradient {
		return new SoftGradient("linear", x0, y0, 0, x1, y1, 0);
	}

	public function createRadialGradient(x0:Float, y0:Float, r0:Float, x1:Float, y1:Float, r1:Float):SoftGradient {
		return new SoftGradient("radial", x0, y0, r0, x1, y1, r1);
	}

	// ---- ImageData ----

	public function getImageData(sx:Float, sy:Float, w:Float, h:Float):SoftImageData {
		var x = Math.floor(sx), y = Math.floor(sy);
		var ww = Math.floor(w);
		var hh = Math.floor(h);
		if (ww < 0) ww = 0;
		if (hh < 0) hh = 0;
		var out = new SoftImageData(ww, hh);
		var src = unpremultiplyRegion(x, y, ww, hh);
		for (i in 0...ww * hh * 4) {
			out.setByte(i, src.get(i));
		}
		return out;
	}

	public function putImageData(imagedata:Dynamic, dx:Float, dy:Float):Void {
		// 规范：像素替换（非合成）、不受 CTM/clip 影响
		var arr:Dynamic = Reflect.field(imagedata, "data");
		var w:Dynamic = Reflect.field(imagedata, "width");
		var h:Dynamic = Reflect.field(imagedata, "height");
		if (arr == null || w == null || h == null) return;
		var wi = Std.int(w), hi = Std.int(h);
		var x0 = Math.floor(dx), y0 = Math.floor(dy);
		for (j in 0...hi) {
			for (i in 0...wi) {
				var px = x0 + i, py = y0 + j;
				if (px < 0 || px >= width || py < 0 || py >= height) continue;
				var s = (j * wi + i) * 4;
				var d = (py * width + px) * 4;
				var a = byteAt(arr, s + 3);
				var r = byteAt(arr, s), g = byteAt(arr, s + 1), b = byteAt(arr, s + 2);
				if (a == 0) {
					r = 0;
					g = 0;
					b = 0;
				} else {
					r = prem(r, a);
					g = prem(g, a);
					b = prem(b, a);
				}
				data.set(d, r);
				data.set(d + 1, g);
				data.set(d + 2, b);
				data.set(d + 3, a);
			}
		}
	}

	static function byteAt(arr:Dynamic, i:Int):Int {
		#if js
		return js.Syntax.code("{0}[{1}]", arr, i);
		#else
		var b:Bytes = arr;
		return b.get(i);
		#end
	}

	public function createImageData(a:Dynamic, ?b:Float):SoftImageData {
		var w:Int, h:Int;
		if (b != null) {
			w = Math.floor(a);
			h = Math.floor(b);
		} else {
			w = Reflect.field(a, "width");
			h = Reflect.field(a, "height");
		}
		return new SoftImageData(w, h);
	}

	function unpremultiplyRegion(sx:Int, sy:Int, w:Int, h:Int):Bytes {
		var out = Bytes.alloc(w * h * 4);
		for (j in 0...h) {
			for (i in 0...w) {
				var px = sx + i, py = sy + j;
				var o = (j * w + i) * 4;
				if (px < 0 || px >= width || py < 0 || py >= height) continue;
				var s = (py * width + px) * 4;
				var pa = data.get(s + 3);
				out.set(o, pa == 0 ? 0 : unprem(data.get(s), pa));
				out.set(o + 1, pa == 0 ? 0 : unprem(data.get(s + 1), pa));
				out.set(o + 2, pa == 0 ? 0 : unprem(data.get(s + 2), pa));
				out.set(o + 3, pa);
			}
		}
		return out;
	}

	static inline function unprem(v:Int, a:Int):Int {
		return clamp255(Math.round(v * 255 / a));
	}

	static inline function prem(v:Int, a:Int):Int {
		return clamp255(Math.round(v * a / 255));
	}

	// ---- 文本（布局保真、字形盲区：每字符画实心盒） ----

	public function measureText(text:String):{width:Float} {
		return {width: textWidth(text, parseFont().size)};
	}

	public function fillText(text:String, x:Float, y:Float):Void {
		fillTextCalls++;
		var size = parseFont().size;
		var asc = size * 0.8;
		var cx = x;
		for (i in 0...text.length) {
			var ch = text.charAt(i);
			var adv = charAdvance(ch, size);
			if (ch != " ") {
				// 字形盒：基线上方 asc 起、高 size（确定性占位，非字形）
				fillRectGlyph(cx + 0.5, y - asc, adv - 1.0, size);
			}
			cx += adv;
		}
	}

	function fillRectGlyph(x:Float, y:Float, w:Float, h:Float):Void {
		if (w <= 0 || h <= 0) return;
		paintPolys([transformPts([x, y, x + w, y, x + w, y + h, x, y + h])], "nonzero", fillStyle);
	}

	function textWidth(text:String, size:Float):Float {
		var w = 0.0;
		for (i in 0...text.length) {
			w += charAdvance(text.charAt(i), size);
		}
		return w;
	}

	function charAdvance(ch:String, size:Float):Float {
		// 确定性字宽（无字体度量）：布局（换行/组位置）由它驱动 → 进基线；
		// 字形形状本身是盲区（fillTextCalls 计数）。
		if (ch == " ") return size * 0.3;
		if ("iljt.,'|!".indexOf(ch) >= 0) return size * 0.28;
		if ("mwMW@".indexOf(ch) >= 0) return size * 0.9;
		return size * 0.55;
	}

	function parseFont():{size:Float} {
		var re = ~/([0-9]+(?:\.[0-9]+)?)(px|pt)\s+/;
		if (re.match(font)) {
			var size = Std.parseFloat(re.matched(1));
			if (re.matched(2) == "pt") size = size * 96 / 72;
			return {size: size};
		}
		return {size: 10.0};
	}

	// ---- 样式解析 ----

	static function tryParseColor(style:Dynamic):Null<ColorSample> {
		if (style == null || !Std.isOfType(style, String)) return null;
		return parseColor(cast style, null);
	}

	/** "#RRGGBB" / "#RGB" / "rgb(...)" / "rgba(...)" / 色名；openfl 只产前
	 * 四种（StringTools.hex / getRGBA），色名兜底。未知 → fallback。 */
	public static function parseColor(s:String, fallback:Null<ColorSample>):Null<ColorSample> {
		if (s == null) return fallback;
		s = StringTools.trim(s);
		if (s.charAt(0) == "#") {
			var hex = s.substr(1);
			if (hex.length == 3) {
				var r = parseHex(hex.charAt(0) + hex.charAt(0));
				var g = parseHex(hex.charAt(1) + hex.charAt(1));
				var b = parseHex(hex.charAt(2) + hex.charAt(2));
				if (r < 0 || g < 0 || b < 0) return fallback;
				return {r: r, g: g, b: b, a: 255};
			}
			if (hex.length == 6) {
				var r = parseHex(hex.substr(0, 2));
				var g = parseHex(hex.substr(2, 2));
				var b = parseHex(hex.substr(4, 2));
				if (r < 0 || g < 0 || b < 0) return fallback;
				return {r: r, g: g, b: b, a: 255};
			}
			return fallback;
		}
		var re = ~/^rgba?\s*\(([^)]*)\)$/;
		if (re.match(s)) {
			var parts = re.matched(1).split(",");
			if (parts.length >= 3) {
				var r = Std.parseInt(StringTools.trim(parts[0]));
				var g = Std.parseInt(StringTools.trim(parts[1]));
				var b = Std.parseInt(StringTools.trim(parts[2]));
				if (r == null || g == null || b == null) return fallback;
				var a = 255;
				if (parts.length >= 4) {
					a = Math.round(Std.parseFloat(StringTools.trim(parts[3])) * 255);
				}
				return {r: clamp255(r), g: clamp255(g), b: clamp255(b), a: clamp255(a)};
			}
		}
		if (s == "transparent") return {r: 0, g: 0, b: 0, a: 0};
		return switch (s) {
			case "black": {r: 0, g: 0, b: 0, a: 255};
			case "white": {r: 255, g: 255, b: 255, a: 255};
			case "red": {r: 255, g: 0, b: 0, a: 255};
			case "green": {r: 0, g: 128, b: 0, a: 255};
			case "blue": {r: 0, g: 0, b: 255, a: 255};
			case "yellow": {r: 255, g: 255, b: 0, a: 255};
			case "gray" | "grey": {r: 128, g: 128, b: 128, a: 255};
			default: fallback;
		}
	}

	static function parseHex(h:String):Int {
		if (h.length != 2) return -1;
		var v = 0;
		for (i in 0...2) {
			var c = h.charCodeAt(i);
			var d = -1;
			if (c >= 48 && c <= 57) d = c - 48;
			else if (c >= 97 && c <= 102) d = c - 87;
			else if (c >= 65 && c <= 70) d = c - 55;
			if (d < 0) return -1;
			v = v * 16 + d;
		}
		return v;
	}

	// ---- 环绕判定（isPointInPath） ----

	function windingAt(polys:Array<Array<Float>>, px:Float, py:Float, rule:String):Bool {
		var winding = 0;
		var even = 0;
		for (pts in polys) {
			var n = Std.int(pts.length / 2);
			for (i in 0...n) {
				var j = (i + 1) % n;
				var y1 = pts[i * 2 + 1], y2 = pts[j * 2 + 1];
				var hit = (y1 <= py && py < y2) || (y2 <= py && py < y1);
				if (!hit) continue;
				var t = (py - y1) / (y2 - y1);
				var x = pts[i * 2] + (pts[j * 2] - pts[i * 2]) * t;
				if (x > px) {
					winding += y2 > y1 ? 1 : -1;
					even++;
				}
			}
		}
		return rule == "evenodd" ? (even % 2 == 1) : (winding != 0);
	}
}

/** getImageData/createImageData 的返回物：data 在 js 上必须是真 Uint8Array
 * （lime convertToData 取 .data.buffer 建 UInt8Array 视图）；eval 下用
 * Bytes（供单测）。 */
