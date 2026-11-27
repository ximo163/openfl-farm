package mc.model;

import openfl.events.EventDispatcher;

/**
 * mc.model.TaskData —— TaskData.as 逐句对应（issue #87「数据」片充真身）。
 * 牧场任务数据单例：currentTask 缺省 {taskId:1, taskFlag:2}
 * （TaskData.as:20-23）、TASK_MAX 9。
 * legacy/decompiled/Master2_v_142/scripts/mc/model/TaskData.as。
 */
@:keep
class TaskData extends EventDispatcher {
	// TaskData.as:8
	private static var instance:TaskData;

	// TaskData.as:10-16
	public static final TASKDATA_CHANGE:String = "taskDataChange";
	public static final COMPLETE:String = "complete";
	public static final TASK_DOING:String = "taskDoing";
	public static final TASK_MAX:Float = 9;

	// TaskData.as:18-23
	private var _updata:Dynamic;
	private var _currentTask:Dynamic = {
		"taskId": 1,
		"taskFlag": 2
	};

	// TaskData.as:25-33（单例守卫——原文构造器即完整实现。
	// PORT-NOTE(cpp)：同 MData——super() 前移到守卫外，Haxe/cpp 要求
	// super 全路径先调；EventDispatcher ctor 无副作用，语义等价）
	public function new() {
		super();
		if (instance == null) {
			return;
		}
		throw new openfl.errors.Error("实例化单例类出错-TaskData");
	}

	// TaskData.as:35-42
	public static function getInstance():TaskData {
		if (instance == null) {
			instance = new TaskData();
		}
		return instance;
	}

	// TaskData.as:44-48/:56-59（updata 存取——setter 派发 COMPLETE）
	public var updata(get, set):Dynamic;

	private function get_updata():Dynamic {
		return this._updata;
	}

	private function set_updata(param1:Dynamic):Dynamic {
		this._updata = param1;
		dispatchEvent(new ModelEvent(TaskData.COMPLETE));
		return param1;
	}

	// TaskData.as:50-54/:61-64（currentTask 存取——setter 派发
	// TASKDATA_CHANGE）
	public var currentTask(get, set):Dynamic;

	private function get_currentTask():Dynamic {
		return this._currentTask;
	}

	private function set_currentTask(param1:Dynamic):Dynamic {
		this._currentTask = param1;
		dispatchEvent(new ModelEvent(TaskData.TASKDATA_CHANGE));
		return param1;
	}
}
