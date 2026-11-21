package com.qzone.utils;

import openfl.text.TextField;
import shim.As3;

/**
 * com.qzone.utils.HtmlUtil —— HtmlUtil.as 逐句对应（issue #18 farm-basic
 * 收尾：工具函数片整类翻译）。HTML 转义/双字节长度。restHTML 走
 * TextField.htmlText → text（显示对象），不进单测。
 */
class HtmlUtil {
	// HtmlUtil.as:8
	private static var _textField:TextField;

	public function new() {}

	// :15-18 链式顺序逐字：& 最先（其后转义产物不再二次展开）、空格、尖括号
	// 全局替换；单引号正则无 /g —— AS3 非全局 replace 只替换第一处，用
	// As3.replaceFirst 复刻（原版笔误，deviations 候选）；双引号全局。
	public static function escHTML(param1:String):String {
		return StringTools.replace( // " → &quot;（全局）
			As3.replaceFirst( // ' → &apos;（仅第一处，正则无 /g）
				StringTools.replace( // > → &gt;
					StringTools.replace( // < → &lt;
						StringTools.replace( // 空格 → &nbsp;
							StringTools.replace(param1, "&", "&amp;"), // & 最先
							" ", "&nbsp;"),
						"<", "&lt;"),
					">", "&gt;"),
				"'", "&apos;"),
			"\"", "&quot;");
	}

	// :20-23（[^\x00-\xff] → "00" 后取长度：非 ASCII 每字符记 2）
	public static function getRealLength(param1:String):UInt {
		return new EReg("[^\\x00-\\xff]", "mg").replace(param1, "00").length;
	}

	// :25-33（TextField 显示对象路径，#39 → ' 全局忽略大小写）
	public static function restHTML(param1:String):String {
		if (_textField == null) {
			_textField = new TextField();
		}
		_textField.htmlText = new EReg("#39", "ig").replace(param1, "\\'");
		return _textField.text;
	}
}
