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
	// Consts.as:218（issue #21：onTaskAllOver 的全部完成提示窗类型）
	public static final ALERT_TYPE_SUCCESS:String = "success";
	// Consts.as:222（issue #20：好友列表功能开关提示窗类型）
	public static final ALERT_TYPE_TIP:String = "tip";
	// Consts.as:224（issue #9：NavigationBar 超市未点亮提示窗类型）
	public static final ALERT_TYPE_TEXT:String = "text";
	public static final MSG_REQUEST_NET_CLIENT_ERROR:String = "RequestNetError";
	public static final MSG_REQUEST_CHECK_ERROR:String = "RequestCheckError";
	public static final CMD_NAME_REQUESTSERVICE:String = "CmdServiceRequest";

	// 场景与层
	public static final SCENE_WIDTH:Int = 1024;
	public static final SCENE_HEIGHT:Int = 800;
	public static final SCENE_ZINDEX_MIDDLE:String = "1.MIDDLE";
	// Consts.as:498/:502（BackgroundScreen 落 BACKGROUND 层、FarmLandsView 落 LAND 层）
	public static final SCENE_ZINDEX_BG:String = "0.BACKGROUND";
	public static final SCENE_ZINDEX_LAND:String = "2.LAND";
	public static final SCENE_ZINDEX_FOREGROUND:String = "3.FOREGROUND";
	public static final LAYER_SCENE_CONTENT:String = "Game Scene Layer";
	public static final LAYER_TOOLS:String = "Tools UI Layer";
	public static final LAYER_FRIEND:String = "Friend List Layer";
	public static final LAYER_TASK:String = "Task Layer";
	public static final LAYER_TOPMOST:String = "Top Most Layer";
	public static final LAYER_WILD:String = "Wild Layer";
	public static final LAYER_DAILYMISSION:String = "DailyMission UI Layer";
	public static final LAYER_STRONG_GUIDE:String = "LAYER_STRONG_GUIDE";
	public static final LAYER_WINDOW:String = "Window Layer";
	public static final LAYER_TIP:String = "Tip Layer";
	public static final LAYER_FLOATING:String = "Floating Layer";
	public static final LAYER_CURSOR:String = "Cursor Layer";

	// 主循环与模块名
	public static final MAIN_TIMER_FREQ:Int = 100;
	public static final MODULE_MAINSCENE:String = "Main Scene";
	public static final MODULE_MESSAGES:String = "Messages Module";
	public static final MODULE_RECALL:String = "Recall Module";
	public static final MODULE_UITOOLS:String = "UI Tools";
	public static final MODULE_FRIENDS:String = "Firends List";
	public static final MODULE_SHOP:String = "Shop Module";
	public static final MODULE_DIY:String = "Decorate Module";
	public static final MODULE_WAREHOUSE:String = "Warehouse Module";
	public static final MODULE_TASK:String = "Task Module";
	public static final MODULE_WATER:String = "Water Pool Module";
	public static final MODULE_CARDS_GAME:String = "Cards Module";
	public static final MODULE_QUICK_SHOOT:String = "Quick Shoot Module";
	public static final MODULE_FREE_GIFT:String = "FreeGift Module";
	public static final PLUGIN_AMOUNT_BG:Int = 0;
	// Consts.as:516（issue #9：ShortcutBar 插件位数量）
	public static final PLUGIN_AMOUNT_SHORTCUT:Int = 5;
	// Consts.as:512（issue #38：装饰窗插件位数量，DecorateView 页签 3）
	public static final PLUGIN_AMOUNT_DECORATE:Int = 3;
	// Consts.as:40（FarmLandController 收获倒计时秒数）
	public static final FARM_LAND_COUNTDOWN:Int = 10;
	// Consts.as:42（issue #37：WaterPool 切换倒计时秒数）
	public static final WATER_POOL_COUNTDOWN:Int = 12;
	// Consts.as:46（issue #37：FishAnimationMgr 鱼池 GC 倒计时秒数）
	public static final FISH_POOL_GC_COUNTDOWN:Int = 300;

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
	public static final MSG_SET_LAND_CURSOR:String = "SetLandCursor";
	public static final MSG_SHOW_UPGRADE_RED:String = "ShowUpgradeRedWindow";
	public static final MSG_SHOW_RECALL:String = "ShowRecall";
	public static final MSG_SHOW_PROFILE:String = "ShowProfile";
	public static final MSG_SHOW_PACK:String = "ShowMyPackage";
	public static final MSG_SHOW_SHOP:String = "ShowShop";
	public static final MSG_SHOW_BUY_DOG_FOOD:String = "ShowBuyDogFood";
	public static final MSG_SHOW_BUY_SEED:String = "ShowBuySeed";
	// Consts.as:332（issue #35：ShopView.showBuyItemWindow 的狗粮刷新派发）
	public static final MSG_REFRSH_MY_DOG_FOOD:String = "RefreshMyDogFood";
	// Consts.as:296
	public static final MSG_SHOW_WAREHOUSE:String = "ShowWarehouse";
	public static final MSG_SHOW_WAREHOUSE_SELL:String = "ShowWarehouseSell";
	// Consts.as:298（issue #36：WarehouseView 的关闭消息）
	public static final MSG_HIDE_WAREHOUSE:String = "HideWarehouse";
	// Consts.as:286/:288/:290（issue #36：PackageTab 页签帧按钮派发，MyBagView
	// 挂到 m_switchBtn 上）
	public static final MSG_SWITCH_TO_SEED:String = "seed";
	public static final MSG_SWITCH_TO_TOOL:String = "tool";
	public static final MSG_SWITCH_TO_FISH:String = "fish";
	public static final MSG_SHOW_FREEGIFT:String = "ShowFreegift";
	public static final MSG_SHOW_DIY:String = "ShowDIY";
	public static final MSG_SHOW_HEALTHMODE:String = "ShowHealthModeWindow";
	public static final MSG_SHOW_CARDSGAMEWINDOW:String = "ShowCardsGameWindow";
	// Consts.as:312（Player._healthMode 到期派发，HealthModeWindow 关）
	public static final MSG_HEALTHMODE_TIMEOUT:String = "HealthModeTimeout";
	// Consts.as:314（issue #9：健康模式开关窗派发，UIController 监听）
	public static final MSG_HEALTH_MODE_OPEN_CHANGED:String = "HealthModeOpenChanged";
	// Consts.as:316
	public static final MSG_CHECK_HEALTHMODE:String = "CheckHealthMode";
	// Consts.as:318（野兽偷菜完成提示）
	public static final MSG_WILD_BEAST_STEAL:String = "StealCrop";
	// Consts.as:324（issue #20：召回好友请求应答，FriendsController 监听）
	public static final MSG_BACK_UPDATE_STATUS:String = "msg_back_update_status";
	// Consts.as:330（任务完成待检）
	public static final MSG_CHECK_TASK:String = "CheckTaskComplete";
	// Consts.as:340（issue #9：每日礼包领取触发，UIController 监听）
	public static final MSG_ACCEPT_NEW_GIFT:String = "AcceptNewGift";
	// Consts.as:334/:336（DIY 预览进出）
	public static final MSG_ENTER_PREVIEW:String = "EnterPreview";
	public static final MSG_EXIT_PREVIEW:String = "ExitPreview";
	// Consts.as:338（BackgroundController 监听重铺场景）
	public static final MSG_REFRESH_SCENE:String = "RefreshBackgroundScene";
	// Consts.as:344（自己地块可摘提示）
	public static final MSG_LAND_CAN_PICK:String = "CurrentUserCanPick";
	// Consts.as:346（好友列表状态刷新）
	public static final MSG_REFRESH_FRIEND_STATUS:String = "RefreshFriendList";
	// Consts.as:348（从牧场回来后开仓库）
	public static final MSG_OPEN_WAREHOUSE_AFTER_BACK:String = "OpenWarehouseAfterBack";
	// Consts.as:360（升级）
	public static final MSG_LEVELUP:String = "LevelUp";
	// Consts.as:362（issue #9：UIController 监听升级检查）
	public static final MSG_CHECK_LEVELUP:String = "CheckLevelup";
	// Consts.as:350/:352（issue #36：送花/删花消息，WarehouseController 监听）
	public static final MSG_FLOWER_SEND:String = "SendFlower";
	public static final MSG_FLOWER_DELETED:String = "FlowerDeleted";
	// Consts.as:370（issue #36：鱼苗引导步派发，UIController 引导片消费）
	public static final MSG_FISH_GUIDE:String = "ShowWaterOpenGuide";
	// Consts.as:400（issue #36：按 id 卖出时仓库无此作物的兜底消息）
	public static final MSG_NO_CROP_WAREHOUSE:String = "NoCropInWarehouse";
	// Consts.as:378（FarmLandsView 鼠标移入显示光标）
	public static final MSG_SHOW_LAND_CURSOR:String = "ShowLandCursor";

	// Consts.as:376（FarmLandController.showWaterCursor 探鱼竿光标占用）
	public static final MSG_SHOW_WATER_CURSOR:String = "ShowWaterCursor";
	// Consts.as:384（NPCView 派发呼叫飞机）
	public static final MSG_CALL_PLANE:String = "CallPlane";
	// Consts.as:366（issue #9：水池模块打开，UIController 监听刷工具条）
	public static final MSG_POOL_OPEN:String = "WaterPoolOpened";
	// Consts.as:374（issue #20：鱼塘状态位更新，FriendsController 监听）
	public static final MSG_REFRESH_FISH_FRIENDLIST:String = "RefreshFishStatusInFriendList";
	// Consts.as:380（issue #9：水池容量刷新，UIController 画 PoolInfo 角标）
	public static final MSG_REFRESH_POOLINFO:String = "RefreshPoolInfo";
	// Consts.as:382（issue #9：PoolInfo 角标点击开窗）
	public static final MSG_SHOW_POOLINFO:String = "ShowPoolInfoWindow";
	// Consts.as:388（FarmLandsView 监听整体重铺）
	public static final MSG_REFRESH_LANDS_DATA:String = "RefreshAllLands";
	// Consts.as:412（NPCView 监听安装活动 NPC）
	public static final MSG_INSTALL_NPC:String = "InstallActivityNPC";
	// Consts.as:414（单块地数据到位）
	public static final MSG_GET_LAND_DATA:String = "GetLandCropData";
	// Consts.as:390（issue #9：移除活动收集图标提示）
	public static final DELEVE_NEW_ICON:String = "DELEVE_NEW_ICON";
	// Consts.as:416（issue #9：安装收集活动图标）
	public static final MSG_ADD_COLLECTING_ICON:String = "AddCollectingIcon";
	// Consts.as:356（issue #9：LeftSideToolBar 监听移除活动图标）
	public static final MSG_REMOVE_SHORTCUT_ICON:String = "RemoveShortcutBarIcon";
	// Consts.as:396（issue #9：免费礼物数清零）
	public static final MSG_FREEGIFT_COUNT_OUT:String = "freegiftcountout";
	// Consts.as:398（issue #20：精灵供奉完成，FriendsController 列表去 "7"）
	public static final MSG_FAIRY_DONATED:String = "DonateFriendFairy";
	// Consts.as:402（issue #9：签到活动图标增删）
	public static final MSG_REFRESH_CARDSGAME:String = "CardsGameUpdated";
	// Consts.as:600（issue #9：ShortcutBar 监听安装入口图标）
	public static final ADD_ENTRANCE_ICON:String = "ADD_ENTRANCE_ICON";
	// Consts.as:590（关闭背包窗口）
	public static final CLOSE_MY_BAG:String = "CLOSE_MY_BAG";
	// Consts.as:592-594（金土地）
	public static final GOLD_LAND_UPDATE_TIME:String = "GOLD_LAND_UPDATE_TIME";
	public static final GOLD_LAND_BUY_FAIL:String = "GOLD_LAND_UPDATE_FAIL";

	// 模型数据键
	public static final USER_DECORATE_OBJECT:String = "UserDecorate";
	// Consts.as:230-244（数据重装/变更标志）
	public static final DATA_CROP_RELOAD_FLAG:String = "CropsReload";
	public static final DATA_BAG_RELOAD_FLAG:String = "BagReload";
	public static final DATA_BAG_DATA_REMOVE:String = "BagDataRemove";
	// Consts.as:242（issue #36：MyBagController 监听背包条目入列）
	public static final DATA_BAG_DATA_ADD:String = "BagDataAdd";
	public static final DATA_DOG_CHANGED:String = "DogDataChanged";
	// Consts.as:236（issue #36：WarehouseController 监听成鱼数据重装标志）
	public static final DATA_FISH_RELOAD_FLAG:String = "FishReload";
	// Consts.as:238（issue #35：买入成功后背包条目入列的 ShopController 派发）
	public static final DATA_BUY_ITEM_ADD:String = "AddBuyItem";
	// Consts.as:245（issue #9：ShortcutBar 监听我的鲜花装载）
	public static final MY_FLOWER_LOADED:String = "MyFlowerLoaded";
	// Consts.as:232（issue #9：Session.addReward 的装饰重装派发）
	public static final DATA_DECORATE_RELOAD_FLAG:String = "DecorateReload";
	// Consts.as:386（issue #9：UIToolsModel.onPostMsgLoaded 的新feeds派发）
	public static final MSG_FEEDS_NPC_NEW_FEEDS_FLAG:String = "feedsNPCNewFeedsFlag";
	// Consts.as:268（当前用户切换）
	public static final MSG_CURRENT_USER_CHANGED:String = "CurrentUserChanged";

	// 窗口/提示/飘字/光标名（FarmStage/FarmApplication 注册用）
	public static final WINDOW_NAME_ALERT:String = "AlertWindow";
	// Consts.as:182（issue #9：LevelAndExperience 窗口名）
	public static final WINDOW_NAME_LEVEL_EXP:String = "LevelAndExp";
	public static final WINDOW_NAME_CONFIRM:String = "ConfirmWindow";
	public static final WINDOW_NAME_GIFT:String = "GiftWindow";
	public static final WINDOW_NAME_PREVIEWDIY:String = "PreviewDiyWindow";
	public static final WINDOW_NAME_REGIFT:String = "PickupGiftWindow";
	public static final WINDOW_NAME_REGIFT_CARD:String = "REGiftWindow";
	public static final WINDOW_NAME_REQUEST_ERROR:String = "RequestErrorWindow";
	// Consts.as:190（issue #21：WelcomeTaskWindow 注册名）
	public static final WINDOW_NAME_TASK_ACCEPT:String = "WelcomeTaskWindow";
	// Consts.as:192（issue #21：TaskOverWindow 注册名）
	public static final WINDOW_NAME_TASK_OVER:String = "TaskOverWindow";
	public static final WINDOW_NAME_UPGRADE_RED:String = "UpgradeRedLandWindow";
	public static final WINDOW_NAME_VALIDATE:String = "ValidateCodeWindow";
	public static final WINDOW_NAME_ABUTTON:String = "AddButtonWindow";
	public static final WINDOW_NAME_SHOP:String = "shop";
	public static final WINDOW_NAME_WAREHOUSE:String = "warehouse";
	// Consts.as:166（issue #38：DIY 装饰窗注册名）
	public static final WINDOW_NAME_DIY:String = "DiyWindow";
	public static final WINDOW_NAME_PROFILE:String = "profile";
	public static final WINDOW_NAME_BUYDIY:String = "BuyDiyWindow";
	// Consts.as:200（issue #35：BuyFishWindow 注册名）
	public static final WINDOW_NAME_BUYFISH:String = "BuyFishWindow";
	// Consts.as:194（issue #36：送花窗注册名，WarehouseController 注册）
	public static final WINDOW_NAME_SENDFLOWER:String = "SendFlowerWindow";
	// Consts.as:196（issue #36：鲜花卡片窗注册名）
	public static final WINDOW_NAME_FLOWER_CARD:String = "FlowerCard";
	// Consts.as:204（issue #36：卖出作物/材料窗注册名）
	public static final WINDOW_NAME_SELLPLANT:String = "SellCropWindow";
	// Consts.as:206（issue #36：种子管理（卖出种子）窗注册名）
	public static final WINDOW_NAME_SELLSEED:String = "SellSeedWindow";
	// Consts.as:208（issue #36：卖出成鱼窗注册名）
	public static final WINDOW_NAME_SELLFISH:String = "SellFishWindow";
	// Consts.as:202（issue #35：UnlockFishWindow 注册名）
	public static final WINDOW_NAME_UNLOCKFISH:String = "UnlockFishWindow";
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
	public static final CURSOR_SYSTEM:String = "system";
	// Consts.as:114（CursorControl.useSystem(false) 下发；issue #9 光标片）
	public static final CURSOR_CUSTOMIZE:String = "customize";

	// 道具/功能开关
	public static final ITEM_TYPE_SEED:String = "1";
	public static final ITEM_TYPE_TOOL:String = "3";
	public static final ITEM_TYPE_PLANE:String = "14";
	public static final ITEM_TYPE_RED_UPGRADE:String = "13";
	public static final ITEM_TYPE_BLACK_UPGRADE:String = "12";
	public static final ITEM_TYPE_FAIRY:String = "31";
	// Consts.as:460/:472/:474（V3b：NPCView 道具类型判断）
	public static final ITEM_TYPE_CARD:String = "11";
	public static final ITEM_TYPE_FISH:String = "23";
	public static final ITEM_TYPE_FISHFEED:String = "24";
	// Consts.as:444-478（issue #9：MaterialProxy.setContent 路由 /
	// Session.addReward 分类派发用的其余类型串）
	public static final ITEM_TYPE_DECORATE:String = "2";
	public static final ITEM_TYPE_DOG:String = "4";
	public static final ITEM_TYPE_MONEY:String = "6";
	public static final ITEM_TYPE_EXP:String = "7";
	public static final ITEM_TYPE_CRYSTAL:String = "9";
	public static final ITEM_TYPE_WEAPON:String = "10";
	public static final ITEM_TYPE_STICK:String = "21";
	public static final ITEM_TYPE_PESTICIDE:String = "22";
	public static final ITEM_TYPE_DOGFOOD:String = "909090";
	// Consts.as:478（issue #35：ShopModel.buyDiy 交易位 parseInt("808080")）
	public static final ITEM_TYPE_DIY:String = "808080";
	public static final ORGANIC_FERTILIZER_ID:Int = 30;
	public static final FAIRY_LADY:Int = 92001;
	// Consts.as:586（issue #36：PlantsPage 卖出合计的财神爷加成判定）
	public static final FAIRY_MONEY:Int = 92003;
	// Consts.as:588（issue #9：AddExpFloating 的花神加成判定）
	public static final FAIRY_GOD:Int = 92004;
	// Consts.as:566（issue #9：水池容量角标分母）
	public static final FISH_MAX_SIZE:UInt = 6;
	// Consts.as:568（issue #29：PoolFish 满级/可收获判定）
	public static final FISH_MAX_LEVEL:UInt = 3;
	// Consts.as:580（issue #9：藏獒 id，启动链狗到期提示）
	public static final DOG_TIBETAN_MASTIFF_ID:Int = 10;
	public static final MY_FAIRY_OBJECT:String = "MyFairy";
	public static final DECOR_DOG:UInt = 8;
	// Consts.as:496（DogRender：装饰狗 id 减基值得素材序号）
	public static final DECOR_DOG_BASE_ID:Int = 80000;
	// Consts.as:428-438（V3b：BackgroundModel/NPCModel 的装饰类型表；
	// 值照抄。DECOR_DOG 见上）
	public static final DECOR_BACKGROUND:UInt = 1;
	public static final DECOR_HOUSE:UInt = 2;
	public static final DECOR_FENCE:UInt = 3;
	public static final DECOR_DOGHOUSE:UInt = 4;
	public static final DECOR_BILLBOARD:UInt = 9;
	public static final GOLD_LAND_UPDATE_TIME_CHANGE:String = "GOLD_LAND_UPDATE_TIME_CHANGE";
	public static final APP_ID:Int = 353;
	// Consts.as:532-538（issue #36：仓库四仓位——collectNotLockedIDs 四路、
	// isEmpty 槽表、WarehouseView 页签位）
	public static final WAREHOUSE_CROP:Int = 1;
	public static final WAREHOUSE_FLOWER:Int = 2;
	public static final WAREHOUSE_CARD:Int = 3;
	public static final WAREHOUSE_FISH:Int = 4;
	// Consts.as:546（issue #9：餐厅跳转 appid）
	public static final RESTAURANT_APPID:Int = 372;
	public static final PAY_QD:Int = 1;
	public static final QQBROWSER_VER1:Int = 6;
	public static final QQBROWSER_VER2:Int = 6;
}
