package module.water;

import com.qzone.qfa.events.CommandEvent;
import common.CommonData;
import common.Settings;
import common.Session;
import common.misc.Utils;
import entities.PoolFish;
import entities.Player;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.vo.ServiceResultVO;
import openfl.events.Event;
import utest.Assert;

/**
 * WaterModel 纯逻辑（issue #37）：鱼塘数据层——装载门位（loadFishes 的
 * _requestPending 闸 + resetLoadingFlags/checkWhiteList）、cgi_fish_index
 * 应答（null 载荷关塘 / 数组装载 + 逐鱼 calcNextStepTime）、可偷判定
 * （canSteal 的 checkAll 短路、thief 名单、left>min 门槛）、一键捞的
 * 返回码表（-3 pending/-2 无可捞/-1 被门槛挡/0 发出，主人侧不看 min 与
 * thief）、单捞/放/喂的副作用位、cgi_fish_harvest 应答（单对象：exp 升级
 * 派发 + 出队 + FISH_HARVESTED；数组：EVENT_BATCH_FISH(2) 起批）、
 * cgi_fish_steal 应答（thief 补记 + status 回写 + remove 判定）、
 * processBatchFish 批处理队列推进、growLoop 成熟结算的重发闸
 * （_requestOutput 单飞 + _requestOutputRecord 两连发封顶）、onGetOutput
 * 匹配回写、onNetError 七个 cmdID 的派发表（open 关塘/output 记账封顶/
 * waterOpen 缺省文案「服务器错误.」/steal 的 direction+l,o 双路/harvest/
 * feed 的 ERROR_MSG、grow 不派发）。
 * WaterController/WaterPool/FishInfoTip/PoolInfoWindow 是接线与显示层，
 * 归 CI web-smoke。
 *
 * 环境口径（同 #35/#36 模块先例）：
 * - NetHelper.sendRequest/getRequest 在 theApp == null 时 no-op（#7 已译），
 *   测试进程不跑 Main、theApp 恒 null——请求侧参数拼装（harvestAll 的
 *   index 逗号串 + flag 2/1 + ownerId、harvest 的 flag、feed 的 {index,tid}、
 *   grow 的 {fid}、openWater 的 {yellow}）不可观测，不设测试；应答侧直接喂
 *   构造好的 CommandEvent（body 用 Utils.buildRequest 造出与真实链路同构的
 *   {cmdID,__body,…}，result 装 ServiceResultVO，走 NetHelper.getVOData 的
 *   m_extra 分支）。openWater 本身无任何可观测状态变化，不设测试。
 * - EventRecorder 按 deviations（no-qq-telemetry）DISABLED，
 *   startARequest/recordSueecssEvent/recordErrorEvent 只保不抛；
 *   Session.updateHostAccount 是 #29 已译的 no-op 存根，onGrowFish/
 *   processHarvestFish 的 exp 分支只剩 EVENT_LEVELUP 可观测。
 * - Session 注入：host._uId=1 恒定（hostId → "1" → parseInt 1），主人侧
 *   currentUser 同 uId 1（me=true），访客侧 currentUser uId 2（me=false）。
 * - Settings 经 m_configDataModel 注入 FakeConfigModel（PoolFishTest 同款，
 *   fish_info 的 id 是 JSON 数字、PoolFish 按 Std.string(_type) 查）。
 * - CommonData.serverTime=0 走 get 的 _serverTime==0 纯分支（不读时钟），
 *   「已流逝秒数」用负 p 合成（elapsed=serverTime-p）。
 * - EVENT_NOT_WHITELIST（:29）声明后全类无派发点，不在监听面。
 * - 私有应答回调/字段（onDataLoaded、_requestOutput 等）经 @:access 直取：
 *   FriendsModelTest/FriendsModelFollowupTest 先例。
 *
 * 出处：
 * - legacy/decompiled/pool_v_13/scripts/module/water/WaterModel.as
 *   （常量 :19-39、ctor :57-68、onWaterOpened :70-75、onHarvestFish :77-98、
 *   findFishByID :100-113、processStealFish :115-145、poolFishes :147-150、
 *   loadFishes :152-161、harvestAll :163-225、onGrowFish :227-249、grow
 *   :251-263、canOperate :265-272、growLoop :274-312、onGetOutput :314-335、
 *   resetLoadingFlags :337-343、onFeedFish :345-365、onDataLoaded :367-387、
 *   feed :389-397、canSteal :399-429、onStealFish :431-451、onNetError
 *   :453-542、openWater :544-550、checkSize :552-559、processHarvestFish
 *   :561-593、harvest :595-625、processBatchFish :627-658、poolSize :660-673、
 *   checkWhiteList :675-679）
 * - legacy/deploy/QFarmFlash/source/core/source/xml/mod/nc_data.php:7565
 *   fish_info 数组（单行）——小丑鱼 id 2 cycle "21600,50400,82800" output 15
 *   pool_size 1（min=ceil(15*0.6)=9）、蝶鱼 id 4 cycle "28800,64800,108000"
 *   output 24 pool_size 1、蝠鲼 id 13 cycle "54000,126000,216000" output 29
 *   pool_size 2（成熟 p=-216000）、海豚 id 14 cycle
 *   "57600,129600,244800" output 25 pool_size 3（成熟 p=-244800）。字段值
 *   逐字，id 保持 JSON 数字原形状。
 * - spec/protocol.json entries.nc.mods：cgi_fish_index（ownerId 参数、
 *   fish[].fid/p/o/l/s 与 open 返回）、cgi_fish_harvest（index/flag 参数、
 *   code/exp/i/o 返回）、cgi_fish_steal（index/flag/ownerId 参数、code/
 *   harvest/index/status 返回，多格成功时响应是数组）、cgi_fish_output
 *   （index/ownerId 参数、i/l/o/p 返回）、cgi_fish_plant（fid 参数、code/
 *   exp/fid/i/o/p 返回）、cgi_fish_fertilize（index/tid 参数、i/f/l/o/p
 *   返回）、cgi_fish_register（无参数）
 * - entities/PoolFish.as（#29 已译，src/entities/PoolFish.hx）：level 按
 *   serverTime-p 落 cycle 段（p=-82800 的小丑鱼 level 3 成熟、p=-1000
 *   level 0）、min=ceil(output*0.6)、poolSize 取配置 pool_size、
 *   calcNextStepTime 满级置 POSITIVE_INFINITY、ctor 把 _nextStepTime 清 0
 * - Consts.hx:313 FISH_MAX_SIZE=6（checkSize 门槛）、:315 FISH_MAX_LEVEL=3
 */
@:access(module.water.WaterModel)
@:access(common.Settings)
class WaterModelTest {
	public function new() {}

	var model:WaterModel;

	var savedHost:Player;
	var savedCurrentUser:Player;

	var hostPlayer:Player;
	var mePlayer:Player;
	var guestPlayer:Player;

	public function setup() {
		var s = Session.getInstance();
		savedHost = s.host;
		savedCurrentUser = s.currentUser;

		hostPlayer = new Player({});
		hostPlayer._uId = 1;
		hostPlayer._userName = "塘主";
		mePlayer = new Player({});
		mePlayer._uId = 1;
		mePlayer._userName = "塘主";
		guestPlayer = new Player({});
		guestPlayer._uId = 2;
		guestPlayer._userName = "访客";
		s.host = hostPlayer;

		model = freshModel();
		becomeHost();
		Settings.getInstance().loadLocalSettings(null); // m_params/m_configDataModel 复位
		pinDefault();
		CommonData.serverTime = 0; // get_serverTime 纯分支，不读时钟
	}

	public function teardown() {
		var s = Session.getInstance();
		s.host = savedHost;
		s.currentUser = savedCurrentUser;
		Settings.getInstance().loadLocalSettings(null);
		Settings.getInstance().m_configDataModel = null;
		CommonData.serverTime = 0;
	}

	// stub 的 ctor 无默认值（那是实现内容），各用例统一从这里起手
	static function freshModel():WaterModel {
		return new WaterModel(null);
	}

	function becomeHost():Void {
		Session.getInstance().currentUser = mePlayer; // me=true（Session.as:108-118）
	}

	function becomeGuest():Void {
		Session.getInstance().currentUser = guestPlayer; // me=false、hostId 仍 "1"
	}

	// ---------- fish_info fixture（nc_data.php:7565 逐字裁剪） ----------

	static function clownRow():Dynamic {
		return {"crop_name": "小丑鱼", "cycle": "21600,50400,82800", "id": 2,
			"output": 15, "pool_size": 1};
	}

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

	static function pinDefault():Void {
		pinFishInfo([clownRow(), butterflyRow(), mantaRow(), dolphinRow()]);
	}

	// 小丑鱼 p=-82800：elapsed 82800 → level 3 成熟（canHarvest true、
	// calcNextStepTime 置 INF）；min=ceil(_output>0?_output:15 * 0.6)=9
	static function matureClown(id:Int, left:Int, output:Int, thief:Array<Dynamic> = null):PoolFish {
		return new PoolFish({i: id, fid: 2, l: left, o: output, p: -82800, s: thief});
	}

	// 小丑鱼 p=-1000：elapsed 1000 → level 0（未成熟、nextStep=p+21600）
	static function youngClown(id:Int):PoolFish {
		return new PoolFish({i: id, fid: 2, l: 0, o: 0, p: -1000});
	}

	static function matureManta(id:Int):PoolFish {
		return new PoolFish({i: id, fid: 13, l: 29, o: 29, p: -216000});
	}

	static function matureDolphin(id:Int):PoolFish {
		return new PoolFish({i: id, fid: 14, l: 25, o: 25, p: -244800});
	}

	// ---------- 事件捕获（ShopModelTest 同款） ----------

	// 10 个会被 WaterModel 派发的事件（EVENT_NOT_WHITELIST :29 声明后全类
	// 无派发点，不在监听面）：{type, data} 落 log
	function listenModel(m:WaterModel, log:Array<Dynamic>):Void {
		var names:Array<String> = [
			WaterModel.EVENT_DATA_LOADED, WaterModel.EVENT_FISH_PLANTED,
			WaterModel.EVENT_FISH_HARVESTED, WaterModel.EVENT_ERROR_MSG,
			WaterModel.EVENT_FISH_CHANGED, WaterModel.EVENT_WATER_OPENED,
			WaterModel.EVENT_LEVELUP, WaterModel.EVENT_GROW_UP,
			WaterModel.EVENT_BATCH_FISH, WaterModel.EVENT_UPDATE_MATURE_FLAG
		];
		for (n in names) {
			m.addEventListener(n, function(e:Event) {
				log.push({type: e.type, data: cast(e, CommonEvent).data});
			});
		}
	}

	static function countType(log:Array<Dynamic>, type:String):Int {
		var n = 0;
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				n++;
			}
		}
		return n;
	}

	static function lastData(log:Array<Dynamic>, type:String):Dynamic {
		var out:Dynamic = null;
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				out = Reflect.field(entry, "data");
			}
		}
		return out;
	}

	// 应答事件：body 用 Utils.buildRequest 造出与 NetHelper.sendRequest →
	// theApp.run 真实链路同构的 {cmdID, __body, __format}；result 装入
	// ServiceResultVO（getVOData 的 m_extra 分支）。同 ShopModelTest。
	static function voEvent(cmd:Int, reqParams:Dynamic, payload:Dynamic):CommandEvent {
		var vo = new ServiceResultVO();
		vo.m_extra = payload;
		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.body = Utils.buildRequest(cmd, reqParams);
		ev.result = vo;
		return ev;
	}

	// ---------- :19-39 常量 + :57-68 ctor 零位 ----------

	// :19-39 事件名常量；:60-67 ctor 零位（opened/whited false、_fishes null、
	// _requestPending false、_requestOutput -1、_requestOutputRecord null、
	// _batchFish null、_batchFlag 0）
	public function test_event_constants_and_ctor_defaults() {
		Assert.equals("Fish Data Loaded", WaterModel.EVENT_DATA_LOADED); // :19
		Assert.equals("Fish Planted", WaterModel.EVENT_FISH_PLANTED); // :21
		Assert.equals("Fish Harvested", WaterModel.EVENT_FISH_HARVESTED); // :23
		Assert.equals("Error Message", WaterModel.EVENT_ERROR_MSG); // :25
		Assert.equals("Fish Data Changed", WaterModel.EVENT_FISH_CHANGED); // :27
		Assert.equals("Not in Whitelist", WaterModel.EVENT_NOT_WHITELIST); // :29
		Assert.equals("Water Pool is Open", WaterModel.EVENT_WATER_OPENED); // :31
		Assert.equals("LevelUp", WaterModel.EVENT_LEVELUP); // :33
		Assert.equals("GrowUp", WaterModel.EVENT_GROW_UP); // :35
		Assert.equals("BatchProcessFish", WaterModel.EVENT_BATCH_FISH); // :37
		Assert.equals("UpdateMatureFlag", WaterModel.EVENT_UPDATE_MATURE_FLAG); // :39
		var raw = freshModel();
		Assert.isFalse(raw.opened); // :60
		Assert.isFalse(raw.whited); // :61
		Assert.isNull(raw.poolFishes); // :62（_fishes null）
		Assert.isFalse(raw._requestPending); // :63
		Assert.equals(-1, raw._requestOutput); // :64
		Assert.isNull(raw._requestOutputRecord); // :65
		Assert.isNull(raw._batchFish); // :66
		Assert.equals(0, raw._batchFlag); // :67
	}

	// ---------- :152-161/:337-343/:675-679 装载门位 ----------

	// loadFishes 置 _requestPending（:158）；pending 期 harvestAll 被
	// canOperate 挡回 -3（:165-168 经 :265-272）；resetLoadingFlags 复位
	// （:337-343）；checkWhiteList 置 whited 并连带 loadFishes（:675-679）
	public function test_loadFishes_pending_gate_reset_and_checkWhiteList() {
		model.loadFishes();
		Assert.isTrue(model._requestPending);
		Assert.equals(-3, model.harvestAll());

		model.resetLoadingFlags();
		Assert.isFalse(model._requestPending);

		var m2 = freshModel();
		Assert.isFalse(m2.whited);
		m2.checkWhiteList();
		Assert.isTrue(m2.whited); // :677
		Assert.isTrue(m2._requestPending); // :678 的 loadFishes
	}

	// ---------- :367-387 cgi_fish_index 应答 ----------

	// null 载荷：关塘 + EVENT_DATA_LOADED(null)（:370-376）
	public function test_onDataLoaded_null_payload_closes_pool() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model.opened = true; // 预置，观测被翻回
		model.loadFishes(); // pending true
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_FISHES, {ownerId: 1}, null));
		Assert.isFalse(model.opened); // :374
		Assert.isFalse(model._requestPending); // :370
		Assert.equals(1, countType(log, WaterModel.EVENT_DATA_LOADED));
		Assert.isNull(lastData(log, WaterModel.EVENT_DATA_LOADED)); // data null
	}

	// 数组载荷：开塘 + _fishes 同引用 + 逐鱼 calcNextStepTime（ctor 清过的
	// _nextStepTime 被算回）+ EVENT_DATA_LOADED(fishes)（:378-386）
	public function test_onDataLoaded_array_loads_and_recalculates() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var mature = matureClown(5, 15, 15, []);
		var young = youngClown(6);
		var fishes = [mature, young];
		Assert.equals(0, mature._nextStepTime); // PoolFish ctor 清 0 的前提

		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_FISHES, {ownerId: 1}, fishes));
		Assert.isTrue(model.opened); // :378
		Assert.equals(fishes, model.poolFishes); // :379 同引用
		Assert.isTrue(model._requestOutputRecord != null); // :380
		Assert.isTrue(mature._nextStepTime == Math.POSITIVE_INFINITY); // :383 → level 3
		Assert.equals(20600, young._nextStepTime); // -1000 + cycle[0] 21600
		Assert.equals(1, countType(log, WaterModel.EVENT_DATA_LOADED));
		Assert.equals(fishes, lastData(log, WaterModel.EVENT_DATA_LOADED)); // :385 同引用
	}

	// ---------- :100-113 findFishByID ----------

	public function test_findFishByID_hit_and_miss() {
		model._fishes = [matureClown(5, 15, 15, []), youngClown(6)];
		Assert.equals(6, model.findFishByID(6)._id);
		Assert.isNull(model.findFishByID(99)); // :112
	}

	// ---------- :660-673/:552-559 poolSize 与 checkSize ----------

	public function test_poolSize_and_checkSize() {
		Assert.equals(0, model.poolSize); // :663-665 _fishes null

		model._fishes = [matureClown(1, 15, 15, []), matureClown(2, 15, 15, []),
			matureClown(3, 15, 15, []), matureClown(4, 15, 15, []),
			matureClown(5, 15, 15, []), matureClown(6, 15, 15, [])];
		Assert.equals(6, model.poolSize); // 6 × pool_size 1
		Assert.isFalse(model.checkSize()); // 6 >= FISH_MAX_SIZE 6（Consts.hx:313）

		model._fishes = [matureManta(1), matureDolphin(2), matureClown(3, 15, 15, [])];
		Assert.equals(6, model.poolSize); // 2 + 3 + 1
		Assert.isFalse(model.checkSize());

		model._fishes = [matureManta(1), matureDolphin(2)]; // 5 < 6
		Assert.isTrue(model.checkSize());

		model._fishes = null;
		Assert.isTrue(model.checkSize()); // poolSize 0
	}

	// ---------- :399-429 canSteal ----------

	// canSteal(checkAll)：checkAll=true 对首条「成熟且 _left>0」短路 true
	// （:412-417）；false 时查 thief 名单（hostId=1）与 left>min（min=9）
	public function test_canSteal_matrix() {
		becomeGuest();
		var cases:Array<{fishes:Array<Dynamic>, checkAll:Bool, expected:Bool, why:String}> = [
			{fishes: null, checkAll: true, expected: false, why: "无鱼"},
			{fishes: [], checkAll: true, expected: false, why: "空数组"},
			{fishes: [youngClown(6)], checkAll: true, expected: false, why: "未成熟跳过"},
			{fishes: [matureClown(5, 0, 15)], checkAll: true, expected: false, why: "_left=0 跳过"},
			{fishes: [matureClown(5, 15, 15, [])], checkAll: true, expected: true, why: "checkAll 短路"},
			{fishes: [matureClown(5, 15, 15, [])], checkAll: false, expected: true, why: "非贼 left15>min9"},
			{fishes: [matureClown(5, 10, 15, [])], checkAll: false, expected: true, why: "left10>min9"},
			{fishes: [matureClown(5, 9, 15, [])], checkAll: false, expected: false, why: "left==min 不大于"},
			{fishes: [matureClown(5, 15, 15, [1])], checkAll: false, expected: false, why: "已在 thief 名单"},
			{fishes: [youngClown(6), matureClown(5, 15, 15, [1])], checkAll: false, expected: false, why: "混合全被挡"}
		];
		for (c in cases) {
			var m = freshModel();
			m._fishes = c.fishes;
			Assert.equals(c.expected, m.canSteal(c.checkAll), '${c.why}（fishes=${c.fishes}）');
		}
	}

	// ---------- :163-225 harvestAll 返回码 ----------

	// -3 pending；-2 无可捞（空/未成熟/成熟但 left=0）；-1 访客被 thief/min
	// 挡；0 发出且 pending 置位。主人侧（me=true）不看 min 与 thief（:181-184
	// 直接 push），访客侧 :185-196
	public function test_harvestAll_return_codes() {
		becomeHost();
		var hostCases:Array<{fishes:Array<Dynamic>, expected:Int, why:String}> = [
			{fishes: null, expected: -2, why: "无鱼"},
			{fishes: [youngClown(6)], expected: -2, why: "未成熟"},
			{fishes: [matureClown(5, 0, 15)], expected: -2, why: "成熟但 left=0"},
			{fishes: [matureClown(5, 5, 15, [])], expected: 0, why: "主人不看 min：left5<min9 照捞"},
			{fishes: [matureClown(5, 15, 15, [1])], expected: 0, why: "主人不看 thief"}
		];
		for (c in hostCases) {
			var m = freshModel();
			m._fishes = c.fishes;
			Assert.equals(c.expected, m.harvestAll(), '主人侧 ${c.why}');
			if (c.expected == 0) {
				Assert.isTrue(m._requestPending); // :211/:221
			}
		}

		becomeGuest();
		var guestCases:Array<{fishes:Array<Dynamic>, expected:Int, why:String}> = [
			{fishes: [matureClown(5, 15, 15, [])], expected: 0, why: "可偷（走 CMD_STEAL_FISH 分支）"},
			{fishes: [matureClown(5, 15, 15, [1])], expected: -1, why: "已在 thief 名单"},
			{fishes: [matureClown(5, 9, 15, [])], expected: -1, why: "left==min 不可偷"}
		];
		for (c in guestCases) {
			var m = freshModel();
			m._fishes = c.fishes;
			Assert.equals(c.expected, m.harvestAll(), '访客侧 ${c.why}');
		}

		var m = freshModel();
		m.loadFishes();
		Assert.equals(-3, m.harvestAll()); // canOperate 挡
	}

	// ---------- :595-625 harvest / :251-263 grow / :389-397 feed ----------

	// 单捞：主人侧 flag 无关都发（:602-611）；访客侧 flag=false 早退
	// （:613-617）、flag=true 走偷（:617-624）
	public function test_harvest_single_gates() {
		becomeHost();
		model.harvest(5, false);
		Assert.isTrue(model._requestPending);

		becomeGuest();
		var m2 = freshModel();
		m2.harvest(5, false);
		Assert.isFalse(m2._requestPending); // 早退不置位

		var m3 = freshModel();
		m3.harvest(5, true);
		Assert.isTrue(m3._requestPending);
	}

	// 放鱼 grow：访客侧早退（:257-260）、主人侧置 pending（:261-262）
	public function test_grow_gates() {
		becomeGuest();
		var m1 = freshModel();
		m1.grow(2);
		Assert.isFalse(m1._requestPending);

		becomeHost();
		var m2 = freshModel();
		m2.grow(2);
		Assert.isTrue(m2._requestPending);
	}

	// 喂鱼 feed：无 canOperate 门，直接置 pending（:389-397）
	public function test_feed_sets_pending_without_gate() {
		becomeGuest();
		model.feed(5, 42);
		Assert.isTrue(model._requestPending);
	}

	// ---------- :345-365 cgi_fish_fertilize 应答 ----------

	// 命中：refreshStatus 回写 _left + EVENT_GROW_UP{fish,food}（food 取
	// body.__body.tid 的回显，:353-363）；未命中鱼：只复位 pending；VO null：
	// pending 保持（:349-352 早退先于复位）
	public function test_onFeedFish_updates_fish_and_dispatches_growup() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var fish = matureClown(5, 15, 15, []);
		model._fishes = [fish];
		model.feed(5, 42);
		model.onFeedFish(voEvent(CommandDefs.CMD_FEED_FISH, {index: 5, tid: 42},
			{i: 5, f: 1, l: 12, o: 15, p: -82800}));
		Assert.isFalse(model._requestPending); // :353
		Assert.equals(12, fish._left); // :357 refreshStatus
		Assert.equals(1, countType(log, WaterModel.EVENT_GROW_UP));
		var d = lastData(log, WaterModel.EVENT_GROW_UP);
		Assert.equals(fish, Reflect.field(d, "fish")); // 同实例
		Assert.equals(42, Reflect.field(d, "food")); // :358 的 tid 回显

		// 未命中：无派发、pending 仍复位
		var log2:Array<Dynamic> = [];
		var m2 = freshModel();
		listenModel(m2, log2);
		var fish2 = matureClown(5, 15, 15, []);
		m2._fishes = [fish2];
		m2.feed(5, 42);
		m2.onFeedFish(voEvent(CommandDefs.CMD_FEED_FISH, {index: 5, tid: 42},
			{i: 99, f: 1, l: 12, o: 15, p: -82800}));
		Assert.isFalse(m2._requestPending);
		Assert.equals(0, log2.length);

		// VO null：pending 保持
		var m3 = freshModel();
		m3._fishes = [matureClown(5, 15, 15, [])];
		m3.feed(5, 42);
		m3.onFeedFish(voEvent(CommandDefs.CMD_FEED_FISH, {index: 5, tid: 42}, null));
		Assert.isTrue(m3._requestPending);
	}

	// ---------- :77-98/:561-593 cgi_fish_harvest 应答（单对象） ----------

	// code=1：exp 在时先 EVENT_LEVELUP（:235-239 同款分支 :567-571）、出队
	// 该鱼、EVENT_FISH_HARVESTED{count:o,id:i,remove:true}；code!=1 无派发
	public function test_onHarvestFish_object_removes_and_dispatches() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var a = matureClown(5, 15, 15, []);
		var b = youngClown(6);
		model._fishes = [a, b];
		var payload = {code: 1, exp: 3, i: 5, o: 15};
		model.onHarvestFish(voEvent(CommandDefs.CMD_HARVEST_FISH, {index: 5, flag: 1}, payload));
		Assert.isFalse(model._requestPending); // :79
		Assert.isNull(model._batchFish); // :93 单对象清批
		Assert.equals(0, model._batchFlag); // :94
		Assert.equals(1, model.poolFishes.length);
		Assert.equals(6, model.poolFishes[0]._id); // :580-586 splice
		Assert.equals(2, log.length);
		Assert.equals(WaterModel.EVENT_LEVELUP, Reflect.field(log[0], "type")); // 先升级
		Assert.equals(payload, Reflect.field(log[0], "data")); // :238/:570 原载荷
		Assert.equals(WaterModel.EVENT_FISH_HARVESTED, Reflect.field(log[1], "type"));
		var d = Reflect.field(log[1], "data");
		Assert.equals(15, Reflect.field(d, "count")); // :589 count=o
		Assert.equals(5, Reflect.field(d, "id")); // :590 id=i
		Assert.isTrue(Reflect.field(d, "remove")); // :591 字面 true

		// 无 exp：只派发 FISH_HARVESTED
		var log2:Array<Dynamic> = [];
		var m2 = freshModel();
		listenModel(m2, log2);
		m2._fishes = [matureClown(5, 15, 15, []), youngClown(6)];
		m2.onHarvestFish(voEvent(CommandDefs.CMD_HARVEST_FISH, {index: 5, flag: 1},
			{code: 1, i: 5, o: 15}));
		Assert.equals(1, log2.length);
		Assert.equals(WaterModel.EVENT_FISH_HARVESTED, Reflect.field(log2[0], "type"));

		// code!=1：无派发、鱼保留
		var log3:Array<Dynamic> = [];
		var m3 = freshModel();
		listenModel(m3, log3);
		m3._fishes = [matureClown(5, 15, 15, [])];
		m3.onHarvestFish(voEvent(CommandDefs.CMD_HARVEST_FISH, {index: 5, flag: 1},
			{code: 0, i: 5, o: 15}));
		Assert.equals(0, log3.length);
		Assert.equals(1, m3.poolFishes.length);
	}

	// ---------- :77-98 cgi_fish_harvest 应答（数组） ----------

	// 多格成功时 cgi_fish_steal/harvest 响应是数组：起批 _batchFish 同引用、
	// _batchFlag=1、EVENT_BATCH_FISH(2)（:85-90）
	public function test_onHarvestFish_array_starts_batch() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var batch = [{code: 1, i: 5, o: 15}, {code: 1, i: 6, o: 15}];
		model.onHarvestFish(voEvent(CommandDefs.CMD_HARVEST_FISH, {index: "5,6", flag: 2}, batch));
		Assert.equals(batch, model._batchFish); // 同引用
		Assert.equals(1, model._batchFlag);
		Assert.equals(1, countType(log, WaterModel.EVENT_BATCH_FISH));
		Assert.equals(2, lastData(log, WaterModel.EVENT_BATCH_FISH)); // :89
	}

	// ---------- :431-451/:115-145 cgi_fish_steal 应答（单对象） ----------

	// code=1：harvest>0 且 hostId 不在名单才补记 thief（:126-130）；status
	// 的 l/o/p 回写（:131-133）；remove=_output>0 && _left==0（:136-138）
	public function test_onStealFish_object_records_thief_and_status() {
		becomeGuest(); // hostId "1" → parseInt 1
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var fish = matureClown(5, 15, 15, []);
		model._fishes = [fish];
		model.onStealFish(voEvent(CommandDefs.CMD_STEAL_FISH, {index: 5, flag: 1, ownerId: 1},
			{code: 1, index: 5, harvest: 6, status: {l: 9, o: 15, p: -82800}}));
		Assert.equals(1, fish._thief.length);
		Assert.equals(1, fish._thief[0]); // hostId 1 入名单
		Assert.equals(9, fish._left); // status.l
		Assert.equals(15, fish._output); // status.o
		Assert.equals(-82800, fish._plantTime); // status.p
		Assert.equals(1, countType(log, WaterModel.EVENT_FISH_HARVESTED));
		var d = lastData(log, WaterModel.EVENT_FISH_HARVESTED);
		Assert.equals(6, Reflect.field(d, "count")); // harvest
		Assert.equals(5, Reflect.field(d, "id")); // index
		Assert.isFalse(Reflect.field(d, "remove")); // o15>0 但 l9≠0

		// status.l=0：remove=true
		var log2:Array<Dynamic> = [];
		var m2 = freshModel();
		listenModel(m2, log2);
		var fish2 = matureClown(5, 15, 15, []);
		m2._fishes = [fish2];
		m2.onStealFish(voEvent(CommandDefs.CMD_STEAL_FISH, {index: 5, flag: 1, ownerId: 1},
			{code: 1, index: 5, harvest: 15, status: {l: 0, o: 15, p: -82800}}));
		var d2 = lastData(log2, WaterModel.EVENT_FISH_HARVESTED);
		Assert.isTrue(Reflect.field(d2, "remove"));

		// harvest=0：不补记 thief
		var m3 = freshModel();
		var fish3 = matureClown(5, 15, 15, []);
		m3._fishes = [fish3];
		m3.onStealFish(voEvent(CommandDefs.CMD_STEAL_FISH, {index: 5, flag: 1, ownerId: 1},
			{code: 1, index: 5, harvest: 0, status: {l: 9, o: 15, p: -82800}}));
		Assert.equals(0, fish3._thief.length);

		// code!=1：无派发
		var log4:Array<Dynamic> = [];
		var m4 = freshModel();
		listenModel(m4, log4);
		m4._fishes = [matureClown(5, 15, 15, [])];
		m4.onStealFish(voEvent(CommandDefs.CMD_STEAL_FISH, {index: 5, flag: 1, ownerId: 1},
			{code: 0, index: 5, harvest: 6, status: {l: 9, o: 15, p: -82800}}));
		Assert.equals(0, log4.length);
	}

	// 数组：_batchFlag=2 + EVENT_BATCH_FISH(2)（:439-444）
	public function test_onStealFish_array_sets_batchflag_2() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var batch = [{code: 1, index: 5, harvest: 6, status: {l: 9, o: 15, p: -82800}}];
		model.onStealFish(voEvent(CommandDefs.CMD_STEAL_FISH, {index: "5", flag: 1, ownerId: 1}, batch));
		Assert.equals(batch, model._batchFish);
		Assert.equals(2, model._batchFlag);
		Assert.equals(1, countType(log, WaterModel.EVENT_BATCH_FISH));
		Assert.equals(2, lastData(log, WaterModel.EVENT_BATCH_FISH)); // :443
	}

	// ---------- :627-658 processBatchFish ----------

	// 逐条 shift 处理（_batchFlag=2 → processStealFish）：每条后
	// EVENT_BATCH_FISH(1)；还有剩余且下一条 harvest>0 时
	// EVENT_UPDATE_MATURE_FLAG(下一条 index) 并返回 true；排空后
	// EVENT_BATCH_FISH(0) 返回 false（:629-658）
	public function test_processBatchFish_steal_queue() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model._fishes = [matureClown(5, 15, 15, []), matureClown(6, 15, 15, [])];
		var batch = [
			{code: 1, index: 5, harvest: 6, status: {l: 9, o: 15, p: -82800}},
			{code: 1, index: 6, harvest: 3, status: {l: 8, o: 15, p: -82800}}
		];
		model.onStealFish(voEvent(CommandDefs.CMD_STEAL_FISH, {index: "5,6", flag: 1, ownerId: 1}, batch));

		Assert.isTrue(model.processBatchFish());
		Assert.equals(WaterModel.EVENT_FISH_HARVESTED, Reflect.field(log[0], "type"));
		Assert.equals(5, Reflect.field(Reflect.field(log[0], "data"), "id"));
		Assert.equals(WaterModel.EVENT_BATCH_FISH, Reflect.field(log[1], "type"));
		Assert.equals(1, Reflect.field(log[1], "data"));
		Assert.equals(WaterModel.EVENT_UPDATE_MATURE_FLAG, Reflect.field(log[2], "type"));
		Assert.equals(6, Reflect.field(log[2], "data")); // 下一条 index、harvest 3>0

		Assert.isFalse(model.processBatchFish()); // 排空
		Assert.equals(WaterModel.EVENT_FISH_HARVESTED, Reflect.field(log[3], "type"));
		Assert.equals(6, Reflect.field(Reflect.field(log[3], "data"), "id"));
		Assert.equals(1, Reflect.field(log[4], "data")); // BATCH_FISH(1)
		Assert.equals(0, Reflect.field(log[5], "data")); // BATCH_FISH(0)
		Assert.equals(6, log.length);

		// 无批与空批：false（:629-632）
		Assert.isFalse(freshModel().processBatchFish());
		var m2 = freshModel();
		m2.onStealFish(voEvent(CommandDefs.CMD_STEAL_FISH, {index: "", flag: 1, ownerId: 1}, []));
		Assert.isFalse(m2.processBatchFish());
	}

	// _batchFlag=1 的批走 processHarvestFish：出队 + remove=true（:638-640）
	public function test_processBatchFish_harvest_queue() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var fish = matureClown(5, 15, 15, []);
		model._fishes = [fish, youngClown(6)];
		model.onHarvestFish(voEvent(CommandDefs.CMD_HARVEST_FISH, {index: "5", flag: 2},
			[{code: 1, i: 5, o: 15}]));
		Assert.isFalse(model.processBatchFish()); // 单条：处理后排空
		Assert.equals(1, countType(log, WaterModel.EVENT_FISH_HARVESTED));
		var d = lastData(log, WaterModel.EVENT_FISH_HARVESTED);
		Assert.isTrue(Reflect.field(d, "remove"));
		Assert.equals(1, model.poolFishes.length); // id 5 出队
		Assert.equals(6, model.poolFishes[0]._id);
		Assert.equals(0, lastData(log, WaterModel.EVENT_BATCH_FISH)); // 收尾 BATCH_FISH(0)
	}

	// ---------- :274-312 growLoop / :314-335 onGetOutput ----------

	// 成熟（nextStepTime=INF）且 _output<=0 的鱼触发 cgi_fish_output 请求
	// 位 _requestOutput（单飞：已在请求中不再发，:291-307）；应答 i 匹配时
	// 回写 l/o、复位请求位、EVENT_FISH_CHANGED；回写后 _output>0 不再发
	public function test_growLoop_output_request_cycle() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var fish = matureClown(5, 0, 0); // 成熟但已产空
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_FISHES, {ownerId: 1}, [fish])); // 顺带建 record
		model.growLoop();
		Assert.equals(5, model._requestOutput); // :295

		model.onGetOutput(voEvent(CommandDefs.CMD_FISH_OUTPUT, {index: 5, ownerId: 1},
			{i: 5, l: 15, o: 15}));
		Assert.equals(-1, model._requestOutput); // :331
		Assert.equals(15, fish._left); // :329
		Assert.equals(15, fish._output); // :330
		Assert.equals(1, countType(log, WaterModel.EVENT_FISH_CHANGED));
		Assert.equals(fish, lastData(log, WaterModel.EVENT_FISH_CHANGED));

		model.growLoop(); // _output 已 15>0：不再发
		Assert.equals(-1, model._requestOutput);
		Assert.equals(1, countType(log, WaterModel.EVENT_FISH_CHANGED));
	}

	// _requestOutputRecord[id] >= 2 封顶（:291）：两轮「请求→应答 o=0 保持
	// 产空」后第三轮不再发（封顶只可经行为观测——请求侧不可见）
	public function test_growLoop_caps_at_two_attempts() {
		var fish = matureClown(5, 0, 0);
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_FISHES, {ownerId: 1}, [fish]));
		model.growLoop();
		Assert.equals(5, model._requestOutput); // 第 1 次
		model.onGetOutput(voEvent(CommandDefs.CMD_FISH_OUTPUT, {index: 5, ownerId: 1},
			{i: 5, l: 0, o: 0}));
		Assert.equals(-1, model._requestOutput);
		model.growLoop();
		Assert.equals(5, model._requestOutput); // 第 2 次
		model.onGetOutput(voEvent(CommandDefs.CMD_FISH_OUTPUT, {index: 5, ownerId: 1},
			{i: 5, l: 0, o: 0}));
		Assert.equals(-1, model._requestOutput);
		model.growLoop();
		Assert.equals(-1, model._requestOutput); // 封顶后不再发
	}

	// :283-289 对 serverTime >= _nextStepTime 的鱼重算（ctor 清过的 0 是
	// 陈值）：成熟 → INF、幼鱼 → p+cycle[0]；_output>0 的成熟鱼不触发请求位
	public function test_growLoop_recalculates_stale_nextStepTime() {
		var mature = matureClown(5, 15, 15, []); // _output 15>0：不碰请求位
		var young = youngClown(6);
		model._fishes = [mature, young];
		model.growLoop();
		Assert.isTrue(mature._nextStepTime == Math.POSITIVE_INFINITY);
		Assert.equals(20600, young._nextStepTime);
		Assert.equals(-1, model._requestOutput);
	}

	// :277-279 无鱼/空数组早退（不触 Session/请求）
	public function test_growLoop_null_and_empty_noop() {
		model.growLoop(); // _fishes null
		model._fishes = [];
		model.growLoop();
		Assert.equals(-1, model._requestOutput);
	}

	// VO null：请求位不动（:316-319）；i 不匹配：复位 -1 且不派发（:321-324）
	public function test_onGetOutput_null_and_mismatch() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var fish = matureClown(5, 0, 0);
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_FISHES, {ownerId: 1}, [fish]));
		model.growLoop();
		Assert.equals(5, model._requestOutput);

		model.onGetOutput(voEvent(CommandDefs.CMD_FISH_OUTPUT, {index: 5, ownerId: 1}, null));
		Assert.equals(5, model._requestOutput); // null 早退

		model.onGetOutput(voEvent(CommandDefs.CMD_FISH_OUTPUT, {index: 5, ownerId: 1},
			{i: 6, l: 15, o: 15}));
		Assert.equals(-1, model._requestOutput); // i 不匹配
		Assert.equals(0, countType(log, WaterModel.EVENT_FISH_CHANGED));
	}

	// ---------- :227-249 cgi_fish_plant 应答 ----------

	// exp 在：先 EVENT_LEVELUP（:235-239）再 EVENT_FISH_PLANTED（:247）；
	// _fishes 为 null 时建数组并推入（:242-246）；新鱼 calcNextStepTime
	// （:241）；无 exp：只派发 PLANTED
	public function test_onGrowFish_appends_and_dispatches_planted() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model.grow(2); // pending true
		var payload = {code: 1, exp: 42, fid: 2, i: 7, o: 0, p: -1000};
		model.onGrowFish(voEvent(CommandDefs.CMD_GROW_FISH, {fid: 2}, payload));
		Assert.isFalse(model._requestPending); // :229
		Assert.equals(2, log.length);
		Assert.equals(WaterModel.EVENT_LEVELUP, Reflect.field(log[0], "type"));
		Assert.equals(payload, Reflect.field(log[0], "data")); // 原载荷
		Assert.equals(WaterModel.EVENT_FISH_PLANTED, Reflect.field(log[1], "type"));
		Assert.equals(1, model.poolFishes.length);
		var f:PoolFish = model.poolFishes[0];
		Assert.equals(7, f._id); // payload.i
		Assert.equals(2, f._type); // payload.fid
		Assert.equals(20600, f._nextStepTime); // :241（p=-1000 + cycle[0]）

		var log2:Array<Dynamic> = [];
		var m2 = freshModel();
		listenModel(m2, log2);
		m2.onGrowFish(voEvent(CommandDefs.CMD_GROW_FISH, {fid: 2},
			{code: 1, fid: 2, i: 8, o: 0, p: -1000}));
		Assert.equals(1, log2.length); // 无 exp：LEVELUP 不派发
		Assert.equals(WaterModel.EVENT_FISH_PLANTED, Reflect.field(log2[0], "type"));
		Assert.equals(8, (m2.poolFishes[0]:PoolFish)._id);
	}

	// ---------- :70-75 onWaterOpened ----------

	// cgi_fish_register 应答：开塘 + EVENT_WATER_OPENED(null)
	public function test_onWaterOpened() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model.onWaterOpened(new CommandEvent(CommandEvent.COMPLETE));
		Assert.isTrue(model.opened); // :72
		Assert.equals(1, countType(log, WaterModel.EVENT_WATER_OPENED));
		Assert.isNull(lastData(log, WaterModel.EVENT_WATER_OPENED)); // :73 data null
	}

	// ---------- :453-542 onNetError 派发表 ----------

	// CMD_GET_FISHES：payload.open==0 → 关塘 + EVENT_DATA_LOADED(null)
	// （:469-477）；open!=0 无派发
	public function test_onNetError_getfishes_open_gate() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model.opened = true;
		model.onNetError(voEvent(CommandDefs.CMD_GET_FISHES, {ownerId: 1}, {open: 0}));
		Assert.isFalse(model.opened);
		Assert.equals(1, countType(log, WaterModel.EVENT_DATA_LOADED));
		Assert.isNull(lastData(log, WaterModel.EVENT_DATA_LOADED));

		var log2:Array<Dynamic> = [];
		var m2 = freshModel();
		listenModel(m2, log2);
		m2.opened = true;
		m2.onNetError(voEvent(CommandDefs.CMD_GET_FISHES, {ownerId: 1}, {open: 1}));
		Assert.isTrue(m2.opened);
		Assert.equals(0, log2.length);
	}

	// CMD_FISH_OUTPUT：错误路径把该 index 的记账置 2 并复位请求位（:478-484）
	// ——随后 growLoop 不再对该鱼发（封顶行为化验证）
	public function test_onNetError_output_pins_record() {
		var fish = matureClown(5, 0, 0);
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_FISHES, {ownerId: 1}, [fish]));
		model.growLoop();
		Assert.equals(5, model._requestOutput);
		model.onNetError(voEvent(CommandDefs.CMD_FISH_OUTPUT, {index: 5, ownerId: 1}, {code: 0}));
		Assert.equals(-1, model._requestOutput); // :482
		model.growLoop();
		Assert.equals(-1, model._requestOutput); // record 已 2：封顶
	}

	// CMD_WATER_OPEN：direction 空串/null 落缺省文案「服务器错误.」
	// （:485-493）
	public function test_onNetError_wateropen_default_direction() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model.onNetError(voEvent(CommandDefs.CMD_WATER_OPEN, {yellow: 0},
			{direction: "请先开通黄钻", code: 0}));
		Assert.equals(1, countType(log, WaterModel.EVENT_WATER_OPENED));
		Assert.equals("请先开通黄钻", lastData(log, WaterModel.EVENT_WATER_OPENED));

		var log2:Array<Dynamic> = [];
		var m2 = freshModel();
		listenModel(m2, log2);
		m2.onNetError(voEvent(CommandDefs.CMD_WATER_OPEN, {yellow: 0}, {code: 0}));
		Assert.equals("服务器错误.", lastData(log2, WaterModel.EVENT_WATER_OPENED)); // 缺 direction

		var log3:Array<Dynamic> = [];
		var m3 = freshModel();
		listenModel(m3, log3);
		m3.onNetError(voEvent(CommandDefs.CMD_WATER_OPEN, {yellow: 0}, {direction: ""}));
		Assert.equals("服务器错误.", lastData(log3, WaterModel.EVENT_WATER_OPENED)); // 空串
	}

	// CMD_STEAL_FISH：direction → EVENT_ERROR_MSG{id,msg}；l/o 都在 → 回写
	// 鱼 + EVENT_FISH_CHANGED；两者可同发（:495-515）
	public function test_onNetError_steal_direction_and_status() {
		becomeGuest();
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var fish = matureClown(5, 15, 15, []);
		model._fishes = [fish];
		model.onNetError(voEvent(CommandDefs.CMD_STEAL_FISH, {index: 5, flag: 1, ownerId: 1},
			{direction: "这条鱼已经被你捞过了", code: 0}));
		Assert.equals(1, countType(log, WaterModel.EVENT_ERROR_MSG));
		var d = lastData(log, WaterModel.EVENT_ERROR_MSG);
		Assert.equals(5, Reflect.field(d, "id")); // body.__body.index
		Assert.equals("这条鱼已经被你捞过了", Reflect.field(d, "msg"));

		var log2:Array<Dynamic> = [];
		var m2 = freshModel();
		listenModel(m2, log2);
		var fish2 = matureClown(5, 15, 15, []);
		m2._fishes = [fish2];
		m2.onNetError(voEvent(CommandDefs.CMD_STEAL_FISH, {index: 5, flag: 1, ownerId: 1},
			{l: 9, o: 15}));
		Assert.equals(0, countType(log2, WaterModel.EVENT_ERROR_MSG));
		Assert.equals(1, countType(log2, WaterModel.EVENT_FISH_CHANGED));
		Assert.equals(9, fish2._left); // :510-512
		Assert.equals(15, fish2._output);

		var log3:Array<Dynamic> = [];
		var m3 = freshModel();
		listenModel(m3, log3);
		var fish3 = matureClown(5, 15, 15, []);
		m3._fishes = [fish3];
		m3.onNetError(voEvent(CommandDefs.CMD_STEAL_FISH, {index: 5, flag: 1, ownerId: 1},
			{direction: "x", l: 9, o: 15}));
		Assert.equals(1, countType(log3, WaterModel.EVENT_ERROR_MSG));
		Assert.equals(1, countType(log3, WaterModel.EVENT_FISH_CHANGED)); // 双路同发
	}

	// CMD_HARVEST_FISH/CMD_FEED_FISH：direction → EVENT_ERROR_MSG（feed 无
	// direction 门直接读，:517-537）；CMD_GROW_FISH 不派发（:538-541）；
	// null 事件早退（:457-459）
	public function test_onNetError_msg_cmds_and_null_event() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model.onNetError(voEvent(CommandDefs.CMD_HARVEST_FISH, {index: 5, flag: 1},
			{direction: "还没有成熟"}));
		Assert.equals(1, countType(log, WaterModel.EVENT_ERROR_MSG));
		var d = lastData(log, WaterModel.EVENT_ERROR_MSG);
		Assert.equals(5, Reflect.field(d, "id"));
		Assert.equals("还没有成熟", Reflect.field(d, "msg"));

		var log2:Array<Dynamic> = [];
		var m2 = freshModel();
		listenModel(m2, log2);
		m2.onNetError(voEvent(CommandDefs.CMD_FEED_FISH, {index: 5, tid: 42},
			{direction: "鱼食不够"}));
		Assert.equals(1, countType(log2, WaterModel.EVENT_ERROR_MSG));
		Assert.equals("鱼食不够", Reflect.field(lastData(log2, WaterModel.EVENT_ERROR_MSG), "msg"));

		var log3:Array<Dynamic> = [];
		var m3 = freshModel();
		listenModel(m3, log3);
		m3.onNetError(voEvent(CommandDefs.CMD_GROW_FISH, {fid: 2}, {direction: "x"}));
		Assert.equals(0, log3.length); // :538-541 只记错误事件

		model.onNetError(null); // :457-459 不抛
	}
}

// Settings.getFishByID 的配置表注入（getData 按表名直取；PoolFishTest/
// ShopModelTest 同款，IModel 含 INotifier 三方法）
private class FakeConfigModel implements com.qzone.qfa.interfaces.IModel {
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
