package com.qzone.utils;

import openfl.errors.Error;

/**
 * com.qzone.utils.HtmlUtil —— issue #18 write-tests 签名 stub
 * （HtmlUtil.as 37 loc，farm-basic 收尾：工具函数片整类翻译）。
 * HTML 转义/双字节长度。方法签名照抄，体 throw not implemented。
 * restHTML 走 TextField.htmlText → text（显示对象），不进单测。
 */
class HtmlUtil {
	// HtmlUtil.as:8
	private static var _textField:openfl.text.TextField;

	public function new() {}

	// :15-18
	public static function escHTML(param1:String):String {
		throw new Error("not implemented");
	}

	// :20-23
	public static function getRealLength(param1:String):UInt {
		throw new Error("not implemented");
	}

	// :25-33（TextField 显示对象路径）
	public static function restHTML(param1:String):String {
		throw new Error("not implemented");
	}
}
