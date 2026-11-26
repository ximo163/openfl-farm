package mc.view.common;

import mc.view.common.ConfirmWindow;
import support.MaterialFakes;
import utest.Assert;

/**
 * mc.view.common.ConfirmWindow 布局纯逻辑（issue #87 write-tests，对 stub
 * 失败）：ctor 常量与按钮排布。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/common/ConfirmWindow.as
 * —— ctor :34-54（width=param1 缺省 360、height=320、windowName
 * "ConfirmWindow"、mode=true；alertText.width=width-60、x=(width-alertText
 * .width)/2、y=170）；init :71-123（ConfirmIcon 居中 y=60——原文**无 null
 * 守卫**（:73 直取即读 .x）；confirmButton 64x25、x=width/2-64-10、
 * y=height-45、label "确定"、ButtonOrange；cancelButton 同尺寸、
 * x=width/2+10、y=height-45、label "取消"、ButtonBlue）；
 * confirmButtonClick :125-131（enable 门——confirmButton.enable==true 才
 * 关窗调 confirmFn）；confirmEnable setter :61-69（按钮存在时同步 enable
 * 与 mouseChildren——`if(this.confirmButton != null)` 守卫）。
 *
 * **本组与 AlertWindowTest 同红于 LipiPanel eval #2024**（见该文件类头
 * 注 1——ctor 撞库底座缺陷，implement/库底座修正后才通）；init 素材通道
 * 的 ConfirmIcon 无守卫 NPE 由 MaterialFakes 假域注入解（同 AlertWindowTest
 * 注 2）。ctor 常量面在 stub 即完整——但一旦 ctor 能跑通即先绿，作回归钉；
 * init 装配面等 implement。隔离：MaterialLib 单例，teardown reset 归位。
 */
@:access(mc.view.common.ConfirmWindow)
class ConfirmWindowTest {
	public function new() {}

	function teardown() {
		MaterialFakes.reset();
	}

	// ctor 常量（ConfirmWindow.as:34-54）
	public function test_ctor_defaults() {
		var win = new ConfirmWindow();
		Assert.equals(360, win.width);
		Assert.equals(320, win.height);
		Assert.equals("ConfirmWindow", win.windowName);
		Assert.isTrue(win.mode);
		// alertText 几何（ctor 内联：width-60、居中 x、y=170）
		Assert.equals(300, win.alertText.width);
		Assert.equals(30, win.alertText.x);
		Assert.equals(170, win.alertText.y);
	}

	// 按钮排布（init :96-115）：confirm 64x25 在中心线左 10、cancel 在右 10，
	// y 同 height-45。MaterialFakes.install 让 ConfirmIcon 命中跳过 NPE
	public function test_button_layout() {
		MaterialFakes.install();
		var win = new ConfirmWindow();
		win.init();
		Assert.equals(64, win.confirmButton.width);
		Assert.equals(25, win.confirmButton.height);
		Assert.equals(360 / 2 - 64 - 10, win.confirmButton.x);
		Assert.equals(320 - 45, win.confirmButton.y);
		Assert.equals("确定", win.confirmButton.label);
		Assert.equals(360 / 2 + 10, win.cancelButton.x);
		Assert.equals(320 - 45, win.cancelButton.y);
		Assert.equals("取消", win.cancelButton.label);
	}

	// confirmEnable setter 同步按钮 enable/mouseChildren（:61-69）——
	// init 后按钮存在：置 false 同步两个键、置回 true 复原
	public function test_confirmEnable_syncs_button() {
		MaterialFakes.install();
		var win = new ConfirmWindow();
		win.init();
		win.confirmEnable = false;
		Assert.isFalse(win.confirmButton.enable);
		Assert.isFalse(win.confirmButton.mouseChildren);
		win.confirmEnable = true;
		Assert.isTrue(win.confirmButton.enable);
		Assert.isTrue(win.confirmButton.mouseChildren);
	}

	// width 覆写联动 alertText.width（:66-70——width 改后 alertText.width
	// 跟到 width-60）。注：本用例不经 init（ctor 内联已完成 alertText
	// 装配、width 覆写是 ctor 即有的完整面）——stub 期 ctor 撞 #2024 红，
	// implement/库底座修正后即绿，无需素材注入
	public function test_width_override_resizes_alertText() {
		var win = new ConfirmWindow(400);
		Assert.equals(400 - 60, win.alertText.width);
	}
}
