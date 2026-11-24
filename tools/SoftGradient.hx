package;

import SoftCanvasContext;
import SoftTypes.ColorSample;

@:keep
class SoftGradient {
	public var kind:String; // "linear" | "radial"
	public var x0:Float;
	public var y0:Float;
	public var r0:Float;
	public var x1:Float;
	public var y1:Float;
	public var r1:Float;
	public var stops:Array<{pos:Float, c:ColorSample}>;

	public function new(kind:String, x0:Float, y0:Float, r0:Float, x1:Float, y1:Float, r1:Float) {
		this.kind = kind;
		this.x0 = x0;
		this.y0 = y0;
		this.r0 = r0;
		this.x1 = x1;
		this.y1 = y1;
		this.r1 = r1;
		stops = [];
	}

	public function addColorStop(offset:Float, color:String):Void {
		var c = SoftCanvasContext.parseColor(color, null);
		if (c == null) c = {r: 0, g: 0, b: 0, a: 0};
		stops.push({pos: offset, c: c});
		stops.sort(function(a, b) return a.pos < b.pos ? -1 : 1);
	}

	/** 用户空间点 → 颜色。t 按规范：linear = 梯度线投影；radial = 半径插值。 */
	public function sample(u:Float, v:Float):ColorSample {
		var t:Float;
		if (kind == "linear") {
			var dx = x1 - x0, dy = y1 - y0;
			var len = dx * dx + dy * dy;
			t = len <= 0 ? 0 : ((u - x0) * dx + (v - y0) * dy) / len;
		} else {
			var dx = u - x0, dy = v - y0;
			var dist = Math.sqrt(dx * dx + dy * dy);
			var span = r1 - r0;
			t = span == 0 ? (dist >= r1 ? 1 : 0) : (dist - r0) / span;
		}
		if (t < 0) t = 0;
		if (t > 1) t = 1;
		if (stops.length == 0) return {r: 0, g: 0, b: 0, a: 0};
		if (t <= stops[0].pos) return stops[0].c;
		var last = stops[stops.length - 1];
		if (t >= last.pos) return last.c;
		var i = 0;
		while (i < stops.length - 1 && stops[i + 1].pos < t) i++;
		var sa = stops[i], sb = stops[i + 1];
		var span = sb.pos - sa.pos;
		if (span <= 0) return sb.c;
		var f = (t - sa.pos) / span;
		return {
			r: Math.round(sa.c.r + (sb.c.r - sa.c.r) * f),
			g: Math.round(sa.c.g + (sb.c.g - sa.c.g) * f),
			b: Math.round(sa.c.b + (sb.c.b - sa.c.b) * f),
			a: Math.round(sa.c.a + (sb.c.a - sb.c.a) * f)
		};
	}
}

/** 图案（createPattern 产物）。canvas 语义：瓦片按「fill 时 CTM ∘ 图案自身
 * 矩阵」放置；pattern.setTransform(DOMMatrix) 换锚（openfl 位图描边矩阵
 * 走这条路）。 */
