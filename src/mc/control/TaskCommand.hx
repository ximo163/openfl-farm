package mc.control;

import openfl.events.EventDispatcher;

/**
 * mc.control.TaskCommand —— TaskCommand.as 的签名面 stub（原类 59 loc，
 * 本可整译，但 run/taskAccept 全部依赖未译的 FBridge 网络栈
 * （FRequest.postRequest/EventRecorder.recordErrorEvent/TaskData），翻译体
 * 无法落地，按规则只保签名面（deviations 候选，见 issue #19 收尾说明）。
 * TaskCommand.as:8 extends EventDispatcher。
 */
@:keep
class TaskCommand extends EventDispatcher {
	public function new() {
		super();
	}

	// TaskCommand.as:22-25（run：fr.postRequest("cgi_up_task",...)）
	public function run():Void {}
}
