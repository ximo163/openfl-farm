package module.uitools;

import com.qzone.allianceActivity.AllianceActivityManager;
import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
import com.qzone.utils.DisplayUtil;
import common.CommonData;
import common.Consts;
import common.Session;
import common.Settings;
import common.misc.Cookies;
import common.misc.Utils;
import entities.Item;
import entities.Player;
import entities.StartupData;
import events.CommonEvent;
import events.ViewEvent;
import framework.api.beast.BeastAPI;
import framework.base.Controller;
import interfaces.IModule;
import interfaces.IMsgCenter;
import module.uitools.widgets.LeftSideToolBar;
import module.uitools.widgets.NavigationBar;
import module.uitools.widgets.PersonInfo;
import module.uitools.widgets.ShortcutBar;
import module.uitools.widgets.ToolBar;
import module.uitools.widgets.ToolBoxBar;
import openfl.filters.BitmapFilter;
import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.GlowFilter;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFormat;
import report.ClickReportManager;
import report.UserActionRecorder;
import shim.As3;
import EvtAPI;

/**
 * module.uitools.UIController —— UIController.as 逐句对应（issue #9 整类翻译）。
 * 工具区装配器：把工具条/导航条/个人信息条/快捷条/左侧工具条挂到模块容器，
 * 经 IMsgCenter 监听启动链与用户切换消息，导航条点击分发仓库/商店/装饰/
 * 收集活动。`as X` 一律用 Haxe 安全 cast（cast(expr, T)，类型不符得 null，
 * 与 AS3 `as` 同语义）；`as Boolean` 落 Bool 变量按 As3.truthy（见
 * onHealthModeOpenClose 注）。
 */
class UIController extends Controller {
	// UIController.as:37
	private var m_toolBoxBar:ToolBoxBar;

	// UIController.as:39
	private var m_shortcuts:ShortcutBar;

	// UIController.as:41
	private var m_navbar:NavigationBar;

	// UIController.as:43
	private var m_toolbar:ToolBar;

	// UIController.as:45
	private var m_headerBG:Sprite;

	// UIController.as:47
	private var healthFirst:Bool = true;

	// UIController.as:49
	private var _planeBtn:MovieClip;

	// UIController.as:51
	private var m_playerbar:PersonInfo;

	// UIController.as:53
	private var _api:BeastAPI = BeastAPI.getInstance();

	// UIController.as:55
	private var m_friendbar:PersonInfo;

	// UIController.as:57
	private var _leftSideBar:LeftSideToolBar;

	// UIController.as:59
	private var m_poolInfo:SimpleButton;

	// UIController.as:61-64
	public function new(param1:IModule) {
		super(param1);
	}

	// UIController.as:66-69
	private function onHostDataChanged(param1:Event):Void {
		this.model.updateHostInfo();
	}

	// UIController.as:71-120（水池容量角标：PoolInfoBtn 素材上挂动态属性
	// tfSize 的文本；size<0 时整套移除。素材类是 swf 动态类，AS3 里
	// m_poolInfo["tfSize"] 是动态属性读写 → Reflect）
	private function onRefreshPoolInfo(param1:CommonEvent):Void {
		var tfSize:TextField = null;
		var e:CommonEvent = param1;
		var data:Dynamic = e.data;
		if (As3.floatOf(Reflect.field(data, "size")) >= 0) {
			if (this.m_poolInfo == null) {
				this.m_poolInfo = cast(Utils.getMaterial("PoolInfoBtn"), SimpleButton);
				if (this.m_poolInfo != null) {
					this.m_poolInfo.x = this.m_module.container.stage.stageWidth - 64;
					this.m_poolInfo.y = this.m_module.container.stage.stageHeight - 40;
					this.m_module.container.addChild(this.m_poolInfo);
					this.m_poolInfo.addEventListener(MouseEvent.CLICK, function(param1:MouseEvent):Void {
						this.m_module.app.dispatchEvent(new Event(Consts.MSG_SHOW_POOLINFO));
					});
				}
				if (this.m_poolInfo != null && Reflect.field(this.m_poolInfo, "tfSize") == null) {
					tfSize = new TextField();
					tfSize.defaultTextFormat = new TextFormat("Arial", 12, 16120557);
					// 原版 `tfSize.filters = [new GlowFilter(...)]`：GlowFilter[]
					// 对 filters 的 BitmapFilter[] 赋值用元素 cast 保数组合变
					tfSize.filters = [(new GlowFilter(3342336, 1, 2, 2, 10, 1) : BitmapFilter)];
					tfSize.selectable = false;
					tfSize.multiline = false;
					tfSize.mouseEnabled = false;
					Reflect.setField(this.m_poolInfo, "tfSize", tfSize);
					tfSize.x = this.m_poolInfo.x;
					tfSize.y = this.m_poolInfo.y;
					this.m_module.container.addChild(tfSize);
				}
			}
			if (this.m_poolInfo != null && Reflect.field(this.m_poolInfo, "tfSize") != null) {
				cast(Reflect.field(this.m_poolInfo, "tfSize"), TextField).text = Std.string(Reflect.field(data, "size"))
					+ "/" + Std.string(Consts.FISH_MAX_SIZE);
			}
		} else if (this.m_poolInfo != null) {
			if (Reflect.field(this.m_poolInfo, "tfSize") != null) {
				DisplayUtil.removeChild(this.m_module.container, cast(Reflect.field(this.m_poolInfo, "tfSize"), TextField));
				Reflect.setField(this.m_poolInfo, "tfSize", null);
			}
			DisplayUtil.removeChild(this.m_module.container, this.m_poolInfo);
			this.m_poolInfo = null;
		}
	}

	// UIController.as:122-178
	override public function initialze():Void {
		super.initialze();
		if (this.m_module.container == null) {
			return;
		}
		if (this.m_model == null) {
			this.m_model = new UIToolsModel(this);
		}
		this.registerListeners();
		if (this.m_toolbar == null) {
			this.m_toolbar = new ToolBar(this);
			this.m_module.container.addChild(this.m_toolbar);
			this.m_toolbar.addEventListener(ToolBar.MODULE_EVENT_CLICK_PACK, this.onPackClicked);
			this.m_toolbar.addEventListener(ToolBar.MODULE_EVENT_CLICK_TOOLBOX, this.onToolBoxClicked);
			this.m_toolbar.addEventListener("hidebeast", this.onHidebeast);
		}
		if (this.m_headerBG == null) {
			this.m_headerBG = cast(Utils.getMaterial("HeadBg"), Sprite);
			this.m_headerBG.width = this.m_module.app.farmView.stage.stageWidth;
			this.m_module.container.addChild(this.m_headerBG);
		}
		if (this.m_navbar == null) {
			this.m_navbar = new NavigationBar(this);
			this.m_navbar.addEventListener(ViewEvent.CHILD_CLICK, this.onNavigateBarClicked, false, 0, true);
			this.m_module.container.addChild(this.m_navbar);
		}
		// 原版 :154-156 空分支（飞机按钮创建已被原版摘除，反编译产物照抄）
		if (this._planeBtn == null) {}
		if (this.m_playerbar == null) {
			this.m_playerbar = new PersonInfo(this, true);
			this.m_playerbar.x = 15;
			this.m_playerbar.name = "__playerbar__";
			this.m_module.container.addChild(this.m_playerbar);
		}
		if (this.m_shortcuts == null) {
			this.m_shortcuts = new ShortcutBar(this);
			this.m_shortcuts.name = "__shortcuts__";
			this.m_module.container.addChild(this.m_shortcuts);
			this.m_shortcuts.x = 45;
		}
		this.creatLeftSideBar();
		this.m_poolInfo = null;
		this.m_friendbar = null;
		this.m_toolBoxBar = null;
		this._api.beastPackContainer = this.m_toolbar;
		this._api.addEventListener(EvtAPI.SHOW_BEAST_PACK, this.hideOtherBar);
		this.m_module.app.addEventListener(Consts.GOLD_LAND_UPDATE_TIME_CHANGE, this.onGoldLandTimeChange, false, 0, true);
	}

	// UIController.as:180-191
	// PORT-NOTE: 原版 `param1.data["open"] as Boolean` 落 Boolean 变量；
	// 字段缺位时 AS3 得 null 再隐式转 false。安全 cast 到 Bool 在静态目标
	// 上会得 null-Bool（编译红），按 As3.truthy：真 Boolean 派发（唯一实际
	// 形态）语义一致，缺位同转 false。
	private function onHealthModeOpenClose(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Bool = As3.truthy(Reflect.field(param1.data, "open"));
		if (this.m_toolBoxBar != null) {
			this.m_toolBoxBar.toggleHealthMode(_loc2_);
		}
	}

	// UIController.as:193-232（自己/好友农场切换：自己的快捷条 vs 好友信息条）
	private function onCurrentUserChanged(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Player = cast(param1.data, Player);
		if (_loc2_ == null) {
			return;
		}
		if (this.m_navbar != null) {
			this.m_navbar.currentUserChanged();
		}
		if (_loc2_.me == true) {
			if (this.m_friendbar != null && this.m_friendbar.parent != null) {
				this.m_friendbar.parent.removeChild(this.m_friendbar);
			}
			this.m_module.container.addChild(this.m_shortcuts);
		} else {
			if (this.m_shortcuts.parent != null) {
				this.m_shortcuts.parent.removeChild(this.m_shortcuts);
			}
			if (this.m_friendbar == null) {
				this.m_friendbar = new PersonInfo(this, false);
				this.m_friendbar.x = 15;
				this.m_friendbar.y = 80;
				this.m_friendbar.name = "__friendbar__";
			}
			this.m_module.container.addChild(this.m_friendbar);
			this.m_friendbar.setFriendInfo(_loc2_);
		}
	}

	// UIController.as:234-237
	// PORT-NOTE: 原版 `param1.data as int`——实际派发都是整型等级值，按
	// As3.intOf 取值；非整型入参的 null 归 0 与原版隐式转换同为 0 起算。
	private function onCheckLevelUp(param1:CommonEvent):Void {
		this.model.checkLevelup(As3.intOf(param1.data));
	}

	// UIController.as:239-242
	override public function finalize():Void {
		super.finalize();
	}

	// UIController.as:244-294（导航条点击分发：仓库/商店/回农场/装饰/收集活动）
	private function onNavigateBarClicked(param1:ViewEvent):Void {
		var _loc3_:IAllianceActivityContext = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:String = Reflect.field(param1.data, "name");
		if (_loc2_ == "warehouse") {
			this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_WAREHOUSE, null));
			UserActionRecorder.recordAction(UserActionRecorder.HF_WAREHOUSE_CLICKED);
			ClickReportManager.reportClick("up.banner.icon_warehouse.click");
		} else if (_loc2_ == "shop") {
			this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_SHOP, null));
			UserActionRecorder.recordAction(UserActionRecorder.HF_SHOP_CLICKED);
			ClickReportManager.reportClick("up.banner.icon_shop.click");
		} else if (_loc2_ == "farm") {
			BeastAPI.getInstance().showFarmStage();
			this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER, null));
			UserActionRecorder.recordAction(UserActionRecorder.HF_MYFARM_CLICKED);
			ClickReportManager.reportClick("up.banner.icon_farm.click");
		} else if (_loc2_ == "decorate") {
			if (Session.getInstance().me == false) {
				this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER, null));
				this.m_module.app.dispatchEvent(new Event(Consts.MSG_OPEN_WAREHOUSE_AFTER_BACK));
			} else {
				this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_DIY, null));
			}
			UserActionRecorder.recordAction(UserActionRecorder.HF_DECORATE_CLICKED);
			ClickReportManager.reportClick("up.banner.icon_decoration.click");
		} else if (_loc2_ == "collecting") {
			_loc3_ = AllianceActivityManager.getInstance().getActivityContext("collecting");
			if (_loc3_ != null) {
				_loc3_.execute("openActivityWin");
				ClickReportManager.reportClick("up.banner.icon_collecting.click");
			}
		}
	}

	// UIController.as:296-308（卡牌活动窗口期判定）
	// PORT-NOTE: 原版 `new Date(串).time`；配置实值是美式串（nc_addon.php:75
	// `3/13/2012 00:00:00`），走 As3.dateOf（Haxe Date 无字符串构造）。解析
	// 失败原版得 NaN → 比较恒 false，这里 null 判掉同 false。
	public function isCardGameActivity():Bool {
		var _loc1_:String = Settings.getInstance().getStringAttribute("cardActivityStart");
		var _loc2_:String = Settings.getInstance().getStringAttribute("cardActivityEnd");
		var start:Date = As3.dateOf(_loc1_);
		var end:Date = As3.dateOf(_loc2_);
		var _loc3_:Float = start == null ? Math.NaN : start.getTime();
		var _loc4_:Float = end == null ? Math.NaN : end.getTime();
		var _loc5_:Float = CommonData.serverTime * 1000;
		if (_loc3_ < _loc5_ && _loc5_ < _loc4_) {
			return true;
		}
		return false;
	}

	// UIController.as:310-341（藏獒到期天数提示：首次见该天数才弹，cookie 记忆）
	private function onGetDogValidTime(param1:Int):Void {
		var _loc3_:Item = null;
		if (param1 != 7 && param1 != 3 && param1 != 1) {
			return;
		}
		var _loc2_:Int = As3.intOf(Cookies.getObject("dogValidTipsDaysShow" + Session.getInstance().hostId));
		if (_loc2_ == param1) {
			return;
		}
		Cookies.setObject("dogValidTipsDaysShow" + Session.getInstance().hostId, param1);
		_loc3_ = new Item(null);
		_loc3_._id = 10;
		_loc3_._type = 4;
		_loc3_._name = "藏獒";
		_loc3_._buy_1 = 100;
		_loc3_._buy_6 = 550;
		_loc3_._buy_12 = 1000;
		_loc3_._Ybuy_1 = 80;
		_loc3_._Ybuy_6 = 440;
		_loc3_._Ybuy_12 = 800;
		_loc3_._fb = 100;
		_loc3_._yfb = 80;
		_loc3_._price = 0;
		_loc3_._desc = "";
		_loc3_._isQDDog = true;
		_loc3_._renew = true;
		_loc3_._timeLimit = param1;
		this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_BUY_DOG_FOOD, _loc3_));
	}

	// UIController.as:343-346
	private function onAcceptNewGift(param1:Event):Void {
		this.model.loadEveryDayGift();
	}

	// UIController.as:348-356
	private function onPlaneClicked(param1:MouseEvent):Void {
		this.m_module.app.dispatchEvent(new Event(Consts.MSG_CALL_PLANE));
		if (this._planeBtn != null) {
			this._planeBtn.gotoAndStop(41);
		}
		this.hideTip();
	}

	// UIController.as:358-361
	private function onPlaneOver(param1:MouseEvent):Void {
		this.showTip(Consts.TIP_NAME_MOUSE, "飞机施肥，一键全熟");
	}

	// UIController.as:363-366
	private function onWaterPoolOpened(param1:CommonEvent):Void {
		this.m_toolbar.refresh();
	}

	// UIController.as:368-374（原版 `if(this._api)` 对象真值 → 非空判定）
	private function onHidebeast(param1:Event):Void {
		if (this._api != null) {
			this._api.hideBeastPack();
		}
	}

	// UIController.as:376-379
	public var model(get, never):UIToolsModel;

	private function get_model():UIToolsModel {
		return cast(this.m_model, UIToolsModel);
	}

	// UIController.as:381-387
	private function hideOtherBar(param1:EvtAPI):Void {
		if (this.m_toolBoxBar != null) {
			this.m_toolBoxBar.close();
		}
	}

	// UIController.as:389-398
	private function removeNewIconTip(param1:CommonEvent):Void {
		var _loc2_:MovieClip = cast(this.m_module.container.getChildByName("__newicontip__"), MovieClip);
		if (_loc2_ != null) {
			this.m_module.container.removeChild(_loc2_);
			_loc2_ = null;
		}
		this.m_toolbar.removeWildText();
	}

	// UIController.as:400-403
	private function onPlaneOut(param1:MouseEvent):Void {
		this.hideTip();
	}

	// UIController.as:405-425
	private function onGameDataReloaded(param1:CommonEvent):Void {
		if (Session.getInstance().me == true) {
			this.onStartupData(param1);
		}
		var _loc2_:Player = Session.getInstance().currentUser;
		if (this.m_toolbar != null) {
			this.m_toolbar.myHome = _loc2_.me == true ? true : false;
		}
		this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PACK, {"close": true}));
		if (this.m_toolBoxBar != null) {
			this.m_toolBoxBar.close();
		}
		if (this._planeBtn != null) {
			this._planeBtn.visible = _loc2_.me == true ? true : false;
		}
	}

	// UIController.as:427-449
	private function onToolBoxClicked(param1:Event):Void {
		var _loc2_:Player = null;
		if (this.m_toolBoxBar == null) {
			this.m_toolBoxBar = new ToolBoxBar(this);
			this.m_module.container.addChild(this.m_toolBoxBar);
		} else {
			this.m_toolBoxBar.toggleVisible();
		}
		if (this.m_toolBoxBar.visible == true) {
			this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PACK, {"close": true}));
		}
		if (this.healthFirst) {
			_loc2_ = Session.getInstance().host;
			this.m_toolBoxBar.toggleHealthMode(_loc2_._healthMode._set == 1 || _loc2_._healthMode._valid == 1);
			this.healthFirst = false;
		}
	}

	// UIController.as:451-476
	private function registerListeners():Void {
		if (this.m_module == null || this.m_module.app == null) {
			return;
		}
		var _loc1_:IMsgCenter = cast(this.m_module.app, IMsgCenter);
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_STARTUP_DATA, this.onStartupData, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_RELOAD_GAME_RESULT, this.onGameDataReloaded, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_HOST_CHANGED, this.onHostDataChanged, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_CURRENT_USER_CHANGED, this.onCurrentUserChanged, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_HEALTH_MODE_OPEN_CHANGED, this.onHealthModeOpenClose, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_ACCEPT_NEW_GIFT, this.onAcceptNewGift, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_TRUNK_SYSTEM_TOOLBAR, this.onChangeToolBar, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_CHECK_LEVELUP, this.onCheckLevelUp, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_LEVELUP, this.onLevelUp, false, 0, true);
			_loc1_.addEventListener(Consts.DELEVE_NEW_ICON, this.removeNewIconTip, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_POOL_OPEN, this.onWaterPoolOpened, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_REFRESH_POOLINFO, this.onRefreshPoolInfo, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_ADD_COLLECTING_ICON, this.onAddCollectingIcon, false, 0, true);
		}
		this.model.addEventListener(UIToolsModel.EVENT_EVERYDAY_GIFT_ACCEPTED, this.onDayGiftAcceptedByServer, false, 0, true);
		this.model.addEventListener(UIToolsModel.EVENT_LEVELUP_GIFTS, this.onLevelUpGiftAccepted, false, 0, true);
	}

	// UIController.as:478-481
	private function onLevelUp(param1:CommonEvent):Void {
		this.model.addLevelUp(param1.data);
	}

	// UIController.as:483-490
	public function openCameraShootWindow():Void {
		var _loc1_:IMsgCenter = cast(this.m_module.app, IMsgCenter);
		if (_loc1_ != null) {
			_loc1_.dispatchEvent(new CommonEvent(Consts.MSG_CAMERA, true));
		}
	}

	// UIController.as:492-519（启动数据落地：资料初始化、离线态、升级礼包、藏獒提示）
	private function onStartupData(param1:CommonEvent):Void {
		var _loc5_:Int = 0;
		var _loc2_:StartupData = cast(param1.data, StartupData);
		if (_loc2_ != null) {
			this.model.initializeMyProfile();
			this.model.updateOfflineStatus(_loc2_._unread);
		}
		var _loc3_:Player = Session.getInstance().host;
		if (_loc3_ != null && _loc3_._healthMode != null) {
			if (this.m_toolBoxBar != null) {
				this.m_toolBoxBar.toggleHealthMode(_loc3_._healthMode._set == 1 || _loc3_._healthMode._valid == 1);
			}
		}
		var _loc4_:Array<Dynamic> = _loc2_._user._levelup;
		if (_loc4_ != null && _loc4_.length > 0) {
			this.model.addLevelUp(_loc4_);
		}
		if (_loc2_._dog._dogId == Consts.DOG_TIBETAN_MASTIFF_ID && _loc2_._dog._validTime >= 0) {
			// 原版 int 局部变量承载 Number 除法 → 隐式截断，As3.intOf 对齐
			_loc5_ = As3.intOf((_loc2_._dog._validTime - CommonData.serverTime) / 86400);
			this.onGetDogValidTime(_loc5_);
		}
	}

	// UIController.as:521-552（收编工具条模式：隐藏/恢复工具条与角标）
	private function onChangeToolBar(param1:CommonEvent):Void {
		// PORT-NOTE: 同 onHealthModeOpenClose——`param1.data as Boolean` 按 truthy
		var _loc2_:Bool = As3.truthy(param1.data);
		if (_loc2_) {
			this.m_toolbar.visible = false;
			if (this.m_poolInfo != null) {
				this.m_poolInfo.visible = false;
				if (Reflect.field(this.m_poolInfo, "tfSize") != null) {
					Reflect.setField(Reflect.field(this.m_poolInfo, "tfSize"), "visible", false);
				}
			}
			if (this._planeBtn != null) {
				this._planeBtn.visible = false;
			}
		} else {
			this.m_toolbar.visible = true;
			if (this.m_poolInfo != null) {
				this.m_poolInfo.visible = true;
				if (Reflect.field(this.m_poolInfo, "tfSize") != null) {
					Reflect.setField(Reflect.field(this.m_poolInfo, "tfSize"), "visible", true);
				}
			}
		}
	}

	// UIController.as:554-557
	private function onGoldLandTimeChange(param1:CommonEvent):Void {
		this.m_toolbar.updateGoldLandTime(param1.data);
	}

	// UIController.as:559-567
	public function switchBigMode(param1:Bool):Void {
		Cookies.Set("bigmode", param1 ? "1" : "0");
		var _loc2_:IMsgCenter = cast(this.m_module.app, IMsgCenter);
		if (_loc2_ != null) {
			_loc2_.dispatchEvent(new CommonEvent(Consts.MSG_ZOOM, param1));
		}
	}

	// UIController.as:569-590
	private function onDayGiftAcceptedByServer(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		var _loc3_:Array<Dynamic> = [];
		// 原版 `!= undefined && != null` 两判在 Haxe 里同为 != null（缺位即 null）
		var item:Dynamic = Reflect.field(_loc2_, "item");
		if (item != null && Std.isOfType(item, Array)) {
			_loc3_ = _loc3_.concat(cast(item, Array<Dynamic>));
		}
		if (Reflect.hasField(_loc2_, "vipItem") == true && Reflect.field(_loc2_, "vipItem") != null
			&& Std.isOfType(Reflect.field(_loc2_, "vipItem"), Array)) {
			_loc3_ = _loc3_.concat(cast(Reflect.field(_loc2_, "vipItem"), Array<Dynamic>));
		}
		if (Reflect.hasField(_loc2_, "packagetime")) {
			Cookies.setObject("new_user_" + Std.string(Session.getInstance().host._uId), Reflect.field(_loc2_, "packagetime"));
		}
		Session.getInstance().addReward(_loc3_);
	}

	// UIController.as:592-611
	private function onLevelUpGiftAccepted(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Array<Dynamic> = [];
		var _loc3_:Dynamic = param1.data;
		// PORT-NOTE: 原版 Array.concat(任意值)——数组则展开、非数组（含
		// null/false）追加为单元素；Haxe concat 只收数组，isOfType 分流保
		// 两种入参的原语义
		if (Reflect.hasField(_loc3_, "item") == true) {
			Reflect.setField(_loc3_, "big", false);
			this.m_module.app.openWindowByName(Consts.WINDOW_NAME_GIFT, _loc3_);
			var item:Dynamic = Reflect.field(_loc3_, "item");
			_loc2_ = _loc2_.concat(Std.isOfType(item, Array) ? cast(item, Array<Dynamic>) : [item]);
		}
		if (Reflect.hasField(_loc3_, "vipItem") == true && Reflect.field(_loc3_, "vipItem") != false) {
			var vipItem:Dynamic = Reflect.field(_loc3_, "vipItem");
			_loc2_ = _loc2_.concat(Std.isOfType(vipItem, Array) ? cast(vipItem, Array<Dynamic>) : [vipItem]);
		}
		Session.getInstance().addReward(_loc2_);
	}

	// UIController.as:613-618
	private function onAddCollectingIcon(param1:CommonEvent):Void {
		var _loc2_:String = cast(Reflect.field(param1.data, "url"), String);
		var _loc3_:String = cast(Reflect.field(param1.data, "tip"), String);
		this.m_navbar.addIcon(_loc2_, "collecting", _loc3_);
	}

	// UIController.as:620-629（原版 :625 给 m_shortcuts 设名而非 _leftSideBar，
	// 原文如此照抄）
	private function creatLeftSideBar():Void {
		if (this._leftSideBar == null) {
			this._leftSideBar = new LeftSideToolBar(this, 60, 250);
			this.m_shortcuts.name = "__leftSideBar__";
			this.m_module.container.addChild(this._leftSideBar);
			this._leftSideBar.y = 75;
		}
	}

	// UIController.as:631-638
	private function onPackClicked(param1:Event):Void {
		this.m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PACK, null));
		if (this.m_toolBoxBar != null) {
			this.m_toolBoxBar.close();
		}
	}

	// UIController.as:640-649（newIconTip 素材的 tipMc.tip 文本链 → As3.childOf，
	// 时间轴具名子实例经显示列表查找）
	private function showNewIconTip(param1:String, param2:Point):Void {
		var _loc3_:MovieClip = cast(Utils.getMaterial("newIconTip"), MovieClip);
		_loc3_.name = "__newicontip__";
		cast(As3.childOf(As3.childOf(_loc3_, "tipMc"), "tip"), TextField).text = param1;
		_loc3_.gotoAndPlay(1);
		_loc3_.x = param2.x;
		_loc3_.y = param2.y;
		this.m_module.container.addChild(_loc3_);
	}
}
