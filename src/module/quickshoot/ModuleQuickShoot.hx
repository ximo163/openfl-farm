package module.quickshoot;

import common.Consts;
import framework.base.Module;
import module.FarmApplication;

/**
 * module.quickshoot.ModuleQuickShoot —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 快速拍照模块（ModuleQuickShoot.as），V3c 片；FarmApplication.startup 里按触发事件 loadLater/直接 load。
 * 这里只保模块壳（Module 子类 + name），控制器/视图随对应片接入。
 */
@:keep
class ModuleQuickShoot extends Module {
	public function new(param1:FarmApplication) {
		super(param1);
	}

	// 原版 override get name
	override private function get_name():String {
		return Consts.MODULE_QUICK_SHOOT;
	}
}
