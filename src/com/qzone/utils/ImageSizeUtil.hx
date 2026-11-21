package com.qzone.utils;

import openfl.errors.Error;

/**
 * com.qzone.utils.ImageSizeUtil —— issue #18 write-tests 签名 stub
 * （ImageSizeUtil.as 135 loc，farm-basic 收尾：工具函数片整类翻译）。
 * 图片适配矩形的纯数学（宽高缩放 + 居中/顶/底对齐），目标是带 width/height/
 * scaleX/scaleY/x/y 的 Dynamic（AS3 传 Object，DisplayObject 也满足）。
 * 风格常量是 Int 字面量，按惯例照抄；方法签名照抄，体 throw not implemented。
 */
class ImageSizeUtil {
	// ImageSizeUtil.as:8-20
	public static final NO_SCALE_CENTER:Int = 0;

	public static final SCALE_WITH_BIG_CENTER:Int = 1;

	public static final SCALE_WITH_SMALL:Int = 3;

	public static final SCALE_WITH_SMALL_TOP:Int = 5;

	public static final SCALE_WITH_SMALL_BUTTOM:Int = 6;

	public static final NO_HANDEL:Int = -1;

	public static final NO_SCALE_CENTER_AND_KEEP_IN_RECT:Int = 4;

	public function new() {}

	// :27-30
	public static function setSize1(param1:Dynamic, param2:Dynamic, param3:Float):Void {
		throw new Error("not implemented");
	}

	// :32-131
	public static function setSize2(param1:Dynamic, param2:Float, param3:Float, param4:Float, param5:Float,
			param6:Float):Void {
		throw new Error("not implemented");
	}
}
