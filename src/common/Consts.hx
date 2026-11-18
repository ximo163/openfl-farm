package common;

import openfl.net.URLRequestMethod;

/**
 * common.Consts —— 闭包 stub（issue #7，后续模块翻译，stub 同 module/Main 先例）。
 * 原版 legacy/decompiled/main3_v_221/scripts/common/Consts.as 是纯常量表
 *（609 loc），本片只收录被翻译类引用到的常量，取值逐字照抄 Consts.as 对应行
 *（常量是数据，非行为）；未引用的常量后续模块翻译时补齐。
 */
class Consts {
	// Consts.as —— 网络与错误
	public static final NET_HTTP_METHOD_GET:String = URLRequestMethod.GET;
	public static final NET_HTTP_METHOD_POST:String = URLRequestMethod.POST;
	public static final ALERT_TYPE_ERROR:String = "error";
	public static final MSG_REQUEST_NET_CLIENT_ERROR:String = "RequestNetError";
	public static final MSG_REQUEST_CHECK_ERROR:String = "RequestCheckError";
	public static final CMD_NAME_REQUESTSERVICE:String = "CmdServiceRequest";

	// 场景与层
	public static final SCENE_WIDTH:Int = 1024;
	public static final SCENE_HEIGHT:Int = 800;
	public static final SCENE_ZINDEX_MIDDLE:String = "1.MIDDLE";
	public static final SCENE_ZINDEX_FOREGROUND:String = "3.FOREGROUND";
	public static final LAYER_SCENE_CONTENT:String = "Game Scene Layer";
	public static final LAYER_TOOLS:String = "Tools UI Layer";
	public static final LAYER_FRIEND:String = "Friend List Layer";
	public static final LAYER_TASK:String = "Task Layer";
	public static final LAYER_TOPMOST:String = "Top Most Layer";
	public static final LAYER_WILD:String = "Wild Layer";
	public static final LAYER_DAILYMISSION:String = "DailyMission UI Layer";
	public static final LAYER_STRONG_GUIDE:String = "LAYER_STRONG_GUIDE";

	// 主循环与模块名
	public static final MAIN_TIMER_FREQ:Int = 100;
	public static final MODULE_MAINSCENE:String = "Main Scene";
	public static final MODULE_MESSAGES:String = "Messages Module";
	public static final MODULE_RECALL:String = "Recall Module";
	public static final PLUGIN_AMOUNT_BG:Int = 0;

	// 消息名
	public static final MSG_SESSION_TIMEOUT:String = "SessionTimeout";
	public static final MSG_NEED_VALIDATE_CODE:String = "validateCode";
	public static final MSG_STARTUP_DATA:String = "StartupDataReturned";
	public static final MSG_RELOAD_GAME_DATA:String = "ReloadUserGameData";
	public static final MSG_RELOAD_GAME_RESULT:String = "ReloadUserGameDataResult";
	public static final MSG_HOST_CHANGED:String = "HostDataChanged";
	public static final MSG_SWITCH_USER:String = "SwitchingUser";
	public static final MSG_USER_SWITCH_FLAG:String = "SwitchingUserFlag";
	public static final MSG_ZOOM:String = "ZoomInOut";
	public static final MSG_CAMERA:String = "CameraShoot";
	public static final MSG_ENTER_MC:String = "EnterPastuer";
	public static final MSG_WILD_TO_FARMSTAGE:String = "WildToFarmStage";
	public static final MSG_WILD_UPDATE_STATUS:String = "msg_wild_update_status";
	public static final MSG_LOAD_WATER:String = "LoadWaterPool";
	public static final MSG_LOAD_QUICKSHOOT:String = "LoadQuickShoot";
	public static final MSG_LOAD_FREEGIFT:String = "LoadFreeGift";
	public static final MSG_LOAD_CARDSGAME:String = "LoadCardsGame";
	public static final MSG_SET_QQBROWSER_ALARM:String = "SetQQBrowserAlarm";
	public static final MSG_PLAY_UPGRADE_RED_LAND:String = "PlayUpgradeLandAnimation";
	public static final MSG_TRUNK_SYSTEM_TOOLBAR:String = "TrunkSystemToolbar";
	public static final CLOSE_RECALL_WINDOW:String = "closerecallwindow";

	// 窗口/提示/飘字/光标名（FarmStage/FarmApplication 注册用）
	public static final WINDOW_NAME_ALERT:String = "AlertWindow";
	public static final WINDOW_NAME_CONFIRM:String = "ConfirmWindow";
	public static final WINDOW_NAME_GIFT:String = "GiftWindow";
	public static final WINDOW_NAME_REGIFT:String = "PickupGiftWindow";
	public static final WINDOW_NAME_REGIFT_CARD:String = "REGiftWindow";
	public static final WINDOW_NAME_REQUEST_ERROR:String = "RequestErrorWindow";
	public static final WINDOW_NAME_UPGRADE_RED:String = "UpgradeRedLandWindow";
	public static final WINDOW_NAME_VALIDATE:String = "ValidateCodeWindow";
	public static final WINDOW_NAME_ABUTTON:String = "AddButtonWindow";
	public static final TIP_NAME_MOUSE:String = "MouseTip";
	public static final TIP_NAME_LAND_INFOR:String = "LandInfoTip";
	public static final TIP_NAME_CROPINFO_MOUSE:String = "CropInfoTip";
	public static final TIP_NAME_DIY_MOUSE:String = "DiyMouseTip";
	public static final TIP_NAME_PROFILE_HISTORY:String = "ProfileHistoryItemTip";
	public static final FLOAT_TYPE_EXP:String = "AddExpFloating";
	public static final FLOAT_TYPE_MONEY:String = "AddMoneyFloating";
	public static final FLOAT_TYPE_OPERATE:String = "FarmOperateFloating";
	public static final FLOAT_TYPE_TEXTTIP:String = "TextTipFloating";
	public static final FLOAT_TYPE_HEALTH:String = "AddHealthAnimation";
	public static final FLOAT_TYPE_HA:String = "HarvestAnimation";
	public static final FLOAT_TYPE_HAC:String = "HarvestAnimationCustom";
	public static final FLOAT_TYPE_HAP:String = "HarvestAnimationPlus";
	public static final CURSOR_STYLE_ARROW:String = "CursorArrow";
	public static final CURSOR_STYLE_HAND:String = "CursorHand";
	public static final CURSOR_STYLE_TOOL:String = "CursorTool";
	public static final CURSOR_STYLE_WATER:String = "CursorWater";
	public static final CURSOR_STYLE_WEED:String = "CursorWeed";
	public static final CURSOR_STYLE_HOE:String = "CursorHoe";
	public static final CURSOR_STYLE_HOOK:String = "CursorHook";
	public static final CURSOR_STYLE_INSET:String = "CursorInsect";
	public static final CURSOR_STYLE_PESTICIDE:String = "CursorPesticide";
	public static final CURSOR_STYLE_CROPSEED:String = "CursorCropSeed";
	public static final CURSOR_STYLE_ONEHAND:String = "CursorOneClickHand";
	public static final CURSOR_STYLE_FISHNET:String = "CursorFishNet";
	public static final CURSOR_STYLE_FISHNET_ALL:String = "CursorFishNetAll";
	public static final CURSOR_WILD_ARROW:String = "Cursor_Wild_Arrow";
	public static final CURSOR_WILD_GUN:String = "Cursor_Wild_Gun";
	public static final CURSOR_WILD_HAND:String = "Wild_Cursor";
	public static final CURSOR_WILD_TOOL:String = "Cursor_Wild_Tool";

	// 道具/功能开关
	public static final ITEM_TYPE_SEED:String = "1";
	public static final ITEM_TYPE_TOOL:String = "3";
	public static final ITEM_TYPE_PLANE:String = "14";
	public static final ITEM_TYPE_RED_UPGRADE:String = "13";
	public static final ITEM_TYPE_BLACK_UPGRADE:String = "12";
	public static final ITEM_TYPE_FAIRY:String = "31";
	public static final ORGANIC_FERTILIZER_ID:Int = 30;
	public static final FAIRY_LADY:Int = 92001;
	public static final MY_FAIRY_OBJECT:String = "MyFairy";
	public static final DECOR_DOG:UInt = 8;
	public static final GOLD_LAND_UPDATE_TIME_CHANGE:String = "GOLD_LAND_UPDATE_TIME_CHANGE";
	public static final APP_ID:Int = 353;
	public static final PAY_QD:Int = 1;
	public static final QQBROWSER_VER1:Int = 6;
	public static final QQBROWSER_VER2:Int = 6;
}
