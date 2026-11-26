package mx.core;

import mx.utils.NameUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

// mx.core.FlexBitmap —— FlexBitmap.as 逐句对应（issue #86 牧场库底座，Flex
// 资产壳片）。Bitmap 子类：构造时经 NameUtil 起唯一名，toString 走
// displayObjectToString。
// 原版 VERSION 带 mx_internal namespace 修饰（包内可见），平铺成 public。
@:keep
class FlexBitmap extends Bitmap {
	// FlexBitmap.as:12（mx_internal static const）
	public static final VERSION:String = "3.2.0.3958";

	// FlexBitmap.as:14-27
	public function new(param1:BitmapData = null, param2:String = "auto", param3:Bool = false) {
		var bitmapData:BitmapData = param1;
		var pixelSnapping:String = param2;
		var smoothing:Bool = param3;
		super(bitmapData, pixelSnapping, smoothing);
		try {
			this.name = NameUtil.createUniqueName(this);
		} catch (e:Dynamic) {}
	}

	// FlexBitmap.as:29-32
	public override function toString():String {
		return NameUtil.displayObjectToString(this);
	}
}
