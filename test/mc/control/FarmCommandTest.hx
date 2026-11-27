package mc.control;

import common.INI;
import common.LocalData;
import mc.control.Command;
import mc.model.FarmData;
import mc.model.MData;
import mc.model.ProductData;
import support.McCommandEnv;
import utest.Assert;

/**
 * mc.control.FarmCommand 纯逻辑（issue #88 write-tests，对 stub 失败）：
 * 牧场农场操作命令——喂食/罐头/拍蚊/扫便/偷取/收获/拆建的请求拼装、
 * 前置守卫与应答分派。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/control/FarmCommand.as
 * —— addFly :178-187（{uId:currentUserId, num:param1, type:1} 发
 * cgi_demolish_pasture——type 恒 1 出处 cgi_demolish_pasture.php 使坏
 * 通道；spec/protocol.json entries.mc.mods.cgi_demolish_pasture）；
 * killFly :640-659（{uId,num:param2,type:1,pos:param1}——type 1 拍蚊、
 * pos 键随参，cgi_help_pasture.php:7 type==1 分支）；clearBB :965-975
 * （同形 type 2 扫便，cgi_help_pasture.php:71 type==2 分支）；
 * addFood :535-557（me → {foodnum,type} 两键；非 me → 补 uId/nick——
 * cgi_feed_food.php:22/69/106 type 三分支出处）；
 * ShengChan :661-700（status!=DAICHAN(3) 拦截——me "不是生产期或收获期，
 * 不能操作罐头可加速生长"/非 me "不是生产期,不能操作"——两文案逐字
 * :665-679，注意标点差异：me 版用「或收获期，」非 me 版用「,」；
 * 放行后 me {serial} 单键/非 me 补 uId/nick 发 cgi_post_product）；
 * useTools :189-277（type 4 特殊食：cId 不符 "只能对"+name+"喂这个。"、
 * SHENGCHAN "不能对生产中的动物操作"、SHOUHUO "不能对收获期的动物操作"
 * ——三文案 :197-224；放行 cgi_feed_special {serial,uId,tid}；type 7
 * 罐头：DAICHAN "当前状态不能使用罐头" :240-245 同款拦截，放行
 * cgi_feedcan {serial,uId,tid}——两 mod 出处 spec/protocol.json
 * entries.mc.mods.cgi_feed_special/cgi_feedcan）；
 * Theft :1016-1076（!all 双守卫：有动物生产同 cId "动物生产中，请稍后
 * 收获！" :1030-1035；cando==2 "做人要厚道，你已经收取过了"、cando==1
 * "手下留情，给主人留一点吧" :1042-1056；all → value -1；postValue 四键
 * {version:1, uId, type:value, nick} :1068-1073——version 恒 1，mod
 * 出处 cgi_steal_product.php:5-6 + spec/protocol.json）；ShouHuo
 * :1153-1230（harvesttype 1：非 all 先扫生产同 cId 拦截；all → type -1；
 * 请求 {version:1, type, harvesttype:1}；harvesttype 2：serial 取
 * animalData[param1].serial；param3 all 且无可收获动物 "当前没有可以
 * 收获的动物哦！" type "animal" serial 原位 :1211-1218；all → serial -1；
 * 请求 {version:1, serial:_loc8_, harvesttype:2, serialIndex:_loc7_}
 * ——harvesttype/serialIndex 出处 cgi_harvest_product.php:7/131 +
 * spec/protocol.json）；
 * getUserSeedFn :822-875（tId 重映射：4 位长 "11" 前缀 → "16"+substr(2,2)、
 * "10" 前缀 → "15"+substr(2,2) :844-854；"40" → "20000" :855-857——
 * 映射逐字；amount<=0 滤掉 :841-842；sortIndex=parseInt 映射后字符串
 * :859；sortOn NUMERIC|DESCENDING :868；tId "40" type 4 → animalPackFood
 * :862-865）；appendActivityItems :378-414（typeP+cId 双键匹配、命中时
 * 活动值覆盖背包值 :395-397、未中 concat 垫尾 :403-411）；
 * flyFn :449-476（errorType "-2005" 特判 maxFly/leftFly/maxErrInfo——
 * :450-456；成功：num=total、mynum+=num、flyNum1=floor(num/2)、
 * flyNum2=num-flyNum1、leftFly=leftnum——:466-473）；
 * foodFn :739-820（type==1 购买通道：host.animalFood=total、money 取负、
 * addFoodDelay 3000ms 定时（异步面不钉）；type==0 背包通道：
 * animalPackFood.amount -= added、reloadUserSeed 置位；addExp==-1 且
 * !totalExp 且 !me → "每天帮忙最多增加300点经验，您已加满" :752-762
 * ——文案逐字、type "food"）；
 * killFn :883-943（ecode 非零 → floatWindow(direction,"Exclamation")
 * + _recallTime 累加、<3 派 "killFlyError"；errorContent "您下手太慢，
 * 蚊子已经被拍了" 特判——killFly(1,4)+killFly(2,4) 双发 :887-893；
 * 成功：killFly(pos,num)、addExp==0 且 !totalExp → "每天帮忙最多增加
 * 300点经验，您已加满" type "fly" :906-916）；
 * clearBBFn :1411-1438（"您下手太慢，便便已经被清理了" 特判 bbData.
 * num=0 + "clearAllBB"；成功：repNum==0 且 !totalBB → "每天最多清理
 * 100坨便便，您已满，不再入库" :1307-1313；clearBBPos=pos、bbData.num
 * 自减——先行自减在 setter 之后 :1317-1318 顺序照抄）；
 * requestNum :1440-1462（**原版 bug 照抄**：`this.requestTime["type"]`
 * 键名恒字面量 "type" 不用 param1——:1442/1446/1451-1459 三处同键；
 * num>5 且 10 秒内 → false 闸门）。
 *
 * 说明：getTimer() 时间面经 FarmCommand 内部 requestStartTime 记录，
 * 但只喂给 EventRecorder（no-qq-telemetry 体空）不进断言。动物数据
 * animalData 是 MainData 40 位数组（MainData.as animalData setter），
 * 测试直接以稀疏数组布置。
 */
class FarmCommandTest {
	var env:McCommandEnv;

	public function new() {}

	function setup() {
		env = new McCommandEnv();
		env.resetStatics();
		env.swapInRecorder();
		env.captureViewControl(["animal_change", "canFeed", "sFeed", "killFlyError", "clearAllBB", "killInsectError", "clearBBError"]);
		var md = MData.getInstance().mainData;
		md.host = {"uId": "100", "money": 5000, "exp": 200, "userName": "主人", "yellowstatus": 1, "yellowlevel": 3, "animal1": 0, "animal2": 0, "animalFood": 0};
		md.currentUser = {"uId": "100", "me": true};
		var fd = MData.getInstance().farmData;
		fd.farmOperate = null;
		fd.reloadUserSeed = false;
		fd.userSeed = [];
	}

	function teardown() {
		env.restoreRecorder();
		env.releaseViewControl();
		FarmData.totalExp = false;
		FarmData.totalBB = false;
		FarmData.maxFly = false;
		FarmData.leftFly = -1;
		FarmData.sFeedTotalError = null;
	}

	// —— 请求拼装组 ——

	// addFly（FarmCommand.as:171-180）：type 恒 1、num 随参、uId 取
	// currentUserId（me 态 = host.uId）
	public function test_addFly_posts_demolish() {
		Command.getInstance().farmCommand.addFly(3);
		Assert.equals(1, env.rec.postCount);
		Assert.equals("cgi_demolish_pasture", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals("100", Reflect.field(v, "uId"));
		Assert.equals(3, Reflect.field(v, "num"));
		Assert.equals(1, Reflect.field(v, "type"));
	}

	// killFly（:640-651）：type 1 + pos 键
	public function test_killFly_posts_help_pasture_type1() {
		Command.getInstance().farmCommand.killFly(2, 3);
		Assert.equals("cgi_help_pasture", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals(1, Reflect.field(v, "type"));
		Assert.equals(2, Reflect.field(v, "pos"));
		Assert.equals(3, Reflect.field(v, "num"));
		Assert.equals("100", Reflect.field(v, "uId"));
	}

	// clearBB（:950-961）：type 2
	public function test_clearBB_posts_help_pasture_type2() {
		Command.getInstance().farmCommand.clearBB(1, 2);
		Assert.equals("cgi_help_pasture", env.rec.postedUrl);
		Assert.equals(2, Reflect.field(env.rec.postedValue, "type"));
		Assert.equals(1, Reflect.field(env.rec.postedValue, "pos"));
	}

	// addFood me/非 me 两形（:559-581）：me 两键、非 me 补 uId/nick
	public function test_addFood_me_two_keys() {
		Command.getInstance().farmCommand.addFood(50, 1);
		var v = env.rec.postedValue;
		Assert.equals(50, Reflect.field(v, "foodnum"));
		Assert.equals(1, Reflect.field(v, "type"));
		Assert.isFalse(Reflect.hasField(v, "uId"));
		Assert.isFalse(Reflect.hasField(v, "nick"));
		Assert.equals("cgi_feed_food", env.rec.postedUrl);
	}

	public function test_addFood_not_me_four_keys() {
		var md = MData.getInstance().mainData;
		// 非 me：currentUser.uId != host.uId（MainData.me getter :1140-1149）
		md.currentUser = {"uId": "200", "me": false};
		Command.getInstance().farmCommand.addFood(50, 0);
		var v = env.rec.postedValue;
		Assert.equals("200", Reflect.field(v, "uId"));
		Assert.equals("主人", Reflect.field(v, "nick"));
		Assert.equals(50, Reflect.field(v, "foodnum"));
		Assert.equals(0, Reflect.field(v, "type"));
	}

	// ShengChan 状态守卫（:665-679）：非 DAICHAN 拦截——me/非 me 文案
	// 逐字差异（标点：me 版「或收获期，」非 me 版「,」）
	public function test_shengchan_blocked_me_text() {
		var md = MData.getInstance().mainData;
		md.animalData = [null, {serial: 11, status: FarmData.ANIMAL_SHENGZHANG, cId: 1001}];
		Command.getInstance().farmCommand.ShengChan(1);
		var fd = MData.getInstance().farmData;
		Assert.equals("不是生产期或收获期，不能操作罐头可加速生长", Reflect.field(fd.farmOperate, "text"));
		Assert.equals("animal", Reflect.field(fd.farmOperate, "type"));
		Assert.equals(1, Reflect.field(fd.farmOperate, "serial"));
		Assert.equals(0, env.rec.postCount);
	}

	public function test_shengchan_blocked_not_me_text() {
		var md = MData.getInstance().mainData;
		md.currentUser = {"uId": "200", "me": false};
		md.animalData = [null, {serial: 11, status: FarmData.ANIMAL_SHENGZHANG, cId: 1001}];
		Command.getInstance().farmCommand.ShengChan(1);
		Assert.equals("不是生产期,不能操作", Reflect.field(MData.getInstance().farmData.farmOperate, "text"));
		Assert.equals(0, env.rec.postCount);
	}

	// ShengChan 放行（:681-700）：DAICHAN → cgi_post_product，me 单键
	// serial、非 me 补 uId/nick
	public function test_shengchan_posts_me_single_key() {
		var md = MData.getInstance().mainData;
		md.animalData = [null, {serial: 11, status: FarmData.ANIMAL_DAICHAN, cId: 1001}];
		Command.getInstance().farmCommand.ShengChan(1);
		Assert.equals("cgi_post_product", env.rec.postedUrl);
		Assert.equals(11, Reflect.field(env.rec.postedValue, "serial"));
		Assert.isFalse(Reflect.hasField(env.rec.postedValue, "uId"));
	}

	// useTools type 4 三拦截（:197-224）——cId 不符文案含动物名（鸡，
	// fixture mc-ini.xml animal 1001 name 抄录 mc_data.php:5575）
	public function test_useTools_type4_cid_mismatch() {
		var md = MData.getInstance().mainData;
		md.animalData = [null, {serial: 11, status: FarmData.ANIMAL_SHENGZHANG, cId: 1001}];
		// 工具 tId 1101 对应动物 1001（fixture toolToAnimal sf 通道）——
		// 用不匹配的动物 cId 1502 逼出「只能对」文案
		md.animalData[1].cId = 1502;
		Command.getInstance().farmCommand.useTools(1, {tId: "1101", type: 4});
		var op = MData.getInstance().farmData.farmOperate;
		Assert.notNull(op);
		Assert.isTrue(Reflect.field(op, "text").indexOf("只能对") == 0);
		Assert.equals(0, env.rec.postCount);
	}

	// useTools type 7 DAICHAN 拦截（:240-245）
	public function test_useTools_type7_daichan_blocked() {
		var md = MData.getInstance().mainData;
		md.animalData = [null, {serial: 11, status: FarmData.ANIMAL_DAICHAN, cId: 1001}];
		Command.getInstance().farmCommand.useTools(1, {tId: "4001", type: 7});
		Assert.equals("当前状态不能使用罐头", Reflect.field(MData.getInstance().farmData.farmOperate, "text"));
		Assert.equals(0, env.rec.postCount);
	}

	// useTools type 7 放行（:256-262）→ cgi_feedcan {serial,uId,tid}
	public function test_useTools_type7_posts_feedcan() {
		var md = MData.getInstance().mainData;
		md.animalData = [null, {serial: 11, status: FarmData.ANIMAL_SHENGZHANG, cId: 1001}];
		Command.getInstance().farmCommand.useTools(1, {tId: "4001", type: 7});
		Assert.equals("cgi_feedcan", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals(11, Reflect.field(v, "serial"));
		Assert.equals("100", Reflect.field(v, "uId"));
		Assert.equals(4001, Reflect.field(v, "tid"));
	}

	// —— Theft/ShouHuo 守卫与拼装 ——

	// Theft 生产拦截（:1030-1035）：有同 cId 动物 SHENGCHAN → 拦
	public function test_theft_blocked_animal_producing() {
		var md = MData.getInstance().mainData;
		md.currentUser = {"uId": "200", "me": false};
		md.animalData = [null, {serial: 11, status: FarmData.ANIMAL_SHENGCHAN, cId: 1001}];
		var pd = MData.getInstance().productData;
		pd.products = {"1001": {cando: 3, amount: 5}};
		Command.getInstance().farmCommand.Theft(1001);
		Assert.equals("动物生产中，请稍后收获！", Reflect.field(MData.getInstance().farmData.farmOperate, "text"));
		Assert.equals(0, env.rec.postCount);
	}

	// Theft cando 守卫（:1042-1056）：cando 2/1 两文案
	public function test_theft_cando_guards() {
		var md = MData.getInstance().mainData;
		md.currentUser = {"uId": "200", "me": false};
		md.animalData = [];
		var pd = MData.getInstance().productData;
		pd.products = {"1001": {cando: 2, amount: 5}};
		Command.getInstance().farmCommand.Theft(1001);
		Assert.equals("做人要厚道，你已经收取过了", Reflect.field(MData.getInstance().farmData.farmOperate, "text"));
		Assert.equals(0, env.rec.postCount);

		pd.products = {"1001": {cando: 1, amount: 5}};
		MData.getInstance().farmData.farmOperate = null;
		Command.getInstance().farmCommand.Theft(1001);
		Assert.equals("手下留情，给主人留一点吧", Reflect.field(MData.getInstance().farmData.farmOperate, "text"));
		Assert.equals(0, env.rec.postCount);
	}

	// Theft 放行四键（:1068-1073）：version 恒 1、type 随参、uId/nick
	// 取当前视角/主人名
	public function test_theft_posts_four_keys() {
		var md = MData.getInstance().mainData;
		md.currentUser = {"uId": "200", "me": false};
		md.animalData = [];
		var pd = MData.getInstance().productData;
		pd.products = {"1001": {cando: 0, amount: 5}};
		Command.getInstance().farmCommand.Theft(1001);
		Assert.equals("cgi_steal_product", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals(1, Reflect.field(v, "version"));
		Assert.equals("200", Reflect.field(v, "uId"));
		Assert.equals(1001, Reflect.field(v, "type"));
		Assert.equals("主人", Reflect.field(v, "nick"));
	}

	// Theft all → type -1（:1061-1063）
	public function test_theft_all_type_minus1() {
		var md = MData.getInstance().mainData;
		md.currentUser = {"uId": "200", "me": false};
		Command.getInstance().farmCommand.Theft(0, true);
		Assert.equals(-1, Reflect.field(env.rec.postedValue, "type"));
	}

	// ShouHuo harvesttype 1 请求（:1111-1119）：{version,type,harvesttype}
	public function test_shouhuo_type1_posts() {
		var md = MData.getInstance().mainData;
		md.animalData = [];
		Command.getInstance().farmCommand.ShouHuo(1001, 1);
		Assert.equals("cgi_harvest_product", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals(1, Reflect.field(v, "version"));
		Assert.equals(1001, Reflect.field(v, "type"));
		Assert.equals(1, Reflect.field(v, "harvesttype"));
	}

	// ShouHuo harvesttype 1 all → type -1（:1103-1105）
	public function test_shouhuo_type1_all_minus1() {
		Command.getInstance().farmCommand.ShouHuo(1001, 1, true);
		Assert.equals(-1, Reflect.field(env.rec.postedValue, "type"));
	}

	// ShouHuo harvesttype 2 请求（:1122-1184）：serial 取动物、serialIndex
	// 原位、all 且无可收获动物拦截
	public function test_shouhuo_type2_posts_serial_pair() {
		var md = MData.getInstance().mainData;
		md.animalData = [null, {serial: 42, status: FarmData.ANIMAL_SHOUHUO, cId: 1001}];
		Command.getInstance().farmCommand.ShouHuo(1, 2);
		var v = env.rec.postedValue;
		Assert.equals(42, Reflect.field(v, "serial"));
		Assert.equals(42, Reflect.field(v, "serialIndex"));
		Assert.equals(2, Reflect.field(v, "harvesttype"));
	}

	public function test_shouhuo_type2_all_none_blocked() {
		var md = MData.getInstance().mainData;
		md.animalData = [null, {serial: 42, status: FarmData.ANIMAL_SHENGZHANG, cId: 1001}];
		Command.getInstance().farmCommand.ShouHuo(1, 2, true);
		Assert.equals("当前没有可以收获的动物哦！", Reflect.field(MData.getInstance().farmData.farmOperate, "text"));
		Assert.equals("animal", Reflect.field(MData.getInstance().farmData.farmOperate, "type"));
		Assert.equals(42, Reflect.field(MData.getInstance().farmData.farmOperate, "serial"));
		Assert.equals(0, env.rec.postCount);
	}

	// harvesttype 2 all 有可收获 → serial -1、serialIndex 原位（:1220-1227）
	public function test_shouhuo_type2_all_serial_minus1() {
		var md = MData.getInstance().mainData;
		md.animalData = [null, {serial: 42, status: FarmData.ANIMAL_SHOUHUO, cId: 1001}];
		Command.getInstance().farmCommand.ShouHuo(1, 2, true);
		Assert.equals(-1, Reflect.field(env.rec.postedValue, "serial"));
		Assert.equals(42, Reflect.field(env.rec.postedValue, "serialIndex"));
	}

	// —— getUserSeedFn 重映射组 ——

	// tId 重映射（:828-839）：1101→1601、1055→1555、"40"→20000；amount<=0
	// 滤掉；sortIndex 数值化 + NUMERIC|DESCENDING 排序
	public function test_getUserSeedFn_tid_remap_and_sort() {
		var fc = Command.getInstance().farmCommand;
		var fd = MData.getInstance().farmData;
		fd.reloadUserSeed = true;
		fd.userSeed = null;
		fc.getUserSeed();
		Assert.equals("cgi_get_package", env.rec.postedUrl);
		env.respond([
			{tId: "1101", type: "4", amount: 2},
			{tId: "1055", type: "4", amount: 1},
			{tId: "4001", type: "7", amount: 5},
			{tId: "1102", type: "4", amount: 0}, // 滤掉
			{tId: "40", type: 4, amount: 30}
		]);
		var seed = fd.userSeed;
		Assert.notNull(seed);
		// DESCENDING：20000 > 4001 > 1601 > 1555
		Assert.equals(4, seed.length);
		Assert.equals(20000, Reflect.field(seed[0], "sortIndex"));
		Assert.equals("40", Reflect.field(seed[0], "tId"));
		Assert.equals(4001, Reflect.field(seed[1], "sortIndex"));
		Assert.equals(1601, Reflect.field(seed[2], "sortIndex"));
		Assert.equals(1555, Reflect.field(seed[3], "sortIndex"));
		// tId "40" type 4 → animalPackFood 原对象（:842-845）
		Assert.equals(30, Reflect.field(fd.animalPackFood, "amount"));
	}

	// —— flyFn/foodFn/killFn/clearBBFn 应答组 ——

	// flyFn 成功（:466-473）：num=total、mynum 累加、flyNum1/2 对半分
	// （floor）、leftFly=leftnum
	public function test_flyFn_success_split() {
		var fd = MData.getInstance().farmData;
		fd.flyData = {num: 0, mynum: 0, flyNum1: 0, flyNum2: 0, type: 1};
		Command.getInstance().farmCommand.addFly(2);
		env.respond({total: 7, num: 2, leftnum: 20});
		var fly = fd.flyData;
		Assert.equals(7, Reflect.field(fly, "num"));
		Assert.equals(2, Reflect.field(fly, "mynum"));
		Assert.equals(3, Reflect.field(fly, "flyNum1")); // floor(7/2)
		Assert.equals(4, Reflect.field(fly, "flyNum2")); // 7-3
		Assert.equals(20, FarmData.leftFly);
	}

	// flyFn "-2005" 特判（:450-456）：maxFly true + leftFly 0 + maxErrInfo
	public function test_flyFn_2005_maxfly() {
		Command.getInstance().farmCommand.addFly(1);
		env.respond({errorType: "-2005", errorContent: "每天最多使坏25次"});
		Assert.isTrue(FarmData.maxFly);
		Assert.equals(0, FarmData.leftFly);
		Assert.equals("每天最多使坏25次", FarmData.maxErrInfo);
	}

	// foodFn type 1 购买通道（:736-749）：host.animalFood=total、money 取负
	// 入账（负负得正——:742 原文 `param1["money"] = -param1["money"]`）
	public function test_foodFn_type1_money_negated() {
		var md = MData.getInstance().mainData;
		Command.getInstance().farmCommand.addFood(50, 1);
		env.respond({type: 1, total: 1050, money: -300, animal: []});
		Assert.equals(1050, Reflect.field(md.host, "animalFood"));
		// money -(-(-300))：先取负 -money=300 入账 → 5000+300……
		// 原文顺序：money = -money 后 addMoney(param1)——money 键此时 300
		Assert.equals(5300, Reflect.field(md.host, "money"));
	}

	// foodFn type 0 背包通道（:750-771）：animalPackFood.amount -= added
	public function test_foodFn_type0_pack_decrement() {
		var fd = MData.getInstance().farmData;
		fd.animalPackFood = {amount: 30};
		var md = MData.getInstance().mainData;
		md.currentUser = {"uId": "200", "me": false};
		Command.getInstance().farmCommand.addFood(5, 0);
		env.respond({type: 0, added: 5, total: 100, addExp: 5, animal: []});
		Assert.equals(25, Reflect.field(fd.animalPackFood, "amount"));
		Assert.isTrue(fd.reloadUserSeed);
	}

	// addExp==-1 帮忙上限（:752-762）：非 me 且 !totalExp → 文案 +
	// totalExp 置位；me 态不弹（!this.mainData.me 条件）
	public function test_foodFn_addExp_minus1_cap() {
		var md = MData.getInstance().mainData;
		md.currentUser = {"uId": "200", "me": false};
		var fd = MData.getInstance().farmData;
		fd.animalPackFood = {amount: 30};
		Command.getInstance().farmCommand.addFood(5, 0);
		env.respond({type: 0, added: 5, total: 100, addExp: -1, animal: []});
		Assert.equals("每天帮忙最多增加300点经验，您已加满", Reflect.field(fd.farmOperate, "text"));
		Assert.equals("food", Reflect.field(fd.farmOperate, "type"));
		Assert.isTrue(FarmData.totalExp);
	}

	// killFn ecode 非零（:876-886）：recallTime<3 派 killFlyError；第三次
	// 起不派
	public function test_killFn_ecode_recall_gate() {
		Command.getInstance().farmCommand.killFly(1, 1);
		env.plainEvents = [];
		env.respond({ecode: 1, direction: "失败"});
		Assert.isTrue(env.plainEvents.indexOf("killFlyError") != -1);
		env.respond({ecode: 1, direction: "失败"});
		env.respond({ecode: 1, direction: "失败"});
		// _recallTime 已到 3 ——不再派（<3 门）；计数仍是前两次
		var count = 0;
		for (e in env.plainEvents) {
			if (e == "killFlyError") count++;
		}
		Assert.equals(2, count);
	}

	// killFn 蚊子被抢特判（:887-893）：errorContent 逐字匹配 →
	// killFly(1,4)+killFly(2,4) 双发（flyNum1/flyNum2 各扣 4）
	public function test_killFn_slowhand_double_kill() {
		var fd = MData.getInstance().farmData;
		fd.flyData = {num: 20, mynum: 0, flyNum1: 10, flyNum2: 10, type: 1};
		Command.getInstance().farmCommand.killFly(1, 1);
		env.respond({
			errorType: "logic",
			errorContent: "您下手太慢，蚊子已经被拍了"
		});
		Assert.equals(6, Reflect.field(fd.flyData, "flyNum1"));
		Assert.equals(6, Reflect.field(fd.flyData, "flyNum2"));
		Assert.equals(12, Reflect.field(fd.flyData, "num")); // 20-4-4
	}

	// killFn 成功 + addExp 0 上限（:906-916）：type "fly" 文案
	public function test_killFn_success_exp_cap() {
		var fd = MData.getInstance().farmData;
		fd.flyData = {num: 5, mynum: 0, flyNum1: 3, flyNum2: 2, type: 1};
		Command.getInstance().farmCommand.killFly(1, 1);
		env.respond({ecode: 0, pos: 1, num: 1, addExp: 0});
		Assert.equals("每天帮忙最多增加300点经验，您已加满", Reflect.field(fd.farmOperate, "text"));
		Assert.equals("fly", Reflect.field(fd.farmOperate, "type"));
		Assert.isTrue(FarmData.totalExp);
	}

	// clearBBFn 被抢特判（:1300-1306）：bbData.num=0 + clearAllBB
	public function test_clearBBFn_slowhand_zeroes() {
		var fd = MData.getInstance().farmData;
		fd.bbData = {num: 5};
		Command.getInstance().farmCommand.clearBB(1, 1);
		env.respond({errorType: "logic", errorContent: "您下手太慢，便便已经被清理了"});
		Assert.equals(0, Reflect.field(fd.bbData, "num"));
		Assert.isTrue(env.plainEvents.indexOf("clearAllBB") != -1);
	}

	// clearBBFn 成功（:1307-1329）：repNum 0 → 100 坨上限文案 type "bb"；
	// bbData.num 自减、clearBBPos 落 pos
	public function test_clearBBFn_success_decrement_and_cap() {
		var fd = MData.getInstance().farmData;
		fd.bbData = {num: 5};
		Command.getInstance().farmCommand.clearBB(3, 1);
		env.respond({ecode: 0, pos: 3, repNum: 0, addExp: 2});
		Assert.equals("每天最多清理100坨便便，您已满，不再入库", Reflect.field(fd.farmOperate, "text"));
		Assert.equals("bb", Reflect.field(fd.farmOperate, "type"));
		Assert.isTrue(FarmData.totalBB);
		Assert.equals(4, Reflect.field(fd.bbData, "num"));
		Assert.equals(3, fd.clearBBPos);
	}

	// —— 纯逻辑工具 ——

	// appendActivityItems（:378-414）：typeP+cId 双键匹配（:395）——命中
	// 时**活动侧 amount 覆盖服务端 amount**（:397 `_loc3_.amount =
	// _loc4_.amount`——param1 是被盖的背包数组、param2 是活动数组，覆盖
	// 方向照抄）、未中 concat 垫尾（:403-411）。私有方法经 getUserSeedFn
	// 的 activityItems 合并点间接驱动（:869-871：activityItems 在且
	// !reloadActivityItems → 合并后写 userSeed）。
	// 服务端条目形状出处 cgi_get_package.php:21-53 echo 拼装——背包条目
	// 键面 {amount,tId,tName,type[,tDesc,lv,price,appid]} **无 cId/typeP
	// 键**：生产上 cId==undefined 恒不命中（重复 id 在水果/工具/goods
	// 三段 JSON 键上互斥，不可能同 id 双条），活动卡恒 concat 追加。
	// 双键覆盖路径按源码逐字可达（同背包数组内重复 cId 条目的病态形状）——
	// fixture 显式布置重复 cId 的服务端双条钉死覆盖方向（覆盖错向时
	// 第二条断言反成）
	public function test_appendActivityItems_concat_unmatched_via_userseed() {
		var fc = Command.getInstance().farmCommand;
		var fd = MData.getInstance().farmData;
		fd.reloadUserSeed = true;
		fd.userSeed = null;
		// 活动条目形状出处 onActivityItems :997-1004（cId=propid、
		// amount=count、typeP 1、type -1）
		fd.activityItems = [
			{cId: "9001", typeP: 1, amount: 3, type: -1},
			{cId: "9002", typeP: 1, amount: 1, type: -1}
		];
		fd.reloadActivityItems = false;
		fc.getUserSeed();
		env.respond([{tId: "1101", type: "4", amount: 2}]); // 真实形状：无 cId/typeP
		// 服务端条无 cId 键 → 双键匹配恒不中（:395）——两活动卡 concat
		// 垫尾（:411），原背包条在前
		var seed:Array<Dynamic> = cast fd.userSeed;
		Assert.equals(3, seed.length);
		Assert.equals("1101", Reflect.field(seed[0], "tId"));
		Assert.equals("9001", Reflect.field(seed[1], "cId"));
		Assert.equals(3, Reflect.field(seed[1], "amount")); // 活动 amount 原样
		Assert.equals("9002", Reflect.field(seed[2], "cId"));
	}

	// 双键命中时的覆盖方向钉（:395-397）：同 cId 重复条目的服务端数组
	// + 同 cId/typeP 活动卡 → 命中条 amount 被活动值覆盖、第二条不命中
	// 原样。断言命中位序[0] 与未中位序[1] 的 amount 分野——覆盖方向
	// 写反时两位数值对调立即现形
	public function test_appendActivityItems_overwrite_direction() {
		var fc = Command.getInstance().farmCommand;
		var fd = MData.getInstance().farmData;
		fd.reloadUserSeed = true;
		fd.userSeed = null;
		fd.activityItems = [{cId: "9001", typeP: 1, amount: 3, type: -1}];
		fd.reloadActivityItems = false;
		fc.getUserSeed();
		env.respond([
			{tId: "9001", cId: "9001", typeP: 1, type: "-1", amount: 9},
			{tId: "9001", type: "-1", amount: 7} // 无 cId 键 → 不命中原样
		]);
		var seed:Array<Dynamic> = cast fd.userSeed;
		Assert.equals(2, seed.length); // 活动卡命中不再 concat（:403-411）
		Assert.equals(3, Reflect.field(seed[0], "amount")); // 9 被覆盖成 3（:397）
		Assert.equals(7, Reflect.field(seed[1], "amount"));
	}

	// requestNum（:1440-1462）：**原版 bug 照抄**——hasOwnProperty 检查
	// 用 param1 键，但读写恒字面量 "type" 键（:1442/1446/1451-1459）。
	// 后果两态：
	//  (a) 每次换不同 key 调用 → hasOwnProperty 恒 false → "type" 桶
	//      **反复重置** num=0——计数永不累积，恒 true；
	//  (b) 同一 key 连调 → 首次后 hasOwnProperty(key) 仍 false（写入
	//      的从来不是 key 自身！）——啊，等等：写恒落 "type"，所以
	//      hasOwnProperty(param1) 除非 param1=="type" 恒 false——
	//      即只有 param1=="type" 时计数才累积：num>5 且 10 秒内 → false
	//      （:1446-1452）。
	// private 经 @:access 钉
	// 合一件钉 requestNum 两态（请求计时器是实例私有态、跨用例共享——
	// @:access 先复位 requestTime 保证顺序无关）：(a) 非 "type" key 每次
	// 重置不累积；(b) "type" key 累积——6 次 true 后第 7 次 false
	public function test_requestNum_literal_type_key_bug() {
		var fc = Command.getInstance().farmCommand;
		resetRequestTime(fc);
		// (a) 不同 key：每次 hasOwnProperty(param1) false → "type" 桶
		// 重置 num=0 再 +=1 —— 第 7 次仍 true（计数从未超 1）
		Assert.isTrue(requestNumOf(fc, "alpha", 1));
		Assert.isTrue(requestNumOf(fc, "beta", 1));
		Assert.isTrue(requestNumOf(fc, "gamma", 1));
		Assert.isTrue(requestNumOf(fc, "delta", 1));
		Assert.isTrue(requestNumOf(fc, "epsilon", 1));
		Assert.isTrue(requestNumOf(fc, "zeta", 1));
		Assert.isTrue(requestNumOf(fc, "eta", 1));
		// (b) 复位后 "type" key 连调：首次 init，之后 hasOwnProperty
		// ("type") true 不再重置——计数累积：前 6 次 true（第 6 次检查
		// 时 num=5 不>5），第 7 次 num=6>5 且 10 秒内 → false
		resetRequestTime(fc);
		Assert.isTrue(requestNumOf(fc, "type", 1));
		Assert.isTrue(requestNumOf(fc, "type", 1));
		Assert.isTrue(requestNumOf(fc, "type", 1));
		Assert.isTrue(requestNumOf(fc, "type", 1));
		Assert.isTrue(requestNumOf(fc, "type", 1));
		Assert.isTrue(requestNumOf(fc, "type", 1));
		Assert.isFalse(requestNumOf(fc, "type", 1));
	}

	@:access(mc.control.FarmCommand)
	static function requestNumOf(fc:mc.control.FarmCommand, key:String, n:Int):Bool {
		return fc.requestNum(key, n);
	}

	@:access(mc.control.FarmCommand)
	static function resetRequestTime(fc:mc.control.FarmCommand):Void {
		fc.requestTime = {};
	}
}
