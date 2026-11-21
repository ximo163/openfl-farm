package com.qzone.utils;

/**
 * com.qzone.utils.ImageSizeUtil —— ImageSizeUtil.as 逐句对应（issue #18
 * farm-basic 收尾：工具函数片整类翻译）。图片适配矩形的纯数学（宽高缩放 +
 * 居中/顶/底对齐），目标是带 width/height/scaleX/scaleY/x/y 的 Dynamic
 * （AS3 传 Object，DisplayObject/Loader 也走同一属性形态）。
 *
 * PORT-NOTE: 属性读写走 Reflect.setProperty/getProperty —— param1 是 Dynamic，
 * 裸 `param1.x = v` 在 js 目标上对 openfl 对象只写影子字段（typed 读回 0），
 * Reflect 才会分发到 set_x；对匿名对象两写法等价，eval 上裸写直接抛错。
 * mode 3/5/6 的 else 分支把 param4（矩形宽）赋给 height（:66/:106/:122），
 * 原版笔误逐字保留（deviations 候选）。
 */
class ImageSizeUtil {
	// ImageSizeUtil.as:8-20（风格常量原样，含拼写 HANDEL/BUTTOM）
	public static final NO_SCALE_CENTER:Int = 0;

	public static final SCALE_WITH_BIG_CENTER:Int = 1;

	public static final SCALE_WITH_SMALL:Int = 3;

	public static final SCALE_WITH_SMALL_TOP:Int = 5;

	public static final SCALE_WITH_SMALL_BUTTOM:Int = 6;

	public static final NO_HANDEL:Int = -1;

	public static final NO_SCALE_CENTER_AND_KEEP_IN_RECT:Int = 4;

	private static var __style:Float;

	public function new() {}

	// :27-30
	public static function setSize1(param1:Dynamic, param2:Dynamic, param3:Float):Void {
		setSize2(param1, Reflect.getProperty(param2, "x"), Reflect.getProperty(param2, "y"),
			Reflect.getProperty(param2, "width"), Reflect.getProperty(param2, "height"), param3);
	}

	// :32-131
	public static function setSize2(param1:Dynamic, param2:Float, param3:Float, param4:Float, param5:Float,
			param6:Float):Void {
		if (param6 == -1) {
			return;
		}
		Reflect.setProperty(param1, "scaleY", 1); // param1.scaleX = param1.scaleY = 1
		Reflect.setProperty(param1, "scaleX", 1);
		if (param6 == 0) {
			Reflect.setProperty(param1, "scaleY", 1);
			Reflect.setProperty(param1, "scaleX", 1);
		} else if (param6 == 1) {
			if (Reflect.getProperty(param1, "width") / param4 > Reflect.getProperty(param1, "height") / param5) {
				Reflect.setProperty(param1, "height",
					Reflect.getProperty(param1, "height") / Reflect.getProperty(param1, "width") * param4);
				Reflect.setProperty(param1, "width", param4);
			} else {
				Reflect.setProperty(param1, "width",
					Reflect.getProperty(param1, "width") / Reflect.getProperty(param1, "height") * param5);
				Reflect.setProperty(param1, "height", param5);
			}
		} else if (param6 == 3) {
			if (Reflect.getProperty(param1, "width") / param4 < Reflect.getProperty(param1, "height") / param5) {
				Reflect.setProperty(param1, "height",
					Reflect.getProperty(param1, "height") / Reflect.getProperty(param1, "width") * param4);
				Reflect.setProperty(param1, "width", param4);
			} else {
				Reflect.setProperty(param1, "width",
					Reflect.getProperty(param1, "width") / Reflect.getProperty(param1, "height") * param5);
				Reflect.setProperty(param1, "height", param4); // :66 原版笔误（param4 非 param5）
			}
		} else if (param6 == 2) {
			Reflect.setProperty(param1, "width", param4);
			Reflect.setProperty(param1, "height", param5);
		} else if (param6 == 4) {
			if (Reflect.getProperty(param1, "width") > param4
				|| Reflect.getProperty(param1, "height") > param5) {
				if (Reflect.getProperty(param1, "width") / param4
					> Reflect.getProperty(param1, "height") / param5) {
					Reflect.setProperty(param1, "height",
						Reflect.getProperty(param1, "height") / Reflect.getProperty(param1, "width") * param4);
					Reflect.setProperty(param1, "width", param4);
				} else {
					Reflect.setProperty(param1, "width",
						Reflect.getProperty(param1, "width") / Reflect.getProperty(param1, "height") * param5);
					Reflect.setProperty(param1, "height", param5);
				}
			} else {
				Reflect.setProperty(param1, "scaleY", 1);
				Reflect.setProperty(param1, "scaleX", 1);
			}
		} else {
			if (param6 == 5) {
				if (Reflect.getProperty(param1, "width") / param4
					< Reflect.getProperty(param1, "height") / param5) {
					Reflect.setProperty(param1, "height",
						Reflect.getProperty(param1, "height") / Reflect.getProperty(param1, "width") * param4);
					Reflect.setProperty(param1, "width", param4);
				} else {
					Reflect.setProperty(param1, "width",
						Reflect.getProperty(param1, "width") / Reflect.getProperty(param1, "height") * param5);
					Reflect.setProperty(param1, "height", param4); // :106 原版笔误
				}
				Reflect.setProperty(param1, "x", param2 + param4 / 2 - Reflect.getProperty(param1, "width") / 2);
				Reflect.setProperty(param1, "y", param3);
				return;
			}
			if (param6 == 6) {
				if (Reflect.getProperty(param1, "width") / param4
					< Reflect.getProperty(param1, "height") / param5) {
					Reflect.setProperty(param1, "height",
						Reflect.getProperty(param1, "height") / Reflect.getProperty(param1, "width") * param4);
					Reflect.setProperty(param1, "width", param4);
				} else {
					Reflect.setProperty(param1, "width",
						Reflect.getProperty(param1, "width") / Reflect.getProperty(param1, "height") * param5);
					Reflect.setProperty(param1, "height", param4); // :122 原版笔误
				}
				Reflect.setProperty(param1, "x", param2 + param4 / 2 - Reflect.getProperty(param1, "width") / 2);
				Reflect.setProperty(param1, "y", param5 - Reflect.getProperty(param1, "height"));
				return;
			}
		}
		Reflect.setProperty(param1, "x", param2 + param4 / 2 - Reflect.getProperty(param1, "width") / 2);
		Reflect.setProperty(param1, "y", param3 + param5 / 2 - Reflect.getProperty(param1, "height") / 2);
	}
}
