package report;

/**
 * report.UserActionRecorder —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 用户行为上报（UserActionRecorder.as 159 loc）；FarmApplication.startup 只调
 * recordAction(HF_GAME_INIT)。上报出口按 deviations（no-qq-telemetry）不外发，
 * 行为号常量表照抄头部供调用点编译，记录逻辑随上报片接入。
 */
@:keep
class UserActionRecorder {
	// UserActionRecorder.as:16
	public static var recordUrl:String = "mync.php?mod=cgi_ua_stat";

	// UserActionRecorder.as:26-（HF_* 行为号）
	public static final HF_GAME_INIT:String = "1";
	public static final HF_TOOL_HOE_CLICKED:String = "7";
	public static final HF_TOOL_PACK_CLICKED:String = "8";
	public static final HF_TOOL_TOOLBOX_CLICKED:String = "9";
	public static final HF_TOOL_HOOK_CLICKED:String = "10";
	public static final HF_TOOL_PESTICIDE_CLICKED:String = "11";
	public static final HF_TOOL_WILD_CLICKED:String = "14";

	public function new() {}

	// UserActionRecorder.as（recordAction：行为上报，上报片翻译）
	public static function recordAction(param1:String, param2:Dynamic = null):Void {}
}
