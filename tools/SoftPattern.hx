package;

import SoftDOMMatrix;

@:keep
class SoftPattern {
	public var source:Dynamic;
	public var repetition:String;
	public var matrix:SoftDOMMatrix;

	public function new(source:Dynamic, repetition:String) {
		this.source = source;
		this.repetition = repetition == null ? "repeat" : repetition;
	}

	public function setTransform(matrix:SoftDOMMatrix):Void {
		this.matrix = matrix;
	}
}

/** Path2D（openfl 非 PAD 渐变路径用）。坐标存用户空间、在 fill(path) 时被
 * 当时 CTM 变换（与 ctx 当前路径「构造时烘死」相反——canvas 规范如此）。 */
