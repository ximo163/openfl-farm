package com.qzone.qfa.data;

import utest.Assert;

/**
 * 预加载器的资源类型判定（CmdLoadFile/LoadManager 按它决定 URLLoader 的 dataFormat）。
 *
 * 出处：legacy/decompiled/happyfarm3_v_149/scripts/com/qzone/qfa/data/ResourceType.as:19-37
 * （正则带 /i，不分大小写；三者都不匹配时返回 TYPE_BINARY）
 */
class ResourceTypeTest {
	public function new() {}

	// ResourceType.as:23-25,32-35
	public function test_swf_urls_are_typed_swf() {
		var cases:Array<String> = [
			"module/happyfarm3_v_149.swf",
			"module/main3_v_221.swf",
			"module/ui/lite_ui_v_0.swf",
			"MODULE/MAIN3_V_221.SWF" // /i
		];
		for (url in cases) Assert.equals(ResourceType.TYPE_SWF, ResourceType.getType(url), url);
	}

	// ResourceType.as:22-23,28-31：config_url/config_data 是带 .xml 的文本资源
	// （nc.htm:84-85；$xml 前缀的两种形态：common.php:60-61 的 data/xml/ 与
	// common.php:68-69 的 xml.php?mod=）
	public function test_text_urls_are_typed_text() {
		var cases:Array<String> = [
			"xml.php?mod=load_main_v_20120905.xml",
			"data/xml/data_zh_CN_v_20120905.xml",
			"data/xml/addon_v_20120905.xml",
			"module/a.txt",
			"module/a.js",
			"module/a.css"
		];
		for (url in cases) Assert.equals(ResourceType.TYPE_TEXT, ResourceType.getType(url), url);
	}

	// ResourceType.as:21-22,24-27
	public function test_image_urls_are_typed_bitmap() {
		var cases:Array<String> = ["a.jpg", "a.jpeg", "a.png", "a.gif", "A.PNG"];
		for (url in cases) Assert.equals(ResourceType.TYPE_BITMAP, ResourceType.getType(url), url);
	}

	// ResourceType.as:36 无匹配返回 TYPE_BINARY
	public function test_unknown_extension_is_typed_binary() {
		var cases:Array<String> = [
			"mync.php?mod=user&act=run", // FarmLite.as:293/311 的 CGI 地址
			"module/no_extension",
			"module/audio.ogg"
		];
		for (url in cases) Assert.equals(ResourceType.TYPE_BINARY, ResourceType.getType(url), url);
	}
}
