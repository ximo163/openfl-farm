package mc.view.common;

import mc.view.common.AlertWindow;
import support.MaterialFakes;
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
 * **本组当前红于两道独立闸门，均属 write-tests 期可接受失败形态**：
 * 1. ctor 撞 LipiPanel 的 eval `#2024`——**main 既有库底座缺陷（#86
 *    交付面 e4544067），机制已实证定位**：initPanel 的
 *    `super.addChild(this._contentPane)`（LipiPanel.hx:102/111/120 三处）
 *    在 Haxe 只上溯方法体、`this` 不变——openfl 9.5.2 原生 addChild
 *    一行转发 `addChildAt(child, numChildren)`，而 addChildAt 被
 *    LipiPanel 自身覆写（:75-80 重定向进 _contentPane），于是
 *    contentPane 被加进 contentPane 自身、构造即抛
 *    `Error #2024: An object cannot be added as a child of itself`。
 *    eval 最小复现：`new com.minutes.ui.core.LipiPanel()` 裸构造即崩
 *    （write-tests visit 3 容器实测）。AS3 原版无此问题——super 通道
 *    在 AVM2 不经 public 覆写派发。**#87 implement 无法修复**（缺陷在
 *    #86 库底座、不在本片 57 类范围），已按 CLAUDE.md 机械自检规矩
 *    报告待开 issue 跟踪（write-tests 容器无 GitHub 写凭证，发现链路
 *    全录于此）；与 lessons #86 节 initPanel 条目是同区域两个独立坑
 *    （那条管 private 名碰撞，这条管重定向覆写与 super 通道互锁）。
 *    窗口族四组测试（本组/ConfirmWindow/HtmlTextWindow/ValidateCodeWindow）
 *    转绿以库底座修正为前提。
 * 2. implement 充真身后 init 的素材通道需假域注入——getMaterial
 *   （"SuccessIcon"/"ErrorIcon"）原文**无 null 守卫**（:84-85 直取即读
 *   .x/.y），素材缺失即 NPE。support/MaterialFakes 假域注入让两个符号
 *   按名命中（MaterialFakes.hx 类头——编译表锚定 + push 普通域），
 *   init 才能走完装配段。round 1 review 驳回的「NPE 永红」即由注入解法。
 *
 * alertText 文本高度依赖字体测量——eval 无真字体但 TextField.height 对
 * 给定 htmlText 是确定值，断言用相对关系（height == alertText.height +
 * alertText.y + 70）而不是绝对像素数，规避字体环境耦合。隔离：MaterialLib
 * 是单例，teardown reset 归位（MaterialProxyTest 等以注册表为空为前提）。
 */
@:access(mc.view.common.AlertWindow)
class AlertWindowTest {
	public function new() {}

	function teardown() {
		MaterialFakes.reset();
	}

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
	// 文本 y。MaterialFakes.install 让 init 的 SuccessIcon/ErrorIcon 命中
	public function test_type_branches_icon_visibility_and_text_y() {
		MaterialFakes.install();
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
		MaterialFakes.install();
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
		MaterialFakes.install();
		var win = new AlertWindow();
		win.init();
		win.data = {type: "success"}; // 无 text
		Assert.equals(280, win.height);
	}
}
