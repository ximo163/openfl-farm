package mc.model;

import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
 * mc.model.ToolData —— ToolData.as 逐句对应（issue #19 Master2 闭包顺手译）。
 * getter 名 whistleDate 原版即如此（返回 _whistleData），照抄不改。
 */
@:keep
class ToolData extends EventDispatcher {
	// ToolData.as:9-15
	private static var instance:ToolData;
	public static var Enemy_TOTAL:String;
	public static final WHISTLE_CHANGE:String = "whistle_change";
	public static final VIEW_WHISTLE:String = "view_whistle";

	// ToolData.as:17-23
	private var _viewWhistleData:Dynamic;
	private var _mpData:Dynamic;
	public var paradeError:String;
	private var _whistleData:Dynamic;

	public function new() {
		super();
	}

	// ToolData.as:30-33
	public var whistleDate(get, never):Dynamic;

	private function get_whistleDate():Dynamic {
		return this._whistleData;
	}

	// ToolData.as:35-38
	public var mpData(get, set):Dynamic;

	private function get_mpData():Dynamic {
		return this._mpData;
	}

	// ToolData.as:40-44
	public var viewWhistleData(get, set):Dynamic;

	private function get_viewWhistleData():Dynamic {
		return this._viewWhistleData;
	}

	private function set_viewWhistleData(param1:Dynamic):Dynamic {
		this._viewWhistleData = param1;
		dispatchEvent(new Event(ToolData.VIEW_WHISTLE));
		return param1;
	}

	// ToolData.as:51-54
	private function set_mpData(param1:Dynamic):Dynamic {
		this._mpData = param1;
		return param1;
	}

	// ToolData.as:56-60
	public var whistleData(get, set):Dynamic;

	private function get_whistleData():Dynamic {
		return this._whistleData;
	}

	private function set_whistleData(param1:Dynamic):Dynamic {
		this._whistleData = param1;
		dispatchEvent(new Event(ToolData.WHISTLE_CHANGE));
		return param1;
	}
}
