package module.mainScene.npc;

import com.qzone.qfa.events.CommandEvent;
import common.Consts;
import common.Session;
import entities.Dog;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import openfl.events.EventDispatcher;
import report.EventRecorder;
import shim.As3;

/**
 * module.mainScene.npc.NPCModel —— V3b 翻译（issue #8）。
 * NPC 数据模型：狗状态（setDogData/changeDog/dogID/dogHungry）与狗粮状态
 * 请求。legacy/decompiled/main3_v_221/scripts/module/mainScene/npc/NPCModel.as
 * 逐句对应。
 */
class NPCModel extends EventDispatcher {
	// NPCModel.as:16-18（internal static const → public：同包 NPCView 原版
	// 同样引用，Haxe 无包可见性）
	public static final EVENT_DOG_LOADED:String = "DogLoaded";
	public static final EVENT_DOG_FOOD_LOADED:String = "DogFoodLoaded";

	// NPCModel.as:20-28
	private var m_session:Session;
	private var m_dog:Dog;
	private var m_dogFood:Dynamic;
	private var m_dogFoodLoading:Bool;
	private var m_ownerId:UInt;

	// NPCModel.as:30-39
	public function new() {
		super();
		this.m_dog = null;
		this.m_dogFood = null;
		this.m_dogFoodLoading = false;
		this.m_session = Session.getInstance();
	}

	// NPCModel.as:41-61（onRequestFoodStatusSuccess：狗粮状态回包，hours<=0
	// 时把存量狗标记为饿）
	private function onRequestFoodStatusSuccess(param1:CommandEvent):Void {
		this.m_dogFoodLoading = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		this.m_dogFood = _loc2_;
		if (_loc2_ != null) {
			// parseInt(hours) <= 0：NaN 时比较为假，用 floatOf 保 NaN 语义
			if (Reflect.hasField(_loc2_, "hours") && As3.floatOf(Reflect.field(_loc2_, "hours")) <= 0) {
				if (this.m_dog != null) {
					this.m_dog._isHungry = 1;
					// 原版这里有一行孤立表达式 Session.getInstance().m_isDogHungry;
					//（读了不用，无副作用），Haxe 里裸属性读不是合法语句，省略不改变行为
				}
			}
			dispatchEvent(new CommonEvent(EVENT_DOG_FOOD_LOADED, _loc2_));
		}
		EventRecorder.recordSueecssEvent("160888", null);
	}

	// NPCModel.as:63-67（loadDogFoodStatus）
	public function loadDogFoodStatus():Void {
		this.m_dogFoodLoading = true;
		NetHelper.sendRequest(CommandDefs.CMD_GET_DOG_FOOD_STATUS, null, this.onRequestFoodStatusSuccess, this.onNetError);
	}

	// NPCModel.as:69-76（dogHungry getter）
	public var dogHungry(get, never):Bool;

	private function get_dogHungry():Bool {
		if (this.m_dog == null) {
			return false;
		}
		return this.m_dog._isHungry > 0;
	}

	// NPCModel.as:78-89（setDogData：首只存引用，后续在存量对象上合并
	// _dogId(≠-1 才写)/_isHungry，每次派发 EVENT_DOG_LOADED）
	public function setDogData(param1:Dog):Void {
		if (this.m_dog == null) {
			this.m_dog = param1;
		} else {
			if (param1._dogId != -1) {
				this.m_dog._dogId = param1._dogId;
			}
			this.m_dog._isHungry = param1._isHungry;
		}
		dispatchEvent(new CommonEvent(EVENT_DOG_LOADED, this.m_dog));
	}

	// NPCModel.as:91-109（changeDog：无狗新建（isHungry=1），有狗只换 dogId；
	// 写 Session.sceneDecorates 的 DECOR_DOG 键）
	public function changeDog(param1:Int):Void {
		if (this.m_dog == null) {
			this.m_dog = new Dog(null);
			this.m_dog._dogId = param1;
			this.m_dog._isHungry = 1;
		} else {
			this.m_dog._dogId = param1;
		}
		dispatchEvent(new CommonEvent(EVENT_DOG_LOADED, this.m_dog));
		var _loc2_:Dynamic = Session.getInstance().sceneDecorates;
		if (_loc2_ != null) {
			Reflect.setField(_loc2_, Std.string(Consts.DECOR_DOG), {"itemId": param1});
		}
	}

	// NPCModel.as:111-114（selfDogFood getter）
	public var selfDogFood(get, never):Dynamic;

	private function get_selfDogFood():Dynamic {
		return this.m_dogFood;
	}

	// NPCModel.as:116-120（onNetError）
	private function onNetError(param1:CommandEvent):Void {
		this.m_dogFoodLoading = false;
		EventRecorder.recordErrorEvent("160888", null, 4);
	}

	// NPCModel.as:122-127（resetLoadingFlags：网络中断后复位）
	public function resetLoadingFlags():Void {
		if (this.m_dogFoodLoading == true) {
			this.m_dogFoodLoading = false;
		}
	}

	// NPCModel.as:129-137（dogID getter：无狗 -1）
	public var dogID(get, never):Int;

	private function get_dogID():Int {
		if (this.m_dog == null) {
			return -1;
		}
		return this.m_dog._dogId;
	}
}
