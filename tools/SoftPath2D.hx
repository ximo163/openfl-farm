package;

import SoftDOMMatrix;

@:keep
class SoftPath2D {
	public var subpaths:Array<{usr:Array<Float>, closed:Bool}>;

	public function new(?source:SoftPath2D) {
		subpaths = [];
		if (source != null) {
			for (sp in source.subpaths) {
				subpaths.push({usr: sp.usr.slice(0), closed: sp.closed});
			}
		}
	}

	public function addPath(path:SoftPath2D, ?transform:SoftDOMMatrix):Void {
		for (sp in path.subpaths) {
			var pts = sp.usr.slice(0);
			if (transform != null) {
				var i = 0;
				while (i + 1 < pts.length) {
					var x = pts[i], y = pts[i + 1];
					pts[i] = transform.a * x + transform.c * y + transform.e;
					pts[i + 1] = transform.b * x + transform.d * y + transform.f;
					i += 2;
				}
			}
			subpaths.push({usr: pts, closed: sp.closed});
		}
	}

	public function moveTo(x:Float, y:Float):Void {
		subpaths.push({usr: [x, y], closed: false});
	}

	public function lineTo(x:Float, y:Float):Void {
		if (subpaths.length == 0) moveTo(0, 0);
		var sp = subpaths[subpaths.length - 1];
		sp.usr.push(x);
		sp.usr.push(y);
	}

	public function closePath():Void {
		if (subpaths.length > 0) subpaths[subpaths.length - 1].closed = true;
	}

	public function rect(x:Float, y:Float, w:Float, h:Float):Void {
		subpaths.push({usr: [x, y, x + w, y, x + w, y + h, x, y + h], closed: true});
	}

	public function quadraticCurveTo(cx:Float, cy:Float, x:Float, y:Float):Void {
		if (subpaths.length == 0) moveTo(0, 0);
		var sp = subpaths[subpaths.length - 1];
		var p = sp.usr.length;
		var x0 = p >= 2 ? sp.usr[p - 2] : 0.0, y0 = p >= 2 ? sp.usr[p - 1] : 0.0;
		// 8 段等参压平（构造期无 CTM 可依，设备空间 flatness 无法测）
		for (i in 1...9) {
			var t = i / 8.0;
			var mt = 1 - t;
			sp.usr.push(mt * mt * x0 + 2 * mt * t * cx + t * t * x);
			sp.usr.push(mt * mt * y0 + 2 * mt * t * cy + t * t * y);
		}
	}

	public function bezierCurveTo(c1x:Float, c1y:Float, c2x:Float, c2y:Float, x:Float, y:Float):Void {
		if (subpaths.length == 0) moveTo(0, 0);
		var sp = subpaths[subpaths.length - 1];
		var p = sp.usr.length;
		var x0 = p >= 2 ? sp.usr[p - 2] : 0.0, y0 = p >= 2 ? sp.usr[p - 1] : 0.0;
		for (i in 1...9) {
			var t = i / 8.0, mt = 1 - t;
			sp.usr.push(mt * mt * mt * x0 + 3 * mt * mt * t * c1x + 3 * mt * t * t * c2x + t * t * t * x);
			sp.usr.push(mt * mt * mt * y0 + 3 * mt * mt * t * c1y + 3 * mt * t * t * c2y + t * t * t * y);
		}
	}
}

/** DOMMatrix（openfl 非 PAD 渐变与位图描边矩阵用）：2D 仿射 + inverse()。 */
