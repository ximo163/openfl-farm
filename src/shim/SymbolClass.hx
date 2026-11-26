package shim;

import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.geom.Point;
import openfl.utils.AssetLibrary;
import openfl.utils.Assets;
#if !eval
import swf.exporters.animate.AnimateLibrary;
#end

/**
 * Flash SymbolClass 直 new 语义的等价物（平台差异胶水，非新架构）。
 *
 * 原版：lite_ui_v_0.swf 的 SymbolClass 把 Farmland_Lite 等导出符号绑到同名
 * AS3 类，视图代码 `new Farmland_Lite()` 构造出的实例天然带着符号时间轴。
 *
 * openfl（swf 3.4.0，构建期 AnimateLibraryExporter，运行时
 * swf.exporters.animate.AnimateLibrary——swf 库的 SWFLite 路径已整体注释掉，
 * 本仓库构建产物 lib/*.zip 的 libraryType 即 AnimateLibrary）：符号只在经
 * Assets.getMovieClip 实例化时挂时间轴；直接 `new` 的同名 Haxe 类是空剪辑。
 * AnimateLibrary 提供了 `bind(className, instance)`（openfl 9.1+，@:bind 元
 * 数据同款入口）：把符号时间轴挂到已构造的实例上。
 *
 * 所以同名 Haxe 类的构造器补一步 bind：直接 new 时按上面入口挂时间轴——符号
 * 内容直接长在实例上，显示树结构与原版一致，不引入包装层。经库实例化进来的
 * （super() 消费 Sprite.__constructor 已挂好）则跳过，不会二次绑定。
 *
 * 库还没装载的情况分两种：farmui 系素材库由启动链（FarmLite.startLiteUI →
 * CmdLoadFile）先行拉起，视图构造时已在 Assets 里；作物分档 swf（Crop_*_*）
 * 原版是 requestClass 按需网络加载后才有类定义，而移植版类编译期即注册、
 * requestClass 的 URL 加载被 getClass 短路——这里把「库到位后符号可用」的
 * 原版时序补回来：库不在就按需 Assets.loadLibrary（html5 的非 preload 库在
 * libraryPaths 里，文件已随构建入库，无网络），同一个库的并发 bind 合并成
 * 一次加载。绑上的时刻晚于构造器返回，与原版「远程加载后 new」的时序差
 * 一个本就是异步的加载窗口（bindBitmap 的位图路径同款，见 pendingBitmaps
 * 与 ensureLibraryLoaded）。
 *
 * 这个异步窗口还吞写：原版 SymbolClass 类定义即绑定，new 完构造器返回时
 * 时间轴必然已在实例上，紧随其后的子件显隐写立即生效；移植版首次拉库时
 * 构造器只把实例入队，构造器返回后的写落在空剪辑上丢失（Crop 的 step1/2/3
 * 显隐就是这么丢的）。afterAttach 把这类写登记进待绑窗口，attach 后原样
 * 重放；时间轴已挂上（同步路径、或同库第二只起）则立即执行。
 */
class SymbolClass {
	// 按需加载中的库：libraryId → 等待绑定的 (symbolName, target) 列表；
	// after 收构造器返回后、attach 前登记的待重放写（见 afterAttach）。
	// 目标放宽到 DisplayObject：#9 工具条 11 枚素材是 DefineButton2（按钮
	// 符号，AnimateButtonSymbol.__constructor 往实例写四态），目标得是
	// SimpleButton（bindButton）；after 只有 MovieClip 路径（afterAttach）
	// 会登记，SimpleButton 目标恒为空数组
	private static var pending:Array<{libraryId:String, symbolName:String, target:DisplayObject, after:Array<MovieClip->Void>}> = [];

	// 位图路径的待拷队列（bindBitmap 的按需拉起窗口）：目标不是
	// DisplayObject，进不了 pending，单列一队，加载完成一并冲刷
	private static var pendingBitmaps:Array<{libraryId:String, symbolName:String, target:BitmapData}> = [];

	// 按需拉起在途的库。lime 的 loadLibrary 不去重并发请求（8.3,2 源可证，
	// 每次调用独立 Promise 重复拉同一文件），pending/pendingBitmaps 两队列
	// 对同一库都可能先后来，显式在途表合并成一次加载
	private static var loadingLibraries:Array<String> = [];

	// DCE 引用锚。Haxe 只编译从 main 可达（被引用/import）的类型；符号 shim
	// 只经反射字符串取用（getMaterial/getClass → ApplicationDomain →
	// Type.resolveClass），编译期零引用时 @:keep 也救不了——类整体不进产物
	// （in-pipeline probe 证实：零引用的 @:keep 类在 bundle 里不存在，反射恒
	// null，LandTile 为此抛 "Can not get land res!"）。AS3 无此问题：Loader
	// 装载 swf 即把 SymbolClass 类注册进 ApplicationDomain。bind 在启动链上
	// 必然执行，首次调用把全部符号 shim 拉进类型图，各自的 @:keep 负责在
	// dce full 下保命。新增符号 shim 时同步补一行。
	// 仅生产目标：eval 按惯例是「无资源」环境（LandItemRenderTest 以
	// updateLandStatus 的素材缺失抛出为前提断言），锚不能把这个前提翻掉。
	#if !eval
	private static var dceAnchor:Array<Class<Dynamic>>;
	#end

	public static function bind(target:MovieClip, libraryId:String, symbolName:String):Void {
		bindAny(target, libraryId, symbolName);
	}

	/**
	 * DefineButton2（按钮符号）的绑定入口：AnimateButtonSymbol.__constructor
	 * 往实例写 downState/hitTestState/overState/upState 四态，目标必须是
	 * SimpleButton——MovieClip 实例在 js 上没有这些 setter 直接 TypeError
	 * （#9 工具条 ToolHoe 等 11 枚）。加载时序与 bind() 完全共用（bindAny）。
	 */
	public static function bindButton(target:SimpleButton, libraryId:String, symbolName:String):Void {
		bindAny(target, libraryId, symbolName);
	}

	private static function bindAny(target:DisplayObject, libraryId:String, symbolName:String):Void {
	#if !eval
		if (dceAnchor == null) {
			dceAnchor = [
				com.qzone.ui.FarmlandS, com.qzone.ui.FarmlandS2, com.qzone.ui.FarmlandG, com.qzone.ui.FarmlandG2,
				com.qzone.ui.red.FarmlandS, com.qzone.ui.red.FarmlandS2, com.qzone.ui.red.FarmlandG, com.qzone.ui.red.FarmlandG2,
				com.qzone.ui.black.FarmlandS, com.qzone.ui.black.FarmlandS2, com.qzone.ui.black.FarmlandG, com.qzone.ui.black.FarmlandG2,
				com.qzone.ui.JPLandS, com.qzone.ui.JPLandS2, com.qzone.ui.JPLandG, com.qzone.ui.JPLandG2,
				com.qzone.ui.Wasteland,
				CursorFishNet, CursorFishNetAll,
				Crop_1_0, Crop_1_6, Crop_2_1, Crop_2_2, Crop_2_3,
				Insect, Weed, Reclaim, CanPickIcon,
				ItemLoading,
				PackBarBg,
				ToolBarBg,
				// #9 uitools 片：工具条/导航条按钮、图标、档案条、飘字素材（按钮
				// 表与图标经 getMaterial 反射，编译期零引用，必须锚进来）
				ToolArrow, ToolHand, OneClickHand, ToolHoe, ToolInsect, ToolPack, ToolBox, ToolTheft, ToolWeed,
				ToolUpgradeNew, ToolFishNet, ToolFishNetAll,
				// #9 ToolBoxBar/UIController 的按钮素材（同上 DefineButton2 组，
				// 开工具箱/水池角标时才构造，同样零引用）
				ToolHook, ToolPesticide, ToolWater, CameraButton, ToolZoomIn, ToolZoomOut, PoolInfoBtn,
				NewHealthModeIcon,
				ButtonFarm, ButtonMC, ButtonRestaurant, ButtonSuperMarket, ButtonMill1, ButtonWarehouse, ButtonShop,
				ButtonDecorate, NavigationLeftArrow, NavigationRightArrow,
				MsgIcon, PostIcon, InformationIcon, CardsGameIcon, CardsGameActivityIcon, FlowerIcon, GiftIcon,
				HeadBg, TipIcon, SuccessIcon, ErrorIcon, GoldIcon, QB, RPIcon,
				LevelBlue, LevelYellow, ExpBlue, ExpBlueBg, ExpYellow, ExpYellowBg, LevelAndExperienss,
				TalkBoxMy1, TalkBoxHe1, AddHealth, AddAnimationEx, HarvestPlusA, HarvestPlusB,
				LevelUpIcon, MonthEndIcon, MonthEndArrow, NewIconTip, Freegift, FreeGiftAni,
				// #9 光标片：FarmStage.register 直接引用（编译期可达），锚只为
				// 与上两组同表可查
				CursorArrow, CursorHand, CursorHoe, CursorHook, CursorInsect, CursorPesticide,
				CursorWater, CursorWeed, CursorOneClickHand,
				// #18 qui 收尾：qui 皮肤/窗件符号（ButtonDefaultSkin 等皮肤表
				// 静态引用 Table 类，符号本体仍零外部引用，锚进来；
				// TabBg/TabDefault/TabSelected/WindowBg/CloseButton/
				// DataLoading_mc 经 Utils.getClass / ResourceManager 反射构造）
				com.qzone.qui.skins.ButtonSkin, com.qzone.qui.skins.ButtonSelectedSkin,
				com.qzone.qui.skins.ToolTipSkin,
				com.qzone.qui.skins.TextInputSkin, com.qzone.qui.skins.TextInputFocusSkin,
				com.qzone.qui.skins.TabSkin, com.qzone.qui.skins.TabSelectedSkin,
				com.qzone.qui.skins.RadioButtonSkin, com.qzone.qui.skins.RadioButtonSelectedSkin,
				com.qzone.qui.skins.PanelSkin, com.qzone.qui.skins.PanelControlBarSkin, com.qzone.qui.skins.PanelCloseButton,
				// #86 牧场库底座：CheckBox 双态皮肤（CheckBoxDefaultSkin 皮肤表
				// 静态引用，符号本体零外部引用，锚进来）
				com.qzone.qui.skins.CheckBoxSkin, com.qzone.qui.skins.CheckBoxSelectedSkin,
				TabBg, TabDefault, TabSelected, WindowBg, CloseButton, DataLoading_mc,
				// #18 升级弹窗：Update.* 面板符号（LevelUpWindow/LandRender/
				// SeedItemRender 经 Utils.getMaterial 反射构造；landPanel/
				// nextLandPanel/landRender 部署包缺符号，空壳仍锚——
				// Type.resolveClass 可得）
				UpdateBigPanel, UpdateSeedsPanel, UpdateEmptyPanel, UpdateSeedsRender,
				UpdateLandPanel, UpdateNextLandPanel, UpdateLandRender,
				// #20 friends 片：好友列表面板/行、状态角标、微博开合皮肤、
				// 等级底图与黄钻徽标（getMaterial/getClass/getCachedBitmapData
				// 全反射构造，编译期零引用；Status_7 由精灵插件运行期供类，
				// 部署包无符号、无 shim——getClass null 即原版无插件行为）
				List_Item, List_UI,
				Status_1, Status_2, Status_3, Status_pre, Status_u, Status_z,
				List_Close_WB, List_Open_WB, Status_6,
				Sort0, Sort1, Sort2, Sort3, SortMe,
				VipL1, VipL2, VipL3, VipL4, VipL5, VipL6, VipL7,
				// #21 tasks 片：新手任务书页按钮与任务插图（task_v_2.swf；
				// WelcomeView/WelcomeTaskWindow 经 getMaterial 反射构造、
				// requestClass 类定义探测，编译期零引用，必须锚进来）
				TaskAwokeButton, TaskingButton,
				Task1, Task2, Task3, Task4, Task5, Task6, Task7, Task8, Task9, Task10, Task11,
				// #29 dog 片：狗粮盆双态图与道具边框（DogBowl/DogFoodWindow 经
				// getMaterial/getClass 反射构造，编译期零引用）
				DogFood, DogFoodNull, ItemBorder,
				// #35 shop 片：商店瓦片/买入窗素材符号（ItemBg 系底板、按钮
				// 皮肤、说明面板、种子类型按钮选中皮肤、鱼苗角标与解锁底板、
				// 页签角标——除 ShopFoodMarkIcon/RestaurantMarkIcon/
				// ShopSuperMarketIcon/ActivityMarkIcon/SteperSkin 五枚由
				// CropItem/BuyItemWindow 直接 new（编译期可达）外，其余全反射
				// 构造，零外部引用，必须锚进来）
				ItemBg, ItemBgRed, ItemBgBlack, VipSeedIcon, ShopNewMarkIcon,
				ButtonOrange, ButtonBlue, ShopSeedForm, ShopToolForm, ShopDiyForm,
				SeedTypeBtnSelectedSkin, SeedTypeVipBtnSelectedSkin,
				ShopFoodMarkIcon, RestaurantMarkIcon, ShopSuperMarketIcon, ActivityMarkIcon,
				SteperSkin, ShopTabNewIcon, FishUnlockBg, FishLocked, FishUnlock,
				// #35 shop 片控制器：ModuleShop.onModuleLoadSuccess 经 Utils.
				// getClass("module.shop.ShopController") 反射构造（编译期零引
				// 用）；锚住后 html5 的 ApplicationDomain.hasDefinition 即真，
				// 装配链走通。ShopView/ShopModel/widgets 经本类可达，不入表。
				// eval 无锚（本表 #if !eval）：单测以 getClass 恒 null 为前提
				// （ModuleShopTest:41），锚不能把这个前提翻掉。
				module.shop.ShopController,
				// #36 warehouse 片：仓库窗口表单板/卖出锁图标/绿色按钮皮肤/
				// 背包页签/背包关闭钮/鲜花卡片版式与列表条目两皮肤（全反射构
				// 造，零外部引用，必须锚进来）；PackClose 宿主是 farmui2_v_58。
				WarehouseForm, SellLockIcon, ButtonGreen, PackageTab, PackClose,
				FlowerCardUI,
				com.qzone.qui.skins.ListItemOverSkin, com.qzone.qui.skins.ListItemSelectedSkin,
				// #36 warehouse 片控制器：ModuleWarehouse.onModuleLoadSuccess
				// 经 Utils.getClass 反射构造（编译期零引用），锚住后装配链走通；
				// 视图/模型/部件经控制器可达，不入表。eval 无锚（本表
				// #if !eval）：单测以 getClass 恒 null 为前提。
				module.warehouse.bag.MyBagController, module.warehouse.house.WarehouseController,
				// #37 water 片符号：水池底图/石框（WaterPool.createPool 经
				// CommonData.applicationDomain.getDefinition 反射构造）、
				// 水池图 PoolMap、鱼详窗 MCFishTip、可捞旗 HarvestFishFlag、
				// 开池板 WaterOpenBoard、详情窗版面 PoolInfoContent、浪花
				// FishWave_0-3（showWaterFlower 反射构造）——零外部引用，
				// 必须锚进来。WaterLand3/StoneFrame1 宿主是 water_v_5。
				PoolMap, MCFishTip, HarvestFishFlag, WaterOpenBoard, PoolInfoContent,
				FishWave_0, FishWave_1, FishWave_2, FishWave_3, WaterLand3, StoneFrame1,
				// #37 water 片控制器：ModuleWater.onModuleLoadSuccess 经 Utils.
				// getClass("module.water.WaterController") 反射构造（编译期零
				// 引用），锚住后装配链走通；视图/模型/部件经控制器可达，不入
				// 表。eval 无锚（本表 #if !eval）：单测以 getClass 恒 null 为
				// 前提（ModuleWaterTest）。
				module.water.WaterController,
				// #38 decorate 片控制器：ModuleDecorate.onModuleLoadSuccess 经
				// Utils.getClass("module.decorate.DecorateController") 反射构造
				// （编译期零引用），锚住后装配链走通；视图/模型/部件经控制器可
				// 达，不入表。eval 无锚（本表 #if !eval）：单测以 getClass 恒
				// null 为前提（ModuleDecorateTest）。
				module.decorate.DecorateController,
				// #37 鱼动画符号族：17 个鱼动画库（fish_01..17，nc_data.php:7564
				// fish_info asset_id.m）导出的 FS_<型两位>_<档0-2>_<向0|2>（游动/
				// 待机，102 枚）与 FJ_<型>_<档>_<向>（跳跃：全型 _2_2，仅型 1/2/3
				// 另有 _2_0）。FishMover.checkResource/spawn 经
				// ApplicationDomain.hasDefinition/getDefinition（openfl 即
				// Type.resolveClass，只看编译期类表）查名——shim 不注册则鱼永
				// 不生成、捞/喂/偷 hitTest 全打不中；FishMCPoolObjectMgr 按
				// Class 键入池。attempt 1 review 驳回点即此链断裂。鱼型 10 的
				// fish_10.swf 把跳跃符号误导出为 FJ_01_2_2（与 fish_01 撞名，
				// dump_swf.php 可证），同名 shim 只能绑一库，按符号名归
				// fish_01（deviations 候选）。
				FS_01_2_0, FS_01_1_0, FS_01_0_0, FS_01_2_2, FS_01_1_2, FS_01_0_2, FJ_01_2_0, FJ_01_2_2,
				FS_02_2_0, FS_02_1_0, FS_02_0_0, FS_02_2_2, FS_02_1_2, FS_02_0_2, FJ_02_2_0, FJ_02_2_2,
				FS_03_2_0, FS_03_1_0, FS_03_0_0, FS_03_2_2, FS_03_1_2, FS_03_0_2, FJ_03_2_0, FJ_03_2_2,
				FS_04_2_0, FS_04_1_0, FS_04_0_0, FS_04_2_2, FS_04_1_2, FS_04_0_2, FJ_04_2_2,
				FS_05_2_0, FS_05_1_0, FS_05_0_0, FS_05_2_2, FS_05_1_2, FS_05_0_2, FJ_05_2_2,
				FS_06_2_0, FS_06_1_0, FS_06_0_0, FS_06_2_2, FS_06_1_2, FS_06_0_2, FJ_06_2_2,
				FS_07_2_0, FS_07_1_0, FS_07_0_0, FS_07_2_2, FS_07_1_2, FS_07_0_2, FJ_07_2_2,
				FS_08_2_0, FS_08_1_0, FS_08_0_0, FS_08_2_2, FS_08_1_2, FS_08_0_2, FJ_08_2_2,
				FS_09_2_0, FS_09_1_0, FS_09_0_0, FS_09_2_2, FS_09_1_2, FS_09_0_2, FJ_09_2_2,
				FS_10_2_0, FS_10_1_0, FS_10_0_0, FS_10_2_2, FS_10_1_2, FS_10_0_2,
				FS_11_2_0, FS_11_1_0, FS_11_0_0, FS_11_2_2, FS_11_1_2, FS_11_0_2, FJ_11_2_2,
				FS_12_2_0, FS_12_1_0, FS_12_0_0, FS_12_2_2, FS_12_1_2, FS_12_0_2, FJ_12_2_2,
				FS_13_2_0, FS_13_1_0, FS_13_0_0, FS_13_2_2, FS_13_1_2, FS_13_0_2, FJ_13_2_2,
				FS_14_2_0, FS_14_1_0, FS_14_0_0, FS_14_2_2, FS_14_1_2, FS_14_0_2, FJ_14_2_2,
				FS_15_2_0, FS_15_1_0, FS_15_0_0, FS_15_2_2, FS_15_1_2, FS_15_0_2, FJ_15_2_2,
				FS_16_2_0, FS_16_1_0, FS_16_0_0, FS_16_2_2, FS_16_1_2, FS_16_0_2, FJ_16_2_2,
				FS_17_2_0, FS_17_1_0, FS_17_0_0, FS_17_2_2, FS_17_1_2, FS_17_0_2, FJ_17_2_2,
				// #37 鱼苗图标：fish_seed_01..17（fish_info asset_id.s）各导出
				// 单符号 Fish_<型>。PoolInfoWindow.onLoaded 经 Utils.getMaterial、
				// MaterialProxy ITEM_TYPE_FISH 经 requestClass（getFishName）
				// 反射构造。
				Fish_1, Fish_2, Fish_3, Fish_4, Fish_5, Fish_6, Fish_7, Fish_8, Fish_9,
				Fish_10, Fish_11, Fish_12, Fish_13, Fish_14, Fish_15, Fish_16, Fish_17,
				// #37 喂鱼食族（宿主 Fertilizer_v_7，secondList id="Fertilizer"）：
				// FishFoodEffect 喂食特效（FishMover.playFeedEffect 的
				// Utils.getMaterial）、FishFood_1-4 鱼食道具图（MaterialProxy
				// requestClass——shim 缺席时 requestClass 的 COMPLETE 重试会
				// 打转，见 RSLManager.requestClass）、Cursor_FishFood_1-4 光标
				// （CursorTool）。库内其余符号属 tools/dogs 模块，后续 issue。
				FishFoodEffect, FishFood_1, FishFood_2, FishFood_3, FishFood_4,
				Cursor_FishFood_1, Cursor_FishFood_2, Cursor_FishFood_3, Cursor_FishFood_4,
				// #41 窗口框架片符号：确认窗图标（ConfirmWindow.customizeIcon
				// getMaterial）、验证码窗体版面（ValidateCodeWindow.init
				// getMaterial）、黑土升级分享板（UpgradeBlackWindow 构造器
				// getMaterial）——宿主 farmui 系、全反射构造，零外部引用；
				// redUpBanner（@:native 小写原名）宿主 redUpBanner_v_2、
				// RequestError 四图（BitmapData 路径）宿主 RequestError_2，
				// 均经 requestClass/getMaterial 反射构造。两库非预载，
				// bind/bindBitmap 按需拉起（见 ensureLibraryLoaded）
				ConfirmIcon, ValidateCodeContent, BlackUpgradeShare, RedUpBanner,
				RequestErrorBG, RequestErrorZZ, RequestErrorHP, RequestErrorFZ,
				// #42 提示片：TipBg 提示底板（MouseTip/CropInfoTip/DiyMouseTip/
				// HistoryItemTip 经 Utils.getMaterial 反射构造）与 FarmInfoPlus
				// 地块信息提示版面（LandInfoTip 同款；原版类体长在该 swf 的
				// DoABC2，方法按 ABC 字节码复原，见类头）——宿主都是
				// farmui_full_v_40，零外部引用，必须锚进来。
				TipBg, FarmInfoPlus,
				// #43 引导片：GameGuide ctor 经 Utils.getMaterial("Arrow") 反射
				// 构造的引导箭头（farmui2_v_58，零外部引用）
				Arrow
			];
		}
#end
#if eval
		// eval 单测（test.hxml 无 -lib swf）：无库可查，保持空剪辑并留痕，
		// 不抛——原版纯符号构造也不抛
		trace("SymbolClass: eval 目标无库 " + libraryId + ":" + symbolName);
#else
		if (Std.isOfType(target, MovieClip)) {
			// 时间轴已挂上（同库第二只起）跳过；SimpleButton 无 __timeline，
			// 恒走绑定（构造器每实例一次，不存在二次绑定）
			var mc:MovieClip = cast target;
			if (@:privateAccess mc.__timeline != null) {
				return;
			}
		}
		// Assets.getLibrary 静态类型是 lime 的 AssetLibrary（无 bind）；
		// 本流水线的库实例都是 openfl 侧库（AnimateLibrary），收窄后走
		// openfl AssetLibrary.bind（AnimateLibrary 覆写）
		var library:AssetLibrary = cast Assets.getLibrary(libraryId);
		if (library != null) {
			attach(library, libraryId, symbolName, target);
			return;
		}
		pending.push({libraryId: libraryId, symbolName: symbolName, target: target, after: []});
		ensureLibraryLoaded(libraryId);
#end
	}

	// 按需拉起（bind/bindBitmap 共用）：完成回调里按注册名重取库实例、
	// 冲刷两队列——剪辑队列 attach + after 重放，位图队列拷像素；失败按
	// 原版「类不存在」处理留痕丢弃。onComplete 后该库已在 Assets 里，迟来
	// 的 bind 走同步路径
	private static function ensureLibraryLoaded(libraryId:String):Void {
		for (id in loadingLibraries) {
			if (id == libraryId) {
				return;
			}
		}
		loadingLibraries.push(libraryId);
		Assets.loadLibrary(libraryId).onComplete(function(lib:AssetLibrary):Void {
			loadingLibraries = [for (id in loadingLibraries) if (id != libraryId) id];
			// 该库这一批等绑的目标全部挂上；再进来的 bind 走上面的同步路径
			var stillQueued:Array<{libraryId:String, symbolName:String, target:DisplayObject, after:Array<MovieClip->Void>}> = [];
			for (entry in pending) {
				if (entry.libraryId == libraryId) {
					attach(lib, entry.libraryId, entry.symbolName, entry.target);
					// 待绑窗口里登记的写按登记序重放一次（见 afterAttach）；
					// after 只会是 MovieClip 路径登记的（SimpleButton 目标恒空）
					for (fn in entry.after) {
						fn(cast entry.target);
					}
				} else {
					stillQueued.push(entry);
				}
			}
			pending = stillQueued;
			var stillBitmaps:Array<{libraryId:String, symbolName:String, target:BitmapData}> = [];
			for (entry in pendingBitmaps) {
				if (entry.libraryId == libraryId) {
					copyBitmapSymbol(libraryId, entry.symbolName, entry.target);
				} else {
					stillBitmaps.push(entry);
				}
			}
			pendingBitmaps = stillBitmaps;
		}).onError(function(err:Dynamic):Void {
			// 库拉不起来（未声明/文件缺失）：按原版「类不存在」处理，留痕不抛；
			// 空剪辑上登记的写无对象可作用，随条目一并丢弃
			trace("SymbolClass: 库加载失败 " + libraryId + " (" + Std.string(err) + ")");
			loadingLibraries = [for (id in loadingLibraries) if (id != libraryId) id];
			pending = [for (entry in pending) if (entry.libraryId != libraryId) entry];
			pendingBitmaps = [for (entry in pendingBitmaps) if (entry.libraryId != libraryId) entry];
		});
	}

	private static function attach(library:AssetLibrary, libraryId:String, symbolName:String, target:DisplayObject):Void {
#if !eval
		if (Std.isOfType(target, MovieClip)) {
			var mc:MovieClip = cast target;
			if (@:privateAccess mc.__timeline != null) {
				// 已挂时间轴（库实例化进来 / 同库第二只起）：帧脚本补偿仍要
				// 登记——Timeline.__addFrameScript 同帧是 set，重复登记幂等；
				// 首见即挂上，不依赖首次路径
				FrameScriptCompensation.attach(mc, libraryId, symbolName);
				return;
			}
		}
		if (!library.bind(symbolName, target)) {
			trace("SymbolClass: 符号不存在 " + libraryId + ":" + symbolName);
		}
		// #58 帧脚本补偿：bind 成功即时间轴已挂（MovieClip 路径），按登记表
		// 回挂 openfl 侧帧脚本（本地化管线把 scriptSource 丢了/跑不动，见
		// shim/FrameScriptCompensation 头注）；SimpleButton 目标无时间轴，
		// addFrameScript 本就是无操作，恒可安全调用
		if (Std.isOfType(target, MovieClip)) {
			FrameScriptCompensation.attach(cast target, libraryId, symbolName);
		}
#end
	}

	/**
	 * 「构造器返回后、符号时间轴挂上前」对实例子件的写经这里登记：
	 * 目标在待绑队列里（库首次拉起的异步窗口）→ fn 进队列，attach 后按
	 * 登记序重放；时间轴已挂上（库已在 Assets、同库第二只起）→ 立即执行
	 * （等价原版同步绑定的时序）。fn 捕获的值在登记时定型（原版是同步
	 * 求值，重放不读晚些时候可能变化的现场）。
	 */
	public static function afterAttach(target:MovieClip, fn:MovieClip->Void):Void {
#if eval
		// eval 无库：时间轴永不挂上（bind 的 eval 分支同款留痕语义），空剪辑
		// 上 fn 是无操作，立即执行保持修复前行为
		fn(target);
#else
		if (@:privateAccess target.__timeline != null) {
			fn(target);
			return;
		}
		for (entry in pending) {
			if (entry.target == target) {
				entry.after.push(fn);
				return;
			}
		}
		// 不在待绑队列也没挂上时间轴（库加载失败/符号不存在的已留痕路径）：
		// 立即执行，保持空剪辑上的无操作行为
		fn(target);
#end
	}

	/**
	 * SymbolClass 把类名绑到**位图**（DefineBits/JPEG/Lossless，flash.display.
	 * BitmapData 子类）时的对应绑定：Animate 导出器把这类符号记成
	 * AnimateBitmapSymbol（data2.className = 符号名，AnimateLibraryExporter
	 * processSymbol；AnimateLibrary 装载时 bitmapClassNames[className]=path），
	 * `Assets.getBitmapData("<库>:<名>")` 即可取到图像。同款直 new 语义的
	 * BitmapData shim 构造器里调这里，把图像像素拷到实例上。
	 *
	 * Flash 对链接位图的 new 无视传入宽高、以图像天然像素为准（0,0 惯用法）；
	 * copyPixels 直拷含 alpha 通道，构造时底也不落 AS3 BitmapData 默认的
	 * 0xFFFFFFFF 白（shim 侧 super 传 0 全透明）。本仓库调用点 (16,13)/(24,24)/
	 * (270,125) 恰为（或不小于）天然尺寸，直拷即逐像素一致；RequestErrorBG
	 * 天然 270×124，末行保持构造底透明，与原版按天然尺寸显示等价。库不在
	 * 时走 pendingBitmaps 按需拉起（ensureLibraryLoaded），完成后原实例补像素。
	 */
	public static function bindBitmap(target:BitmapData, libraryId:String, symbolName:String):Void {
#if eval
		// eval 单测（bind 同款留痕）：无库可查，保持全透明空位图，不抛
		trace("SymbolClass: eval 目标无库 " + libraryId + ":" + symbolName);
#else
		if (Assets.getLibrary(libraryId) != null) {
			copyBitmapSymbol(libraryId, symbolName, target);
			return;
		}
		// 库不在（首见位图符号，如 RequestError_2）：入位图待拷队列按需拉起
		//（bind 同款时序），完成后原实例上补像素——Bitmap 已上树的场景图
		// 内容就位，与原版「远程加载后 new」等价
		pendingBitmaps.push({libraryId: libraryId, symbolName: symbolName, target: target});
		ensureLibraryLoaded(libraryId);
#end
	}

	private static function copyBitmapSymbol(libraryId:String, symbolName:String, target:BitmapData):Void {
		var src:BitmapData = Assets.getBitmapData(libraryId + ":" + symbolName);
		if (src == null) {
			trace("SymbolClass: 位图符号不存在 " + libraryId + ":" + symbolName);
			return;
		}
		target.copyPixels(src, src.rect, new Point(0, 0));
	}

	/**
	 * SymbolClass 把类名绑到**根时间轴**（tag id 0，即文档类）时的对应绑定：
	 * Animate 导出器不给根符号记 className（AnimateLibraryExporter 只处理有
	 * character 的符号，id 0 不是 character），`bind(类名, …)` 查不到。按
	 * Assets.getMovieClip("<库>:") 同款做法（root.__createObject 的内部路径）
	 * 把根符号时间轴挂到实例上——实例本身就是根时间轴，不加包装层。
	 */
	public static function bindRoot(target:MovieClip, libraryId:String):Void {
#if eval
		trace("SymbolClass: eval 目标无库 " + libraryId + ":(root)");
#else
		if (@:privateAccess target.__timeline != null) {
			// 同款幂等登记（见 attach 的早退分支）
			FrameScriptCompensation.attach(target, libraryId, "");
			return;
		}
		var library:AssetLibrary = cast Assets.getLibrary(libraryId);
		if (library == null) {
			trace("SymbolClass: 库未加载 " + libraryId);
			return;
		}
		if (Std.isOfType(library, AnimateLibrary)) {
			var animate:AnimateLibrary = cast library;
			@:privateAccess animate.root.__initObject(animate, target);
			// 根符号无 SymbolClass 名，导出器不给 scriptSource——帧脚本补偿
			// 查表登记（#58，symbolKey 空串 = 根时间轴）
			FrameScriptCompensation.attach(target, libraryId, "");
		} else {
			trace("SymbolClass: 非 AnimateLibrary，无法绑根 " + libraryId);
		}
#end
	}
}
