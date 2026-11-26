package mx.core;

import openfl.display.BitmapData;

// mx.core.BitmapAsset —— BitmapAsset.as 逐句对应（issue #86 牧场库底座，Flex
// 资产壳片）。嵌入位图资产的载体：measuredWidth/Height 报位图原始尺寸。
// 原版 VERSION 带 mx_internal namespace 修饰（包内可见），平铺成 public。
// PORT-NOTE: 原版 implements IFlexAsset, IFlexDisplayObject。IFlexAsset 照带；
// IFlexDisplayObject 落不了 implements——它的成员签名（blendMode:String、
// filters:Array、opaqueBackground:Object、accessibilityProperties…）与 openfl
// DisplayObject 的属性类型（BlendMode 枚举抽象、Array<BitmapFilter>、
// Null<Int>、整个 accessibility 包缺失）结构性不合，Haxe 接口满足检查直接红。
// 原版运行期无人以 IFlexDisplayObject 静态类型取用（Master2 全脚本零引用，
// 见 issue #86 排查），省略 implements 不改变任何实际行为。
@:keep
class BitmapAsset extends FlexBitmap implements IFlexAsset {
	// BitmapAsset.as:10（mx_internal static const）
	public static final VERSION:String = "3.2.0.3958";

	// BitmapAsset.as:12-15
	public function new(param1:BitmapData = null, param2:String = "auto", param3:Bool = false) {
		super(param1, param2, param3);
	}

	// BitmapAsset.as:17-24
	public var measuredWidth(get, never):Float;

	private function get_measuredWidth():Float {
		if (this.bitmapData != null) {
			return this.bitmapData.width;
		}
		return 0;
	}

	// BitmapAsset.as:26-33
	public var measuredHeight(get, never):Float;

	private function get_measuredHeight():Float {
		if (this.bitmapData != null) {
			return this.bitmapData.height;
		}
		return 0;
	}

	// BitmapAsset.as:35-39
	public function setActualSize(param1:Float, param2:Float):Void {
		this.width = param1;
		this.height = param2;
	}

	// BitmapAsset.as:41-45
	public function move(param1:Float, param2:Float):Void {
		this.x = param1;
		this.y = param2;
	}
}
