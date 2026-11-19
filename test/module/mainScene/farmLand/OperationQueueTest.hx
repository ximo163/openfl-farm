package module.mainScene.farmLand;

import com.qzone.qfa.events.CommandEvent;
import framework.net.CommandDefs;
import framework.net.vo.ServiceResultVO;
import utest.Assert;

/**
 * OperationQueue 的合批/派发纯逻辑（issue #8）。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/
 * OperationQueue.as（ctor 定时器 :45-48、onOperateResponse :63-204、
 * delayRequest :238-252、onProcessResponseTimer :254-290；cmdID 路由 :84-103、
 * 成功项去重 :118-145、失败项方向合并 :146-198）。
 *
 * 不触网：构造用 60s 延迟（:45 的 delayRequestNow 不会在用例内触发），
 * 回包直接喂 onOperateResponse；展示节奏用 onProcessResponseTimer 手动步进。
 */
@:access(module.mainScene.farmLand.OperationQueue)
class OperationQueueTest {
	public function new() {}

	// 回包事件：body.cmdID（:71）+ result.m_extra（:73）
	static function responseEvent(cmdID:UInt, extra:Dynamic):CommandEvent {
		var vo = new ServiceResultVO();
		vo.m_extra = extra;
		var evt = new CommandEvent(CommandEvent.COMPLETE, null, {"cmdID": cmdID});
		evt.result = vo;
		return evt;
	}

	// 手动步进展示定时器直至自停（空轮 :284-289），收集 :275-278 派发的
	// {cmd, data}（每 tick 每个非空槽 shift 一条，:274）
	static function drain(queue:OperationQueue):Array<Dynamic> {
		var events:Array<Dynamic> = [];
		queue.addEventListener(OperationQueue.EVENT_OPERATE_SUCCES, function(e) events.push(e.data));
		while (queue.m_showByTimer != null && queue.m_showByTimer.running) {
			queue.onProcessResponseTimer(null);
		}
		return events;
	}

	// 用例收尾不留守计时器（eval 的定时器在 main 返回后仍会触发）
	static function stopTimers(queue:OperationQueue):Void {
		if (queue.m_delayRequestTimer != null) {
			queue.m_delayRequestTimer.stop();
		}
		if (queue.m_showByTimer != null) {
			queue.m_showByTimer.stop();
		}
	}

	// delayRequest :240-252：空槽首参按引用存入（:242）；同槽再进只并入 place
	//（逗号连接改写存量，:246）；延迟定时器未运行则启动（:248-251）
	public function test_delayRequest_stores_by_reference_and_merges_place() {
		var queue = new OperationQueue(60000);
		var first:Dynamic = {place: "1"};
		queue.delayRequest(OperationQueue.ADD_WEED, first);
		Assert.equals(first, queue.m_requestQueue[OperationQueue.ADD_WEED]); // :242 存引用
		Assert.isTrue(queue.m_delayRequestTimer.running); // :250
		queue.delayRequest(OperationQueue.ADD_WEED, {place: "2"});
		Assert.equals("1,2", Reflect.field(queue.m_requestQueue[OperationQueue.ADD_WEED], "place")); // :246
		queue.delayRequest(OperationQueue.ADD_WEED, {place: "5"});
		Assert.equals("1,2,5", Reflect.field(queue.m_requestQueue[OperationQueue.ADD_WEED], "place"));
		stopTimers(queue);
	}

	// :240-252：四个操作槽互不影响（每次只动 param1 指的槽）
	public function test_delayRequest_slots_are_independent() {
		var queue = new OperationQueue(60000);
		queue.delayRequest(OperationQueue.ADD_WEED, {place: "1"});
		queue.delayRequest(OperationQueue.ADD_BUG, {place: "7"});
		Assert.equals("1", Reflect.field(queue.m_requestQueue[OperationQueue.ADD_WEED], "place"));
		Assert.equals("7", Reflect.field(queue.m_requestQueue[OperationQueue.ADD_BUG], "place"));
		Assert.isNull(queue.m_requestQueue[OperationQueue.CLEAR_WEED]);
		Assert.isNull(queue.m_requestQueue[OperationQueue.CLEAR_BUG]);
		stopTimers(queue);
	}

	// onOperateResponse :84-103 cmdID→槽位（ADDWEED 12 → ADD_WEED）、:200-203
	// 启动展示定时器、onProcessResponseTimer :274-278 逐条派发 {cmd, data}
	public function test_addweed_response_routes_to_slot_and_dispatches_items() {
		var queue = new OperationQueue(60000);
		queue.onOperateResponse(responseEvent(CommandDefs.CMD_OPERATE_ADDWEED, [
			{farmlandIndex: 0, code: 0, poptype: 0},
			{farmlandIndex: 4, code: 0, poptype: 0}
		]));
		var events = drain(queue);
		Assert.equals(2, events.length); // 每 tick 每槽一条，共两轮
		Assert.equals(OperationQueue.ADD_WEED, Reflect.field(events[0], "cmd"));
		Assert.equals(0, Reflect.field(Reflect.field(events[0], "data"), "farmlandIndex"));
		Assert.equals(4, Reflect.field(Reflect.field(events[1], "data"), "farmlandIndex"));
		stopTimers(queue);
	}

	// :118-145：code==0 且 farmlandIndex+code+poptype 全同 → 不重复入列，
	// 存量对象 error_repeat 置 1（:134-137 首次）；farmlandIndex 不同正常追加
	public function test_success_items_dedup_by_land_with_error_repeat() {
		var queue = new OperationQueue(60000);
		queue.onOperateResponse(responseEvent(CommandDefs.CMD_OPERATE_ADDWEED, [
			{farmlandIndex: 2, code: 0, poptype: 0}
		]));
		queue.onOperateResponse(responseEvent(CommandDefs.CMD_OPERATE_ADDWEED, [
			{farmlandIndex: 2, code: 0, poptype: 0},
			{farmlandIndex: 3, code: 0, poptype: 0}
		]));
		var events = drain(queue);
		Assert.equals(2, events.length); // 地 2 只留一条 + 地 3 一条
		Assert.equals(2, Reflect.field(Reflect.field(events[0], "data"), "farmlandIndex"));
		Assert.equals(1, Reflect.field(Reflect.field(events[0], "data"), "error_repeat")); // :136
		Assert.equals(3, Reflect.field(Reflect.field(events[1], "data"), "farmlandIndex"));
		stopTimers(queue);
	}

	// :146-198：code!=0 按 farmlandIndex 对齐 + 槽位方向合并——ADD_WEED 取
	// weed 更大者（:155-161），命中时 money/exp 累加进存量（:185-186）、
	// levelUp 只升不降（:187-191）
	public function test_addweed_error_items_merge_taking_larger_weed() {
		var queue = new OperationQueue(60000);
		queue.onOperateResponse(responseEvent(CommandDefs.CMD_OPERATE_ADDWEED, [
			{farmlandIndex: 1, code: 2, poptype: 1, weed: 2, money: 1, exp: 1, levelUp: false}
		]));
		queue.onOperateResponse(responseEvent(CommandDefs.CMD_OPERATE_ADDWEED, [
			{farmlandIndex: 1, code: 2, poptype: 1, weed: 3, money: 2, exp: 2, levelUp: true}
		]));
		var events = drain(queue);
		Assert.equals(1, events.length); // weed 3>=2 命中合并，不另立
		var merged = Reflect.field(events[0], "data");
		Assert.equals(3, Reflect.field(merged, "weed")); // :159 取更大
		Assert.equals(3, Reflect.field(merged, "money")); // :185 1+2
		Assert.equals(3, Reflect.field(merged, "exp")); // :186
		Assert.isTrue(Reflect.field(merged, "levelUp")); // :187-190
		stopTimers(queue);
	}

	// :162-168 CLEAR_WEED 方向相反（weed 更小才命中）；不命中另立一条
	//（:194-197），存量不被新回包的奖励覆盖
	public function test_clearweed_error_items_keep_strictly_smaller_weed() {
		var queue = new OperationQueue(60000);
		queue.onOperateResponse(responseEvent(CommandDefs.CMD_OPERATE_CLEARWEED, [
			{farmlandIndex: 0, code: 1, poptype: 1, weed: 2, money: 1, exp: 1, levelUp: false}
		]));
		queue.onOperateResponse(responseEvent(CommandDefs.CMD_OPERATE_CLEARWEED, [
			{farmlandIndex: 0, code: 1, poptype: 1, weed: 5, money: 9, exp: 9, levelUp: true}
		]));
		var events = drain(queue);
		Assert.equals(2, events.length); // 5<=2 不成立 → 另立
		var kept = Reflect.field(events[0], "data");
		Assert.equals(2, Reflect.field(kept, "weed"));
		Assert.equals(1, Reflect.field(kept, "money")); // 未并入
		var added = Reflect.field(events[1], "data");
		Assert.equals(5, Reflect.field(added, "weed"));
		stopTimers(queue);
	}

	// 早退族：m_extra null（:73-77）、errorType 回包（:79-82 + :104-108）、
	// 未知 cmdID（:104-108）都不入列不派发；CLEARBUG 14 → CLEAR_BUG 槽
	//（:99-103）作对照
	public function test_guards_and_clearbug_slot() {
		var queue = new OperationQueue(60000);
		queue.onOperateResponse(responseEvent(CommandDefs.CMD_OPERATE_CLEARBUG, [
			{farmlandIndex: 5, code: 0, poptype: 0}
		]));
		var events = drain(queue);
		Assert.equals(1, events.length);
		Assert.equals(OperationQueue.CLEAR_BUG, Reflect.field(events[0], "cmd"));
		Assert.equals(5, Reflect.field(Reflect.field(events[0], "data"), "farmlandIndex"));

		queue.onOperateResponse(responseEvent(CommandDefs.CMD_OPERATE_ADDBUG, null)); // :73-77
		queue.onOperateResponse(responseEvent(CommandDefs.CMD_OPERATE_ADDBUG, {errorType: 1})); // :79-108
		queue.onOperateResponse(responseEvent(999, [{farmlandIndex: 0, code: 0, poptype: 0}])); // :104
		var more = drain(queue);
		Assert.equals(0, more.length);
		stopTimers(queue);
	}
}
