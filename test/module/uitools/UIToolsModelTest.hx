package module.uitools;

import common.Session;
import entities.Player;
import events.CommonEvent;
import module.uitools.vo.OfflineData;
import utest.Assert;

/**
 * UIToolsModel 纯逻辑（issue #9）：工具区数据层——host 档案/账户 diff 派发
 * （金币/经验面板数字与 AddMoney/AddExp 飘字的数据源）、离线计数 diff、
 * 升级礼物合并去重、礼物加载的门位。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/module/uitools/UIToolsModel.as
 * （ctor :72-86、updateOfflineStatus :94-124、updateHostInfo :253-301、
 * resetLoadingFlags :302-320、addLevelUp :342-378、loadEveryDayGift :379-393、
 * drawLevelUpGift :454-471、initializeMyProfile :472-487、clearUnReadMsgFlag
 * :507-513）；字段/默认值见同目录 vo/OfflineData.as、vo/ProfileData.as。
 *
 * 网络路径不进测试：loadEveryDayGift/drawLevelUpGift 的 NetHelper.sendRequest
 * 在 NetHelper.theApp == null 时直接 return（#7 已译，FarmLandModelTest 同
 * 口径），单测进程不跑 Main、theApp 恒 null，只断言本地状态。Session 全局
 * 单例，每个用例自行钉 host。
 */
@:access(module.uitools.UIToolsModel)
class UIToolsModelTest {
	public function new() {}

	function pinHost(uId:UInt, userName:String, headPic:String, money:Float, exp:Int, fb:Int, moralExp:Int):Void {
		var host = new Player({});
		host._uId = uId;
		host._userName = userName;
		host._headPic = headPic;
		host._money = money;
		host._exp = exp;
		host._fb = fb;
		host._moralExp = moralExp;
		var s = Session.getInstance();
		s.currentUser = host;
		s.host = host;
	}

	function makeModel():UIToolsModel {
		return new UIToolsModel(null);
	}

	// :259-292 baseinfo（用户名/头像）先、account（金币/经验/fb/道德）后，
	// 各自只在 diff 时派发
	public function test_updateHostInfo_copies_host_fields_and_dispatches_baseinfo_then_account() {
		pinHost(1, "admin", "http://qzlogo/1", 123.5, 40, 2, 7);
		var model = makeModel();
		var log:Array<String> = [];
		model.addEventListener(UIToolsModel.EVENT_PLAYER_BASEINFO_CHANGED, function(e) log.push("base"));
		model.addEventListener(UIToolsModel.EVENT_PLAYER_ACCOUNT_CHANGED, function(e) log.push("account"));

		model.updateHostInfo();

		Assert.equals(2, log.length);
		Assert.equals("base", log[0]); // :268-270
		Assert.equals("account", log[1]); // :300-302
		Assert.equals("admin", model.myProfile.m_userName); // :259-263
		Assert.equals("http://qzlogo/1", model.myProfile.m_photoUrl); // :264-268
		Assert.equals(123.5, model.myProfile.m_gold); // :273-277
		Assert.equals(40, model.myProfile.m_exp); // :278-282
		Assert.equals(2, model.myProfile.m_fb); // :283-287
		Assert.equals(7, model.myProfile.m_moral); // :288-292
	}

	// 第二次全同调用：两段 diff 都不成立 → 零派发（面板/飘字不闪）
	public function test_updateHostInfo_is_silent_when_nothing_changed() {
		pinHost(1, "admin", "http://qzlogo/1", 123.5, 40, 2, 7);
		var model = makeModel();
		model.updateHostInfo();
		var count = 0;
		model.addEventListener(UIToolsModel.EVENT_PLAYER_BASEINFO_CHANGED, function(e) count++);
		model.addEventListener(UIToolsModel.EVENT_PLAYER_ACCOUNT_CHANGED, function(e) count++);

		model.updateHostInfo();

		Assert.equals(0, count);
	}

	// 只动 _money：baseinfo 静默，account 恰好一次，档案同步新值
	public function test_updateHostInfo_account_only_change_fires_only_account_event() {
		pinHost(1, "admin", "http://qzlogo/1", 123.5, 40, 2, 7);
		var model = makeModel();
		model.updateHostInfo();
		Session.getInstance().host._money = 200;
		var log:Array<String> = [];
		model.addEventListener(UIToolsModel.EVENT_PLAYER_BASEINFO_CHANGED, function(e) log.push("base"));
		model.addEventListener(UIToolsModel.EVENT_PLAYER_ACCOUNT_CHANGED, function(e) log.push("account"));

		model.updateHostInfo();

		Assert.equals(1, log.length);
		Assert.equals("account", log[0]);
		Assert.equals(200.0, model.myProfile.m_gold);
	}

	// :255-257 host 为 null：直接返回，零派发零写入
	public function test_updateHostInfo_returns_without_host() {
		Session.getInstance().host = null;
		var model = makeModel();
		var count = 0;
		model.addEventListener(UIToolsModel.EVENT_PLAYER_BASEINFO_CHANGED, function(e) count++);
		model.addEventListener(UIToolsModel.EVENT_PLAYER_ACCOUNT_CHANGED, function(e) count++);

		model.updateHostInfo();

		Assert.equals(0, count);
		Assert.equals("", model.myProfile.m_userName); // 档案未被触碰
	}

	// :472-487：无条件拷贝（无 diff 门）且两事件必派发——注意 :472-487 没有
	// m_fb 行（对比 updateHostInfo :283-287），fb 不经 initializeMyProfile 进档案
	public function test_initializeMyProfile_copies_all_but_fb_and_dispatches_both() {
		pinHost(1, "admin", "http://qzlogo/1", 123.5, 40, 2, 7);
		var model = makeModel();
		var log:Array<String> = [];
		model.addEventListener(UIToolsModel.EVENT_PLAYER_BASEINFO_CHANGED, function(e) log.push("base"));
		model.addEventListener(UIToolsModel.EVENT_PLAYER_ACCOUNT_CHANGED, function(e) log.push("account"));

		model.initializeMyProfile();

		Assert.equals(2, log.length);
		Assert.equals("base", log[0]); // :481
		Assert.equals("account", log[1]); // :486
		Assert.equals("admin", model.myProfile.m_userName); // :477
		Assert.equals("http://qzlogo/1", model.myProfile.m_photoUrl); // :478
		Assert.equals(40, model.myProfile.m_exp); // :482
		Assert.equals(123.5, model.myProfile.m_gold); // :483
		Assert.equals(7, model.myProfile.m_moral); // :484
		Assert.equals(0, model.myProfile.m_fb); // 无 m_fb 行 → 保持 VO 默认 0
	}

	// :94-124：b/c/d/e → 帖子/私信/礼物/鲜花，变化才派发；载荷是 OfflineData
	// 实例本身（CommonEvent.data）
	public function test_updateOfflineStatus_diffs_and_dispatches_with_offline_data() {
		var model = makeModel();
		var events:Array<CommonEvent> = [];
		model.addEventListener(UIToolsModel.EVENT_OFFLINE_DATA_CHANGED, function(e) events.push(cast e));

		model.updateOfflineStatus({b: 2, c: 1, d: 5, e: 4});

		Assert.equals(1, events.length);
		var od = cast(events[0].data, OfflineData);
		Assert.equals(2, od.m_postNum); // :98-101 "b"
		Assert.equals(1, od.m_msgNum); // :102-105 "c"
		Assert.equals(5, od.m_giftNum); // :106-109 "d"
		Assert.equals(4, od.m_flowerNum); // :110-113 "e"

		model.updateOfflineStatus({b: 2, c: 1, d: 5, e: 4}); // 全同 → 不派发
		Assert.equals(1, events.length); // :98 的 != diff 门

		model.updateOfflineStatus(null); // null → 不派发
		Assert.equals(1, events.length); // :97 的 null 门
	}

	// 键缺位：AS3 里 0 != undefined 成立 → 视为变化派发，undefined as int → 0
	public function test_updateOfflineStatus_missing_keys_count_as_change() {
		var model = makeModel();
		var events:Array<CommonEvent> = [];
		model.addEventListener(UIToolsModel.EVENT_OFFLINE_DATA_CHANGED, function(e) events.push(cast e));

		model.updateOfflineStatus({});

		Assert.equals(1, events.length); // :98 m_postNum(0) != undefined
		var od = cast(events[0].data, OfflineData);
		Assert.equals(0, od.m_postNum); // :100 "b" as int → 0
		Assert.equals(0, od.m_msgNum);
		Assert.equals(0, od.m_giftNum);
		Assert.equals(0, od.m_flowerNum);
	}

	// :507-513：info/msg 清零并派发；帖子计数不受影响
	public function test_clearUnReadMsgFlag_zeroes_info_and_msg_and_dispatches() {
		var model = makeModel();
		model.updateOfflineStatus({b: 3, c: 4, d: 5, e: 6});
		model.m_offlineData.m_infoNum = 9;
		var events:Array<CommonEvent> = [];
		model.addEventListener(UIToolsModel.EVENT_OFFLINE_DATA_CHANGED, function(e) events.push(cast e));

		model.clearUnReadMsgFlag();

		Assert.equals(1, events.length);
		Assert.equals(0, model.m_offlineData.m_infoNum); // :508
		Assert.equals(0, model.m_offlineData.m_msgNum); // :509
		Assert.equals(3, model.m_offlineData.m_postNum); // 不在清除之列
	}

	// :342-378：null 早退；hasgift+lvup → 空表直挂/非空合并去重；Array 载荷
	// 整表替换；{hasgift:true} 无 lvup → 早退不派发；无 hasgift（如 {hasgift:false}
	// 或 Array 之外的其它对象）→ 仍派发当前表
	public function test_addLevelUp_merges_dedupes_and_replaces_levelup_gifts() {
		var model = makeModel();
		var count = 0;
		model.addEventListener(UIToolsModel.EVENT_LEVELUP_CHANGED, function(e) count++);

		model.addLevelUp(null);
		Assert.equals(0, count); // :344-346
		Assert.isNull(model.m_levelupGifts);

		model.addLevelUp({hasgift: true, lvup: [1, 2]}); // :352-355 空表直挂
		Assert.equals(1, count);
		Assert.equals(1, model.m_levelupGifts[0]);
		Assert.equals(2, model.m_levelupGifts[1]);
		Assert.equals(2, model.m_levelupGifts.length);

		model.addLevelUp({hasgift: true, lvup: [2, 3]}); // :356-366 合并去重
		Assert.equals(2, count);
		Assert.equals(3, model.m_levelupGifts.length);
		Assert.equals(3, model.m_levelupGifts[2]);

		model.addLevelUp([5, 6]); // :368-371 Array 载荷整表替换
		Assert.equals(3, count);
		Assert.equals(2, model.m_levelupGifts.length);
		Assert.equals(5, model.m_levelupGifts[0]);
		Assert.equals(6, model.m_levelupGifts[1]);

		model.addLevelUp({hasgift: false}); // :376 无条件派发当前表
		Assert.equals(4, count);
		Assert.equals(2, model.m_levelupGifts.length);

		model.addLevelUp({hasgift: true}); // :348-350 lvup 缺位 → 早退
		Assert.equals(4, count);
		Assert.equals(2, model.m_levelupGifts.length);
	}

	// :302-320：清加载位并作废对应缓存
	public function test_resetLoadingFlags_clears_flags_and_cached_data() {
		var model = makeModel();
		model.m_postMsgLoading = true;
		model.m_postMsg = {a: 1};
		model.m_giftDataLoading = true;
		model.m_giftData = {b: 2};
		model.m_freeDataLoading = true;
		model.m_freeData = {c: 3};

		model.resetLoadingFlags();

		Assert.isFalse(model.m_postMsgLoading); // :303-307
		Assert.isNull(model.m_postMsg);
		Assert.isFalse(model.m_giftDataLoading); // :308-312
		Assert.isNull(model.m_giftData);
		Assert.isFalse(model.m_freeDataLoading); // :313-317
		Assert.isNull(model.m_freeData);
	}

	// :379-393：缓存命中返回原引用；在途返回 null；首次发起置在途位
	//（sendRequest 对 null theApp 是 no-op）
	public function test_loadEveryDayGift_cache_hit_loading_gate_and_request_flip() {
		var model = makeModel();
		model.m_giftData = {cached: true};
		Assert.equals(model.m_giftData, model.loadEveryDayGift()); // :381-384

		var loading = makeModel();
		loading.m_giftDataLoading = true;
		Assert.isNull(loading.loadEveryDayGift()); // :385-388

		var fresh = makeModel();
		Assert.isNull(fresh.loadEveryDayGift()); // 发起侧恒 null
		Assert.isTrue(fresh.m_giftDataLoading); // :389-390
	}

	// :454-471：在途 → false；空表也发起（:459 的 `== null && length == 0`
	// 对 [] 不成立）；发起置 pending；lv 取表头
	public function test_drawLevelUpGift_pending_gate_and_request_flip() {
		var model = makeModel();
		model.m_levelupGiftPending = true;
		Assert.isFalse(model.drawLevelUpGift()); // :456-458

		var empty = makeModel();
		empty.m_levelupGifts = [];
		Assert.isTrue(empty.drawLevelUpGift()); // [] 非-null → 过门
		Assert.isTrue(empty.m_levelupGiftPending); // :464
		Assert.isFalse(empty.drawLevelUpGift()); // 二连被在途门挡下

		var filled = makeModel();
		filled.m_levelupGifts = [3, 4];
		Assert.isTrue(filled.drawLevelUpGift()); // :465-470 发请求
		Assert.isTrue(filled.m_levelupGiftPending);
	}
}
