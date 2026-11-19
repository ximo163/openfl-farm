package com.qzone.qui.containers;

import openfl.events.Event;

/**
 * com.qzone.qui.containers.TitleWindow —— V3b 闭包 stub（issue #8）。qui
 * 标题窗容器（TitleWindow.as 106 loc > 100，闭包规则走 stub，qui 组件片
 * 翻译）。继承 Panel stub（原版 TitleWindow → Panel → UIComponent）。
 * 本片 PreviewDiyWindow 覆写 onClose/调 close：原版语义（onClose → close →
 * 派发 Event.CLOSE + closeFn 短路调用，TitleWindow.as:89-91/:97-102）随
 * qui 片接入，窗口片未通前 close/onClose 为 no-op。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/qui/containers/TitleWindow.as
 */
@:keep
class TitleWindow extends Panel {
	// TitleWindow.as:29-35（ctor 形态；皮肤/关闭按钮装配随 qui 片）
	public function new(param1:String = "Window", param2:Int = 300, param3:Int = 200, param4:Dynamic = null) {
		super(param1, param2, param3);
	}

	// TitleWindow.as:89-91（onClose：子类覆写点，qui 片翻译）
	private function onClose(param1:Event):Void {}

	// TitleWindow.as:97-102（close：派发 CLOSE + closeFn，qui 片翻译）
	private function close():Void {}
}
