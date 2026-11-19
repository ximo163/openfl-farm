package module.freegift;

import common.Consts;
import framework.base.Module;
import module.FarmApplication;

/**
 * module.FreeGift.ModuleFreeGift —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 免费礼包模块（ModuleFreeGift.as），V3c 片；FarmApplication.startup 里按触发事件 loadLater/直接 load。
 * 这里只保模块壳（Module 子类 + name），控制器/视图随对应片接入。
 * PORT-NOTE: 原版包名 module.FreeGift（首字母大写段），Haxe 4.3.6 的类型路径
 * 解析不支持首字母大写的包段（实测 import 直接 Type not found），按 Haxe 惯例
 * 改小写 module.freegift；类名与文件名 1:1 不变。deviations 候选（人维护）。
 */
@:keep
class ModuleFreeGift extends Module {
	public function new(param1:FarmApplication) {
		super(param1);
	}

	// 原版 override get name
	override private function get_name():String {
		return Consts.MODULE_FREE_GIFT;
	}
}
