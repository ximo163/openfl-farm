package mc.model;

import mc.model.FarmData;
import utest.Assert;

/**
 * mc.model.FarmData 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 牧场农场数据的常量面值、killFly 双扣数与事件、setter 派发矩阵。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/model/FarmData.as
 * —— 事件名常量 :15-37（USER_SEED "userSeedChange" :15、ANIMAL_FOOD
 * "animalFoodChange" :27、PACKAGE_FOOD "pack_age_food" :29、
 * FLY_DATA_CHANGE "fly_data_change" :33、BB_DATA_CHANGE "bb_data_change"
 * :35、INSECT_KILL "insect_kill" :37、CLEAR_BB "clear_bb_pos" :49、
 * FARM_OPERATE "farmOperate" :19、HARVEST_DATA "harvestData" :21、
 * USER_SEED_ERR "userSeedErr" :25、USER_SEED_LOADING "userSeedLoading"
 * :17、ACTIVITY_ITEMS "activityItemsChange" :31、ENEMY_CHANGE
 * "enemy_change" :51、BEAT_ANIMAL "beat_animal" :65、USE_ANIMAL_CUB
 * "USE_ANIMAL_CUB" :67、ADD_HEALTH "addHealth" :23）；动物状态序号
 * :53-63（YOUZAI 1、SHENGZHANG 2、DAICHAN 3、SHENGCHAN 4、CHANHOU 5、
 * SHOUHUO 6）；静态位初值 :39-47（maxFly false、maxErrInfo
 * "每天最多使坏25次"、leftFly -1、totalExp false、totalBB false）；
 * killFly :156-161（_flyData["flyNum"+param1] -= param2、
 * _flyData["num"] -= param2、派发 FLY_DATA_CHANGE）；setter 派发：
 * animalFood :251-255（ANIMAL_FOOD，ModelEvent）、bbData :126-130
 * （BB_DATA_CHANGE，Event）、clearBBPos :120-124（CLEAR_BB，Event）、
 * insectExp :169-173（INSECT_KILL，Event）、userSeed :163-167（USER_SEED，
 * ModelEvent）、animalPackFood :218-222（PACKAGE_FOOD，ModelEvent）、
 * harvestData :229-233（HARVEST_DATA，ModelEvent）、flyData :245-249
 * （FLY_DATA_CHANGE，Event）、userSeedLoading :104-108
 * （USER_SEED_LOADING，ModelEvent）、userSeedErr :195-199（USER_SEED_ERR，
 * ModelEvent）、activityItems :206-210（ACTIVITY_ITEMS，ModelEvent）、
 * farmOperate :212-216（FARM_OPERATE，ModelEvent）；reloadUserSeed
 * :142-149（true 才派发 "reloadUserSeed"——注意事件类型串是字面量
 * "reloadUserSeed" 不是常量）。getter 全为 backing 直返（:110-113 等）。
 *
 * stub 期形态：setter 全部 throw not implemented、killFly throw——本测试
 * 必然等 implement 充真身才绿（write-tests 的意图即如此）。getter 在
 * stub 已实现为 backing 直返，但 setter 不写 backing——直接验证 getter
 * 缺省态（null/空/初值）而非先 set 再 get。
 */
@:access(mc.model.FarmData)
class FarmDataTest {
	var fd:FarmData;

	public function new() {}

	function setup() {
		fd = new FarmData();
	}

	// 事件名常量面值（FarmData.as:15-67）
	public function test_event_constants() {
		Assert.equals("userSeedChange", FarmData.USER_SEED);
		Assert.equals("userSeedLoading", FarmData.USER_SEED_LOADING);
		Assert.equals("farmOperate", FarmData.FARM_OPERATE);
		Assert.equals("harvestData", FarmData.HARVEST_DATA);
		Assert.equals("addHealth", FarmData.ADD_HEALTH);
		Assert.equals("userSeedErr", FarmData.USER_SEED_ERR);
		Assert.equals("animalFoodChange", FarmData.ANIMAL_FOOD);
		Assert.equals("pack_age_food", FarmData.PACKAGE_FOOD);
		Assert.equals("activityItemsChange", FarmData.ACTIVITY_ITEMS);
		Assert.equals("fly_data_change", FarmData.FLY_DATA_CHANGE);
		Assert.equals("bb_data_change", FarmData.BB_DATA_CHANGE);
		Assert.equals("insect_kill", FarmData.INSECT_KILL);
		Assert.equals("clear_bb_pos", FarmData.CLEAR_BB);
		Assert.equals("enemy_change", FarmData.ENEMY_CHANGE);
		Assert.equals("beat_animal", FarmData.BEAT_ANIMAL);
		Assert.equals("USE_ANIMAL_CUB", FarmData.USE_ANIMAL_CUB);
	}

	// 动物状态序号（FarmData.as:53-63）：1..6 连续
	public function test_animal_status_sequence() {
		Assert.equals(1, FarmData.ANIMAL_YOUZAI);
		Assert.equals(2, FarmData.ANIMAL_SHENGZHANG);
		Assert.equals(3, FarmData.ANIMAL_DAICHAN);
		Assert.equals(4, FarmData.ANIMAL_SHENGCHAN);
		Assert.equals(5, FarmData.ANIMAL_CHANHOU);
		Assert.equals(6, FarmData.ANIMAL_SHOUHUO);
	}

	// 静态位初值（FarmData.as:39-47）
	public function test_static_initial_values() {
		Assert.isFalse(FarmData.maxFly);
		Assert.equals("每天最多使坏25次", FarmData.maxErrInfo);
		Assert.equals(-1, FarmData.leftFly);
		Assert.isFalse(FarmData.totalExp);
		Assert.isFalse(FarmData.totalBB);
	}

	// killFly（FarmData.as:156-161）：flyNum<idx> 与 num 双扣 param2 +
	// 派发 FLY_DATA_CHANGE。flyData setter 是 throw-stub——经 @:access 直接
	// 布置 _flyData backing（等价 setter 充真身后的写入结果），再调 killFly
	// 钉双扣语义。
	public function test_killFly_double_decrement() {
		fd._flyData = {flyNum3: 10, num: 25};
		var dispatched = false;
		fd.addEventListener(FarmData.FLY_DATA_CHANGE, function(e) dispatched = true);
		fd.killFly(3, 4);
		Assert.equals(6, fd._flyData.flyNum3); // 10-4
		Assert.equals(21, fd._flyData.num); // 25-4
		Assert.isTrue(dispatched);
	}

	// killFly 对其他 idx 键不动（"flyNum" + param1 的键名拼接语义）
	public function test_killFly_only_indexed_key() {
		fd._flyData = {flyNum1: 8, flyNum2: 12, num: 20};
		fd.killFly(1, 3);
		Assert.equals(5, fd._flyData.flyNum1); // 8-3
		Assert.equals(12, fd._flyData.flyNum2); // 不动
		Assert.equals(17, fd._flyData.num); // 20-3
	}

	// setter 派发矩阵（逐 setter 的事件类型串与事件类）。事件类型串是
	// 核心钉点；事件类（ModelEvent vs Event）在 AS3 双类同继承 Event，
	// 监听侧无差异，但类型串本身逐字钉。
	public function test_animalFood_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.ANIMAL_FOOD, function(e) got.push(e.type));
		fd.animalFood = 5;
		Assert.equals("animalFoodChange", got.join(","));
		Assert.equals(5, fd.animalFood);
	}

	public function test_bbData_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.BB_DATA_CHANGE, function(e) got.push(e.type));
		var data = {x: 1};
		fd.bbData = data;
		Assert.equals("bb_data_change", got.join(","));
		Assert.equals(data, fd.bbData);
	}

	public function test_clearBBPos_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.CLEAR_BB, function(e) got.push(e.type));
		fd.clearBBPos = 3;
		Assert.equals("clear_bb_pos", got.join(","));
		Assert.equals(3, fd.clearBBPos);
	}

	public function test_insectExp_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.INSECT_KILL, function(e) got.push(e.type));
		fd.insectExp = {exp: 10};
		Assert.equals("insect_kill", got.join(","));
		Assert.equals(10, fd.insectExp.exp);
	}

	public function test_userSeed_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.USER_SEED, function(e) got.push(e.type));
		fd.userSeed = [1, 2];
		Assert.equals("userSeedChange", got.join(","));
		Assert.equals(2, fd.userSeed.length);
	}

	public function test_animalPackFood_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.PACKAGE_FOOD, function(e) got.push(e.type));
		fd.animalPackFood = {n: 1};
		Assert.equals("pack_age_food", got.join(","));
		Assert.equals(1, fd.animalPackFood.n);
	}

	public function test_harvestData_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.HARVEST_DATA, function(e) got.push(e.type));
		fd.harvestData = {h: 1};
		Assert.equals("harvestData", got.join(","));
		Assert.equals(1, fd.harvestData.h);
	}

	public function test_flyData_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.FLY_DATA_CHANGE, function(e) got.push(e.type));
		fd.flyData = {num: 5};
		Assert.equals("fly_data_change", got.join(","));
		Assert.equals(5, fd.flyData.num);
	}

	public function test_userSeedLoading_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.USER_SEED_LOADING, function(e) got.push(e.type));
		fd.userSeedLoading = true;
		Assert.equals("userSeedLoading", got.join(","));
		Assert.isTrue(fd.userSeedLoading);
	}

	public function test_userSeedErr_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.USER_SEED_ERR, function(e) got.push(e.type));
		fd.userSeedErr = "err";
		Assert.equals("userSeedErr", got.join(","));
		Assert.equals("err", fd.userSeedErr);
	}

	public function test_activityItems_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.ACTIVITY_ITEMS, function(e) got.push(e.type));
		fd.activityItems = [1];
		Assert.equals("activityItemsChange", got.join(","));
		Assert.equals(1, fd.activityItems.length);
	}

	public function test_farmOperate_setter_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener(FarmData.FARM_OPERATE, function(e) got.push(e.type));
		fd.farmOperate = {op: 1};
		Assert.equals("farmOperate", got.join(","));
		Assert.equals(1, fd.farmOperate.op);
	}

	// reloadUserSeed（FarmData.as:142-149）：true 才派发，事件类型串是
	// 字面量 "reloadUserSeed"（不是常量——原文直接写字符串）
	public function test_reloadUserSeed_true_dispatches() {
		var got:Array<String> = [];
		fd.addEventListener("reloadUserSeed", function(e) got.push(e.type));
		fd.reloadUserSeed = true;
		Assert.equals("reloadUserSeed", got.join(","));
		Assert.isTrue(fd.reloadUserSeed);
	}

	public function test_reloadUserSeed_false_no_dispatch() {
		fd._reloadUserSeed = true; // 先置 true 避免缺省 true 干扰
		var got:Array<String> = [];
		fd.addEventListener("reloadUserSeed", function(e) got.push(e.type));
		fd.reloadUserSeed = false;
		Assert.equals("", got.join(","));
		Assert.isFalse(fd.reloadUserSeed);
	}

	// getter 缺省态（backing 直返，初值见 :69-97）：未 set 时
	// animalFood 0（:75 AS3 int 字段缺省 0——注意 eval 上无初值的 Int
	// backing 读回 null，implement 须按 AS3 语义补 = 0 初值；null-Int
	// 坑见 handbook/lessons）、bbData {} 非 null（:77 有初值）、
	// userSeedErr ""（:81）、reloadUserSeed true（:83）、
	// userSeedLoading false（:69）、activityItemsLoading false（:71）
	public function test_getter_defaults() {
		Assert.equals(0, fd.animalFood);
		Assert.notNull(fd.bbData);
		Assert.equals("", fd.userSeedErr);
		Assert.isTrue(fd.reloadUserSeed);
		Assert.isFalse(fd.userSeedLoading);
		Assert.isFalse(fd.activityItemsLoading);
		Assert.isNull(fd.userSeed);
		Assert.isNull(fd.harvestData);
		Assert.isNull(fd.flyData);
		Assert.isNull(fd.farmOperate);
		Assert.isNull(fd.insectExp);
		Assert.isNull(fd.animalPackFood);
		Assert.isNull(fd.activityItems);
	}
}
