package module.mainScene.farmLand;

import common.Session;
import entities.FarmLand;
import entities.Player;
import events.CommonEvent;
import haxe.Json;
import utest.Assert;

/**
 * FarmLandModel 数值/状态公式纯逻辑（issue #7）。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/FarmLandModel.as
 *   （buildCommonPostParams :300-326、canHandler :705-717、showLandTip :2009-2025、
 *   countNoneMatureLands :684-703、refreshLands :1859-1862、isAllGoldLand :1517-1532、
 *   landIsFull :1534-1545、updateLandData :274-298、getLandData :1573-1584、
 *   hasBlackLand :145-153、alarmTimeSort :1305-1312、checkRequestFreq :1314-1339、
 *   hasLandToScarify :1825-1837、hasLandToWater :2027-2038、setUserFarmData :1066-1071、
 *   farmChange :1357-1444）
 * - legacy/deploy/QFarmFlash/source/core/source/nc/mod/farmlandstatus_water.php:5-6
 *   （服务端读 $_REQUEST['place']/$_REQUEST['ownerId']，即 buildCommonPostParams
 *   拼出的公共参数）、farmlandstatus_planting.php:6（place）
 * - legacy/decompiled/main3_v_221/scripts/common/GetCropID.as:267-277（getCropByID：
 *   theApp.model 为 null 返回 null）、:201-227（timeToMature：查无作物返回 -1）
 * - test/fixtures/uid1_user_run.json —— CI 旧后端快照 uid=1 "admin" 的 user_run
 *   真实下发（user.uId=1/userName="admin"、serverTime=1794915896、6 块地 status）
 *
 * 测试环境说明：
 * - FarmLandModel 构造器建 OperationQueue（:110，闭包 stub，空实现先例），事件基座
 *   是纯 EventDispatcher，eval 上可直排（LoadManagerTest 先例）；
 * - GetCropID 在本片是空 stub（issue 闭包规则，772 loc > 100），timeToMature 返回
 *   0；真身在无 app 数据时返回 -1（GetCropID.as:270-277/:204-207）——两者过
 *   Math.ceil(x/3600)（:698）后都是 0，故 countNoneMatureLands 只断言可推导的
 *   「哪些地进 _refreshLands/不进」与 0 返回值，不对 timeToMature>0 的累加值
 *   造数（那要等 GetCropID 翻译 + cropstype 配置加载）；
 * - Session 同为本片闭包 stub（src/common/Session.hx，字段存取语义），每个用例
 *   自行钉 currentUser/host/friendKeys，不依赖用例顺序。
 */
@:access(module.mainScene.farmLand.FarmLandModel)
class FarmLandModelTest {
	public function new() {}

	static function bareLand():FarmLand {
		// new FarmLand({})：importObject 全键缺省 → 字段保持默认（FarmLand.as:187-223
		// 条件赋值），再直排字段构造目标状态（growLoop :737 同样直接写 _step）
		return new FarmLand({});
	}

	static function pinSession(meUId:UInt, meName:String, hostUId:UInt, hostName:String):Void {
		var me = new Player({});
		me._uId = meUId;
		me._userName = meName;
		var host = new Player({});
		host._uId = hostUId;
		host._userName = hostName;
		var s = Session.getInstance();
		s.currentUser = me;
		s.host = host;
	}

	// buildCommonPostParams :300-326：uid=1 admin 自访（fixture user 块）+
	// friendKeys 有 "1" → 全量参数（服务端按 farmlandstatus_water.php:5-6 读）
	public function test_buildCommonPostParams_full_params_for_uid1_admin() {
		pinSession(1, "admin", 1, "admin");
		var fk:Dynamic = Session.getInstance().friendKeys;
		Reflect.setField(fk, "1", "k1"); // 真实流由 updateCurrentFriendsKeys 写入（Session.as:120-128）
		var model = new FarmLandModel();
		var params:Dynamic = model.buildCommonPostParams("3");
		Assert.equals(1, Reflect.field(params, "ownerId")); // :307 currentUser._uId
		Assert.equals("3", Reflect.field(params, "place"));
		Assert.equals("admin", Reflect.field(params, "tName")); // :308
		Assert.equals("admin", Reflect.field(params, "fName")); // :313 host._userName
		Assert.equals("k1", Reflect.field(params, "fkey")); // :321-324
	}

	// :321 hasOwnProperty(uId) 不成立 → 不带 fkey（uid=7 不在 friendKeys 里）
	public function test_buildCommonPostParams_omits_fkey_when_key_missing() {
		pinSession(7, "guest", 1, "admin");
		var model = new FarmLandModel();
		var params:Dynamic = model.buildCommonPostParams("0");
		Assert.equals(7, Reflect.field(params, "ownerId"));
		Assert.equals("guest", Reflect.field(params, "tName"));
		Assert.isFalse(Reflect.hasField(params, "fkey")); // AS3 hasOwnProperty==false → 不写键
	}

	// :303-304/:305-309：currentUser 为 null → ownerId=0、tName=""（局部变量初值）
	public function test_buildCommonPostParams_defaults_when_no_current_user() {
		pinSession(1, "admin", 1, "admin");
		Session.getInstance().currentUser = null;
		var model = new FarmLandModel();
		var params:Dynamic = model.buildCommonPostParams("2");
		Assert.equals(0, Reflect.field(params, "ownerId"));
		Assert.equals("", Reflect.field(params, "tName"));
		Assert.equals("admin", Reflect.field(params, "fName")); // host 仍在
	}

	// :310-314：host 为 null → fName=""
	public function test_buildCommonPostParams_defaults_when_no_host() {
		pinSession(1, "admin", 1, "admin");
		Session.getInstance().host = null;
		var model = new FarmLandModel();
		var params:Dynamic = model.buildCommonPostParams("2");
		Assert.equals("admin", Reflect.field(params, "tName"));
		Assert.equals("", Reflect.field(params, "fName"));
	}

	// canHandler :705-717：land null → false；空地（_cId==0）→ false 并经
	// showLandTip :2009-2025 派发 EVENT_OPERATE_INVALID（"FarmLandOperateError"）
	// 带文案/索引；有种 → true
	public function test_canHandler_rejects_empty_land_with_tip_event() {
		var model = new FarmLandModel();
		var planted = bareLand();
		planted._cId = 2; // fixture land0 a:2
		var empty = bareLand();
		empty._cId = 0;
		model.m_farmlandData = [planted, empty];

		Assert.isFalse(model.canHandler(9, null)); // :707-710

		var tips:Array<CommonEvent> = [];
		model.addEventListener("FarmLandOperateError", function(e) tips.push(cast(e, CommonEvent)));
		Assert.isFalse(model.canHandler(1, empty)); // :711-715
		Assert.isTrue(model.canHandler(0, planted)); // :716
		Assert.equals(1, tips.length); // 有种的地不派发
		Assert.equals("不可以对空地进行这个操作啦！", Reflect.field(tips[0].data, "text")); // :713
		Assert.equals(1, Reflect.field(tips[0].data, "index")); // :2020-2023
		Assert.equals(0, Reflect.field(tips[0].data, "yAdjust")); // 缺省 0
	}

	// countNoneMatureLands :684-703：只有 _cId>0 且 _step<5 的地进 _refreshLands
	// （:694-696）；成熟（step 5）/空地不进。返回值见类头 GetCropID 说明，此处为 0
	public function test_countNoneMatureLands_collects_only_growing_lands() {
		var model = new FarmLandModel();
		var growing = bareLand();
		growing._cId = 1;
		growing._step = 3;
		var mature = bareLand();
		mature._cId = 2;
		mature._step = 5; // :694 _step < 5 不成立
		var emptyLand = bareLand();
		emptyLand._cId = 0; // :694 _cId > 0 不成立
		var growing2 = bareLand();
		growing2._cId = 3;
		growing2._step = 4;
		model.m_farmlandData = [growing, mature, emptyLand, growing2];

		Assert.equals(0, model.countNoneMatureLands()); // timeToMature≤0 → ceil 后 0（类头说明）
		Assert.same([0, 3], model.refreshLands); // 收的是下标 _loc2_（:696）
	}

	// :684-703：成熟时间累加对 timeToMature≤0 的地贡献 0——未知 cId 走
	// GetCropID.as:204-207 返回 -1，Math.ceil(-1/3600) 为 0（:698）
	public function test_countNoneMatureLands_returns_zero_when_nothing_growing() {
		var model = new FarmLandModel();
		var mature = bareLand();
		mature._cId = 2;
		mature._step = 5;
		var emptyLand = bareLand();
		emptyLand._cId = 0;
		model.m_farmlandData = [mature, emptyLand];
		Assert.equals(0, model.countNoneMatureLands());
		Assert.same([], model.refreshLands); // :687 每次调用新建数组
	}

	// isAllGoldLand :1517-1532：非金地→2；全金且不足 24 块→1；全金且 ≥24→3
	public function test_isAllGoldLand_states() {
		var one = bareLand();
		one._goldLand = 1;
		var model = new FarmLandModel();
		model.m_farmlandData = [one];
		Assert.equals(1, model.isAllGoldLand); // :1527-1530 length 1 < 24

		var all:Array<Dynamic> = [];
		for (i in 0...24) {
			var l = bareLand();
			l._goldLand = 1;
			all.push(l);
		}
		model.m_farmlandData = all;
		Assert.equals(3, model.isAllGoldLand); // :1531

		var mixed = bareLand();
		mixed._goldLand = 0;
		all[23] = mixed;
		Assert.equals(2, model.isAllGoldLand); // :1522-1525 第 24 块不是金地
	}

	// landIsFull :1534-1545：任一地 null 或 _cId==0 → false；全有种 → true；
	// 空数组没有失败项 → true（for-each 零次迭代）
	public function test_landIsFull_requires_every_land_planted() {
		var model = new FarmLandModel();
		var a = bareLand();
		a._cId = 1;
		var b = bareLand();
		b._cId = 2;
		model.m_farmlandData = [a, b];
		Assert.isTrue(model.landIsFull());

		var emptyLand = bareLand();
		emptyLand._cId = 0;
		model.m_farmlandData = [a, emptyLand];
		Assert.isFalse(model.landIsFull()); // :1539 !_cId

		model.m_farmlandData = [a, null];
		Assert.isFalse(model.landIsFull()); // :1539 !land

		model.m_farmlandData = [];
		Assert.isTrue(model.landIsFull());
	}

	// updateLandData :274-298：普通分支赋 _output/_left/_min，bitmap 只在
	// param6!=1 时写（:289-292），goldLand 只在 param6>=0 时写（:293-296），
	// 完成后派发 EVENT_LAND_CHANGED（"FarmLandChanged"）带 index
	public function test_updateLandData_sets_fields_and_dispatches_change_event() {
		var model = new FarmLandModel();
		var lands:Array<Dynamic> = [];
		for (i in 0...3) {
			var l = bareLand();
			l._cId = 2;
			l._output = 99;
			lands.push(l);
		}
		model.m_farmlandData = lands;

		var changes:Array<CommonEvent> = [];
		model.addEventListener("FarmLandChanged", function(e) changes.push(cast(e, CommonEvent)));

		// (idx, output, left, min, bitmap, gold)：param6=0 → bitmap=0、goldLand=0
		model.updateLandData(0, 5, 3, 2, 0, 0);
		Assert.equals(5, lands[0]._output);
		Assert.equals(3, lands[0]._left);
		Assert.equals(2, lands[0]._min);
		Assert.equals(0, lands[0]._bitmap);
		Assert.equals(0, lands[0]._goldLand);

		// param6=1 → bitmap 不写（:289-292，地块初值 0 保持，尽管 param5=7）、goldLand=1
		model.updateLandData(1, 5, 3, 2, 7, 1);
		Assert.equals(0, lands[1]._bitmap); // param6==1：bitmap 被跳过
		Assert.equals(1, lands[1]._goldLand);

		// param6=-1 → bitmap 写、goldLand 不动
		model.updateLandData(2, 5, 3, 2, 7, -1);
		Assert.equals(7, lands[2]._bitmap);
		Assert.equals(0, lands[2]._goldLand);

		Assert.equals(3, changes.length);
		Assert.equals(0, Reflect.field(changes[0].data, "index")); // :297 {"index":param1}
		Assert.equals(2, Reflect.field(changes[2].data, "index"));

		// :277-280 越界下标静默返回（getLandData null），不派发
		model.updateLandData(99, 1, 1, 1, 0, 0);
		Assert.equals(3, changes.length);
	}

	// getLandData :1573-1584：数据未初始化/越界 → null，否则原引用
	public function test_getLandData_bounds() {
		var model = new FarmLandModel();
		Assert.equals(null, model.getLandData(0)); // :1575-1577 m_farmlandData==null
		var a = bareLand();
		var b = bareLand();
		model.m_farmlandData = [a, b];
		Assert.equals(null, model.getLandData(-1)); // :1579
		Assert.equals(null, model.getLandData(2)); // :1579
		Assert.equals(a, model.getLandData(0));
		Assert.equals(b, model.getLandData(1));
	}

	// hasBlackLand :145-153：0 号地 bitmap==2 才是黑土地
	public function test_hasBlackLand_reads_land0_bitmap() {
		var model = new FarmLandModel();
		Assert.isFalse(model.hasBlackLand); // m_farmlandData==null → :147 null → false
		var normal = bareLand();
		normal._bitmap = 1;
		model.m_farmlandData = [normal];
		Assert.isFalse(model.hasBlackLand);
		var black = bareLand();
		black._bitmap = 2;
		model.m_farmlandData = [black];
		Assert.isTrue(model.hasBlackLand);
	}

	// alarmTimeSort :1305-1312：null 任一 → 0；remain 大 → 1、小 → -1、相等 → -1
	public function test_alarmTimeSort_comparator() {
		var model = new FarmLandModel();
		Assert.equals(0, model.alarmTimeSort(null, {remain: 1})); // :1307-1310
		Assert.equals(0, model.alarmTimeSort({remain: 1}, null));
		Assert.equals(1, model.alarmTimeSort({remain: 5}, {remain: 2})); // :1311
		Assert.equals(-1, model.alarmTimeSort({remain: 2}, {remain: 5}));
		Assert.equals(-1, model.alarmTimeSort({remain: 3}, {remain: 3})); // 严格 > 才 1
	}

	// checkRequestFreq :1314-1339：空串/计数 0 → false；前两次放行，第三次起
	// 10 秒内拒（:1327-1333）；桶键是字面量 "type"（:1322/:1327/:1336），换名
	// 也共享同一桶（原版如此，照抄）
	public function test_checkRequestFreq_counter_and_shared_type_bucket() {
		var model = new FarmLandModel(); // 构造 :109 m_requestFreq = {}
		Assert.isFalse(model.checkRequestFreq("", 1)); // :1316
		Assert.isFalse(model.checkRequestFreq("water", 0)); // :1316

		Assert.isTrue(model.checkRequestFreq("water", 1)); // num 0→1（:1336）
		Assert.isTrue(model.checkRequestFreq("water", 1)); // num 1→2
		Assert.isFalse(model.checkRequestFreq("water", 1)); // num 2>1 且 10 秒内（相邻调用）
		// 相邻两次调用间隔远小于 :1329 的 10000ms，分支结果是确定的
		Assert.isFalse(model.checkRequestFreq("spraying", 1)); // :1322 桶键恒为 "type"
	}

	// hasLandToScarify :1825-1837：Session.me 且存在 step 6/7 的地 → true
	public function test_hasLandToScarify_requires_me_and_withered_land() {
		var withered = bareLand();
		withered._cId = 2;
		withered._step = 6; // :1831
		var growing = bareLand();
		growing._cId = 1;
		growing._step = 3;
		var model = new FarmLandModel();

		pinSession(1, "admin", 1, "admin"); // currentUser._uId == host._uId → me（Session.as:108-118）
		model.m_farmlandData = [growing, withered];
		Assert.isTrue(model.hasLandToScarify());

		model.m_farmlandData = [growing]; // 没有 6/7
		Assert.isFalse(model.hasLandToScarify());

		pinSession(2, "guest", 1, "admin"); // 访客 → me=false
		model.m_farmlandData = [withered];
		Assert.isFalse(model.hasLandToScarify()); // :1831 _loc1_==true 不成立
	}

	// hasLandToWater :2027-2038：任一地湿度 !=1 → true（fixture land2 h:0 即缺水）
	public function test_hasLandToWater_reads_humidity() {
		var model = new FarmLandModel();
		var dry = bareLand();
		dry._humidity = 0;
		var wet = bareLand();
		wet._humidity = 1;
		model.m_farmlandData = [wet, dry];
		Assert.isTrue(model.hasLandToWater());

		model.m_farmlandData = [wet];
		Assert.isFalse(model.hasLandToWater());
	}

	// setUserFarmData :1066-1071：存数组 + 派发 EVENT_INITIALZED（"DataInitialized"）
	// 带数组本体；reGetOutput 对 step!=5 的地不发请求（fixture 各地 b 都不是 5 的
	// 收获态 + GetCropID stub → _step=0），单测不触网
	public function test_setUserFarmData_dispatches_initialized_with_array() {
		var model = new FarmLandModel();
		var lands:Array<Dynamic> = [bareLand(), bareLand()];
		var initialized:Array<CommonEvent> = [];
		model.addEventListener("DataInitialized", function(e) initialized.push(cast(e, CommonEvent)));
		model.setUserFarmData(lands);
		Assert.equals(1, initialized.length);
		Assert.equals(lands, initialized[0].data); // :1069 原数组引用
		Assert.equals(lands[0], model.getLandData(0));
	}

	// farmChange :1357-1444：code==1 且字段值变化 → 写 humidity/weed/pest 并派发
	// EVENT_LAND_CHANGED；值相同 → 不动不派发（:1391 diff 门）
	public function test_farmChange_applies_changed_fields_only() {
		var model = new FarmLandModel();
		var land = bareLand();
		land._cId = 1;
		land._humidity = 0;
		model.m_farmlandData = [land];
		var changes:Array<CommonEvent> = [];
		model.addEventListener("FarmLandChanged", function(e) changes.push(cast(e, CommonEvent)));

		model.farmChange({farmlandIndex: 0, code: 1, humidity: 1}, "humidity"); // :1379-1381 旧值 0
		Assert.equals(1, land._humidity); // :1407-1410
		Assert.equals(1, changes.length); // :1419

		model.farmChange({farmlandIndex: 0, code: 1, humidity: 1}, "humidity"); // 值相同
		Assert.equals(1, changes.length); // :1391 _loc6_ == param1[param2] → 不进

		model.farmChange({farmlandIndex: 99, code: 1, humidity: 1}, "humidity"); // :1367 越界
		Assert.equals(1, changes.length);
	}

	// farmChange :1422-1443：poptype==1 + direction 含「最多使坏」的回滚分支
	// （放坏失败）：pest 分支先 -- 再扣 weed（error_repeat），只对 pest 取
	// Math.max(0,…)；weed 分支对称。数值出处即这几行
	public function test_farmChange_rolls_back_on_max_baddness_error() {
		var model = new FarmLandModel();
		var land = bareLand();
		land._cId = 1;
		land._pest = 2;
		land._weed = 1;
		model.m_farmlandData = [land];
		var changes:Array<CommonEvent> = [];
		model.addEventListener("FarmLandChanged", function(e) changes.push(cast(e, CommonEvent)));

		// 响应不带 pest 键（hasOwnProperty 失败）→ 走 :1422 poptype 分支
		model.farmChange({farmlandIndex: 0, poptype: 1, direction: "最多使坏3次", error_repeat: 2}, "pest", 1);
		Assert.equals(1, land._pest); // :1426 --pest（2→1）
		Assert.equals(-1, land._weed); // :1428-1430 weed -= 2，该分支不夹 0
		Assert.equals(1, changes.length); // :1442

		var land2 = bareLand();
		land2._cId = 1;
		land2._weed = 1;
		model.m_farmlandData = [land2];
		model.farmChange({farmlandIndex: 0, poptype: 1, direction: "最多使坏3次"}, "weed", 2);
		Assert.equals(0, land2._weed); // :1435 --weed 后 max(0,…)（:1440）
	}
}
