package common;

import com.qzone.qfa.model.AppData;
import common.GetCropID;
import entities.StartupData;
import module.FarmApplication;
import utest.Assert;

/**
 * GetCropID.idState/timeToMature 生长档推导纯逻辑（issue #8 review round 1
 * 补课：作物生长档此前是 stub 恒 0，所有作物永远渲染种子图）。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/common/GetCropID.as:589-664（idState：
 *   cropGrow 档位表从高往低首个命中档 +1；param4==2 的非红作物 *0.8 提速、
 *   末两档削 %600 余数；param5>0 时低于 3 的档抬到 3）、:201-228（timeToMature：
 *   成熟线取倒数第二档位值，param4==2 的非红作物 *0.8 - 原值%600）
 * - legacy/deploy/QFarmFlash/source/core/config/nc/cropstime.php（服务端生长
 *   档表："1" 行 [14400,28800,46800,64800,86400,2000000000]、"2" 行
 *   [7200,14400,25200,36000,36000,2000000000]）
 * - legacy/deploy/QFarmFlash/source/core/source/xml/mod/nc_data.php:6020
 *   （id 1 草莓 cropGrow "14400,28800,46800,64800,86400,2000000000"，无
 *   isRed）、:6021（id 2 白萝卜 cropGrow "7200,14400,25200,36000,36000,
 *   2000000000"，无 isRed）、:6416（id 460 园艺熊猫 cropGrow "32400,64800,
 *   100800,144000,187200,2000000000"、"isRed": 2 数值形态）——客户端 crops
 *   配置与 cropstime.php 同值下发，insect 字段一并原样带入（getInsectPosition
 *   对缺 insect 的条目会走 null.split，真配置里 insect 恒在）
 * - test/fixtures/uid1_user_run.json（uid=1 真实 user_run 下发，见
 *   FarmLandModelTest 类头）：serverTime.time=1794915896；farmlandStatus
 *   land0 {a:2,b:6,q:1794879866}、land1/2 {a:2,b:1,q:1794901496}、land3
 *   {a:2,b:1,q:1794890696}、land4/5 {a:0}
 *
 * 环境与稳定度说明：
 * - idState 内部读 CommonData.serverTime（活时钟：set 锚定 + get 按真实流逝
 *   秒漂移，CommonData.hx:129-148），同用例内相邻语句的漂移 ∈ [0, 1] 秒且
 *   只增不减——表里贴档位边界的行按「elapsed 只会被漂移推高」选值（如
 *   land1 恰在 14400 档线上、land0 留 30 秒余量），期望档对 +1 秒漂移不变；
 * - timeToMature 的 serverTime 是传参（countNoneMatureLands 的调用形态，
 *   FarmLandModel.as:696 先读一次再传），表里传字面量 1794915896，纯函数
 *   无漂移；
 * - crops 经 AppData 单例注入，每用例开头重钉；teardown 把 "crops" 置回
 *   null，单例不携带本用例数据到其他 case（FarmLandsViewTest/
 *   LandItemRenderTest 以「无 crops 配置」为前提）；
 * - 注册待 write-tests 阶段（test/ 既有文件 append-only，TestMain 的注册行
 *   留给下一轮，见 handbook/lessons #8 对应条目）。
 */
class GetCropIDTest {
	public function new() {}

	// 真实 crops 条目（nc_data.php:6020/6021/6416 字段原样，仅省略与本片
	// 无关的文案字段）
	static function pinCrops():Void {
		// GetCropID.theApp 只在 module/Main 启动时设置（Main.hx:246 对应
		// 原版 Main.as 同位置）；单测进程不跑启动链，按 FarmLandsViewTest/
		// BackgroundModelTest 先例装空配置 app 再注入 crops
		GetCropID.theApp = new FarmApplication();
		AppData.gi().setData("crops", [
			{
				"id": 1,
				"cropGrow": "14400,28800,46800,64800,86400,2000000000",
				"insect": "0,0,0,0,0,0|50,10,65,-30,110,-2|50,10,65,-30,110,-2|0,0,0,0,0,0"
			},
			{
				"id": 2,
				"cropGrow": "7200,14400,25200,36000,36000,2000000000",
				"insect": "0,0,0,0,0,0|74,8,92,2,109,33|74,8,92,2,109,33|0,0,0,0,0,0"
			},
			{
				"id": 460,
				"cropGrow": "32400,64800,100800,144000,187200,2000000000",
				"isRed": 2,
				"insect": "0,0,0,0,0,0|84,23,73,-32,94,11|104,16,89,28,65,-55|0,0,0,0,0,0"
			}
		]);
	}

	public function teardown() {
		// AppData 是进程级单例：crops 置回 null（无 removeData API，null 与
		// 缺键在 getCropByID 的 `getData(...) == null` 判定下同义），别的 case
		// 继续拿「无配置」
		AppData.gi().setData("crops", null);
	}

	// uid=1 真实 6 块地按 serverTime=1794915896 的生长档（user_run 快照；
	// 档位表 nc_data.php:6021 = cropstime.php "2" 行）。land0 已熟（36030 ≥
	// 36000）、land1 在 14400 档线上、land3 在 25200 档线上——边界行对
	// serverTime 活钟 ±1 秒漂移单调安全（见类头）
	public function test_idState_real_user_run_lands_span_stages() {
		pinCrops();
		CommonData.serverTime = 1794915896;
		// land0：elapsed 36030，白萝卜档位 [7200,14400,25200,36000,36000,…]
		// 从高往低首个命中 idx4 → 档 5（成熟，与其 b=6 下发态一致）
		Assert.equals(5, GetCropID.idState(2, 1794879866, 6, 0, 0));
		// land1/2：elapsed 14400 → idx1 → 档 2
		Assert.equals(2, GetCropID.idState(2, 1794901496, 1, 0, 0));
		// land3：elapsed 25200 → idx2 → 档 3
		Assert.equals(3, GetCropID.idState(2, 1794890696, 1, 0, 0));
		// land4/5：a=0 → :594-596 空地短路 0
		Assert.equals(0, GetCropID.idState(0, 0, 0, 0, 0));
		// cropStatus 7 → :598-600 枯死短路 7（走不到档位表）
		Assert.equals(7, GetCropID.idState(2, 1794901496, 7, 0, 0));
		// cId 9999 不在 crops → :602-605 查无作物 0
		Assert.equals(0, GetCropID.idState(9999, 1794901496, 1, 0, 0));
	}

	// 红土地（bitmap 2）0.8 提速、末两档 %600 削余（:636-648）、isRed 2 红作物
	// 不提速（:632-634）、收获过的低档抬 3（:652-658）。plantTime 按
	// 1794915896 - elapsed 派生（期望档的推导链在每行注释）
	public function test_idState_gold_land_speedup_600_adjust_isred_and_harvest_floor() {
		pinCrops();
		CommonData.serverTime = 1794915896;
		// elapsed 28800（=1794915896-1794887096）：白萝卜红土地档位
		// idx4 = 36000*0.8 = 28800（%600 余 0，:641-648 的削余不改动）→ 档 5
		Assert.equals(5, GetCropID.idState(2, 1794887096, 1, 2, 0));
		// 同 elapsed 普通地：走原档 idx2 = 25200 → 档 3（提速前后对照）
		Assert.equals(3, GetCropID.idState(2, 1794887096, 1, 0, 0));
		// elapsed 69030（=1794915896-1794846866）：草莓红土地 idx4 =
		// 86400*0.8 = 69120，69120%600 = 120 → 69120-120 = 69000，69030 ≥
		// 69000 → 档 5（削余真正改动边界的一行）
		Assert.equals(5, GetCropID.idState(1, 1794846866, 1, 2, 0));
		// elapsed 68970（=1794915896-1794846926）< 69000 → 落 idx3 =
		// 64800*0.8 = 51840 → 档 4
		Assert.equals(4, GetCropID.idState(1, 1794846926, 1, 2, 0));
		// elapsed 144000（=1794915896-1794771896）：园艺熊猫 isRed 2 数值形态
		// 经 As3.eqString 命中 :632-634 → 原档 idx3 = 144000 → 档 4（同 elapsed
		// 若提速应早过 idx4 = 187200*0.8 = 149760 削余 149400，不提速故仍 4）
		Assert.equals(4, GetCropID.idState(460, 1794771896, 1, 2, 0));
		// elapsed 14400：草莓 idx0 命中 _loc16_ = 1，param5=1 > 0 且 1 < 3 →
		// :652-658 抬到 3
		Assert.equals(3, GetCropID.idState(1, 1794901496, 1, 0, 1));
		// 同 elapsed 无收获史 → 原档 1
		Assert.equals(1, GetCropID.idState(1, 1794901496, 1, 0, 0));
	}

	// timeToMature：serverTime 传参（FarmLandModel.as:696 调用形态），表值全
	// 纯函数可复算。成熟线 = cropGrow 倒数第二档（:217 的 arr[len-2]）
	public function test_timeToMature_remaining_seconds() {
		pinCrops();
		// fixture land0：elapsed 36030 > 成熟线 36000 → 剩 -30 < 0 → -1
		//（:222-226 已熟回 -1）
		Assert.equals(-1, GetCropID.timeToMature(1794915896, 2, 1794879866, 0));
		// fixture land1：36000 - 14400 = 21600
		Assert.equals(21600, GetCropID.timeToMature(1794915896, 2, 1794901496, 0));
		// fixture land3：36000 - 25200 = 10800
		Assert.equals(10800, GetCropID.timeToMature(1794915896, 2, 1794890696, 0));
		// 红土地非红作物成熟线：36000*0.8 - 36000%600 = 28800 - 0（:218-220 的
		// % 作用于原值），对 elapsed 25200（plantTime=1794890696）剩 3600
		Assert.equals(3600, GetCropID.timeToMature(1794915896, 2, 1794890696, 2));
		// isRed 2 红作物不提速：成熟线 187200（nc_data.php:6416 倒数第二档），
		// 对 elapsed 144000（plantTime=1794771896）剩 43200
		Assert.equals(43200, GetCropID.timeToMature(1794915896, 460, 1794771896, 2));
		// cId 9999 查无作物 → -1（:204-207）
		Assert.equals(-1, GetCropID.timeToMature(1794915896, 9999, 1794901496, 0));
	}

	// CommonData.serverTime 未设（0）时用 StartupData.serverTime 兜底
	//（:613-620；原版同款双源），档位推导结果同 land1
	public function test_idState_startupdata_fallback_when_servertime_unset() {
		pinCrops();
		CommonData.serverTime = 0; // set 后 get 走 _serverTime==0 纯分支回 0
		StartupData.serverTime = 1794915896; // StartupDataParserTest 同款静态钉法
		Assert.equals(2, GetCropID.idState(2, 1794901496, 1, 0, 0));
		Assert.equals(5, GetCropID.idState(2, 1794879866, 6, 0, 0));
		// 还原：后续用例（ProtocolTest 等）自设 serverTime，别把 0 留在静态里
		CommonData.serverTime = 1794915896;
	}
}
