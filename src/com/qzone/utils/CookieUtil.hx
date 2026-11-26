package com.qzone.utils;

import shim.QQOutlets;

/**
 * com.qzone.utils.CookieUtil —— CookieUtil.as 逐句对应（issue #86 牧场库
 * 底座，工具函数片）。浏览器 cookie 读写：原版经 ExternalInterface 往页面
 * 注入 snw_setCookie/snw_getCookie 两个 JS 函数再调。
 * legacy/decompiled/Master2_v_142/scripts/com/qzone/utils/CookieUtil.as。
 *
 * PORT-NOTE: ExternalInterface 出口按仓内既定决策走 shim.QQOutlets
 * （no-qzone-jsapi 决策族：独立部署无宿主 JS，一律不发送、取值回 null——
 * getCookie 因此恒 null，与原版在非 QZone 页面的兜底一致；deviations 候选
 * 待人登记）。注入函数的字符串常量逐字保留。
 */
@:keep
class CookieUtil {
	// CookieUtil.as:7-8（JS 注入体逐字照抄——无消费也不改写）
	private static final FUNCTION_SETCOOKIE:String = "document.insertScript = function ()" + "{ "
		+ "if (document.snw_setCookie==null)" + "{" + "snw_setCookie = function (name, value, days)" + "{" + "if (days) {"
		+ "var date = new Date();" + "date.setTime(date.getTime()+(days*24*60*60*1000));" + "var expires = \'; expires=\'+date.toGMTString();" + "}"
		+ "else var expires = \'\';" + "document.cookie = name+\'=\'+value+expires+\'; path=/\';" + "}" + "}" + "}";

	private static final FUNCTION_GETCOOKIE:String = "document.insertScript = function ()" + "{ "
		+ "if (document.snw_getCookie==null)" + "{" + "snw_getCookie = function (name)" + "{" + "var nameEQ = name + \'=\';"
		+ "var ca = document.cookie.split(\';\');" + "for(var i=0;i < ca.length;i++) {" + "var c = ca[i];"
		+ "while (c.charAt(0)==\' \') c = c.substring(1,c.length);" + "if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);" + "}"
		+ "return null;" + "}" + "}" + "}";

	// :10
	private static var INITIALIZED:Bool = false;

	// :12-16（静态专用类，ctor 照原文抛错）
	public function new() {
		throw "CookieUtil only a static class.";
	}

	// :18-23
	private static function init():Void {
		QQOutlets.call(FUNCTION_GETCOOKIE);
		QQOutlets.call(FUNCTION_SETCOOKIE);
		INITIALIZED = true;
	}

	// :25-31
	public static function deleteCookie(param1:String):Void {
		if (!INITIALIZED) {
			init();
		}
		QQOutlets.call("snw_setCookie", param1, "", -1);
	}

	// :33-39
	public static function getCookie(param1:String):Dynamic {
		if (!INITIALIZED) {
			init();
		}
		return QQOutlets.call("snw_getCookie", param1);
	}

	// :41-47
	public static function setCookie(param1:String, param2:Dynamic, param3:Int):Void {
		if (!INITIALIZED) {
			init();
		}
		QQOutlets.call("snw_setCookie", param1, param2, param3);
	}
}
