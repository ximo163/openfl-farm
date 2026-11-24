package common.view.window;

import common.Consts;
import common.view.window.AlertWindow;
import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import openfl.text.TextField;
import utest.Assert;

/**
 * AlertWindow 纯逻辑（issue #41）：setData 的文案/标题/按钮/句柄提取表与
 * type 决定的 _alertText.y。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/window/
 * AlertWindow.as（ctor :37-48 常量；setData :55-204：width/height :63-80、
 * type 分支的 y——text=35 :102-113、缺省=110 :138-149、PIC/PIC2 :114-137、
 * text→_alertText.htmlText + width=width-40 :150-160、title 默认“提示”
 * :161-168、textLinkHandle/confirmButtonClickHandle :169-184、textSelectable
 * 默认 false :185-192、buttonText→_confirmButton.text :193-196、按钮居中
 * + visible=true :197-199；尾部 titleAlign==CENTER 时 panelTitle.x :200-203）。
 *
 * eval 适配：init() 的 _alertText/_confirmButton 钉 TextField/Button；
 * BaseWindow ctor 恒置 titleAlign=CENTER，setData 尾段要读 panelTitle
 * （:202），钉 new Label()（Panel._title 存取不依赖它，probe 实测）。
 * SUCCESS/ERROR/TIP 三型走 createIcon 的 getMaterial（eval 无素材返回
 * null 后 :251 `this._icon.x` 必炸）、PIC/PIC2 走 ExtLoader.load，均为
 * 显示装配，不进单测，由 CI web-smoke 兜底。
 */
@:access(common.view.window.AlertWindow)
@:access(com.qzone.qui.containers.Panel)
class AlertWindowTest {
	public function new() {}

	private function buildWindow():AlertWindow {
		var win = new AlertWindow(null);
		win._alertText = new TextField();
		win._confirmButton = new Button();
		win.panelTitle = new Label();
		return win;
	}

	// :37-48：构造器常量
	public function test_ctor_constants() {
		var win = new AlertWindow(null);
		Assert.equals(320, win.width);
		Assert.equals(240, win.height);
		Assert.equals("提示", win.title);
		Assert.equals(Consts.WINDOW_NAME_ALERT, win.windowName);
		Assert.isTrue(win.mode);
	}

	// :150-199：文案/按钮提取与落点（type=text 全链）
	public function test_setData_text_button_copy() {
		var win = buildWindow();
		var link = function(e) {};
		var click = function() {};
		win.data = {type: Consts.ALERT_TYPE_TEXT, text: "仓库已满，无法收获。", buttonText: "知道了", textSelectable: true, textLinkHandle: link, confirmButtonClickHandle: click};
		Assert.equals("仓库已满，无法收获。", win._alertText.text); // :152 htmlText 落文
		Assert.equals(280, Std.int(win._alertText.width)); // :153 width-40（默认 320）
		Assert.equals(35, Std.int(win._alertText.y)); // :108 text 型
		Assert.equals("知道了", win._confirmButton.text); // :195
		Assert.isTrue(win._confirmButton.visible); // :199
		Assert.isTrue(win._alertText.selectable); // :187
		Assert.isTrue(Reflect.compareMethods(win._textLinkHandle, link)); // :171
		Assert.isTrue(Reflect.compareMethods(win._confirmButtonClickHandle, click)); // :179
		Assert.equals("提示", win.title); // :167 缺省
	}

	// :102-149：type 表——text→35、缺省→110（其余型见类头，不进单测）
	public function test_setData_type_decides_alertText_y() {
		var cases:Array<{type:Dynamic, y:Float, why:String}> = [
			{type: Consts.ALERT_TYPE_TEXT, y: 35, why: "text 型 :108"},
			{type: null, y: 110, why: "无 type 落 else :144"}
		];
		for (c in cases) {
			var win = buildWindow();
			win.data = {type: c.type};
			Assert.equals(c.y, win._alertText.y, c.why);
			Assert.isNull(win._icon); // createIcon 对未知型早退 :245-248
		}
	}

	// :63-72 + :150-153：width 键先落 _alertText.width=width-20，text 键
	// 随后重写为 width-40——有 text 时终值是 width-40
	public function test_setData_width_key_and_text_ordering() {
		var win = buildWindow();
		win.data = {width: 400, text: "x"};
		Assert.equals(400, win.width);
		Assert.equals(360, Std.int(win._alertText.width)); // 400-40 终值

		var win2 = buildWindow();
		win2.data = {width: 400};
		Assert.equals(380, Std.int(win2._alertText.width)); // 无 text：400-20 :66
	}

	// :161-192：title 覆盖与句柄缺省清空
	public function test_setData_title_override_and_handle_defaults() {
		var win = buildWindow();
		win._textLinkHandle = function(e) {};
		win._confirmButtonClickHandle = function() {};
		win._alertText.selectable = true;
		win.data = {title: "系统提示"};
		Assert.equals("系统提示", win.title); // :163
		Assert.isNull(win._textLinkHandle); // :175
		Assert.isNull(win._confirmButtonClickHandle); // :183
		Assert.isFalse(win._alertText.selectable); // :191 默认关
		Assert.equals(240, win.height); // :79 缺省
	}
}
