package mc.view.common;

import mc.view.common.AlertWindow;
import utest.Assert;

/**
 * mc.view.common.AlertWindow 布局纯逻辑（issue #87 write-tests，对 stub
 * 失败）：ctor 常量与 data.type 驱动的图标显隐/文本 y/窗口高度重算。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/common/AlertWindow.as
 * —— ctor :34-42（width=param1 缺省 320、height=280、windowName
 * "AlertWindow"、mode=true）；setData :139-229（type "success" →
 * successIcon 显 errorIcon 隐、alertText.y=170；"error" → 反之、y=170；
 * "tip" → 双隐、y=60；缺省/无 type → 双隐、y=130；data.text 存在时
 * height=alertText.height+alertText.y+70、confirmButton.y=height-50）。
 *
 * 测试形态：ctor 常量面在 stub 即完整（src 逐字入 stub）会先绿；
 * type 分派面等 implement 充真身。alertText 文本高度依赖字体测量——
 * eval 无真字体但 TextField.height 对给定 htmlText 是确定值，断言用
 * 相对关系（height == alertText.height + alertText.y + 70）而不是绝对
 * 像素数，规避字体环境耦合。
 */
@:access(mc.view.common.AlertWindow)
class AlertWindowTest {
	public function new() {}

	// ctor 常量（AlertWindow.as:34-42）：缺省宽 320、高 280、窗名、模态
	public function test_ctor_defaults() {
		var win = new AlertWindow();
		Assert.equals(320, win.width);
		Assert.equals(280, win.height);
		Assert.equals("AlertWindow", win.windowName);
		Assert.isTrue(win.mode);
	}

	// 自定义宽（param1）
	public function test_ctor_custom_width() {
		var win = new AlertWindow(400);
		Assert.equals(400, win.width);
		Assert.equals(280, win.height);
	}

	// data.type 四分（:143-168）：success/error/tip/缺省各自的图标显隐与
	// 文本 y。需要先 init() 装配（init 在 stub 里 throw——本测试此刻必
	// 败，implement 后转绿）
	public function test_type_branches_icon_visibility_and_text_y() {
		var win = new AlertWindow();
		win.init();
		win.data = {type: "success", text: "x"};
		Assert.isTrue(win.successIcon.visible);
		Assert.isFalse(win.errorIcon.visible);
		Assert.equals(170, win.alertText.y);

		win.data = {type: "error", text: "x"};
		Assert.isFalse(win.successIcon.visible);
		Assert.isTrue(win.errorIcon.visible);
		Assert.equals(170, win.alertText.y);

		win.data = {type: "tip", text: "x"};
		Assert.isFalse(win.successIcon.visible);
		Assert.isFalse(win.errorIcon.visible);
		Assert.equals(60, win.alertText.y);

		win.data = {text: "x"}; // 无 type → 缺省分支
		Assert.isFalse(win.successIcon.visible);
		Assert.isFalse(win.errorIcon.visible);
		Assert.equals(130, win.alertText.y);
	}

	// 高度重算（:172-176）：data.text 进来后 height=alertText.height+
	// alertText.y+70、confirmButton.y=height-50
	public function test_height_recalculation() {
		var win = new AlertWindow();
		win.init();
		win.data = {type: "success", text: "一行文本"};
		var expectHeight = win.alertText.height + win.alertText.y + 70;
		Assert.floatEquals(expectHeight, win.height);
		Assert.floatEquals(win.height - 50, win.confirmButton.y);
		// type 切到 tip（y 60 < 170）同文本 → 高度随 y 收缩
		win.data = {type: "tip", text: "一行文本"};
		var expectTip = win.alertText.height + 60 + 70;
		Assert.floatEquals(expectTip, win.height);
	}

	// 无 text 键 → 高度不重算（:171 hasOwnProperty 门）
	public function test_no_text_key_keeps_height() {
		var win = new AlertWindow();
		win.init();
		win.data = {type: "success"}; // 无 text
		Assert.equals(280, win.height);
	}
}
