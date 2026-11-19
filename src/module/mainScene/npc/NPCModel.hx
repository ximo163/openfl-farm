package module.mainScene.npc;

import entities.Dog;
import openfl.errors.Error;
import openfl.events.EventDispatcher;

/**
 * module.mainScene.npc.NPCModel —— V3b 模块翻译，闭包 stub（issue #7）。
 * NPC 数据模型（NPCModel.as 141 loc：狗状态/NPC 数据与请求装载标志）；
 * ModuleMainScene.onNetRequestStopped 调 resetLoadingFlags。数据流随 V3b 片。
 * issue #8 write-tests：补常量与狗数据访问器/写入口签名（体 throw），
 * 继承 EventDispatcher（原版 setDogData/changeDog 派发 DogLoaded）。
 */
@:keep
class NPCModel extends EventDispatcher {
	// NPCModel.as:16-18（internal static const → public：同包 NPCView 原版
	// 同样引用，Haxe 无包可见性）
	public static final EVENT_DOG_LOADED:String = "DogLoaded";
	public static final EVENT_DOG_FOOD_LOADED:String = "DogFoodLoaded";

	public function new() {
		super();
	}

	// NPCModel.as（resetLoadingFlags：网络中断后复位请求标志，V3b 片）
	public function resetLoadingFlags():Void {}

	// NPCModel.as:65-72（dogHungry getter：m_dog null → false，否则
	// _isHungry > 0；V3b 实现）
	public var dogHungry(get, never):Bool;

	private function get_dogHungry():Bool {
		throw new Error("not implemented");
	}

	// NPCModel.as:74-89（setDogData：首只存引用，后续在存量对象上合并
	// _dogId(≠-1 才写)/_isHungry，每次派发 EVENT_DOG_LOADED；V3b 实现）
	public function setDogData(param1:Dog):Void {
		throw new Error("not implemented");
	}

	// NPCModel.as:91-109（changeDog：无狗新建 {dogId, isHungry:1}，有狗只换
	// dogId；写 Session.sceneDecorates 的 DECOR_DOG 键；V3b 实现）
	public function changeDog(param1:Int):Void {
		throw new Error("not implemented");
	}

	// NPCModel.as:130-137（dogID getter：m_dog null → -1；V3b 实现）
	public var dogID(get, never):Int;

	private function get_dogID():Int {
		throw new Error("not implemented");
	}
}
