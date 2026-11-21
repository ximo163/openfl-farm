package module.task.welcome;

import com.qzone.qfa.events.CommandEvent;
import common.Session;
import entities.Task;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import openfl.events.EventDispatcher;
import report.EventRecorder;
import shim.As3;

/**
 * module.task.welcome.WelcomeModel —— WelcomeModel.as（223 loc）逐句对应
 * （issue #21，替换 write-tests 的签名 stub）。新手任务数据层：11 项任务表
 * （taskComp 完成判定的全部输入）、新 id 空间 → 旧 id 的 newIDToOldID 反查表、
 * currentTask 装载（TaskChanged 派发 + Session.isNewGuideTask 极性）、
 * taskComp 三门（flag==1 + 名字与 me 对表 + code==1）→ updateTask 请求
 * （m_taskUpdating 门位防重入，ModuleTask.onNetRequestStopped 经
 * resetLoadingFlags 复位）。任务推进语义：task_update 完成后 DB taskid+1 但
 * 响应回显刚完成的旧 id（taskFlag=2 待领下一个；taskid==11 回 0/0 全部完成），
 * 「+1」发生在下一个 task_accept 应答（task_accept.php:5-6 /
 * task_update.php:6-15，见 spec/protocol.json entries.nc.mods）。
 */
class WelcomeModel extends EventDispatcher {
	// WelcomeModel.as:15
	public static final EVENT_TASK_CHANGED:String = "TaskChanged";

	// WelcomeModel.as:17
	public static final EVENT_TASK_COMPLETED:String = "TaskCompleted";

	// WelcomeModel.as:19-64（"1"-"11" 数字串键照抄；Haxe 对象字面量收带引号键）
	private static var taskList:Dynamic = {
		"1": {"name": "harvest", "me": true},
		"2": {"name": "scarify", "me": true},
		"3": {"name": "sale", "me": true},
		"4": {"name": "planting", "me": true},
		"5": {"name": "water", "me": true},
		"6": {"name": "clearWeed", "me": true},
		"7": {"name": "spraying", "me": true},
		"8": {"name": "water", "me": false},
		"9": {"name": "clearWeed", "me": false},
		"10": {"name": "spraying", "me": false},
		"11": {"name": "harvest", "me": false}
	};

	// WelcomeModel.as:66（新 id 空间 → 旧 id 查表：下标即旧 id；99 双现于
	// 下标 0/8，indexOf 恒取首个）
	private static final newIDToOldID:Array<Dynamic> = [99, 21, 24, 25, 26, 27, 22, 23, 99, 28, 29, 30];

	// WelcomeModel.as:68
	private var m_currentTaskID:Int;

	// WelcomeModel.as:70
	private var m_currentTaskFlag:Int;

	// WelcomeModel.as:72
	private var m_taskUpdating:Bool;

	// WelcomeModel.as:74-80
	public function new() {
		super();
		this.m_currentTaskID = 0;
		this.m_currentTaskFlag = 0;
		this.m_taskUpdating = false;
	}

	// WelcomeModel.as:82-85
	public var taskID(get, never):Int;

	private function get_taskID():Int {
		return this.m_currentTaskID;
	}

	// WelcomeModel.as:87-90（AS3 `concat()` 无参调用是防御性拷贝 → Haxe copy()）
	public var newIDToOldIDArray(get, never):Array<Dynamic>;

	private function get_newIDToOldIDArray():Array<Dynamic> {
		return newIDToOldID.copy();
	}

	// WelcomeModel.as:92-104。`_loc2_["taskId"] != undefined` → Reflect 判空
	//（键缺位/显式 null 同落 null，AS3 里两者对 != undefined 都不成立）
	private function onAccepted(param1:CommandEvent):Void {
		var _loc3_:Task = null;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ != null && Reflect.field(_loc2_, "taskId") != null) {
			_loc3_ = new Task(null);
			_loc3_._taskId = As3.intOf(Reflect.field(_loc2_, "taskId"));
			_loc3_._taskFlag = 1;
			this.currentTask = _loc3_;
		}
		EventRecorder.recordSueecssEvent("160858", null);
	}

	// WelcomeModel.as:106-121。:112 读小写 "cmdId" 是原版笔误（请求侧
	// Utils.buildRequest 只产 "cmdID"，该分支恒假），照抄不修
	private function onNetError(param1:CommandEvent):Void {
		if (param1 == null || param1.result == null) {
			return;
		}
		if (Reflect.field(param1.body, "cmdId") == CommandDefs.CMD_ACCEPT_TASK) {
			EventRecorder.recordErrorEvent("160858", null, 4);
		}
		if (Reflect.field(param1.body, "cmdID") == CommandDefs.CMD_UPDATE_TASK) {
			this.m_taskUpdating = false;
			EventRecorder.recordErrorEvent("160859", null, 4);
		}
	}

	// WelcomeModel.as:123-126
	public function acceptTask():Void {
		NetHelper.sendRequest(CommandDefs.CMD_ACCEPT_TASK, null, this.onAccepted, this.onNetError);
	}

	// WelcomeModel.as:128-136
	private function updateTask():Void {
		if (this.m_taskUpdating == true) {
			return;
		}
		this.m_taskUpdating = true;
		NetHelper.sendRequest(CommandDefs.CMD_UPDATE_TASK, null, this.onTaskUpdated, this.onNetError);
	}

	// WelcomeModel.as:138-141
	public var taskFlag(get, never):Int;

	private function get_taskFlag():Int {
		return this.m_currentTaskFlag;
	}

	// WelcomeModel.as:143-162。`_loc3_["me"] as Boolean`：表值本就是 Bool
	// 字面量，直接比；`param2.hasOwnProperty("code")` → Reflect.hasField
	public function taskComp(param1:String, param2:Dynamic):Void {
		if (this.m_currentTaskFlag != 1) {
			return;
		}
		var _loc3_:Dynamic = Reflect.field(taskList, Std.string(this.m_currentTaskID));
		if (_loc3_ == null) {
			return;
		}
		var _loc4_:Bool = Session.getInstance().me;
		if (Reflect.field(_loc3_, "name") == param1 && _loc4_ == Reflect.field(_loc3_, "me")) {
			if (Reflect.hasField(param2, "code") == true && Reflect.field(param2, "code") == 1) {
				this.updateTask();
			}
		}
	}

	// WelcomeModel.as:164-167
	public function preSetTaskFlag():Void {
		this.m_currentTaskFlag = 2;
	}

	// WelcomeModel.as:169-175
	public function resetLoadingFlags():Void {
		if (this.m_taskUpdating == true) {
			this.m_taskUpdating = false;
		}
	}

	// WelcomeModel.as:177-198
	public var currentTask(never, set):Task;

	private function set_currentTask(param1:Task):Task {
		if (param1 == null) {
			return param1;
		}
		if (param1._taskId < 20) {
			this.m_currentTaskID = param1._taskId;
			Session.getInstance().isNewGuideTask = false;
		} else {
			this.m_currentTaskID = newIDToOldID.indexOf(param1._taskId);
			Session.getInstance().isNewGuideTask = true;
		}
		this.m_currentTaskFlag = param1._taskFlag;
		dispatchEvent(new CommonEvent(EVENT_TASK_CHANGED, {
			"taskID": this.m_currentTaskID,
			"taskFlag": this.m_currentTaskFlag
		}));
		return param1;
	}

	// WelcomeModel.as:200-219。:211-214 的 `taskId==0&&taskFlag==0` 自赋值
	// 是原版死分支，照抄；TaskCompleted 载荷原样转发（direction/item/levelUp/
	// task 由 WelcomeView 消费）
	private function onTaskUpdated(param1:CommandEvent):Void {
		this.m_taskUpdating = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = Reflect.field(_loc2_, "task");
		if (_loc3_ != null && Reflect.field(_loc3_, "taskId") != null) {
			if (Reflect.field(_loc3_, "taskId") == 0 && Reflect.field(_loc3_, "taskFlag") == 0) {
				Reflect.setField(_loc3_, "taskId", 0);
			}
			this.currentTask = new Task(_loc3_);
			dispatchEvent(new CommonEvent(EVENT_TASK_COMPLETED, _loc2_));
		}
		EventRecorder.recordSueecssEvent("160859", null);
	}
}
