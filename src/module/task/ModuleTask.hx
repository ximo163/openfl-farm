package module.task;

import common.Consts;
import framework.base.BaseLayer;
import framework.base.Module;
import module.FarmApplication;
import module.task.welcome.WelcomeController;

/**
 * module.task.welcome 包外的模块壳 —— module.task.ModuleTask —— ModuleTask.as
 * （54 loc）逐句对应（issue #7 先保壳，issue #21 补控制器装配）。任务模块：
 * load 建 WelcomeController 并 initialze（挂 MSG_STARTUP_DATA/MSG_CHECK_TASK），
 * unload finalize；停网（onNetRequestStopped）经 model.resetLoadingFlags 复位
 * 更新中门位，卡死的 m_taskUpdating 放行下一轮。
 */
@:keep
class ModuleTask extends Module {
	// ModuleTask.as:8
	private var m_welcomeSystem:WelcomeController;

	// ModuleTask.as:10-14
	public function new(param1:FarmApplication) {
		super(param1);
		this.m_welcomeSystem = null;
	}

	// ModuleTask.as:16-19
	override private function get_name():String {
		return Consts.MODULE_TASK;
	}

	// ModuleTask.as:21-30
	override public function onNetRequestStopped():Void {
		if (this.m_welcomeSystem != null) {
			if (this.m_welcomeSystem.model != null) {
				this.m_welcomeSystem.model.resetLoadingFlags();
			}
		}
	}

	// ModuleTask.as:32-38
	override public function load(param1:BaseLayer):Void {
		super.load(param1);
		this.m_welcomeSystem = new WelcomeController(this);
		this.m_welcomeSystem.initialze();
	}

	// ModuleTask.as:40-47
	override public function unload():Void {
		if (this.m_welcomeSystem != null) {
			this.m_welcomeSystem.finalize();
			this.m_welcomeSystem = null;
		}
	}
}
