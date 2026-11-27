package mc.view.common;

import mc.view.common.HtmlTextWindow;
import utest.Assert;

/**
 * mc.view.common.HtmlTextWindow 布局纯逻辑（issue #87 write-tests，对 stub
 * 失败）：常量、type 决定的钮装配、高度公式、关窗回报。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/common/HtmlTextWindow.as
 * —— 常量 OK=2/CANCEL=4（:10-12）；ctor :34-45（_detail 缺省 CANCEL）；
 * init :53-90（textFormat 缺省 Verdana/12/3355443、leading=6；_txt.x=
 * padding+2、y=27+padding、width=width-(padding+2)*2；未 isSetHeight 时
 * height=_txt.textHeight+27+padding*2+45；vMiddle 时 _txt.y=int(height/2-
 * textHeight/2)-13；type==2||6 装确定钮（addButton(okLabel,"ButtonOrange",
 * 68,25)）、type==4||6 装取消钮）；closeHandler :47-51（先 _closeFn(_detail)
 * 后 super——确定钮把 _detail 置 OK 再关）。
 *
 * **本组与 AlertWindowTest 同红于 LipiPanel eval #2024**（见该文件类头
 * 注 1——ctor 撞库底座缺陷，implement/库底座修正后才通）。
 */
@:access(mc.view.common.HtmlTextWindow)
class HtmlTextWindowTest {
	public function new() {}

	// 常量（HtmlTextWindow.as:10-12）
	public function test_constants() {
		Assert.equals(2, HtmlTextWindow.OK);
		Assert.equals(4, HtmlTextWindow.CANCEL);
	}

	// ctor 缺省态（:34-45）：_detail=CANCEL、okLabel "确定"
	public function test_ctor_defaults() {
		var win = new HtmlTextWindow("文本");
		Assert.equals(HtmlTextWindow.CANCEL, win._detail);
		Assert.equals("确定", win.okLabel);
		Assert.isFalse(win.vMiddle);
		Assert.isFalse(win.isSetHeight);
	}

	// 高度公式（:66-68）：未 isSetHeight 时 height=textHeight+27+padding*2+45。
	// padding=12 缺省 → +27+24+45=+96。文本高度依赖字体测量，断言相对关系
	public function test_height_formula() {
		var win = new HtmlTextWindow("一行", 2, 12, function(d) {});
		win.width = 300;
		win.init();
		Assert.floatEquals(win._txt.textHeight + 27 + 12 * 2 + 45, win.height);
	}

	// isSetHeight=true 时高度不被公式覆盖（:66 门）
	public function test_isSetHeight_skips_formula() {
		var win = new HtmlTextWindow("一行", 2, 12, function(d) {});
		win.width = 300;
		win.isSetHeight = true;
		win.height = 500;
		win.init();
		Assert.equals(500, win.height);
	}

	// 文本排版（:56-64）：x=padding+2、y=27+padding、宽=width-(padding+2)*2
	public function test_text_layout() {
		var win = new HtmlTextWindow("一行", 2, 12, function(d) {});
		win.width = 300;
		win.init();
		Assert.equals(14, win._txt.x);
		Assert.equals(39, win._txt.y);
		Assert.equals(300 - 28, win._txt.width);
	}

	// type 钮装配（:72-89）：type 2 只装确定、type 4 只装取消、type 6 双装。
	// addButton 是 AddButtonWindow 真实已实现的通道——经 numChildren 增量判
	public function test_type_button_assembly() {
		var win2 = new HtmlTextWindow("t", 2, 12, function(d) {});
		var before2 = win2.numChildren;
		win2.init();
		Assert.equals(before2 + 1, win2.numChildren); // 仅确定钮

		var win4 = new HtmlTextWindow("t", 4, 12, function(d) {});
		var before4 = win4.numChildren;
		win4.init();
		Assert.equals(before4 + 1, win4.numChildren); // 仅取消钮

		var win6 = new HtmlTextWindow("t", 6, 12, function(d) {});
		var before6 = win6.numChildren;
		win6.init();
		Assert.equals(before6 + 2, win6.numChildren); // 双钮
	}

	// closeHandler 回报（:47-51）：未点钮直接关 → _detail 仍 CANCEL，
	// closeFn 收 4
	public function test_close_reports_cancel_by_default() {
		var got = -1;
		var win = new HtmlTextWindow("t", 2, 12, function(d) got = d);
		win.init();
		win.closeWindow(); // AddButtonWindow.closeWindow → closeHandler
		Assert.equals(HtmlTextWindow.CANCEL, got);
	}

	// vMiddle 文本垂直居中（:69-71）：y=int(height/2-textHeight/2)-13
	public function test_vMiddle_vertical_centering() {
		var win = new HtmlTextWindow("一行", 2, 12, function(d) {});
		win.width = 300;
		win.vMiddle = true;
		win.init();
		var expect = Std.int(win.height / 2 - win._txt.textHeight / 2) - 13;
		Assert.equals(expect, Std.int(win._txt.y));
	}
}
