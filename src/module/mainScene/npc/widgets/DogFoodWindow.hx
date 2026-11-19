package module.mainScene.npc.widgets;

import common.view.window.AddButtonWindow;
import interfaces.IMsgCenter;
import module.mainScene.npc.NPCView;
import openfl.text.TextField;

/**
 * module.mainScene.npc.widgets.DogFoodWindow —— V3b 闭包 stub（issue #8）。
 * 狗粮购买窗口（DogFoodWindow.as 149 loc > 100，闭包规则走 stub，狗狗
 * 交互窗口片翻译）。NPCView.onFoodLoaded 经 winCtrl.open 打开并写 data，
 * 这里只保 ctor 形态（原版 super 传宿主 app，窗口标题等 chrome 属
 * qui TitleWindow 基类，窗口片接入后随整类翻译补齐）。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/npc/widgets/DogFoodWindow.as
 */
@:keep
class DogFoodWindow extends AddButtonWindow {
	// DogFoodWindow.as:11
	private var m_parent:NPCView;

	// DogFoodWindow.as:13
	private var m_leftime:TextField;

	// DogFoodWindow.as:15-26
	public function new(param1:NPCView) {
		super(Std.isOfType(param1.controller.module.app, IMsgCenter) ? cast(param1.controller.module.app, IMsgCenter) : null);
		this.m_parent = param1;
		this.m_leftime = null;
	}
}
