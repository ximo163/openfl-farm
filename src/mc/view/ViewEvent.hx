package mc.view;

import openfl.events.Event;

/**
 * mc.view.ViewEvent —— ViewEvent.as 逐句对应（issue #19 Master2 闭包顺手译）。
 */
@:keep
class ViewEvent extends Event {
	// ViewEvent.as:8-22
	public static final ERROR_LOAD:String = "errorLoad";
	public static final PROGRESS_LOAD:String = "progressLoad";
	public static final RECLAIM_CLICK:String = "reclaimClick";
	public static final MODULE_COMP:String = "moduleComp";
	public static final CHILD_CLICK:String = "childClick";
	public static final CHILD_OVER:String = "childOver";
	public static final CHILD_OUT:String = "childOut";
	public static final LINK_CLICK:String = "linkClick";

	// ViewEvent.as:24
	private var _data:Dynamic;

	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// ViewEvent.as:33-39（AS3 public get/set data 对）
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		return param1;
	}
}
