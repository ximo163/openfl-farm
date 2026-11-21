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
	// UserActionRecorder.as:40/:42（issue #9：收获手/一键摘取上报）
	public static final HF_TOOL_HAND_CLICKED:String = "18";
	public static final HF_TOOL_ONECLICK_CLICKED:String = "19";
	// UserActionRecorder.as:92/:94/:96（V3b：NPCView 点牧场/看板/狗盆上报）
	public static final HF_TO_PASTURE_CLICKED:String = "10300";
	public static final HF_BILLBOARD_CLICKED:String = "10301";
	public static final HF_DOGBOWL_CLICKED:String = "10302";
	// UserActionRecorder.as:64/:72/:74/:76（issue #9：导航条按钮上报）
	public static final HF_MYFARM_CLICKED:String = "42";
	public static final HF_WAREHOUSE_CLICKED:String = "46";
	public static final HF_SHOP_CLICKED:String = "47";
	public static final HF_DECORATE_CLICKED:String = "48";
	// UserActionRecorder.as:66/:68/:70（issue #9：牧场/餐厅/加工坊跳转上报）
	public static final HF_MYPASTURE_CLICKED:String = "43";
	public static final HF_MYRESTAURANT_CLICKED:String = "44";
	public static final HF_MYMILL_CLICKED:String = "45";
	// UserActionRecorder.as:78/:82/:84（issue #9：左侧工具条消息/公告/签到上报）
	public static final HF_SHORTCUTBAR_INFO_CLICKED:String = "50";
	public static final HF_SHORTCUTBAR_POST_CLICKED:String = "54";
	public static final HF_SHORTCUTBAR_CARDS_CLICKED:String = "55";
	// UserActionRecorder.as:60（issue #9：个人信息区头像点击上报）
	public static final HF_PERSONINFO_OPEN:String = "30";

	public function new() {}

	// UserActionRecorder.as:132（recordAction(param1:String)：行为上报，签名
	// 照原文单参；上报片翻译，出口按 deviations 不外发）
	public static function recordAction(param1:String):Void {}
}
