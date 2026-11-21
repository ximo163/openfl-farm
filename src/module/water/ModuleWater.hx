package module.water;

import common.Consts;
import events.CommonEvent;
import framework.base.Controller;
import framework.base.Module;
import module.FarmApplication;
import openfl.errors.Error;

/**
 * module.water.ModuleWater —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 鱼塘模块（ModuleWater.as），V3c 片；FarmApplication.startup 里按触发事件 loadLater/直接 load。
 * 这里只保模块壳（Module 子类 + name），控制器/视图随对应片接入。
 */
@:keep
class ModuleWater extends Module {
	// ModuleWater.as:16（#29 write-tests：被测面字段声明——onModuleLoadSuccess
	// 反射 null 分支与 onZoom 空控制器的断言经它读取；初始化/赋值随 implement
	// 阶段整类真身化）
	private var _waterCtrl:Controller;

	public function new(param1:FarmApplication) {
		super(param1);
	}

	// ModuleWater.as:103-117（onZoom：MSG_ZOOM 收听器，空事件/空 data/空
	// 控制器三分支；#29 write-tests stub，实现随 implement 阶段真身化）
	private function onZoom(param1:CommonEvent):Void {
		throw new Error("not implemented");
	}

	// 原版 override get name
	override private function get_name():String {
		return Consts.MODULE_WATER;
	}
}
