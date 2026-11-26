package mc.fBridge;

import common.CommonData;
import common.LocalData;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;
import shim.As3;

/**
 * mc.fBridge.RequestManager —— RequestManager.as 逐句对应（issue #87
 * 「网络」片）。偷菜/进好友牧场的错误次数熔断：actList/uinList 持久化在
 * SharedObject（LocalData.setObject），checkAction 按 serverTime 与
 * blocking 比较出分钟数文案。
 * legacy/decompiled/Master2_v_142/scripts/mc/FBridge/RequestManager.as。
 *
 * PORT-NOTE（动态键读写）：actList/uinList 是 AS3 Object 关联表——
 * `this.actList[param1]` 读 → Reflect.field、写 → Reflect.setField，
 * `delete` → Reflect.deleteField（仓内 Dynamic 键通道通行做法）。
 * PORT-NOTE（数值比较）：errNum/blocking 等存进 Object 的数值读出是
 * Dynamic，与 errTotal/serverTime 的比较走 As3.floatOf（AS3 Number 通道，
 * cpp 上 Dynamic 裸比不做数值转换——ShopController/ProfileMsg 同款先例）。
 * PORT-NOTE（`++errNum` 自增，:65/:129）：AS3 对 Number 槽位自增——
 * 读出 +1 写回，As3.floatOf 转数（FarmLite.hx:283 同款先例）。
 * PORT-NOTE（EventRecorder 上报，:96/:113）：mcloader 加载链的外部依赖
 * （spec/modules/pasture.json notes），编译 stub 体空——no-qq-telemetry
 * 偏差下上报出口本不发送，调用点行为不受影响（见该文件头注）。
 * PORT-NOTE(命名)：原包 `mc.FBridge` 的 FBridge 段首字母大写，Haxe 包段
 * 必须小写开头，落 `fBridge`（windowControl 同款先例，deviations 候选）。
 */
@:keep
class RequestManager extends EventDispatcher {
	// RequestManager.as:11
	private static var instance:RequestManager;

	// RequestManager.as:13-15
	public static final STEAL:String = "steal";
	public static final ENTER:String = "enter";

	// RequestManager.as:17-25
	private var actList:Dynamic = {};
	private var _errInfo:String;
	private var localData:LocalData;
	private var uinList:Dynamic = {};
	private var errTotal:Float = 3;

	// RequestManager.as:27-31
	public function new(param1:IEventDispatcher = null) {
		super(param1);
		this.localData = LocalData.getInstance();
	}

	// RequestManager.as:33-39
	public static function getInstance():RequestManager {
		if (instance == null) {
			instance = new RequestManager();
		}
		return instance;
	}

	// RequestManager.as:42-58（整个方法体在 try/catch 内——原文如此，
	// setObject 掷错被原代码自身吞掉、内存清零已生效）
	public function resetAction(param1:String):Void {
		var action:String = param1;
		try {
			if (As3.truthy(Reflect.field(this.actList, action))) {
				var _entry:Dynamic = Reflect.field(this.actList, action);
				Reflect.setField(_entry, "errNum", 0);
				Reflect.setField(_entry, "blocking", 0);
				Reflect.deleteField(_entry, "record");
				this.localData.setObject("requestManager_mc_action", this.actList, 0, false);
			}
		} catch (e:Dynamic) {}
	}

	// RequestManager.as:60-73
	public function addAction(param1:String):Void {
		var _loc2_:Float = Math.NaN;
		if (As3.truthy(Reflect.field(this.actList, param1))) {
			var _entry:Dynamic = Reflect.field(this.actList, param1);
			Reflect.setField(_entry, "errNum", As3.floatOf(Reflect.field(_entry, "errNum")) + 1);
			if (As3.floatOf(Reflect.field(_entry, "errNum")) >= this.errTotal && As3.floatOf(Reflect.field(_entry, "blocking")) == 0) {
				_loc2_ = Math.floor(5 + Math.random() * 5);
				Reflect.setField(_entry, "blocking", CommonData.serverTime + _loc2_ * 60);
			}
			this.localData.setObject("requestManager_mc_action", this.actList, 0, false);
		}
	}

	// RequestManager.as:75-82（delete 在 setObject 之前）
	public function resetUin(param1:String):Void {
		if (As3.truthy(Reflect.field(this.uinList, param1))) {
			Reflect.deleteField(this.uinList, param1);
			this.localData.setObject("requestManager_mc_uin", this.uinList, 0, false);
		}
	}

	// RequestManager.as:84-122
	public function checkAction(param1:String, param2:String = null):String {
		var _loc3_:Float = Math.NaN;
		if (param1 == RequestManager.ENTER) {
			var _uinEntry:Dynamic = Reflect.field(this.uinList, param2);
			if (As3.truthy(_uinEntry) && CommonData.serverTime < As3.floatOf(Reflect.field(_uinEntry, "blocking"))) {
				_loc3_ = Math.ceil((As3.floatOf(Reflect.field(_uinEntry, "blocking")) - CommonData.serverTime) / 60);
				this._errInfo = "系统太忙，建议" + _loc3_ + "分钟后再访问该好友。";
				if (!As3.truthy(Reflect.field(_uinEntry, "record"))) {
					Reflect.setField(_uinEntry, "record", true);
					EventRecorder.recordErrorEvent(EventRecorder.MC_SNOW, 0, EventRecorder.FAULT_SNOW_ENTER);
				}
				return this._errInfo;
			}
			if (As3.truthy(_uinEntry) && As3.truthy(CommonData.serverTime >= As3.floatOf(Reflect.field(_uinEntry, "blocking")))
				&& As3.floatOf(Reflect.field(_uinEntry, "errNum")) >= this.errTotal) {
				this.resetUin(param2);
			}
			return null;
		}
		var _actEntry:Dynamic = Reflect.field(this.actList, param1);
		if (As3.truthy(_actEntry) && CommonData.serverTime < As3.floatOf(Reflect.field(_actEntry, "blocking"))) {
			_loc3_ = Math.ceil((As3.floatOf(Reflect.field(_actEntry, "blocking")) - CommonData.serverTime) / 60);
			this._errInfo = "系统太忙，建议" + _loc3_ + "分钟后再试。";
			if (!As3.truthy(Reflect.field(_actEntry, "record"))) {
				Reflect.setField(_actEntry, "record", true);
				EventRecorder.recordErrorEvent(EventRecorder.MC_SNOW, 0, EventRecorder.FAULT_SNOW_STEAL);
			}
			return this._errInfo;
		}
		if (As3.truthy(_actEntry) && As3.truthy(CommonData.serverTime >= As3.floatOf(Reflect.field(_actEntry, "blocking")))
			&& As3.floatOf(Reflect.field(_actEntry, "errNum")) >= this.errTotal) {
			this.resetAction(param1);
		}
		return null;
	}

	// RequestManager.as:124-144
	public function addUin(param1:String):Void {
		var _loc2_:Float = Math.NaN;
		if (As3.truthy(Reflect.field(this.uinList, param1))) {
			var _entry:Dynamic = Reflect.field(this.uinList, param1);
			Reflect.setField(_entry, "errNum", As3.floatOf(Reflect.field(_entry, "errNum")) + 1);
			if (As3.floatOf(Reflect.field(_entry, "errNum")) >= this.errTotal && As3.floatOf(Reflect.field(_entry, "blocking")) == 0) {
				_loc2_ = Math.floor(5 + Math.random() * 5);
				Reflect.setField(_entry, "blocking", CommonData.serverTime + _loc2_ * 60);
			}
		} else {
			Reflect.setField(this.uinList, param1, {
				"errNum": 1,
				"blocking": 0
			});
		}
		this.localData.setObject("requestManager_mc_uin", this.uinList, 0, false);
	}

	// RequestManager.as:146-170（`Number(...) || this.errTotal` → As3.or
	// 通道：Number(非法串/undefined)=NaN 为假回落 errTotal）
	public function registerAction():Void {
		this.errTotal = As3.or(As3.floatOf(Reflect.field(LocalData.parameters, "snowslide")), this.errTotal);
		if (!As3.truthy(this.localData.getObject("requestManager_mc_action"))) {
			Reflect.setField(this.actList, "steal", {
				"action": "steal",
				"errNum": 0,
				"blocking": 0
			});
			this.localData.setObject("requestManager_mc_action", this.actList, 0, false);
		} else {
			this.actList = LocalData.getInstance().getObject("requestManager_mc_action");
		}
		if (!As3.truthy(this.localData.getObject("requestManager_mc_uin"))) {
			this.localData.setObject("requestManager_mc_uin", this.uinList, 0, false);
		} else {
			this.uinList = this.localData.getObject("requestManager_mc_uin");
		}
	}
}
