package com.adobe.utils;

/**
 * com.adobe.utils.StringUtil —— 闭包 stub（issue #7）：trim 真身（StringUtil.as:16-19，
 * 等价 StringTools.trim）。原类 112 loc（>100 不在 #7 全量翻译规则内）。
 * issue #43（引导与启动杂尾）整类补齐闭包规则解除，write-tests 阶段先落
 * 其余 8 个方法的 throw stub（无运行期调用方，FeartureManager/ProfileMsg
 * 只用 trim）。
 */
@:keep
class StringUtil {
	// StringUtil.as:16-19
	public static function trim(param1:String):String {
		return StringTools.trim(param1);
	}

	// StringUtil.as:11-14（beginsWith：前缀整段比对，#43 翻译）
	public static function beginsWith(param1:String, param2:String):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// StringUtil.as:21-28（stringsAreEqual：大小写敏感档走 ==，不敏感档两侧
	// toUpperCase，#43 翻译）
	public static function stringsAreEqual(param1:String, param2:String, param3:Bool):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// StringUtil.as:30-63（replace：手工逐字符扫描，命中即跳过整段针串，#43 翻译）
	public static function replace(param1:String, param2:String, param3:String):String {
		throw new openfl.errors.Error("not implemented");
	}

	// StringUtil.as:65-78（rtrim：右侧 charCode <= 32 裁剪，#43 翻译）
	public static function rtrim(param1:String):String {
		throw new openfl.errors.Error("not implemented");
	}

	// StringUtil.as:80-83（endsWith：后缀整段比对，#43 翻译）
	public static function endsWith(param1:String, param2:String):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// StringUtil.as:85-88（stringHasValue：非 null 且非空，#43 翻译）
	public static function stringHasValue(param1:String):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// StringUtil.as:90-93（remove：replace 的空串替换，#43 翻译）
	public static function remove(param1:String, param2:String):String {
		throw new openfl.errors.Error("not implemented");
	}

	// StringUtil.as:95-108（ltrim：左侧 charCode <= 32 裁剪，#43 翻译）
	public static function ltrim(param1:String):String {
		throw new openfl.errors.Error("not implemented");
	}

	public function new() {}
}
