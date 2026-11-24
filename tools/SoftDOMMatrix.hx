package;

@:keep
class SoftDOMMatrix {
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
	public var e:Float;
	public var f:Float;

	public function new(?init:Dynamic) {
		if (init != null && Std.isOfType(init, Array)) {
			var arr:Array<Float> = cast init;
			if (arr.length >= 6) {
				a = arr[0];
				b = arr[1];
				c = arr[2];
				d = arr[3];
				e = arr[4];
				f = arr[5];
				return;
			}
			if (arr.length >= 16) {
				a = arr[0];
				b = arr[1];
				c = arr[4];
				d = arr[5];
				e = arr[12];
				f = arr[13];
				return;
			}
		}
		a = 1;
		b = 0;
		c = 0;
		d = 1;
		e = 0;
		f = 0;
	}

	public function inverse():SoftDOMMatrix {
		var m = new SoftDOMMatrix();
		var det = a * d - b * c;
		if (det == 0) return m; // 不可逆：恒等（真 DOMMatrix 抛错；量级罕见）
		var ia = d / det, ib = -b / det, ic = -c / det, id = a / det;
		m.a = ia;
		m.b = ib;
		m.c = ic;
		m.d = id;
		m.e = -(e * ia + f * ic);
		m.f = -(e * ib + f * id);
		return m;
	}
}
