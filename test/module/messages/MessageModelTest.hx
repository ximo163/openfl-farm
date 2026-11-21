package module.messages;

import com.qzone.qfa.events.CommandEvent;
import common.Settings;
import common.Session;
import common.misc.Utils;
import entities.Player;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.vo.ServiceResultVO;
import openfl.events.Event;
import utest.Assert;

/**
 * MessageModel 纯逻辑（issue #19）：消息模块数据层——个人信息窗六页签
 * （消息/留言/成果/成鱼/消费/系统）的数据装载门位、chat&act=getAllInfo
 * 按 flag 的应答分派、hydra feeds 日志、sysmsg 系统公告、双源消费流水
 * 合并排序、留言列表的收发/清空。
 *
 * 「已读状态」说明：isread 的落库是服务端副作用（chat_getallinfo 按
 * flag 2/3/16 标 nclogs、4/5 标 message，见 protocol.json 该条 notes），
 * 客户端侧对应物是这里被钉住的两组行为——m_flags 旗标表（决定请求带
 * 哪个 flag）与 loadData 的已缓存早退门（已读过的页不再发请求、不再
 * 触发服务端标记），reset 后重新放行。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/module/messages/MessageModel.as
 *   （常量 :17-25、sendChat :44-56、onLogCleared :63-71、reloadAll :73-80、
 *   onDataLoaded :87-209、loadFeeds :211-230、onChatCleared :247-259、
 *   reset :261-266、me :268-271、onChatMsgSent :278-291、loadData :293-398、
 *   currentPlayer :400-410、onLoadFeeds :425-449、onNetError :451-478）
 * - spec/protocol.json entries.nc.mods：
 *   chat_getallinfo（flag 语义 2=只要 log；3/16=只要 user；4=只要 chat；
 *   5=user+chat；8=只要 repertory；其他=user+log+chat+repertory。
 *   chat_getallinfo.php:9; :95-115；isread 副作用 :98,:102,:106,:110）、
 *   chat_sendchat（chat 数组回显 :9-21）、chat_clearchat（code 恒 1，:7）、
 *   hydra_feeds_select（ecode 恒 0、data 条目 cn/domain/t/opuin/triples，
 *   :10,58,60,62）、sysmsg_select（ret 恒 0/info "succ"/data 空数组，:4）、
 *   cgi_farm_exchange（cost 元素 {msg:string, time:int}，:5,25-31）、
 *   fcg_ws_get_costfeeds（恒空 cost，:5）
 * - cmd→mod 映射：framework/net/ServerServices.hx m_cmdMap（45→chat&
 *   act=getAllInfo、46→cgi_farm_exchange、51→fcg_ws_get_costfeeds、
 *   53→sysmsg_select、54→hydra_feeds_select、210→cgi_fish_getall）
 * - 页签序：MessageView.as:121-141 addTab 顺序（消息/留言/成果/成鱼/消费/
 *   系统）与 onTabSwitched :319-323 loadData(selectedIndex)
 *
 * 网络路径不进测试：NetHelper.sendRequest 在 theApp == null 时 no-op
 * （#7 已译，UIToolsModelTest/LevelUpModelTest 同口径），单测进程不跑
 * Main、theApp 恒 null——sendChat/clearChat/clearAllLog/loadFeeds 的请求
 * 参数拼装因此不可观测，不设测试；应答侧直接喂构造好的 CommandEvent
 * （body 用 Utils.buildRequest 造出与真实链路同构的 {cmdID,__body,…}，
 * result 为 ServiceResultVO，走 NetHelper.getVOData 的 m_extra 分支）。
 * EventRecorder 已按 deviations（no-qq-telemetry）DISABLED，onNetError
 * 的上报分支无观测。多键 for-in 的派发顺序 AS3/eval 均无保证，一律按
 * 集合断言不按序断言。
 */
@:access(module.messages.MessageModel)
class MessageModelTest {
	public function new() {}

	var model:MessageModel;

	var savedHost:Player;
	var savedCurrentUser:Player;

	public function setup() {
		model = new MessageModel();
		var host = new Player({});
		host._uId = 1;
		host._userName = "admin";
		host._uinLogin = 88888888;
		var currentUser = new Player({});
		currentUser._uId = 1;
		var s = Session.getInstance();
		savedHost = s.host;
		savedCurrentUser = s.currentUser;
		s.host = host;
		s.currentUser = currentUser;
		// mode 复位 ""（flag==3/默认分支的 xystr 拷贝门 :151/:199 读它）
		Settings.getInstance().loadLocalSettings(null);
	}

	public function teardown() {
		var s = Session.getInstance();
		s.host = savedHost;
		s.currentUser = savedCurrentUser;
		Settings.getInstance().loadLocalSettings(null);
	}

	// :17-23 事件名 + :25 旗标表。m_flags 与 getAllInfo 的 flag 语义一一对账：
	// 页签 0 消息→2（只要 log）、1 留言→4（只要 chat）、2 成果→8（只要
	// repertory）；user 未装载时 +1 → 3（只要 user）/5（user+chat）/9（默认
	// user+log+chat+repertory）。服务端按 flag 顺带标已读（protocol.json
	// chat_getallinfo notes），客户端选对 flag 即选对了标记范围。
	public function test_event_constants_and_flag_table_matches_getallinfo_flag_semantics() {
		Assert.equals("DataChanged", MessageModel.EVENT_DATA_CHANGED); // :17
		Assert.equals("DataLoading", MessageModel.EVENT_DATA_LOADING); // :19
		Assert.equals("DataFailed", MessageModel.EVENT_DATA_FAILED); // :21
		Assert.equals("LogCleared", MessageModel.EVENT_LOG_CLEARED); // :23
		Assert.same([2, 4, 8], model.m_flags); // :25
	}

	// :293-336 页签 0/1/2：未缓存先派 DataLoading(true)（:327，请求侧
	// theApp==null no-op）；对应键已缓存则 :298-308 早退不再派发
	public function test_loadData_log_chat_repertory_cache_gates_and_loading_dispatch() {
		var log:Array<Dynamic> = [];
		listen(model, log);

		model.loadData(0);
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_LOADING));
		Assert.isTrue(firstData(log, MessageModel.EVENT_DATA_LOADING) == true); // :78/:327 data 恒 true

		model.m_data = {log: []}; // 已读过的页
		model.loadData(0);
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_LOADING)); // :298-301 早退
		model.m_data = {chat: []};
		model.loadData(1);
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_LOADING)); // :302-305
		model.m_data = {repertory: []};
		model.loadData(2);
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_LOADING)); // :306-309

		// 门按页签独立：log 已缓存不挡 chat 页
		model.m_data = {log: []};
		model.loadData(1);
		Assert.equals(2, countType(log, MessageModel.EVENT_DATA_LOADING));
	}

	// :337-397 页签 3/4/5 与越界：fish/cost/systemMsg 各自的门；cost 发起
	// 时双源位复位（:362-363）；页签 5 在 user 未装载时不派 DataLoading
	//（:368-381 无 dispatchEvent）、systemMsg 已缓存则 :384-387 早退
	public function test_loadData_fish_cost_systemmsg_gates() {
		var log:Array<Dynamic> = [];
		listen(model, log);

		model.loadData(3);
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_LOADING)); // :352
		model.m_data = {fish: []};
		model.loadData(3);
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_LOADING)); // :339-342

		model.m_costNM = true;
		model.m_costWS = true;
		model.m_data = {};
		model.loadData(4);
		Assert.equals(2, countType(log, MessageModel.EVENT_DATA_LOADING)); // :361
		Assert.isFalse(model.m_costNM == true); // :362 复位
		Assert.isFalse(model.m_costWS == true); // :363 复位
		model.m_data = {cost: []};
		model.loadData(4);
		Assert.equals(2, countType(log, MessageModel.EVENT_DATA_LOADING)); // :356-360

		var five = makeModel();
		var log5:Array<Dynamic> = [];
		listen(five, log5);
		five.m_data = {};
		five.loadData(5);
		Assert.equals(0, log5.length); // :368-381 只发请求，无任何派发
		five.m_data = {user: {uName: "admin"}};
		five.loadData(5);
		Assert.equals(1, countType(log5, MessageModel.EVENT_DATA_LOADING)); // :388
		five.m_data = {user: {uName: "admin"}, systemMsg: []};
		five.loadData(5);
		Assert.equals(1, countType(log5, MessageModel.EVENT_DATA_LOADING)); // :384-387

		var outside = makeModel();
		var logO:Array<Dynamic> = [];
		listen(outside, logO);
		outside.loadData(6);
		outside.loadData(-1);
		Assert.equals(0, logO.length); // 0-5 之外全不匹配
	}

	// :73-80 reloadAll：派 DataLoading(true)；请求 flag=16（只要 user，
	// protocol.json chat_getallinfo flag 语义）在 theApp==null 下 no-op
	public function test_reloadAll_dispatches_loading() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		model.reloadAll();
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_LOADING));
		Assert.isTrue(firstData(log, MessageModel.EVENT_DATA_LOADING) == true);
	}

	// :100-107 cgi_farm_exchange 应答：存 cost、置 NM 位、不派发
	//（DataChanged 只在双源齐后的 WS 分支）
	public function test_onDataLoaded_bill_data_stores_cost_sets_nm_flag_no_dispatch() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		var cost = [{msg: "卖出了仓库里已收获的3个草莓。", time: 1416000001}];
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_BILL_DATA, {uIdx: 1}, {code: 1, cost: cost}));

		Assert.isTrue(model.m_costNM); // :102
		Assert.equals(1, (Reflect.field(model.m_data, "cost"):Array<Dynamic>).length); // :105
		Assert.equals("卖出了仓库里已收获的3个草莓。",
			Reflect.field((Reflect.field(model.m_data, "cost"):Array<Dynamic>)[0], "msg"));
		Assert.equals(1416000001,
			Reflect.field((Reflect.field(model.m_data, "cost"):Array<Dynamic>)[0], "time"));
		Assert.equals(0, countType(log, MessageModel.EVENT_DATA_CHANGED));
	}

	// :108-118 fcg_ws_get_costfeeds 应答单独到达：m_data 无 cost → 整表
	// 替换（:111-114）；NM 位未置 → 双源条件不成立，不派发
	public function test_onDataLoaded_bill_ws_alone_stores_cost_without_dispatch() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		var cost = [];
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_BILL_WS_DATA, {uin: 88888888}, {code: 1, cost: cost}));

		Assert.isTrue(model.m_costWS); // :110
		Assert.isTrue(Reflect.hasField(model.m_data, "cost")); // :113
		Assert.isFalse(model.m_costNM == true);
		Assert.equals(0, countType(log, MessageModel.EVENT_DATA_CHANGED)); // :119 双源门
	}

	// :100-129 双源齐：NM 后到 WS → concat 合并、按 time 降序 sortOn、
	// 恰一次 DataChanged{index:"cost"}，载荷 data 就是模型数据本体。
	// time 取等宽 10 位时间戳（cgi_farm_exchange.php:26,28 真实形态），
	// 字符串序与数值序一致，不钉 AVM2 sortOn 的比较细节
	public function test_onDataLoaded_bill_ws_merges_sorts_desc_and_dispatches_when_both_sources() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_BILL_DATA, {uIdx: 1}, {
			cost: [
				{msg: "nm-1", time: 1416000001},
				{msg: "nm-3", time: 1416000003}
			]
		}));
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_BILL_WS_DATA, {uin: 88888888}, {
			cost: [{msg: "ws-2", time: 1416000002}]
		}));

		Assert.isTrue(model.m_costNM);
		Assert.isTrue(model.m_costWS);
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_CHANGED)); // :125-128
		var changed = firstData(log, MessageModel.EVENT_DATA_CHANGED);
		Assert.equals("cost", Reflect.field(changed, "index"));
		var viaPayload:Array<Dynamic> = Reflect.field(Reflect.field(changed, "data"), "cost");
		var merged:Array<Dynamic> = Reflect.field(model.m_data, "cost");
		Assert.equals(3, merged.length); // concat 不去重（:117）
		Assert.equals(3, viaPayload.length); // 载荷 data 是模型数据本体
		Assert.equals(1416000003, Reflect.field(merged[0], "time")); // 降序
		Assert.equals(1416000002, Reflect.field(merged[1], "time"));
		Assert.equals(1416000001, Reflect.field(merged[2], "time"));
		Assert.equals("ws-2", Reflect.field(merged[1], "msg"));
	}

	// :132-143 sysmsg_select 应答：ret==0 才入 systemMsg；DataChanged
	//（index:"systemMsg"）无论 ret 都派发。真实下发 ret 恒 0
	//（sysmsg_select.php:4），ret!=1 分支是 :134 门的钉子
	public function test_onDataLoaded_systemMsg_ret_gate() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		var msgs = [{words: "系统公告", time: 1416000000}];
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_SYSTEM_MSG,
			{uin: "88888888", opuin: "88888888", appid: "353", msgnum: "300"},
			{ret: 0, info: "succ", data: msgs}));

		Assert.isTrue(Reflect.hasField(model.m_data, "systemMsg")); // :136
		Assert.equals(1, (Reflect.field(model.m_data, "systemMsg"):Array<Dynamic>).length);
		Assert.equals("系统公告",
			Reflect.field((Reflect.field(model.m_data, "systemMsg"):Array<Dynamic>)[0], "words"));
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_CHANGED));

		var retBad = makeModel();
		var log2:Array<Dynamic> = [];
		listen(retBad, log2);
		retBad.onDataLoaded(voEvent(CommandDefs.CMD_GET_SYSTEM_MSG, {}, {ret: 1, data: msgs}));
		Assert.isFalse(Reflect.hasField(retBad.m_data, "systemMsg")); // :134 门未过
		Assert.equals(1, countType(log2, MessageModel.EVENT_DATA_CHANGED)); // :138 派发在门外
	}

	// :144-158 flag==3（user 未装载时页签 0 的旗标）：逐键拷贝但跳过 log，
	// 零派发（本分支不 dispatch），随后转 loadFeeds（no-op）；user 带
	// xystr 且 mode=="" 时同步进 Session.currentUser
	public function test_onDataLoaded_profile_flag3_copies_all_but_log_no_dispatch() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_PROFILE_ALL_INFO,
			{uId: "1", ownerId: "1", flag: 3},
			{
				user: {uName: "admin", uId: 1, xystr: "XYZ"},
				log: [{domain: 1, msg: "日志", time: 1416000000}],
				chat: [{fromId: 2, fromName: "bob", toId: 1, toName: "admin", time: 1416000100, msg: " hi ", isReply: 0}]
			}));

		Assert.isTrue(Reflect.hasField(model.m_data, "user")); // :150
		Assert.isTrue(Reflect.hasField(model.m_data, "chat"));
		Assert.isFalse(Reflect.hasField(model.m_data, "log")); // :148 跳过
		Assert.equals(0, log.length); // 本分支无派发（reload 链由 loadFeeds 接续）
		Assert.equals("XYZ", Session.getInstance().currentUser.xystr); // :151-153

		// user 无 xystr → 不碰 Session（:151 hasOwnProperty 门）
		var noXy = makeModel();
		Session.getInstance().currentUser.xystr = null;
		noXy.onDataLoaded(voEvent(CommandDefs.CMD_GET_PROFILE_ALL_INFO, {flag: 3}, {user: {uName: "admin"}}));
		Assert.isTrue(Reflect.hasField(noXy.m_data, "user"));
		Assert.isNull(Session.getInstance().currentUser.xystr);
	}

	// :159-181 flag==1（页签 5 补 user）：逐键拷贝并按键派 DataChanged
	//（顺序无保证，按集合断言）；systemMsg 未缓存再补一发 DataLoading(true)
	public function test_onDataLoaded_profile_flag1_dispatches_each_key_then_sysmsg_request() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_PROFILE_ALL_INFO,
			{uId: "1", ownerId: "1", flag: 1},
			{user: {uName: "admin"}, chat: [{msg: "m1", isReply: 0}]}));

		Assert.equals(2, countType(log, MessageModel.EVENT_DATA_CHANGED)); // :163-167
		var indexes = changedIndexes(log);
		Assert.isTrue(indexes.indexOf("user") >= 0);
		Assert.isTrue(indexes.indexOf("chat") >= 0);
		Assert.isTrue(Reflect.hasField(model.m_data, "user"));
		Assert.isTrue(Reflect.hasField(model.m_data, "chat"));
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_LOADING)); // :173

		// systemMsg 已缓存 → :169-172 早退，不再派 DataLoading
		var cached = makeModel();
		var log2:Array<Dynamic> = [];
		listen(cached, log2);
		cached.m_data = {systemMsg: []};
		cached.onDataLoaded(voEvent(CommandDefs.CMD_GET_PROFILE_ALL_INFO, {flag: 1}, {user: {uName: "admin"}}));
		Assert.equals(1, countType(log2, MessageModel.EVENT_DATA_CHANGED));
		Assert.equals(0, countType(log2, MessageModel.EVENT_DATA_LOADING));
	}

	// :182-193 cgi_fish_getall 应答：repertory 是 Array 才入 fish；
	// DataChanged（index:"fish"）无论是否 Array 都派发
	public function test_onDataLoaded_fish_maps_repertory() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		var repertory = [{cId: 1, cName: "草莓", harvestNumber: 5, scroungeNumber: 2}];
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_FISH_ALL, {uId: "1", ownerId: "1"}, {repertory: repertory}));

		Assert.isTrue(Reflect.hasField(model.m_data, "fish")); // :186
		Assert.equals("草莓",
			Reflect.field((Reflect.field(model.m_data, "fish"):Array<Dynamic>)[0], "cName"));
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_CHANGED));
		Assert.equals("fish", changedIndexes(log)[0]);

		var notArray = makeModel();
		var log2:Array<Dynamic> = [];
		listen(notArray, log2);
		notArray.onDataLoaded(voEvent(CommandDefs.CMD_GET_FISH_ALL, {}, {}));
		Assert.isFalse(Reflect.hasField(notArray.m_data, "fish")); // :184 is Array 门
		Assert.equals(1, countType(log2, MessageModel.EVENT_DATA_CHANGED)); // :188 仍在门外
	}

	// :194-208 默认分支（flag 9 等，protocol.json：其他=user+log+chat+
	// repertory）：全键拷贝含 log、按键派发、xystr 同步
	public function test_onDataLoaded_default_branch_copies_everything_including_log() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		model.onDataLoaded(voEvent(CommandDefs.CMD_GET_PROFILE_ALL_INFO,
			{uId: "1", ownerId: "1", flag: 9},
			{
				user: {uName: "admin", xystr: "Q"},
				log: [{domain: 1, msg: "日志", time: 1416000000}],
				chat: [{msg: "hi", isReply: 0}],
				repertory: [{cId: 1, cName: "草莓", harvestNumber: 5, scroungeNumber: 2}]
			}));

		Assert.equals(4, countType(log, MessageModel.EVENT_DATA_CHANGED)); // :203-207
		var indexes = changedIndexes(log);
		for (key in ["user", "log", "chat", "repertory"]) {
			Assert.isTrue(indexes.indexOf(key) >= 0, "缺 " + key + " 的派发");
			Assert.isTrue(Reflect.hasField(model.m_data, key), "缺 " + key + " 的拷贝");
		}
		Assert.equals("Q", Session.getInstance().currentUser.xystr); // :199-201
	}

	// :94-98 应答 VO 为 null（getVOData null）直接 return：零状态零派发
	public function test_onDataLoaded_null_vo_is_silent() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.body = Utils.buildRequest(CommandDefs.CMD_GET_PROFILE_ALL_INFO, {flag: 3});
		ev.result = null;
		model.onDataLoaded(ev);
		Assert.equals(0, log.length);
		Assert.isTrue(model.m_data == null || Reflect.fields(model.m_data).length == 0);
	}

	// :278-291 chat_sendchat 应答：chat 列表整表替换 + 一次 DataChanged
	//（index:"chat"）；:247-259 chat_clearchat 应答 code==1 → chat 置空表
	// + 一次 DataChanged。code 恒 1（chat_clearchat.php:7），code!=1 与
	// null VO 是门钉子
	public function test_onChatMsgSent_and_onChatCleared_chat_list_updates() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		model.onChatMsgSent(voEvent(CommandDefs.CMD_SEND_CHAT, {toId: "1", msg: " hi "}, {
			code: 1,
			chat: [{fromId: 2, fromName: "bob", toId: 1, toName: "admin", time: 1416000100, msg: " hi ", isReply: 0}]
		}));
		Assert.equals(1, (Reflect.field(model.m_data, "chat"):Array<Dynamic>).length); // :285
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_CHANGED));
		Assert.equals("chat", changedIndexes(log)[0]);

		var cleared = makeModel();
		var log2:Array<Dynamic> = [];
		listen(cleared, log2);
		cleared.onChatCleared(voEvent(CommandDefs.CMD_CLEAR_ALL_CHAT, null, {code: 1}));
		Assert.equals(0, (Reflect.field(cleared.m_data, "chat"):Array<Dynamic>).length); // :252 空表
		Assert.equals(1, countType(log2, MessageModel.EVENT_DATA_CHANGED));

		var badCode = makeModel();
		badCode.onChatCleared(voEvent(CommandDefs.CMD_CLEAR_ALL_CHAT, null, {code: 0}));
		Assert.isFalse(Reflect.hasField(badCode.m_data, "chat")); // :250 code 门

		var nullVo = makeModel();
		nullVo.onChatCleared(new CommandEvent(CommandEvent.COMPLETE));
		Assert.isFalse(Reflect.hasField(nullVo.m_data, "chat")); // :250 null 门
	}

	// :63-71 hydra_feeds_delete 应答（code 恒 1）：log 置空表 + 一次
	// DataChanged（index:"log"）。注意派的是 EVENT_DATA_CHANGED——
	// EVENT_LOG_CLEARED 常量本类从未派发，照抄不修
	public function test_onLogCleared_empties_log_dispatches_DataChanged() {
		model.m_data = {log: [{domain: 1, msg: "日志", time: 1416000000}]};
		var log:Array<Dynamic> = [];
		listen(model, log);
		model.onLogCleared(voEvent(CommandDefs.CMD_CLEAR_ALL_FEEDS, {appid: 353, isfeeds: 1, uin: 88888888}, {code: 1}));

		Assert.equals(0, (Reflect.field(model.m_data, "log"):Array<Dynamic>).length); // :65
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_CHANGED));
		Assert.equals("log", changedIndexes(log)[0]); // :66-69
	}

	// :425-449 hydra_feeds_select 应答：ecode==0 → log=data，且对 m_data
	// 的每个键（含新写入的 log）各派一次 DataChanged；ecode!=0 且带
	// errmsg → DataFailed{error}，log 不落
	public function test_onLoadFeeds_sets_log_and_dispatches_every_loaded_key() {
		model.m_data = {user: {uName: "admin"}};
		var log:Array<Dynamic> = [];
		listen(model, log);
		model.onLoadFeeds(voEvent(CommandDefs.CMD_GET_FEEDS,
			{appid: 353, feedsnum: 50, isfeeds: 1, uin: 88888888, opuin: 88888888},
			{
				ecode: 0,
				data: [{cn: "<font color=\"#009900\"><b>bob</b></font> 来农场偷窃，偷走2个草莓。", domain: 1, t: 1416000000, opuin: 2, triples: []}]
			}));

		var feeds:Array<Dynamic> = Reflect.field(model.m_data, "log"); // :435
		Assert.equals(1, feeds.length);
		Assert.equals(2, Reflect.field(feeds[0], "opuin"));
		Assert.equals(1416000000, Reflect.field(feeds[0], "t"));
		Assert.equals(2, countType(log, MessageModel.EVENT_DATA_CHANGED)); // user + log
		var indexes = changedIndexes(log);
		Assert.isTrue(indexes.indexOf("log") >= 0);
		Assert.isTrue(indexes.indexOf("user") >= 0);

		var failed = makeModel();
		var log2:Array<Dynamic> = [];
		listen(failed, log2);
		failed.onLoadFeeds(voEvent(CommandDefs.CMD_GET_FEEDS, {}, {ecode: 1, errmsg: "服务器开小差了"}));
		Assert.isFalse(Reflect.hasField(failed.m_data, "log")); // :433 ecode 门
		Assert.equals(1, countType(log2, MessageModel.EVENT_DATA_FAILED)); // :447
		Assert.equals("服务器开小差了", Reflect.field(firstData(log2, MessageModel.EVENT_DATA_FAILED), "error"));

		var nullVo = makeModel();
		nullVo.onLoadFeeds(new CommandEvent(CommandEvent.COMPLETE));
		Assert.isFalse(Reflect.hasField(nullVo.m_data, "log")); // :429-431
	}

	// :451-478 网络失败：DataFailed 带重试链接文案（Language cn 表
	// “请求超时，”/“点击重试” 为恒等映射）；上报分支 DISABLED 无观测，
	// body 为 null 也在派发之后才判
	public function test_onNetError_dispatches_DataFailed_with_retry_link() {
		var log:Array<Dynamic> = [];
		listen(model, log);
		var ev = new CommandEvent(CommandEvent.ERROR);
		ev.body = null;
		model.onNetError(ev);

		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_FAILED));
		Assert.equals("请求超时，<a href=\'event:reload\'><u><font color=\'#ff6600\'>点击重试</font></u></a>",
			Reflect.field(firstData(log, MessageModel.EVENT_DATA_FAILED), "error")); // :453
	}

	// :261-266 reset：m_data 清空、双源位复位 → 已读门重新放行
	//（reset 后 loadData(0) 又会派 DataLoading）
	public function test_reset_clears_cache_flags_and_reopens_gates() {
		model.m_data = {log: [{msg: "x"}], user: {uName: "admin"}};
		model.m_costNM = true;
		model.m_costWS = true;
		var log:Array<Dynamic> = [];
		listen(model, log);

		model.reset();

		Assert.isFalse(Reflect.hasField(model.m_data, "log")); // :263
		Assert.isFalse(Reflect.hasField(model.m_data, "user"));
		Assert.isFalse(model.m_costNM == true); // :264（eval 未赋值 Bool 为 null，取「非 true」）
		Assert.isFalse(model.m_costWS == true); // :265

		model.loadData(0);
		Assert.equals(1, countType(log, MessageModel.EVENT_DATA_LOADING)); // 门已开
	}

	// :39 ctor 默认 m_me=true；:400-410 currentPlayer：null 或 me==true
	// 的玩家 → m_me=true，否则 false（到访他人农场时 loadData 改查
	// currentUser 的 uId）
	public function test_me_default_and_currentPlayer_setter() {
		Assert.isTrue(model.me); // :39

		var other = new Player({});
		other.me = false;
		model.currentPlayer = other;
		Assert.isFalse(model.me); // :408-409

		model.currentPlayer = null;
		Assert.isTrue(model.me); // :402-403

		var mePlayer = new Player({});
		mePlayer.me = true;
		model.currentPlayer = mePlayer;
		Assert.isTrue(model.me); // :405-406
	}

	// —— 工具 ——

	function makeModel():MessageModel {
		return new MessageModel();
	}

	// 三类事件全收进一个 log：{type, data}
	function listen(model:MessageModel, log:Array<Dynamic>):Void {
		model.addEventListener(MessageModel.EVENT_DATA_CHANGED,
			function(e:Event) log.push({type: MessageModel.EVENT_DATA_CHANGED, data: cast(e, CommonEvent).data}));
		model.addEventListener(MessageModel.EVENT_DATA_LOADING,
			function(e:Event) log.push({type: MessageModel.EVENT_DATA_LOADING, data: cast(e, CommonEvent).data}));
		model.addEventListener(MessageModel.EVENT_DATA_FAILED,
			function(e:Event) log.push({type: MessageModel.EVENT_DATA_FAILED, data: cast(e, CommonEvent).data}));
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

	static function firstData(log:Array<Dynamic>, type:String):Dynamic {
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				return Reflect.field(entry, "data");
			}
		}
		return null;
	}

	static function changedIndexes(log:Array<Dynamic>):Array<String> {
		var out:Array<String> = [];
		for (entry in log) {
			if (Reflect.field(entry, "type") == MessageModel.EVENT_DATA_CHANGED) {
				out.push(Reflect.field(Reflect.field(entry, "data"), "index"));
			}
		}
		return out;
	}

	// 应答事件：body 用 Utils.buildRequest 造出与 NetHelper.sendRequest →
	// theApp.run 真实链路同构的 {cmdID, __body, __method, __format}；
	// result 装入 ServiceResultVO（getVOData 的 m_extra 分支）
	static function voEvent(cmd:Int, reqParams:Dynamic, payload:Dynamic):CommandEvent {
		var vo = new ServiceResultVO();
		vo.m_extra = payload;
		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.body = Utils.buildRequest(cmd, reqParams);
		ev.result = vo;
		return ev;
	}
}
