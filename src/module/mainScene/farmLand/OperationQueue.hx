package module.mainScene.farmLand;

import com.qzone.qfa.events.CommandEvent;
import common.Session;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import framework.net.vo.ServiceResultVO;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import report.EventRecorder;
import shim.As3;

/**
 * module.mainScene.farmLand.OperationQueue —— V3b 翻译（issue #8）。
 * 农事操作合批队列（撒种/除草/害虫/喷药四槽延迟合批 + 回包按槽位方向去重
 * 合并 + 展示定时器逐条派发）。OperationQueue.as 293 loc 逐句对应。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/OperationQueue.as
 * PORT-NOTE(动态取键)：AS3 `obj["k"] != undefined` → Reflect.hasField(...) &&
 * Reflect.field(...) != null；`++obj["k"]` / `obj["k"] += x` 的动态自增按
 * 读-改-写复刻；`as int` → As3.intOf。
 */
class OperationQueue extends EventDispatcher {
	// OperationQueue.as:17-27。EVENT_OPERATE_SUCCES 与四槽常量原版 internal、
	// 同包 FarmLandModel（.as:111 等）原版就引用 → public；EVENT_OPERATE_ERROR
	// /QUEUE_LEN 原版 internal 且全库无外部引用（ERROR 甚至本类内也不派发），
	// 按 internal → private 映射收窄
	public static final EVENT_OPERATE_SUCCES:String = "OperateSuccess";
	private static final EVENT_OPERATE_ERROR:String = "OperateError";
	public static final ADD_WEED:Int = 0;
	public static final CLEAR_WEED:Int = 1;
	public static final ADD_BUG:Int = 2;
	public static final CLEAR_BUG:Int = 3;
	private static final QUEUE_LEN:Int = 4;

	// OperationQueue.as:32-38
	private var m_delayRequestTimer:Timer;
	private var m_requestQueue:Array<Dynamic>;
	private var m_responseQueue:Array<Dynamic>;
	private var m_showByTimer:Timer;

	// OperationQueue.as:40-49
	public function new(param1:UInt = 1000, param2:IEventDispatcher = null) {
		super(param2);
		// AS3 new Array(QUEUE_LEN)：定长 4 的空槽表
		this.m_requestQueue = [for (_ in 0...QUEUE_LEN) null];
		this.m_responseQueue = [for (_ in 0...QUEUE_LEN) null];
		this.m_delayRequestTimer = new Timer(param1, 0);
		this.m_delayRequestTimer.addEventListener(TimerEvent.TIMER, this.delayRequestNow);
		this.m_showByTimer = new Timer(400, 0);
		this.m_showByTimer.addEventListener(TimerEvent.TIMER, this.onProcessResponseTimer);
	}

	// OperationQueue.as:51-61
	private function recordResp(param1:String, param2:Bool, param3:String):Void {
		if (param2 == true) {
			EventRecorder.recordSueecssEvent(param1, null, param3);
		} else {
			EventRecorder.recordErrorEvent(param1, null, EventRecorder.FAULT_ERROR, param3);
		}
	}

	// OperationQueue.as:63-204
	private function onOperateResponse(param1:CommandEvent):Void {
		var _loc10_:Dynamic = null;
		if (param1 == null) {
			Session.getInstance().isExpLocked = false;
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.body, "cmdID"));
		var _loc3d:Dynamic = param1.result;
		var _loc3_:ServiceResultVO = Std.isOfType(_loc3d, ServiceResultVO) ? cast _loc3d : null;
		if (_loc3_ == null || _loc3_.m_extra == null) {
			Session.getInstance().isExpLocked = false;
			return;
		}
		var _loc4_:Bool = false;
		// AS3 Object.hasOwnProperty("errorType") ≡ Reflect.hasField
		if (Reflect.hasField(_loc3_.m_extra, "errorType") == true) {
			_loc4_ = true;
		}
		var _loc5_:Int = -1;
		if (_loc2_ == CommandDefs.CMD_OPERATE_ADDWEED) {
			this.recordResp(EventRecorder.HF_SCATTERSEED, !_loc4_, "mod=farmlandstatus&act=scatterSeed");
			_loc5_ = ADD_WEED;
		} else if (_loc2_ == CommandDefs.CMD_OPERATE_CLEARWEED) {
			this.recordResp(EventRecorder.HF_CLEARWEED, !_loc4_, "mod=farmlandstatus&act=clearWeed");
			_loc5_ = CLEAR_WEED;
		} else if (_loc2_ == CommandDefs.CMD_OPERATE_ADDBUG) {
			this.recordResp(EventRecorder.HF_PEST, !_loc4_, "mod=farmlandstatus&act=pest");
			_loc5_ = ADD_BUG;
		} else if (_loc2_ == CommandDefs.CMD_OPERATE_CLEARBUG) {
			this.recordResp(EventRecorder.HF_SPRAYING, !_loc4_, "mod=farmlandstatus&act=spraying");
			_loc5_ = CLEAR_BUG;
		}
		if (_loc5_ == -1 || _loc4_ == true) {
			Session.getInstance().isExpLocked = false;
			return;
		}
		if (this.m_responseQueue[_loc5_] == null) {
			this.m_responseQueue[_loc5_] = new Array<Dynamic>();
		}
		var _loc6_:Array<Dynamic> = new Array<Dynamic>();
		_loc6_ = _loc6_.concat(_loc3_.m_extra);
		var _loc7_:Array<Dynamic> = this.m_responseQueue[_loc5_];
		var _loc8_:Dynamic = null;
		var _loc9_:Bool = false;
		for (_loc10_ in _loc6_) {
			if (Reflect.field(_loc10_, "code") == 0) {
				_loc9_ = false;
				for (_loc8_ in _loc7_) {
					if (Reflect.field(_loc10_, "farmlandIndex") == Reflect.field(_loc8_, "farmlandIndex")) {
						if (Reflect.field(_loc10_, "code") == Reflect.field(_loc8_, "code") && Reflect.field(_loc10_, "poptype") == Reflect.field(_loc8_, "poptype")) {
							_loc9_ = true;
							if (Reflect.hasField(_loc8_, "error_repeat") && Reflect.field(_loc8_, "error_repeat") != null) {
								// ++_loc8_["error_repeat"]
								Reflect.setField(_loc8_, "error_repeat", As3.intOf(Reflect.field(_loc8_, "error_repeat")) + 1);
							} else {
								Reflect.setField(_loc8_, "error_repeat", 1);
							}
						}
					}
				}
				if (_loc9_ == false) {
					_loc7_.push(_loc10_);
				}
			} else {
				_loc9_ = false;
				for (_loc8_ in _loc7_) {
					if (Reflect.field(_loc10_, "farmlandIndex") == Reflect.field(_loc8_, "farmlandIndex")) {
						switch (_loc5_) {
							case ADD_WEED:
								if (Reflect.field(_loc10_, "weed") >= Reflect.field(_loc8_, "weed")) {
									_loc9_ = true;
									Reflect.setField(_loc8_, "weed", Reflect.field(_loc10_, "weed"));
								}
							case CLEAR_WEED:
								if (Reflect.field(_loc10_, "weed") <= Reflect.field(_loc8_, "weed")) {
									_loc9_ = true;
									Reflect.setField(_loc8_, "weed", Reflect.field(_loc10_, "weed"));
								}
							case ADD_BUG:
								if (Reflect.field(_loc10_, "pest") >= Reflect.field(_loc8_, "pest")) {
									_loc9_ = true;
									Reflect.setField(_loc8_, "pest", Reflect.field(_loc10_, "pest"));
								}
							case CLEAR_BUG:
								if (Reflect.field(_loc10_, "pest") <= Reflect.field(_loc8_, "pest")) {
									_loc9_ = true;
									Reflect.setField(_loc8_, "pest", Reflect.field(_loc10_, "pest"));
								}
						}
						if (_loc9_ == true) {
							// _loc8_["money"] += _loc10_["money"] as int
							Reflect.setField(_loc8_, "money", As3.intOf(Reflect.field(_loc8_, "money")) + As3.intOf(Reflect.field(_loc10_, "money")));
							Reflect.setField(_loc8_, "exp", As3.intOf(Reflect.field(_loc8_, "exp")) + As3.intOf(Reflect.field(_loc10_, "exp")));
							if (Reflect.field(_loc8_, "levelUp") == false && Reflect.field(_loc10_, "levelUp") == true) {
								Reflect.setField(_loc8_, "levelUp", true);
							}
						}
					}
				}
				if (_loc9_ == false) {
					_loc7_.push(_loc10_);
				}
			}
		}
		if (this.m_showByTimer.running == false) {
			this.m_showByTimer.start();
		}
	}

	// OperationQueue.as:206-236
	private function delayRequestNow(param1:TimerEvent):Void {
		var _loc2_:Dynamic = null;
		if (this.m_requestQueue[ADD_WEED] != null) {
			EventRecorder.startARequest(EventRecorder.HF_SCATTERSEED);
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_ADDWEED, this.m_requestQueue[ADD_WEED], this.onOperateResponse, this.onOperateResponse);
			this.m_requestQueue[ADD_WEED] = null;
		}
		if (this.m_requestQueue[CLEAR_WEED] != null) {
			EventRecorder.startARequest(EventRecorder.HF_CLEARWEED);
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_CLEARWEED, this.m_requestQueue[CLEAR_WEED], this.onOperateResponse, this.onOperateResponse);
			this.m_requestQueue[CLEAR_WEED] = null;
			Session.getInstance().isExpLocked = true;
		}
		if (this.m_requestQueue[ADD_BUG] != null) {
			EventRecorder.startARequest(EventRecorder.HF_PEST);
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_ADDBUG, this.m_requestQueue[ADD_BUG], this.onOperateResponse, this.onOperateResponse);
			this.m_requestQueue[ADD_BUG] = null;
		}
		if (this.m_requestQueue[CLEAR_BUG] != null) {
			EventRecorder.startARequest(EventRecorder.HF_SPRAYING);
			NetHelper.sendRequest(CommandDefs.CMD_OPERATE_CLEARBUG, this.m_requestQueue[CLEAR_BUG], this.onOperateResponse, this.onOperateResponse);
			this.m_requestQueue[CLEAR_BUG] = null;
			Session.getInstance().isExpLocked = true;
		}
		this.m_delayRequestTimer.stop();
	}

	// OperationQueue.as:238-252
	public function delayRequest(param1:Int, param2:Dynamic):Void {
		if (this.m_requestQueue[param1] == null) {
			this.m_requestQueue[param1] = param2;
		} else {
			// AS3 queue[i]["place"] += "," + param2["place"]：串接改写存量
			Reflect.setField(this.m_requestQueue[param1], "place", Reflect.field(this.m_requestQueue[param1], "place") + "," + Reflect.field(param2, "place"));
		}
		if (this.m_delayRequestTimer.running == false) {
			this.m_delayRequestTimer.start();
		}
	}

	// OperationQueue.as:254-290
	private function onProcessResponseTimer(param1:TimerEvent):Void {
		var _loc4_:Dynamic = null;
		if (this.m_responseQueue == null || this.m_responseQueue.length == 0) {
			return;
		}
		Session.getInstance().harvestAnimationPlaying = true;
		var _loc2_:Bool = true;
		var _loc3_:Int = 0;
		while (_loc3_ < this.m_responseQueue.length) {
			if (this.m_responseQueue[_loc3_] != null) {
				if (this.m_responseQueue[_loc3_].length == 0) {
					this.m_responseQueue[_loc3_] = null;
				} else {
					_loc4_ = this.m_responseQueue[_loc3_].shift();
					dispatchEvent(new CommonEvent(EVENT_OPERATE_SUCCES, {
						"cmd": _loc3_,
						"data": _loc4_
					}));
					_loc2_ = false;
				}
			}
			_loc3_++;
		}
		if (_loc2_ == true) {
			this.m_showByTimer.stop();
			Session.getInstance().harvestAnimationPlaying = false;
			Session.getInstance().isExpLocked = false;
		}
	}
}
