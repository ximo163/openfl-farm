package module.levelup;

import common.Consts;
import framework.base.Module;
import module.FarmApplication;

/**
 * module.levelup.LevelUpModule —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 升级模块（LevelUpModule.as 35 loc，收获可触发；spec 的升级片）——原版不覆写 name，沿用 Module 基类的空名；FarmApplication.startup 里按触发事件 loadLater/直接 load。
 * 这里只保模块壳（Module 子类 + name），控制器/视图随对应片接入。
 */
@:keep
class LevelUpModule extends Module {
	public function new(param1:FarmApplication) {
		super(param1);
	}
}
