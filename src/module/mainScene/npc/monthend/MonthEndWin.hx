// PORT-NOTE: 原包名 module.mainScene.npc.MonthEnd（MonthEnd.as 所在包）。
// Haxe 点路径把大写开头的段解析为模块名而非包段——module.mainScene.npc.
// MonthEnd.MonthEndWin 不可 import（"Type not found: ...MonthEnd"）。目录/
// 包段降为小写 monthend，类名/文件名不变；反射名无调用方。
package module.mainScene.npc.monthend;

import module.uitools.UIController;
import openfl.display.Sprite;

/**
 * module.mainScene.npc.MonthEnd.MonthEndWin —— 闭包 stub（issue #9）。
 * 完整类在 spec/modules/activities.json:2109（月末礼包窗 ~660 loc，activities
 * 片翻译）。本片 uitools 的 ShortcutBar.monthEndClick 引用的成员：ctor 形态
 * （MonthEndWin.as:55，入参 UIController）、openWindows（:600）；窗体装配、
 * 礼包领取、PopUpManager 弹层逻辑随 activities 片接入，stub 只保成员语义。
 * PopUpManager.addPopUp 侧按 DisplayObject 收参，Sprite 基类照原文。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/npc/MonthEnd/MonthEndWin.as
 */
@:keep
class MonthEndWin extends Sprite {
	// MonthEndWin.as:55-（ctor 形态照抄；useSystemCursor、皮肤与礼包装载随
	// activities 片）
	public function new(param1:UIController) {
		super();
	}

	// MonthEndWin.as:600
	public function openWindows():Void {}
}
