package mc.control;

import mc.control.Command;
import mc.control.TaskCommand;
import mc.model.TaskData;
import support.McCommandEnv;
import utest.Assert;

/**
 * mc.control.TaskCommand 纯逻辑（issue #88 write-tests，对 stub 失败）：
 * cgi_up_task 接任务的请求拼装与应答四分支。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/control/TaskCommand.as
 * —— run :22-25（postRequest("cgi_up_task", {"act":1}, taskAccept)——
 * mod 出处 spec/protocol.json entries.mc.mods.cgi_up_task +
 * legacy/deploy/QFarmFlash/source/core/source/mc/mod/cgi_up_task.php:3
 * `$_REQUEST['act']==1` 接任务分支）；taskAccept :27-58（ecode==0 →
 * taskData.currentTask = {taskId:param1.task.taskId, taskFlag:1}——
 * taskFlag 恒字面量 1 :31；非零 ecode 三分支：hasOwnProperty("direction")
 * → floatWindow(direction)、否则 errorContent 分支、再否则兜底
 * "系统繁忙，请稍候重试。" :55）。
 *
 * floatWindow 属 MainCommand（本片另一被测类）——TaskCommand 应答的浮字
 * 面由 MainCommandTest 钉，本测试只钉 TaskData.currentTask 写入与请求拼装；
 * 应答回调经 McCommandEnv 截获回放（HTTPRequest 不出网）。
 * EventRecorder 是 no-qq-telemetry 体空通道（#87 决策族），不进断言。
 */
@:access(mc.model.TaskData)
class TaskCommandTest {
	var env:McCommandEnv;

	public function new() {}

	function setup() {
		env = new McCommandEnv();
		env.resetStatics();
		env.swapInRecorder();
		// TaskData 单例跨用例复位（TaskDataTest 同款）：currentTask 回
		// 原文初值 {taskId:1, taskFlag:2}（TaskData.as:20-23）
		var td = TaskData.getInstance();
		td._updata = null;
		td._currentTask = {"taskId": 1, "taskFlag": 2};
	}

	function teardown() {
		env.restoreRecorder();
		var td = TaskData.getInstance();
		td._updata = null;
		td._currentTask = {"taskId": 1, "taskFlag": 2};
	}

	// run（TaskCommand.as:22-25）：mod 串逐字 "cgi_up_task"、参数体仅
	// {"act":1} 一键（无 uId/无多余键）
	public function test_run_posts_cgi_up_task_with_act1() {
		Command.getInstance().taskCommand.run();
		Assert.equals(1, env.rec.postCount);
		Assert.equals("cgi_up_task", env.rec.postedUrl);
		Assert.equals(1, Reflect.field(env.rec.postedValue, "act"));
	}

	// taskAccept 成功分支（:28-35）：ecode==0 且 task 载荷在 →
	// currentTask = {taskId: 应答 task.taskId, taskFlag:1}——taskFlag
	// 不读应答，恒字面量 1（:31 逐字）
	public function test_taskAccept_success_writes_currentTask_flag1() {
		Command.getInstance().taskCommand.run();
		env.respond({ecode: 0, task: {taskId: 5, taskFlag: 9, foo: "x"}});
		var cur = TaskData.getInstance().currentTask;
		Assert.equals(5, Reflect.field(cur, "taskId"));
		Assert.equals(1, Reflect.field(cur, "taskFlag"));
	}

	// taskAccept 非零 ecode 三分支（:37-57）：direction 优先于
	// errorContent 优先于兜底——三分支都走 mainCommand.floatWindow，
	// 写入面在 MainCommandTest 钉；这里只钉**不写 currentTask**：
	// 失败路径 currentTask 保持 setup 的缺省 {taskId:1, taskFlag:2}
	public function test_taskAccept_failure_keeps_currentTask() {
		Command.getInstance().taskCommand.run();
		// 请求确实出网（负断言的载体——空 stub 不出网即失败；应答分派
		// 的前提成立）
		Assert.equals(1, env.rec.postCount);
		env.respond({ecode: 1, direction: "任务不存在"});
		var cur = TaskData.getInstance().currentTask;
		Assert.equals(1, Reflect.field(cur, "taskId"));
		Assert.equals(2, Reflect.field(cur, "taskFlag"));
	}

	// errorContent 分支（:44-48）与兜底分支（:50-55）同样不写 currentTask
	public function test_taskAccept_errorContent_and_fallback_keep_task() {
		Command.getInstance().taskCommand.run();
		Assert.equals(1, env.rec.postCount); // 出网前提（空 stub 即失败）
		env.respond({ecode: 2, errorContent: "服务异常"});
		var cur = TaskData.getInstance().currentTask;
		Assert.equals(1, Reflect.field(cur, "taskId"));
		Command.getInstance().taskCommand.run();
		Assert.equals(2, env.rec.postCount);
		env.respond({ecode: 3});
		cur = TaskData.getInstance().currentTask;
		Assert.equals(1, Reflect.field(cur, "taskId"));
		Assert.equals(2, Reflect.field(cur, "taskFlag"));
	}
}
