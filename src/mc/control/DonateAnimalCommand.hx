package mc.control;

import mc.view.farm.animals.Animal;
import openfl.errors.Error;

/**
 * mc.control.DonateAnimalCommand —— DonateAnimalCommand.as 的签名面 stub
 * （原类 175 loc，牧场命令片真身待译——issue #88 write-tests 按测试引用面
 * 补落）。原类 final 不继承 EventDispatcher、懒单例无守卫（getInstance
 * 重复 new 不报错——DonateAnimalCommand.as:41-48）。方法签名逐字取自
 * legacy/decompiled/Master2_v_142/scripts/mc/control/DonateAnimalCommand.as。
 */
@:keep
class DonateAnimalCommand {
	// DonateAnimalCommand.as:18
	private static var _instance:DonateAnimalCommand = null;

	public function new() {}

	// DonateAnimalCommand.as:41-48（懒单例——无实例化守卫）
	public static function getInstance():DonateAnimalCommand {
		if (_instance != null) {
			return _instance;
		}
		_instance = new DonateAnimalCommand();
		return _instance;
	}

	// DonateAnimalCommand.as:62（donateAnimal(param1:Animal)）
	public function donateAnimal(param1:Animal):Void {
		throw new Error("not implemented");
	}
}
