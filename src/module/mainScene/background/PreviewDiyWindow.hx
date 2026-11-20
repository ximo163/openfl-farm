package module.mainScene.background;

import common.Consts;
import common.Language;
import common.view.window.AddButtonWindow;
import events.CommonEvent;
import interfaces.IMsgCenter;
import openfl.events.Event;

/**
 * module.mainScene.background.PreviewDiyWindow —— V3b 顺手翻（issue #8）。
 * 装饰预览取消窗（PreviewDiyWindow.as 42 loc ≤ 100 闭包规则整类翻译）。
 * super 链的标题栏/关闭按钮行为在 qui 窗口片 stub 上（见 TitleWindow/Panel
 * stub 头注释）。PORT-NOTE(动态取键)：`Language.L["…"]` → Reflect.field
 * （eval 上 String 键直下标报 "String should be Int"）。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/background/PreviewDiyWindow.as
 */
@:keep
class PreviewDiyWindow extends AddButtonWindow {
	// PreviewDiyWindow.as:13-22
	public function new(param1:IMsgCenter) {
		super(param1);
		width = 200;
		height = 100;
		mode = false;
		title = Reflect.field(Language.L, "取消预览");
		windowName = Consts.WINDOW_NAME_PREVIEWDIY;
		addButton(Reflect.field(Language.L, "取消预览"), "ButtonOrange", 100, 25, this.onCancel);
	}

	// PreviewDiyWindow.as:24-28
	private function onCancel():Void {
		super.close();
		this.recover();
	}

	// PreviewDiyWindow.as:30-34（override protected → override private：
	// Haxe 私有对子类可见）
	override private function onClose(param1:Event):Void {
		super.onClose(param1);
		this.recover();
	}

	// PreviewDiyWindow.as:36-39
	private function recover():Void {
		this.m_msgCenter.dispatchEvent(new CommonEvent(Consts.MSG_EXIT_PREVIEW, null));
	}
}
