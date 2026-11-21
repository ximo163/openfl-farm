package entities;

import common.misc.Utils;

// entities.Task —— Task.as 逐句对应（issue #7 闭包 stub 起步：StartupDataParser
// 构造 _task = new Task(param1["task"])；issue #21（tasks）把 importObject 的
// 解析补齐——WelcomeModel.onTaskUpdated 构造 new Task(应答 task 对象)、
// WelcomeController.startNewTask 构造 new Task(null) 后直接写字段）。
@:final
class Task {
	// Task.as:7
	public var _taskFlag:Int;

	// Task.as:9
	public var _taskId:Int;

	public function new(param1:Dynamic = null) {
		this.importObject(param1);
	}

	// Task.as:16-23（AS3 int 字段收 Number 返回值隐式截断 → Std.int，
	// DecorateItem/BagItem 先例）
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this._taskId = Std.int(Utils.getIntAttribute(param1, "taskId"));
		this._taskFlag = Std.int(Utils.getIntAttribute(param1, "taskFlag"));
	}
}
