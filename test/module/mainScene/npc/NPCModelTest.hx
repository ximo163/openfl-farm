package module.mainScene.npc;

import common.Consts;
import common.Session;
import entities.Dog;
import module.FarmApplication;
import utest.Assert;

/**
 * NPCModel 的狗数据纯逻辑（issue #8）。issue 文案猜的「NPC 行走参数」在原版
 * NPCView/NPCModel 里不存在——NPCModel 管的是狗状态，以 legacy 为准。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/module/mainScene/npc/NPCModel.as
 * （dogHungry :65-72、setDogData :74-89、changeDog :91-109、dogID :130-137）。
 *
 * changeDog 写 Session.sceneDecorates（:104-108，键 DECOR_DOG.toString()="8"）：
 * Session 的存取经 app.model 的 UserDecorate 键，测试按启动链给 Session 装 app
 * 并预置空装饰表（真游戏在 Main 启动时设 Session.app）。
 */
class NPCModelTest {
	public function new() {}

	// 每个用例重置装饰表，避免单例跨用例串数据
	static function pinSceneDecorates():Void {
		var app = new FarmApplication();
		Session.getInstance().app = app;
		app.model.setData(Consts.USER_DECORATE_OBJECT, {});
	}

	// dogID :130-137 / dogHungry :65-72：没有狗时 -1 / false
	public function test_dog_accessors_default_without_dog() {
		var model = new NPCModel();
		Assert.equals(-1, model.dogID);
		Assert.isFalse(model.dogHungry);
	}

	// setDogData :74-89：首次直接存引用并派发 EVENT_DOG_LOADED（:88，data 是
	// 存储的 Dog）；再次调用在存量对象上合并——_dogId != -1 才覆写（:82-85）、
	// _isHungry 无条件覆写（:86），存储实例不换
	public function test_setDogData_first_store_then_merge_in_place() {
		var model = new NPCModel();
		var loaded:Array<Dynamic> = [];
		model.addEventListener(NPCModel.EVENT_DOG_LOADED, function(e) loaded.push(e.data));
		var first = new Dog({dogId: 5, isHungry: 1});
		model.setDogData(first);
		Assert.equals(1, loaded.length);
		Assert.equals(first, loaded[0]); // :78 存引用
		Assert.equals(5, model.dogID);
		Assert.isTrue(model.dogHungry); // _isHungry 1 > 0（:71）

		model.setDogData(new Dog({dogId: 6, isHungry: 0}));
		Assert.equals(6, model.dogID); // :84 覆写
		Assert.isFalse(model.dogHungry); // :86 覆写
		Assert.equals(first, loaded[1]); // :88 派发的还是存量实例

		model.setDogData(new Dog({dogId: -1, isHungry: 2}));
		Assert.equals(6, model.dogID); // :82 dogId -1 不覆写
		Assert.isTrue(model.dogHungry);
		Assert.equals(3, loaded.length); // 每次都派发
	}

	// changeDog :91-109：无狗时新建（dogId=param1、isHungry=1，:95-98）；
	// 已有狗只换 dogId（:101，饥饿态不动）；每次派发并写 sceneDecorates 的
	// DECOR_DOG 键 {itemId:param1}（:103-108）
	public function test_changeDog_creates_or_replaces_and_records_decor() {
		pinSceneDecorates();
		var model = new NPCModel();
		var loaded:Array<Dynamic> = [];
		model.addEventListener(NPCModel.EVENT_DOG_LOADED, function(e) loaded.push(e.data));
		model.changeDog(3);
		Assert.equals(3, model.dogID);
		Assert.isTrue(model.dogHungry); // 新狗 isHungry=1（:97）
		Assert.equals(1, loaded.length);
		Assert.equals(3, Reflect.field(Reflect.field(Session.getInstance().sceneDecorates, "8"), "itemId"));

		model.setDogData(new Dog({dogId: 2, isHungry: 0})); // 存量狗，改不换实例
		model.changeDog(7);
		Assert.equals(7, model.dogID);
		Assert.isFalse(model.dogHungry); // :100-102 不动 _isHungry
		Assert.equals(2, loaded.length); // :103 派发
		Assert.equals(7, Reflect.field(Reflect.field(Session.getInstance().sceneDecorates, "8"), "itemId"));
	}
}
