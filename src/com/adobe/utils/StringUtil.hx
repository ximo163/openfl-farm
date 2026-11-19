package com.adobe.utils;

/**
 * com.adobe.utils.StringUtil —— 闭包 stub（issue #7）：只实现被本片翻译代码引用的
 * trim（StringUtil.as:16-19，等价 StringTools.trim）。原类 112 loc（>100 不在本片
 * 全量翻译规则内），其余方法（stringsAreEqual 等）V3b/V3c 模块翻译时补齐。
 */
@:keep
class StringUtil {
	// StringUtil.as:16-19
	public static function trim(param1:String):String {
		return StringTools.trim(param1);
	}

	public function new() {}
}
