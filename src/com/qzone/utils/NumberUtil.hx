package com.qzone.utils;

// com.qzone.utils.NumberUtil —— NumberUtil.as 逐句对应（85 loc ≤ 100，闭包规则
// 整类翻译；FarmApplication.onMainLoop 的 isZero 用到）。`_fABS = Math.abs` 的
// 函数引用照抄。
class NumberUtil {
	// NumberUtil.as:7-15
	private static var __TWO_PI:Float = 2 * Math.PI;
	private static var __PI:Float = Math.PI;
	private static var __HALF_PI:Float = 0.5 * Math.PI;
	private static var __TO_DREGREE:Float = 180 / Math.PI;
	private static var __TO_RADIAN:Float = Math.PI / 180;

	// NumberUtil.as:17
	public static var TOL:Float = 0.00001;

	// NumberUtil.as:19（private static var _fABS:Function = Math.abs）
	private static var _fABS:Float->Float = Math.abs;

	public function new() {
		super();
	}

	// NumberUtil.as:21-24
	public static function areEqual(param1:Float, param2:Float):Bool {
		return _fABS(param1 - param2) < TOL;
	}

	// NumberUtil.as:26-29
	public static var TO_DEGREE(get, never):Float;

	private static function get_TO_DEGREE():Float {
		return __TO_DREGREE;
	}

	// NumberUtil.as:31-34
	public static var HALF_PI(get, never):Float;

	private static function get_HALF_PI():Float {
		return __HALF_PI;
	}

	// NumberUtil.as:36-39
	public static function toDegree(param1:Float):Float {
		return param1 * TO_DEGREE;
	}

	// NumberUtil.as:41-48
	public static function roundTo(param1:Float, param2:Float = 0):Float {
		if (param2 == 0) {
			param2 = 1;
		}
		return Math.round(param1 / param2) * param2;
	}

	// NumberUtil.as:50-53
	public static var TWO_PI(get, never):Float;

	private static function get_TWO_PI():Float {
		return __TWO_PI;
	}

	// NumberUtil.as:55-58
	public static function isZero(param1:Float):Bool {
		return _fABS(param1) < TOL;
	}

	// NumberUtil.as:60-63
	public static var TO_RADIAN(get, never):Float;

	private static function get_TO_RADIAN():Float {
		return __TO_RADIAN;
	}

	// NumberUtil.as:65-68
	public static function constrain(param1:Float, param2:Float, param3:Float):Float {
		return Math.max(Math.min(param1, param3), param2);
	}

	// NumberUtil.as:70-73
	public static var PI(get, never):Float;

	private static function get_PI():Float {
		return __PI;
	}

	// NumberUtil.as:75-78
	public static function toRadian(param1:Float):Float {
		return param1 * TO_RADIAN;
	}
}
