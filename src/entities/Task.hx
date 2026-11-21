package entities;

// Task.as —— 后续模块翻译，stub 同 module/Main 先例（issue #7 闭包类：StartupDataParser
// 构造 _task = new Task(param1["task"])，这里只保证可编译、不抛）。
// issue #21（tasks）引用面补齐（Task.as 字段区，同 Friend 先例）：
// WelcomeModel.currentTask setter 读 _taskId/_taskFlag（WelcomeModel.as:183-193）、
// onAccepted 直接写字段（:99-100）、WelcomeController.startNewTask 同款（:22-23）。
// importObject 的解析（Task.as:16-23，经 Utils.getIntAttribute）留给实现阶段。
@:final
class Task {
	// Task.as:7
	public var _taskFlag:Int;

	// Task.as:9
	public var _taskId:Int;

	public function new(param1:Dynamic = null) {}
}
