package mc.fBridge;

/**
 * mc.fBridge.EventRecorder —— 编译 stub（范围外依赖，后续模块充真身）。
 * 本类是 mcloader_v_53 加载链提供的外部依赖（spec/modules/pasture.json
 * notes：「外部依赖……不在 805 类内」），Master2 的 RequestManager.as:96/
 * :113 以包内非限定名引用（MC_SNOW/FAULT_SNOW_ENTER/FAULT_SNOW_STEAL 常量
 * 与 recordErrorEvent 上报）。本 stub 只为 mc.FBridge 网络片的编译链而落，
 * 成员签名逐字取自 mcloader 反编译原文，mcloader 模块立项时归并复审充
 * 真身。legacy/decompiled/mcloader_v_53/scripts/mc/FBridge/EventRecorder.as。
 *
 * recordErrorEvent 体空：no-qq-telemetry 偏差（spec/deviations.json）下
 * 上报出口本就不发送，空体即终态行为——mcloader 片充真身时按原文恢复
 * 概率采样与 record 通道（出口同样按偏差禁用），调用点行为不变。
 *
 * PORT-NOTE(命名)：原包 `mc.FBridge` 的 FBridge 段首字母大写，Haxe 包段
 * 必须小写开头，落 `fBridge`（windowControl 同款先例，deviations 候选）。
 */
@:keep
class EventRecorder {
	// EventRecorder.as:41/47-48（mcloader_v_53 行号；MC_SNOW 是 var 非
	// const，FAULT_SNOW_ENTER/FAULT_SNOW_STEAL 是 const——原文如此）
	public static var MC_SNOW:String = "160029";
	public static final FAULT_SNOW_ENTER:Int = 17;
	public static final FAULT_SNOW_STEAL:Int = 18;

	public function new() {}

	// EventRecorder.as:276-294（签名逐字；体空见类头注——param4 原文
	// 默认 null 照抄）
	public static function recordErrorEvent(param1:String, param2:Float, param3:Int, param4:String = null):Void {}

	// EventRecorder.as:392-404（recordMultiValueInCode(param1:String,
	// param2:String)——issue #87 AppHelper.reportReturnCode 编译链需要
	// 签名；体空同 recordErrorEvent 条：no-qq-telemetry 偏差下上报出口
	// 本就不发送，空体即终态行为，mcloader 片充真身时按原文恢复概率
	// 采样与 record 通道）
	public static function recordMultiValueInCode(param1:String, param2:String):Void {}
}
