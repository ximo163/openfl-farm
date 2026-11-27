package mc.view.farm.animals;

import openfl.display.Sprite;
import openfl.errors.Error;

/**
 * mc.view.farm.animals.Animal —— Animal.as 的签名面 stub（原类为场景片
 * 显示对象，真身随牧场场景片翻译——非 issue #88 范围；#88 命令层
 * DonateAnimalCommand.donateAnimal 的入参类型需要签名）。只保 data
 * 存取面（命令层唯一触碰的成员——DonateAnimalCommand.as:66-175）。
 * 签名逐字取自
 * legacy/decompiled/Master2_v_142/scripts/mc/view/farm/animals/Animal.as。
 */
@:keep
class Animal extends Sprite {
	public function new() {
		super();
	}

	// Animal.as:199/:368（data 存取——getter/setter 成对）
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		throw new Error("not implemented");
	}

	private function set_data(param1:Dynamic):Dynamic {
		throw new Error("not implemented");
	}
}
