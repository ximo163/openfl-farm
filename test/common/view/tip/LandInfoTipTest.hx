package common.view.tip;

import common.CommonData;
import entities.FarmLand;
import utest.Assert;

/**
 * LandInfoTip 地块信息提示纯逻辑（issue #42）：countHealth 健康值衰减/
 * 动作档位公式、jsonToArray 动作日志时序化、data 路由（null 早退与
 * _cId 0 空地早退）、mX/mY 的 -60/-120 锚点偏移。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/common/view/tip/LandInfoTip.as
 *   （countHealth :59-170、data :354-369、jsonToArray :371-385、sortArray
 *   :413-420、mY :387-391、mX :393-397；ctor :33-44 的 _preTime=-1 :42、
 *   _frequence=5000 :37）。
 * - 动作日志形状（param7）：键=秒级时间戳字符串、值=动作码（标量或数组，
 *   :114 的 concat 两形态都吃）。PHP 侧按 $_QFG['timestamp'] 落键：
 *   legacy/deploy/QFarmFlash/source/core/source/nc/mod/farmlandstatus_pest.php
 *   :32-41（`$farm_p[$farm_time] = 1`，同秒撞键 +g 秒避让），经
 *   farmlandstatus_getoutput.php 的 `"action":qf_jsonCode($p)` 下发。
 * - FarmLand 空对象导入全默认（_cId=0）：src/entities/FarmLand.hx 的
 *   importObject 字段默认段。
 *
 * 期望值手推口径（每行注释附推导）：
 * - param1（健康值）与各 int 局部在 AS3 里逐次赋值截断——:107 的
 *   `param1 -= (loc8-param2)*loc9/60` 截断在**整式结果**上（96.667→96），
 *   不是截断被减项（那会得 97）；c6 行专门钉这个差。
 * - param6（currentTime）原文从不读（:59 声明后无引用），表驱动一律传 0。
 * - 无动作条目（含 :74 合成的 "2228612959":null 键）取 loc8=int(serverTime)
 *   （:82）；serverTime 钉 10000，其读数对 set 时刻有每秒 +1 的漂移
 *   （CommonData.hx:141-148 读 get_timer）——不等式分支余量 ≥200 秒、
 *   截断前的小数余量 ≥0.4，对漂移免疫（teardown 复位 0，PoolFishTest
 *   同口径）。
 * stub 阶段失败点：countHealth/jsonToArray/data/mX/mY 是 throw stub。
 */
@:access(common.view.tip.LandInfoTip)
class LandInfoTipTest {
	public function new() {}

	public function setup() {
		CommonData.serverTime = 10000;
	}

	public function tearDown() {
		CommonData.serverTime = 0;
	}

	// countHealth :59-170 —— 表驱动：健康值随动作日志与流逝时间的推进。
	// 期望值全部避开整数截断边界 ≥0.4（serverTime 读数对 set 时刻有每秒
	// +1 的漂移，CommonData.hx:141-148；余量见类头）；每行推导：
	// - c1 无日志：loc9=0.6，loc10=(90-70)*100=2000，2000+9150≥10000 →
	//   90-(10000-9150)*0.6/60=90-8.5=81.5 → 81
	// - c2 过期下限：loc10=1000，1000+1000<10000 → 取 loc11=70
	// - c3 零速率：p5=1、无草虫 → loc9=0 → 直接 100（:94-97）
	// - c4 施肥+虫害：E1 loc9=0 → 100，action4(+30,p5=1)+action1(p4=1)，
	//   钳 100；E2 loc9=0.2、loc11=90，3000+2000<10000 → 90
	// - c5 档位封顶 3：E1 loc9=1.2、loc11=40，衰减 (9620-9600)*0.02=0.4
	//   → 99.6 → 99，四个 2/四个 1 都不再涨档（再涨会 loc9=2.8、结果
	//   漂到 81）；E2 loc10=2950、12570≥10000，衰减 380*0.02=7.6 →
	//   99-7.6=91.4 → 91
	// - c6 整式截断：loc9=0.2，100-(1000)*0.2/60=100-3.333=96.667 → 96
	//   （截被减项会得 97）
	// - c7 Array 日志整体丢弃（:68-71 只剩合成键）→ loc9=0 → 100
	// - c8 除虫/除草/浇水：E1 loc9=1.0、loc11=50，0+9800≥9800 → 不动，
	//   action5(p4 1→0,+10)+action6(p3 1→0,+10)+action3(p5=0) → 70；
	//   E2 loc9 重回 0.6（p5=0 的 +0.6 生效）、loc11=70，0+9800<10000 → 70
	// - c9 标量动作（PHP 正典形状，pest.php :39 值是裸 int）+ 时序排序：
	//   :114 的 `[].concat(action)` 对标量是**包裹**语义（Haxe 的
	//   Array.concat 只收数组——译成 isOfType 门 + 包裹）；E1(9200,2)
	//   loc9=0 → 100、p3=1；E2(9500,1) loc9=0.2，100-(300)/300=99、p4=1；
	//   E3 合成键 loc9=0.4、loc11=80，99-(500)*0.2/60=99-3.333=95.667 → 95
	public function test_countHealth_table() {
		var tip = new LandInfoTip();
		var cases:Array<{
			desc:String,
			health:Int,
			updateTime:Int,
			oldweed:Int,
			oldpest:Int,
			oldhumidity:Int,
			action:Dynamic,
			expected:Int
		}> = [
			{desc: "c1 无日志按流逝衰减", health: 90, updateTime: 9150, oldweed: 0, oldpest: 0, oldhumidity: 0, action: {}, expected: 81},
			{desc: "c2 超时落到健康下限", health: 80, updateTime: 1000, oldweed: 0, oldpest: 0, oldhumidity: 0, action: {}, expected: 70},
			{desc: "c3 零衰减速率重置满值", health: 30, updateTime: 9900, oldweed: 0, oldpest: 0, oldhumidity: 1, action: {}, expected: 100},
			{desc: "c4 施肥+30 与虫害档", health: 70, updateTime: 500, oldweed: 0, oldpest: 0, oldhumidity: 1, action: {"2000": [4, 1]}, expected: 90},
			{desc: "c5 杂草/虫害档位封顶 3", health: 100, updateTime: 9600, oldweed: 3, oldpest: 3, oldhumidity: 1, action: {"9620": [2, 2, 2, 2, 1, 1, 1, 1]}, expected: 91},
			{desc: "c6 分数衰减整式截断", health: 100, updateTime: 9000, oldweed: 0, oldpest: 1, oldhumidity: 1, action: {}, expected: 96},
			{desc: "c7 Array 日志整体丢弃", health: 90, updateTime: 0, oldweed: 0, oldpest: 0, oldhumidity: 1, action: [1, 2, 3], expected: 100},
			{desc: "c8 除草除虫浇水回档", health: 50, updateTime: 9800, oldweed: 1, oldpest: 1, oldhumidity: 0, action: {"9800": [5, 6, 3]}, expected: 70},
			{desc: "c9 标量动作时序推进", health: 100, updateTime: 9000, oldweed: 0, oldpest: 0, oldhumidity: 1, action: {"9500": 1, "9200": 2}, expected: 95}
		];
		for (c in cases) {
			Assert.equals(c.expected, tip.countHealth(c.health, c.updateTime, c.oldweed, c.oldpest, c.oldhumidity, 0, c.action), c.desc);
		}
	}

	// :371-385 + :413-420：动作日志对象 → {time:键, action:值} 数组，按
	// Number(time) 升序（sortArray :415 的 > 升序）；time 是键字符串原样；
	// 值 null（无动作）也成条（countHealth :80 按null取 serverTime）
	public function test_jsonToArray_sorts_entries_by_time_ascending() {
		var tip = new LandInfoTip();
		var arr = tip.jsonToArray({"300": [1, 2], "100": [3], "200": null});
		Assert.equals(3, arr.length);
		Assert.equals("100", Reflect.field(arr[0], "time"));
		Assert.equals(3, (Reflect.field(arr[0], "action"):Array<Dynamic>)[0]);
		Assert.equals("200", Reflect.field(arr[1], "time"));
		Assert.isNull(Reflect.field(arr[1], "action"));
		Assert.equals("300", Reflect.field(arr[2], "time"));
		Assert.equals(2, (Reflect.field(arr[2], "action"):Array<Dynamic>)[1]);
	}

	// :354-363：data null → _land null、早退（removeFarmInfo/onRemovedFromStage
	// 都不新建素材），_preTime 归 -1（:436）
	public function test_data_null_clears_land() {
		var tip = new LandInfoTip();
		tip.data = null;
		Assert.isNull(tip.data); // :356 super.data 原样 null
		Assert.isNull(tip._land); // :357 as FarmLand 失败落 null
		Assert.equals(-1, tip._preTime); // :436
	}

	// :354-369：_cId 0 的空地（onFarmTimer :185-189 早退，不建 FarmInfoPlus）
	// 仍记录 _land、复位种子缓存（:364-365）
	public function test_data_cid0_land_recorded_without_farm_info() {
		var tip = new LandInfoTip();
		var land = new FarmLand({});
		tip.data = land;
		Assert.equals(land, tip.data); // :356
		Assert.equals(land, tip._land); // :357
		Assert.equals("", tip._seedClassName); // :364
		Assert.isNull(tip._seedIcon); // :365
		Assert.isNull(tip._farmInfo); // :185-189 早退未建素材
	}

	// :393-397：mX 记原值，x 落 m-60（提示锚点在鼠标左 60px）
	public function test_mX_anchor_offsets_minus_60() {
		var tip = new LandInfoTip();
		tip.mX = 300;
		Assert.equals(300, tip.mX); // :395
		Assert.equals(240.0, tip.x); // :396
	}

	// :387-391：mY 记原值，y 落 m-120（提示整体上移避开手指）
	public function test_mY_anchor_offsets_minus_120() {
		var tip = new LandInfoTip();
		tip.mY = 400;
		Assert.equals(400, tip.mY); // :389
		Assert.equals(280.0, tip.y); // :390
	}
}
