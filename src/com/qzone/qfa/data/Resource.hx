package com.qzone.qfa.data;

import openfl.display.LoaderInfo;
import openfl.system.ApplicationDomain;

// Resource.as 逐句对应。原版是 dynamic class（可运行时挂属性，LoadManager.as:88
// 往实例上写 applicationDomain）——Haxe 没有 dynamic class，该字段直接落成
// 公共成员（PORT-NOTE: 原版未声明、LoadManager 动态写入）。
class Resource {
	// Resource.as:10
	public var type:String;

	// Resource.as:12
	public var loaded:Bool;

	// Resource.as:14
	public var loaderInfo:LoaderInfo;

	// Resource.as:16
	public var data:Dynamic;

	// Resource.as:18
	public var url:String;

	// LoadManager.as:88 动态挂上的字段（`_loc3_.applicationDomain = ...`）
	public var applicationDomain:ApplicationDomain;

	public function new() {
	}
}
