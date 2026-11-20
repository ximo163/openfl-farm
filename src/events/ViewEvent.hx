package events;

import openfl.events.Event;

// events.ViewEvent —— ViewEvent.as 逐句对应（issue #9）。视图通用事件
// （子项点击/悬浮、装载进度/错误、开垦、任务开始），带 data 载荷与
// 锁状态存取对。
class ViewEvent extends Event {
	// ViewEvent.as:8-22
	public static final CHILD_CLICK:String = "childClick";
	public static final CHILD_OUT:String = "childOut";
	public static final CHILD_OVER:String = "childOver";
	public static final ERROR_LOAD:String = "errorLoad";
	public static final LINK_CLICK:String = "linkClick";
	public static final PROGRESS_LOAD:String = "progressLoad";
	public static final RECLAIM_CLICK:String = "reclaimClick";
	public static final TASK_START:String = "taskStart";

	// ViewEvent.as:24-28
	private var _data:Dynamic;
	private var _changeLockStatus:Bool = false;
	private var _newLockStatus:Bool = false;

	// ViewEvent.as:30-33
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// ViewEvent.as:35-38/:60-63
	public var lockStatus(get, set):Bool;

	private function set_lockStatus(param1:Bool):Bool {
		this._newLockStatus = param1;
		return param1;
	}

	// ViewEvent.as:40-42/:50-53
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}

	// ViewEvent.as:45-47/:55-58
	public var changeLockStatus(get, set):Bool;

	private function get_changeLockStatus():Bool {
		return this._changeLockStatus;
	}

	private function set_changeLockStatus(param1:Bool):Bool {
		this._changeLockStatus = param1;
		return param1;
	}

	// ViewEvent.as:60-63
	private function get_lockStatus():Bool {
		return this._newLockStatus;
	}
}