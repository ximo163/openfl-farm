package module.mainScene.farmLand;

import com.qzone.qfa.events.CommandEvent;
import common.CommonData;
import common.Consts;
import common.FeartureManager;
import common.GetCropID;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import entities.FarmLand;
import entities.StartupData;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import report.EventRecorder;
import shim.As3;
import shim.QQOutlets;

// module.mainScene.farmLand.FarmLandModel —— FarmLandModel.as 逐句对应。
// PORT-NOTE: `x["k"] != undefined` → Reflect.field(x,"k") != null；
// hasOwnProperty → Reflect.hasField；`as int`/int() → Std.int；
// ExternalInterface.call → shim.QQOutlets.call（见 shim 头注释）；
// getTimer → shim.As3.getTimer（eval 上 openfl 的纪元溢出，见 shim/As3.hx）。
//
// 事件名常量（AS3 internal static const :29-73；V3a 先按「internal→private」
// 落位，V3b 的同包 FarmLandsView/FarmLandController 原版同样引用这些常量
// （Haxe 无包可见性），改 public——同 NPCModel.EVENT_DOG_LOADED 先例）；
// 构造器建 OperationQueue 监听（:110-111）。
@:access(module.mainScene.farmLand.FarmLandModel)
class FarmLandModel extends EventDispatcher {
	// FarmLandModel.as:29-73（EVENT_*，internal → public：同包跨类引用）
	public static final EVENT_INITIALZED:String = "DataInitialized";
	public static final EVENT_HARVEST_DATA:String = "HarvestData";
	public static final EVENT_ADD_HEALTH:String = "AddHealth";
	public static final EVENT_OPERATE_INVALID:String = "FarmLandOperateError";
	public static final EVENT_OPERATE_FAILED:String = "FarmLandOperateFailed";
	public static final EVENT_LAND_CHANGED:String = "FarmLandChanged";
	public static final EVENT_CONFIRM_SCARIFY:String = "ConfirmScarify";
	public static final EVENT_ALERT_WINDOW:String = "AlertWindow";
	public static final EVENT_SHOW_PICK_ICON:String = "ShowPickIcon";
	public static final EVENT_DIG_OUT_ITEMS:String = "DigItems";
	public static final EVENT_SHOW_TIP:String = "SendDogHitTip";
	public static final EVENT_SHOW_GIFT_WINDOW:String = "ShowBigGift";
	public static final EVENT_REFRESH_CROP_DATA:String = "RefreshCropData";
	public static final EVENT_REMOVE_MYBAG_ITEM:String = "UpdateMyBag";
	public static final EVENT_RECLAIM_CONDITION:String = "ReclaimCondition";
	public static final EVENT_RECLAIM_RESULT:String = "ReclaimResult";
	public static final EVENT_HEALTH_MODE_PROTECTED:String = "HealthModeProtectedNow";
	public static final EVENT_CHECK_TASK:String = "CheckTaskComplete";
	public static final EVENT_CHECK_STATUS:String = "CheckLandsStatus";
	public static final EVENT_FUNCTION_FORBIDDEN:String = "ScroungeForbid";
	public static final EVENT_LEVELUP:String = "LevelUp";
	public static final EVENT_HARVEST_OVER:String = "FinishHarvesting";
	public static final EVENT_PLAY_PLANE:String = "PlayPlanAnimation";

	// FarmLandModel.as:75-103 字段（public/private 原样；int 字段补 AS3 默认 0）
	public var tjShare:Array<Dynamic>;
	private var m_farmlandData:Array<Dynamic>;
	private var m_harvestAllFlag:Bool = false; // AS3 Boolean 默认值
	private var m_allFailedLost:Int = 0; // AS3 int 默认值
	private var m_reclaiming:Bool = false; // AS3 Boolean 默认值
	private var _refreshAllLands:Bool = false; // AS3 Boolean 默认值
	private var _refreshLands:Array<Dynamic>;
	private var m_harvestAllTimer:Timer;
	private var m_requestFreq:Dynamic;
	private var m_opQueue:OperationQueue;
	private var m_harvestRequesting:Bool = false; // AS3 Boolean 默认值
	private var m_showDogHitTipDelay:Int = 0; // AS3 int 默认值
	private var m_harvestAllArray:Array<Dynamic>;
	private var m_allFailedLostTimes:Int = 0; // AS3 int 默认值
	private var firstHelpExpFull:Bool = true;

	// FarmLandModel.as:105-121
	public function new(param1:IEventDispatcher = null) {
		super(param1);
		this.m_farmlandData = null;
		this.m_requestFreq = {};
		this.m_opQueue = new OperationQueue();
		this.m_opQueue.addEventListener(OperationQueue.EVENT_OPERATE_SUCCES, this.onDelayResponseSuccess);
		this.m_harvestRequesting = false;
		this.m_harvestAllFlag = false;
		this.m_allFailedLost = 0;
		this.m_allFailedLostTimes = 0;
		this.m_harvestAllTimer = null;
		this.m_harvestAllArray = null;
		this.m_showDogHitTipDelay = 0;
		this.m_reclaiming = false;
		this.tjShare = [];
	}

	// FarmLandModel.as:123-137
	public function reGetOutput():Void {
		var _loc2_:FarmLand = null;
		var _loc3_:Dynamic = null;
		var _loc1_:Int = 0;
		for (_loc2_ in (this.m_farmlandData:Array<Dynamic>)) {
			if (_loc2_._step == 5 && _loc2_._output == 0) {
				_loc3_ = this.buildCommonPostParams(Std.string(_loc1_));
				NetHelper.sendRequest(CommandDefs.CMD_GET_OUTPUT, _loc3_, this.onReGetOutput, this.onReGetOutputFail);
			}
			_loc1_++;
		}
	}

	// FarmLandModel.as:139-143
	public function getOutput(param1:Int):Void {
		var _loc2_:Dynamic = this.buildCommonPostParams(Std.string(param1));
		NetHelper.sendRequest(CommandDefs.CMD_GET_OUTPUT, _loc2_, this.onGetOutput, this.onGetOutputFail);
	}

	// FarmLandModel.as:145-153
	public var hasBlackLand(get, never):Bool;

	private function get_hasBlackLand():Bool {
		var _loc1_:FarmLand = this.getLandData(0);
		if (_loc1_ != null && _loc1_._bitmap == 2) {
			return true;
		}
		return false;
	}

	// FarmLandModel.as:155-171
	private function acceptHarvestGift(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:Array<Dynamic> = [];
		if (Reflect.hasField(param1, "item") == true) {
			_loc2_ = _loc2_.concat(Reflect.field(param1, "item"));
		}
		if (Reflect.hasField(param1, "vipItem") == true && Reflect.field(param1, "vipItem") != false) {
			_loc2_ = _loc2_.concat(Reflect.field(param1, "vipItem"));
		}
		Session.getInstance().addReward(_loc2_);
	}

	// FarmLandModel.as:173-231
	public function operate_harvestAll(param1:Int):Void {
		var _loc4_:Dynamic = null;
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return;
		}
		if (this.m_harvestRequesting == true) {
			return;
		}
		if (this.m_harvestAllFlag == true) {
			return;
		}
		var _loc2_:Array<Dynamic> = this.getHarvestPlaces();
		if (_loc2_ == null || _loc2_.length == 0) {
			this.showLandTip("当前农田没有作物可摘取！", param1);
			return;
		}
		if (Session.getInstance().checkHealthMode() == true) {
			return;
		}
		if (this.checkRequestFreq("harvest", 1) == false) {
			return;
		}
		this.m_harvestRequesting = true;
		var _loc3_:Dynamic = this.buildCommonPostParams(_loc2_.join(","));
		if (Session.getInstance().me == true) {
			EventRecorder.startARequest(EventRecorder.HF_HARVEST);
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_HARVEST, _loc3_, this.onHarvestAll, this.onNetError);
		} else {
			_loc4_ = FeartureManager.stealMod();
			if (_loc4_ != false) {
				this.alertWindow("tip", _loc4_);
				return;
			}
			_loc4_ = FeartureManager.stealOtherMod();
			if (_loc4_ != false) {
				this.alertWindow("tip", _loc4_);
				return;
			}
			if (FeartureManager.openByFlashVar()) {
				this.alertWindow("tip", Settings.getInstance().getStringAttribute("steal_tips_2"));
				return;
			}
			EventRecorder.startARequest(EventRecorder.HF_SCROUNGE);
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_SCROUNGE_NEW, _loc3_, this.onHarvestAllScrounge, this.onNetError);
		}
	}

	// FarmLandModel.as:233-247
	private function onOperateSuccessWater(param1:CommandEvent):Void {
		this.checkRequestFreq("water", -1);
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ != null) {
			this.farmChange(_loc2_, "humidity", 4);
			this.floatHandler(_loc2_);
			Session.getInstance().updateHostAccount(Reflect.field(_loc2_, "money"), Reflect.field(_loc2_, "exp"), 0);
			dispatchEvent(new CommonEvent(EVENT_LEVELUP, _loc2_));
			dispatchEvent(new CommonEvent(EVENT_CHECK_TASK, {"water": _loc2_}));
			this.recordResp(EventRecorder.HF_WATER, true, "mod=farmlandstatus&act=water");
			dispatchEvent(new Event(EVENT_CHECK_STATUS));
		}
	}

	// FarmLandModel.as:249-267
	private function onHarvestAllScrounge(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Bool = false;
		if (Std.isOfType(_loc2_, Array) && Reflect.hasField(_loc2_[0], "code") && Reflect.field(_loc2_[0], "code") == 1) {
			_loc3_ = true;
		} else if (Std.isOfType(_loc2_, Array) == false && Reflect.field(_loc2_, "code") == 1) {
			_loc3_ = true;
		}
		this.recordResp(EventRecorder.HF_SCROUNGE, _loc3_, "mod=farmlandstatus&act=scrounge");
		this.harvestAll(_loc2_);
	}

	// FarmLandModel.as:269-272
	private function onGetOutputFail(param1:CommandEvent):Void {
		EventRecorder.recordErrorEvent("160879", null, 4);
	}

	// FarmLandModel.as:274-298
	public function updateLandData(param1:Int, param2:Int, param3:Int, param4:Int, param5:Int, param6:Int):Void {
		var _loc7_:FarmLand = this.getLandData(param1);
		if (_loc7_ == null) {
			return;
		}
		if (param5 == 2 && param2 == 0 && param3 == 0) {
			this.getOutput(param1);
			return;
		}
		_loc7_._output = param2;
		_loc7_._left = param3;
		_loc7_._min = param4;
		if (param6 != 1) {
			_loc7_._bitmap = param5;
		}
		if (param6 >= 0) {
			_loc7_._goldLand = param6;
		}
		dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": param1}));
	}

	// FarmLandModel.as:300-326（mod 公共请求参数拼装 ownerId/place/tName/fName/fkey）
	private function buildCommonPostParams(param1:String):Dynamic {
		var _loc2_:Session = Session.getInstance();
		var _loc3_:UInt = 0;
		var _loc4_:String = "";
		if (_loc2_.currentUser != null) {
			_loc3_ = _loc2_.currentUser._uId;
			_loc4_ = _loc2_.currentUser._userName;
		}
		var _loc5_:String = "";
		if (_loc2_.host != null) {
			_loc5_ = _loc2_.host._userName;
		}
		var _loc6_:Dynamic = {
			"ownerId": _loc3_,
			"place": param1,
			"tName": _loc4_,
			"fName": _loc5_
		};
		if (_loc2_.friendKeys != null && Reflect.hasField(_loc2_.friendKeys, Std.string(_loc3_)) == true) {
			Reflect.setField(_loc6_, "fkey", Reflect.field(_loc2_.friendKeys, Std.string(_loc3_)));
		}
		return _loc6_;
	}

	// FarmLandModel.as:328-363
	public function operate_scarify(param1:Int):Void {
		var _loc3_:Dynamic = null;
		if (Session.getInstance().me == false) {
			return;
		}
		if (this.m_harvestAllFlag == true) {
			return;
		}
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return;
		}
		var _loc2_:FarmLand = this.m_farmlandData[param1];
		if (this.canHandler(param1, _loc2_) == false) {
			return;
		}
		if (_loc2_._step == 6 || _loc2_._step == 7) {
			this.executeScarify(param1, _loc2_._step);
		} else {
			_loc3_ = {
				"place": param1,
				"step": _loc2_._step
			};
			dispatchEvent(new CommonEvent(EVENT_CONFIRM_SCARIFY, {
				"callback": this.executeScarify,
				"argument": _loc3_
			}));
		}
	}

	// FarmLandModel.as:365-401
	private function onOperateSuccessSacrify(param1:CommandEvent):Void {
		var _loc3_:Int = 0;
		var _loc4_:FarmLand = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "farmlandIndex") != null) {
			_loc3_ = Std.int(Reflect.field(_loc2_, "farmlandIndex"));
			if (_loc3_ < 0 || _loc3_ >= this.m_farmlandData.length) {
				return;
			}
			_loc4_ = this.m_farmlandData[_loc3_];
			_loc4_._cId = 0;
			_loc4_._weed = 0;
			_loc4_._pest = 0;
			_loc4_._humidity = 1;
			_loc4_._cropStatus = 0;
			_loc4_._fertilize = false;
			_loc4_._step = 0;
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": _loc3_}));
		}
		if (Reflect.field(_loc2_, "randsend") != null) {
			dispatchEvent(new CommonEvent(EVENT_DIG_OUT_ITEMS, Reflect.field(_loc2_, "randsend")));
		}
		this.showPickIcon();
		this.recordResp(EventRecorder.HF_SCARIFY, true, "mod=farmlandstatus&act=scarify");
		Session.getInstance().updateHostAccount(Reflect.field(_loc2_, "money"), Reflect.field(_loc2_, "exp"), 0);
		dispatchEvent(new CommonEvent(EVENT_LEVELUP, _loc2_));
		dispatchEvent(new CommonEvent(EVENT_CHECK_TASK, {"scarify": _loc2_}));
		this.setQQBrowserAlarm();
	}

	// FarmLandModel.as:403-410
	private function delayShowDogHitTip(param1:String):Void {
		var _loc2_:String = "<font color=\"#369937\">【农场语录】<br>路边的野花不要采，别人的果实不要摘！</font><br>您在摘取过程中被<font color=\"#009900\"><b>"
			+ param1 + "</b></font>的狗发现<font color=\"#FF6600\"> <b>" + this.m_allFailedLostTimes
			+ "</b></font>次，在逃跑过程中总共丢失<font color=\"#FF6600\"> <b>" + this.m_allFailedLost + " </b> </font>金币。";
		dispatchEvent(new CommonEvent(EVENT_SHOW_TIP, {
			"tip": "DogTip",
			"text": _loc2_
		}));
	}

	// FarmLandModel.as:412-435
	private function onCallPlaneInGame(param1:CommandEvent):Void {
		var e:CommandEvent = param1;
		var onPaySuccess:Dynamic = function(param1:Dynamic):Void {
			dispatchEvent(new Event(EVENT_PLAY_PLANE));
		};
		var data:Dynamic = NetHelper.getVOData(e);
		if (data == null) {
			return;
		}
		if (Reflect.field(data, "ecode") == 0) {
			EventRecorder.recordSueecssEvent("160885", null);
			QzoneJSAPI.getInGamePay(Reflect.field(data, "url_params"), onPaySuccess);
		} else {
			EventRecorder.recordErrorEvent("160885", null, 4);
			this.alertWindow(Consts.ALERT_TYPE_ERROR, Reflect.field(data, "direction"));
		}
	}

	// FarmLandModel.as:437-455
	private function changeHarvestAllSequence():Void {
		var seq:Array<Int> = null;
		var order:Dynamic->Dynamic->Int = null;
		order = function(param1:Dynamic, param2:Dynamic):Int {
			if (Reflect.field(param1, "farmlandIndex") == null || Reflect.field(param2, "farmlandIndex") == null) {
				return 0;
			}
			return seq.indexOf(Reflect.field(param1, "farmlandIndex")) < seq.indexOf(Reflect.field(param2, "farmlandIndex")) ? -1 : 1;
		};
		if (this.m_harvestAllArray == null || this.m_harvestAllArray.length == 0) {
			return;
		}
		seq = [0, 3, 6, 9, 12, 15, 1, 4, 7, 10, 13, 16, 2, 5, 8, 11, 14, 17, 18, 19, 20, 21, 22, 23];
		this.m_harvestAllArray.sort(order);
	}

	// FarmLandModel.as:457-531
	// PORT-NOTE: RegExp → EReg。`/\d{1,9}/g` 的第二次 exec（lastIndex 续读）用
	// 「首次匹配后的剩余串再 match」复刻（Haxe EReg 无 g 标志）；ExternalInterface
	// → shim.QQOutlets（不通宿主时 call 返回 null，对应 exec 结果 null 提前 return）。
	public function setQQBrowserAlarm():Void {
		var _loc17_:Dynamic = null;
		var _loc18_:Int = 0;
		var _loc19_:Int = 0;
		var _loc20_:String = null;
		var _loc1_:String = QQOutlets.call("function BrowserAgent(){return navigator.userAgent;}");
		var _loc2_:EReg = new EReg("QQBrowser\\/\\d{1,9}.\\d{1,9}.", "");
		if (_loc1_ == null || _loc2_.match(_loc1_) == false) {
			return;
		}
		var _loc3_:String = _loc2_.matched(0);
		var _loc4_:EReg = new EReg("\\d{1,9}", "");
		var _loc5_:String = null;
		var _loc6_:String = null;
		if (_loc4_.match(_loc3_)) {
			_loc5_ = _loc4_.matched(0);
			var rest:String = _loc3_.substr(_loc4_.matchedPos().pos + _loc5_.length);
			if (_loc4_.match(rest)) {
				_loc6_ = _loc4_.matched(0);
			}
		}
		if (_loc5_ == null || _loc6_ == null) {
			return;
		}
		if (As3.intOf(_loc5_) > Consts.QQBROWSER_VER1 || As3.intOf(_loc5_) == Consts.QQBROWSER_VER1 && As3.intOf(_loc6_) >= Consts.QQBROWSER_VER2) {
			var _loc7_:String = "";
			var _loc8_:FarmLand = null;
			var _loc9_:Int = 0;
			var _loc10_:Int = 0;
			var _loc11_:Int = 0;
			var _loc12_:Int = this.m_farmlandData.length;
			var _loc13_:Array<Dynamic> = [];
			var _loc14_:Int = 0;
			while (_loc14_ < _loc12_) {
				_loc8_ = this.m_farmlandData[_loc14_];
				_loc11_ = Std.int(CommonData.serverTime - _loc8_._plantTime);
				_loc9_ = As3.intOf(GetCropID.cropTime(Std.string(_loc8_._cId)).split(",")[4]);
				if (_loc8_._bitmap == 2) {
					_loc18_ = Std.int(Math.floor(_loc9_ * 0.8));
					_loc19_ = _loc18_ % 600;
					if (_loc18_ > _loc19_) {
						_loc9_ = _loc18_ - _loc19_;
					} else {
						_loc9_ = _loc18_;
					}
				}
				_loc10_ = _loc9_ - _loc11_;
				if (!(_loc8_._cId <= 0 || _loc10_ <= 0)) {
					_loc17_ = {};
					Reflect.setField(_loc17_, "name", Reflect.field(Settings.getInstance().getCropByID(Std.string(_loc8_._cId)), "name"));
					Reflect.setField(_loc17_, "remain", _loc10_);
					_loc13_.push(_loc17_);
				}
				_loc14_++;
			}
			if (_loc13_.length <= 0) {
				_loc20_ = "var ret = window.external.delAlarm(1, " + Session.getInstance().host._uinLogin + ")";
				QQOutlets.call("eval", _loc20_);
				return;
			}
			_loc13_.sort(this.alarmTimeSort);
			_loc14_ = 0;
			while (_loc14_ < _loc13_.length) {
				_loc7_ += Reflect.field(_loc13_[_loc14_], "name") + ",";
				_loc7_ = _loc7_ + (Reflect.field(_loc13_[_loc14_], "remain") + ";");
				_loc14_++;
			}
			_loc7_ = _loc7_.substr(0, _loc7_.length - 1);
			var _loc15_:String = Settings.getInstance().mode == "qzone" ? "" : "http://apps.pengyou.com/353?adtag=applist_shouye";
			var _loc16_:String = "var ret = window.external.setAlarm(1, " + Session.getInstance().host._uinLogin + ", '"
				+ As3.or(Session.getInstance().host._userName, "农场玩家") + "', " + Reflect.field(_loc13_[0], "remain")
				+ ", '农场闹钟', '" + _loc7_ + "','" + _loc15_ + "')";
			QQOutlets.call("eval", _loc16_);
			return;
		}
	}

	// FarmLandModel.as:533-569
	public function operate_addBug(param1:Int):Void {
		var _loc3_:Dynamic = null;
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return;
		}
		var _loc2_:FarmLand = this.m_farmlandData[param1];
		if (this.canHandler(param1, _loc2_) == false) {
			return;
		}
		if (_loc2_._pest >= 3) {
			this.showLandTip("这块地无法放虫啦！", param1);
		} else if (_loc2_._step != 3 && _loc2_._step != 4) {
			this.showLandTip("作物这个阶段不会生虫！", param1);
		} else {
			if (this.checkRequestFreq("pest", 1) == false) {
				return;
			}
			if (Session.getInstance().host._canbad <= 0) {
				this.showLandTip("每天最多使坏50次哦。", param1);
				return;
			}
			_loc3_ = this.buildCommonPostParams(Std.string(param1));
			this.m_opQueue.delayRequest(OperationQueue.ADD_BUG, _loc3_);
			++_loc2_._pest;
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": param1}));
		}
	}

	// FarmLandModel.as:571-579
	public function beastSteal(param1:Int, param2:Int):Void {
		var _loc3_:FarmLand = this.m_farmlandData[param1];
		if (_loc3_ != null) {
			_loc3_._left -= param2;
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": param1}));
		}
	}

	// FarmLandModel.as:581-605
	public function operate_clearBug(param1:Int):Void {
		var _loc3_:Dynamic = null;
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return;
		}
		var _loc2_:FarmLand = this.m_farmlandData[param1];
		if (_loc2_._pest == 0) {
			this.showLandTip("这块地不需要除虫啦！", param1);
		} else if (_loc2_._pest > 0) {
			if (this.checkRequestFreq("spraying", 1) == false) {
				return;
			}
			_loc3_ = this.buildCommonPostParams(Std.string(param1));
			this.m_opQueue.delayRequest(OperationQueue.CLEAR_BUG, _loc3_);
			--_loc2_._pest;
			dispatchEvent(new CommonEvent(EVENT_ADD_HEALTH, {"index": param1}));
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": param1}));
		}
	}

	// FarmLandModel.as:607-614
	public function nextReclaimCondition():Void {
		if (this.m_reclaiming == false) {
			this.m_reclaiming = true;
			NetHelper.sendRequest(CommandDefs.CMD_RECLAIM_CONDITION, null, this.onReclaimConditionSuccess, this.onReclaimConditionFailed);
		}
	}

	// FarmLandModel.as:616-665
	private function floatHandler(param1:Dynamic):Void {
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		var _loc4_:Dynamic = null;
		var _loc5_:FarmLand = null;
		if (param1 == null) {
			return;
		}
		if (Reflect.hasField(param1, "direction") == true && Reflect.field(param1, "direction") != "") {
			if (Reflect.hasField(param1, "poptype") == true && Reflect.field(param1, "poptype") == 1) {
				_loc2_ = Std.int(Reflect.field(param1, "farmlandIndex"));
				if (Reflect.hasField(param1, "exp") && Reflect.field(param1, "exp") <= 0 && this.firstHelpExpFull
					&& (Reflect.hasField(param1, "pest") || Reflect.hasField(param1, "weed") || Reflect.hasField(param1, "humidity"))) {
					_loc3_ = 300;
					_loc4_ = Session.getInstance().myFairy;
					if (_loc4_ != null && Reflect.field(_loc4_, "itemId") == Consts.FAIRY_LADY) {
						_loc3_ = 600;
					}
					this.showLandTip("每天帮忙最多增加" + _loc3_ + "点经验,您已加满", _loc2_, -7);
					this.firstHelpExpFull = false;
				} else {
					this.showLandTip(Reflect.field(param1, "direction"), _loc2_);
				}
				if (Std.string(Reflect.field(param1, "direction")).indexOf("证据是不能") == 0) {
					_loc5_ = this.m_farmlandData[_loc2_];
					if (_loc5_ != null && Reflect.hasField(param1, "weed") == true) {
						_loc5_._weed = Reflect.field(param1, "weed");
					}
					if (_loc5_ != null && Reflect.hasField(param1, "pest") == true) {
						_loc5_._pest = Reflect.field(param1, "pest");
					}
					dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": _loc2_}));
				}
			}
		}
		if (Reflect.hasField(param1, "canbad") == true) {
			Session.getInstance().host._canbad = As3.intOf(Reflect.field(param1, "canbad"));
		}
	}

	// FarmLandModel.as:667-677
	private function onOperateSuccessAddBug(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this.checkRequestFreq("pest", -1);
		this.farmChange(param1, "pest", 1);
		this.floatHandler(param1);
		this.doBadFailed(param1);
	}

	// FarmLandModel.as:679-682
	private function showPickIcon():Void {
		dispatchEvent(new CommonEvent(EVENT_SHOW_PICK_ICON, null));
	}

	// FarmLandModel.as:684-703
	public function countNoneMatureLands():Int {
		var _loc5_:FarmLand = null;
		this._refreshLands = new Array();
		var _loc1_:Int = 0;
		var _loc2_:Int = 0;
		var _loc3_:Float = CommonData.serverTime;
		var _loc4_:Float = -1;
		for (_loc5_ in (this.m_farmlandData:Array<Dynamic>)) {
			if (_loc5_._cId > 0 && _loc5_._step < 5) {
				this._refreshLands.push(_loc2_);
				_loc4_ = GetCropID.timeToMature(_loc3_, _loc5_._cId, _loc5_._plantTime, _loc5_._bitmap);
				_loc1_ += Std.int(Math.ceil(_loc4_ / 3600));
			}
			_loc2_++;
		}
		return _loc1_;
	}

	// FarmLandModel.as:705-717
	private function canHandler(param1:Int, param2:FarmLand):Bool {
		if (param2 == null) {
			return false;
		}
		if (param2._cId == 0) {
			this.showLandTip("不可以对空地进行这个操作啦！", param1);
			return false;
		}
		return true;
	}

	// FarmLandModel.as:719-743
	public function growLoop():Void {
		var _loc3_:FarmLand = null;
		if (this.m_farmlandData == null) {
			return;
		}
		var _loc1_:Int = 0;
		var _loc2_:Int = 0;
		for (_loc3_ in (this.m_farmlandData:Array<Dynamic>)) {
			_loc2_ = GetCropID.idState(_loc3_._cId, _loc3_._plantTime, _loc3_._cropStatus, _loc3_._bitmap, _loc3_._harvestTimes);
			if (_loc2_ != _loc3_._step) {
				if (_loc2_ == 5) {
					this.getOutput(_loc1_);
				}
				_loc3_._step = _loc2_;
				_loc3_._fertilize = false;
				dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": _loc1_}));
			}
			_loc1_++;
		}
	}

	// FarmLandModel.as:745-770
	private function getHarvestPlaces():Array<Dynamic> {
		var _loc5_:FarmLand = null;
		var _loc6_:Dynamic = null;
		var _loc1_:Bool = Session.getInstance().me;
		var _loc2_:String = Session.getInstance().hostId;
		var _loc3_:Array<Dynamic> = [];
		var _loc4_:Int = 0;
		while (_loc4_ < this.m_farmlandData.length) {
			_loc5_ = this.m_farmlandData[_loc4_];
			if (_loc5_._step == 5) {
				_loc6_ = _loc5_._thief;
				if (_loc6_ != null && Reflect.hasField(_loc6_, _loc2_) == false) {
					if (_loc5_._left > 0 && (_loc5_._left > _loc5_._min || _loc1_ == true)) {
						_loc3_.push(_loc4_);
					}
				}
			}
			_loc4_++;
		}
		return _loc3_;
	}

	// FarmLandModel.as:772-792
	private function onCallPlanePreChecked(param1:CommandEvent):Void {
		var _loc3_:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "code") == 1) {
			_loc3_ = {
				"itemId": Reflect.field(Reflect.field(param1.body, "__body"), "itemId"),
				"itemNum": Reflect.field(Reflect.field(param1.body, "__body"), "itemNum"),
				"itemType": Reflect.field(Reflect.field(param1.body, "__body"), "itemType"),
				"payType": 1,
				"shopType": Reflect.field(Reflect.field(param1.body, "__body"), "shopType")
			};
			NetHelper.sendRequest(CommandDefs.CMD_BUY_INGAME_BUY, _loc3_, this.onCallPlaneInGame, this.onCallPlaneInGame);
			EventRecorder.recordSueecssEvent("160883", null);
		}
	}

	// FarmLandModel.as:794-850
	private function doBadFailed(param1:Dynamic):Void {
		var _loc2_:Dynamic = null;
		var _loc3_:String = null;
		var _loc4_:String = null;
		var _loc5_:Int = 0;
		var _loc6_:FarmLand = null;
		var _loc7_:String = null;
		if (param1 == null) {
			return;
		}
		if (Reflect.field(param1, "poptype") != null && Reflect.field(param1, "poptype") == 3) {
			if (Reflect.field(param1, "direction") == null) {
				return;
			}
			if (this.m_harvestAllFlag == true) {
				this.m_allFailedLost += Std.int(Math.abs(Reflect.field(param1, "money")));
				++this.m_allFailedLostTimes;
				if (Reflect.field(param1, "money") != null && Reflect.field(param1, "money") <= 0) {
					_loc2_ = {
						"money": Reflect.field(param1, "money"),
						"index": Reflect.field(param1, "farmlandIndex")
					};
					dispatchEvent(new CommonEvent(EVENT_OPERATE_FAILED, _loc2_));
				}
			} else {
				_loc3_ = As3.or(Session.getInstance().currentUser._userName, "他");
				_loc4_ = As3.or(Reflect.field(param1, "direction"), "");
				_loc4_ = _loc4_.split("他").join("<font color='#009900'><b>" + _loc3_ + "</b></font>");
				dispatchEvent(new CommonEvent(EVENT_SHOW_TIP, {
					"tip": "DogTip",
					"text": _loc4_
				}));
			}
			if (Reflect.field(param1, "farmlandIndex") != null) {
				_loc5_ = Std.int(Reflect.field(param1, "farmlandIndex"));
				if (_loc5_ >= 0 && _loc5_ < this.m_farmlandData.length) {
					_loc6_ = this.m_farmlandData[_loc5_];
					_loc7_ = Session.getInstance().hostId;
					if (_loc6_ != null) {
						Reflect.setField(_loc6_._thief, _loc7_, 1);
					}
				}
			}
			this.showPickIcon();
		}
	}

	// FarmLandModel.as:852-942
	private function harvest(param1:Dynamic):Void {
		var _loc3_:Int = 0;
		var _loc4_:FarmLand = null;
		var _loc5_:Dynamic = null;
		this.checkRequestFreq("harvest", -1);
		this.m_harvestRequesting = false;
		var _loc2_:Session = Session.getInstance();
		if (Reflect.field(param1, "status") != null) {
			_loc3_ = Std.int(Reflect.field(param1, "farmlandIndex"));
			if (_loc3_ < 0 || _loc3_ >= this.m_farmlandData.length) {
				return;
			}
			_loc4_ = this.m_farmlandData[_loc3_];
			if (_loc4_ == null) {
				return;
			}
			_loc4_.copyFrom(Reflect.field(param1, "status"));
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": _loc3_}));
			if (Reflect.field(param1, "harvest") > 0) {
				_loc5_ = {
					"text": Reflect.field(param1, "harvest"),
					"index": _loc3_,
					"cId": Reflect.field(Reflect.field(param1, "status"), "cId"),
					"plus": Reflect.field(param1, "plus")
				};
				dispatchEvent(new CommonEvent(EVENT_HARVEST_DATA, _loc5_));
				this.m_showDogHitTipDelay = 800;
			} else {
				this.showPickIcon();
			}
		}
		if (Reflect.field(param1, "fkey") != null) {
			_loc2_.updateCurrentFriendsKeys(Reflect.field(param1, "fkey"));
		}
		dispatchEvent(new Event(EVENT_REFRESH_CROP_DATA));
		if (Reflect.field(param1, "health") == 1) {
			dispatchEvent(new Event(EVENT_HEALTH_MODE_PROTECTED));
		} else {
			this.doBadFailed(param1);
		}
		_loc2_.updateHostAccount(Reflect.field(param1, "money"), Reflect.field(param1, "exp"), 0);
		dispatchEvent(new CommonEvent(EVENT_LEVELUP, param1));
		dispatchEvent(new CommonEvent(EVENT_CHECK_TASK, {"harvest": param1}));
		if (Reflect.field(param1, "gift") != null) {
			Reflect.setField(param1, "big", true);
			dispatchEvent(new CommonEvent(EVENT_SHOW_GIFT_WINDOW, Reflect.field(param1, "gift")));
			this.acceptHarvestGift(Reflect.field(param1, "gift"));
		}
		this.gainRandomGift(param1);
		if (Session.getInstance().me) {
			this.setQQBrowserAlarm();
		}
		if (Reflect.field(param1, "code") == 1 && this.m_harvestAllFlag == false) {
			dispatchEvent(new Event(EVENT_HARVEST_OVER));
		}
		if (Reflect.field(param1, "nsid") != null && Reflect.field(param1, "nsid") > 0) {
			this.tjShare.push({
				"type": 2,
				"id": Reflect.field(param1, "nsid")
			});
		} else if (Reflect.field(param1, "ncid") != null && Reflect.field(param1, "ncid") > 0) {
			this.tjShare.push({
				"type": 1,
				"id": Reflect.field(param1, "ncid")
			});
		} else if (Reflect.field(param1, "star3") != null && Reflect.field(param1, "star3") > 0) {
			this.tjShare.push({
				"type": 3,
				"id": Reflect.field(param1, "star3")
			});
		}
	}

	// FarmLandModel.as:944-1052
	private function onNetError(param1:CommandEvent):Void {
		var _loc4_:Int = 0;
		var _loc5_:FarmLand = null;
		var _loc6_:Float = Math.NaN;
		if (param1 == null) {
			return;
		}
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = Std.int(Reflect.field(param1.body, "cmdID"));
		if (_loc3_ == CommandDefs.CMD_OPERATE_WATER) {
			if (Reflect.hasField(_loc2_, "humidity") == true && Reflect.hasField(_loc2_, "farmlandIndex") == true) {
				_loc4_ = Std.int(Reflect.field(_loc2_, "farmlandIndex"));
				if (_loc4_ < 0 || _loc4_ >= this.m_farmlandData.length) {
					return;
				}
				_loc5_ = this.m_farmlandData[_loc4_];
				if (_loc5_ != null) {
					_loc5_._humidity = Reflect.field(_loc2_, "humidity");
					dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": _loc4_}));
				}
			}
			this.recordResp(EventRecorder.HF_WATER, false, "mod=farmlandstatus&act=water");
			QzoneJSAPI.reportError("浇水操作失败", 2);
		} else if (_loc3_ == CommandDefs.CMD_OPERATE_SCARIFY) {
			this.recordResp(EventRecorder.HF_SCARIFY, false, "mod=farmlandstatus&act=scarify");
			QzoneJSAPI.reportError("铲地操作失败", 2);
		} else if (_loc3_ == CommandDefs.CMD_OPERATE_PLANT) {
			this.recordResp(EventRecorder.HF_PLANTING, false, "mod=farmlandstatus&act=planting");
			QzoneJSAPI.reportError("种植操作失败", 2);
		} else if (_loc3_ == CommandDefs.CMD_OPERATE_FERTILIZE) {
			this.recordResp(EventRecorder.HF_FERTILIZE, false, "mod=farmlandstatus&act=fertilize");
			QzoneJSAPI.reportError("施肥操作失败", 2);
		} else if (_loc3_ == CommandDefs.CMD_OPERATE_HARVEST) {
			this.recordResp(EventRecorder.HF_HARVEST, false, "mod=farmlandstatus&act=harvest");
			this.harvestAll(_loc2_);
			QzoneJSAPI.reportError("收获操作失败", 2);
		} else if (_loc3_ == CommandDefs.CMD_OPERATE_SCROUNGE_NEW) {
			if (Reflect.hasField(_loc2_, "errorType") == true) {
				if (Reflect.field(_loc2_, "errorType") == "ErrFarmkey") {
					this.recordResp(EventRecorder.HF_SCROUNGE, false, "mod=farmlandstatus&act=scrounge", 11);
				} else if (Reflect.field(_loc2_, "errorType") == "ErrFarmTime") {
					this.recordResp(EventRecorder.HF_SCROUNGE, false, "mod=farmlandstatus&act=scrounge", 12);
					if (Reflect.field(_loc2_, "svrTime") != null) {
						_loc6_ = As3.floatOf(Reflect.field(_loc2_, "svrTime"));
						if (Math.isNaN(_loc6_) == false) {
							CommonData.serverTime = _loc6_;
							NetHelper.reSendRequest(null);
							return;
						}
					}
				}
			} else {
				this.recordResp(EventRecorder.HF_SCROUNGE, false, "mod=farmlandstatus&act=scrounge");
			}
			this.harvestAll(_loc2_);
			QzoneJSAPI.reportError("摘取操作失败", 2);
		} else {
			if (_loc3_ == CommandDefs.CMD_BUY_PRECHECK) {
				this.alertWindow(Consts.ALERT_TYPE_ERROR, Reflect.field(_loc2_, "direction"));
				EventRecorder.recordErrorEvent("160883", null, 4);
				return;
			}
			if (_loc3_ == CommandDefs.CMD_RECLAIM_PAY) {
				this.alertWindow(Consts.ALERT_TYPE_ERROR, Reflect.field(_loc2_, "direction"));
				EventRecorder.recordErrorEvent("160882", null, 4);
				return;
			}
			if (_loc3_ == CommandDefs.CMD_RELOAD_GAME_DATA) {
				EventRecorder.recordErrorEvent("160884", null, 4);
			}
		}
		if (Reflect.field(_loc2_, "errorType") == null || Reflect.field(_loc2_, "errorType") != null && Reflect.field(_loc2_, "errorType") != Consts.MSG_REQUEST_NET_CLIENT_ERROR) {
			this.floatHandler(_loc2_);
		}
	}

	// FarmLandModel.as:1054-1064
	private function alertWindow(param1:String, param2:String):Void {
		if (param1 == "" || param2 == "") {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_ALERT_WINDOW, {
			"type": param1,
			"text": param2
		}));
	}

	// FarmLandModel.as:1066-1071（初始化入口）
	public function setUserFarmData(param1:Array<Dynamic>):Void {
		this.m_farmlandData = param1;
		dispatchEvent(new CommonEvent(EVENT_INITIALZED, this.m_farmlandData));
		this.reGetOutput();
	}

	// FarmLandModel.as:1073-1091
	private function gainRandomGift(param1:Dynamic):Void {
		var _loc2_:String = null;
		if (Reflect.field(param1, "plus") != null && Reflect.field(param1, "money") != null && As3.intOf(Reflect.field(param1, "money")) != 0) {
			if (Reflect.field(param1, "money") > 0) {
				_loc2_ = "RedEventTipB";
			} else {
				_loc2_ = "RedEventTipA";
			}
			dispatchEvent(new CommonEvent(EVENT_SHOW_TIP, {
				"tip": _loc2_,
				"text": Reflect.field(param1, "plus")
			}));
		}
	}

	// FarmLandModel.as:1093-1156
	private function onReloadLandsSuccess(param1:CommandEvent):Void {
		var _loc2_:StartupData = cast NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (_loc2_._landStatus == null) {
			return;
		}
		var _loc3_:FarmLand = null;
		var _loc4_:Int = _loc2_._landStatus.length;
		var _loc5_:Int = this.m_farmlandData.length;
		var _loc6_:Int = -1;
		var _loc7_:Int = 0;
		if (this._refreshAllLands == true) {
			_loc7_ = 0;
			while (_loc7_ < _loc4_) {
				if (_loc7_ < _loc5_) {
					_loc3_ = _loc2_._landStatus[_loc7_];
					if (_loc3_ != null) {
						this.m_farmlandData[_loc7_] = _loc3_;
						dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {
							"index": _loc7_,
							"animation": false
						}));
					}
				}
				_loc7_++;
			}
			this._refreshAllLands = false;
		} else {
			if (this._refreshLands == null) {
				return;
			}
			_loc7_ = 0;
			while (_loc7_ < this._refreshLands.length) {
				_loc6_ = Std.int(this._refreshLands[_loc7_]);
				if (!(_loc6_ >= _loc4_ || _loc6_ >= _loc5_)) {
					_loc3_ = _loc2_._landStatus[_loc6_];
					if (_loc3_ != null) {
						this.m_farmlandData[_loc6_] = _loc3_;
						dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {
							"index": _loc6_,
							"animation": true
						}));
					}
				}
				_loc7_++;
			}
		}
		EventRecorder.recordSueecssEvent("160884", null);
	}

	// FarmLandModel.as:1158-1221
	private function onOperateSuccessPlant(param1:CommandEvent):Void {
		var _loc5_:Int = 0;
		var _loc6_:FarmLand = null;
		var _loc7_:Int = 0;
		var _loc8_:Dynamic = null;
		var _loc9_:Dynamic = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.hasField(_loc2_, "farmlandIndex") == true) {
			_loc5_ = Std.int(Reflect.field(_loc2_, "farmlandIndex"));
			_loc6_ = this.m_farmlandData[_loc5_];
			_loc6_._cId = Reflect.field(_loc2_, "cId");
			_loc6_._step = 0;
			_loc6_._plantTime = Std.int(CommonData.serverTime);
			_loc6_._harvestTimes = 0;
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": _loc5_}));
		}
		dispatchEvent(new CommonEvent(EVENT_REMOVE_MYBAG_ITEM, {
			"id": Reflect.field(_loc2_, "cId"),
			"type": As3.intOf(Consts.ITEM_TYPE_SEED)
		}));
		this.recordResp(EventRecorder.HF_PLANTING, true, "mod=farmlandstatus&act=planting");
		this.floatHandler(_loc2_);
		var _loc3_:Int = 0;
		var _loc4_:Session = Session.getInstance();
		if (Reflect.hasField(_loc2_, "exp") == true) {
			if (As3.intOf(Reflect.field(_loc2_, "exp")) > 0) {
				_loc3_ = As3.intOf(Reflect.field(_loc2_, "exp"));
				_loc4_.expFullToday = false;
			} else if (As3.intOf(Reflect.field(_loc2_, "exp")) == 0) {
				if (_loc4_.expFullToday == false) {
					_loc7_ = 150;
					_loc8_ = Session.getInstance().myFairy;
					if (_loc8_ != null && Reflect.field(_loc8_, "itemId") == Consts.FAIRY_LADY) {
						_loc7_ = 350;
					}
					_loc9_ = {
						"type": "tip",
						"title": "提示",
						"width": 390,
						"height": 250,
						"text": "您已经达到每天种植获得经验上限<font color='#ff0000'>" + _loc7_ + "点</font>，今天以内您将无法通过种植获得经验。"
					};
					dispatchEvent(new CommonEvent(EVENT_ALERT_WINDOW, _loc9_));
					_loc4_.expFullToday = true;
				}
			}
		}
		_loc4_.updateHostAccount(Reflect.field(_loc2_, "money"), _loc3_, 0);
		dispatchEvent(new CommonEvent(EVENT_LEVELUP, _loc2_));
		dispatchEvent(new CommonEvent(EVENT_CHECK_TASK, {"planting": _loc2_}));
		this.setQQBrowserAlarm();
	}

	// FarmLandModel.as:1223-1260
	private function harvestAll(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this.m_harvestRequesting = false;
		this.m_harvestAllFlag = false;
		if (Reflect.field(param1, "code") != 0) {
			if (Std.isOfType(param1, Array) && param1.length > 1) {
				this.m_harvestAllFlag = true;
				Session.getInstance().harvestAnimationPlaying = true;
				this.m_allFailedLost = 0;
				this.m_allFailedLostTimes = 0;
				this.m_showDogHitTipDelay = 200;
				this.m_harvestAllArray = param1;
				this.changeHarvestAllSequence();
				this.onHarvestAllTimer(null);
				if (this.m_harvestAllTimer == null) {
					this.m_harvestAllTimer = new Timer(400);
					this.m_harvestAllTimer.addEventListener(TimerEvent.TIMER, this.onHarvestAllTimer);
				}
				this.m_harvestAllTimer.reset();
				this.m_harvestAllTimer.start();
			} else {
				this.harvest(param1);
			}
		} else {
			this.harvest(param1);
		}
	}

	// FarmLandModel.as:1262-1298
	public function operate_addWeed(param1:Int):Void {
		var _loc3_:Dynamic = null;
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return;
		}
		var _loc2_:FarmLand = this.m_farmlandData[param1];
		if (this.canHandler(param1, _loc2_) == false) {
			return;
		}
		if (_loc2_._weed >= 3) {
			this.showLandTip("这块地无法种草啦！", param1);
		} else if (_loc2_._step >= 5) {
			this.showLandTip("作物这个阶段不会长草！", param1);
		} else {
			if (this.checkRequestFreq("scatterWeed", 1) == false) {
				return;
			}
			if (Session.getInstance().host._canbad <= 0) {
				this.showLandTip("每天最多使坏50次哦。", param1);
				return;
			}
			_loc3_ = this.buildCommonPostParams(Std.string(param1));
			this.m_opQueue.delayRequest(OperationQueue.ADD_WEED, _loc3_);
			++_loc2_._weed;
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": param1}));
		}
	}

	// FarmLandModel.as:1300-1303
	private function onReGetOutputFail(param1:CommandEvent):Void {
		EventRecorder.recordErrorEvent("160880", null, 4);
	}

	// FarmLandModel.as:1305-1312（QQ 浏览器闹钟排序比较器，remain 升序）
	private function alarmTimeSort(param1:Dynamic, param2:Dynamic):Int {
		if (param1 == null || param2 == null) {
			return 0;
		}
		return Reflect.field(param1, "remain") > Reflect.field(param2, "remain") ? 1 : -1;
	}

	// FarmLandModel.as:1314-1339。原版 bug 照抄：桶键是字面量 "type" 而不是
	// param1，导致 param1 != "type" 时每次调用都重置桶（num 永远到不了 >1 的
	// 频控门槛）——测试按原版行为钉死，不许修。
	private function checkRequestFreq(param1:String, param2:Int):Bool {
		if (param1 == "" || param2 == 0) {
			return false;
		}
		if (Reflect.hasField(this.m_requestFreq, param1) == false) {
			Reflect.setField(this.m_requestFreq, "type", {
				"num": 0,
				"time": As3.getTimer()
			});
		}
		if (param2 > 0 && Reflect.field(Reflect.field(this.m_requestFreq, "type"), "num") > 1) {
			if (As3.getTimer() - Reflect.field(Reflect.field(this.m_requestFreq, "type"), "time") < 10000) {
				Reflect.setField(Reflect.field(this.m_requestFreq, "type"), "time", As3.getTimer());
				return false;
			}
			Reflect.setField(Reflect.field(this.m_requestFreq, "type"), "num", 0);
		}
		Reflect.setField(Reflect.field(this.m_requestFreq, "type"), "num", Reflect.field(Reflect.field(this.m_requestFreq, "type"), "num") + param2);
		Reflect.setField(Reflect.field(this.m_requestFreq, "type"), "time", As3.getTimer());
		return true;
	}

	// FarmLandModel.as:1341-1350
	public function reloadAllLands(param1:Bool):Void {
		var _loc2_:Dynamic = {
			"ownerId": 0,
			"flag": "1"
		};
		this._refreshAllLands = param1;
		this._refreshLands = null;
		NetHelper.sendRequest(CommandDefs.CMD_RELOAD_GAME_DATA, _loc2_, this.onReloadLandsSuccess, this.onNetError);
	}

	// FarmLandModel.as:1352-1355
	public function reclaimNewLand():Void {
		NetHelper.sendRequest(CommandDefs.CMD_RECLAIM_PAY, null, this.onReclaimSuccess, this.onNetError);
	}

	// FarmLandModel.as:1357-1444（poptype==1 使坏失败回滚；pest 分支里减错到
	// _weed 的原版写法照抄，见 :1429）
	private function farmChange(param1:Dynamic, param2:String, param3:Int = 0):Void {
		var _loc6_:Int = 0;
		var _loc7_:String = null;
		var _loc8_:Array<Dynamic> = null;
		if (param1 == null) {
			return;
		}
		var _loc4_:Int = Std.int(Reflect.field(param1, "farmlandIndex"));
		if (_loc4_ < 0 || _loc4_ >= this.m_farmlandData.length) {
			return;
		}
		var _loc5_:FarmLand = this.m_farmlandData[_loc4_];
		if (_loc5_ == null) {
			return;
		}
		if (Reflect.hasField(param1, param2) == true) {
			_loc6_ = -1;
			if (param2 == "humidity") {
				_loc6_ = _loc5_._humidity;
			} else if (param2 == "weed") {
				_loc6_ = _loc5_._weed;
			} else if (param2 == "pest") {
				_loc6_ = _loc5_._pest;
			}
			if (_loc6_ != Reflect.field(param1, param2)) {
				if (Reflect.field(param1, "code") == 1) {
					if (param3 != 0) {
						if (Std.isOfType(_loc5_._action, Array)) {
							_loc5_._action = {};
						}
						_loc7_ = Std.string(CommonData.serverTime);
						_loc8_ = [];
						_loc8_.push(param3);
						Reflect.setField(_loc5_._action, _loc7_, _loc8_);
					}
				}
				if (Reflect.hasField(param1, "humidity") == true) {
					_loc5_._humidity = Reflect.field(param1, "humidity");
				}
				if (Reflect.hasField(param1, "weed") == true) {
					_loc5_._weed = Reflect.field(param1, "weed");
				}
				if (Reflect.hasField(param1, "pest") == true) {
					_loc5_._pest = Reflect.field(param1, "pest");
				}
				dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": _loc4_}));
			}
		} else if (Reflect.hasField(param1, "poptype") == true && Reflect.field(param1, "poptype") == 1 && Reflect.hasField(param1, "direction") == true
				&& Std.string(Reflect.field(param1, "direction")).indexOf("最多使坏") != -1) {
			if (param2 == "pest" && param3 == 1) {
				--_loc5_._pest;
				if (Reflect.hasField(param1, "error_repeat") == true) {
					_loc5_._weed -= Std.int(Reflect.field(param1, "error_repeat"));
				}
				_loc5_._pest = Std.int(Math.max(0, _loc5_._pest));
			} else if (param2 == "weed" && param3 == 2) {
				--_loc5_._weed;
				if (Reflect.hasField(param1, "error_repeat") == true) {
					_loc5_._weed -= Std.int(Reflect.field(param1, "error_repeat"));
				}
				_loc5_._weed = Std.int(Math.max(0, _loc5_._weed));
			}
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": _loc4_}));
		}
	}

	// FarmLandModel.as:1446-1452
	private function onReclaimConditionSuccess(param1:CommandEvent):Void {
		this.m_reclaiming = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		dispatchEvent(new CommonEvent(EVENT_RECLAIM_CONDITION, _loc2_));
		EventRecorder.recordSueecssEvent("160881", null);
	}

	// FarmLandModel.as:1454-1463
	private function onReclaimSuccess(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		dispatchEvent(new CommonEvent(EVENT_RECLAIM_RESULT, _loc2_));
		EventRecorder.recordSueecssEvent("160882", null);
	}

	// FarmLandModel.as:1465-1475
	public function resetLoadingFlags():Void {
		if (this.m_harvestRequesting == true) {
			this.m_harvestRequesting = false;
		}
		if (this.m_reclaiming == true) {
			this.m_reclaiming = false;
		}
	}

	// FarmLandModel.as:1477-1503
	public function operate_water(param1:Int):Void {
		var _loc3_:Dynamic = null;
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return;
		}
		var _loc2_:FarmLand = this.m_farmlandData[param1];
		if (this.canHandler(param1, _loc2_) == false) {
			return;
		}
		if (_loc2_._humidity == 1) {
			this.showLandTip("这块地不需要浇水啦！", param1);
		} else {
			if (this.checkRequestFreq("water", 1) == false) {
				return;
			}
			EventRecorder.startARequest(EventRecorder.HF_WATER);
			_loc3_ = this.buildCommonPostParams(Std.string(param1));
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_WATER, _loc3_, this.onOperateSuccessWater, this.onNetError);
		}
	}

	// FarmLandModel.as:1505-1515
	public function callPlane():Void {
		var _loc1_:Int = this.countNoneMatureLands();
		var _loc2_:Dynamic = {
			"shopType": Consts.ITEM_TYPE_PLANE,
			"itemType": Consts.ITEM_TYPE_PLANE,
			"itemId": 1,
			"itemNum": _loc1_
		};
		NetHelper.sendRequest(CommandDefs.CMD_BUY_PRECHECK, _loc2_, this.onCallPlanePreChecked, this.onNetError);
	}

	// FarmLandModel.as:1517-1532
	public var isAllGoldLand(get, never):Int;

	private function get_isAllGoldLand():Int {
		var _loc1_:FarmLand = null;
		// PORT-NOTE(AS3→Haxe)：原版 for each 的循环变量是编译期 FarmLand，
		// `_loc1_._goldLand` 必调计算属性 getter（FarmLand.as:225-245 金地判定
		// 依赖 Settings 的 jinPaiLand 活动窗口）；从 Array<Dynamic> 迭代出的元素
		// 是 Dynamic，直读不触发 getter（eval 得 null→恒判非金地），故先把数组按
		// Array<FarmLand> 取回再迭代。for each 对 null 数组零次迭代，Haxe 迭代
		// null 会抛 Null Access，需显式判空。
		if (this.m_farmlandData != null) {
			var typed:Array<FarmLand> = cast this.m_farmlandData;
			for (_loc1_ in typed) {
				if (_loc1_._goldLand != 1) {
					return 2;
				}
			}
		}
		if (As3.truthy(this.m_farmlandData) && this.m_farmlandData.length < 24) {
			return 1;
		}
		return 3;
	}

	// FarmLandModel.as:1534-1545
	public function landIsFull():Bool {
		var _loc1_:FarmLand = null;
		for (_loc1_ in (this.m_farmlandData:Array<Dynamic>)) {
			if (!As3.truthy(_loc1_) || !As3.truthy(_loc1_._cId)) {
				return false;
			}
		}
		return true;
	}

	// FarmLandModel.as:1547-1559
	private function onOperateSuccessClearBug(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this.checkRequestFreq("spraying", -1);
		this.farmChange(param1, "pest", 5);
		this.floatHandler(param1);
		Session.getInstance().updateHostAccount(Reflect.field(param1, "money"), Reflect.field(param1, "exp"), 0);
		dispatchEvent(new CommonEvent(EVENT_LEVELUP, param1));
		dispatchEvent(new CommonEvent(EVENT_CHECK_TASK, {"spraying": param1}));
	}

	// FarmLandModel.as:1561-1571
	private function executeScarify(param1:Int, param2:Int):Void {
		var _loc3_:Dynamic = this.buildCommonPostParams(Std.string(param1));
		if (_loc3_ == null) {
			return;
		}
		Reflect.setField(_loc3_, "cropStatus", param2);
		EventRecorder.startARequest(EventRecorder.HF_SCARIFY);
		NetHelper.sendRequest(CommandDefs.CMD_OPERATE_SCARIFY, _loc3_, this.onOperateSuccessSacrify, this.onNetError);
	}

	// FarmLandModel.as:1573-1584
	public function getLandData(param1:Int):FarmLand {
		if (this.m_farmlandData == null) {
			return null;
		}
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return null;
		}
		return this.m_farmlandData[param1];
	}

	// FarmLandModel.as:1586-1645
	public function operate_harvest(param1:Int):Void {
		var _loc4_:Dynamic = null;
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return;
		}
		if (this.m_harvestAllFlag == true) {
			return;
		}
		if (Session.getInstance().checkHealthMode() == true) {
			return;
		}
		var _loc2_:FarmLand = this.m_farmlandData[param1];
		if (this.canHandler(param1, _loc2_) == false) {
			return;
		}
		if (this.canHavest(param1, _loc2_) == false) {
			return;
		}
		if (this.checkRequestFreq("harvest", 1) == false) {
			return;
		}
		this.m_harvestRequesting = true;
		var _loc3_:Dynamic = null;
		if (Session.getInstance().me == true) {
			EventRecorder.startARequest(EventRecorder.HF_HARVEST);
			_loc3_ = this.buildCommonPostParams(Std.string(param1));
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_HARVEST, _loc3_, this.onHarvestAll, this.onNetError);
		} else {
			_loc4_ = FeartureManager.stealMod();
			if (_loc4_ != false) {
				this.alertWindow("tip", _loc4_);
				return;
			}
			_loc4_ = FeartureManager.stealOtherMod();
			if (_loc4_ != false) {
				this.alertWindow("tip", _loc4_);
				return;
			}
			if (FeartureManager.openByFlashVar()) {
				this.alertWindow("tip", Settings.getInstance().getStringAttribute("steal_tips_2"));
				return;
			}
			EventRecorder.startARequest(EventRecorder.HF_SCROUNGE);
			_loc3_ = this.buildCommonPostParams(Std.string(param1));
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_SCROUNGE_NEW, _loc3_, this.onHarvestAllScrounge, this.onNetError);
		}
	}

	// FarmLandModel.as:1647-1657
	private function onOperateSuccessAddWeed(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this.checkRequestFreq("scatterWeed", -1);
		this.farmChange(param1, "weed", 2);
		this.floatHandler(param1);
		this.doBadFailed(param1);
	}

	// FarmLandModel.as:1659-1688
	private function onOperateSuccessFertilize(param1:CommandEvent):Void {
		var _loc3_:Int = 0;
		var _loc4_:FarmLand = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.hasField(_loc2_, "farmlandIndex") == true) {
			_loc3_ = Std.int(Reflect.field(_loc2_, "farmlandIndex"));
			_loc4_ = this.m_farmlandData[_loc3_];
			if (_loc4_ != null) {
				_loc4_.copyFrom(Reflect.field(_loc2_, "status"));
				dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {
					"index": _loc3_,
					"fertilize": true
				}));
			}
		}
		dispatchEvent(new CommonEvent(EVENT_REMOVE_MYBAG_ITEM, {
			"id": Reflect.field(_loc2_, "tId"),
			"type": As3.intOf(Consts.ITEM_TYPE_TOOL)
		}));
		this.recordResp(EventRecorder.HF_FERTILIZE, true, "mod=farmlandstatus&act=fertilize");
		Session.getInstance().updateHostAccount(Reflect.field(_loc2_, "money"), Reflect.field(_loc2_, "exp"), 0);
		this.setQQBrowserAlarm();
	}

	// FarmLandModel.as:1690-1711
	private function onReGetOutput(param1:CommandEvent):Void {
		var _loc3_:Int = 0;
		var _loc4_:FarmLand = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "farmlandIndex") != null) {
			_loc3_ = Std.int(Reflect.field(_loc2_, "farmlandIndex"));
			_loc4_ = this.m_farmlandData[_loc3_];
			if (_loc4_ == null) {
				return;
			}
			_loc4_.copyFrom(Reflect.field(_loc2_, "status"));
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": _loc3_}));
			EventRecorder.recordSueecssEvent("160880", null);
		}
	}

	// FarmLandModel.as:1713-1764
	public function operate_fertilize(param1:Int, param2:Int):Void {
		var _loc5_:Dynamic = null;
		if (Session.getInstance().me == false) {
			return;
		}
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return;
		}
		if (param2 <= 0) {
			return;
		}
		var _loc3_:FarmLand = this.m_farmlandData[param1];
		if (this.canHandler(param1, _loc3_) == false) {
			return;
		}
		if (_loc3_._step == 5 || _loc3_._step == 6 || _loc3_._step == 7) {
			this.showLandTip("作物这个阶段不需要施肥。", param1);
			return;
		}
		if (param2 < Consts.ORGANIC_FERTILIZER_ID) {
			if (_loc3_._fertilize == true) {
				this.showLandTip("施过肥了，下个阶段再施吧。", param1);
				return;
			}
			_loc5_ = Settings.getInstance().getCropByID(Std.string(_loc3_._cId));
			if (_loc5_ != null && Reflect.field(_loc5_, "isYouji") == 1) {
				this.showLandTip("有机种子只能浇有机肥哦~", param1);
				return;
			}
		} else if (_loc3_._cId <= 0) {
			return;
		}
		var _loc4_:Dynamic = this.buildCommonPostParams(Std.string(param1));
		if (_loc4_ == null) {
			return;
		}
		Reflect.setField(_loc4_, "tId", param2);
		EventRecorder.startARequest(EventRecorder.HF_FERTILIZE);
		NetHelper.sendRequest(CommandDefs.CMD_OPERATE_FERTILIZE, _loc4_, this.onOperateSuccessFertilize, this.onNetError);
	}

	// FarmLandModel.as:1766-1780
	private function onHarvestAll(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Bool = false;
		if (Reflect.field(_loc2_, "code") == 1 || Std.isOfType(_loc2_, Array) && Reflect.hasField(_loc2_[0], "code") && Reflect.field(_loc2_[0], "code") == 1) {
			_loc3_ = true;
		}
		this.recordResp(EventRecorder.HF_HARVEST, _loc3_, "mod=farmlandstatus&act=harvest");
		this.harvestAll(_loc2_);
	}

	// FarmLandModel.as:1782-1823
	private function canHavest(param1:Int, param2:FarmLand):Bool {
		var _loc3_:Dynamic = null;
		var _loc4_:String = null;
		if (Session.getInstance().me == true) {
			if (param2._step == 5) {
				return true;
			}
			this.showLandTip("这块地没东西可收获！", param1);
		} else if (param2._step != 5) {
			this.showLandTip("这块地没东西可偷！", param1);
		} else {
			_loc3_ = param2._thief;
			_loc4_ = Session.getInstance().hostId;
			if (_loc3_ != null && Reflect.hasField(_loc3_, _loc4_) == true) {
				if (Reflect.field(_loc3_, _loc4_) == 0) {
					this.showLandTip("狗盯上了您，别做坏事了。", param1);
				} else {
					this.showLandTip("做人不能贪得无厌！", param1);
				}
			} else {
				if (!(param2._left != 0 && param2._left <= param2._min)) {
					return true;
				}
				this.showLandTip("行行好吧，我所剩无几了！", param1);
			}
		}
		return false;
	}

	// FarmLandModel.as:1825-1837
	public function hasLandToScarify():Bool {
		var _loc2_:FarmLand = null;
		var _loc1_:Bool = Session.getInstance().me;
		for (_loc2_ in (this.m_farmlandData:Array<Dynamic>)) {
			if ((_loc2_._step == 6 || _loc2_._step == 7) && _loc1_ == true) {
				return true;
			}
		}
		return false;
	}

	// FarmLandModel.as:1839-1857
	private function recordResp(param1:String, param2:Bool, param3:String, param4:Int = 0):Void {
		if (param1 == "") {
			return;
		}
		if (param2 == true) {
			EventRecorder.recordSueecssEvent(param1, null, param3);
		} else if (param4 == 0) {
			EventRecorder.recordErrorEvent(param1, null, EventRecorder.FAULT_ERROR, param3);
		} else {
			EventRecorder.recordErrorEvent(param1, null, param4, param3);
		}
	}

	// FarmLandModel.as:1859-1862
	public var refreshLands(get, never):Array<Dynamic>;

	private function get_refreshLands():Array<Dynamic> {
		return this._refreshLands;
	}

	// FarmLandModel.as:1864-1900
	private function onHarvestAllTimer(param1:TimerEvent):Void {
		var _loc3_:String = null;
		if (this.m_harvestAllArray == null) {
			if (this.m_harvestAllTimer != null) {
				this.m_harvestAllTimer.stop();
			}
			this.m_harvestAllFlag = false;
			return;
		}
		var _loc2_:Dynamic = null;
		if (this.m_harvestAllArray.length > 0) {
			_loc2_ = this.m_harvestAllArray.shift();
		}
		if (_loc2_ != null) {
			this.harvest(_loc2_);
		}
		if (this.m_harvestAllArray.length == 0) {
			if (this.m_harvestAllTimer != null) {
				this.m_harvestAllTimer.stop();
			}
			this.m_harvestAllFlag = false;
			if (this.m_allFailedLostTimes > 0) {
				_loc3_ = As3.or(Session.getInstance().currentUser._userName, "TA");
				As3.setTimeout(this.delayShowDogHitTip.bind(_loc3_), this.m_showDogHitTipDelay);
			}
			Session.getInstance().harvestAnimationPlaying = false;
			dispatchEvent(new Event(EVENT_HARVEST_OVER));
		}
	}

	// FarmLandModel.as:1902-1906
	private function onReclaimConditionFailed(param1:CommandEvent):Void {
		this.m_reclaiming = false;
		EventRecorder.recordErrorEvent("160881", null, 4);
	}

	// FarmLandModel.as:1908-1934
	private function onGetOutput(param1:CommandEvent):Void {
		var _loc3_:Int = 0;
		var _loc4_:FarmLand = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Reflect.field(_loc2_, "farmlandIndex") != null) {
			_loc3_ = Std.int(Reflect.field(_loc2_, "farmlandIndex"));
			if (_loc3_ < 0 || _loc3_ >= this.m_farmlandData.length) {
				return;
			}
			_loc4_ = this.m_farmlandData[_loc3_];
			if (_loc4_ == null) {
				return;
			}
			_loc4_.copyFrom(Reflect.field(_loc2_, "status"));
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": _loc3_}));
			this.reGetOutput();
			EventRecorder.recordSueecssEvent("160879", null);
		}
	}

	// FarmLandModel.as:1936-1960
	public function operate_clearWeed(param1:Int):Void {
		var _loc3_:Dynamic = null;
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return;
		}
		var _loc2_:FarmLand = this.m_farmlandData[param1];
		if (_loc2_._weed == 0) {
			this.showLandTip("这块地不需要除草啦！", param1);
		} else if (_loc2_._weed > 0) {
			if (this.checkRequestFreq("clearWeed", 1) == false) {
				return;
			}
			_loc3_ = this.buildCommonPostParams(Std.string(param1));
			this.m_opQueue.delayRequest(OperationQueue.CLEAR_WEED, _loc3_);
			--_loc2_._weed;
			dispatchEvent(new CommonEvent(EVENT_ADD_HEALTH, {"index": param1}));
			dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED, {"index": param1}));
		}
	}

	// FarmLandModel.as:1962-1974
	private function onOperateSuccessClearWeed(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this.checkRequestFreq("clearWeed", -1);
		this.farmChange(param1, "weed", 6);
		this.floatHandler(param1);
		Session.getInstance().updateHostAccount(Reflect.field(param1, "money"), Reflect.field(param1, "exp"), 0);
		dispatchEvent(new CommonEvent(EVENT_LEVELUP, param1));
		dispatchEvent(new CommonEvent(EVENT_CHECK_TASK, {"clearWeed": param1}));
	}

	// FarmLandModel.as:1976-2007
	public function operate_plant(param1:Int, param2:Int):Void {
		var _loc4_:Dynamic = null;
		if (Session.getInstance().me == false) {
			return;
		}
		if (param1 < 0 || param1 >= this.m_farmlandData.length) {
			return;
		}
		if (param2 <= 0) {
			return;
		}
		var _loc3_:FarmLand = this.m_farmlandData[param1];
		if (_loc3_._cId != 0) {
			this.showLandTip("不可以种在这里哦！", param1);
		} else {
			EventRecorder.startARequest(EventRecorder.HF_PLANTING);
			_loc4_ = this.buildCommonPostParams(Std.string(param1));
			if (_loc4_ == null) {
				return;
			}
			Reflect.setField(_loc4_, "cId", param2);
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_PLANT, _loc4_, this.onOperateSuccessPlant, this.onNetError);
		}
	}

	// FarmLandModel.as:2009-2025
	private function showLandTip(param1:String, param2:Int, param3:Int = 0):Void {
		if (param2 < 0 || param2 >= this.m_farmlandData.length) {
			return;
		}
		if (param1 == "") {
			return;
		}
		var _loc4_:Dynamic = {
			"text": param1,
			"index": param2,
			"yAdjust": param3
		};
		dispatchEvent(new CommonEvent(EVENT_OPERATE_INVALID, _loc4_));
	}

	// FarmLandModel.as:2027-2038（湿度状态公式）
	public function hasLandToWater():Bool {
		var _loc1_:FarmLand = null;
		for (_loc1_ in (this.m_farmlandData:Array<Dynamic>)) {
			if (_loc1_._humidity != 1) {
				return true;
			}
		}
		return false;
	}

	// FarmLandModel.as:2040-2067
	private function onDelayResponseSuccess(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = Std.int(Reflect.field(param1.data, "cmd"));
		var _loc3_:Dynamic = Reflect.field(param1.data, "data");
		if (_loc3_ == null) {
			return;
		}
		switch (_loc2_) {
			case OperationQueue.ADD_BUG:
				this.onOperateSuccessAddBug(_loc3_);
			case OperationQueue.CLEAR_BUG:
				this.onOperateSuccessClearBug(_loc3_);
			case OperationQueue.ADD_WEED:
				this.onOperateSuccessAddWeed(_loc3_);
			case OperationQueue.CLEAR_WEED:
				this.onOperateSuccessClearWeed(_loc3_);
			default:
		}
		dispatchEvent(new Event(EVENT_CHECK_STATUS));
	}
}
