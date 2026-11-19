package com.qzone.allianceActivity;

/**
 * com.qzone.allianceActivity.AllianceActivityInfo —— V3b 顺手翻（issue #8
 * 闭包，AllianceActivityInfo.as 24 loc ≤ 100；活动配置载体）。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/allianceActivity/
 * AllianceActivityInfo.as 逐句对应。
 * PORT-NOTE(source)：原版 `public var source:XML` 是 E4X XML，Haxe 无等价
 * 物；活动片未接入前无人读写，暂以 Dynamic 占位（读 XML 的活动配置解析随
 * 活动片 BLOCKED/接入时定）。
 */
class AllianceActivityInfo {
	// AllianceActivityInfo.as:7
	public var source:Dynamic;

	// AllianceActivityInfo.as:9-17
	public var assets:Array<Dynamic>;
	public var src:String;
	public var expireTime:Float;
	public var startTime:Float;
	public var id:String;

	public function new() {}
}
