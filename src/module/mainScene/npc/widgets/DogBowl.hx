package module.mainScene.npc.widgets;

import module.mainScene.npc.NPCView;
import openfl.display.Sprite;

/**
 * module.mainScene.npc.widgets.DogBowl —— V3b 闭包 stub（issue #8）。
 * 狗粮盆（DogBowl.as 108 loc > 100，闭包规则走 stub，狗狗交互窗口片翻译）。
 * NPCView.updateFood 经 set food 换盆（满/空用 DogFood/DogFoodNull 符号），
 * 这里只保引用面：ctor 存宿主、food setter 空实现（不摆素材）。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/npc/widgets/DogBowl.as
 */
@:keep
class DogBowl extends Sprite {
	// DogBowl.as:11（宿主视图）
	private var m_parent:NPCView;

	// DogBowl.as:13-15（AS3 实例 const → static final，CLAUDE.md 规则）
	private static final salverX:Int = 400;
	private static final salverY:Int = 200;

	// DogBowl.as:17-21
	public function new(param1:NPCView) {
		super();
		this.m_parent = param1;
	}

	// DogBowl.as:57-103（set food：满/空两态换 DogFoodNull/DogFood 符号并挂
	// 鼠标事件——狗盆素材与交互随狗狗窗口片翻译）
	public var food(never, set):Bool;

	private function set_food(param1:Bool):Bool {
		return param1;
	}
}
