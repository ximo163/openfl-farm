package mc.view.farm.land;

import mc.view.main.floating.FloatingBase;

/**
 * mc.view.farm.land.ClockOperateFloating —— ClockOperateFloating.as 的
 * 签名面 stub（原类 118 loc，归「牧场地块/动物」子系统后续片充真身——
 * spec/modules/pasture.json；issue #87 只保 FloatingLayer.updateAnimalSkin
 * 编译链用到的成员面：类型存在 + updatePos()，签名逐字取自反编译原文、
 * 行号对应 ClockOperateFloating.as）。其余成员（animal/_animal 等以
 * mc.view.farm.animals.Animal 为类型形参的字段与构造器——Animal 同属该
 * 后续片、本 stub 期尚无类型可引）随所属片补全，本 stub 整体届时由该片
 * 的真身替换。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/farm/land/ClockOperateFloating.as。
 */
@:keep
class ClockOperateFloating extends FloatingBase {
	// ClockOperateFloating.as:32（构造器原文 (param1:Number, param2:Animal)
	// ——Animal 类型形参随所属片补全，见类头注）
	public function new() {
		super();
	}

	// ClockOperateFloating.as:60-75（签名逐字；体空——真身按 animal 位
	// 置跟手定位，随所属片充真身）
	public function updatePos():Void {}
}
