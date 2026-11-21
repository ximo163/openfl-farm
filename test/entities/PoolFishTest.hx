package entities;

import common.CommonData;
import common.Settings;
import com.qzone.qfa.interfaces.IModel;
import utest.Assert;

/**
 * PoolFish 实体纯逻辑（issue #29）：鱼塘格位状态的导入/刷新与等级、喂食、
 * 产量、剩余时间的全部公式。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/entities/PoolFish.as
 *   （ctor :32-40、calcNextStepTime :42-60、importObject :62-93、
 *   canHarvest :96-99、level :101-132、cycles :134-161、name :168-175、
 *   min :177-194、refreshStatus :196-217、leftTime :219-259、poolSize :261-268）
 * - 配置行：legacy/deploy/QFarmFlash/source/core/source/xml/mod/nc_data.php
 *   :7565 fish_info 数组（单行）——小丑鱼 id 2 cycle "21600,50400,82800"
 *   output 15 pool_size 1；蝶鱼 id 4 output 24；蝠鲼 id 13 pool_size 2；
 *   海豚 id 14 pool_size 3。id 与 cycle 等保持 JSON 数字/字符串原形状。
 * - 状态载荷键：spec/protocol.json cgi_fish_index 条目（fish[].fid/p/o/l/s，
 *   cgi_fish_index.php:34-41）+ cgi_fish_plant.php:41（放养写 f=0）+
 *   cgi_fish_fertilize.php:43（喂食回 i/f/l/o/p；f=已达到阶段数+1）。
 *
 * 等级公式（:101-132）读 CommonData.serverTime——测试钉 serverTime=0 走
 * get 的 _serverTime==0 纯分支（不读时钟，CommonData.hx:141-148，
 * FarmLandTest 同口径），「已流逝秒数」用负 p 合成（elapsed=serverTime-p）。
 * Settings 经 m_configDataModel 注入 FakeConfigModel（LevelUpModelTest 先例）；
 * fish_info 的 id 是 JSON 数字、PoolFish 按 Std.string(_type) 查——钉住
 * Settings.getFishByID 的数字↔字符串松等（As3.eqString，lessons #8）。
 */
@:access(common.Settings)
class PoolFishTest {
	public function new() {}

	public function setup() {
		var s = Settings.getInstance();
		s.loadLocalSettings(null); // m_params = null、m_appImgPrefix 复位 ""
		s.m_configDataModel = null;
		// get_serverTime 的 _serverTime==0 纯分支：不读时钟（CommonData.hx:141-148）
		CommonData.serverTime = 0;
	}

	public function teardown() {
		var s = Settings.getInstance();
		s.loadLocalSettings(null);
		s.m_configDataModel = null;
		CommonData.serverTime = 0;
	}

	// nc_data.php:7565 小丑鱼行逐字裁剪（PoolFish 只读 id/cycle/crop_name/
	// output/pool_size 五键；id 保持 JSON 数字原形状）
	static function clownRow():Dynamic {
		return {"crop_name": "小丑鱼", "cycle": "21600,50400,82800", "id": 2,
			"output": 15, "pool_size": 1};
	}

	// nc_data.php:7565 蝶鱼（output 24）与蝠鲼/海豚（pool_size 2/3）行逐字裁剪
	static function butterflyRow():Dynamic {
		return {"crop_name": "蝶鱼", "cycle": "28800,64800,108000", "id": 4,
			"output": 24, "pool_size": 1};
	}

	static function mantaRow():Dynamic {
		return {"crop_name": "蝠鲼", "cycle": "54000,126000,216000", "id": 13,
			"output": 29, "pool_size": 2};
	}

	static function dolphinRow():Dynamic {
		return {"crop_name": "海豚", "cycle": "57600,129600,244800", "id": 14,
			"output": 25, "pool_size": 3};
	}

	static function pinFishInfo(rows:Array<Dynamic>):Void {
		Settings.getInstance().m_configDataModel = new FakeConfigModel({"fish_info": rows});
	}

	// PoolFishTest 全用例都需小丑鱼在表里（:70 fid → :101 level 查它）
	static function pinDefault():Void {
		pinFishInfo([clownRow(), butterflyRow(), mantaRow(), dolphinRow()]);
	}

	// :64-77 映射 + :77-79 缺 s 补空数组；:64-66 null 载荷早退（ctor :34 的
	// _fertilize=true 保持）；:72 `param1["s"] as Array` 是同引用不拷贝
	public function test_importObject_maps_slot_payload_and_defaults_thief() {
		pinDefault();
		var fish = new PoolFish({i: 5, fid: 2, l: 3, o: 15, p: -3600});
		Assert.equals(5, fish._id);
		Assert.equals(2, fish._type);
		Assert.equals(3, fish._left);
		Assert.equals(15, fish._output);
		Assert.equals(-3600, fish._plantTime);
		Assert.isTrue(fish._thief != null); // 缺 s → new Array()（:77-79）
		Assert.equals(0, fish._thief.length);

		// s 给了就用原数组（:72 as Array 同引用）：动 s 能看到 _thief 跟着动
		var s = [500, 600];
		var fish2 = new PoolFish({i: 5, fid: 2, l: 3, o: 15, p: -3600, s: s});
		Assert.equals(2, fish2._thief.length);
		s.push(700);
		Assert.equals(3, fish2._thief.length); // 同引用而非拷贝

		// null 载荷早退：ctor :34 的 _fertilize=true 不被 :82-87 的复位碰到
		var fish3 = new PoolFish(null);
		Assert.isTrue(fish3._fertilize);
	}

	// ctor :32-40 顺序：importObject（:76 内调 calcNextStepTime 算出值）之后
	// _nextStepTime 才被清零——新鱼恒为 0
	public function test_ctor_resets_nextStepTime_after_import() {
		pinDefault();
		var fish = new PoolFish({i: 5, fid: 2, l: 3, o: 15, p: -3600});
		Assert.equals(0, fish._nextStepTime);
	}

	// :78-87 喂食标记 f（1/2/3 才判，其余含缺省一律 false）：
	// _fertilize = (f == level+1)；level 按 serverTime-p 落在哪段 cycle。
	// 小丑鱼 cycle 21600/50400/82800，serverTime=0 → 负 p 合成鱼龄。
	public function test_fertilize_flag_matches_stage_after_level() {
		pinDefault();
		var cases:Array<{payload:Dynamic, expected:Bool, why:String}> = [
			// p=-3600 → level 0；f=1 == 0+1 → 已喂本阶段（cgi_fish_fertilize
			// 回 f=ii+1，ii 为 now-p 已达阶段数）
			{payload: {fid: 2, p: -3600, f: 1}, expected: true, why: "level0 f1"},
			{payload: {fid: 2, p: -3600, f: 2}, expected: false, why: "level0 f2"},
			{payload: {fid: 2, p: -3600}, expected: false, why: "缺 f"},
			{payload: {fid: 2, p: -3600, f: 0}, expected: false, why: "f=0 出 1..3"},
			{payload: {fid: 2, p: -3600, f: 4}, expected: false, why: "f=4 出 1..3"},
			// p=-21600 → elapsed 21600：21600<21600 不成立 → level 1
			{payload: {fid: 2, p: -21600, f: 2}, expected: true, why: "level1 f2"},
			{payload: {fid: 2, p: -21600, f: 1}, expected: false, why: "level1 f1"},
			// p=-82800 → elapsed 82800 → level 3（=cycle 段数，Consts.as:568
			// FISH_MAX_LEVEL=3）：:84-86 满级钳 false
			{payload: {fid: 2, p: -82800, f: 3}, expected: false, why: "level3 钳 false"},
			// 配置缺失 → level -1（:101-132 st null 分支）；f==(-1)+1=0 恒不中
			{payload: {fid: 777, p: -3600, f: 1}, expected: false, why: "无配置 level-1"}
		];
		for (c in cases) {
			var fish = new PoolFish(c.payload);
			Assert.equals(c.expected, fish._fertilize, 'payload=${c.payload}（${c.why}）');
		}
	}

	// :101-132 level：elapsed=serverTime-p 落在 cycle 首个大于它的下标；
	// elapsed<0 → -1；全越界 → cycles 段数。:96-99 canHarvest=level>=3
	//（Consts.as:568）
	public function test_level_bands_and_canHarvest() {
		pinDefault();
		var cases:Array<{p:Int, expected:Int, why:String}> = [
			{p: -3600, expected: 0, why: "第一段内"},
			{p: -21599, expected: 0, why: "第一段内（1 秒前）"},
			{p: -21600, expected: 1, why: "恰到第一段末：21600<21600 不成立"},
			{p: -50400, expected: 2, why: "恰到第二段末"},
			{p: -82800, expected: 3, why: "越出全部段 → 段数 3（=FISH_MAX_LEVEL）"},
			{p: -100000, expected: 3, why: "远越界仍 3"}
		];
		for (c in cases) {
			var fish = new PoolFish({fid: 2, p: c.p});
			Assert.equals(c.expected, fish.level, 'p=${c.p}（${c.why}）');
		}
		// elapsed<0（p 在 serverTime 之后的时钟偏斜形态）→ -1，canHarvest false
		var future = new PoolFish({fid: 2, p: 3600});
		Assert.equals(-1, future.level);
		Assert.isFalse(future.canHarvest);
		// 满级可收获；倒数第二段不可
		Assert.isTrue(new PoolFish({fid: 2, p: -82800}).canHarvest);
		Assert.isFalse(new PoolFish({fid: 2, p: -50400}).canHarvest);
	}

	// :134-161 cycles：cycle 逗号串逐段 parseFloat；行缺 cycle 键或鱼不在表
	// → null，level/-1、leftTime null、canHarvest false
	public function test_cycles_parses_cycle_string_and_null_without_config() {
		pinDefault();
		var fish = new PoolFish({fid: 2, p: -3600});
		Assert.equals(3, fish.cycles.length);
		Assert.equals(21600.0, fish.cycles[0]); // nc_data.php:7565 小丑鱼 cycle
		Assert.equals(50400.0, fish.cycles[1]);
		Assert.equals(82800.0, fish.cycles[2]);

		// 行缺 cycle 键（真实表都有；值合成钉 :143-146 的 undefined 分支）
		pinFishInfo([{"crop_name": "无周期鱼", "id": 2, "output": 15, "pool_size": 1}]);
		var noCycle = new PoolFish({fid: 2, p: -3600});
		Assert.isNull(noCycle.cycles);
		Assert.equals(-1, noCycle.level);
		Assert.isNull(noCycle.leftTime);
		Assert.isFalse(noCycle.canHarvest);

		// 鱼种不在表 → st null（:101-108）同形态
		pinDefault();
		var unknown = new PoolFish({fid: 777, p: -3600});
		Assert.isNull(unknown.cycles);
		Assert.equals(-1, unknown.level);
		Assert.isNull(unknown.leftTime);
	}

	// :42-60 calcNextStepTime：level<0 早退不清值；level 3 → +∞；
	// 其余 = _plantTime + cycles[level]
	public function test_calcNextStepTime_bands() {
		pinDefault();
		// level 0：-3600 + cycles[0] 21600
		var f0 = new PoolFish({fid: 2, p: -3600});
		f0.calcNextStepTime();
		Assert.equals(18000.0, f0._nextStepTime);
		// level 1（elapsed 36000 落第二段）：-36000 + 50400
		var f1 = new PoolFish({fid: 2, p: -36000});
		f1.calcNextStepTime();
		Assert.equals(14400.0, f1._nextStepTime);
		// level 3 → Number.POSITIVE_INFINITY（:51-54）
		var f3 = new PoolFish({fid: 2, p: -82800});
		f3.calcNextStepTime();
		Assert.equals(Math.POSITIVE_INFINITY, f3._nextStepTime);
		// level<0 早退：保持调用前的值（:44-48）
		pinFishInfo([]); // 空表 → st null → level -1
		var fn = new PoolFish({fid: 2, p: -3600});
		fn._nextStepTime = 12345;
		fn.calcNextStepTime();
		Assert.equals(12345.0, fn._nextStepTime);
	}

	// :177-194 min：_output>0 用 _output，否则取配置 output（parseFloat）；
	// 一律 ceil(值*0.6)
	public function test_min_formula_uses_output_then_config() {
		pinDefault();
		var cases:Array<{payload:Dynamic, expected:Int, why:String}> = [
			// 15*0.6=9.0 → ceil 9
			{payload: {fid: 2, o: 15, p: -3600}, expected: 9, why: "自带 output 15"},
			// 24*0.6=14.4 → ceil 15
			{payload: {fid: 2, o: 24, p: -3600}, expected: 15, why: "小数进位"},
			// 4*0.6=2.4 → ceil 3（值合成钉 ceil）
			{payload: {fid: 2, o: 4, p: -3600}, expected: 3, why: "ceil 上取整"},
			// o 缺省 0 → 小丑鱼配置 output 15 → 9
			{payload: {fid: 2, p: -3600}, expected: 9, why: "回退配置 output 15"},
			// 蝶鱼配置 output 24 → 15
			{payload: {fid: 4, p: -3600}, expected: 15, why: "蝶鱼配置 24"}
		];
		for (c in cases) {
			var fish = new PoolFish(c.payload);
			Assert.equals(c.expected, fish.min, 'payload=${c.payload}（${c.why}）');
		}
		// 配置缺失但 _output>0：min 不查表（:180-182 先判）
		pinFishInfo([]);
		var orphan = new PoolFish({fid: 777, o: 10, p: -3600});
		Assert.equals(6, orphan.min);
	}

	// :219-259 leftTime：elapsed<=0 → null；未到段的返回
	// [本段剩余, 本段全长（首段取 cycles[0]，其后取相邻差）]；全越界 [0,0]
	public function test_leftTime_bands() {
		pinDefault();
		var cases:Array<{p:Int, expected:Array<Dynamic>, why:String}> = [
			// elapsed 3600 在第一段：[21600-3600, 21600]（首段全长=cycles[0]）
			{p: -3600, expected: [18000.0, 21600.0], why: "第一段"},
			// elapsed 21600 恰进第二段：[50400-21600, 50400-21600]（段差）
			{p: -21600, expected: [28800.0, 28800.0], why: "第二段起用相邻差"},
			// elapsed 50400 恰进第三段：[82800-50400, 82800-50400]
			{p: -50400, expected: [32400.0, 32400.0], why: "第三段"},
			// elapsed 82800 越出全部段 → [0,0]（:257）
			{p: -82800, expected: [0.0, 0.0], why: "全越界"},
			{p: -100000, expected: [0.0, 0.0], why: "远越界仍 [0,0]"}
		];
		for (c in cases) {
			var fish = new PoolFish({fid: 2, p: c.p});
			var lt = fish.leftTime;
			Assert.isFalse(lt == null, 'p=${c.p}（${c.why}）');
			Assert.equals(c.expected[0], lt[0], 'p=${c.p} 剩余（${c.why}）');
			Assert.equals(c.expected[1], lt[1], 'p=${c.p} 全长（${c.why}）');
		}
		// elapsed<=0 → null（:230-232；含恰好 0）
		Assert.isNull(new PoolFish({fid: 2, p: 0}).leftTime);
		Assert.isNull(new PoolFish({fid: 2, p: 3600}).leftTime);
		// 配置缺失 → null（:221-227 st null 分支）
		pinFishInfo([]);
		Assert.isNull(new PoolFish({fid: 777, p: -3600}).leftTime);
	}

	// :261-268 poolSize / :168-175 name：直接读配置行字段
	public function test_poolSize_and_name_from_config() {
		pinDefault();
		Assert.equals(1, new PoolFish({fid: 2, p: -3600}).poolSize); // 小丑鱼
		Assert.equals(2, new PoolFish({fid: 13, p: -3600}).poolSize); // 蝠鲼
		Assert.equals(3, new PoolFish({fid: 14, p: -3600}).poolSize); // 海豚
		Assert.equals("小丑鱼", new PoolFish({fid: 2, p: -3600}).name);
	}

	// :196-217 refreshStatus：只更新 l/o/p（缺省按 0 解析）与 f 标记；
	// _id/_type/_thief 不动；末尾 calcNextStepTime 无 ctor 式清零
	public function test_refreshStatus_updates_only_status_fields() {
		pinDefault();
		var s = [500, 600];
		var fish = new PoolFish({i: 5, fid: 2, l: 3, o: 15, p: -3600, f: 1, s: s});
		// p=-36000 → elapsed 36000 落第二段（level 1）→ f=2 == 1+1
		fish.refreshStatus({l: 9, o: 11, p: -36000, f: 2});
		Assert.equals(9, fish._left);
		Assert.equals(11, fish._output);
		Assert.equals(-36000, fish._plantTime);
		Assert.equals(5, fish._id); // 不动
		Assert.equals(2, fish._type); // 不动
		Assert.equals(2, fish._thief.length); // 不动
		s.push(700);
		Assert.equals(3, fish._thief.length); // 仍是原数组引用（未被重建/拷贝）
		Assert.isTrue(fish._fertilize);
		// :201 内调 calcNextStepTime：-36000 + cycles[1] 50400，且不清零
		Assert.equals(14400.0, fish._nextStepTime);

		// 只给 f=1：l/o/p 缺省按 0（:197-199 getIntAttribute）→ elapsed 0
		// → level 0 → f=1 == 0+1 → true
		fish.refreshStatus({f: 1});
		Assert.equals(0, fish._left);
		Assert.equals(0, fish._plantTime);
		Assert.isTrue(fish._fertilize);
		// f 缺省 → false（:211-216 else）
		fish.refreshStatus({l: 4, o: 5, p: -3600});
		Assert.isFalse(fish._fertilize);
		Assert.equals(18000.0, fish._nextStepTime); // p=-3600 level0 → -3600+21600
	}
}

/**
 * 测试用 IModel：getData 按表名取 Reflect 字段，其余 no-op（Settings 只经
 * getData 读 fish_info：getFishByID :90-110，LevelUpModelTest 同款）。
 */
private class FakeConfigModel implements IModel {
	var tables:Dynamic;

	public function new(tables:Dynamic) {
		this.tables = tables;
	}

	public function getData(param1:String):Dynamic {
		return Reflect.field(this.tables, param1);
	}

	public function flush():Void {}

	public function setData(param1:String, param2:Dynamic):Bool {
		return true;
	}

	public function notify(param1:String):Void {}

	public function removeNotifier(param1:String, param2:Dynamic):Void {}

	public function addNotifier(param1:String, param2:Dynamic):Void {}
}
