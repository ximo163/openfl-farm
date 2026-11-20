package module.uitools.widgets;

import com.qzone.qui.containers.boxClasses.Box;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import com.qzone.qui.core.Align;
import com.qzone.qui.core.Direction;
import com.qzone.qui.managers.PopUpManager;
import common.CommonData;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.Cookies;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.window.PostWindow;
import entities.Player;
import events.CommonEvent;
import module.mainScene.npc.monthend.MonthEndWin;
import module.uitools.UIController;
import module.uitools.UIToolsModel;
import module.uitools.vo.OfflineData;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.system.SecurityDomain;
import openfl.text.TextField;
import report.ClickReportManager;
import report.EventRecorder;
import framework.api.PluginManager;
import framework.net.protocol.Protocol;
import shim.As3;
import shim.QQOutlets;

/**
 * module.uitools.widgets.ShortcutBar —— ShortcutBar.as 逐句对应（issue #9
 * uitools 片）。左上快捷条：免费礼物/鲜花/升级礼包/月末礼包/管家/闹钟/KFC/特步
 * 一排活动入口图标，按离线数据与配置增删（msg/gift/flower 三个写入位）。
 *
 * PORT-NOTE 汇总：
 * - ExternalInterface.available/call → shim.QQOutlets（deviations no-qq-telemetry：
 *   宿主缺位不外发，available=false 使 __security__/__alarmClock__ 分支照原文
 *   判空早退）；QZFL.dialog.create 的宿主弹窗调用原样落到 QQOutlets.call。
 * - IOErrorEvent.NETWORK_ERROR：openfl 没有该常量（AIR 专有），按 AS3 常量值
 *   "networkError" 照挂——Flash Player 里 Loader 从不发该事件，监听恒不触发。
 * - `param1 as Boolean == true` → As3.truthy（as Boolean 不做原语强制；桥发方
 *   恒发真 Boolean，LeftSideToolBar 同款）。
 * - `["key"] != undefined`/`!= undefined && != null` 键缺位判：Haxe 匿名对象无
 *   undefined，并成 null 判（LeftSideToolBar 先例）。
 * - `new Date(美式串)` → As3.dateOf，失败回 null 按 AS3 NaN-time 语义代入
 *   （ToolBar.initRedUpBtn 同款）。
 * - MonthEndWin（activities.json:2109）、PostWindow（messages.json:228）闭包
 *   stub；QUIOutlets 侧 addCallBackProxy/getKey 是宿主桥注入的 Dynamic 静态
 *   （CommonData.as:28/:32），缺宿主时为 null、判空分支照原文。
 * MOUSE_OVER/OUT 监听照抄——悬停合成在 spec/interaction-map.json 落地前不做
 * （见 BLOCKED 项）。
 * legacy/decompiled/main3_v_221/scripts/module/uitools/widgets/ShortcutBar.as
 */
class ShortcutBar extends Box {
	// ShortcutBar.as:49-61
	private var m_postWindow:PostWindow;
	private var _isNewUser:Int;
	private var _gift:Int = 0;
	private var monthend_timer:UInt;
	private var _monthEndWin:MonthEndWin;
	private var m_controller:UIController;
	private var m_offlineMsg:Int = 1;

	// ShortcutBar.as:63-93
	public function new(param1:UIController) {
		super(600, 62);
		x = 5;
		y = 68;
		alignH = Align.LEFT;
		gapH = 0;
		gapV = 0;
		direction = Direction.HORIZONTAL;
		_vScrollPolicy = ScrollPolicy.OFF;
		backgroundAlpha = 0;
		defaultSkin = null;
		this.m_postWindow = null;
		this.m_controller = param1;
		this.createView();
		this.amountPlugins();
		addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver, false, 0, true);
		addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut, false, 0, true);
		addEventListener(MouseEvent.CLICK, this.onClicked, false, 0, true);
		this.m_controller.module.app.addEventListener(Consts.MY_FLOWER_LOADED, this.onMyFlowerLoaded, false, 0, true);
		this.m_controller.module.app.addEventListener(Consts.DELEVE_NEW_ICON, this.removeNewIconTip, false, 0, true);
		this.m_controller.module.app.addEventListener(Consts.MSG_REMOVE_SHORTCUT_ICON, this.onRemoveIcon, false, 0, true);
		this.m_controller.module.app.addEventListener(Consts.ADD_ENTRANCE_ICON, this.addEntranceIcon, false, 0, true);
		var _loc2_:EventDispatcher = cast(this.m_controller.model, EventDispatcher);
		_loc2_.addEventListener(UIToolsModel.EVENT_OFFLINE_DATA_CHANGED, this.onDataChanged, false, 0, true);
		_loc2_.addEventListener(UIToolsModel.EVENT_EVERYDAY_GIFT_LOADED, this.onEverydayGiftLoaded, false, 0, true);
		_loc2_.addEventListener(UIToolsModel.EVENT_OFFLINE_DATA_MSG, this.onOfflineDataMessageLoaded, false, 0, true);
		_loc2_.addEventListener(UIToolsModel.GET_VIPRETURN_GIFT, this.onGetVipReturnGift, false, 0, true);
		_loc2_.addEventListener(UIToolsModel.EVENT_SHOW_WARNMSG, this.onShowWarnMsg, false, 0, true);
		_loc2_.addEventListener(UIToolsModel.EVENT_LEVELUP_CHANGED, this.onLevelUp, false, 0, true);
	}

	// ShortcutBar.as:95-115
	private function isNewUserToday():Bool {
		var _loc1_:Bool = false;
		if (Cookies.getObject("new_user_" + Session.getInstance().host._uId) == null) {
			return false;
		}
		var _loc2_:Date = Date.fromTime(CommonData.serverTime * 1000);
		var _loc3_:Date = Date.fromTime(As3.floatOf(Cookies.getObject("new_user_" + Session.getInstance().host._uId)) * 1000);
		if (_loc2_.getFullYear() == _loc3_.getFullYear()) {
			if (_loc2_.getMonth() == _loc3_.getMonth()) {
				if (_loc2_.getDate() == _loc3_.getDate()) {
					_loc1_ = true;
				}
			}
		}
		return _loc1_;
	}

	// ShortcutBar.as:117-130
	private function createView():Void {
		enableValidate = false;
		if (Settings.getInstance().mode != "" && QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
			this.m_controller.model.loadFreeData();
		}
		if (Settings.getInstance().isGiftTime()) {
			this.monthend_timer = As3.setTimeout(this.monthEndFn, 1000);
		}
		enableValidate = true;
		validateNow();
	}

	// ShortcutBar.as:132-135
	private function onGetVipReturnGift(param1:CommonEvent):Void {
		this.gift = Session.getInstance().isVipReturn == true ? 1 : 0;
	}

	// ShortcutBar.as:137-144（`param1 as Boolean == true`：as Boolean 不做原语
	// 强制；addCallBackProxy 桥恒发真 Boolean，truthy 等价——类头 PORT-NOTE）
	private function onTeBuCallback(param1:Dynamic):Void {
		if (As3.truthy(param1) == true) {
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG, null));
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG, null));
		}
	}

	// ShortcutBar.as:146-158
	private function giftWindowConfirmHandler():Void {
		if (Session.getInstance().isVipReturn) {
			this.m_controller.model.acceptGifts(true);
		} else {
			this.m_controller.model.acceptGifts(false);
		}
		this.gift = 2;
		this.adjustLayout();
	}

	// ShortcutBar.as:160-182
	private function onDataChanged(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:OfflineData = cast(param1.data, OfflineData);
		if (_loc2_ == null) {
			return;
		}
		this.msg = _loc2_.m_msgNum > 0 ? true : false;
		if (this.isNewUserToday()) {
			this.gift = 2;
		} else {
			this.gift = _loc2_.m_giftNum > 0 || Session.getInstance().isVipReturn ? 1 : 0;
		}
		this._isNewUser = _loc2_.m_giftNum;
		this.flower = _loc2_.m_flowerNum > 0 ? true : false;
	}

	// ShortcutBar.as:184-192
	private function removeNewIconTip(param1:CommonEvent):Void {
		var _loc2_:MovieClip = cast(this.getChildByName("__newicontip__"), MovieClip);
		if (_loc2_ != null) {
			this.removeChild(_loc2_);
			_loc2_ = null;
		}
	}

	// ShortcutBar.as:194-210
	private function monthEndClick():Void {
		var _loc1_:MovieClip = null;
		if (this._monthEndWin == null) {
			this._monthEndWin = new MonthEndWin(this.m_controller);
			_loc1_ = cast(this.getChildByName("__monthendarrow__"), MovieClip);
			if (_loc1_ != null) {
				removeChild(_loc1_);
				_loc1_ = null;
			}
			Cookies.setObject("monthend_" + Session.getInstance().host._uId, CommonData.serverTime);
		}
		PopUpManager.addPopUp(this._monthEndWin, true);
		this._monthEndWin.openWindows();
	}

	// ShortcutBar.as:212-224
	private function loadAdvertiseIcon(param1:String, param2:Dynamic, param3:Dynamic):Void {
		if (param1 == "" || param1 == null) {
			return;
		}
		param1 = Settings.getInstance().replaceAppImg(param1);
		var _loc4_:Loader = new Loader();
		// openfl IOErrorEvent 无 NETWORK_ERROR（AIR 专有），按 AS3 常量值照挂；
		// Flash Player 里 Loader 不发该事件，监听恒不触发（类头 PORT-NOTE）
		_loc4_.contentLoaderInfo.addEventListener("networkError", param3);
		_loc4_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, param3);
		_loc4_.contentLoaderInfo.addEventListener(Event.COMPLETE, param2);
		_loc4_.load(new URLRequest(param1), new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain));
	}

	// ShortcutBar.as:226-229
	private function addEntranceIcon(param1:CommonEvent):Void {
		addElement(cast(param1.data, DisplayObject));
	}

	// ShortcutBar.as:231-235
	private function onMyFlowerLoaded(param1:Event):Void {
		this.flower = false;
		this.adjustLayout();
	}

	// ShortcutBar.as:237-247
	private function onEverydayGiftLoaded(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		Reflect.setField(_loc2_, "big", false);
		Reflect.setField(_loc2_, "confirmHandler", this.giftWindowConfirmHandler);
		this.m_controller.openWindow(Consts.WINDOW_NAME_GIFT, _loc2_);
	}

	// ShortcutBar.as:249-348
	private function onClicked(param1:MouseEvent):Void {
		var _loc3_:String = null;
		var _loc4_:Dynamic = null;
		var _loc5_:String = null;
		var _loc6_:Int = 0;
		var _loc7_:Int = 0;
		var _loc8_:String = null;
		if (param1 == null || param1.target == null) {
			return;
		}
		var _loc2_:String = param1.target.name;
		if (_loc2_ == "__gift__") {
			if (this._isNewUser == 2) {
				_loc4_ = this.m_controller.model.loadEveryDayGift();
				if (_loc4_ != null) {
					Reflect.setField(_loc4_, "big", false);
					Reflect.setField(_loc4_, "confirmHandler", this.giftWindowConfirmHandler);
					this.m_controller.openWindow(Consts.WINDOW_NAME_GIFT, _loc4_);
				}
			} else {
				this.showYellowPackage(this._gift > 0);
			}
			ClickReportManager.reportClick("left.banner.icon_huang_zuan.click");
		} else if (_loc2_ == "__flower__") {
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_WAREHOUSE, {"openWithFlower": true}));
		} else if (_loc2_ == "__levelup__") {
			if (this.m_controller.model.drawLevelUpGift() == true) {
				this.m_controller.model.addEventListener(UIToolsModel.EVENT_LEVELUP_GIFTS, this.onLevelUpGift, false, 0, true);
			}
		} else if (_loc2_ == "__monthEnd__") {
			this.monthEndClick();
		} else if (_loc2_ == "__security__") {
			_loc5_ = Settings.getInstance().getStringAttribute("QQSecurity_CMD");
			if (_loc5_ != "" && QQOutlets.available) {
				_loc6_ = 369;
				_loc7_ = 550;
				// AS3 parseInt 回 Number 进 int 槽位隐式截断，Std.int 复刻
				_loc6_ = Std.int(As3.parseInt(Settings.getInstance().getStringAttribute("QQSecurity_width")));
				_loc7_ = Std.int(As3.parseInt(Settings.getInstance().getStringAttribute("QQSecurity_height")));
				// PORT-NOTE(qq-outlet)：ExternalInterface.call → QQOutlets.call
				QQOutlets.call("QZFL.dialog.create", "电脑管家农牧场主题活动", _loc5_, {
					"width": _loc6_,
					"height": _loc7_
				});
				EventRecorder.recordSueecssEvent("160645", null, null);
			}
		} else if (_loc2_ == "__alarmClock__") {
			_loc8_ = Settings.getInstance().getStringAttribute("QQAlarmClock_CMD");
			if (_loc8_ != "" && QQOutlets.available) {
				QQOutlets.call(_loc8_);
				EventRecorder.recordSueecssEvent("160649", null, null);
				Session.getInstance().addReward([{
					"type": "1",
					"num": 1
				}]);
			}
		} else if (_loc2_ == "__KFC__") {
			_loc3_ = "";
			if (Settings.getInstance().mode == "") {
				_loc3_ = "";
			}
			QQOutlets.call("QZFL.dialog.create(''," + "'<iframe src=" + _loc3_ + "&id=0"
				+ ' style="width:434px; height:394px; border:0px" scrolling=no border=0 frameBorder=no allowTransparency=true></iframe>'
				+ "', {width:434,height:396,noBorder:true})");
			com.qzone.allianceActivity.framewrok.manager.ClickReportManager.reportClick("KFC_Click_Icon_NC");
		} else if (_loc2_ == "_teBu_") {
			if (Settings.getInstance().mode == "") {
				_loc3_ = "";
			} else {
				_loc3_ = "";
			}
			CommonData.addCallBackProxy("getGiftBack", this.onTeBuCallback);
			QQOutlets.call("QZFL.dialog.create(''," + "'<iframe src=" + _loc3_ + "&id=1"
				+ ' style="width:630px; height:460.5px; border:0px" scrolling=no border=0 frameBorder=no allowTransparency=true></iframe>'
				+ "', {width:630,height:460.5,noBorder:true})");
			com.qzone.allianceActivity.framewrok.manager.ClickReportManager.reportClick("TeBu_Click_Icon_NC");
		}
	}

	// ShortcutBar.as:350-373
	private function adjustLayout():Void {
		var _loc3_:Int = 0;
		if (content == null) {
			return;
		}
		var _loc1_:Array<Dynamic> = [];
		var _loc2_:DisplayObject = null;
		while (_loc3_ < content.numChildren) {
			_loc2_ = content.getChildAt(_loc3_);
			_loc1_.push(_loc2_);
			_loc3_++;
		}
		enableValidate = false;
		removeAllElements();
		for (_loc2_ in (_loc1_ : Array<Dynamic>)) {
			addElement(_loc2_);
		}
		enableValidate = true;
		validateNow();
	}

	// ShortcutBar.as:375-425（`["content"] != undefined` 键缺位判 → hasField，
	// LeftSideToolBar 先例；__post__ 缺位无守卫照抄——缺素材同抛）
	private function openPostWindow():Void {
		var _loc2_:MovieClip = null;
		var _loc3_:String = null;
		var _loc4_:String = null;
		var _loc1_:Dynamic = this.m_controller.model.loadPostData();
		if (_loc1_ != null) {
			if (Reflect.hasField(_loc1_, "content")) {
				_loc3_ = cast(Reflect.field(_loc1_, "content"), String);
				if (_loc3_ == "" || _loc3_ == null) {
					return;
				}
				if (this.m_postWindow == null) {
					this.m_postWindow = new PostWindow(null, Reflect.field(Language.L, "确定"));
					this.m_postWindow.title = "";
					this.m_postWindow.closeFn = this.onPostWindowClosed;
				}
				this.m_postWindow.text = _loc3_;
				this.m_controller.module.app.farmView.winCtrl.open(this.m_postWindow);
				this.m_controller.module.app.useSystemCursor(true);
				Cookies.setObject("postText", _loc3_);
				Cookies.setObject("postClicked", true);
			} else if (Reflect.hasField(_loc1_, "imageurl")) {
				_loc4_ = cast(Reflect.field(_loc1_, "imageurl"), String);
				if (_loc4_ == "" || _loc4_ == null) {
					return;
				}
				if (this.m_postWindow == null) {
					this.m_postWindow = new PostWindow(null, Reflect.field(Language.L, "确定"));
					this.m_postWindow.title = "";
					this.m_postWindow.closeFn = this.onPostWindowClosed;
				}
				this.m_postWindow.imgUrl = _loc4_;
				this.m_controller.module.app.farmView.winCtrl.open(this.m_postWindow);
				this.m_controller.module.app.useSystemCursor(true);
				Cookies.setObject("postImage", _loc4_);
				Cookies.setObject("postImageClicked", true);
			}
			EventRecorder.recordSueecssEvent(EventRecorder.HF_POSTVIEW, 0);
			_loc2_ = cast(content.getChildByName("__post__"), MovieClip);
			_loc2_.gotoAndStop(1);
		}
	}

	// ShortcutBar.as:427-525（closure 变量 FFDec 顶部前置；`new Date(美式串)`
	// → As3.dateOf，失败回 null 按 NaN-time 语义代入——ToolBar 同款）
	private function amountPlugins():Void {
		var self:ShortcutBar = null;
		var loadTeBu:Dynamic = null;
		var teBuLoaded:Dynamic = null;
		var loadComplete:Dynamic = null;
		var errorHandler:Dynamic = null;
		loadTeBu = function(param1:Int, param2:Dynamic):Void {
			if (As3.truthy(param2) && Reflect.field(param2, "code") == 1 && Reflect.field(param2, "ecode") == 0) {
				loadAdvertiseIcon("module/ui/teBuRes.swf", teBuLoaded, errorHandler);
			}
		};
		teBuLoaded = function(param1:Event):Void {
			var _loc2_:DisplayObject = null;
			if (Std.isOfType(param1.target, LoaderInfo)) {
				_loc2_ = cast(param1.target, LoaderInfo).content;
			}
			if (_loc2_ == null) {
				return;
			}
			addElement(_loc2_);
		};
		loadComplete = function(param1:Event):Void {
			var _loc2_:DisplayObject = null;
			if (Std.isOfType(param1.target, LoaderInfo)) {
				_loc2_ = cast(param1.target, LoaderInfo).content;
			}
			if (_loc2_ == null) {
				return;
			}
			addElement(_loc2_);
		};
		errorHandler = function(param1:IOErrorEvent):Void {};
		self = this;
		As3.setTimeout(function():Void {
			var _loc1_:Settings = null;
			var _loc2_:String = null;
			var _loc3_:Array<Dynamic> = null;
			var _loc4_:Date = null;
			var _loc5_:Date = null;
			var _loc6_:Float = Math.NaN;
			var _loc7_:String = null;
			var _loc8_:Settings = null;
			var _loc9_:String = null;
			PluginManager.getInstance().amountPlugins(Consts.PLUGIN_AMOUNT_SHORTCUT, self, null);
			if (QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false) {
				_loc1_ = Settings.getInstance();
				_loc2_ = _loc1_.getStringAttribute("kfc");
				if (_loc2_ == null || _loc2_ == "") {
					return;
				}
				_loc3_ = _loc2_.split("-");
				_loc4_ = As3.dateOf(_loc3_[0]);
				_loc5_ = As3.dateOf(_loc3_[1]);
				_loc6_ = CommonData.serverTime * 1000;
				if (_loc6_ >= (_loc4_ == null ? Math.NaN : _loc4_.getTime()) && _loc6_ <= (_loc5_ == null ? Math.NaN : _loc5_.getTime())) {
					loadAdvertiseIcon("module/ui/kfc.swf", loadComplete, errorHandler);
				}
				_loc7_ = _loc1_.getStringAttribute("teBu");
				if (_loc7_ == null || _loc7_ == "") {
					return;
				}
				_loc3_ = _loc7_.split("-");
				_loc4_ = As3.dateOf(_loc3_[0]);
				_loc5_ = As3.dateOf(_loc3_[1]);
				_loc6_ = CommonData.serverTime * 1000;
				if (_loc6_ >= (_loc4_ == null ? Math.NaN : _loc4_.getTime()) && _loc6_ <= (_loc5_ == null ? Math.NaN : _loc5_.getTime())) {
					_loc8_ = Settings.getInstance();
					_loc9_ = _loc8_.mode;
					if (_loc9_ == "qplus") {
						_loc9_ = "qzone";
					}
					if (PluginManager.getInstance().api == null) {
						return;
					}
					PluginManager.getInstance().api.registerNetCommand(16001, "" + _loc9_ + "mod=cgi_farm_get_bit?bit=7", null);
					PluginManager.getInstance().api.sendRequest(16001, {}, loadTeBu, null);
				}
			}
		}, 3000);
	}

	// ShortcutBar.as:527-529（public set msg，无 get；原文空体）
	public var msg(never, set):Bool;

	private function set_msg(param1:Bool):Bool {
		return param1;
	}

	// ShortcutBar.as:531-556
	private function onLevelUp(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:MovieClip = cast(content.getChildByName("__levelup__"), MovieClip);
		var _loc3_:Array<Dynamic> = cast(param1.data, Array<Dynamic>);
		if (_loc3_ == null || _loc3_.length == 0) {
			if (_loc2_ == null) {
				return;
			}
			removeElement(_loc2_);
			this.adjustLayout();
		} else if (_loc2_ == null) {
			_loc2_ = cast(Utils.getMaterial("LevelUpIcon"), MovieClip);
			_loc2_.name = "__levelup__";
			_loc2_.buttonMode = true;
			_loc2_.stop();
			addElement(_loc2_);
		}
	}

	// ShortcutBar.as:558-561
	private function onMouseOut(param1:MouseEvent):Void {
		this.m_controller.hideTip();
	}

	// ShortcutBar.as:563-609
	private function monthEndFn():Void {
		var monthEnd:MovieClip;
		var arrow:MovieClip = null;
		As3.clearTimeout(this.monthend_timer);
		monthEnd = cast(content.getChildByName("__monthEnd__"), MovieClip);
		if (monthEnd == null) {
			monthEnd = cast(Utils.getMaterial("MonthEndIcon"), MovieClip);
			if (monthEnd != null) {
				monthEnd.name = "__monthEnd__";
				monthEnd.mouseChildren = false;
				monthEnd.buttonMode = true;
				addElement(monthEnd);
				if (CommonData.isMonthEndToday(Session.getInstance().host._uId)) {
					arrow = cast(this.getChildByName("__monthendarrow__"), MovieClip);
					if (arrow == null) {
						arrow = cast(Utils.getMaterial("monthEndArrow"), MovieClip);
						arrow.name = "__monthendarrow__";
						if (As3.truthy(Settings.getInstance().getMonthEnds("0", "month"))) {
							cast(Reflect.field(Reflect.field(arrow, "tipMc"), "tip"), TextField).text = Settings.getInstance()
								.getMonthEnds("0", "month") + "礼包\n火热促销中";
						} else {
							cast(Reflect.field(Reflect.field(arrow, "tipMc"), "tip"), TextField).text = "月末大礼包\n火热促销中";
						}
						addChild(arrow);
					}
					arrow.x = monthEnd.x + 35;
					arrow.y = monthEnd.y + 30;
					arrow.mouseEnabled = false;
					As3.setTimeout(function():Void {
						if (As3.truthy(arrow) && As3.truthy(arrow.parent)) {
							arrow.parent.removeChild(arrow);
							arrow = null;
						}
					}, 5000);
				}
			}
		}
	}

	// ShortcutBar.as:611-620
	private function onRemoveIcon(param1:CommonEvent):Void {
		var _loc2_:DisplayObjectContainer = cast(param1.data, DisplayObjectContainer);
		if (_loc2_ == null) {
			return;
		}
		removeElement(_loc2_);
		this.adjustLayout();
	}

	// ShortcutBar.as:622-661（public set gift，无 get）
	public var gift(never, set):Int;

	private function set_gift(param1:Int):Int {
		this._gift = param1;
		var _loc2_:MovieClip = null;
		if (QzoneJSAPI.QPLUS == true || QzoneJSAPI.WB == true) {
			return param1;
		}
		_loc2_ = cast(content.getChildByName("__gift__"), MovieClip);
		if (_loc2_ == null) {
			_loc2_ = cast(Utils.getMaterial("GiftIcon"), MovieClip);
			_loc2_.name = "__gift__";
			_loc2_.buttonMode = true;
			addElement(_loc2_);
		}
		if (param1 == 1) {
			if (Std.string(Session.getInstance().host._yellowstatus) != "0") {
				_loc2_.gotoAndPlay("GiftMove");
				return param1;
			}
			_loc2_.gotoAndStop(2);
		} else if (param1 == 2) {
			removeElement(_loc2_);
			this.adjustLayout();
		} else {
			if (Std.string(Session.getInstance().host._yellowstatus) != "0") {
				_loc2_.gotoAndStop(1);
				return param1;
			}
			_loc2_.gotoAndStop(2);
		}
		return param1;
	}

	// ShortcutBar.as:663-691
	private function showYellowPackage(param1:Bool):Void {
		var _loc5_:String = null;
		var _loc6_:String = null;
		var _loc7_:String = null;
		var _loc2_:Session = Session.getInstance();
		var _loc3_:String = "";
		if (CommonData.getKey != null) {
			_loc3_ = CommonData.getKey();
		}
		var _loc4_:String = Std.string(CommonData.serverTime);
		if (Settings.getInstance().mode == "qzone") {
			_loc6_ = Protocol._userUin;
			_loc7_ = _loc2_.hostUin;
		}
		_loc5_ = "farmKey=" + _loc3_ + "&farmTime=" + _loc4_ + "&uIdx=" + _loc2_.hostId + "&uinX=" + _loc6_ + "&uinY=" + _loc7_;
		CommonData.addCallBackProxy("getGiftBack", this.setGiftData);
		var _loc8_:Player = _loc2_.host;
		if (_loc8_._yellowstatus != 0) {
			QzoneJSAPI.showVIPPackage(Consts.APP_ID, param1 == true ? false : true, _loc5_, _loc8_._yellowstatus, _loc8_._yellowlevel);
		} else {
			QzoneJSAPI.showVIPPackage(Consts.APP_ID, false, _loc5_, _loc8_._yellowstatus, _loc8_._yellowlevel);
		}
	}

	// ShortcutBar.as:693-711（public set flower，无 get）
	public var flower(never, set):Bool;

	private function set_flower(param1:Bool):Bool {
		var _loc2_:Sprite = cast(content.getChildByName("__flower__"), Sprite);
		if (param1 == true) {
			if (_loc2_ == null) {
				_loc2_ = cast(Utils.getMaterial("FlowerIcon"), Sprite);
				_loc2_.name = "__flower__";
				_loc2_.mouseChildren = false;
				_loc2_.buttonMode = true;
				addElement(_loc2_);
			}
		} else if (_loc2_ != null) {
			removeElement(_loc2_);
		}
		return param1;
	}

	// ShortcutBar.as:713-733
	private function onLevelUpGift(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		var _loc3_:Array<Dynamic> = [];
		if (Reflect.hasField(_loc2_, "item") == true) {
			Reflect.setField(_loc2_, "big", false);
			this.m_controller.module.app.openWindowByName(Consts.WINDOW_NAME_GIFT, _loc2_);
			this.m_controller.module.app.hideTip();
			_loc3_ = _loc3_.concat(Reflect.field(_loc2_, "item"));
		}
		var _vipItem:Dynamic = Reflect.field(_loc2_, "vipItem");
		if (Reflect.hasField(_loc2_, "vipItem") == true && _vipItem != false) {
			_loc3_ = _loc3_.concat(_vipItem);
		}
		Session.getInstance().addReward(_loc3_);
	}

	// ShortcutBar.as:735-781
	private function onMouseOver(param1:MouseEvent):Void {
		if (param1 == null || param1.target == null) {
			return;
		}
		var _loc2_:String = param1.target.name;
		if (_loc2_ == "__gift__") {
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "礼包");
		} else if (_loc2_ == "__flower__") {
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "收到鲜花");
		} else if (_loc2_ == "__levelup__") {
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "领取升级礼包");
		} else if (_loc2_ == "__monthEnd__") {
			if (As3.truthy(Settings.getInstance().getMonthEnds("0", "month"))) {
				this.m_controller.showTip(Consts.TIP_NAME_MOUSE, Settings.getInstance().getMonthEnds("0", "month") + "大礼包");
			} else {
				this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "大礼包");
			}
		} else if (_loc2_ == "__security__") {
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "安装管家送管家精灵狗");
		} else if (_loc2_ == "__alarmClock__") {
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "安装QQ闹钟送大礼");
		} else if (_loc2_ == "__KFC__") {
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "KFC有料同享 第二杯半价");
		} else if (_loc2_ == "_teBu_") {
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "特步，趣跑无限");
		}
	}

	// ShortcutBar.as:783-786
	private function onPostWindowClosed(param1:Event):Void {
		this.m_controller.module.app.useSystemCursor(false);
	}

	// ShortcutBar.as:788-828（`["item"] != undefined && != null` 双判：Haxe
	// 匿名对象无 undefined，并成 null 判；`["vipItem"][0] != undefined` 同）
	public function setGiftData(param1:Dynamic):Void {
		var _loc4_:Dynamic = null;
		var _loc5_:String = null;
		this.gift = 0;
		var _loc2_:Array<Dynamic> = [];
		var _loc3_:Array<Dynamic> = [];
		var _item:Dynamic = Reflect.field(param1, "item");
		if (_item != null) {
			if (Std.isOfType(_item, Array)) {
				_loc2_ = _loc2_.concat(_item);
			} else {
				_loc4_ = _item;
				for (_loc5_ in Reflect.fields(_loc4_)) {
					_loc3_.push(Reflect.field(_loc4_, _loc5_));
				}
				_loc2_ = _loc2_.concat(_loc3_);
			}
		}
		var _vipItem:Dynamic = Reflect.field(param1, "vipItem");
		if (Reflect.hasField(param1, "vipItem") == true && _vipItem != null) {
			if (Std.isOfType(_vipItem, Array)) {
				_loc2_ = _loc2_.concat(cast(_vipItem, Array<Dynamic>)[0] != null ? cast(_vipItem, Array<Dynamic>)[0] : _vipItem);
			} else {
				_loc4_ = _vipItem;
				for (_loc5_ in Reflect.fields(_loc4_)) {
					_loc3_.push(Reflect.field(_loc4_, _loc5_));
				}
				_loc2_ = _loc2_.concat(_loc3_);
			}
		}
		Session.getInstance().addReward(_loc2_);
	}

	// ShortcutBar.as:830-837（`param1.data as int`：UIToolsModel 恒派发 Int
	// （UIToolsModel.as:138），直接 cast 等价）
	private function onOfflineDataMessageLoaded(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.m_offlineMsg = cast(param1.data, Int);
	}

	// ShortcutBar.as:839-843
	private function onShowWarnMsg(param1:CommonEvent):Void {
		this.openPostWindow();
		EventRecorder.recordErrorEvent(EventRecorder.CHEAT_FARM, 0, EventRecorder.SUEECSS);
	}
}
