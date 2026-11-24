package;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.io.BytesInput;

/**
 * T2 资产渲染对拍——位图解码钩子（issue #57）。lime 在 js/html5 上把位图字节
 * 走 `Image.__fromBase64` → `js.Syntax.code('new window.Image()')` + data URI
 * src（lime/graphics/Image.hx:1433），真浏览器里由引擎解码；node 垫片的
 * FakeImage 是 1×1 假图（解码为零像素）。本类顶替 globalThis.Image：data URI
 * 到手即同步解码（监听器在 src 赋值前注册，lime 的用法保证同步派发可行），
 * 解出的直行 RGBA 放 __softPixels——SoftCanvasContext.surfaceOf 认这个字段，
 * drawImage/createPattern 采样走真像素。
 *
 * 解码能力边界（如实计数，不静默）：
 * - PNG：format.png.Reader + Tools.extract32（BGRA→RGBA 逐像素换序；调色板/
 *   tRNS/多 IDAT 由 format 处理）。
 * - JPEG：format 3.7.0 没有解码器（只有 Writer）——从 SOF 段取真实宽高，
 *   像素按全黑不透明兜底（104 张 jpg 资产的采样面是假的，计数进报告；
 *   换真 Flash 参考采集后这一盲区随源消失）。
 * - 其它/解码失败：1×1 黑不透明兜底 + decodeFailures 计数（原因进报告，
 *   不许无声变黑）。
 * 三个静态计数器供探针汇总进报告，reset() 每资产清零。
 */
class DecodingImage {
	/** 解码成功计数（按格式，报告覆盖数用）。 */
	static public var decodedPng:Int = 0;
	static public var decodedJpeg:Int = 0;
	/** 解码失败计数 + 前 8 条原因（data URI 坏、不认识的格式）。 */
	static public var decodeFailures:Array<String> = [];

	/** 供 SoftCanvasContext.surfaceOf 采样的解码结果（直行 RGBA）。 */
	public var __softPixels:{width:Int, height:Int, bytes:Bytes};

	public var width:Int = 0;
	public var height:Int = 0;
	/** onload/onerror 属性式回调（lime 用 addEventListener，这里只兜底）。 */
	public var onload:Dynamic;
	public var onerror:Dynamic;

	var listeners:Array<{type:String, fn:Dynamic}>;
	var srcUrl:String;

	public function new(?w:Int, ?h:Int) {
		if (w != null) width = w;
		if (h != null) height = h;
		listeners = [];
	}

	/** 顶替 globalThis.Image（window === globalThis，lime 的 new window.Image()
	 * 落到这里）。每次安装前 reset 计数由探针控制，本函数只做安装。 */
	static public function install():Void {
		#if js
		// Haxe js 的类本身就是构造函数，可以直接当全局构造器用
		js.Syntax.code("globalThis.Image = {0}", DecodingImage);
		// lime 生成的 js 是裸赋值 image.src = uri——不走 Haxe 的 set_src 方法
		// （方法只对本类静态调用方存在，外部 js 赋值落在普通字段上）。必须在
		// 原型上定义真访问器桥过去，解码才会被触发。
		js.Syntax.code("(function(cls) {
			Object.defineProperty(cls.prototype, 'src', {
				get: function() { return this.get_src(); },
				set: function(v) { this.set_src(v); },
				configurable: true
			});
		})({0})", DecodingImage);
		// lime 装库时位图走 HTML5HTTPRequest.loadImageFromBytes：先试
		// URL.createObjectURL(new Blob(...))，node 的 URL 没这个函数（直接
		// ReferenceError）；置 null 让 lime 走它自己的 data URI 分支（
		// HTML5HTTPRequest.hx:225-246 的 else），data URI 进 new Image().src
		// ——正好被上面的钩子同步解码。Blob 本身 node 有，构造不炸。
		js.Syntax.code("globalThis.URL.createObjectURL = function() { return null; }");
		#end
	}

	static public function resetCounters():Void {
		decodedPng = 0;
		decodedJpeg = 0;
		decodeFailures = new Array<String>();
	}

	public function addEventListener(type:String, listener:Dynamic, ?useCapture:Bool):Void {
		listeners.push({type: type, fn: listener});
	}

	/** 同步派发（lime 先 addEventListener 再赋 src，顺序保证监听不丢）。 */
	public function dispatch(type:String):Void {
		var evt = {type: type, target: this};
		for (l in listeners.copy()) {
			if (l.type == type) Reflect.callMethod(null, l.fn, [evt]);
		}
		var prop = type == "load" ? onload : (type == "error" ? onerror : null);
		if (prop != null) Reflect.callMethod(null, prop, [evt]);
	}

	public function set_src(v:String):String {
		srcUrl = v;
		decode(v);
		return v;
	}

	public function get_src():String {
		return srcUrl;
	}

	function decode(url:String):Void {
		var comma = url.indexOf(",");
		if (url.indexOf("data:") == 0 && comma > 0) {
			var bytes:Bytes = null;
			try {
				bytes = Base64.decode(url.substr(comma + 1));
			} catch (e:Dynamic) {
				// 落到下面的兜底，原因进 decodeFailures
			}
			if (bytes != null && bytes.length >= 8) {
				if (isPng(bytes)) {
					decodePng(bytes);
				} else if (isJpeg(bytes)) {
					decodeJpeg(bytes);
				}
			}
		}
		if (__softPixels == null) {
			// 兜底：1×1 黑不透明（surfaceOf 的 blackTile 同款），失败原因如实计数
			if (decodeFailures.length < 8) {
				var head = url.length > 60 ? url.substr(0, 60) : url;
				decodeFailures.push('位图解码失败（非 PNG/JPEG 或数据坏）: ${head}…');
			}
			width = 1;
			height = 1;
			var b = Bytes.alloc(4);
			b.set(3, 255);
			__softPixels = {width: 1, height: 1, bytes: b};
		}
		dispatch("load");
	}

	function isPng(b:Bytes):Bool {
		return b.get(0) == 0x89 && b.get(1) == 0x50 && b.get(2) == 0x4E && b.get(3) == 0x47;
	}

	function isJpeg(b:Bytes):Bool {
		return b.get(0) == 0xFF && b.get(1) == 0xD8;
	}

	function decodePng(bytes:Bytes):Void {
		try {
			var data = new format.png.Reader(new BytesInput(bytes)).read();
			var header = format.png.Tools.getHeader(data);
			var w = header.width;
			var h = header.height;
			// extract32 出 BGRA（format/png/Tools.hx:205）；swap 成直行 RGBA
			var bgra = format.png.Tools.extract32(data);
			var rgba = Bytes.alloc(w * h * 4);
			for (i in 0...w * h) {
				var o = i * 4;
				rgba.set(o, bgra.get(o + 2));
				rgba.set(o + 1, bgra.get(o + 1));
				rgba.set(o + 2, bgra.get(o));
				rgba.set(o + 3, bgra.get(o + 3));
			}
			__softPixels = {width: w, height: h, bytes: rgba};
			width = w;
			height = h;
			decodedPng++;
		} catch (e:Dynamic) {
			if (decodeFailures.length < 8) decodeFailures.push("PNG 解码异常: " + Std.string(e));
		}
	}

	function decodeJpeg(bytes:Bytes):Void {
		// format 3.7.0 无 JPEG 解码器：SOF0/1/2/3 段取真实宽高，像素全黑不透明
		var w = 0;
		var h = 0;
		var i = 2; // 越过 SOI
		while (i + 9 < bytes.length) {
			if (bytes.get(i) != 0xFF) {
				i++;
				continue;
			}
			var marker = bytes.get(i + 1);
			if (marker == 0xC0 || marker == 0xC1 || marker == 0xC2 || marker == 0xC3) {
				h = bytes.get(i + 5) * 256 + bytes.get(i + 6);
				w = bytes.get(i + 7) * 256 + bytes.get(i + 8);
				break;
			}
			if (marker == 0xD8 || (marker >= 0xD0 && marker <= 0xD9) || marker == 0x01) {
				i += 2; // 无长度字段的标记
				continue;
			}
			var len = bytes.get(i + 2) * 256 + bytes.get(i + 3);
			if (len < 2) break; // 流坏，停在 0 尺寸
			i += 2 + len;
		}
		if (w <= 0 || h <= 0) {
			if (decodeFailures.length < 8) decodeFailures.push("JPEG 尺寸解析失败（无 SOF 段）");
			return; // 落回 1×1 兜底
		}
		var b = Bytes.alloc(w * h * 4);
		for (o in 0...w * h) {
			b.set(o * 4 + 3, 255);
		}
		__softPixels = {width: w, height: h, bytes: b};
		width = w;
		height = h;
		decodedJpeg++;
	}
}
