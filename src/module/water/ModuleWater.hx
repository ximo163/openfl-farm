package module.water;

import common.Consts;
import framework.base.Module;
import module.FarmApplication;

/**
 * module.water.ModuleWater —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 鱼塘模块（ModuleWater.as），V3c 片；FarmApplication.startup 里按触发事件 loadLater/直接 load。
 * 这里只保模块壳（Module 子类 + name），控制器/视图随对应片接入。
 */
@:keep
class ModuleWater extends Module {
	public function new(param1:FarmApplication) {
		super(param1);
	}

	// 原版 override get name
	override private function get_name():String {
		return Consts.MODULE_WATER;
	}
}
