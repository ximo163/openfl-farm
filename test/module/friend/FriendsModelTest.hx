package module.friend;

import com.qzone.qfa.events.CommandEvent;
import common.CommonData;
import common.Session;
import common.Settings;
import common.misc.Utils;
import entities.Friend;
import entities.Player;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.vo.ServiceResultVO;
import openfl.events.Event;
import utest.Assert;

/**
 * FriendsModel 纯逻辑（issue #20）：好友列表数据层——排序/过滤/分页/搜索，
 * cgi_farm_getstatus_filter 状态表（"1"-"7"）的装载与本地推进，功能门位，
 * 各应答回调的分派。好友切换进好友农场（偷菜/浇水入口）依赖这里的列表与
 * 状态数据。
 *
 * 环境口径（同 #19 MessageModelTest）：
 * - NetHelper.sendRequest 在 theApp == null 时 no-op（#7 已译），单测进程
 *   不跑 Main、theApp 恒 null——请求侧参数拼装（friend_uids/friend_uins、
 *   addFilter 的 uId 等）不可观测，不设测试；应答侧直接喂构造好的
 *   CommandEvent（body 用 Utils.buildRequest 造出与真实链路同构的
 *   {cmdID,__body,…}，result 为 ServiceResultVO，走 NetHelper.getVOData
 *   的 m_extra 分支）。getVOData 对非 ServiceResultVO/Array 的 result
 *   （refreshFriendStatus :471 的裸 status 表复用）返回 null → onFriendStatusLoaded
 *   不重读表、引用不动。
 * - Cookies 的 SharedObject 未初始化（Cookie == null）时 getObject 恒
 *   null、setObject 恒 false（Cookies.hx :22/:44）——好友列表缓存命中
 *   （loadFriendsData :297-313）、nameMap 空名回退（:984-997）、
 *   specialProcessStatus 的 f_ cookie 覆盖（:201-206）、t_/u_/z_ cookie
 *   侧写均不可观测，不设测试；onFriendsDataFailed 的
 *   loadFriendsDataFromCache(null) 因此走「缓存无 → m_friendListLocal
 *   保持 null」分支（:1083-1086），loadFriendsData 恒走 :315-323 网络分支。
 * - EventRecorder 按 deviations（no-qq-telemetry）DISABLED（record* 入口
 *   即返回，src/report/EventRecorder.hx:173），上报分支无观测——但调用点
 *   参数照常求值：onFriendsDataFailed :1052 `getTimer() - m_requestStartTime`
 *   在 eval 上 Int-null 算术直接抛（实测），故该用例先钉
 *   m_requestStartTime = 0（真实链路里 loadFriendsData :288/:318 发请求前
 *   已赋值；AS3 int 字段默认 0）。
 * - QzoneJSAPI.WB 恒 false（qqoutlets-shim）：updateHeadList 的 WB 分支
 *   （:116-131）与 qzone getHeadList 分支（:132-146）在测试 mode="" 下均不
 *   触发；onWBProfileLoadedSuccess/Fail、setHeadList、getFriendByFiD
 *   （Friend._fid 是 farm-basic 翻译内容）不在本模块测试面内。
 * - CommonData.serverTime 钉 0 走 get_serverTime 的 _serverTime==0 纯分支
 *   （不读时钟，FarmLandModelTest 先例，CommonData.hx:144-148）；时间戳
 *   断言以 0 为「现在」，正数即未来、负数即过去。
 * - Language.L["请求超时，"]/["点击重试"] 在 cn 表恒等映射
 *   （src/common/Language.hx _l.cn；language 未配 → lang="cn"），失败文案
 *   按字面串断言。
 * - 多键 for-in 的派发顺序 AS3/eval 均无保证，一律按集合断言不按序断言。
 *
 * 过滤表（m_friendListFilter）的语义依据（重要，勿按直觉改断言）：
 * - filterOut :697 闭包 `return m_friendListFilter.hasOwnProperty(_uin)`
 *   且 Array.filter 保留返回 true 的项 → 极性是「表内好友被保留」，与
 *   FriendsView.setGray（表内仅置灰仍在渲染）直觉矛盾，曾疑 FFDec 丢取反；
 *   经 tools/DumpAbcMethod.hx 直接读部署 swf 的 ABC 核对：闭包字节码
 *   getlex m_friendListFilter / getprop _uin / callproperty hasOwnProperty /
 *   returnvalue，无 OpNot——FFDec 反编译忠实，极性就是「保留」。
 * - 本部署快照里过滤器三动作均无服务端实现（mync.php:50-51 白名单只有
 *   'friend' 与 'cgi_farm_getstatus_filter'，无 friend_listfilter/
 *   friend_addfilter/friend_delfilter），且 cgi_farm_getstatus_filter.php
 *   只回 '{"status":…}'、没有 filter 字段 → m_friendListFilter 运行期恒
 *   null，filterOut 走 :703-705 直通。下面对「表非 null」的合成场景钉的
 *   是反编译指令语义本身——防止实现阶段按直觉把它「修」成剔除极性。
 *
 * 依赖的 Friend 半成品：entities/Friend.hx 是 #7 的字段 stub（本阶段补
 * _userId/sort/status 三个被引用字段）。onFriendsDataLoaded 补自己
 * （:516-518）走 Friend.importFromPlayer、缓存恢复走 importFromCache
 * （Friend.as:88-131）——是 Friend 留给「后续模块片」的部分，测试只断言
 * FriendsModel 侧可观测结果，Friend 方法内部语义随实现阶段按 Friend.as
 * 补齐。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/module/friend/FriendsModel.as
 *   （常量 :26-38、ctor :66-81、removeFairyStatus :97-108、
 *   specialProcessStatus :149-210、reloadThisPage :212-215、canPick :217-237、
 *   sortBy :239-263、loadFriendsData :270-324、onFriendStatusLoaded :326-357、
 *   goBackPage :359-377、refreshFriendStatus :451-491、onFriendsDataLoaded
 *   :493-559、checkServerDown :561-570、goNextPage :572-584、loadFriendStatus
 *   :586-627、onRefreshStatusSuccess :629-645、pageHandler :658-689、
 *   filterOut :691-708、copyStatus :733-779、onFriendStatusFailed :781-804、
 *   goLastPage :806-811、showFriendSum :813-828、onFriendsFilterSuccess
 *   :830-842、updatePoolStatus :864-908、processFriendList :910-1008、
 *   onAddFriendFilterSuccess :1010-1029、onFriendsDataFailed :1031-1059、
 *   goFirstPage :1061-1065、updateLandsStatus2 :1101-1121、updateBackStatus
 *   :1123-1150、friendSort :1152-1167、cleanUserRecall :1169-1184、
 *   searchFriend :1186-1200、hasMe :1202-1214、alertWindow :1222-1232、
 *   getFriendByID :1234-1245、onRemoveFriendFilterSuccess :1252-1271、
 *   updateLandsStatus :1273-1373、filterFriendList :1375-1438、openByFlashVar
 *   :1445-1466、forbidden :1468-1480）
 * - spec/protocol.json entries.nc.mods：
 *   friend（每好友 {uId,uin(=uId),userName,headPic,yellowlevel,
 *   yellowstatus,exp,pastrueExp,money,pf}，friend.php:31-54；friendType==1
 *   时列表含自己 :6-12——对应 hasMe/补自己路径）、cgi_farm_getstatus_filter
 *   （status.<uid> 子键："1" 可偷成熟时间戳 :25-43、"2"=1 长草可帮 :44-47、
 *   "3"=1 长虫可帮 :48-50、"4" 可攻击野牛截止 :56-68、"6"=1 鱼塘成熟
 *   :70-85）、user_checkstatus（cmd 20 备用空壳，mync.php:88）
 * - legacy/deploy/QFarmFlash/source/core/source/nc/mod/cgi_farm_getstatus_filter.php
 *   （只回 status，无 filter 字段）、legacy/deploy/QFarmFlash/source/core/mync.php:50-51
 *   （mod 白名单）、tools/DumpAbcMethod.hx（filterOut 极性字节码核对）
 * - cmd→mod 映射：framework/net/ServerServices.hx m_cmdMap（40→mod=friend、
 *   41→cgi_farm_getstatus_filter、42→mod=friend&act=listFilter、88→
 *   mod=friend&act=addFilter、89→mod=friend&act=delFilter、20→
 *   mod=user&act=checkStatus）
 * - Consts.ALERT_TYPE_TIP 的值 "tip"（Consts.as:222，常见值已译，本类
 *   实现时补常量）
 */
@:access(module.friend.FriendsModel)
class FriendsModelTest {
	public function new() {}

	var model:FriendsModel;

	var savedHost:Player;
	var savedCurrentUser:Player;
	var savedHealthModeValid:Bool;

	public function setup() {
		model = freshModel();
		var host = new Player({});
		host._uId = 1;
		host._userName = "农场主";
		host._exp = 100;
		host._money = 50.0;
		host._uinLogin = 88888888;
		host.me = true;
		var s = Session.getInstance();
		savedHost = s.host;
		savedCurrentUser = s.currentUser;
		savedHealthModeValid = s.healthModeValid;
		s.host = host;
		s.currentUser = host;
		s.healthModeValid = false;
		Settings.getInstance().loadLocalSettings(null); // mode 复位 ""（Settings.hx:122-135 空参分支）
		CommonData.serverTime = 0;
	}

	public function teardown() {
		var s = Session.getInstance();
		s.host = savedHost;
		s.currentUser = savedCurrentUser;
		s.healthModeValid = savedHealthModeValid;
		Settings.getInstance().loadLocalSettings(null);
		CommonData.serverTime = 0;
	}

	// stub 的 ctor 无默认值（那是实现内容），各用例统一从这里起手
	static function freshModel():FriendsModel {
		var m = new FriendsModel();
		m._showFriendPage = 1; // AS3 ctor :77
		m.m_sortField = "exp"; // :79
		m.m_searchFriendValue = ""; // :80
		return m;
	}

	// :26-38 事件名/页容量常量；:66-81 ctor 默认（m_sortField="exp"、
	// _showFriendPage=1、m_searchFriendValue=""、各列表 null）
	public function test_event_constants_and_ctor_defaults() {
		Assert.equals("PopAlertWindow", FriendsModel.EVENT_ALERT_WINDOW); // :26
		Assert.equals("FriendDataLoading", FriendsModel.EVENT_DATA_LOADING); // :28
		Assert.equals("FriendDataFailed", FriendsModel.EVENT_DATA_LOAD_FAILED); // :30
		Assert.equals("FriendListForbid", FriendsModel.EVENT_FUNCTION_FORBIDDEN); // :32
		Assert.equals("HeadPicLoaded", FriendsModel.EVENT_HEAD_PIC_LOADED); // :34
		Assert.equals("RefreshCurrentpage", FriendsModel.EVENT_REFRESH_PAGE); // :36
		Assert.equals(10, FriendsModel.friendPageNum); // :38
		var fresh = new FriendsModel();
		Assert.equals("exp", fresh.m_sortField); // :79
		Assert.equals(1, fresh._showFriendPage); // :77
		Assert.equals("", fresh.m_searchFriendValue); // :80
		Assert.isNull(fresh.m_friendList); // :71
		Assert.isFalse(fresh.m_gotFriendStatus == true); // :76 AS3 Boolean 默认 false
	}

	// :239-263 + :1152-1167：sortBy 同域早退；换域重排（exp/money 降序）+
	// sort 重编号 1..n + RefreshCurrentpage；列表 null 只换域不派发
	public function test_sortBy_same_field_noop_and_switch_renumbers() {
		var fA = mkFriend(11, 11, 30, 5.0, "甲");
		var fB = mkFriend(12, 12, 10, 9.0, "乙");
		var fC = mkFriend(13, 13, 20, 7.0, "丙");
		model.m_friendList = [fA, fB, fC];
		var log:Array<Dynamic> = [];
		listen(log);

		model.sortBy("exp"); // 与默认域相同 → :244-246 早退
		Assert.equals(0, log.length);

		model.sortBy("money"); // :1158-1166 按 money 降序
		Assert.equals("money", model.m_sortField);
		Assert.equals(1, countType(log, FriendsModel.EVENT_REFRESH_PAGE));
		Assert.equals(3, model.m_friendList.length);
		Assert.equals(fB, model.m_friendList[0]); // money 9 → 头位
		Assert.equals(fC, model.m_friendList[1]);
		Assert.equals(fA, model.m_friendList[2]);
		Assert.equals(1, fB.sort); // :254-260 重编号 1..n
		Assert.equals(2, fC.sort);
		Assert.equals(3, fA.sort);

		model.sortBy("money"); // 再次同域 → 早退
		Assert.equals(1, log.length);

		model.sortBy("exp"); // 换回 exp → 降序重排
		Assert.equals(2, countType(log, FriendsModel.EVENT_REFRESH_PAGE));
		Assert.equals(fA, model.m_friendList[0]); // exp 30
		Assert.equals(fC, model.m_friendList[1]);
		Assert.equals(fB, model.m_friendList[2]);
		Assert.equals(1, fA.sort);
		Assert.equals(3, fB.sort);

		var noList = freshModel();
		noList.sortBy("money"); // :249 null 列表只换域
		Assert.equals("money", noList.m_sortField);
	}

	// :910-1008 列表处理（过滤表 null 的直通路径——本部署快照唯一可达路径，
	// cgi_farm_getstatus_filter.php 无 filter 字段）：按 exp 降序 → sort 重编号
	// → status 挂接（键 _uId，无键置 null）→ 自己行打 me 旗标并同步宿主
	// exp/money → 空名不回退（cookie nameMap 环境侧不可达）→ DataLoading(false)
	// + RefreshCurrentpage
	public function test_processFriendList_sort_renumber_me_status() {
		var f1 = mkFriend(101, 101, 5, 1.0, "甲");
		var f2 = mkFriend(102, 102, 9, 2.0, ""); // 空名
		var fMe = mkFriend(1, 1, 7, 3.0, "我");
		var st102 = obj([["2", 1]]); // cgi_farm_getstatus_filter "2" 长草（:44-47）
		model.m_friendStatus = obj([["102", st102]]);
		var log:Array<Dynamic> = [];
		listen(log);

		model.processFriendList([f1, f2, fMe]);

		Assert.equals(3, model.m_friendList.length); // 过滤表 null → :703-705 直通
		Assert.equals(f2, model.m_friendList[0]); // exp 9 头位
		Assert.equals(fMe, model.m_friendList[1]); // 7
		Assert.equals(f1, model.m_friendList[2]); // 5
		Assert.equals(1, f2.sort); // :941 重编号
		Assert.equals(2, fMe.sort);
		Assert.isFalse(f2.me == true); // :966
		Assert.isTrue(fMe.me == true); // :958-960 _uId 命中宿主
		Assert.equals(100, fMe._exp); // :961 同步宿主
		Assert.equals(50.0, fMe._money); // :962
		Assert.equals("", f2._userName); // :984-997 cookie 回退不可达，空名保持
		Assert.isTrue(f2.status == st102); // :951 键 _uId 命中，引用挂接
		Assert.isTrue(fMe.status == null); // :955 状态表无我 → null
		Assert.isTrue(f1.status == null);
		Assert.equals(1, countType(log, FriendsModel.EVENT_DATA_LOADING)); // :917
		Assert.isFalse(firstData(log, FriendsModel.EVENT_DATA_LOADING) == true);
		var page = firstData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals(1, Reflect.field(page, "index"));
		Assert.equals(1, Reflect.field(page, "total"));
		Assert.equals(3, (Reflect.field(page, "friends"):Array<Dynamic>).length);

		// 过滤表非 null（合成场景）：filterOut 极性为「表内保留」
		// （:697 + 字节码核对 tools/DumpAbcMethod.hx），列表只剩表内好友
		var flt = freshModel();
		var gA = mkFriend(201, 201, 1, 1.0, "表内");
		var gB = mkFriend(202, 202, 2, 2.0, "表外");
		flt.m_friendListFilter = obj([["201", 1]]);
		flt.processFriendList([gA, gB]);
		Assert.equals(1, flt.m_friendList.length);
		Assert.equals(gA, flt.m_friendList[0]);
		Assert.equals(1, gA.sort);
		Assert.isFalse(gB.me == true); // gB 未进列表，me 旗标不打

		// m_friendStatus == null 时 status 整段跳过 :947-957
		var bare = freshModel();
		var fX = mkFriend(21, 21, 1, 1.0, "x");
		bare.processFriendList([fX]);
		Assert.isTrue(fX.status == null);
	}

	// :691-708 filterOut：null/空数据原样返回；过滤表 null 原样；
	// 表非 null 时只保留 uin 在表里的（字节码核对的保留极性，勿改）
	public function test_filterOut_boundaries() {
		Assert.isTrue(model.filterOut(null) == null); // :699-701
		Assert.equals(0, model.filterOut([]).length);
		var f1 = mkFriend(301, 301, 1, 1.0, "a");
		var f2 = mkFriend(302, 302, 2, 2.0, "b");
		var f3 = mkFriend(303, 303, 3, 3.0, "c");
		var data = [f1, f2, f3];
		var out = model.filterOut(data); // 过滤表 null → 原样 :703-705
		Assert.equals(3, out.length);
		model.m_friendListFilter = obj([["303", 1]]);
		var kept = model.filterOut(data); // :697 hasOwnProperty → 表内保留
		Assert.equals(1, kept.length);
		Assert.equals(f3, kept[0]);
	}

	// :813-828 showFriendSum：null 列表恒 1；空列表 ceil(0)→0 取 1；满页 10
	// 一页、11 两页、25 三页；搜索态按过滤后条数
	public function test_showFriendSum_boundaries() {
		Assert.equals(1, model.showFriendSum); // null 列表 :816
		model.m_friendList = [];
		Assert.equals(1, model.showFriendSum); // ceil(0)=0 → :827 取 1
		model.m_friendList = mkNamedFriends(1, "a");
		Assert.equals(1, model.showFriendSum);
		model.m_friendList = mkNamedFriends(10, "a");
		Assert.equals(1, model.showFriendSum); // 恰满页
		model.m_friendList = mkNamedFriends(11, "a");
		Assert.equals(2, model.showFriendSum);
		model.m_friendList = mkNamedFriends(25, "a");
		Assert.equals(3, model.showFriendSum);
		// 搜索态：15 人 s01..s15，"s1" 命中 s10..s15 共 6 → 1 页
		model.m_friendList = mkNamedFriends(15, "s");
		model.m_searchFriendValue = "s1";
		Assert.equals(1, model.showFriendSum); // :824
		model.m_searchFriendValue = "s";
		Assert.equals(2, model.showFriendSum); // 15 人 → 2 页
		model.m_friendList = null;
		model.m_searchFriendValue = "s1";
		Assert.equals(1, model.showFriendSum); // null 列表不看搜索
	}

	// :658-689 pageHandler：页切片 [(page-1)*10, page*10) 钳制到列表长；
	// RefreshCurrentpage 携 {index,total,friends}；空列表零条不抛；
	// reloadThisPage 重派发；null 列表早退不派发
	public function test_pageHandler_slices_and_refresh_event() {
		var log:Array<Dynamic> = [];
		listen(log);
		model.pageHandler();
		Assert.equals(0, log.length); // :660-661 null 列表

		model.m_friendList = mkNamedFriends(21, "p");
		model._showFriendPage = 1;
		model.pageHandler();
		var page = firstData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals(10, (Reflect.field(page, "friends"):Array<Dynamic>).length); // 满 10
		Assert.equals(1, Reflect.field(page, "index"));
		Assert.equals(3, Reflect.field(page, "total"));

		model._showFriendPage = 2;
		model.reloadThisPage(); // :212-215 → pageHandler
		var page2 = lastData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals(2, Reflect.field(page2, "index"));
		var friends2:Array<Dynamic> = Reflect.field(page2, "friends");
		Assert.equals(10, friends2.length);
		Assert.equals("p11", friends2[0]._userName); // 切片从第 11 条起

		model._showFriendPage = 3;
		model.reloadThisPage();
		var page3 = lastData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals(1, (Reflect.field(page3, "friends"):Array<Dynamic>).length); // 21 条只剩 1

		model._showFriendPage = 9; // 越界页 → :667-669 钳到表尾 → 空切片
		model.reloadThisPage();
		var page9 = lastData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals(0, (Reflect.field(page9, "friends"):Array<Dynamic>).length);
		Assert.equals(3, Reflect.field(page9, "total"));

		model.m_friendList = [];
		model._showFriendPage = 1;
		model.reloadThisPage(); // 空列表：零条不抛
		var pageE = lastData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals(0, (Reflect.field(pageE, "friends"):Array<Dynamic>).length);
		Assert.equals(1, Reflect.field(pageE, "total"));
	}

	// :359-377 goBackPage、:572-584 goNextPage、:806-811 goLastPage、
	// :1061-1065 goFirstPage：翻页环绕、回退的搜索词覆盖与复位分支
	public function test_page_navigation_wrap_and_back_quirks() {
		model.m_friendList = mkNamedFriends(25, "g");
		var log:Array<Dynamic> = [];
		listen(log);

		model.goFirstPage(); // :1061-1065（param1 原版未使用）
		Assert.equals(1, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));
		model.goLastPage(); // :806-811
		Assert.equals(3, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));
		model._showFriendPage = 1;
		model.goNextPage(); // :575-578
		Assert.equals(2, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));
		model.goNextPage();
		Assert.equals(3, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));
		model.goNextPage(); // 3+1 > 3 → :580-582 回卷 1
		Assert.equals(1, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));
		model.goBackPage(); // :371-376 3→2→1
		Assert.equals(2, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));
		model.goBackPage();
		Assert.equals(1, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));
		var before = log.length;
		model.goBackPage(); // :371 页 1 早退，不派发
		Assert.equals(before, log.length);
		// 页 1 带参回退：搜索词已设（:363）但页不动、不派发
		model.goBackPage("xyz");
		Assert.equals("xyz", model.m_searchFriendValue);
		Assert.equals(before, log.length);
		model.m_searchFriendValue = "";

		// 无参回退越界：复位分支（:364）只在 param 非空时可达，普通减页
		// 会把搜索词覆盖成 param（:373）——传 "" 即清搜索回全表切片
		model._showFriendPage = 3;
		model.m_searchFriendValue = "nomatch";
		model.goBackPage("");
		var back = lastData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals(2, Reflect.field(back, "index"));
		Assert.equals("", model.m_searchFriendValue); // :373 覆盖为 param
		Assert.equals(3, Reflect.field(back, "total")); // 搜索已清 → 全表
		Assert.equals(10, (Reflect.field(back, "friends"):Array<Dynamic>).length); // 全表第 2 页

		// 带 param 且 page-1 > sum（搜索收窄后越界）→ 复位 1（:364-369）
		model._showFriendPage = 3;
		model.goBackPage("nomatch");
		var reset = lastData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals("nomatch", model.m_searchFriendValue);
		Assert.equals(1, Reflect.field(reset, "index"));
		Assert.equals(1, Reflect.field(reset, "total")); // 无命中 → 1
		Assert.equals(0, (Reflect.field(reset, "friends"):Array<Dynamic>).length);

		// goNextPage(param) 先设搜索词再判环绕：25 人里 "g2" 命中 g20..g25
		// 共 6 → 单页 → 1+1>1 回卷 1，friends 是过滤切片 :673
		model._showFriendPage = 1;
		model.goNextPage("g2");
		var next = lastData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals("g2", model.m_searchFriendValue);
		Assert.equals(1, Reflect.field(next, "index"));
		Assert.equals(1, Reflect.field(next, "total"));
		Assert.equals(6, (Reflect.field(next, "friends"):Array<Dynamic>).length);
	}

	// :1186-1200 searchFriend：设词并翻页；当前页越界复位 1；空词清搜索
	public function test_searchFriend_set_clear_and_page_reset() {
		model.m_friendList = mkNamedFriends(25, "g");
		var log:Array<Dynamic> = [];
		listen(log);

		model.searchFriend("g2"); // g20..g25 共 6 条
		Assert.equals("g2", model.m_searchFriendValue);
		var page = lastData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals(6, (Reflect.field(page, "friends"):Array<Dynamic>).length);
		Assert.equals(1, Reflect.field(page, "total"));

		model._showFriendPage = 3; // :1191-1196 搜索收窄后越界 → 复位 1
		model.searchFriend("g2");
		Assert.equals(1, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));

		model.searchFriend(""); // :1198-1199 清搜索回全表
		var full = lastData(log, FriendsModel.EVENT_REFRESH_PAGE);
		Assert.equals("", model.m_searchFriendValue);
		Assert.equals(3, Reflect.field(full, "total"));
		Assert.equals(10, (Reflect.field(full, "friends"):Array<Dynamic>).length);
	}

	// :1394-1411 filterFriendList 名字匹配：大小写不敏感子串、保序列、
	// null 条目丢弃、无匹配空
	public function test_filterFriendList_name_match_case_insensitive() {
		var bob = mkFriend(1, 1, 1, 1.0, "bob");
		var alice = mkFriend(2, 2, 2, 2.0, "Alice");
		var charlie = mkFriend(3, 3, 3, 3.0, "Charlie");
		model.m_friendList = [bob, alice, charlie];

		model.m_searchFriendValue = "LI"; // :1401 ".*?LI.*" i 旗标
		var out = model.filterFriendList;
		Assert.equals(2, out.length);
		Assert.equals(alice, out[0]); // 保输入序 :1416
		Assert.equals(charlie, out[1]);

		model.m_searchFriendValue = "zzz";
		Assert.equals(0, model.filterFriendList.length);
	}

	// :1403-1436 qzone 模式的 QQ 号匹配分支：名字没中但 uin 中 → 追加；
	// 双命中去重只出现一次；非 qzone 模式无此分支
	public function test_filterFriendList_qzone_uin_branch_and_dedupe() {
		var a = mkFriend(555, 555, 1, 1.0, "Al555"); // 名字和 uin 都含 555
		var b = mkFriend(300, 300, 2, 2.0, "Zed"); // 只有 uin 含 300
		model.m_friendList = [a, b];

		model.m_searchFriendValue = "300"; // 非 qzone：无 uin 分支
		Assert.equals(0, model.filterFriendList.length);

		// Settings.get_mode："mode"=="1" → "qzone"（Settings.hx :129-134）
		Settings.getInstance().loadLocalSettings({mode: "1"});
		model.m_searchFriendValue = "300";
		var out = model.filterFriendList;
		Assert.equals(1, out.length); // :1419-1436 uin 命中追加
		Assert.equals(b, out[0]);

		model.m_searchFriendValue = "555"; // 名字+uin 双命中 → :1424-1435 去重
		var dedup = model.filterFriendList;
		Assert.equals(1, dedup.length);
		Assert.equals(a, dedup[0]);
	}

	// :1384-1393/:1412-1415 魔法搜索值 "45623371"/"82822239"：不走名字匹配，
	// 只列状态表里出现过的好友（m_friendListMap 按 m_friendStatus 键取）
	public function test_filterFriendList_magic_values_status_only() {
		var fA = mkFriend(401, 401, 1, 1.0, "状态甲");
		var fB = mkFriend(402, 402, 2, 2.0, "状态乙");
		model.m_friendListMap = obj([["401", fA], ["402", fB]]);
		model.m_friendStatus = obj([["401", obj([["2", 1]])], ["402", null]]);
		model.m_friendList = null; // 魔法值在 :1416 之前短路，列表可空

		model.m_searchFriendValue = "45623371";
		var out = model.filterFriendList;
		Assert.equals(2, out.length); // for-in 键序无保证，按集合断言
		var uins:Array<Dynamic> = [out[0]._uin, out[1]._uin];
		Assert.isTrue(uins.indexOf(401) >= 0);
		Assert.isTrue(uins.indexOf(402) >= 0);

		model.m_searchFriendValue = "82822239";
		Assert.equals(2, model.filterFriendList.length);
	}

	// :149-210 specialProcessStatus：null 条目删除、String 条目转 {}、
	// "6"（鱼塘成熟标记，cgi_farm_getstatus_filter :70-85）数值>0 → true、
	// 0/非数保持原样；f_ cookie 覆盖分支环境侧不可达（Cookies inert）
	public function test_specialProcessStatus_entry_cleanup_and_fish_flag() {
		var f203 = mkFriend(203, 203, 1, 1.0, "鱼塘有货");
		var f204 = mkFriend(204, 204, 2, 2.0, "鱼塘空");
		var f205 = mkFriend(205, 205, 3, 3.0, "脏值");
		model.m_friendList = [f203, f204, f205];
		var st = obj([
			["201", null],
			["202", ""],
			["203", obj([["6", 1]])],
			["204", obj([["6", 0]])],
			["205", obj([["6", "x"]])],
			["206", obj([["2", 1]])]
		]);
		model.m_friendStatus = st;

		model.specialProcessStatus();

		Assert.isFalse(Reflect.hasField(st, "201")); // :172-175 null 删除
		Assert.equals(0, Reflect.fields(Reflect.field(st, "202")).length); // :178-181 String → {}
		Assert.isTrue(Reflect.field(Reflect.field(st, "203"), "6") == true); // :196-200
		Assert.equals(0, Reflect.field(Reflect.field(st, "204"), "6")); // 非 >0 保持
		Assert.equals("x", Reflect.field(Reflect.field(st, "205"), "6")); // parseFloat NaN 保持
		Assert.equals(1, Reflect.field(Reflect.field(st, "206"), "2")); // 无 "6" 不动
	}

	// :217-237 canPick：uid 0 早退、状态未装载早退；"1"（可偷成熟时间戳，
	// cgi_farm_getstatus_filter :25-43）是 int 且在未来 → 置 true 并请求
	// checkStatus（theApp null no-op）；过去值/非 int 不动；null 条目安全
	public function test_canPick_gates_and_mature_flag() {
		var st = obj([
			["101", obj([["1", 5000]])],
			["102", obj([["1", -50]])],
			["103", obj([["1", true]])],
			["104", null]
		]);
		model.m_friendStatus = st;
		var log:Array<Dynamic> = [];
		listen(log);

		model.canPick(101, 7); // :224-226 状态未装载早退（AS3 Boolean 默认 false）
		Assert.equals(5000, Reflect.field(Reflect.field(st, "101"), "1"));

		model.m_gotFriendStatus = true;
		model.canPick(0, 7); // :220-222
		Assert.equals(5000, Reflect.field(Reflect.field(st, "101"), "1"));

		model.canPick(101, 7); // 5000 > serverTime 0 → :232-233 置 true
		Assert.isTrue(Reflect.field(Reflect.field(st, "101"), "1") == true);
		model.canPick(102, 7); // -50 ≤ 0 不动
		Assert.equals(-50, Reflect.field(Reflect.field(st, "102"), "1"));
		model.canPick(103, 7); // true 非 int 不动（:228 is int 门）
		Assert.isTrue(Reflect.field(Reflect.field(st, "103"), "1") == true);
		model.canPick(104, 7); // null 条目 :228-229 短路不抛
		Assert.isTrue(Reflect.field(st, "104") == null);
		Assert.equals(0, log.length); // canPick 不派发
	}

	// :864-908 updatePoolStatus（鱼塘 "6" 标记的本地推进）：空表早退；无
	// uid 门（0 照样建 "0" 键）；未装载直写；已装载条目缺则新建、值不同才动
	public function test_updatePoolStatus_fish_flag_gates() {
		model.updatePoolStatus(101, 7, true, true); // :867-869 空表早退
		Assert.isNull(model.m_friendStatus);

		model.m_friendStatus = obj([]);
		model.updatePoolStatus(0, 7, true, true); // :875 无 uid 门，照建 "0"
		Assert.equals(1, Reflect.fields(model.m_friendStatus).length);
		Assert.isTrue(Reflect.field(Reflect.field(model.m_friendStatus, "0"), "6") == true);

		// 未装载（m_gotFriendStatus false）：条目缺 → 新建 {"6":true}（:875-878）
		model.updatePoolStatus(101, 7, true, true);
		Assert.isTrue(Reflect.field(Reflect.field(model.m_friendStatus, "101"), "6") == true);
		// 条目已有 → 原位改写（:879-882）
		model.m_friendStatus = obj([["102", obj([["2", 1]])]]);
		model.updatePoolStatus(102, 7, true, true);
		Assert.isTrue(Reflect.field(Reflect.field(model.m_friendStatus, "102"), "6") == true);
		Assert.equals(1, Reflect.field(Reflect.field(model.m_friendStatus, "102"), "2")); // 原键保留

		// 已装载：条目缺 → 新建（:896-898）
		model.m_friendStatus = obj([]);
		model.m_gotFriendStatus = true;
		model.updatePoolStatus(103, 7, true, true);
		Assert.isTrue(Reflect.field(Reflect.field(model.m_friendStatus, "103"), "6") == true);
		// 条目值翻转（:886-893）
		model.m_friendStatus = obj([["104", obj([["6", false]])]]);
		model.updatePoolStatus(104, 7, true, true);
		Assert.isTrue(Reflect.field(Reflect.field(model.m_friendStatus, "104"), "6") == true);
	}

	// :1273-1373 updateLandsStatus（"1" 偷取时间/"2" 除草/"3" 除虫的本地推进）
	// 逐分支表：p5=false 过去的 int "1" 删除；p5=true "1" 无条件置 true；
	// p3/p4=false 删键、=true 置 true；条目缺而已装载时按 p3/p4 逐段新建；
	// :1344-1348/:1364-1368 的 else-if 在主分支删键后不可达（死代码，照钉）
	public function test_updateLandsStatus_land_flags_table() {
		// r1：空表早退 :1277-1279
		model.updateLandsStatus(101, 7, true, true, false, false);
		Assert.isNull(model.m_friendStatus);
		// r2：uid 0 早退
		model.m_friendStatus = obj([]);
		model.updateLandsStatus(0, 7, true, true, false, false);
		Assert.equals(0, Reflect.fields(model.m_friendStatus).length);
		// r3：过去的成熟时间戳（"1" int ≤ serverTime 0）删除（:1287-1294，
		// cookie t_ 写不可观测）；p3/p4=false → "2"/"3" 删除（:1311-1326）
		var st3 = obj([["1", -100], ["2", 1], ["3", 1]]);
		model.m_friendStatus = obj([["101", st3]]);
		model.m_gotFriendStatus = true;
		model.updateLandsStatus(101, 7, false, false, false, false);
		Assert.equals(0, Reflect.fields(st3).length);
		// r4：条目缺 + 已装载 + p3/p4=true → :1333-1340 先建 "2"、
		// :1353-1355 读表判存后原位补 "3"，最终 {"2":true,"3":true}
		model.m_friendStatus = obj([]);
		model.updateLandsStatus(102, 7, true, true, false, false);
		var entry4 = Reflect.field(model.m_friendStatus, "102");
		Assert.isTrue(Reflect.field(entry4, "2") == true);
		Assert.isTrue(Reflect.field(entry4, "3") == true);
		Assert.equals(2, Reflect.fields(entry4).length);
		// r5/r6：p5=true → "1" 置 true（:1299-1303，取值门只影响 changed 旗标）
		var st5 = obj([["1", -100]]);
		model.m_friendStatus = obj([["103", st5]]);
		model.updateLandsStatus(103, 7, false, false, true, false);
		Assert.isTrue(Reflect.field(st5, "1") == true);
		var st6 = obj([["1", 5000]]);
		model.m_friendStatus = obj([["104", st6]]);
		model.updateLandsStatus(104, 7, false, false, true, false);
		Assert.isTrue(Reflect.field(st6, "1") == true);
		// r7：条目 {"2": false} + p3=true → 置 true（:1317）
		var st7 = obj([["2", false]]);
		model.m_friendStatus = obj([["105", st7]]);
		model.updateLandsStatus(105, 7, true, false, false, false);
		Assert.isTrue(Reflect.field(st7, "2") == true);
		// r8：条目 {"2": true} + p3=false → 删除，p4=true 置 "3"（:1313/:1325；
		// :1344-1348 的 else-if 在删除后取到 undefined，不可达）
		var st8 = obj([["2", true]]);
		model.m_friendStatus = obj([["106", st8]]);
		model.updateLandsStatus(106, 7, false, true, false, false);
		Assert.isFalse(Reflect.hasField(st8, "2"));
		Assert.isTrue(Reflect.field(st8, "3") == true);
		// r9：条目 {"3": true} + p4=false → 删除，p3=true 置 "2"（:1321/:1317；
		// :1364-1368 同理不可达）
		var st9 = obj([["3", true]]);
		model.m_friendStatus = obj([["107", st9]]);
		model.updateLandsStatus(107, 7, true, false, false, false);
		Assert.isFalse(Reflect.hasField(st9, "3"));
		Assert.isTrue(Reflect.field(st9, "2") == true);
	}

	// :97-108 removeFairyStatus（删 "7"）与 :1169-1184 cleanUserRecall
	//（删页内条目的 "5"）：键清理族，其余键保留
	public function test_removeFairyStatus_and_cleanUserRecall_delete_keys() {
		var st = obj([["7", 1], ["2", 1]]);
		model.removeFairyStatus(0); // :100-102 空表早退
		Assert.isNull(model.m_friendStatus);
		model.m_friendStatus = obj([["101", st]]);
		model.removeFairyStatus(101); // :106 删 "7"
		Assert.isFalse(Reflect.hasField(st, "7"));
		Assert.equals(1, Reflect.field(st, "2"));
		var stNull = obj([["102", null]]);
		model.m_friendStatus = stNull;
		model.removeFairyStatus(102); // :104 null 条目短路
		Assert.isTrue(Reflect.field(stNull, "102") == null);

		// cleanUserRecall：for-in 数组下标，条目有 status → 删 status["5"]
		var fa = mkFriend(31, 31, 1, 1.0, "a");
		fa.status = obj([["5", 1], ["2", 1]]);
		var fb = mkFriend(32, 32, 2, 2.0, "b");
		fb.status = obj([["5", 3]]);
		model.cleanUserRecall([fa, fb]);
		Assert.isFalse(Reflect.hasField(fa.status, "5"));
		Assert.equals(1, Reflect.field(fa.status, "2")); // "2" 保留
		Assert.isFalse(Reflect.hasField(fb.status, "5"));
	}

	// :1101-1121 updateLandsStatus2（"4" 野牛截止挪进 u_ cookie）与
	// :1123-1150 updateBackStatus（"5" 挪进 z_ cookie）：cookie 侧不可观测，
	// 钉状态表里键被摘除；条目 null/uid 0/空表均早退
	public function test_updateLandsStatus2_and_updateBackStatus_move_keys() {
		model.updateLandsStatus2(101, 0); // :1103 空表早退
		Assert.isNull(model.m_friendStatus);
		model.updateBackStatus(101, 0);
		Assert.isNull(model.m_friendStatus);

		var st4 = obj([["4", 12345]]);
		model.m_friendStatus = obj([["101", st4]]);
		model.updateLandsStatus2(0, 0); // :1103 uid 0
		Assert.equals(12345, Reflect.field(st4, "4"));
		model.updateLandsStatus2(101, 0); // :1111-1114 param2==0 → 存原 "4" 值
		Assert.isFalse(Reflect.hasField(st4, "4"));
		var st4b = obj([["4", 22222]]);
		model.m_friendStatus = obj([["102", st4b]]);
		model.updateLandsStatus2(102, 999); // :1115-1117 存 param2
		Assert.isFalse(Reflect.hasField(st4b, "4"));

		var st5 = obj([["5", 3]]);
		model.m_friendStatus = obj([["103", st5]]);
		model.updateBackStatus(103, 0); // :1132-1138 z_ 带 serverTime
		Assert.isFalse(Reflect.hasField(st5, "5"));
		var st5b = obj([["5", 4]]);
		model.m_friendStatus = obj([["104", st5b]]);
		model.updateBackStatus(104, 777); // :1139-1146 z_ 带 param2
		Assert.isFalse(Reflect.hasField(st5b, "5"));
		var stNull = obj([["105", null]]);
		model.m_friendStatus = stNull;
		model.updateBackStatus(105, 0); // :1131 null 条目短路
		Assert.isTrue(Reflect.field(stNull, "105") == null);
	}

	// :733-779 copyStatus：状态表按键（非 uinMode 用 _uId、uinMode 用 _uin）
	// 挂到 friend.status，表里没有的置 null；空表早退
	public function test_copyStatus_attaches_by_uid_then_uinmode() {
		var fA = mkFriend(701, 501, 1, 1.0, "a"); // uin≠uId
		var fB = mkFriend(702, 502, 2, 2.0, "b");
		model.m_friendList = [fA, fB];
		var entry = obj([["2", 1]]);
		model.m_friendStatus = obj([["501", entry]]);

		model.copyStatus();

		Assert.isTrue(fA.status == entry); // :768-770 按 _uId 命中，引用挂接
		Assert.isTrue(fB.status == null); // :773-774

		// uinMode（uinMode=="1" 且 mode=="qzone"，Settings.hx:54-66）→ 按 _uin
		Settings.getInstance().loadLocalSettings({mode: "1", uinMode: "1"});
		var fC = mkFriend(601, 651, 3, 3.0, "c");
		model.m_friendList = [fC];
		var entryUin = obj([["3", 1]]);
		model.m_friendStatus = obj([["601", entryUin]]);
		model.copyStatus();
		Assert.isTrue(fC.status == entryUin); // :764-766 uinMode 分支
	}

	// :326-357 onFriendStatusLoaded（cmd 41 应答，本部署载荷只有 status——
	// cgi_farm_getstatus_filter.php 无 filter 字段）：status 落表 +
	// specialProcessStatus 预处理 + m_gotFriendStatus 置位 + 列表重排挂状态；
	// null 事件（健康模式路径）只走列表处理不读表
	public function test_onFriendStatusLoaded_status_response() {
		var fA = mkFriend(101, 101, 1, 1.0, "甲");
		var fB = mkFriend(102, 102, 2, 2.0, "乙");
		model.m_friendList = [fB, fA]; // 乱序进
		var log:Array<Dynamic> = [];
		listen(log);

		model.onFriendStatusLoaded(voEvent(CommandDefs.CMD_GET_FRIENDLIST_STATUS, {},
			{status: obj([["101", obj([["6", 1]])], ["102", null]])}));

		Assert.isTrue(model.m_gotFriendStatus == true); // :329
		Assert.isNull(model.friendListFilter); // 载荷无 filter 键 → :338-341 不动
		var st = model.m_friendStatus;
		Assert.isTrue(Reflect.field(Reflect.field(st, "101"), "6") == true); // :342 specialProcessStatus
		Assert.isFalse(Reflect.hasField(st, "102")); // null 条目被 :174 删除
		Assert.equals(fB, model.m_friendList[0]); // exp 2 头位
		Assert.equals(1, fB.sort);
		Assert.isTrue(fB.status == null); // "102" 已删 → 挂 null
		Assert.isTrue(fA.status == Reflect.field(st, "101")); // 挂同一对象
		// :330 + processFriendList :917 两处 DataLoading(false)
		Assert.equals(2, countType(log, FriendsModel.EVENT_DATA_LOADING));
		Assert.isFalse(firstData(log, FriendsModel.EVENT_DATA_LOADING) == true);
		Assert.equals(1, countType(log, FriendsModel.EVENT_REFRESH_PAGE));

		// 载荷带 filter 键（非本部署形态，钉读取路径 + 保留极性的后果）：
		// 表被整表替换，列表重排后只剩表内 uin
		var flt = freshModel();
		var gA = mkFriend(401, 401, 1, 1.0, "表内");
		var gB = mkFriend(402, 402, 2, 2.0, "表外");
		flt.m_friendList = [gA, gB];
		var filter = obj([["401", 1]]);
		flt.onFriendStatusLoaded(voEvent(CommandDefs.CMD_GET_FRIENDLIST_STATUS, {},
			{status: obj([]), filter: filter}));
		Assert.isTrue(flt.friendListFilter == filter); // :338-341
		Assert.equals(1, flt.m_friendList.length); // 保留极性：只剩 gA
		Assert.equals(gA, flt.m_friendList[0]);

		// null 事件（refreshFriendStatus :459-462 健康模式同路径）：不读表
		var bare = freshModel();
		var fX = mkFriend(21, 21, 1, 1.0, "x");
		bare.m_friendList = [fX];
		var log2:Array<Dynamic> = [];
		listenModel(bare, log2);
		bare.onFriendStatusLoaded(null);
		Assert.isTrue(bare.m_gotFriendStatus == true);
		Assert.isNull(bare.m_friendStatus); // :331 param null 不读
		Assert.equals(fX, bare.m_friendList[0]);
		Assert.equals(2, countType(log2, FriendsModel.EVENT_DATA_LOADING));
		Assert.equals(1, countType(log2, FriendsModel.EVENT_REFRESH_PAGE));
	}

	// :629-645 onRefreshStatusSuccess（刷新状态应答）：status 落表 +
	// specialProcessStatus + copyStatus + DataLoading(false) + 翻页重派
	//（不经 processFriendList）
	public function test_onRefreshStatusSuccess_status_copy_and_refresh() {
		var fA = mkFriend(501, 501, 1, 1.0, "a");
		model.m_friendList = [fA];
		var log:Array<Dynamic> = [];
		listen(log);

		model.onRefreshStatusSuccess(voEvent(CommandDefs.CMD_GET_FRIENDLIST_STATUS, {},
			{status: obj([["501", obj([["6", 1]])]])}));

		Assert.isTrue(Reflect.field(Reflect.field(model.m_friendStatus, "501"), "6") == true);
		Assert.isTrue(fA.status == Reflect.field(model.m_friendStatus, "501")); // :641 copyStatus
		Assert.equals(1, countType(log, FriendsModel.EVENT_DATA_LOADING)); // :642
		Assert.isFalse(firstData(log, FriendsModel.EVENT_DATA_LOADING) == true);
		Assert.equals(1, countType(log, FriendsModel.EVENT_REFRESH_PAGE)); // :644
	}

	// :493-559 onFriendsDataLoaded（cmd 40 应答，FriendsDataParser 已把 JSON
	// 行转成 Friend）：无自己 → 用 Session.host 补一个自己行（protocol friend
	// friendType==1 含自己 :6-12）；有自己 → 原位同步 exp/money；userId 别名
	// 也算「有自己」（hasMe :1208）；随后走 loadFriendStatus（DataLoading true +
	// theApp null no-op）；xb 停机在 DataLoading(false) 之后早退
	public function test_onFriendsDataLoaded_me_append_or_sync() {
		var f2 = mkFriend(2, 2, 3, 3.0, "乙");
		var log:Array<Dynamic> = [];
		listen(log);

		model.onFriendsDataLoaded(voEvent(CommandDefs.CMD_GET_FRIENDLIST, {}, [f2]));

		Assert.equals(2, model.m_friendListNet.length); // :549
		var me:Friend = model.m_friendListNet[1];
		Assert.equals(1, me._uId); // importFromPlayer 从 host 拷（Friend.as:116-118）
		Assert.equals(88888888, me._uin); // host._uinLogin
		Assert.equals("农场主", me._userName);
		Assert.equals("", me._headPic); // :518
		Assert.isTrue(me.me == true); // host.me
		Assert.isTrue(model.friendListLocal == model.m_friendListNet); // :599-601
		var loading = allData(log, FriendsModel.EVENT_DATA_LOADING);
		Assert.equals(2, loading.length); // :509 false → :621 true
		Assert.isFalse(loading[0] == true);
		Assert.isTrue(loading[1] == true);

		// 有自己：不补行，_uId 对上的行同步 exp/money（:522-537）
		var again = freshModel();
		var fMe = mkFriend(1, 1, 5, 9.0, "我");
		var fOther = mkFriend(2, 2, 3, 3.0, "乙");
		again.onFriendsDataLoaded(voEvent(CommandDefs.CMD_GET_FRIENDLIST, {}, [fMe, fOther]));
		Assert.equals(2, again.m_friendListNet.length);
		Assert.equals(100, fMe._exp); // :532
		Assert.equals(50.0, fMe._money); // :533
		Assert.equals(5, fOther._exp); // 别人不动

		// userId 别名（Friend._userId == host._uId）也算有自己（:1208）→
		// 不补行；但同步循环只对 _uId（:530）→ 别名行不被同步
		var alias = mkFriend(7, 7, 11, 11.0, "别名");
		alias._userId = 1;
		again.m_friendListNet = null;
		again.onFriendsDataLoaded(voEvent(CommandDefs.CMD_GET_FRIENDLIST, {}, [alias]));
		Assert.equals(1, again.m_friendListNet.length);
		Assert.equals(11, alias._exp);

		// checkServerDown 在 DataLoading(false) 之后（:509-512）：xb 置位时
		// 应答早退，列表不落
		Settings.getInstance().loadLocalSettings({xb: "停机维护中"});
		var down = freshModel();
		var log3:Array<Dynamic> = [];
		listenModel(down, log3);
		down.onFriendsDataLoaded(voEvent(CommandDefs.CMD_GET_FRIENDLIST, {}, [f2]));
		Assert.isNull(down.m_friendListNet);
		Assert.equals(1, countType(log3, FriendsModel.EVENT_DATA_LOAD_FAILED)); // :566
		Assert.equals("停机维护中", Reflect.field(firstData(log3, FriendsModel.EVENT_DATA_LOAD_FAILED), "error"));
		Assert.equals(1, countType(log3, FriendsModel.EVENT_DATA_LOADING)); // :509
		Assert.isFalse(firstData(log3, FriendsModel.EVENT_DATA_LOADING) == true);
	}

	// :1031-1059 onFriendsDataFailed：四类错误 → DataFailed 带重试链接文案
	//（Language.L cn 表恒等映射，src/common/Language.hx）；其他错误类型/
	// 空载荷无派发；缓存读不可用 → m_friendListLocal 保持 null（:1083-1086）
	public function test_onFriendsDataFailed_error_types_and_retry_text() {
		// 真实链路里 loadFriendsData 发请求前已设 m_requestStartTime
		//（:288/:318）；EventRecorder DISABLED 但调用点参数照常求值，eval 上
		// Int-null 算术抛，故先钉 0（AS3 int 字段默认也是 0）
		model.m_requestStartTime = 0;
		var log:Array<Dynamic> = [];
		listen(log);
		var retry = "请求超时，<a href=\'event:reload\'><u><font color=\'#ff6600\'>点击重试</font></u></a>"; // :1054

		for (errorType in ["IOError", "httpStatus", "timeOut", "PHPError"]) { // :1050
			model.onFriendsDataFailed(voEvent(CommandDefs.CMD_GET_FRIENDLIST, {}, {errorType: errorType}));
			Assert.equals(retry, Reflect.field(lastData(log, FriendsModel.EVENT_DATA_LOAD_FAILED), "error"));
			Assert.isNull(model.friendListLocal); // :1042-1045 缓存不可用，早退前未置
		}
		Assert.equals(4, countType(log, FriendsModel.EVENT_DATA_LOAD_FAILED));
		Assert.equals(4, countType(log, FriendsModel.EVENT_DATA_LOADING)); // :1041 每次先 false
		Assert.isFalse(firstData(log, FriendsModel.EVENT_DATA_LOADING) == true);

		model.onFriendsDataFailed(voEvent(CommandDefs.CMD_GET_FRIENDLIST, {}, {errorType: "securityError"}));
		Assert.equals(4, countType(log, FriendsModel.EVENT_DATA_LOAD_FAILED));

		model.onFriendsDataFailed(new CommandEvent(CommandEvent.COMPLETE)); // getVOData null → :1038 早退
		Assert.equals(4, countType(log, FriendsModel.EVENT_DATA_LOAD_FAILED));
	}

	// :781-804 onFriendStatusFailed：direction 拼接换行重试链接、
	// m_gotFriendStatus 落 false、列表照常重排（状态表为 null 不挂）
	public function test_onFriendStatusFailed_retry_text_and_list_processed() {
		var fA = mkFriend(101, 101, 1, 1.0, "甲");
		var fB = mkFriend(102, 102, 2, 2.0, "乙");
		model.m_friendList = [fA, fB];
		var log:Array<Dynamic> = [];
		listen(log);

		model.onFriendStatusFailed(voEvent(CommandDefs.CMD_GET_FRIENDLIST_STATUS, {}, {direction: "服务器繁忙"}));

		Assert.isFalse(model.m_gotFriendStatus == true); // :788
		Assert.equals("服务器繁忙<br/><a href=\'event:reload\'><u><font color=\'#ff6600\'>点击重试</font></u></a>",
			Reflect.field(firstData(log, FriendsModel.EVENT_DATA_LOAD_FAILED), "error")); // :789
		Assert.equals(fB, model.m_friendList[0]); // :791-802 列表重排
		Assert.equals(1, countType(log, FriendsModel.EVENT_REFRESH_PAGE));
		Assert.isTrue(fA.status == null);

		model.onFriendStatusFailed(new CommandEvent(CommandEvent.COMPLETE)); // 空载荷早退
		Assert.equals(1, countType(log, FriendsModel.EVENT_DATA_LOAD_FAILED));
	}

	// :830-842 onFriendsFilterSuccess（cmd 42 listFilter 应答）：过滤表整表
	// 落位（cookie 写环境侧不可观测）
	public function test_onFriendsFilterSuccess_stores_filter() {
		var payload = obj([["303", 1], ["304", 1]]);
		model.onFriendsFilterSuccess(voEvent(CommandDefs.CMD_GET_FRIEND_FILTER, {}, payload));
		Assert.isTrue(model.friendListFilter == payload); // :841
	}

	// :1010-1029 + :647-656 + :1222-1232：addFilter 应答 code=="1"（字符串）
	// → success 窗 + uId 落过滤表 + 列表重排（保留极性 → 列表只剩表内）；
	// code 不对全不动；code=="1" 无 uId 只弹窗；错误应答 alertWindow("error")、
	// 空文案不派发。:1024 对过滤表裸写，表须已存在（真实链路先经 cmd42 装载）
	public function test_addFilter_success_updates_map_and_relists() {
		var fA = mkFriend(303, 303, 1, 1.0, "甲");
		var fB = mkFriend(304, 304, 2, 2.0, "乙");
		model.m_friendList = [fA, fB];
		model.m_friendListFilter = obj([]); // :1024 裸写要求表已存在
		var log:Array<Dynamic> = [];
		listen(log);

		model.onAddFriendFilterSuccess(voEvent(CommandDefs.CMD_ADD_FRIEND_FILTER, {},
			{code: "1", direction: "指定好友的信息将不再显示", uId: 303}));

		Assert.equals(1, countType(log, FriendsModel.EVENT_ALERT_WINDOW)); // :1020
		var alert = firstData(log, FriendsModel.EVENT_ALERT_WINDOW);
		Assert.equals("success", Reflect.field(alert, "type"));
		Assert.equals("指定好友的信息将不再显示", Reflect.field(alert, "text"));
		Assert.equals(1, Reflect.field(model.friendListFilter, "303")); // :1024
		Assert.equals(1, model.m_friendList.length); // :1025 重排，保留极性 → 只剩 fA
		Assert.equals(fA, model.m_friendList[0]);
		Assert.equals(1, countType(log, FriendsModel.EVENT_REFRESH_PAGE));

		// code 不是 "1"：全不动（连窗都不弹）
		var reject = freshModel();
		var log2:Array<Dynamic> = [];
		listenModel(reject, log2);
		reject.onAddFriendFilterSuccess(voEvent(CommandDefs.CMD_ADD_FRIEND_FILTER, {},
			{code: "0", direction: "x", uId: 303}));
		Assert.equals(0, log2.length);
		Assert.isNull(reject.friendListFilter);

		// code=="1" 无 uId：只弹窗，不进表不重排（:1021 hasOwnProperty 门）
		reject.onAddFriendFilterSuccess(voEvent(CommandDefs.CMD_ADD_FRIEND_FILTER, {},
			{code: "1", direction: "已受理"}));
		Assert.equals(1, countType(log2, FriendsModel.EVENT_ALERT_WINDOW));
		Assert.equals(0, countType(log2, FriendsModel.EVENT_REFRESH_PAGE));
		Assert.isNull(reject.friendListFilter);

		// 错误应答 → error 窗；空 direction → alertWindow 门内不派发（:1224）
		reject.onFriendFilterOpError(voEvent(CommandDefs.CMD_ADD_FRIEND_FILTER, {}, {direction: "操作失败"}));
		var errAlert = lastData(log2, FriendsModel.EVENT_ALERT_WINDOW);
		Assert.equals("error", Reflect.field(errAlert, "type")); // :654
		Assert.equals("操作失败", Reflect.field(errAlert, "text"));
		reject.onFriendFilterOpError(voEvent(CommandDefs.CMD_ADD_FRIEND_FILTER, {}, {direction: ""}));
		Assert.equals(2, countType(log2, FriendsModel.EVENT_ALERT_WINDOW));
	}

	// :1252-1271 removeFilter 应答 code==1（int，与 add 的 "1" 字面量不对称，
	// 照抄）→ 删表键 + 重排（保留极性 → 表内剩下的继续显示）；code 不对全不动
	public function test_removeFilter_success_deletes_and_relists() {
		var fA = mkFriend(303, 303, 1, 1.0, "甲");
		var fB = mkFriend(304, 304, 2, 2.0, "乙");
		model.m_friendList = [fA, fB];
		model.m_friendListFilter = obj([["303", 1], ["304", 1]]);
		var log:Array<Dynamic> = [];
		listen(log);

		model.onRemoveFriendFilterSuccess(voEvent(CommandDefs.CMD_REMOVE_FRIEND_FILTER, {},
			{code: 1, direction: "已恢复显示", uId: 303}));

		Assert.equals(1, countType(log, FriendsModel.EVENT_ALERT_WINDOW));
		Assert.equals("已恢复显示", Reflect.field(firstData(log, FriendsModel.EVENT_ALERT_WINDOW), "text"));
		Assert.isFalse(Reflect.hasField(model.friendListFilter, "303")); // :1266
		Assert.equals(1, model.m_friendList.length); // "304" 仍在表 → 只剩 fB
		Assert.equals(fB, model.m_friendList[0]);

		var reject = freshModel();
		var log2:Array<Dynamic> = [];
		listenModel(reject, log2);
		reject.onRemoveFriendFilterSuccess(voEvent(CommandDefs.CMD_REMOVE_FRIEND_FILTER, {},
			{code: 2, direction: "x", uId: 303}));
		Assert.equals(0, log2.length); // :1260 code 门
	}

	// :270-324 loadFriendsData 门位链（checkServerDown :561-570 →
	// forbidden :1468-1480 → openByFlashVar :1445-1466）：xb 停机文案 →
	// DataFailed；friend_list 区间命中 → FriendListForbid；useflag 关位
	//（非 qzone 取十位、qzone 取个位）→ FriendListForbid 带 friend_list_tips_2
	// 文案；全开 → DataLoading(true) + 缓存不可用走网络分支
	//（m_updateFriendCache=true，theApp null no-op）
	public function test_loadFriendsData_gates_serverdown_forbidden_useflag() {
		var log:Array<Dynamic> = [];
		listen(log);

		// xb 停机
		Settings.getInstance().loadLocalSettings({xb: "停机维护中"});
		model.loadFriendsData();
		Assert.equals(1, countType(log, FriendsModel.EVENT_DATA_LOAD_FAILED)); // :566
		Assert.equals("停机维护中", Reflect.field(firstData(log, FriendsModel.EVENT_DATA_LOAD_FAILED), "error"));
		Assert.equals(0, countType(log, FriendsModel.EVENT_DATA_LOADING));

		// forbidden：friend_list 区间命中（FeartureManager.friendListMod 按
		// hostId%mod 落区间，Settings 空配时恒 false，这里配区间强制命中）
		Settings.getInstance().loadLocalSettings({friend_list: "0-100", friend_list_mod_xy: "101", friend_list_tips: "好友列表暂不开放"});
		model.loadFriendsData();
		Assert.equals(1, countType(log, FriendsModel.EVENT_FUNCTION_FORBIDDEN)); // :1473
		var forbid = firstData(log, FriendsModel.EVENT_FUNCTION_FORBIDDEN);
		Assert.equals("tip", Reflect.field(forbid, "type")); // Consts.ALERT_TYPE_TIP（Consts.as:222）
		Assert.equals("好友列表暂不开放", Reflect.field(forbid, "text"));
		Assert.equals(0, countType(log, FriendsModel.EVENT_DATA_LOADING));

		// useflag 关：非 qzone 取十位（"0" → 0）
		Settings.getInstance().loadLocalSettings({useflag: "0"});
		model.loadFriendsData();
		Assert.equals(2, countType(log, FriendsModel.EVENT_FUNCTION_FORBIDDEN));
		var closed = lastData(log, FriendsModel.EVENT_FUNCTION_FORBIDDEN);
		Assert.equals("tip", Reflect.field(closed, "type")); // :1459-1462
		Assert.equals("", Reflect.field(closed, "text")); // friend_list_tips_2 未配 → 空串
		Assert.equals(0, countType(log, FriendsModel.EVENT_DATA_LOADING));

		// useflag 缺省（"" → parseInt NaN → 位值非真）也关
		model.loadFriendsData();
		Assert.equals(3, countType(log, FriendsModel.EVENT_FUNCTION_FORBIDDEN));

		// useflag 开：非 qzone "10" → 十位 1 → 放行到网络分支
		Settings.getInstance().loadLocalSettings({useflag: "10"});
		model.loadFriendsData();
		Assert.equals(1, countType(log, FriendsModel.EVENT_DATA_LOADING)); // :284
		Assert.isTrue(firstData(log, FriendsModel.EVENT_DATA_LOADING) == true);
		Assert.isTrue(model.m_updateFriendCache == true); // :317 缓存不可用分支

		// qzone 模式取个位："10" 个位 0 → 关
		Settings.getInstance().loadLocalSettings({mode: "1", useflag: "10"});
		model.loadFriendsData();
		Assert.equals(4, countType(log, FriendsModel.EVENT_FUNCTION_FORBIDDEN));
		// "11" 个位 1 → 开
		Settings.getInstance().loadLocalSettings({mode: "1", useflag: "11"});
		model.loadFriendsData();
		Assert.equals(2, countType(log, FriendsModel.EVENT_DATA_LOADING));
	}

	// :451-491 refreshFriendStatus：列表 null 早退；健康模式直走
	// onFriendStatusLoaded(null)；param=false 且状态表已装 → 裸 status 表
	// 复用（getVOData 对非 VO/Array result 取 null → 不重读表，引用不动）
	public function test_refreshFriendStatus_healthmode_and_cached_reuse() {
		var log:Array<Dynamic> = [];
		listen(log);
		model.refreshFriendStatus(false); // :455-456 null 列表
		Assert.equals(0, log.length);

		var fA = mkFriend(101, 101, 1, 1.0, "甲");
		model.m_friendList = [fA];
		Session.getInstance().healthModeValid = true;
		model.refreshFriendStatus(false); // :459-462
		Assert.isTrue(model.m_gotFriendStatus == true);
		// :330 + processFriendList :917 两处 DataLoading(false) + RefreshPage
		Assert.equals(2, countType(log, FriendsModel.EVENT_DATA_LOADING));
		Assert.isFalse(firstData(log, FriendsModel.EVENT_DATA_LOADING) == true);
		Assert.equals(1, countType(log, FriendsModel.EVENT_REFRESH_PAGE));
		Session.getInstance().healthModeValid = false;

		// 复用：状态表引用不变（:470-472 裸表作 result，getVOData 取 null →
		// :334-341 不重读；:342 specialProcessStatus 对无 "6" 的表是 no-op）
		var stRef = obj([["101", obj([["2", 1]])]]);
		model.m_friendStatus = stRef;
		model.m_gotFriendStatus = false;
		var before = log.length;
		model.refreshFriendStatus(false); // :468-473
		Assert.isTrue(model.m_friendStatus == stRef); // 不重读不重排键
		Assert.isTrue(model.m_gotFriendStatus == true);
		Assert.equals(before + 3, log.length); // :330 + :917 + RefreshPage
		Assert.isFalse(lastData(log, FriendsModel.EVENT_DATA_LOADING) == true);

		// param=true → 跳过复用走请求（theApp null no-op），多 DataLoading(true)
		var before2 = log.length;
		model.refreshFriendStatus(true); // :475-490
		Assert.equals(before2 + 1, log.length);
		Assert.isTrue(lastData(log, FriendsModel.EVENT_DATA_LOADING) == true);
	}

	// :586-627 loadFriendStatus：健康模式早退不落 m_friendListLocal；
	// 正常路径首调用把参数列表存进 m_friendListLocal（引用）且只存一次；
	// 状态表已装 + param2=false → 复用；param2=true 强制走请求
	public function test_loadFriendStatus_local_caching_and_reuse() {
		var fA = mkFriend(101, 101, 1, 1.0, "甲");
		var fB = mkFriend(102, 102, 2, 2.0, "乙");
		var log:Array<Dynamic> = [];
		listen(log);

		Session.getInstance().healthModeValid = true; // :590-594 健康模式先于
		model.loadFriendStatus([fA]); // m_friendListLocal 赋值（:599-601 之后）
		Assert.isNull(model.friendListLocal);
		Assert.isTrue(model.m_gotFriendStatus == true);
		Session.getInstance().healthModeValid = false;

		model.loadFriendStatus([fA, fB]); // 首调用：落 local + 请求 no-op
		Assert.equals(2, model.friendListLocal.length); // :599-601
		Assert.equals(fA, model.friendListLocal[0]);
		Assert.equals(1, countType(log, FriendsModel.EVENT_DATA_LOADING));
		Assert.isTrue(firstData(log, FriendsModel.EVENT_DATA_LOADING) == true); // :621

		var log2:Array<Dynamic> = [];
		listen(log2);
		var stRef = obj([["101", obj([["2", 1]])]]);
		model.m_friendStatus = stRef;
		model.loadFriendStatus([fA], false); // :603-608 复用 → onFriendStatusLoaded
		// :330 + processFriendList :917 两处 DataLoading(false) + RefreshPage
		Assert.equals(2, countType(log2, FriendsModel.EVENT_DATA_LOADING));
		Assert.isFalse(firstData(log2, FriendsModel.EVENT_DATA_LOADING) == true);
		Assert.equals(1, countType(log2, FriendsModel.EVENT_REFRESH_PAGE));
		Assert.isTrue(model.m_gotFriendStatus == true);

		// 已有 local 后再传不同列表：保持首次引用（:599 null 门）
		var fC = mkFriend(103, 103, 3, 3.0, "丙");
		model.loadFriendStatus([fC]);
		Assert.equals(2, model.friendListLocal.length);
		Assert.equals(fA, model.friendListLocal[0]);

		// param2=true：跳过复用强制请求
		var log3:Array<Dynamic> = [];
		listen(log3);
		model.loadFriendStatus([fA], true);
		Assert.isTrue(firstData(log3, FriendsModel.EVENT_DATA_LOADING) == true);
	}

	// :1234-1245 getFriendByID：按 _uin 查列表；查无/null 列表返回 null
	//（for-each(null) 零迭代）
	public function test_getFriendByID_uin_lookup() {
		var f = mkFriend(55, 55, 1, 1.0, "甲");
		var g = mkFriend(66, 66, 2, 2.0, "乙");
		model.m_friendList = [f, g];
		Assert.equals(g, model.getFriendByID(66));
		Assert.equals(f, model.getFriendByID(55));
		Assert.isTrue(model.getFriendByID(99) == null);
		model.m_friendList = null;
		Assert.isTrue(model.getFriendByID(55) == null);
	}

	// —— 工具 ——

	// 数字字符串键的 AS3 Object 形态（cgi_farm_getstatus_filter 的 JSON 键是
	// uid 字符串；AS3 obj[101] 按 "101" 命中，按同形态喂）
	static function obj(pairs:Array<Array<Dynamic>>):Dynamic {
		var o:Dynamic = {};
		for (p in pairs) {
			Reflect.setField(o, p[0], p[1]);
		}
		return o;
	}

	function mkFriend(uin:UInt, uId:UInt, exp:Int, money:Float, name:String):Friend {
		var f = new Friend(null);
		f._uin = uin;
		f._uId = uId;
		f._exp = exp;
		f._money = money;
		f._userName = name;
		f._headPic = "";
		return f;
	}

	// i=1..count，名字 prefix + 两位零垫（g01..g25）；exp=i 互异保排序确定
	function mkNamedFriends(count:Int, prefix:String):Array<Dynamic> {
		var out:Array<Dynamic> = [];
		for (i in 1...count + 1) {
			var idx = i < 10 ? "0" + i : "" + i;
			out.push(mkFriend(i, i, i, i * 1.0, prefix + idx));
		}
		return out;
	}

	// 六类事件全收进一个 log：{type, data}；对同一 model 多次 listen 会各收
	// 一份（按段用新 log 分阶段断言）
	function listen(log:Array<Dynamic>):Void {
		listenModel(model, log);
	}

	static function listenModel(m:FriendsModel, log:Array<Dynamic>):Void {
		m.addEventListener(FriendsModel.EVENT_DATA_LOADING,
			function(e:Event) log.push({type: FriendsModel.EVENT_DATA_LOADING, data: cast(e, CommonEvent).data}));
		m.addEventListener(FriendsModel.EVENT_DATA_LOAD_FAILED,
			function(e:Event) log.push({type: FriendsModel.EVENT_DATA_LOAD_FAILED, data: cast(e, CommonEvent).data}));
		m.addEventListener(FriendsModel.EVENT_FUNCTION_FORBIDDEN,
			function(e:Event) log.push({type: FriendsModel.EVENT_FUNCTION_FORBIDDEN, data: cast(e, CommonEvent).data}));
		m.addEventListener(FriendsModel.EVENT_REFRESH_PAGE,
			function(e:Event) log.push({type: FriendsModel.EVENT_REFRESH_PAGE, data: cast(e, CommonEvent).data}));
		m.addEventListener(FriendsModel.EVENT_ALERT_WINDOW,
			function(e:Event) log.push({type: FriendsModel.EVENT_ALERT_WINDOW, data: cast(e, CommonEvent).data}));
		m.addEventListener(FriendsModel.EVENT_HEAD_PIC_LOADED,
			function(e:Event) log.push({type: FriendsModel.EVENT_HEAD_PIC_LOADED, data: cast(e, CommonEvent).data}));
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

	static function lastData(log:Array<Dynamic>, type:String):Dynamic {
		var out = null;
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				out = Reflect.field(entry, "data");
			}
		}
		return out;
	}

	static function allData(log:Array<Dynamic>, type:String):Array<Dynamic> {
		var out:Array<Dynamic> = [];
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				out.push(Reflect.field(entry, "data"));
			}
		}
		return out;
	}

	// 应答事件：body 用 Utils.buildRequest 造出与 NetHelper.sendRequest →
	// theApp.run 真实链路同构的 {cmdID, __body, __format}；result 装入
	// ServiceResultVO（getVOData 的 m_extra 分支）。同 MessageModelTest。
	static function voEvent(cmd:Int, reqParams:Dynamic, payload:Dynamic):CommandEvent {
		var vo = new ServiceResultVO();
		vo.m_extra = payload;
		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.body = Utils.buildRequest(cmd, reqParams);
		ev.result = vo;
		return ev;
	}
}
