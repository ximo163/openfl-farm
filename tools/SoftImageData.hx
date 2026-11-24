package;

@:keep
class SoftImageData {
	public var width:Int;
	public var height:Int;
	public var data:Dynamic;

	public function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
		#if js
		data = new js.lib.Uint8Array(width * height * 4);
		#else
		data = Bytes.alloc(width * height * 4);
		#end
	}

	public inline function getByte(i:Int):Int {
		#if js
		return js.Syntax.code("{0}[{1}]", data, i);
		#else
		return (cast data:Bytes).get(i);
		#end
	}

	@:allow(SoftCanvasContext)
	private inline function setByte(i:Int, v:Int):Void {
		#if js
		js.Syntax.code("{0}[{1}] = {2}", data, i, v);
		#else
		(cast data:Bytes).set(i, v);
		#end
	}
}

/** 安装入口：canvas 工厂 + Path2D/DOMMatrix 全局（node 环境）。 */
