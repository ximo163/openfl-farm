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
	// 引用出处：nc_addon.php:128 `<activity id="collecting" standalone="1"
	// enter_type="customize" gray="1" start_time="2012-7-31 00:00"
	// expire_time="2050-1-1 00:00" src="module/collect/CollectingMain_v_3.swf">`；
	// 加载链 main3：AllianceActivityController.as:79 standalone==1 且
	// onPreloadCustomize 过门即 loadActivityModule，:246-249 enter_type=customize
	// 分支挂自定入口图标（asset customize_icon，nc_addon.php:129）；农场侧
	// ActivityController.as:46 `helperMap["collecting"]=new CollectingActivity(...)`
	// 绑定 helper。
	// 活跃判定（两层分开表态）：(1) 时间窗——start 2012-7-31 / expire 2050-1-1，
	// AllianceActivityManager.as:226-238 checkActivityAvaliable 用 serverTime
	// 比对，固定快照 serverTime=1794915896（initialized.sql，≈2026-11）落在窗内
	// → 时间窗这层活跃；(2) gray 黄钻门——ActivityController.as:27-39
	// onPreloadCustomize：gray="1" 时要求 host._yellowstatus>0 且
	// _yellowlevel>=gray 才预载，快照 uid1 的 vip 字段为 '[]'（user_run.php:254-260
	// exp 缺省 → yellowlevel=0/yellowstatus=0）→ **不过门，快照里 swf 实际不加载**。
	// 定级建议：**立项翻译**（给所有者拍板）——链路完整、窗口不过期、灰度门只是
	// 快照帐户口径问题（换黄钻号即活），属农场常驻收集活动。
	public static var COLLECTING_MAIN_V_3:String = "引用出处：nc_addon.php:128 <activity id=\"collecting\" standalone=\"1\" enter_type=\"customize\" gray=\"1\" start_time=\"2012-7-31 00:00\" expire_time=\"2050-1-1 00:00\" src=\"module/collect/CollectingMain_v_3.swf\">；加载链 main3 AllianceActivityController.as:79 standalone==1 且 onPreloadCustomize 过门即 loadActivityModule，:246-249 enter_type=customize 分支挂自定入口（asset customize_icon nc_addon.php:129）；农场侧 ActivityController.as:46 helperMap collecting 绑定 CollectingActivity。活跃判定（两层分开）：(1) 时间窗 start 2012-7-31/expire 2050-1-1，AllianceActivityManager.as:226-238 checkActivityAvaliable 以 serverTime 比对，固定快照 serverTime=1794915896（initialized.sql，≈2026-11）在窗内→时间层活跃；(2) gray 黄钻门 ActivityController.as:27-39 要求 host._yellowstatus>0 且 _yellowlevel>=gray(=1)，快照 uid1 vip='[]'（user_run.php:254-260 yellowlevel=0/yellowstatus=0）→不过门，快照里 swf 实际不加载。定级建议：立项翻译（给所有者拍板）——链路完整、窗口不过期、灰度门只是快照帐户口径（换黄钻号即活），属农场常驻收集活动。";

	// plugin/FairyPlugin_v_21：nc_addon.php:303-305 plugins 节 proxy 挂载
	// 引用出处：nc_addon.php:305 plugins JSON 唯一条目 `{"id":2,
	// "proxy":"plugins.FairyPluginProxy","url":"module/plugin/FairyPlugin_v_21.swf",
	// "amount":[{type:0 背景挂载 x=140 y=510 zIndex/layer},{type:5 tip 请小仙},
	// {type:5 tip 升级仙皇}]}`（nc_addon.php:300 有 amount 语义注释，:326-328
	// fairy f0-f3 子素材表）。加载机制：FarmApplication.as:1004-1005
	// `plugins=model.getData("plugins"); PluginManager.loadPlugins(...)`；
	// PluginManager.as:51-53 `applicationDomain.hasDefinition(proxy)` 反射门——
	// proxy 类 plugins.FairyPluginProxy **在 main3 里**（main3 scripts/plugins/
	// FairyPluginProxy.as:15），故反射命中、proxy 实例化。
	// 活跃判定核心：nc_addon.php:104 `<fairy>0</fairy>` 灰度总开关——
	// FairyPluginProxy.as:111-114 PLUGIN_PROXY_AMOUNT 分支
	// `getStringAttribute("fairy")=="0"` 直接 break，loadResource（:123 加载
	// m_config["url"]=FairyPlugin_v_21.swf）永不执行；addToolIcon（:71-92）
	// 同受 fairy 档位黄钻门。本部署 fairy=0 → **swf 永不加载**（非活跃）。
	// 定级建议：建议**冻结**（给所有者拍板）——链路完整可译但总开关关闭，
	// 快照无路径走到；若所有者要全量保真可改立项，翻译批次含 proxy+plugin 两庫。
	public static var FAIRY_PLUGIN_V_21:String = "引用出处：nc_addon.php:305 plugins JSON 唯一条目 {\"id\":2,\"proxy\":\"plugins.FairyPluginProxy\",\"url\":\"module/plugin/FairyPlugin_v_21.swf\",\"amount\":[{\"type\":0,\"zIndex\":0,\"layer\":3,\"x\":140,\"y\":510},{\"type\":5,\"tip\":\"请小仙\"},{\"type\":5,\"tip\":\"升级仙皇\"}]}（nc_addon.php:300 amount 语义注释、:326-328 fairy f0-f3 子素材表）。加载机制：FarmApplication.as:1004-1005 plugins=model.getData(\"plugins\") 交 PluginManager.loadPlugins；PluginManager.as:51-53 applicationDomain.hasDefinition(proxy) 反射门——plugins.FairyPluginProxy 在 main3 内（main3 scripts/plugins/FairyPluginProxy.as:15）故命中实例化。活跃判定核心：nc_addon.php:104 <fairy>0</fairy> 灰度总开关——FairyPluginProxy.as:111-114 PLUGIN_PROXY_AMOUNT 分支 getStringAttribute(\"fairy\")==\"0\" 直接 break，loadResource（:123 加载 m_config url 即 FairyPlugin_v_21.swf）永不执行；addToolIcon（:71-92）同受 fairy 档位黄钻门。本部署 fairy=0→swf 永不加载（非活跃）。定级建议：建议冻结（给所有者拍板）——链路完整可译但总开关关闭，快照无路径走到；若要全量保真可改立项，翻译批次含 proxy+plugin 两库。";

	// plugin/MailPromotionPlugin_v_3：普查无文件名直接命中，加载链待查
	// 引用出处排查结果：**部署内零引用**（配置侧）。排查范围：(1) nc_addon.php
	// plugins JSON（:301-330）只有 id:2 FairyPlugin 一条，无 MailPromotion 条目；
	// (2) main3/happyfarm3 反编译全树 grep 文件名 MailPromotionPlugin 零命中；
	// (3) PHP source/ 全树零命中。(4) 但注意：main3 存在 proxy 类
	// scripts/plugins/MailPromotionProxy.as（:27/:59 从 m_config.url 取址
	// loadResource）——proxy 在宿主里、swf 本体是插件载荷，链路形态与 Fairy
	// 相同；**缺的只是配置条目**：PluginManager.as:45 纯配置驱动遍历，配置没有
	// 该 proxy 条 → proxy 永不实例化 → swf 永不加载。
	// 活跃判定：非活跃（零配置驱动）。
	// 定级建议：建议**冻结**（给所有者拍板）——部署配置不引用即死代码；
	// 若后续发现运营期 XML 变体含该条目再立项。
	public static var MAIL_PROMOTION_PLUGIN_V_3:String = "引用出处：部署内零引用（配置侧）。排查范围：(1) nc_addon.php plugins JSON（nc_addon.php:301-330）只有 id:2 FairyPlugin 一条，无 MailPromotion 条目；(2) main3/happyfarm3 反编译全树 grep 文件名 MailPromotionPlugin 零命中；(3) PHP source/ 全树零命中。(4) 注意：main3 存在 proxy 类 scripts/plugins/MailPromotionProxy.as（:27/:59 从 m_config url 取址 loadResource）——proxy 在宿主、swf 本体是插件载荷，链路形态与 Fairy 相同；缺的只是配置条目：PluginManager.as:45 纯配置驱动遍历，配置没有该 proxy 条→proxy 永不实例化→swf 永不加载。活跃判定：非活跃（零配置驱动）。定级建议：建议冻结（给所有者拍板）——部署配置不引用即死代码；若后续发现运营期 XML 变体含该条目再立项。";

	// plugin/PromotionsPlugin_v_1：普查无文件名直接命中，加载链待查
	// 引用出处排查结果：**部署内零引用**。排查范围：(1) nc_addon.php plugins
	// JSON 唯一条目是 FairyPlugin（nc_addon.php:305），无 Promotions 条目；
	// (2) main3 scripts/plugins/ 目录只有 FairyPluginProxy/MailPromotionProxy/
	// MobileFarmPluginProxy/QShowPluginProxy/WeekendSalePluginProxy 五个 proxy，
	// **没有 PromotionsPlugin 对应的 proxy 类**（连宿主侧挂载点都不存在）；
	// (3) main3/happyfarm3 反编译与 PHP source/ 全树 grep 文件名零命中。
	// 该 swf 内含 plugins/external + promotions/promotoins 包族（自含 plugin
	// 本体），但没有任何宿主代码会加载它。
	// 活跃判定：非活跃。
	// 定级建议：建议**冻结**（给所有者拍板）——宿主 proxy 都不存在的孤儿插件，
	// 疑似历史运营件遗留。
	public static var PROMOTIONS_PLUGIN_V_1:String = "引用出处：部署内零引用。排查范围：(1) nc_addon.php plugins JSON 唯一条目是 FairyPlugin（nc_addon.php:305），无 Promotions 条目；(2) main3 scripts/plugins/ 目录只有 FairyPluginProxy/MailPromotionProxy/MobileFarmPluginProxy/QShowPluginProxy/WeekendSalePluginProxy 五个 proxy，没有 PromotionsPlugin 对应的 proxy 类（连宿主侧挂载点都不存在）；(3) main3/happyfarm3 反编译与 PHP source/ 全树 grep 文件名零命中。该 swf 内含 plugins/external + promotions/promotoins 包族（自含 plugin 本体），但没有任何宿主代码会加载它。活跃判定：非活跃。定级建议：建议冻结（给所有者拍板）——宿主 proxy 都不存在的孤儿插件，疑似历史运营件遗留。";

	// plugin/WeekendPlugin_v_3：普查无文件名直接命中，加载链待查
	// 引用出处排查结果：**部署内零引用**（配置侧）。排查范围：(1) nc_addon.php
	// plugins JSON（nc_addon.php:301-330）只有 id:2 FairyPlugin 一条；
	// (2) main3/happyfarm3 反编译全树 grep 文件名 WeekendPlugin 零命中；
	// (3) PHP source/ 全树零命中。(4) 与 MailPromotion 同形态：main3 存在
	// proxy 类 scripts/plugins/WeekendSalePluginProxy.as（:31/:73 从
	// m_config.url loadResource），swf 本体是 plugins/external/weekendSale
	// 包族的周末大促插件载荷；缺配置条目 → PluginManager.as:45 遍历不到 →
	// proxy 不实例化 → swf 不加载。
	// 活跃判定：非活跃（零配置驱动）。
	// 定级建议：建议**冻结**（给所有者拍板）——同 MailPromotion 口径。
	public static var WEEKEND_PLUGIN_V_3:String = "引用出处：部署内零引用（配置侧）。排查范围：(1) nc_addon.php plugins JSON（nc_addon.php:301-330）只有 id:2 FairyPlugin 一条；(2) main3/happyfarm3 反编译全树 grep 文件名 WeekendPlugin 零命中；(3) PHP source/ 全树零命中。(4) 与 MailPromotion 同形态：main3 存在 proxy 类 scripts/plugins/WeekendSalePluginProxy.as（:31/:73 从 m_config url loadResource），swf 本体是 plugins/external/weekendSale 包族的周末大促插件载荷；缺配置条目→PluginManager.as:45 遍历不到→proxy 不实例化→swf 不加载。活跃判定：非活跃（零配置驱动）。定级建议：建议冻结（给所有者拍板）——同 MailPromotion 口径。";

	// ui/dialogs/ArborDayActivityContext_v_0：植树节活动面板族，未定位引用
	// 引用出处排查结果：**部署内零引用**（外部）。排查范围：(1) nc_addon.php
	// activity_list 块只有 olympicGames（nc_addon.php:126）与 collecting
	// （nc_addon.php:128）两条，无 arbor 条目——AllianceActivityController.as:73-84
	// 只遍历配置里的 activity 节点，配置无条目即永不加载；(2) main3/happyfarm3/
	// Master2 反编译全树 grep arborDay/ArborDay 零命中；(3) xml 配置目录全树
	// 零命中。(4) 内部关系：三件套用 com/qzone/allianceActivity 包族——context
	// 的 view 类 import 两件 panel view 的符号类（ArborDayActivityWin.as:3
	// import ArborDayMainPanelView 即 arborDayMainPanelView_v_0 的符号；
	// ArborDayActivityRecordWin.as:3 / ArborDayActivityDetailWin.as:3 /
	// ScoreNotEnoughtAlertWin.as:3 / ArborDayActivityFinalPresentWin.as:3
	// import 的 ArborDayRecordPanelView/ArborDayDetailPanelView/
	// ArborDayScoreAlertPanelView/ArborDayFinalPresentPanelView 即
	// arborDayLv2PanelView_v_0 的符号）——即 context 是主程序、两件 panel view
	// 是它的素材库，三件套属同一活动（2012 植树节，联盟活动框架）。
	// 活跃判定：非活跃（配置无条目，且植树节活动无窗口配置可查）。
	// 定级建议：建议**冻结**（给所有者拍板）——活动已下线且配置无痕迹；
	// 三件套若立项须作为一个批次（内部 cross 引用不可拆）。
	public static var ARBOR_DAY_ACTIVITY_CONTEXT_V_0:String = "引用出处：部署内零引用（外部）。排查范围：(1) nc_addon.php activity_list 块只有 olympicGames（nc_addon.php:126）与 collecting（nc_addon.php:128）两条，无 arbor 条目——AllianceActivityController.as:73-84 只遍历配置里的 activity 节点，配置无条目即永不加载；(2) main3/happyfarm3/Master2 反编译全树 grep arborDay/ArborDay 零命中；(3) xml 配置目录全树零命中。内部关系：三件套共享 com/qzone/allianceActivity 包族——context 的 view 类 import 两件 panel view 的符号类（ArborDayActivityWin.as:3 import ArborDayMainPanelView 即 arborDayMainPanelView_v_0 的符号；ArborDayActivityRecordWin.as:3/ArborDayActivityDetailWin.as:3/ScoreNotEnoughtAlertWin.as:3/ArborDayActivityFinalPresentWin.as:3 import 的 ArborDayRecordPanelView/ArborDayDetailPanelView/ArborDayScoreAlertPanelView/ArborDayFinalPresentPanelView 即 arborDayLv2PanelView_v_0 的符号）——context 是主程序、两件 panel view 是它的素材库，三件套属同一活动（2012 植树节，联盟活动框架）。活跃判定：非活跃（配置无条目，活动窗口不可查）。定级建议：建议冻结（给所有者拍板）——活动已下线且配置无痕迹；三件套若立项须作为一个批次（内部 cross 引用不可拆）。";

	// ui/dialogs/arborDayLv2PanelView_v_0：植树节活动面板族，未定位引用
	// 与 ArborDayActivityContext_v_0 同一活动族：本件是素材库 swf，导出符号
	// ArborDayRecordPanelView/ArborDayDetailPanelView/ArborDayScoreAlertPanelView/
	// ArborDayFinalPresentPanelView（com.qzone.allianceActivity 包，见本件
	// scripts/），被 context 的 view 类 import 引用（ArborDayActivityRecordWin
	// .as:3 等四处，见 context 件考证）。外部引用：**部署内零引用**——
	// nc_addon.php activity_list 无 arbor 条目（仅 nc_addon.php:126/128 两条）、
	// 三客户端反编译与 PHP 全树无文件名命中（排查范围同 context 件）。
	// 活跃判定：非活跃（依附 context，context 不加载则本件无加载路径）。
	// 定级建议：建议**冻结**（给所有者拍板）——与 context 同进退，不可单独立项。
	public static var ARBOR_DAY_LV2_PANEL_VIEW_V_0:String = "与 ArborDayActivityContext_v_0 同一活动族：本件是素材库 swf，导出符号 ArborDayRecordPanelView/ArborDayDetailPanelView/ArborDayScoreAlertPanelView/ArborDayFinalPresentPanelView（com.qzone.allianceActivity 包，见本件 scripts/），被 context 的 view 类 import 引用（ArborDayActivityRecordWin.as:3/ArborDayActivityDetailWin.as:3/ScoreNotEnoughtAlertWin.as:3/ArborDayActivityFinalPresentWin.as:3 四处，见 context 件考证）。外部引用：部署内零引用——nc_addon.php activity_list 无 arbor 条目（仅 nc_addon.php:126 olympicGames/nc_addon.php:128 collecting 两条）、三客户端反编译与 PHP 全树无文件名命中（排查范围同 context 件：nc_addon 全文件、main3/happyfarm3/Master2 反编译全树、xml 配置目录）。活跃判定：非活跃（依附 context，context 不加载则本件无加载路径）。定级建议：建议冻结（给所有者拍板）——与 context 同进退，不可单独立项。";

	// ui/dialogs/arborDayMainPanelView_v_0：植树节活动面板族，主面板 78KB
	// 与 ArborDayActivityContext_v_0 同一活动族：本件是主面板素材库 swf，
	// 导出符号 ArborDayMainPanelView（com.qzone.allianceActivity 包），被
	// context 的 ArborDayActivityWin.as:3 import、:83 `new ArborDayMainPanelView()`
	// 实例化为主窗视图。外部引用：**部署内零引用**——nc_addon.php activity_list
	// 无 arbor 条目（仅 nc_addon.php:126/128 两条）、三客户端反编译与 PHP
	// 全树无文件名命中（排查范围同 context 件）。
	// 活跃判定：非活跃（依附 context）。
	// 定级建议：建议**冻结**（给所有者拍板）——与 context 同进退。
	public static var ARBOR_DAY_MAIN_PANEL_VIEW_V_0:String = "与 ArborDayActivityContext_v_0 同一活动族：本件是主面板素材库 swf，导出符号 ArborDayMainPanelView（com.qzone.allianceActivity 包），被 context 的 ArborDayActivityWin.as:3 import、:83 new ArborDayMainPanelView() 实例化为主窗视图。外部引用：部署内零引用——nc_addon.php activity_list 无 arbor 条目（仅 nc_addon.php:126 olympicGames/nc_addon.php:128 collecting 两条）、main3/happyfarm3/Master2 反编译与 PHP source 全树无文件名命中（排查范围：nc_addon 全文件、三客户端反编译全树、xml 配置目录、PHP source）。活跃判定：非活跃（依附 context，context 无配置条目不加载）。定级建议：建议冻结（给所有者拍板）——与 context 同进退，三件套要么整体立项要么整体冻结。";

	// ui/lite_ui_v_0：10 个 *_Lite 类，加载链待查
	// 引用出处：预加载器硬引用——happyfarm3_v_149 FarmLite.as:366
	// `uiResUrl = this._settings.replaceAppImg("module/ui/lite_ui_v_0.swf")`
	// + :369 加载键 "lite_ui" 进 CmdLoadFile 队列（与 mainXMLUrl/config_data
	// 同批，boot 阶段必载）。**不是 URL 表配置 key，是硬编码路径**（#67 要求
	// 区分两者）。消费侧：happyfarm3 module/lite/FarmLiteView.as 直接
	// `new *_Lite` 符号——:67 canPickIcon_Lite、:183 Wasteland_Lite、
	// :200 Farmland_Lite、:204 FarmlandRed_Lite、:208 FarmlandBlack_Lite 等；
	// 本件导出恰 10 个 *_Lite 类（CursorArrow/CursorHand/DataLoading/
	// FarmLoading/Farmland/FarmlandBlack/FarmlandRed/TalkBoxMy1/Wasteland/
	// canPickIcon）。定位：boot 阶段加载界面/低配地块素材库（非「低配置模式」
	// 开关件）。
	// 活跃判定：**活跃**——FarmLite 是预加载器主类，每次启动必走 :366 加载。
	// 定级建议：**立项翻译**（给所有者拍板）——boot 必经路径上的功能 swf，
	// 且 10 个符号全是 boot 画面视觉件，画面保真硬需求直接相关。
	public static var LITE_UI_V_0:String = "引用出处：预加载器硬引用——happyfarm3_v_149 FarmLite.as:366 uiResUrl=this._settings.replaceAppImg(\"module/ui/lite_ui_v_0.swf\")+FarmLite.as:369 加载键 \"lite_ui\" 进 CmdLoadFile 队列（与 mainXMLUrl/config_data 同批，boot 阶段必载）。不是 URL 表配置 key，是硬编码路径（issue #67 已要求区分两者）。消费侧：happyfarm3 module/lite/FarmLiteView.as 直接 new *_Lite 符号——:67 canPickIcon_Lite、:183 Wasteland_Lite、:200 Farmland_Lite、:204 FarmlandRed_Lite、:208 FarmlandBlack_Lite 等；本件导出恰 10 个 *_Lite 类（CursorArrow_Lite/CursorHand_Lite/DataLoading_Lite/FarmLoading_Lite/Farmland_Lite/FarmlandBlack_Lite/FarmlandRed_Lite/TalkBoxMy1_Lite/Wasteland_Lite/canPickIcon_Lite）。定位：boot 阶段加载界面/地块素材库，非「低配置模式」开关件。活跃判定：活跃——FarmLite 是预加载器主类，每次启动必走 FarmLite.as:366 加载。定级建议：立项翻译（给所有者拍板）——boot 必经路径上的功能 swf，10 个符号全是 boot 画面视觉件，画面保真硬需求直接相关。";

	// ui/freegift_v_5：nc_addon freegift 键族，配置指 v_6 部署是 v_5（漂移）
	// 引用出处：nc_addon.php:289 secondList JSON
	// `{"id":"freegift","src":"module/ui/freegift_v_6.swf"}`。
	// 活跃判定双要素（issue 点名版本漂移待核）：(1) **漂移坐实**——配置指
	// freegift_v_6.swf，部署包 module/ui/ 下只有 freegift_v_5.swf，无 v_6 文件；
	// 即便有消费方，加载也是 404。(2) **消费方缺位**——main3 反编译全树 grep
	// `getSecondUrl("freegift")` 零命中；secondList 键的消费形态是经
	// Settings.getSecondUrl(id) 取址（对照 recall 键 RecallView.as:65 有消费），
	// freegift 键无任何调用方。main3 module/FreeGift/ModuleFreeGift.as 是免费
	// 礼物模块壳，但它走 Utils.getClass 反射外部模块（module.FreeGift.
	// FreeGiftController 在 gifts_v_11 里，#67 已考证），与本 freegift 键族
	// 无关——freegift≠gifts。两要素叠加 → 部署内不活跃（死键+死文件）。
	// 本件内容：FreeGiftGetTip/FreeGiftSendTip/HallowExp/HallowThanks/HallowTick
	// 等礼物赠送提示符号族（含万圣节外观件）。
	// 定级建议：建议**冻结**（给所有者拍板）——配置漂移+零消费方，快照无路径
	// 走到；若所有者要保真 secondList 全键族可改立项（按素材库翻译）。
	public static var FREEGIFT_V_5:String = "引用出处：nc_addon.php:289 secondList JSON {\"id\":\"freegift\",\"src\":\"module/ui/freegift_v_6.swf\"}。活跃判定双要素：(1) 版本漂移坐实——配置指 freegift_v_6.swf，部署包 module/ui/ 下只有 freegift_v_5.swf 无 v_6；即便有消费方加载也是 404。(2) 消费方缺位——main3 反编译全树 grep getSecondUrl(\"freegift\") 零命中；secondList 键的消费形态是经 Settings.getSecondUrl(id) 取址（对照 recall 键 RecallView.as:65 有消费），freegift 键无任何调用方。main3 module/FreeGift/ModuleFreeGift.as 是免费礼物模块壳，但走 Utils.getClass 反射外部模块（module.FreeGift.FreeGiftController 在 gifts_v_11 里，issue #67 已考证），与本 freegift 键族无关——freegift≠gifts。两要素叠加→部署内不活跃（死键+死文件）。本件内容：FreeGiftGetTip/FreeGiftSendTip/HallowExp/HallowThanks/HallowTick/freeSendItem 等礼物赠送提示符号族（含万圣节外观件）。定级建议：建议冻结（给所有者拍板）——配置漂移+零消费方，快照无路径走到；若要保真 secondList 全键族可改立项（按素材库翻译）。";

	// ui/monthEnd_v_5：nc_addon.php:121 指 monthEnd_v_8 部署只有 v_5（漂移），
	// 窗口期 2012-7-20~8-13 已过期
	// 引用出处：nc_addon.php:121 `<monthEnd id="0" ... url="module/ui/
	// monthEnd_v_8.swf" start="7/20/2012 00:00:00" end="8/13/2012 23:59:59">`。
	// 加载链：**不是独立模块**——main3 内嵌 ShortcutBar.as:124
	// `isGiftTime()` 过门则 monthEndFn 挂月末图标（:571 MonthEndIcon 素材），
	// 点击进 monthEndClick（:194-209）`new MonthEndWin` + openWindows；
	// MonthEndWin.as:603 `LoadManager.add(Utils.addPrefix(Settings
	// .getMonthEnds("0","url")))` 取配置 url 加载本件 swf 作窗口内容。
	// 活跃判定双要素：(1) **版本漂移**——配置指 monthEnd_v_8.swf，部署只有
	// monthEnd_v_5.swf，加载必 404（MonthEndWin.as:605 对 ERROR 也进
	// completeHandler，窗口内容空）。(2) **窗口过期**——isGiftTime
	// （happyfarm3 Settings.as:460-479）以 CommonData.serverTime 比对
	// start/end：快照 serverTime=1794915896（≈2026-11）远在 2012-7-20~8-13
	// 窗外 → ShortcutBar.as:124 门为假，图标都不挂 → 链路易 cold 不走到。
	// 与 Master2 monthBegin 的关系澄清（issue 点名项）：Master2 module/
	// monthBegin/（MonthBeginController/MonthBeginWin/MonthEndGift.as）是
	// **牧场侧**月初礼包模块，名字里的 MonthEndGift 只是牧场月促礼物符号；
	// 本件是**农场侧**月末促销窗内容物——两者是不同模块，仅「月促」主题
	// 同源，无加载链关系。
	// 定级建议：建议**冻结**（给所有者拍板）——漂移+窗口过期双死，
	// 快照无路径走到。
	public static var MONTH_END_V_5:String = "引用出处：nc_addon.php:121 <monthEnd id=\"0\" name=\"monthend\" month=\"7月\" url=\"module/ui/monthEnd_v_8.swf\" start=\"7/20/2012 00:00:00\" end=\"8/13/2012 23:59:59\">。加载链：不是独立模块——main3 内嵌 ShortcutBar.as:124 isGiftTime() 过门则 monthEndFn 挂月末图标（ShortcutBar.as:571 MonthEndIcon 素材），点击进 monthEndClick（ShortcutBar.as:194-209）new MonthEndWin+openWindows；MonthEndWin.as:603 LoadManager.add(Utils.addPrefix(Settings.getMonthEnds(\"0\",\"url\"))) 取配置 url 加载本件 swf 作窗口内容。活跃判定双要素：(1) 版本漂移——配置指 monthEnd_v_8.swf，部署只有 monthEnd_v_5.swf，加载必 404；(2) 窗口过期——isGiftTime（happyfarm3 Settings.as:460-479）以 serverTime 比对 start/end：快照 serverTime=1794915896（≈2026-11）远在 2012-7-20~8-13 窗外→ShortcutBar.as:124 门为假，图标都不挂。与 Master2 monthBegin 的关系澄清（issue 点名项）：Master2 module/monthBegin/（MonthBeginController/MonthBeginWin/MonthEndGift.as）是牧场侧月初礼包模块，MonthEndGift 只是牧场月促礼物符号；本件是农场侧月末促销窗内容物——两者是不同模块，仅月促主题同源，无加载链关系。定级建议：建议冻结（给所有者拍板）——漂移+窗口过期双死，快照无路径走到。";

	// ui/recall_v_3：nc_addon recall 键 + Master2 mc/control/FarmCommand.as 命中
	// 引用出处：nc_addon.php:288 secondList JSON
	// `{"id":"recall","src":"module/ui/recall_v_3.swf"}`。农场侧模块链（完整）：
	// FarmApplication.as:1029 `new ModuleRecall` 注册进模块表 +
	// FarmApplication.as:1031 监听 MSG_SHOW_RECALL；ModuleRecall.as:37
	// load 时 `new RecallController`；RecallView.as:65
	// `Settings.getInstance().getSecondUrl("recall")` 取址经 RSLManager
	// requestClass 加载本件（RECALL_BG 等符号：recallBg/recallItem/
	// RequestItem/RequestNum）。触发链：Main.as:392 openZhaoHui() 过门 +
	// actiontype=request 匹配 + app_request_num!="0" → Main.as:399 派发
	// MSG_SHOW_RECALL（另 :448/:463 两条余量路径）。
	// 活跃判定：**开关开**——nc_addon.php:64 `<zhaohuiOpen>1</zhaohuiOpen>`，
	// happyfarm3 Settings.as:455-457 openZhaoHui() 判 "1" 为真 → 门开；
	// 但触发还依赖外部进链参数 actiontype=request（分享回流）或好友/消息
	// 余量计数，快照首启不占 actiontype → 首启不弹，属**条件活跃**（链路活、
	// 快照首启路径不走）。
	// 牧场/农场归属澄清（issue 点名项）：Master2 mc/control/FarmCommand.as:49/
	// :890-897 的 `_recallTime` 经考证是**拍蚊子（killFly）失败重试计数器**
	// （ecode!=0 时 ++、<3 重派 killFlyError、成功清零）——与召回模块无关的
	// 伪命中，牧场侧不存在 recall 加载链；本件纯农场侧。
	// 定级建议：**立项翻译**（给所有者拍板）——农场常驻召回模块，开关开、
	// 链路完整，属 main3 已注册模块的素材依赖。
	public static var RECALL_V_3:String = "引用出处：nc_addon.php:288 secondList JSON {\"id\":\"recall\",\"src\":\"module/ui/recall_v_3.swf\"}。农场侧模块链（完整）：FarmApplication.as:1029 new ModuleRecall 注册进模块表+FarmApplication.as:1031 监听 MSG_SHOW_RECALL；ModuleRecall.as:37 load 时 new RecallController；RecallView.as:65 Settings.getInstance().getSecondUrl(\"recall\") 取址经 RSLManager requestClass 加载本件（RECALL_BG 等符号 recallBg/recallItem/RequestItem/RequestNum）。触发链：Main.as:392 openZhaoHui() 过门+actiontype=request 匹配+app_request_num!=\"0\"→Main.as:399 派发 MSG_SHOW_RECALL（另 Main.as:448/:463 两条余量路径）。活跃判定：开关开——nc_addon.php:64 <zhaohuiOpen>1</zhaohuiOpen>，happyfarm3 Settings.as:455-457 openZhaoHui() 判 \"1\" 为真→门开；但触发还依赖外部进链参数 actiontype=request（分享回流）或好友/消息余量计数，快照首启不占 actiontype→首启不弹，属条件活跃（链路活、快照首启路径不走）。牧场/农场归属澄清（issue 点名项）：Master2 mc/control/FarmCommand.as:49/:890-897 的 _recallTime 经考证是拍蚊子（killFly）失败重试计数器（ecode!=0 时自增、<3 重派 killFlyError、成功清零）——与召回模块无关的伪命中，牧场侧不存在 recall 加载链；本件纯农场侧。定级建议：立项翻译（给所有者拍板）——农场常驻召回模块，开关开、链路完整，属 main3 已注册模块的素材依赖。";

	// ui/sellyouji_v_1：未定位引用
	// 引用出处排查结果：**部署内零引用**。排查范围：(1) nc_addon.php 全文件
	// （含 secondList :248-296、plugins :301-330、素材列表）无 sellyouji/
	// SellYouJi/youji 命中；(2) main3/happyfarm3/mcloader 反编译全树 grep
	// 三种拼写零命中；(3) PHP source/ 全树零命中（无对应 cgi mod）。
	// 本件内容：SellYouJiIcon+SellYouJiWindow 两个符号（window 含
	// item0-3/btnGotoShop/btnClose 四格卖货窗），「有机（youji）」应是有机肥/
	// 有机作物售卖活动件。无任何加载链可查——未验证项无残留（排查已穷尽
	// 部署内三客户端+配置+PHP 三层）。
	// 活跃判定：非活跃（零引用）。
	// 定级建议：建议**冻结**（给所有者拍板）——孤儿活动件，疑似线下活动
	// 遗留；reason 写本考证结论。
	public static var SELLYOUJI_V_1:String = "引用出处：部署内零引用。排查范围：(1) nc_addon.php 全文件（含 secondList nc_addon.php:248-296、plugins nc_addon.php:301-330、素材列表）无 sellyouji/SellYouJi/youji 命中；(2) main3/happyfarm3/mcloader 反编译全树 grep 三种拼写零命中；(3) PHP source/ 全树零命中（无对应 cgi mod）。本件内容：SellYouJiIcon+SellYouJiWindow 两个符号（window 含 item0-3/btnGotoShop/btnClose 四格卖货窗），「youji」应是有机肥/有机作物售卖活动件。无任何加载链可查——排查已穷尽部署内三客户端+配置+PHP 三层，无残留未验证点。活跃判定：非活跃（零引用）。定级建议：建议冻结（给所有者拍板）——孤儿活动件，疑似线下活动遗留；reason 写本考证结论。";

	// ui/singleFes_v_0：未定位引用
	// 引用出处排查结果：**部署内零引用**（swf 文件名层面）。排查范围：
	// (1) nc_addon.php 全文件无 singleFes/singleShare 命中；(2) main3/
	// happyfarm3 反编译全树 grep singleFes/SingleFes/singleShare 零命中；
	// (3) PHP 全树无文件名命中。**但有一条残迹链须写明**：main3
	// framework/net/CommandDefs.as:236 `CMD_SINGLE_FES=204` +
	// ServerServices.as:153 `mod=cgi_farm_guang_gun`（光棍节 mod，PHP 侧
	// cgi_farm_guang_gun.php 存在）——协议端点注册在案，但反编译全树
	// **无任何代码使用 CMD_SINGLE_FES**（除定义/注册两处外零命中），即
	// 客户端调用方已移除、只剩死注册；swf 本体（singleFes_fla/singleShare）
	// 应是 2011 光棍节活动窗。文件名层面零引用+协议层死注册。
	// 活跃判定：非活跃。
	// 定级建议：建议**冻结**（给所有者拍板）——节日活动已过期且客户端
	// 调用方不存在。
	public static var SINGLE_FES_V_0:String = "引用出处：部署内零引用（swf 文件名层面）。排查范围：(1) nc_addon.php 全文件无 singleFes/singleShare 命中；(2) main3/happyfarm3 反编译全树 grep singleFes/SingleFes/singleShare 零命中；(3) PHP 全树无文件名命中。但有一条残迹链须写明：main3 framework/net/CommandDefs.as:236 CMD_SINGLE_FES=204+ServerServices.as:153 mod=cgi_farm_guang_gun（光棍节 mod，PHP 侧 cgi_farm_guang_gun.php 存在）——协议端点注册在案，但反编译全树无任何代码使用 CMD_SINGLE_FES（除 CommandDefs.as:236 定义/ServerServices.as:153 注册两处外零命中），即客户端调用方已移除、只剩死注册；swf 本体（singleFes_fla/singleShare）应是 2011 光棍节活动窗。文件名层面零引用+协议层死注册。活跃判定：非活跃。定级建议：建议冻结（给所有者拍板）——节日活动已过期且客户端调用方不存在。";

	// ui/stocks_v_2：未定位引用
	// 引用出处排查结果：**部署内零引用**。排查范围：(1) nc_addon.php 全文件
	// 无 stocks/Stocking/ChristmasWindow 命中；(2) main3/happyfarm3/mcloader
	// 反编译全树 grep 三种拼写零命中；(3) PHP source/ 全树零命中。
	// 本件内容：ChristmasWindow1/ChristmasWindow2（btnGetGift/btnClose 圣诞
	// 礼物窗）+ToolStocking（圣诞袜道具符号）——圣诞节活动件。无加载链可查，
	// 排查穷尽三层无残留。
	// 活跃判定：非活跃（零引用）。
	// 定级建议：建议**冻结**（给所有者拍板）——节日孤儿件。
	public static var STOCKS_V_2:String = "引用出处：部署内零引用。排查范围：(1) nc_addon.php 全文件无 stocks/Stocking/ChristmasWindow 命中；(2) main3/happyfarm3/mcloader 反编译全树 grep stocks/Stocking/ChristmasWindow 三种拼写零命中；(3) PHP source/ 全树零命中。本件内容：ChristmasWindow1/ChristmasWindow2（btnGetGift/btnClose 圣诞礼物窗）+ToolStocking（圣诞袜道具符号）——圣诞节活动件。无加载链可查，排查穷尽配置/客户端/PHP 三层无残留。活跃判定：非活跃（零引用）。定级建议：建议冻结（给所有者拍板）——节日孤儿件。";

	// ui/QDSeed_v_1：未定位引用
	// 引用出处排查结果：**部署内零引用**（swf 文件名层面）。排查范围：
	// (1) nc_addon.php/nc_data.php/nc_main.php 无 qdseeds 配置节（ConfigMerger
	// 的合并名单里有 qdseeds 键——main3 common/misc/ConfigMerger.as:152
	// `mergeCommonNode("qdseeds")`——但下发的 XML 里该节点不存在）；
	// (2) main3/happyfarm3 反编译全树除 ConfigMerger.as:152 与 EventRecorder
	// .as:143/145 两个上报常量（QDSEED_BUYCLICK/QDSEED_BUYSUCCESS）外零命中，
	// 无任何加载/消费代码；(3) PHP 全树零命中。本件内容：QDSeed_fla 时间轴
	// 件（frame1 仅 stop）——「Q点种子」售卖窗残留。配置节缺位+消费代码
	// 缺位，仅有死合并键与死上报常量。
	// 活跃判定：非活跃。
	// 定级建议：建议**冻结**（给所有者拍板）——运营入口已拆除的残留件。
	public static var QD_SEED_V_1:String = "引用出处：部署内零引用（swf 文件名层面）。排查范围：(1) nc_addon.php/nc_data.php/nc_main.php 无 qdseeds 配置节（ConfigMerger 合并名单里有 qdseeds 键——main3 common/misc/ConfigMerger.as:152 mergeCommonNode(\"qdseeds\")——但下发的 XML 里该节点不存在）；(2) main3/happyfarm3 反编译全树除 ConfigMerger.as:152 与 happyfarm3 report/EventRecorder.as:143/:145 两个上报常量（QDSEED_BUYCLICK/QDSEED_BUYSUCCESS）外零命中，无任何加载/消费代码；(3) PHP source/ 全树零命中。本件内容：QDSeed_fla/Timeline_2.as 时间轴件（frame1 仅 stop）——Q点种子售卖窗残留。配置节缺位+消费代码缺位，仅有死合并键与死上报常量。活跃判定：非活跃。定级建议：建议冻结（给所有者拍板）——运营入口已拆除的残留件。";

	// ui/farm/houseKeeper_v_0：未定位引用
	// 引用出处排查结果：**部署内零引用**（swf 文件名层面）。排查范围：
	// (1) nc_addon.php 全文件无 houseKeeper 命中；(2) main3/happyfarm3
	// 反编译全树 grep houseKeeper/HouseKeeper 零命中（文件名层面）；
	// (3) PHP 全树无文件名命中。**残迹链**：main3 framework/net/
	// CommandDefs.as:234 `CMD_HOUSE_KEEPER=202` + ServerServices.as:152
	// `mod=cgi_farm_housekeeper` 协议注册——但 PHP source/nc/mod/ 下
	// **没有 cgi_farm_housekeeper.php**（mod 文件不存在，调用必 404），
	// 且客户端无任何代码使用 CMD_HOUSE_KEEPER（除定义/注册外零命中）。
	// 本件内容：Tool_7_3（道具符号，同目录 houseKeeperGift_v_0.xml:4
	// 以 cla='Tool_7_3' 引用作礼包图标）+a1087 两符号；配套 xml 本身也
	// 无客户端引用（grep houseKeeperGift 零命中）——「管家」应是已下线的
	// 托管功能。协议死注册+后端 mod 缺文件+配套 xml 死引用三重死。
	// 活跃判定：非活跃。
	// 定级建议：建议**冻结**（给所有者拍板）——功能整体拆除的残留件；
	// Tool_7_3 若将来进道具素材体系可按需单捞，不必随本批立项。
	public static var HOUSE_KEEPER_V_0:String = "引用出处：部署内零引用（swf 文件名层面）。排查范围：(1) nc_addon.php 全文件无 houseKeeper 命中；(2) main3/happyfarm3 反编译全树 grep houseKeeper/HouseKeeper 零命中（文件名层面）；(3) PHP source/ 全树无文件名命中。残迹链：main3 framework/net/CommandDefs.as:234 CMD_HOUSE_KEEPER=202+ServerServices.as:152 mod=cgi_farm_housekeeper 协议注册——但 PHP source/nc/mod/ 下没有 cgi_farm_housekeeper.php（mod 文件不存在，调用必 404），且客户端无任何代码使用 CMD_HOUSE_KEEPER（除 CommandDefs.as:234 定义/ServerServices.as:152 注册外零命中）。本件内容：Tool_7_3（道具符号，同目录 houseKeeperGift_v_0.xml:4 以 cla='Tool_7_3' 引用作礼包图标）+a1087 两符号；配套 xml 本身也无客户端引用（grep houseKeeperGift 零命中）——管家应是已下线的托管功能。协议死注册+后端 mod 缺文件+配套 xml 死引用三重死。活跃判定：非活跃。定级建议：建议冻结（给所有者拍板）——功能整体拆除的残留件；Tool_7_3 若将来进道具素材体系可按需单捞，不必随本批立项。";

	public function new() {}
}
