package module.messages;

import common.Consts;
import framework.base.BaseLayer;
import framework.base.Module;
import module.FarmApplication;

/**
 * module.messages.ModuleMessages —— ModuleMessages.as 逐句对应（issue #19，
 * 替换 #7 的闭包 stub）。消息模块壳：load 建 MessageController 并挂
 * MSG_SHOW_PROFILE 监听，unload 落地。
 */
@:keep
class ModuleMessages extends Module {
	// ModuleMessages.as:11
	private var m_msgSystem:MessageController;

	public function new(param1:FarmApplication) {
		super(param1);
		this.m_msgSystem = null;
	}

	// ModuleMessages.as:20-22
	override private function get_name():String {
		return Consts.MODULE_MESSAGES;
	}

	// ModuleMessages.as:24-29
	override public function load(param1:BaseLayer):Void {
		super.load(param1);
		this.m_msgSystem = new MessageController(this);
		this.m_msgSystem.initialze();
	}

	// ModuleMessages.as:31-37
	override public function unload():Void {
		if (this.m_msgSystem != null) {
			this.m_msgSystem.finalize();
			this.m_msgSystem = null;
		}
	}
}
