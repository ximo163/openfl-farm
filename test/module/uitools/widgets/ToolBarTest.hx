package module.uitools.widgets;

import common.Consts;
import common.Session;
import common.view.cursor.CursorControl;
import module.FarmApplication;
import module.FarmStage;
import module.uitools.ModuleUITools;
import module.uitools.UIController;
import openfl.events.KeyboardEvent;
import support.FakeMsgCenter;
import utest.Assert;

/**
 * ToolBar 工具选择/取消状态机纯逻辑（issue #9）。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/module/uitools/widgets/ToolBar.as
 * （setCursor :174-204、onKeyUp :390-411、m_lockFishMouse 写入 :203）。
 * 快捷键映射 Q81→浇水 W87→钩 E69→杀虫 R82→手 T84→一键；焦点在 TextField
 * 时忽略（:393-397）。
 *
 * 链路组装按 :179-181：controller.module.app.farmView.cursorCtrl——FarmStage
 * 建层光标注册走真资源，这里手动注入 CursorControl（ctor 只建空注册表）。
 * eval 无资源，addTools 的取素材恒 null，只断言状态机本身。FarmApplication
 * 空构造安全（#8 GetCropID.theApp 先例）。Session 全局单例，用例自行钉
 * m_lockFishMouse 初值。
 */
@:access(module.uitools.widgets.ToolBar)
@:access(module.FarmStage)
class ToolBarTest {
	public function new() {}

	function makeEnv():{tb:ToolBar, ctrl:CursorControl} {
		var app = new FarmApplication();
		var stage = new FarmStage(app);
		app.view = stage;
		var ctrl = new CursorControl(new FakeMsgCenter());
		stage.m_cursorCtrl = ctrl;
		var controller = new UIController(new ModuleUITools(app));
		return {tb: new ToolBar(controller), ctrl: ctrl};
	}

	function keyUp(keyCode:Int):KeyboardEvent {
		// KeyboardEvent(type, bubbles, cancelable, charCodeValue, keyCodeValue)
		return new KeyboardEvent(KeyboardEvent.KEY_UP, false, false, 0, keyCode);
	}

	// :183-201：param2 且当前名不同 → 设光标回 true；param2 且同名 → 弹回
	// ARROW 回 false（工具按钮二次点击取消选择）；:192-194 弹回走 param2=false
	public function test_setCursor_toggle_selects_then_cancels_back_to_arrow() {
		var env = makeEnv();
		Assert.isTrue(env.tb.setCursor(Consts.CURSOR_STYLE_HOE, true)); // :186-190
		Assert.equals(Consts.CURSOR_STYLE_HOE, env.ctrl.name);
		Assert.isFalse(env.tb.setCursor(Consts.CURSOR_STYLE_HOE, true)); // :191-196
		Assert.equals(Consts.CURSOR_STYLE_ARROW, env.ctrl.name); // :194 弹回
		Assert.isTrue(env.tb.setCursor(Consts.CURSOR_STYLE_HOE, true)); // 再选又立起
		Assert.equals(Consts.CURSOR_STYLE_HOE, env.ctrl.name);
	}

	// :183-185：param2=false（快捷键路径）不做同名判断，恒设恒 true
	public function test_setCursor_without_check_always_sets() {
		var env = makeEnv();
		Assert.isTrue(env.tb.setCursor(Consts.CURSOR_STYLE_FISHNET, false));
		Assert.equals(Consts.CURSOR_STYLE_FISHNET, env.ctrl.name);
		Assert.isTrue(env.tb.setCursor(Consts.CURSOR_STYLE_FISHNET, false)); // 同名也过
		Assert.equals(Consts.CURSOR_STYLE_FISHNET, env.ctrl.name);
	}

	// :203：渔网类光标锁鼠标，其余不锁（收杆/撒网切换时渔场免点穿）
	public function test_setCursor_fishnet_locks_mouse() {
		var s = Session.getInstance();
		s.m_lockFishMouse = false;
		var env = makeEnv();
		env.tb.setCursor(Consts.CURSOR_STYLE_FISHNET); // param2 默认 false
		Assert.isTrue(s.m_lockFishMouse); // == FISHNET → true
		env.tb.setCursor(Consts.CURSOR_STYLE_FISHNET_ALL);
		Assert.isTrue(s.m_lockFishMouse); // == FISHNET_ALL → true
		env.tb.setCursor(Consts.CURSOR_STYLE_HOE);
		Assert.isFalse(s.m_lockFishMouse); // 其它光标 → false
	}

	// :399-417 键码 → 光标；无对应键不动当前光标（switch 无 default 分支）
	public function test_onKeyUp_maps_shortcut_keys_to_cursors() {
		var env = makeEnv();
		var cases:Array<{keyCode:Int, cursor:String}> = [
			{keyCode: 81, cursor: Consts.CURSOR_STYLE_WATER}, // Q → 浇水
			{keyCode: 87, cursor: Consts.CURSOR_STYLE_HOOK}, // W → 钩（摘）
			{keyCode: 69, cursor: Consts.CURSOR_STYLE_PESTICIDE}, // E → 杀虫
			{keyCode: 82, cursor: Consts.CURSOR_STYLE_HAND}, // R → 手（收）
			{keyCode: 84, cursor: Consts.CURSOR_STYLE_ONEHAND} // T → 一键
		];
		for (c in cases) {
			env.tb.onKeyUp(keyUp(c.keyCode));
			Assert.equals(c.cursor, env.ctrl.name);
		}

		env.tb.onKeyUp(keyUp(90)); // Z 无映射
		Assert.equals(Consts.CURSOR_STYLE_ONEHAND, env.ctrl.name);
	}
}
