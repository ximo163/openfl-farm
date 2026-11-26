package mx.core;

// mx.core.MovieClipAsset —— MovieClipAsset.as 逐句对应（issue #86 牧场库底座，
// Flex 资产壳片）。嵌入剪辑资产的载体：构造时快照原始尺寸为 measured 值，
// borderMetrics 从 scale9Grid 推九宫格边距。
// 原版 VERSION 带 mx_internal namespace 修饰（包内可见），平铺成 public。
// PORT-NOTE: 原版 implements IFlexAsset, IFlexDisplayObject, IBorder。
// IFlexDisplayObject 落不了 implements（成员签名与 openfl DisplayObject 属性
// 类型结构性不合，见 BitmapAsset 头注）；IBorder 是单 getter 接口，
// get_borderMetrics 本类就带，implements 照带。
@:keep
class MovieClipAsset extends FlexMovieClip implements IFlexAsset implements IBorder {
	// MovieClipAsset.as:8（mx_internal static const）
	public static final VERSION:String = "3.2.0.3958";

	// MovieClipAsset.as:10-12
	private var _measuredHeight:Float;

	private var _measuredWidth:Float;

	// MovieClipAsset.as:14-19
	public function new() {
		super();
		this._measuredWidth = this.width;
		this._measuredHeight = this.height;
	}

	// MovieClipAsset.as:21-24
	public var measuredWidth(get, never):Float;

	private function get_measuredWidth():Float {
		return this._measuredWidth;
	}

	// MovieClipAsset.as:26-29
	public var measuredHeight(get, never):Float;

	private function get_measuredHeight():Float {
		return this._measuredHeight;
	}

	// MovieClipAsset.as:31-35
	public function setActualSize(param1:Float, param2:Float):Void {
		this.width = param1;
		this.height = param2;
	}

	// MovieClipAsset.as:37-41
	public function move(param1:Float, param2:Float):Void {
		this.x = param1;
		this.y = param2;
	}

	// MovieClipAsset.as:43-50（get_borderMetrics 须 public——IBorder 接口
	// 实现的 Haxe 可见性要求；AS3 无此约束，接口面即 public 语义不变）
	public var borderMetrics(get, never):EdgeMetrics;

	public function get_borderMetrics():EdgeMetrics {
		if (this.scale9Grid == null) {
			return EdgeMetrics.EMPTY;
		}
		return new EdgeMetrics(this.scale9Grid.left, this.scale9Grid.top, Math.ceil(this.measuredWidth - this.scale9Grid.right),
			Math.ceil(this.measuredHeight - this.scale9Grid.bottom));
	}
}
