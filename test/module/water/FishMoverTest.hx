package module.water;

import entities.PoolFish;
import openfl.geom.Point;
import utest.Assert;

/**
 * FishMover 纯逻辑（issue #37）：鱼群游动状态机的可测纯面——
 * formatFishName 的鱼动画符号命名约定（FishAnimationMgr.createFishMC 的
 * 键，FS/FJ 前缀 + Utils.formatNumber(type,2) 补零 + level 钳 2 + dir）、
 * equalZeroSpeed 的 0.05 平方和阈值、stop() 的冻结语义（IDLE 态 + 永不
 * 再思考）、ctor 初始态与 _mc 为 null 的访问器退化。
 * think()/moveFrame()/checkCD() 等走 Math.random 与 WaterPool/MovieClip
 * 的路径不进单测（随机数/显示对象），归 CI 时间轴比对。
 * _waterPool 在构造期只存引用不解引用（FishMover.as:71-90），传 null 即可
 * 覆盖纯分支；私有成员经 @:access 直取（FriendsModelTest 先例）。
 *
 * 出处：
 * - legacy/decompiled/pool_v_13/scripts/module/water/FishMover.as
 *   （ctor :71-90、stop :92-105、get x :137-144、localToGlobal :146-153、
 *   get loaded :201-204、get hFlip :206-213、formatFishName :244-260、
 *   equalZeroSpeed :412-423、get fish :623-626、get y :810-817）
 * - common/misc/Utils.hx:165-171（formatNumber(x,2)=Std.string(x+100)
 *   .substr(1,2)：2→"02"、4→"04"、13→"13"）
 * - spec/modules/water-ui.json（FAST_SPEED=1.2 等常量与帧驱动语义的模块
 *   级描述；本测试只经行为/白盒字段钉数值，不引用常量名，避免钉死实现
 *   的常量形态选择）
 */
@:access(module.water.FishMover)
class FishMoverTest {
	public function new() {}

	var fish:PoolFish;

	public function setup() {
		fish = new PoolFish({i: 5, fid: 2, l: 15, o: 15, p: -82800}); // 配置无关，仅作引用
	}

	// :244-260：前缀 F + S/J + "_" + formatNumber(type,2) + "_" +
	// min(level,2) + "_" + dir；S 覆盖 IDLE/SWIM/ADJUST 与未列态（含
	// CENTER），J 仅 JUMP（:255-258 level 钳 2）
	public function test_formatFishName_symbol_naming() {
		var mover = new FishMover(null, fish);
		var cases:Array<{state:String, type:Int, level:Int, dir:Int, expected:String, why:String}> = [
			{state: "SWIM", type: 2, level: 0, dir: 0, expected: "FS_02_0_0", why: "SWIM→S"},
			{state: "IDLE", type: 2, level: 1, dir: 1, expected: "FS_02_1_1", why: "IDLE→S"},
			{state: "ADJUST", type: 13, level: 2, dir: 3, expected: "FS_13_2_3", why: "ADJUST→S"},
			{state: "CENTER", type: 4, level: 0, dir: 2, expected: "FS_04_0_2", why: "未列态落默认 S"},
			{state: "JUMP", type: 4, level: 0, dir: 0, expected: "FJ_04_0_0", why: "JUMP→J"},
			{state: "JUMP", type: 4, level: 3, dir: 2, expected: "FJ_04_2_2", why: "level 3 钳 2"},
			{state: "JUMP", type: 4, level: 7, dir: 1, expected: "FJ_04_2_1", why: "level 7 钳 2"}
		];
		for (c in cases) {
			Assert.equals(c.expected,
				mover.formatFishName(c.state, c.type, c.level, c.dir),
				'${c.state}/${c.type}/${c.level}/${c.dir}（${c.why}）');
		}
	}

	// :412-423：null → true（:413-416）；x²+y² <= 0.05（:418，分量平方，
	// 符号无关）
	public function test_equalZeroSpeed_threshold() {
		var mover = new FishMover(null, fish);
		Assert.isTrue(mover.equalZeroSpeed(null));
		Assert.isTrue(mover.equalZeroSpeed(new Point(0, 0)));
		Assert.isTrue(mover.equalZeroSpeed(new Point(0.1, 0.1))); // 0.02
		Assert.isTrue(mover.equalZeroSpeed(new Point(0.2, 0.05))); // 0.0425
		Assert.isTrue(mover.equalZeroSpeed(new Point(0.15, -0.1))); // 0.0325，负分量按平方
		Assert.isFalse(mover.equalZeroSpeed(new Point(0.75, 0))); // 0.5625
		Assert.isFalse(mover.equalZeroSpeed(new Point(1, 1))); // 2
	}

	// :92-105 stop()：_mc 为 null 时跳过 Utils.stroke（:101-103），状态面
	// 全落：IDLE 态、速度/加速度清零、frameDuration=IDLE_DURATION(8)、
	// status=NORMAL、step 归零、nextThinkingTime=99999999（永不思考）
	public function test_stop_freezes_motion_state() {
		var mover = new FishMover(null, fish);
		mover.stop();
		Assert.equals("IDLE", mover._state); // :94
		Assert.equals(0, mover._velocity.x); // :95
		Assert.equals(0, mover._velocity.y);
		Assert.equals(0, mover._acc.x); // :96
		Assert.equals(0, mover._acc.y);
		Assert.equals(8, mover._frameDuration); // :97 IDLE_DURATION
		Assert.equals(2, mover._status); // :98 NORMAL
		Assert.equals(0, mover._step); // :99
		Assert.equals(99999999, mover._nextThinkingTime); // :100
	}

	// :71-90 ctor 初始态（_mc 为 null 的退化访问器 ：137-144/:146-153/
	// :201-204/:206-213/:623-626/:810-817）
	public function test_ctor_initial_state_and_null_mc_accessors() {
		var mover = new FishMover(null, fish);
		Assert.equals(fish, mover.fish); // :623-626 构造期存引用
		Assert.isFalse(mover.loaded); // :201-204
		Assert.isFalse(mover.hFlip); // :206-213
		Assert.equals(0, mover.x); // :137-144
		Assert.equals(0, mover.y); // :810-817
		Assert.isNull(mover.localToGlobal(null)); // :147-149
		var p = new Point(3, 4);
		Assert.equals(p, mover.localToGlobal(p)); // :150-153 原样返回

		Assert.equals("SWIM", mover._state); // :76
		Assert.equals(-1, mover._dir); // :77
		Assert.equals(2, mover._status); // :78 NORMAL
		Assert.equals(4, mover._frameDuration); // :79 NORMAL_DURATION
		Assert.equals(0, mover._step); // :80
		Assert.equals(0, mover._nextThinkingTime); // :81
		Assert.equals(0, mover._cdt); // :82
		Assert.equals(0, mover._corner); // :83
		Assert.isNull(mover._mc); // :84
		Assert.isNull(mover._wps); // :85
		Assert.isNull(mover._spawnPos); // :86
		Assert.isTrue(mover._checkLoading); // :87
		Assert.isNull(mover._waterPool); // 测试注入 null
	}
}
