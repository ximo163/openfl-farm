package module.water;

import com.qzone.qfa.events.CommandEvent;
import common.CommonData;
import common.Consts;
import common.Session;
import entities.PoolFish;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;
import openfl.utils.Dictionary;
import report.EventRecorder;
import shim.As3;

/**
 * module.water.WaterModel —— WaterModel.as 逐句对应（issue #37 功能 swf 翻译：
 * 鱼塘 pool_v_13 数据层）。鱼塘全部 7 个 mod 的唯一发起者：装载
 * （cgi_fish_index 300）、放养（cgi_fish_plant 301）、捞/一键捞
 * （cgi_fish_harvest 302）、偷（cgi_fish_steal 303）、成熟结算（cgi_fish_output
 * 304）、开通（cgi_fish_register 305）、喂食（cgi_fish_fertilize 306），全部经
 * main3 ServerServices m_cmdMap 拼网关。
 *
 * PORT-NOTE: AS3 对回包 Object 的裸键读（`_loc2_["i"]` 等）按 Dynamic 处理：
 * 松等比较（`!= 1`、`> 0`、`== this._requestOutput`）与 int 强转统一走
 * As3.floatOf/intOf——"0" 字串与数字混写时静态目标直 `==` 会因类型先行判不等。
 * `!= undefined` 判存在性按 As3.hasProp（Reflect.hasField + 原型链兜底）。
 * EventRecorder 按 deviations（no-qq-telemetry）DISABLED，record* 只保不抛。
 * AS3 internal static const → private（CLAUDE.md 映射），同包消费方（本包的
 * WaterController/WaterGrayOpen）按 FriendsController 先例以 @:access 取。
 */
class WaterModel extends EventDispatcher {
	// WaterModel.as:19（AS3 internal static const → private，CLAUDE.md 映射）
	private static final EVENT_DATA_LOADED:String = "Fish Data Loaded";

	// WaterModel.as:21
	private static final EVENT_FISH_PLANTED:String = "Fish Planted";

	// WaterModel.as:23
	private static final EVENT_FISH_HARVESTED:String = "Fish Harvested";

	// WaterModel.as:25
	private static final EVENT_ERROR_MSG:String = "Error Message";

	// WaterModel.as:27
	private static final EVENT_FISH_CHANGED:String = "Fish Data Changed";

	// WaterModel.as:29
	private static final EVENT_NOT_WHITELIST:String = "Not in Whitelist";

	// WaterModel.as:31
	private static final EVENT_WATER_OPENED:String = "Water Pool is Open";

	// WaterModel.as:33
	private static final EVENT_LEVELUP:String = "LevelUp";

	// WaterModel.as:35
	private static final EVENT_GROW_UP:String = "GrowUp";

	// WaterModel.as:37
	private static final EVENT_BATCH_FISH:String = "BatchProcessFish";

	// WaterModel.as:39
	private static final EVENT_UPDATE_MATURE_FLAG:String = "UpdateMatureFlag";

	// WaterModel.as:41
	private var _batchFlag:Int;

	// WaterModel.as:43
	private var _requestOutputRecord:Dictionary<Int, Int>;

	// WaterModel.as:45
	public var whited:Bool;

	// WaterModel.as:47
	private var _fishes:Array<Dynamic>;

	// WaterModel.as:49
	private var _requestPending:Bool;

	// WaterModel.as:51
	public var opened:Bool;

	// WaterModel.as:53
	private var _requestOutput:Int;

	// WaterModel.as:55
	private var _batchFish:Array<Dynamic>;

	// WaterModel.as:57-68
	public function new(param1:IEventDispatcher = null) {
		super(param1);
		this.opened = false;
		this.whited = false;
		this._fishes = null;
		this._requestPending = false;
		this._requestOutput = -1;
		this._requestOutputRecord = null;
		this._batchFish = null;
		this._batchFlag = 0;
	}

	// WaterModel.as:70-75
	private function onWaterOpened(param1:CommandEvent):Void {
		this.opened = true;
		dispatchEvent(new CommonEvent(EVENT_WATER_OPENED, null));
		EventRecorder.recordSueecssEvent("160759", 0, null);
	}

	// WaterModel.as:77-98
	private function onHarvestFish(param1:CommandEvent):Void {
		this._requestPending = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Std.isOfType(_loc2_, Array)) {
			this._batchFish = cast _loc2_;
			this._batchFlag = 1;
			dispatchEvent(new CommonEvent(EVENT_BATCH_FISH, 2));
		} else {
			this._batchFish = null;
			this._batchFlag = 0;
			this.processHarvestFish(_loc2_);
		}
		EventRecorder.recordSueecssEvent("160761", 0, null);
	}

	// WaterModel.as:100-113
	public function findFishByID(param1:Int):PoolFish {
		var _loc2_:Int = this._fishes.length;
		var _loc3_:Int = 0;
		while (_loc3_ < _loc2_) {
			if (cast(this._fishes[_loc3_], PoolFish)._id == param1) {
				return this._fishes[_loc3_];
			}
			_loc3_++;
		}
		return null;
	}

	// WaterModel.as:115-145
	private function processStealFish(param1:Dynamic):Void {
		var _loc5_:Int = 0;
		if (As3.floatOf(Reflect.field(param1, "code")) != 1) {
			return;
		}
		var _loc2_:Int = Std.int(As3.parseInt(Reflect.field(param1, "index")));
		var _loc3_:PoolFish = this.findFishByID(_loc2_);
		if (_loc3_ != null) {
			_loc5_ = Std.int(As3.parseInt(Session.getInstance().hostId));
			if (As3.floatOf(Reflect.field(param1, "harvest")) > 0
				&& _loc3_._thief.indexOf(_loc5_) == -1) {
				_loc3_._thief.push(_loc5_);
			}
			var _locStatus_:Dynamic = Reflect.field(param1, "status");
			_loc3_._left = Reflect.field(_locStatus_, "l");
			_loc3_._output = Reflect.field(_locStatus_, "o");
			_loc3_._plantTime = Reflect.field(_locStatus_, "p");
		}
		// PORT-NOTE: 原版这里对可能为 null 的 _loc3_ 直接解引用（findFishByID
		// 未命中时 TypeError 中断后续派发）——原样照留，不加守卫（lessons #35）
		var _loc4_:Bool = false;
		if (_loc3_._output > 0 && _loc3_._left == 0) {
			_loc4_ = true;
		}
		dispatchEvent(new CommonEvent(EVENT_FISH_HARVESTED, {
			"count": Reflect.field(param1, "harvest"),
			"id": Reflect.field(param1, "index"),
			"remove": _loc4_
		}));
	}

	// WaterModel.as:147-150
	public var poolFishes(get, never):Array<Dynamic>;

	private function get_poolFishes():Array<Dynamic> {
		return this._fishes;
	}

	// WaterModel.as:152-161
	public function loadFishes():Void {
		if (this._requestPending == true) {
			return;
		}
		this._requestPending = true;
		EventRecorder.startARequest("160613");
		NetHelper.sendRequest(CommandDefs.CMD_GET_FISHES, {"ownerId": Session.getInstance().currentUser._uId},
			this.onDataLoaded, this.onNetError);
	}

	// WaterModel.as:163-225
	public function harvestAll():Int {
		if (this.canOperate() == false) {
			return -3;
		}
		var _loc1_:Int = Std.int(As3.parseInt(Session.getInstance().hostId));
		var _loc2_:Bool = Session.getInstance().me;
		var _loc3_:Array<Dynamic> = [];
		var _loc4_:UInt = this._fishes.length;
		var _loc5_:PoolFish = null;
		var _loc6_:Bool = false;
		var _loc7_:Int = 0;
		while (_loc7_ < _loc4_) {
			_loc5_ = cast(this._fishes[_loc7_], PoolFish);
			if (_loc5_ != null && _loc5_.canHarvest == true && _loc5_._left > 0) {
				if (_loc2_ == true) {
					_loc3_.push(_loc5_._id);
				} else if (_loc5_._thief.indexOf(_loc1_) != -1) {
					_loc6_ = true;
				} else if (_loc5_._left > _loc5_.min) {
					_loc3_.push(_loc5_._id);
				} else {
					_loc6_ = true;
				}
			}
			_loc7_++;
		}
		if (_loc3_.length == 0) {
			return _loc6_ ? -1 : -2;
		}
		var _loc8_:Dynamic = null;
		if (_loc2_ == true) {
			_loc8_ = {
				"index": _loc3_.join(","),
				"flag": 2
			};
			this._requestPending = true;
			NetHelper.sendRequest(CommandDefs.CMD_HARVEST_FISH, _loc8_, this.onHarvestFish, this.onNetError);
		} else {
			_loc8_ = {
				"index": _loc3_.join(","),
				"flag": 1,
				"ownerId": Session.getInstance().currentUser._uId
			};
			this._requestPending = true;
			NetHelper.sendRequest(CommandDefs.CMD_STEAL_FISH, _loc8_, this.onStealFish, this.onNetError);
		}
		return 0;
	}

	// WaterModel.as:227-249
	private function onGrowFish(param1:CommandEvent):Void {
		this._requestPending = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (As3.hasProp(_loc2_, "exp")) {
			Session.getInstance().updateHostAccount(0, Reflect.field(_loc2_, "exp"));
			dispatchEvent(new CommonEvent(EVENT_LEVELUP, _loc2_));
		}
		var _loc3_:PoolFish = new PoolFish(_loc2_);
		_loc3_.calcNextStepTime();
		if (this._fishes == null) {
			this._fishes = new Array();
		}
		this._fishes.push(_loc3_);
		dispatchEvent(new CommonEvent(EVENT_FISH_PLANTED, _loc3_));
		EventRecorder.recordSueecssEvent("160763", 0, null);
	}

	// WaterModel.as:251-263
	public function grow(param1:Int):Void {
		if (this.canOperate() == false) {
			return;
		}
		if (Session.getInstance().me == false) {
			return;
		}
		this._requestPending = true;
		NetHelper.sendRequest(CommandDefs.CMD_GROW_FISH, {"fid": param1}, this.onGrowFish, this.onNetError);
	}

	// WaterModel.as:265-272
	private function canOperate():Bool {
		if (this._requestPending == true) {
			return false;
		}
		return true;
	}

	// WaterModel.as:274-312
	public function growLoop():Void {
		var _loc3_:PoolFish = null;
		if (this._fishes == null || this._fishes.length == 0) {
			return;
		}
		var _loc1_:UInt = Session.getInstance().currentUser._uId;
		var _loc2_:Float = CommonData.serverTime;
		// for-each：AS3 声明 `_loc3_:PoolFish`，转译经 typed 收窄
		// （FarmLandModel:1288 先例）——动态元素上属性 getter 取不到
		var typed3:Array<PoolFish> = cast this._fishes;
		for (_loc3_ in typed3) {
			if (_loc2_ >= _loc3_._nextStepTime) {
				_loc3_.calcNextStepTime();
			}
			if (_loc3_._nextStepTime == Math.POSITIVE_INFINITY && _loc3_._output <= 0) {
				// `record[id] != undefined && record[id] >= 2`（Dictionary 缺键
				// → null）
				var _locRec_:Dynamic = this._requestOutputRecord.get(_loc3_._id);
				if (!(_locRec_ != null && As3.floatOf(_locRec_) >= 2)) {
					if (this._requestOutput == -1 && this._requestOutput != _loc3_._id) {
						this._requestOutput = _loc3_._id;
						NetHelper.sendRequest(CommandDefs.CMD_FISH_OUTPUT, {
							"index": _loc3_._id,
							"ownerId": _loc1_
						}, this.onGetOutput, this.onNetError);
						if (this._requestOutputRecord.get(_loc3_._id) == null) {
							this._requestOutputRecord.set(_loc3_._id, 1);
						} else {
							this._requestOutputRecord.set(_loc3_._id, As3.intOf(this._requestOutputRecord.get(_loc3_._id)) + 1);
						}
					}
				}
			}
		}
	}

	// WaterModel.as:314-335
	private function onGetOutput(param1:CommandEvent):Void {
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (_loc2_ == null || As3.floatOf(Reflect.field(_loc2_, "i")) != this._requestOutput) {
			this._requestOutput = -1;
			return;
		}
		var _loc3_:PoolFish = this.findFishByID(As3.intOf(Reflect.field(_loc2_, "i")));
		if (_loc3_ != null) {
			_loc3_._left = Reflect.field(_loc2_, "l");
			_loc3_._output = Reflect.field(_loc2_, "o");
			this._requestOutput = -1;
			dispatchEvent(new CommonEvent(EVENT_FISH_CHANGED, _loc3_));
			EventRecorder.recordSueecssEvent("160872", 0, null);
		}
	}

	// WaterModel.as:337-343
	public function resetLoadingFlags():Void {
		if (this._requestPending == true) {
			this._requestPending = false;
		}
	}

	// WaterModel.as:345-365
	private function onFeedFish(param1:CommandEvent):Void {
		var _loc4_:Int = 0;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this._requestPending = false;
		var _loc3_:PoolFish = this.findFishByID(As3.intOf(Reflect.field(_loc2_, "i")));
		if (_loc3_ != null) {
			_loc3_.refreshStatus(_loc2_);
			_loc4_ = As3.intOf(Reflect.field(Reflect.field(param1.body, "__body"), "tid"));
			dispatchEvent(new CommonEvent(EVENT_GROW_UP, {
				"fish": _loc3_,
				"food": _loc4_
			}));
		}
		EventRecorder.recordSueecssEvent("160762", 0, null);
	}

	// WaterModel.as:367-387
	private function onDataLoaded(param1:CommandEvent):Void {
		var _loc3_:PoolFish = null;
		this._requestPending = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			this.opened = false;
			dispatchEvent(new CommonEvent(EVENT_DATA_LOADED, null));
			return;
		}
		this.opened = true;
		this._fishes = cast _loc2_;
		this._requestOutputRecord = new Dictionary<Int, Int>();
		// for-each：AS3 声明 `_loc3_:PoolFish`，经 typed 收窄（同上）
		var typed2:Array<PoolFish> = cast this._fishes;
		for (_loc3_ in typed2) {
			_loc3_.calcNextStepTime();
		}
		dispatchEvent(new CommonEvent(EVENT_DATA_LOADED, this._fishes));
		EventRecorder.recordSueecssEvent("160613", 0, null);
	}

	// WaterModel.as:389-397
	public function feed(param1:Int, param2:Int):Void {
		var _loc3_:Dynamic = {
			"index": param1,
			"tid": param2
		};
		this._requestPending = true;
		NetHelper.sendRequest(CommandDefs.CMD_FEED_FISH, _loc3_, this.onFeedFish, this.onNetError);
	}

	// WaterModel.as:399-429
	public function canSteal(param1:Bool):Bool {
		if (this._fishes == null || this._fishes.length == 0) {
			return false;
		}
		var _loc2_:Int = Std.int(As3.parseInt(Session.getInstance().hostId));
		var _loc3_:UInt = this._fishes.length;
		var _loc4_:PoolFish = null;
		var _loc5_:Int = 0;
		while (_loc5_ < _loc3_) {
			_loc4_ = cast(this._fishes[_loc5_], PoolFish);
			if (_loc4_ != null && _loc4_.canHarvest == true && _loc4_._left > 0) {
				if (param1 == true) {
					return true;
				}
				if (_loc4_._thief.indexOf(_loc2_) == -1) {
					if (_loc4_._left > _loc4_.min) {
						return true;
					}
				}
			}
			_loc5_++;
		}
		return false;
	}

	// WaterModel.as:431-451
	private function onStealFish(param1:CommandEvent):Void {
		this._requestPending = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		if (Std.isOfType(_loc2_, Array)) {
			this._batchFish = cast _loc2_;
			this._batchFlag = 2;
			dispatchEvent(new CommonEvent(EVENT_BATCH_FISH, 2));
		} else {
			this._batchFish = null;
			this.processStealFish(_loc2_);
		}
		EventRecorder.recordSueecssEvent("160760", 0, null);
	}

	// WaterModel.as:453-542
	private function onNetError(param1:CommandEvent):Void {
		var _loc5_:String = null;
		var _loc6_:PoolFish = null;
		if (param1 == null) {
			return;
		}
		this._requestPending = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = As3.intOf(Reflect.field(param1.body, "cmdID"));
		var _loc4_:Int = 0;
		if (_loc3_ == CommandDefs.CMD_GET_FISHES) {
			EventRecorder.recordErrorEvent("160613", null, 0, null);
			if (As3.floatOf(Reflect.field(_loc2_, "open")) == 0) {
				this.opened = false;
				dispatchEvent(new CommonEvent(EVENT_DATA_LOADED, null));
			}
		} else if (_loc3_ == CommandDefs.CMD_FISH_OUTPUT) {
			_loc4_ = As3.intOf(Reflect.field(Reflect.field(param1.body, "__body"), "index"));
			this._requestOutputRecord.set(_loc4_, 2);
			this._requestOutput = -1;
			EventRecorder.recordErrorEvent("160872", null, 4);
		} else if (_loc3_ == CommandDefs.CMD_WATER_OPEN) {
			_loc5_ = Reflect.field(_loc2_, "direction");
			if (_loc5_ == null || _loc5_ == "") {
				_loc5_ = "服务器错误.";
			}
			dispatchEvent(new CommonEvent(EVENT_WATER_OPENED, _loc5_));
			EventRecorder.recordErrorEvent("160759", null, 0, null);
		} else if (_loc3_ == CommandDefs.CMD_STEAL_FISH) {
			_loc4_ = As3.intOf(Reflect.field(Reflect.field(param1.body, "__body"), "index"));
			if (As3.hasProp(_loc2_, "direction")) {
				dispatchEvent(new CommonEvent(EVENT_ERROR_MSG, {
					"id": _loc4_,
					"msg": Reflect.field(_loc2_, "direction")
				}));
			}
			if (As3.hasProp(_loc2_, "l") && As3.hasProp(_loc2_, "o")) {
				_loc6_ = this.findFishByID(_loc4_);
				if (_loc6_ != null) {
					_loc6_._output = Reflect.field(_loc2_, "o");
					_loc6_._left = Reflect.field(_loc2_, "l");
					dispatchEvent(new CommonEvent(EVENT_FISH_CHANGED, _loc6_));
				}
			}
			EventRecorder.recordErrorEvent("160760", null, 0, null);
		} else if (_loc3_ == CommandDefs.CMD_HARVEST_FISH) {
			_loc4_ = As3.intOf(Reflect.field(Reflect.field(param1.body, "__body"), "index"));
			if (As3.hasProp(_loc2_, "direction")) {
				dispatchEvent(new CommonEvent(EVENT_ERROR_MSG, {
					"id": _loc4_,
					"msg": Reflect.field(_loc2_, "direction")
				}));
			}
			EventRecorder.recordErrorEvent("160761", null, 0, null);
		} else if (_loc3_ == CommandDefs.CMD_FEED_FISH) {
			_loc4_ = As3.intOf(Reflect.field(Reflect.field(param1.body, "__body"), "index"));
			dispatchEvent(new CommonEvent(EVENT_ERROR_MSG, {
				"id": _loc4_,
				"msg": Reflect.field(_loc2_, "direction")
			}));
			EventRecorder.recordErrorEvent("160762", null, 0, null);
		} else if (_loc3_ == CommandDefs.CMD_GROW_FISH) {
			EventRecorder.recordErrorEvent("160763", null, 0, null);
		}
	}

	// WaterModel.as:544-550
	public function openWater():Void {
		if (this.whited == true && this.opened == false) {
			NetHelper.sendRequest(CommandDefs.CMD_WATER_OPEN,
				{"yellow": Session.getInstance().host._yellowstatus}, this.onWaterOpened, this.onNetError);
		}
	}

	// WaterModel.as:552-559
	public function checkSize():Bool {
		if (this.poolSize >= Consts.FISH_MAX_SIZE) {
			return false;
		}
		return true;
	}

	// WaterModel.as:561-593
	private function processHarvestFish(param1:Dynamic):Void {
		if (param1 == null || As3.floatOf(Reflect.field(param1, "code")) != 1) {
			return;
		}
		if (As3.hasProp(param1, "exp")) {
			Session.getInstance().updateHostAccount(0, Reflect.field(param1, "exp"));
			dispatchEvent(new CommonEvent(EVENT_LEVELUP, param1));
		}
		var _loc2_:Int = this._fishes.length;
		var _loc3_:PoolFish = null;
		var _loc4_:Int = 0;
		while (_loc4_ < _loc2_) {
			_loc3_ = cast(this._fishes[_loc4_], PoolFish);
			if (_loc3_ != null) {
				if (_loc3_._id == Reflect.field(param1, "i")) {
					this._fishes.splice(_loc4_, 1);
					break;
				}
			}
			_loc4_++;
		}
		dispatchEvent(new CommonEvent(EVENT_FISH_HARVESTED, {
			"count": Reflect.field(param1, "o"),
			"id": Reflect.field(param1, "i"),
			"remove": true
		}));
	}

	// WaterModel.as:595-625
	public function harvest(param1:Int, param2:Bool):Void {
		if (this.canOperate() == false) {
			return;
		}
		var _loc3_:Dynamic = null;
		if (Session.getInstance().me == true) {
			_loc3_ = {"index": param1};
			if (param2 == false) {
				Reflect.setField(_loc3_, "flag", 1);
			}
			this._requestPending = true;
			NetHelper.sendRequest(CommandDefs.CMD_HARVEST_FISH, _loc3_, this.onHarvestFish, this.onNetError);
		} else {
			if (param2 == false) {
				return;
			}
			this._requestPending = true;
			_loc3_ = {
				"index": param1,
				"ownerId": Session.getInstance().currentUser._uId
			};
			NetHelper.sendRequest(CommandDefs.CMD_STEAL_FISH, _loc3_, this.onStealFish, this.onNetError);
		}
	}

	// WaterModel.as:627-658
	public function processBatchFish():Bool {
		if (this._batchFish == null || this._batchFish.length == 0) {
			return false;
		}
		var _loc1_:Dynamic = this._batchFish.shift();
		if (_loc1_ == null) {
			return false;
		}
		if (this._batchFlag == 1) {
			this.processHarvestFish(_loc1_);
		} else if (this._batchFlag == 2) {
			this.processStealFish(_loc1_);
		}
		dispatchEvent(new CommonEvent(EVENT_BATCH_FISH, 1));
		if (this._batchFish.length > 0) {
			_loc1_ = this._batchFish[0];
			if (As3.floatOf(Reflect.field(_loc1_, "harvest")) > 0) {
				dispatchEvent(new CommonEvent(EVENT_UPDATE_MATURE_FLAG, Reflect.field(_loc1_, "index")));
			}
			return true;
		}
		dispatchEvent(new CommonEvent(EVENT_BATCH_FISH, 0));
		return false;
	}

	// WaterModel.as:660-673
	public var poolSize(get, never):Int;

	private function get_poolSize():Int {
		var _loc2_:PoolFish = null;
		if (this._fishes == null) {
			return 0;
		}
		var _loc1_:Int = 0;
		// for-each：AS3 声明 `_loc2_:PoolFish`，经 typed 收窄——poolSize 是
		// getter，动态接收者上取不到（eval 返 null、js 落 undefined）
		var typed:Array<PoolFish> = cast this._fishes;
		for (_loc2_ in typed) {
			_loc1_ += _loc2_.poolSize;
		}
		return _loc1_;
	}

	// WaterModel.as:675-679
	public function checkWhiteList():Void {
		this.whited = true;
		this.loadFishes();
	}
}
