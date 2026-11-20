package module.uitools;

import common.Consts;
import framework.base.BaseLayer;
import framework.base.Module;
import module.FarmApplication;

/**
 * module.uitools.ModuleUITools —— ModuleUITools.as 逐句对应（issue #9）。
 * 工具区模块壳：load 建 UIController 并 initialze，unload finalize，
 * 网络停摆时复位 model 的加载位。
 */
@:keep
class ModuleUITools extends Module {
	// ModuleUITools.as:10
	private var m_uiCtrl:UIController;

	// ModuleUITools.as:12-16
	public function new(param1:FarmApplication) {
		super(param1);
	}

	// ModuleUITools.as:18-21
	override private function get_name():String {
		return Consts.MODULE_UITOOLS;
	}

	// ModuleUITools.as:23-32
	override public function onNetRequestStopped():Void {
		if (this.m_uiCtrl != null) {
			if (this.m_uiCtrl.model != null) {
				this.m_uiCtrl.model.resetLoadingFlags();
			}
		}
	}

	// ModuleUITools.as:34-39
	override public function load(param1:BaseLayer):Void {
		super.load(param1);
		this.m_uiCtrl = new UIController(this);
		this.m_uiCtrl.initialze();
	}

	// ModuleUITools.as:41-48
	override public function unload():Void {
		if (this.m_uiCtrl != null) {
			this.m_uiCtrl.finalize();
			this.m_uiCtrl = null;
		}
	}
}
