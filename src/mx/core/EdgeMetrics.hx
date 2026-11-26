package mx.core;

// mx.core.EdgeMetrics —— EdgeMetrics.as 逐句对应（issue #86 牧场库底座，
// Flex 核心片）。四向边距值对象（scale9Grid 九宫格的边框度量）。
// 原版 VERSION 带 mx_internal namespace 修饰（包内可见），平铺成 public。
@:keep
class EdgeMetrics {
	// EdgeMetrics.as:8（mx_internal static const）
	public static final VERSION:String = "3.2.0.3958";

	// EdgeMetrics.as:10
	public static final EMPTY:EdgeMetrics = new EdgeMetrics(0, 0, 0, 0);

	// EdgeMetrics.as:12-18
	public var top:Float;

	public var left:Float;

	public var bottom:Float;

	public var right:Float;

	// EdgeMetrics.as:20-27
	public function new(param1:Float = 0, param2:Float = 0, param3:Float = 0, param4:Float = 0) {
		this.left = param1;
		this.top = param2;
		this.right = param3;
		this.bottom = param4;
	}

	// EdgeMetrics.as:29-32
	public function clone():EdgeMetrics {
		return new EdgeMetrics(this.left, this.top, this.right, this.bottom);
	}
}
