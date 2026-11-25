package;

/** issue #68 农场侧 17 件无归属带代码 swf 加载链考证结论（研究任务交付物）。
 *
 *  本文件是 write-tests 阶段按「stub 归树」规矩立的**产品树空串 stub**：
 *  考证结论属研究交付物（非测试零件），完工后属于 src/ 树，故放 src/——
 *  test/ 对 implement 是 append-only，放 test/ 会让 implement 无法原地
 *  填结论（#56 教训）。17 个 static var 当前全是空串，test/Issue68TriageTest.hx
 *  的全部要素断言因此红（长度 <200、缺行号出处、缺定级建议）；implement
 *  完成考证后把每件结论填进对应 var 即转绿。implement 填本文件不违反任何
 *  规则——src/ 不受 append-only 约束。
 *
 *  格式 per 件（// issue #68 验收原文）：引用出处（文件:行，可核对）→
 *  活跃/非活跃（窗口期/serverTime/开关/版本漂移）→ 定级建议（立项翻译/
 *  冻结/牧场批次三选一表态，给所有者拍板，不自行裁决）。查不清的写
 *  「未验证」+ 卡在哪，不猜；查不到引用的明写「部署内零引用」+ 排查范围。
 *
 *  17 件清单（// issue #68 原文「17 件现状」表）： */
class Issue68TriageNotes {
	// collect/CollectingMain_v_3：nc_addon.php:128 activity id="collecting"
	public static var COLLECTING_MAIN_V_3:String = "";

	// plugin/FairyPlugin_v_21：nc_addon.php:303-305 plugins 节 proxy 挂载
	public static var FAIRY_PLUGIN_V_21:String = "";

	// plugin/MailPromotionPlugin_v_3：普查无文件名直接命中，加载链待查
	public static var MAIL_PROMOTION_PLUGIN_V_3:String = "";

	// plugin/PromotionsPlugin_v_1：普查无文件名直接命中，加载链待查
	public static var PROMOTIONS_PLUGIN_V_1:String = "";

	// plugin/WeekendPlugin_v_3：普查无文件名直接命中，加载链待查
	public static var WEEKEND_PLUGIN_V_3:String = "";

	// ui/dialogs/ArborDayActivityContext_v_0：植树节活动面板族，未定位引用
	public static var ARBOR_DAY_ACTIVITY_CONTEXT_V_0:String = "";

	// ui/dialogs/arborDayLv2PanelView_v_0：植树节活动面板族，未定位引用
	public static var ARBOR_DAY_LV2_PANEL_VIEW_V_0:String = "";

	// ui/dialogs/arborDayMainPanelView_v_0：植树节活动面板族，主面板 78KB
	public static var ARBOR_DAY_MAIN_PANEL_VIEW_V_0:String = "";

	// ui/lite_ui_v_0：10 个 *_Lite 类，加载链待查
	public static var LITE_UI_V_0:String = "";

	// ui/freegift_v_5：nc_addon freegift 键族，配置指 v_6 部署是 v_5（漂移）
	public static var FREEGIFT_V_5:String = "";

	// ui/monthEnd_v_5：nc_addon.php:121 指 monthEnd_v_8 部署只有 v_5（漂移），
	// 窗口期 2012-7-20~8-13 已过期
	public static var MONTH_END_V_5:String = "";

	// ui/recall_v_3：nc_addon recall 键 + Master2 mc/control/FarmCommand.as 命中
	public static var RECALL_V_3:String = "";

	// ui/sellyouji_v_1：未定位引用
	public static var SELLYOUJI_V_1:String = "";

	// ui/singleFes_v_0：未定位引用
	public static var SINGLE_FES_V_0:String = "";

	// ui/stocks_v_2：未定位引用
	public static var STOCKS_V_2:String = "";

	// ui/QDSeed_v_1：未定位引用
	public static var QD_SEED_V_1:String = "";

	// ui/farm/houseKeeper_v_0：未定位引用
	public static var HOUSE_KEEPER_V_0:String = "";

	public function new() {}
}
