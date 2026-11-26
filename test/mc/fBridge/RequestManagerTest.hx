package mc.fBridge;

import common.CommonData;
import mc.fBridge.RequestManager;
import utest.Assert;

/**
 * mc.fBridge.RequestManager 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 偷菜/进好友牧场的错误次数熔断。errTotal=3 次后按 serverTime 封禁
 * 5+random*5 分钟（向下取整），checkAction 文案按剩余秒数上取整出分钟。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/FBridge/RequestManager.as
 * —— addAction :60-73（errNum 自增、>=errTotal 且 blocking==0 时封禁
 * blocking=serverTime+floor(5+random*5)*60）；checkAction :84-122（ENTER
 * 查 uinList、其余查 actList；封禁中 → "系统太忙，建议"+ceil(余秒/60)+
 * "分钟后再试。"（ENTER 变体 "分钟后再访问该好友。"）；封禁过期且
 * errNum>=errTotal → reset）；addUin :124-144（无记录时建 {errNum:1,
 * blocking:0}）；errTotal 初值 :25（=3）。
 *
 * 随机性边界：floor(5+random*5) ∈ [5,9]，测试断言 blocking-serverTime 落
 * [300,540] 区间而不是定值；分钟文案同理用 blocking 反推 ceil 值。
 * SharedObject 持久化通道（localData.setObject）在 stub 期掷
 * not implemented——addAction/addUin/registerAction 路径都过它，本测试
 * 的调用形态必然等 implement 充真身才绿（write-tests 的意图即如此）。
 * serverTime 走 CommonData.serverTime 注入（setter 存锚点+getTimer 漂移，
 * 测试用远大锚点值、秒级漂移不影响区间断言）。
 *
 * 时间窗边界值推导：blocking = serverTime+300（5 分钟下限）时，
 * ceil((blocking-serverTime)/60) = ceil(300/60) = 5；450 秒 → ceil(7.5)=8。
 */
@:access(mc.fBridge.RequestManager)
class RequestManagerTest {
	public function new() {}

	function setup() {
		CommonData.serverTime = 1700000000; // 远大锚点，秒级漂移不进位
	}

	function freshManager():RequestManager {
		// 单例态跨测试污染——重置内部表单（测试专用的状态隔离，
		// 不改产品代码）：actList/uinList 原文初值即 {}（:17/:23）
		var rm = RequestManager.getInstance();
		rm.actList = {};
		rm.uinList = {};
		return rm;
	}

	// errTotal 初值 3（RequestManager.as:25）
	public function test_errTotal_default_is_3() {
		Assert.equals(3, freshManager().errTotal);
	}

	// addUin 首调建记录 {errNum:1, blocking:0}（:124-144 else 分支）
	public function test_addUin_first_creates_record() {
		var rm = freshManager();
		rm.addUin("12345");
		Assert.equals(1, Reflect.field(Reflect.field(rm.uinList, "12345"), "errNum"));
		Assert.equals(0, Reflect.field(Reflect.field(rm.uinList, "12345"), "blocking"));
	}

	// addUin 累加到 errTotal 触发封禁：blocking = serverTime +
	// floor(5+random*5)*60 ∈ [serverTime+300, serverTime+540]
	// （:132-136——floor(5+random*5)∈[5,9]）
	public function test_addUin_third_error_blocks() {
		var rm = freshManager();
		var t = CommonData.serverTime;
		rm.addUin("12345");
		rm.addUin("12345");
		Assert.equals(0, Reflect.field(Reflect.field(rm.uinList, "12345"), "blocking")); // 第二次未达 errTotal
		rm.addUin("12345");
		var blocking:Float = Reflect.field(Reflect.field(rm.uinList, "12345"), "blocking");
		Assert.isTrue(blocking >= t + 300 && blocking <= t + 540 + 2, 'blocking=$blocking 应落 [t+300,t+540]（±2 秒漂移容忍）');
	}

	// checkAction ENTER 封禁中文案："系统太忙，建议N分钟后再访问该好友。"
	// （:96——ceil((blocking-serverTime)/60)）
	public function test_checkAction_enter_blocked_message() {
		var rm = freshManager();
		var t = CommonData.serverTime;
		Reflect.setField(rm.uinList, "999", {errNum: 3, blocking: t + 450}); // 直接布置封禁态
		var msg = rm.checkAction(RequestManager.ENTER, "999");
		Assert.equals("系统太忙，建议8分钟后再访问该好友。", msg); // ceil(450/60)=8
	}

	// checkAction 非 ENTER（steal）封禁中文案变体 "分钟后再试。"（:113）
	public function test_checkAction_steal_blocked_message() {
		var rm = freshManager();
		var t = CommonData.serverTime;
		Reflect.setField(rm.actList, "steal", {action: "steal", errNum: 3, blocking: t + 300});
		var msg = rm.checkAction(RequestManager.STEAL);
		Assert.equals("系统太忙，建议5分钟后再试。", msg); // ceil(300/60)=5
	}

	// 未封禁（无记录）→ null（:122 落穿）
	public function test_checkAction_unblocked_returns_null() {
		var rm = freshManager();
		Assert.isNull(rm.checkAction(RequestManager.STEAL));
		Assert.isNull(rm.checkAction(RequestManager.ENTER, "999"));
	}

	// 封禁过期且 errNum>=errTotal → 重置（errNum=0 blocking=0 后可再通）
	// （:118-121/:84-122 resetAction :42-58——actList 侧）
	public function test_checkAction_expired_block_resets() {
		var rm = freshManager();
		var t = CommonData.serverTime;
		Reflect.setField(rm.actList, "steal", {action: "steal", errNum: 5, blocking: t - 10}); // 已过期
		Assert.isNull(rm.checkAction(RequestManager.STEAL));
		Assert.equals(0, Reflect.field(Reflect.field(rm.actList, "steal"), "errNum"));
		Assert.equals(0, Reflect.field(Reflect.field(rm.actList, "steal"), "blocking"));
	}

	// uin 侧过期重置走 delete（resetUin :75-82——记录整个删掉）
	public function test_checkAction_expired_uin_deleted() {
		var rm = freshManager();
		var t = CommonData.serverTime;
		Reflect.setField(rm.uinList, "999", {errNum: 3, blocking: t - 10});
		Assert.isNull(rm.checkAction(RequestManager.ENTER, "999"));
		Assert.isFalse(Reflect.hasField(rm.uinList, "999"));
	}

	// 封禁中但 errNum<errTotal 不触发重置——封禁判定只看 blocking 时钟
	// （errNum 未达 3 但 blocking 未来时的边界形态：仍返回封禁文案）
	public function test_checkAction_blocking_clock_governs() {
		var rm = freshManager();
		var t = CommonData.serverTime;
		Reflect.setField(rm.actList, "steal", {action: "steal", errNum: 1, blocking: t + 60});
		Assert.equals("系统太忙，建议1分钟后再试。", rm.checkAction(RequestManager.STEAL));
	}

	// addAction 只对已注册动作生效（actList[param1]  falsy → 跳过，:62）
	public function test_addAction_unregistered_noop() {
		var rm = freshManager();
		rm.addAction("steal"); // 未 registerAction，actList 无 steal 键
		Assert.isFalse(Reflect.hasField(rm.actList, "steal"));
	}

	// addAction 已注册：errNum 自增、第三次封禁（:64-69）
	public function test_addAction_increments_and_blocks() {
		var rm = freshManager();
		var t = CommonData.serverTime;
		Reflect.setField(rm.actList, "steal", {action: "steal", errNum: 0, blocking: 0}); // registerAction 建成形态
		rm.addAction("steal");
		Assert.equals(1, Reflect.field(Reflect.field(rm.actList, "steal"), "errNum"));
		Assert.equals(0, Reflect.field(Reflect.field(rm.actList, "steal"), "blocking"));
		rm.addAction("steal");
		rm.addAction("steal");
		var blocking:Float = Reflect.field(Reflect.field(rm.actList, "steal"), "blocking");
		Assert.isTrue(blocking >= t + 300 && blocking <= t + 540 + 2, 'blocking=$blocking');
	}

	// 已封禁后再加错不重复展期（blocking != 0 守卫，:66）
	public function test_addAction_no_reblock_while_blocked() {
		var rm = freshManager();
		var t = CommonData.serverTime;
		Reflect.setField(rm.actList, "steal", {action: "steal", errNum: 3, blocking: t + 300});
		rm.addAction("steal");
		Assert.equals(t + 300, Reflect.field(Reflect.field(rm.actList, "steal"), "blocking")); // 原封禁不展期
		Assert.equals(4, Reflect.field(Reflect.field(rm.actList, "steal"), "errNum")); // errNum 照增
	}

	// resetAction 清零 errNum/blocking 并删 record（:42-58）
	public function test_resetAction_clears() {
		var rm = freshManager();
		var t = CommonData.serverTime;
		Reflect.setField(rm.actList, "steal", {action: "steal", errNum: 3, blocking: t + 300, record: true});
		rm.resetAction("steal");
		Assert.equals(0, Reflect.field(Reflect.field(rm.actList, "steal"), "errNum"));
		Assert.equals(0, Reflect.field(Reflect.field(rm.actList, "steal"), "blocking"));
		Assert.isFalse(Reflect.hasField(Reflect.field(rm.actList, "steal"), "record"));
	}
}
