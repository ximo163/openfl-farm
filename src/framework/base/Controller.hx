package framework.base;

import common.view.cursor.CursorControl;
import common.view.floating.FloatControl;
import interfaces.IModule;
import module.FarmApplication;
import shim.As3;

// framework.base.Controller —— Controller.as 逐句对应（控制器基类：经
// module.app 转发 tip/float/cursor/window 的便捷面）。`param2 is String &&
// length == 0` 的组合真值按 As3.truthy 拆开保持语义。
class Controller {
	// Controller.as:10-14（protected → Haxe private，子类可见）
	private var m_view:Dynamic;
	private var m_module:IModule;
	private var m_model:Dynamic;

	// Controller.as:16-22
	public function new(param1:IModule) {
		super();
		this.m_module = param1;
		this.m_model = null;
		this.m_view = null;
	}

	// Controller.as:24-34
	public function showTip(param1:String, param2:Dynamic):Void {
		if (param1 == "" || param2 == null || (Std.isOfType(param2, String) && As3.truthy(param2) == false)) {
			return;
		}
		if (this.m_module != null && this.m_module.app != null) {
			this.m_module.app.showTip(param1, param2);
		}
	}

	// Controller.as:36-42
	public function useSystemCursor(param1:Bool):Void {
		if (this.m_module != null && this.m_module.app != null) {
			this.m_module.app.useSystemCursor(param1);
		}
	}

	// Controller.as:44-46
	public function initialze():Void {}

	// Controller.as:48-59
	public function openFloat(param1:String, param2:Dynamic):Void {
		if (param1 == "" || param2 == null) {
			return;
		}
		var _loc3_:FloatControl = this.m_module.app.farmView.floatCtrl;
		if (_loc3_ != null) {
			_loc3_.open(param1, 0, param2);
		}
	}

	// Controller.as:61-77
	public function setCursor(param1:String, param2:String):Void {
		var _loc3_:CursorControl = null;
		if (param1 == "") {
			return;
		}
		if (this.m_module != null && this.m_module.app != null) {
			_loc3_ = this.m_module.app.farmView.cursorCtrl;
			if (_loc3_ == null) {
				return;
			}
			_loc3_.setCursor(param1, param2);
		}
	}

	// Controller.as:79-85
	public function hideTip():Void {
		if (this.m_module != null && this.m_module.app != null) {
			this.m_module.app.hideTip();
		}
	}

	// Controller.as:87-97
	public function openWindow(param1:String, param2:Dynamic):Void {
		if (param1 == "") {
			return;
		}
		if (this.m_module != null && this.m_module.app != null) {
			this.m_module.app.openWindowByName(param1, param2);
		}
	}

	// Controller.as:99-102
	public var module(get, set):IModule;

	private function get_module():IModule {
		return this.m_module;
	}

	// Controller.as:104-109
	public function finalize():Void {
		this.m_model = null;
		this.m_view = null;
		this.m_module = null;
	}

	// Controller.as:111-114
	private function set_module(param1:IModule):IModule {
		this.m_module = param1;
		return param1;
	}
}
