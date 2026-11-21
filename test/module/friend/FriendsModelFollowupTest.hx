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
 * FriendsModel 修正断言（issue #20 implement 阶段补充）：FriendsModelTest
 * 三处期望值与其同用例内**已通过的断言**自相矛盾，原版行为（反编译逐句）
 * 与实现一致，按 NEEDS-TESTS 协议把修正后的期望钉在本文件——原文件是
 * 已审核测试不改，等下一轮 write-tests 修 :379/:845/:1149 并注册本文件。
 *
 * 三处矛盾（引用行为均为 FriendsModel.as 原文，本实现逐句照译）：
 * - FriendsModelTest.hx:379 期望回卷后再 goBackPage 派发 index 2，但其
 *   :377 已断言 goNextPage :580-582 回卷页=1；:359-377 从页 1 走
 *   `page-1 > 0` 恒假不派发。作者注释「3→2→1」说明本意是从页 3 起退，
 *   漏钉了页。本文件补「页 1 早退」与「钉回 3 后 3→2→1」两条。
 * - FriendsModelTest.hx:845 期望 fOther._exp == 5（"别人不动"），但
 *   fOther 创建 exp=3，5 是 fMe 的创建值（笔误）；:522-537 同步只对
 *   `_uId == host._uId` 行写 host 的 exp/money，别人保持创建值——同文件
 *   :854 别名用例正是按创建值 11 断言的。本文件按 3 钉。
 * - FriendsModelTest.hx:1149 期望复用后 friendListLocal[0] == fA，但其
 *   :1139-1141 已断言复用路径跑了 processFriendList（RefreshPage 只有它
 *   派发）；:352-355 恰把 m_friendListLocal 传入，:918 原地 sort，按
 *   friendSort :1160 exp 降序 → [fA(1),fB(2)] 变 [fB,fA]。作者验证「:599
 *   null 门保持首次引用」的意图正确，索引 0 应是 fB。本文件按 fB 钉并
 *   补引用恒等断言。
 *
 * 环境口径同 FriendsModelTest（theApp null 请求 no-op、Cookie 未初始化、
 * EventRecorder DISABLED、QzoneJSAPI.WB false、serverTime=0、mode ""）。
 * 注册待 write-tests 阶段（lessons「implement 阶段不能动 TestMain.hx」：
 * TestMain 末尾 `// 新测试文件在这里注册`）。
 */
@:access(module.friend.FriendsModel)
class FriendsModelFollowupTest {
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
		Settings.getInstance().loadLocalSettings(null); // mode 复位 ""
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

	// :572-584 回卷后页=1：:371 `page-1 > 0` 恒假 → goBackPage 不派发；
	// 作者原意的 3→2→1 需先把页钉回 3（FriendsModelTest.hx:379 的修正）
	public function test_goBackPage_after_wrap_is_noop() {
		model.m_friendList = mkNamedFriends(25, "g"); // ceil(25/10)=3 页
		var log:Array<Dynamic> = [];
		listen(log);
		model._showFriendPage = 1;
		model.goNextPage(); // :575-578 → 2
		model.goNextPage(); // → 3
		model.goNextPage(); // :580-582 回卷 1
		Assert.equals(1, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));
		Assert.equals(1, model._showFriendPage);
		var before = log.length;
		model.goBackPage(); // :371-376 页 1 早退，不派发
		Assert.equals(before, log.length);
		Assert.equals(1, model._showFriendPage);

		// 漏钉的页补上后，:371-376 的 3→2→1 序列按原意可走通
		model._showFriendPage = 3;
		model.goBackPage();
		Assert.equals(2, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));
		model.goBackPage();
		Assert.equals(1, Reflect.field(lastData(log, FriendsModel.EVENT_REFRESH_PAGE), "index"));
		var before2 = log.length;
		model.goBackPage(); // 页 1 早退
		Assert.equals(before2, log.length);
	}

	// :522-537 有自己时同步只写 _uId 对上的行（host 的 exp/money），别的行
	// 保持创建值——FriendsModelTest.hx:845 的 5 是 fMe 创建值的笔误，按 3 钉
	public function test_onFriendsDataLoaded_sync_leaves_other_rows_untouched() {
		var fMe = mkFriend(1, 1, 5, 9.0, "我");
		var fOther = mkFriend(2, 2, 3, 3.0, "乙");
		model.onFriendsDataLoaded(voEvent(CommandDefs.CMD_GET_FRIENDLIST, {}, [fMe, fOther]));
		Assert.equals(2, model.m_friendListNet.length); // hasMe → 不补行
		Assert.equals(100, fMe._exp); // :532
		Assert.equals(50.0, fMe._money); // :533
		Assert.equals(3, fOther._exp); // 别人不动：创建值原样（:530 只对 _uId）
		Assert.equals(3.0, fOther._money);
	}

	// :603-608 状态表复用 → onFriendStatusLoaded :352-355 把 local 传入
	// processFriendList → :918 原地按 friendSort :1160 exp 降序排序：
	// [fA(1),fB(2)] → [fB,fA]；:599 null 门保持首次引用不换列表
	//（FriendsModelTest.hx:1149 的修正：local[0] 是 fB 不是 fA）
	public function test_loadFriendStatus_reuse_sorts_local_in_place() {
		var fA = mkFriend(101, 101, 1, 1.0, "甲");
		var fB = mkFriend(102, 102, 2, 2.0, "乙");
		model.loadFriendStatus([fA, fB]); // 首调用落 local（:599-601），未排序
		Assert.equals(fA, model.friendListLocal[0]);
		Assert.equals(fB, model.friendListLocal[1]);

		var log2:Array<Dynamic> = [];
		listen(log2);
		var stRef = obj([["101", obj([["2", 1]])]]);
		model.m_friendStatus = stRef;
		model.loadFriendStatus([fA], false); // :603-608 复用 → onFriendStatusLoaded
		// :330 + :917 两处 DataLoading{false}；RefreshPage 证明 processFriendList 已跑
		Assert.equals(2, countType(log2, FriendsModel.EVENT_DATA_LOADING));
		Assert.equals(1, countType(log2, FriendsModel.EVENT_REFRESH_PAGE));
		Assert.equals(fB, model.friendListLocal[0]); // 降序排序原地在 local 上生效
		Assert.equals(fA, model.friendListLocal[1]);

		// :599 null 门：已有 local 再传新列表不换引用（作者原意，按引用恒等钉）
		var fC = mkFriend(103, 103, 3, 3.0, "丙");
		var ref = model.friendListLocal;
		model.loadFriendStatus([fC]);
		Assert.isTrue(model.friendListLocal == ref);
		Assert.equals(2, model.friendListLocal.length);
		Assert.equals(fB, model.friendListLocal[0]);
	}

	// —— 与 FriendsModelTest 同款的起手/辅助 ——

	static function freshModel():FriendsModel {
		var m = new FriendsModel();
		m._showFriendPage = 1; // AS3 ctor :77
		m.m_sortField = "exp"; // :79
		m.m_searchFriendValue = ""; // :80
		return m;
	}

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

	function mkNamedFriends(count:Int, prefix:String):Array<Dynamic> {
		var out:Array<Dynamic> = [];
		for (i in 1...count + 1) {
			var idx = i < 10 ? "0" + i : "" + i;
			out.push(mkFriend(i, i, i, i * 1.0, prefix + idx));
		}
		return out;
	}

	static function voEvent(cmd:Int, reqParams:Dynamic, payload:Dynamic):CommandEvent {
		var vo = new ServiceResultVO();
		vo.m_extra = payload;
		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.body = Utils.buildRequest(cmd, reqParams);
		ev.result = vo;
		return ev;
	}

	function listen(log:Array<Dynamic>):Void {
		model.addEventListener(FriendsModel.EVENT_DATA_LOADING,
			function(e:Event) log.push({type: FriendsModel.EVENT_DATA_LOADING, data: cast(e, CommonEvent).data}));
		model.addEventListener(FriendsModel.EVENT_DATA_LOAD_FAILED,
			function(e:Event) log.push({type: FriendsModel.EVENT_DATA_LOAD_FAILED, data: cast(e, CommonEvent).data}));
		model.addEventListener(FriendsModel.EVENT_FUNCTION_FORBIDDEN,
			function(e:Event) log.push({type: FriendsModel.EVENT_FUNCTION_FORBIDDEN, data: cast(e, CommonEvent).data}));
		model.addEventListener(FriendsModel.EVENT_REFRESH_PAGE,
			function(e:Event) log.push({type: FriendsModel.EVENT_REFRESH_PAGE, data: cast(e, CommonEvent).data}));
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
		var out = null;
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				out = Reflect.field(entry, "data");
			}
		}
		return out;
	}
}
