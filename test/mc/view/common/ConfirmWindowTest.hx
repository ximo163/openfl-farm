package mc.view.common;

import mc.view.common.ConfirmWindow;
import utest.Assert;

/**
 * mc.view.common.ConfirmWindow 布局纯逻辑（issue #87 write-tests，对 stub
 * 失败）：ctor 常量与按钮排布。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/common/ConfirmWindow.as
 * —— ctor :34-54（width=param1 缺省 360、height=320、windowName
 * "ConfirmWindow"、mode=true；alertText.width=width-60、x=(width-alertText
 * .width)/2、y=170）；init :71-123（confirmButton 64x25、x=width/2-width-10、
 * y=height-45、label "确定"；cancelButton 同尺寸、x=width/2+10、y=height-45、
 * label "取消"）；confirmButtonClick :125-131（enable 门——
 * confirmButton.enable==true 才关窗调 confirmFn）；confirmEnable setter
 * :61-69（按钮存在时同步 enable 与 mouseChildren）。
 *
 * ctor 常量面在 stub 即完整会先绿；init 装配面等 implement。
 */
@:access(mc.view.common.ConfirmWindow)
class ConfirmWindowTest {
	public function new() {}

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
	// y 同height-45
	public function test_button_layout() {
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
	// init 前按钮 null 时只记标志位不炸
	public function test_confirmEnable_syncs_button() {
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
	// 跟到 width-60）
	public function test_width_override_resizes_alertText() {
		var win = new ConfirmWindow(400);
		Assert.equals(400 - 60, win.alertText.width);
	}
}
