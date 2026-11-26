package mc.model;

import mc.model.TaskData;
import utest.Assert;

/**
 * mc.model.TaskData 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 牧场任务数据单例——常量面值、getInstance 同一性、currentTask 缺省
 * {taskId:1, taskFlag:2}、setter 派发 COMPLETE/TASKDATA_CHANGE。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/model/TaskData.as
 * —— 常量 :10-16（TASKDATA_CHANGE "taskDataChange" :10、COMPLETE
 * "complete" :12、TASK_DOING "taskDoing" :14、TASK_MAX 9 :16）；
 * _currentTask 初值 :20-23（{taskId:1, taskFlag:2}）；getInstance :35-42
 * （instance null 才 new）；updata setter :44-48（存 + 派 COMPLETE，
 * ModelEvent）；currentTask setter :50-54（存 + 派 TASKDATA_CHANGE，
 * ModelEvent）；getter :56-64（backing 直返）。
 *
 * 单例态跨测试污染：instance 静态持有——每个测试结尾经 @:access 复位
 * _updata/_currentTask 回缺省，避免顺序耦合。setter 在 stub 期 throw
 * not implemented——本测试必然等 implement 充真身才绿。
 */
@:access(mc.model.TaskData)
class TaskDataTest {
	var td:TaskData;

	public function new() {}

	function setup() {
		td = TaskData.getInstance();
		// 单例跨用例复位：backing 直写回原文初值（:20-23 缺省形态）
		td._updata = null;
		td._currentTask = {"taskId": 1, "taskFlag": 2};
	}

	// 常量面值（TaskData.as:10-16）
	public function test_constants() {
		Assert.equals("taskDataChange", TaskData.TASKDATA_CHANGE);
		Assert.equals("complete", TaskData.COMPLETE);
		Assert.equals("taskDoing", TaskData.TASK_DOING);
		Assert.equals(9, TaskData.TASK_MAX);
	}

	// 单例同一性（:35-42）：两次 getInstance 返回同一对象
	public function test_getInstance_identity() {
		Assert.equals(TaskData.getInstance(), TaskData.getInstance());
	}

	// currentTask 缺省（:20-23）：未 set 时 {taskId:1, taskFlag:2}
	public function test_currentTask_default() {
		var task = td.currentTask;
		Assert.notNull(task);
		Assert.equals(1, task.taskId);
		Assert.equals(2, task.taskFlag);
	}

	// updata setter（:44-48）：存值 + 派 COMPLETE
	public function test_updata_setter_dispatches_complete() {
		var got:Array<String> = [];
		td.addEventListener(TaskData.COMPLETE, function(e) got.push(e.type));
		td.updata = {u: 1};
		Assert.equals("complete", got.join(","));
		Assert.equals(1, td.updata.u);
	}

	// currentTask setter（:50-54）：存值 + 派 TASKDATA_CHANGE
	public function test_currentTask_setter_dispatches_change() {
		var got:Array<String> = [];
		td.addEventListener(TaskData.TASKDATA_CHANGE, function(e) got.push(e.type));
		td.currentTask = {"taskId": 3, "taskFlag": 1};
		Assert.equals("taskDataChange", got.join(","));
		Assert.equals(3, td.currentTask.taskId);
		Assert.equals(1, td.currentTask.taskFlag);
	}

	// 两 setter 事件串不交叉：updata 只派 COMPLETE、currentTask 只派
	// TASKDATA_CHANGE（:44-54 各一派发）
	public function test_setters_dispatch_distinct_events() {
		var completes = 0;
		var changes = 0;
		td.addEventListener(TaskData.COMPLETE, function(e) completes++);
		td.addEventListener(TaskData.TASKDATA_CHANGE, function(e) changes++);
		td.updata = {};
		Assert.equals(1, completes);
		Assert.equals(0, changes);
		td.currentTask = {"taskId": 2, "taskFlag": 0};
		Assert.equals(1, completes);
		Assert.equals(1, changes);
	}
}
