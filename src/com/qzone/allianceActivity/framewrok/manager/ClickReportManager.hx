package com.qzone.allianceActivity.framewrok.manager;

/**
 * com.qzone.allianceActivity.framewrok.manager.ClickReportManager —— V3b
 * 闭包 stub（issue #8）。活动点击/曝光上报（ClickReportManager.as 111 loc
 * > 100，闭包规则走 stub，活动片翻译）。注意与已翻译的 report.
 * ClickReportManager 不是同一个类（包名不同）。原版经 ExternalInterface
 * 发宿主 JS 上报；spec/deviations.json：no-qq-telemetry 不外发，stub 出口
 * 一律 no-op（QQOutlets 同款约定）。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/allianceActivity/framewrok/
 * manager/ClickReportManager.as
 */
@:keep
class ClickReportManager {
	public function new() {}

	// ClickReportManager.as（reportClick：点击上报，活动片翻译）
	public static function reportClick(param1:String):Void {}

	// ClickReportManager.as（reportPv：曝光上报，活动片翻译）
	public static function reportPv():Void {}
}
