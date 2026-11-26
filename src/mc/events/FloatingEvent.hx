package mc.events;

import mc.view.main.floating.FloatingBase;
import openfl.events.Event;

/**
 * mc.events.FloatingEvent —— FloatingEvent.as 逐句对应（issue #86 牧场库
 * 底座，事件片）。飘字开/关事件，载荷是 FloatingBase 实例。
 * legacy/decompiled/Master2_v_142/scripts/mc/events/FloatingEvent.as。
 */
@:keep
class FloatingEvent extends Event {
	// FloatingEvent.as:9-11
	public static final FLOATING_OPEN:String = "floatingOpen";
	public static final FLOATING_CLOSE:String = "floatingClose";

	// :13
	private var _floating:FloatingBase;

	// :15-18
	public function new(param1:String, param2:Bool = false, param3:Bool = false) {
		super(param1, param2, param3);
	}

	// :20-27
	public var floating(get, set):FloatingBase;

	private function get_floating():FloatingBase {
		return this._floating;
	}

	private function set_floating(param1:FloatingBase):FloatingBase {
		this._floating = param1;
		return param1;
	}
}
