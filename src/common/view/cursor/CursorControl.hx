package common.view.cursor;

import common.Consts;
import events.CursorEvent;
import interfaces.IMsgCenter;

/**
 * common.view.cursor.CursorControl —— CursorControl.as 逐句对应（issue #9）。
 * 光标控件：类注册表（m_cusrsorLib，原版拼写如此 :14）+ setCursor/useSystem
 * 经 msgCenter 派发 CursorEvent 的切换入口。
 */
class CursorControl {
	// CursorControl.as:10
	private var m_msgCenter:IMsgCenter;

	// CursorControl.as:12
	private var m_cursorArgument:String;

	// CursorControl.as:14（原版拼写 m_cusrsorLib）
	private var m_cusrsorLib:Dynamic;

	// CursorControl.as:16
	private var m_preName:String;

	// CursorControl.as:18
	private var m_name:String;

	// CursorControl.as:20-25
	public function new(param1:IMsgCenter) {
		this.m_name = this.m_preName = null;
		this.m_msgCenter = param1;
	}

	// CursorControl.as:27-30
	public function getMsgCenter():IMsgCenter {
		return this.m_msgCenter;
	}

	// CursorControl.as:32-43（getClass：注册表查类；"" 或未注册返回 null）
	public function getClass(param1:String):Class<Dynamic> {
		if (param1 == "") {
			return null;
		}
		if (this.m_cusrsorLib == null) {
			return null;
		}
		return Reflect.field(this.m_cusrsorLib, param1);
	}

	// CursorControl.as:45-52（register：光标名 → 类）
	public function register(param1:String, param2:Class<Dynamic>):Void {
		if (this.m_cusrsorLib == null) {
			this.m_cusrsorLib = {};
		}
		Reflect.setField(this.m_cusrsorLib, param1, param2);
	}

	// CursorControl.as:54-57/:69-72
	public var cursorArgument(get, set):String;

	private function get_cursorArgument():String {
		return this.m_cursorArgument;
	}

	private function set_cursorArgument(param1:String):String {
		this.m_cursorArgument = param1;
		return param1;
	}

	// CursorControl.as:59-67
	public var name(get, set):String;

	private function get_name():String {
		return this.m_name;
	}

	private function set_name(param1:String):String {
		this.m_name = param1;
		return param1;
	}

	// CursorControl.as:74-86（useSystem：SWITCH_CURSOR 派发，true 切系统光标）
	public function useSystem(param1:Bool = true):Void {
		var _loc2_:CursorEvent = new CursorEvent(CursorEvent.SWITCH_CURSOR);
		if (param1 == true) {
			_loc2_.cursorName = Consts.CURSOR_SYSTEM;
		} else {
			_loc2_.cursorName = Consts.CURSOR_CUSTOMIZE;
		}
		this.m_msgCenter.dispatchEvent(_loc2_);
	}

	// CursorControl.as:88-100（setCursor：记名/参数（非空名落 m_preName）+
	// SET_CURSOR 派发。m_name 初值 null，首调 `null != ""` 为真同 AS3）
	public function setCursor(param1:String, param2:String = ""):Void {
		if (this.m_name != "") {
			this.m_preName = this.m_name;
		}
		this.m_name = param1;
		this.m_cursorArgument = param2;
		var _loc3_:CursorEvent = new CursorEvent(CursorEvent.SET_CURSOR);
		_loc3_.cursorName = param1;
		_loc3_.cursorArgument = this.m_cursorArgument;
		this.m_msgCenter.dispatchEvent(_loc3_);
	}
}
