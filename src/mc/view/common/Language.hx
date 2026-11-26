package mc.view.common;

import openfl.errors.Error;

/**
 * mc.view.common.Language —— Language.as 的签名面 stub（原类 71 loc，
 * issue #87「通用视图」片充真身）。多语文本：内置 _l 模板表，lang 取
 * INI version.@language（空/缺省落 "cn"），replaceText 按 {key} 替换
 * 并在键循环内做 #1#→1st 等序号替换。成员签名逐字取自反编译原文，
 * 方法体随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/Language.as。
 *
 * PORT-NOTE: main3 侧另有 common/Language.as（不同类、不同表），本类是
 * 牧场 mc.view.common.Language——import 时注意按包区分。
 */
@:keep
class Language {
	// Language.as:8-10
	public static final CN:String = "cn";
	public static final EN:String = "en";

	// Language.as:12-27（内置模板表，真身随 implement 逐字搬运）
	private static var _l:Dynamic;

	// Language.as:28
	private static var _currentLang:String = "";

	// Language.as:30-32
	public function new() {}

	// Language.as:34-47
	public static function replaceText(param1:String, param2:Dynamic):String {
		throw new Error("not implemented");
	}

	// Language.as:49-52（L：_l[lang]）
	public static var L(get, never):Dynamic;

	private static function get_L():Dynamic {
		throw new Error("not implemented");
	}

	// Language.as:54-69（lang：INI version.@language 空/缺省落 "cn"）
	public static var lang(get, never):String;

	private static function get_lang():String {
		throw new Error("not implemented");
	}
}
