package module.mainScene.farmLand;

import com.greensock.TweenLite;
import com.qzone.allianceActivity.AllianceActivityManager;
import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
import com.qzone.qui.effects.Move;
import com.qzone.qui.managers.PopUpManager;
import com.qzone.qui.styles.Style;
import com.qzone.utils.AlignUtil;
import com.qzone.utils.GraphicsUtil;
import common.CommonData;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.Utils;
import common.misc.time.CountDown;
import common.view.cursor.CursorControl;
import entities.FarmLand;
import entities.Player;
import entities.StartupData;
import events.CommonEvent;
import framework.base.Controller;
import interfaces.IModule;
import interfaces.IMsgCenter;
import module.mainScene.farmLand.widgets.LandItemRender;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
import report.EventRecorder;
import shim.As3;
import shim.LocalSwfLoader;

/**
 * module.mainScene.farmLand.FarmLandController —— V3b 翻译（issue #8）。
 * 农田控制器（光标状态机、地块操作派发、飞机窗口、扩建确认、升级红土地动画
 * 装载、礼包弹窗）。FarmLandController.as 1074 loc 逐句对应。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/FarmLandController.as
 * PORT-NOTE(动态取键)：AS3 `obj["k"] != undefined` → Reflect.hasField(...) &&
 * Reflect.field(...) != null；`as int`（JSON 数值）→ As3.intOf；mc["字段"] 的
 * 动态字段读写 → Reflect.setField/field（Flash 动态属性）。AS3 Function 形参
 * 无 Haxe 等价物，按本仓库既定做法走 Dynamic + Reflect.callMethod。
 */
@:keep
class FarmLandController extends Controller {
	// FarmLandController.as:44
	private var m_confirmScarifyArg:Dynamic;

	// FarmLandController.as:46
	private var _beginLoadCrops:UInt = 0; // AS3 uint 默认值

	// FarmLandController.as:48（原版声明后未用，照抄）
	private var _firecracker:MovieClip;

	// FarmLandController.as:50
	private var m_isInit:Bool = true;

	// FarmLandController.as:52（AS3 Function → Dynamic）
	private var m_confirmScarifyCallback:Dynamic;

	// FarmLandController.as:54
	private var m_updateFreq:CountDown;

	// FarmLandController.as:56-63
	public function new(param1:IModule) {
		super(param1);
		this.m_confirmScarifyArg = null;
		this.m_confirmScarifyCallback = null;
		this.m_updateFreq = new CountDown(Consts.FARM_LAND_COUNTDOWN);
		this._beginLoadCrops = 0;
	}

	// FarmLandController.as:65-69
	private function onUpdateGoldLandTime(param1:CommonEvent):Void {
		var _loc2_:Int = this.model.isAllGoldLand;
		param1.data.updateGoldLandTimeShow(_loc2_);
	}

	// FarmLandController.as:71-79
	private function onSetLandCursor(param1:Event):Void {
		this.view.showPickIcon(true);
		var _loc2_:String = module.app.farmView.cursorCtrl.name;
		if (_loc2_ == null || _loc2_ == "") {
			module.app.farmView.cursorCtrl.setCursor(Consts.CURSOR_STYLE_ARROW);
		}
	}

	// FarmLandController.as:81-159
	public function setNextAction(param1:Bool, param2:Bool, param3:Bool):Void {
		var _loc4_:CursorControl = null;
		if (m_module != null && m_module.app != null) {
			_loc4_ = m_module.app.farmView.cursorCtrl;
		}
		if (_loc4_ == null) {
			return;
		}
		var _loc5_:Bool = Session.getInstance().me;
		if (_loc5_ == true) {
			if (_loc4_.name == Consts.CURSOR_STYLE_HOE) {
				if (this.model.hasLandToScarify() == true) {
					return;
				}
			}
		}
		if (param1 == true) {
			if (this.m_isInit) {
				this.m_isInit = false;
			}
			if (_loc5_ == false) {
				if (_loc4_.name == Consts.CURSOR_STYLE_WEED || _loc4_.name == Consts.CURSOR_STYLE_INSET) {
					return;
				}
			}
			if (_loc4_.name != Consts.CURSOR_STYLE_PESTICIDE && _loc4_.name != Consts.CURSOR_STYLE_WATER) {
				_loc4_.setCursor(Consts.CURSOR_STYLE_HOOK);
			}
		} else if (param2 == true) {
			if (this.m_isInit) {
				this.m_isInit = false;
			}
			if (_loc5_ == false) {
				if (_loc4_.name == Consts.CURSOR_STYLE_WEED || _loc4_.name == Consts.CURSOR_STYLE_INSET) {
					return;
				}
			}
			if (_loc4_.name != Consts.CURSOR_STYLE_WATER) {
				_loc4_.setCursor(Consts.CURSOR_STYLE_PESTICIDE);
			}
		} else if (param3 == true) {
			if (this.m_isInit) {
				this.m_isInit = false;
			}
			if (_loc4_.name != Consts.CURSOR_STYLE_WATER) {
				_loc4_.setCursor(Consts.CURSOR_STYLE_WATER);
			}
		} else if (this.m_isInit == true && this.model.hasLandToScarify() == true) {
			this.m_isInit = false;
			if (_loc4_.name != Consts.CURSOR_STYLE_HOE) {
				_loc4_.setCursor(Consts.CURSOR_STYLE_HOE);
			}
			return;
		}
	}

	// FarmLandController.as:161-164
	private function onSetQQBrowserAlarm(param1:CommonEvent):Void {
		this.model.setQQBrowserAlarm();
	}

	// FarmLandController.as:166-173
	private function onAlertWindow(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		m_module.app.openWindowByName(Consts.WINDOW_NAME_ALERT, param1.data);
	}

	// FarmLandController.as:175-184（返回值是 AS3 把 Object 强转 Boolean，
	// 用 As3.truthy 复刻）
	public function showWaterCursor():Bool {
		var _loc1_:Dynamic = {"fish": false};
		m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_WATER_CURSOR, null, _loc1_));
		if (Reflect.field(_loc1_, "fish") == true) {
			this.view.loseMouse();
		}
		return As3.truthy(Reflect.field(_loc1_, "fish"));
	}

	// FarmLandController.as:186-205
	private function onGoldLandUpdateFail(param1:CommonEvent):Void {
		if (param1.data != null) {
			if (Reflect.hasField(param1.data, "direction")) {
				openWindow(Consts.WINDOW_NAME_ALERT, {
					"icon": Consts.ALERT_TYPE_ERROR,
					"text": Reflect.field(param1.data, "direction")
				});
			} else {
				openWindow(Consts.WINDOW_NAME_ALERT, {"icon": Consts.ALERT_TYPE_ERROR, "text": "购买失败!"});
			}
		}
	}

	// FarmLandController.as:207-268
	public function clickOnLand(param1:LandItemRender):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:String = "";
		if (m_module != null && m_module.app != null) {
			_loc2_ = m_module.app.farmView.cursorCtrl.name;
		}
		if (_loc2_ == "") {
			return;
		}
		var _loc3_:Array<String> = null;
		var _loc4_:String = m_module.app.farmView.cursorCtrl.cursorArgument;
		switch (_loc2_) {
			case Consts.CURSOR_STYLE_WATER:
				m_model.operate_water(param1.index);
			case Consts.CURSOR_STYLE_HOOK:
				m_model.operate_clearWeed(param1.index);
				this.preCheckNextOperate(0);
			case Consts.CURSOR_STYLE_WEED:
				m_model.operate_addWeed(param1.index);
			case Consts.CURSOR_STYLE_INSET:
				m_model.operate_addBug(param1.index);
			case Consts.CURSOR_STYLE_PESTICIDE:
				m_model.operate_clearBug(param1.index);
				this.preCheckNextOperate(1);
			case Consts.CURSOR_STYLE_HAND:
				m_model.operate_harvest(param1.index);
			case Consts.CURSOR_STYLE_ONEHAND:
				m_model.operate_harvestAll(param1.index);
			case Consts.CURSOR_STYLE_HOE:
				m_model.operate_scarify(param1.index);
			case Consts.CURSOR_STYLE_CROPSEED:
				_loc3_ = _loc4_.split(",");
				if (_loc3_.length < 2 || _loc3_[0] != Consts.ITEM_TYPE_SEED) {
					return;
				}
				// AS3 parseInt → int 形参隐式截断
				m_model.operate_plant(param1.index, As3.intOf(_loc3_[1]));
			case Consts.CURSOR_STYLE_TOOL:
				_loc3_ = _loc4_.split(",");
				if (_loc3_.length < 2 || _loc3_[0] != Consts.ITEM_TYPE_TOOL) {
					return;
				}
				m_model.operate_fertilize(param1.index, As3.intOf(_loc3_[1]));
		}
	}

	// FarmLandController.as:270-286
	private function onConfirmScarifyOK():Void {
		if (this.m_confirmScarifyArg == null) {
			return;
		}
		if (this.m_confirmScarifyCallback == null) {
			return;
		}
		if (Reflect.hasField(this.m_confirmScarifyArg, "place") && Reflect.field(this.m_confirmScarifyArg, "place") != null
			&& Reflect.hasField(this.m_confirmScarifyArg, "step") && Reflect.field(this.m_confirmScarifyArg, "step") != null) {
			Reflect.callMethod(null, this.m_confirmScarifyCallback, [
				As3.intOf(Reflect.field(this.m_confirmScarifyArg, "place")),
				As3.intOf(Reflect.field(this.m_confirmScarifyArg, "step"))
			]);
		}
		this.m_confirmScarifyArg = null;
		this.m_confirmScarifyCallback = null;
	}

	// FarmLandController.as:288-291
	private function confirmReclaim():Void {
		m_model.reclaimNewLand();
	}

	// FarmLandController.as:293-299
	private function onCropDataChanged(param1:Event):Void {
		if (m_module != null && m_module.app != null) {
			m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG, null));
		}
	}

	// FarmLandController.as:301-307
	override public function finalize():Void {
		if (m_model != null) {
			m_model = null;
		}
	}

	// FarmLandController.as:309-331
	private function onReclaimSuccess(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		if (Reflect.field(_loc2_, "code") == 1) {
			Session.getInstance().updateHostAccount(As3.intOf(Reflect.field(_loc2_, "money")), 0, 0);
			if (m_module != null && m_module.app != null) {
				m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER, null));
			}
		} else {
			openWindow(Consts.WINDOW_NAME_ALERT, {
				"icon": Consts.ALERT_TYPE_ERROR,
				"text": Reflect.field(_loc2_, "direction")
			});
		}
	}

	// FarmLandController.as:333-387（PlaneWindow 内部是 Flash 命名时间轴子对象
	// + 动态字段 __mask__，eval 下 getMaterial 恒 null 提前返回，符号类接入后
	// 这些动态读写才走到）
	private function onPlaneLoaded():Void {
		var _loc1_:MovieClip = null;
		m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {"showLoading": false}));
		var _loc1d:Dynamic = Utils.getMaterial("PlaneWindow");
		_loc1_ = Std.isOfType(_loc1d, MovieClip) ? cast _loc1d : null;
		if (_loc1_ == null) {
			return;
		}
		var _loc2d:Dynamic = Reflect.field(CommonData.root, "stage");
		var _loc2_:Stage = Std.isOfType(_loc2d, Stage) ? cast _loc2d : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Sprite = new Sprite();
		GraphicsUtil.draw(_loc3_, Style.popUpModalColor, Style.popUpModalAlpha, new Rectangle(0, 0, _loc2_.stageWidth, _loc2_.stageHeight), true);
		_loc2_.addChild(_loc3_);
		_loc1_.name = "__plane__";
		Reflect.setField(_loc1_, "__mask__", _loc3_);
		_loc1_.x = AlignUtil.middle(_loc2_.stageWidth, _loc1_.width) + 65;
		_loc1_.y = AlignUtil.middle(_loc2_.stageHeight, _loc1_.height);
		_loc1_.filters = cast Style.getShadowFilter(); // AS3 Array → openfl Array<BitmapFilter>
		_loc2_.addChild(_loc1_);
		var _loc4_:Int = this.model.countNoneMatureLands();
		var _loc5_:Int = _loc4_ * 3;
		var tfHrs:Dynamic = Reflect.field(_loc1_, "tfHrs");
		tfHrs.text = Std.string(_loc4_); // AS3 int → text 的 String 隐式转换
		var tfQD:Dynamic = Reflect.field(_loc1_, "tfQD");
		tfQD.text = Std.string(_loc5_);
		var _loc6_:String = "";
		if (Settings.getInstance().getStringAttribute("PlaneDiscount") != "1") {
			var tf1:Dynamic = Reflect.field(_loc1_, "tf1");
			tf1.text = "仅年费VIP尊享此功能";
		}
		if (Session.getInstance().isMeVIP == true) {
			_loc6_ += "&nbsp;x&nbsp;0.8";
			_loc5_ = Std.int(_loc5_ * 0.8); // AS3 int 收 Number 隐式截断
		} else {
			_loc6_ += "&nbsp;x&nbsp;1.0";
		}
		_loc5_ = Std.int(Math.floor(_loc5_)); // AS3 Math.floor(...) as int
		var tfSum:Dynamic = Reflect.field(_loc1_, "tfSum");
		tfSum.htmlText = "<font color=\'#E17204\'>" + Std.string(_loc4_ * 3) + "</font>&nbsp;元宝" + _loc6_ + "&nbsp;=&nbsp;<font color=\'#E17204\'>" + _loc5_ + "</font>&nbsp;元宝";
		if (_loc4_ == 0) {
			var btnOK:Dynamic = Reflect.field(_loc1_, "btnOK");
			btnOK.mouseEnabled = false;
			btnOK.filters = Style.getDisableFilter();
		} else {
			var btnOK2:Dynamic = Reflect.field(_loc1_, "btnOK");
			btnOK2.mouseEnabled = true;
			btnOK2.filters = null;
		}
		_loc1_.addEventListener(MouseEvent.CLICK, this.onPlaneWindowClicked, false, 0, true);
	}

	// FarmLandController.as:389-393
	private function onHealthModeTimeout(param1:CommonEvent):Void {
		hideTip();
		this.view.showPickIcon(false);
	}

	// FarmLandController.as:395-398
	public var view(get, never):FarmLandsView;

	private function get_view():FarmLandsView {
		var _loc1_:Dynamic = m_view;
		return Std.isOfType(_loc1_, FarmLandsView) ? cast _loc1_ : null;
	}

	// FarmLandController.as:400-423
	public function setHandCursor():Void {
		var _loc1_:CursorControl = null;
		if (m_module != null && m_module.app != null) {
			_loc1_ = m_module.app.farmView.cursorCtrl;
		}
		if (_loc1_ == null) {
			return;
		}
		var _loc2_:Session = Session.getInstance();
		if (this.isOneClickMode() == true || !_loc2_.currentUser.me) {
			if (_loc1_.name != Consts.CURSOR_STYLE_ONEHAND && _loc1_.name != Consts.CURSOR_STYLE_HAND && _loc1_.name != Consts.CURSOR_STYLE_HOE) {
				_loc1_.setCursor(Consts.CURSOR_STYLE_ONEHAND);
			}
		} else if (_loc1_.name != Consts.CURSOR_STYLE_HAND && _loc1_.name != Consts.CURSOR_STYLE_HOE) {
			_loc1_.setCursor(Consts.CURSOR_STYLE_HAND);
		}
	}

	// FarmLandController.as:425-428
	public var model(get, never):FarmLandModel;

	private function get_model():FarmLandModel {
		var _loc1_:Dynamic = m_model;
		return Std.isOfType(_loc1_, FarmLandModel) ? cast _loc1_ : null;
	}

	// FarmLandController.as:430-439
	private function onPlaneClicked(param1:Event):Void {
		var _loc2_:String = Settings.getInstance().getSecondUrl("plane");
		if (_loc2_ == null || _loc2_ == "") {
			return;
		}
		m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {"showLoading": true}));
		CommonData.rslManager.requestClass("PlaneWindow", this.onPlaneLoaded, _loc2_);
	}

	// FarmLandController.as:441-506
	private function preCheckNextOperate(param1:Int):Void {
		var _loc2_:CursorControl = null;
		if (m_module != null && m_module.app != null) {
			_loc2_ = m_module.app.farmView.cursorCtrl;
		}
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:FarmLand = null;
		var _loc4_:Bool = false;
		var _loc5_:Bool = false;
		var _loc6_:Bool = false;
		var _loc7_:Int = this.view.landNum;
		var _loc8_:Int = 0;
		while (_loc8_ < _loc7_) {
			_loc3_ = this.model.getLandData(_loc8_);
			if (_loc3_ != null) {
				if (_loc4_ == false) {
					_loc4_ = _loc3_.hasPest;
				}
				if (_loc5_ == false) {
					_loc5_ = _loc3_.hasWeed;
				}
				if (_loc6_ == false) {
					_loc6_ = _loc3_.needWater;
				}
			}
			_loc8_++;
		}
		if (param1 == 0) {
			if (_loc5_ == false) {
				if (_loc4_ == true) {
					_loc2_.setCursor(Consts.CURSOR_STYLE_PESTICIDE);
				} else if (_loc6_ == true) {
					_loc2_.setCursor(Consts.CURSOR_STYLE_WATER);
				}
			}
		} else if (param1 == 1) {
			if (_loc4_ == false) {
				if (_loc5_ == true) {
					_loc2_.setCursor(Consts.CURSOR_STYLE_HOOK);
				} else if (_loc6_ == true) {
					_loc2_.setCursor(Consts.CURSOR_STYLE_WATER);
				}
			}
		}
	}

	// FarmLandController.as:508-548
	public function onGameLoop(param1:Float):Void {
		var _loc2_:IAllianceActivityContext = null;
		var _loc3_:Float = Math.NaN;
		if (this.m_updateFreq.isReady() == false) {
			return;
		}
		this.m_updateFreq.reset(Consts.FARM_LAND_COUNTDOWN);
		if (this.model != null) {
			this.model.growLoop();
			if (this.model.tjShare != null && this.model.tjShare.length > 0) {
				_loc2_ = AllianceActivityManager.getInstance().getActivityContext("collecting");
				if (_loc2_ != null) {
					_loc2_.execute("10004", this.model.tjShare);
					this.model.tjShare = [];
				}
			}
		}
		if (this.view != null) {
			this.view.talkRandom();
		}
		if (this._beginLoadCrops > 0) {
			_loc3_ = As3.getTimer() - this._beginLoadCrops;
			if (this.view.checkCropLoaded() == true) {
				EventRecorder.recordSueecssEvent("160452", _loc3_);
				this._beginLoadCrops = 0;
			} else if (_loc3_ > 7) {
				EventRecorder.recordErrorEvent("160452", _loc3_, EventRecorder.TIME_OUT);
				this._beginLoadCrops = 0;
			}
		}
	}

	// FarmLandController.as:550-574
	private function onConfirmScarify(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = Reflect.field(param1.data, "callback");
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = Reflect.field(param1.data, "argument");
		if (_loc3_ == null) {
			return;
		}
		this.m_confirmScarifyArg = _loc3_;
		this.m_confirmScarifyCallback = _loc2_;
		var _loc4_:Dynamic = {
			"title": "铲除作物",
			"text": "作物还没有收获，真的要铲除吗？",
			"confirmFn": this.onConfirmScarifyOK
		};
		m_module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM, _loc4_);
	}

	// FarmLandController.as:576-623（原版 new Loader() 远程加载 redup swf，
	// 本部署已本地化 → shim/LocalSwfLoader（CLAUDE.md 加载器约定）；COMPLETE
	// 里原版的 arguments.callee 自移除用具名闭包等价）
	private function onPlayUpgradeRedLandAnimatin(param1:CommonEvent):Void {
		var redUpLoader:LocalSwfLoader;
		var url:String;
		var data:Dynamic;
		var e:CommonEvent = param1;
		if (e == null || e.data == null) {
			return;
		}
		data = e.data;
		if (Reflect.field(data, "black") == true && Reflect.hasField(data, "error")) {
			if (Reflect.field(data, "error") != "" && Reflect.hasField(data, "place")) {
				this.view.openLandFloatTip(Reflect.field(data, "error"), As3.intOf(Reflect.field(data, "place")));
			}
			return;
		}
		url = Settings.getInstance().getSecondUrl("redup");
		if (url == "") {
			return;
		}
		redUpLoader = new LocalSwfLoader();
		redUpLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(param1:Event):Void {
			var _loc2_:Int = Reflect.field(data, "red") == true ? 1 : 0;
			_loc2_ = Reflect.field(data, "black") == true ? 2 : _loc2_;
			var _loc3_:String = _loc2_ == 1 ? "红土地升级成功!" : "";
			_loc3_ = _loc2_ == 2 ? "黑土地升级成功!" : _loc3_;
			if (As3.truthy(Reflect.field(data, "gold"))) {
				_loc3_ = "金牌土地升级成功!";
			}
			openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
				"text": _loc3_,
				"parent": m_view.stage
			});
			model.updateLandData(As3.intOf(Reflect.field(data, "place")), As3.intOf(Reflect.field(data, "output")), As3.intOf(Reflect.field(data, "leavings")), As3.intOf(Reflect.field(data, "min")), _loc2_, As3.truthy(Reflect.field(data, "gold")) ? 1 : 0);
		});
		var onRedUpComplete:Event->Void = null; // arguments.callee 的具名等价
		onRedUpComplete = function(param1:Event):Void {
			param1.currentTarget.removeEventListener(Event.COMPLETE, onRedUpComplete);
			var _loc1d:Dynamic = param1.currentTarget.content;
			view.playUpgradeRed(As3.intOf(Reflect.field(data, "place")), Std.isOfType(_loc1d, Sprite) ? cast _loc1d : null, data);
		};
		redUpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onRedUpComplete);
		redUpLoader.load(new URLRequest(url), new LoaderContext(true));
	}

	// FarmLandController.as:625-641
	private function onShowLandCursor(param1:CommonEvent):Void {
		var _loc2_:CursorControl = null;
		this.view.showPickIcon(true, true);
		if (param1.result != null) {
			_loc2_ = m_module.app.farmView.cursorCtrl;
			if (_loc2_ != null && _loc2_.name == Consts.CURSOR_STYLE_HAND || _loc2_.name == Consts.CURSOR_STYLE_ONEHAND) {
				Reflect.setField(param1.result, "harvest", true);
			} else {
				this.view.loseMouse();
			}
		}
	}

	// FarmLandController.as:643-684
	private function onReclaimResult(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		var _loc3_:Player = Session.getInstance().host;
		var _loc4_:Int = Std.int(Math.sqrt((_loc3_._exp + 25) / 100) - 0.5); // AS3 int 收 Number 隐式截断
		var _loc5_:Float = _loc3_._money;
		var _loc6_:Int = As3.intOf(Reflect.field(_loc2_, "level")); // AS3 parseInt → int
		var _loc7_:Int = As3.intOf(Reflect.field(_loc2_, "money"));
		var _loc8_:String = "";
		if (_loc4_ < _loc6_ && _loc5_ < _loc7_) {
			_loc8_ = Reflect.field(Language.L, "对不起，您的金币和等级均不足。");
		} else if (_loc4_ < _loc6_) {
			_loc8_ = Reflect.field(Language.L, "对不起，您的等级不足。");
		} else if (_loc5_ < _loc7_) {
			_loc8_ = Reflect.field(Language.L, "对不起，您的金币不足。");
		}
		var _loc9_:Dynamic = {"level": _loc6_, "money": _loc7_};
		var _loc10_:String = Language.replaceText("reclaimPayText", _loc9_);
		var _loc11_:Dynamic = {
			"title": Reflect.field(Language.L, "扩建农场"),
			"text": _loc10_,
			"confirmFn": this.confirmReclaim
		};
		if (_loc8_ != "") {
			Reflect.setField(_loc11_, "confirmEnable", false);
			Reflect.setField(_loc11_, "error", _loc8_);
		}
		openWindow(Consts.WINDOW_NAME_CONFIRM, _loc11_);
	}

	// FarmLandController.as:686-701
	private function onGetLandData(param1:CommonEvent):Void {
		var _loc4_:Int = 0;
		var _loc2_:Array<Dynamic> = [];
		var _loc3_:FarmLand = null;
		while (_loc4_ < 24) {
			_loc3_ = this.model.getLandData(_loc4_);
			if (_loc3_ != null && _loc3_._cId > 0 && _loc3_._step < 6) {
				_loc2_.push(_loc3_._cId);
			}
			_loc4_++;
		}
		param1.result = _loc2_;
	}

	// FarmLandController.as:703-740（dogTip.effect = Move 是把类对象赋进动态
	// 字段；cacheAsBitmp 是原版拼写错误，照抄）
	private function onPopupTip(param1:CommonEvent = null):Void {
		var tip:String;
		var text:String;
		var dogTip:Dynamic;
		var e:CommonEvent = param1;
		if (e == null || e.data == null) {
			return;
		}
		var tipd:Dynamic = Reflect.field(e.data, "tip");
		tip = Std.isOfType(tipd, String) ? cast tipd : null;
		var textd:Dynamic = Reflect.field(e.data, "text");
		text = Std.isOfType(textd, String) ? cast textd : null;
		if (tip == "" || text == "") {
			return;
		}
		dogTip = Utils.getMaterial(tip);
		if (dogTip != null) {
			dogTip.effect = Move;
			dogTip.mouseChildren = false;
			dogTip.mouseEnabled = false;
			dogTip.cacheAsBitmp = true;
			if (Reflect.hasField(dogTip, "tipText")) {
				Reflect.field(dogTip, "tipText").htmlText = text;
			} else if (Reflect.hasField(dogTip, "txt")) {
				Reflect.field(dogTip, "txt").htmlText = text;
			}
			PopUpManager.addPopUp(dogTip);
			TweenLite.delayedCall(2, function():Void {
				PopUpManager.removePopUp(dogTip);
			});
		}
	}

	// FarmLandController.as:742-778（for-each 取数组元素值；AS3 关系比较把
	// String 操作数转 Number，from/to 可能是缺键（单小时配置无 "to"）→ NaN）
	private function isOneClickMode():Bool {
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:Array<String> = null;
		var _loc6_:String = null;
		var _loc7_:Dynamic = null;
		var _loc8_:Array<String> = null;
		// AS3 new Date() + setTime(毫秒) ≡ Date.fromTime
		var _loc1_:Date = Date.fromTime(CommonData.serverTime * 1000);
		var _loc2_:Int = _loc1_.getHours();
		var _loc3_:String = Settings.getInstance().getStringAttribute("batchStealHour");
		if (_loc3_ != "") {
			_loc4_ = [];
			_loc5_ = _loc3_.split(",");
			for (_loc6_ in _loc5_) {
				_loc8_ = _loc6_.split("-");
				_loc4_.push({"from": _loc8_[0], "to": _loc8_[1]});
			}
			for (_loc7_ in _loc4_) {
				if (_loc2_ >= As3.floatOf(Reflect.field(_loc7_, "from")) && _loc2_ < As3.floatOf(Reflect.field(_loc7_, "to"))) {
					return true;
				}
			}
		}
		if (_loc2_ >= 6 && _loc2_ < 10) {
			return true;
		}
		return false;
	}

	// FarmLandController.as:780-785
	private function onGameDataReloaded(param1:CommonEvent):Void {
		this.onStartupData(param1);
		this.view.hideTalkTip();
		this._beginLoadCrops = 0;
	}

	// FarmLandController.as:787-814
	private function onFarmLandChanged(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		if (_loc2_ < 0) {
			return;
		}
		var _loc3_:FarmLand = this.model.getLandData(_loc2_);
		if (_loc3_ == null) {
			return;
		}
		if (m_module.app != null && m_module.app.farmView != null) {
			m_module.app.farmView.tipCtrl.update(Consts.TIP_NAME_LAND_INFOR, _loc3_);
		}
		if (As3.truthy(m_module.app) && this.model.landIsFull()) {
			if (m_module.app.farmView.cursorCtrl.name == Consts.CURSOR_STYLE_CROPSEED) {
				m_module.app.dispatchEvent(new Event(Consts.CLOSE_MY_BAG));
			}
		}
	}

	// FarmLandController.as:816-830（原版第二个 guard `data == undefined` 在
	// AS3 里 undefined == null 为真，已被前一判空吞掉，恒死分支）
	private function onDigOutItems(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		m_module.app.openWindowByName(Consts.WINDOW_NAME_REGIFT, {
			"send": param1.data,
			"dig": true
		});
	}

	// FarmLandController.as:832-835
	private function showPickIcon(param1:CommonEvent):Void {
		this.view.showPickIcon(true);
	}

	// FarmLandController.as:837-863
	private function onPlaneWindowClicked(param1:MouseEvent):Void {
		var _loc3_:MovieClip = null;
		var _loc2d:Dynamic = Reflect.field(CommonData.root, "stage");
		var _loc2_:DisplayObjectContainer = Std.isOfType(_loc2d, DisplayObjectContainer) ? cast _loc2d : null;
		if (_loc2_ == null) {
			return;
		}
		if (param1.target.name == "btnOK") {
			this.model.callPlane();
		}
		if (param1.target.name == "btnClose" || param1.target.name == "btnOK") {
			var _loc3d:Dynamic = _loc2_.getChildByName("__plane__");
			_loc3_ = Std.isOfType(_loc3d, MovieClip) ? cast _loc3d : null;
			if (_loc3_ != null) {
				_loc2_.removeChild(_loc3_);
				var maskd:Dynamic = Reflect.field(_loc3_, "__mask__");
				if (maskd != null) {
					_loc2_.removeChild(maskd);
				}
				Reflect.setField(_loc3_, "__mask__", null);
				_loc3_ = null;
			}
		}
	}

	// FarmLandController.as:865-902
	private function registerListeners():Void {
		var _loc1_:IMsgCenter = m_module.app;
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_STARTUP_DATA, this.onStartupData, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_RELOAD_GAME_RESULT, this.onGameDataReloaded, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_PLAY_UPGRADE_RED_LAND, this.onPlayUpgradeRedLandAnimatin, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_HEALTHMODE_TIMEOUT, this.onHealthModeTimeout, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_WILD_BEAST_STEAL, this.onBeastSteal, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_WILD_TO_FARMSTAGE, this.showPickIcon, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_SET_LAND_CURSOR, this.onSetLandCursor, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_SET_QQBROWSER_ALARM, this.onSetQQBrowserAlarm, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_SHOW_LAND_CURSOR, this.onShowLandCursor, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_CALL_PLANE, this.onPlaneClicked, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_REFRESH_LANDS_DATA, this.onRefreshAllLands, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_GET_LAND_DATA, this.onGetLandData, false, 0, true);
			_loc1_.addEventListener(Consts.GOLD_LAND_UPDATE_TIME, this.onUpdateGoldLandTime, false, 0, true);
			_loc1_.addEventListener(Consts.GOLD_LAND_BUY_FAIL, this.onGoldLandUpdateFail, false, 0, true);
		}
		if (m_model != null) {
			m_model.addEventListener(FarmLandModel.EVENT_DIG_OUT_ITEMS, this.onDigOutItems, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_SHOW_TIP, this.onPopupTip, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_SHOW_GIFT_WINDOW, this.onGiftWindow, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_ALERT_WINDOW, this.onAlertWindow, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_CONFIRM_SCARIFY, this.onConfirmScarify, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_LAND_CHANGED, this.onFarmLandChanged, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_REFRESH_CROP_DATA, this.onCropDataChanged, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_REMOVE_MYBAG_ITEM, this.onMyBagDataRemoved, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_RECLAIM_CONDITION, this.onReclaimResult, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_RECLAIM_RESULT, this.onReclaimSuccess, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_HEALTH_MODE_PROTECTED, this.onHealthModeProtected, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_CHECK_TASK, this.onCheckTaskComplete, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_LEVELUP, this.onLevelUp, false, 0, true);
			m_model.addEventListener(FarmLandModel.EVENT_HARVEST_OVER, this.onHarvestOver, false, 0, true);
		}
	}

	// FarmLandController.as:904-910
	private function onLevelUp(param1:CommonEvent):Void {
		if (param1 != null && param1.data != null) {
			m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_LEVELUP, param1.data));
		}
	}

	// FarmLandController.as:912-915
	private function onRefreshAllLands(param1:CommonEvent):Void {
		this.model.reloadAllLands(true);
	}

	// FarmLandController.as:917-924
	private function onCheckTaskComplete(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		module.app.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_TASK, param1.data));
	}

	// FarmLandController.as:926-942
	private function onStartupData(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2d:Dynamic = param1.data;
		var _loc2_:StartupData = Std.isOfType(_loc2d, StartupData) ? cast _loc2d : null;
		if (_loc2_ == null) {
			return;
		}
		this.model.setUserFarmData(_loc2_._landStatus);
		if (param1.type == Consts.MSG_STARTUP_DATA) {
			this._beginLoadCrops = As3.getTimer();
		}
	}

	// FarmLandController.as:944-959
	override public function initialze():Void {
		if (m_model == null) {
			m_model = new FarmLandModel();
		}
		this.registerListeners();
		if (m_view == null) {
			m_view = new FarmLandsView(this);
			if (m_module != null && m_module.container != null) {
				m_module.container.addChild(m_view);
			}
		}
	}

	// FarmLandController.as:961-964
	private function onHealthModeProtected(param1:Event):Void {
		module.app.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_HEALTHMODE, {"sync": true}));
	}

	// FarmLandController.as:966-971
	private function onBeastSteal(param1:CommonEvent):Void {
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "farmIdx"));
		var _loc3_:Int = As3.intOf(Reflect.field(param1.data, "num"));
		this.model.beastSteal(_loc2_, _loc3_);
	}

	// FarmLandController.as:973-984（AS3 链式赋值拆开，Haxe 禁链式）
	public function switchMode(param1:Bool):Void {
		this.view.hideTalkTip();
		if (param1 == true) {
			this.view.scaleX = 1.3;
			this.view.scaleY = 1.3;
		} else {
			this.view.scaleX = 1;
			this.view.scaleY = 1;
		}
	}

	// FarmLandController.as:986-996
	private function onMyBagDataRemoved(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (m_module != null && m_module.app != null) {
			m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_DATA_REMOVE, param1.data));
		}
	}

	// FarmLandController.as:998-1030
	private function onHarvestOver(param1:Event):Void {
		var _loc7_:Dynamic = null;
		this.view.showPickIcon(true);
		var _loc2_:Session = Session.getInstance();
		var _loc3_:String = _loc2_.hostId;
		var _loc4_:FarmLand = null;
		var _loc5_:Bool = false;
		var _loc6_:Int = 0;
		while (_loc6_ < 24) {
			_loc4_ = this.model.getLandData(_loc6_);
			if (_loc4_ != null) {
				if (_loc4_._step == 5 && !(_loc2_.healthModeValid == true || _loc2_.currentFarmHealthModeValid == true)) {
					_loc7_ = _loc4_._thief;
					// AS3 Object.hasOwnProperty(uin) ≡ Reflect.hasField
					if (_loc7_ != null && Reflect.hasField(_loc7_, _loc3_) == false) {
						if (_loc4_._left > 0 && (_loc4_._left > _loc4_._min || _loc2_.me == true)) {
							_loc5_ = true;
						}
					}
				}
			}
			_loc6_++;
		}
		if (_loc5_ == false) {
			this.showWaterCursor();
		}
	}

	// FarmLandController.as:1032-1071
	private function onGiftWindow(param1:CommonEvent):Void {
		var _loc2_:Array<Dynamic> = null;
		var _loc3_:String = null;
		var _loc4_:String = null;
		if (param1 == null || param1.data == null || param1.data == "") {
			return;
		}
		Reflect.setField(param1.data, "big", true);
		if (Std.isOfType(param1.data, Array) && param1.data.length == 1 && Reflect.field(param1.data[0], "eType") == Consts.ITEM_TYPE_CARD) {
			m_module.app.openWindowByName(Consts.WINDOW_NAME_REGIFT_CARD, param1.data);
		} else {
			var _loc2d:Dynamic = Reflect.field(param1.data, "item");
			_loc2_ = Std.isOfType(_loc2d, Array) ? cast _loc2d : null;
			if (_loc2_ == null) {
				return;
			}
			if (Reflect.field(_loc2_[0], "eType") == "6" && (Reflect.field(_loc2_[0], "eNum") == "66" || Reflect.field(_loc2_[0], "eNum") == "666")) {
				Reflect.setField(param1.data, "title", "温馨提示");
				_loc3_ = Reflect.field(_loc2_[0], "eNum") + "金币";
				Reflect.setField(param1.data, "direction", "\n哇！幸运哦！！\n<font color=\"#FF0000\">获得奖励：</font ><font color=\"#FF0000\">" + _loc3_ + "</font>");
			} else {
				_loc4_ = "红土地";
				if (this.model.hasBlackLand == true) {
					_loc4_ = "红黑土地";
				}
				Reflect.setField(param1.data, "title", _loc4_ + "事件");
				Reflect.setField(param1.data, "direction", "\n哇！在" + _loc4_ + "上进行收获时发现了宝贝！" + _loc4_ + "不仅可以培育奇珍异草，珍贵名药，还有更多普通土地没有的幸运哦！！\n");
			}
			m_module.app.openWindowByName(Consts.WINDOW_NAME_GIFT, param1.data);
		}
	}
}
