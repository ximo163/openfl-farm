package common.view.window;

import common.Consts;
import common.view.window.ConfirmWindow;
import com.qzone.qui.controls.Button;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import utest.Assert;

/**
 * ConfirmWindow 纯逻辑（issue #41）：setData 的字段提取表、confirmEnable/
 * confirmFn 访问器、keyEnter→confirmButtonClick 的确认回调语义。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/window/
 * ConfirmWindow.as（ctor :35-46 常量；setData :219-296：error→_errorText
 * :225-228、text→_alertText.htmlText :229-233、confirmFn :238-245、title
 * 默认“确定” :246-253、width 默认 320 且 _alertText.width=width-20 :254-263、
 * height 默认 240 :264-271、confirmEnable :272-279、hideIcon→adjustIcon 的
 * _alertText.height 110/80 :280-290+:184-202、尾段按钮镜像 :292-295；
 * confirmEnable setter :93-103 按钮四连写；confirmButtonClick :146-157：
 * enabled 门 → super.close() → _confirmFn() → _confirmFn=null；keyEnter
 * :214-217 直落 confirmButtonClick）。
 *
 * eval 适配（DogFoodWindowTest 先例）：init() 产出的 _alertText/_errorText/
 * _confirmButton 钉等价对象（TextField 字符串持有器 / Button）；:224 的
 * `_errorText.text = ""` 无 null 门，必须先钉。所有数据都带 hideIcon 键——
 * 缺键分支 :288 会走 customizeIcon()，其 getMaterial("ConfirmIcon") 在 eval
 * 无素材得 null、addChild(null) 必炸（:169-182），那是显示装配，留给 CI。
 */
@:access(common.view.window.ConfirmWindow)
class ConfirmWindowTest {
	public function new() {}

	private function buildWindow():ConfirmWindow {
		var win = new ConfirmWindow(null);
		win._alertText = new TextField();
		win._errorText = new TextField();
		return win;
	}

	// :35-46：构造器常量
	public function test_ctor_constants() {
		var win = new ConfirmWindow(null);
		Assert.equals(320, win.width);
		Assert.equals(240, win.height);
		Assert.equals("确定", win.title);
		Assert.equals(Consts.WINDOW_NAME_CONFIRM, win.windowName);
		Assert.isTrue(win.mode);
		Assert.isTrue(win.confirmEnable); // :44
		Assert.isFalse(win._hideIcon); // :43
		Assert.isNull(win.confirmFn); // :45
	}

	// :219-296：提取表（数据全带 hideIcon，理由见类头）
	public function test_setData_extracts_fields() {
		// 显式覆盖各键
		var win = buildWindow();
		var fn = function() {};
		win.data = {text: "卖出手上的作物吗？", error: "余额不足。", title: "卖出", width: 400, height: 300, confirmFn: fn, confirmEnable: false, hideIcon: true};
		Assert.equals("余额不足。", win._errorText.text); // :227 `data["error"] || ""`
		Assert.equals("卖出手上的作物吗？", win._alertText.text); // :231 htmlText 落文
		Assert.equals("卖出", win.title); // :248
		Assert.equals(400, win.width); // :256
		Assert.equals(300, win.height); // :266
		Assert.isTrue(Reflect.compareMethods(win._confirmFn, fn)); // :240
		Assert.isFalse(win.confirmEnable); // :274
		Assert.isTrue(win._hideIcon); // :282
		Assert.equals(110, Std.int(win._alertText.height)); // adjustIcon hideIcon 分支 :192
		// 宽度落点：width 有键时 _alertText.width = width-20（:257）
		Assert.equals(380, Std.int(win._alertText.width));

		// 全缺省：error 清空、title/width/height 回默认、回调 null、图标开
		var win2 = buildWindow();
		win2._errorText.text = "旧错误";
		win2.data = {hideIcon: false};
		Assert.equals("", win2._errorText.text); // :224 无条件清
		Assert.equals("", win2._alertText.htmlText); // text 缺键整支跳过
		Assert.equals("确定", win2.title); // :252
		Assert.equals(320, win2.width); // :261
		Assert.equals(240, win2.height); // :270
		Assert.isNull(win2._confirmFn); // :244
		Assert.isTrue(win2.confirmEnable); // :278
		Assert.isFalse(win2._hideIcon); // :287
		Assert.equals(80, Std.int(win2._alertText.height)); // adjustIcon else :200
		Assert.equals(300, Std.int(win2._alertText.width)); // 320-20 :262

		// error 显式空串：`data["error"] || ""` → ""
		var win3 = buildWindow();
		win3._errorText.text = "旧错误";
		win3.data = {error: "", hideIcon: true};
		Assert.equals("", win3._errorText.text);
	}

	// :292-295 + :93-103：confirmEnable 联动按钮四连写
	public function test_confirmEnable_gate_writes_button() {
		var win = buildWindow();
		win._confirmButton = new Button();
		win.confirmEnable = false;
		Assert.isFalse(win._confirmEnable);
		Assert.isFalse(win._confirmButton.enabled);
		Assert.isFalse(win._confirmButton.mouseEnabled);
		Assert.isFalse(win._confirmButton.mouseChildren);
		Assert.isFalse(win._confirmButton.useHandCursor);
		win.confirmEnable = true;
		Assert.isTrue(win._confirmButton.enabled);
		Assert.isTrue(win._confirmButton.mouseEnabled);
		// setData 尾段同样按 confirmEnable 镜像按钮（:292-295）
		win.data = {confirmEnable: false, hideIcon: true};
		Assert.isFalse(win._confirmButton.enabled);
	}

	// :146-157 + :214-217：keyEnter → confirmButtonClick：enabled 时关窗 +
	// 单发回调 + 清 _confirmFn；禁用时全不发生
	public function test_keyEnter_fires_confirm_fn_once_then_closes() {
		var win = buildWindow();
		win._confirmButton = new Button(); // enabled 默认 true
		var closeCount = 0;
		win.addEventListener(Event.CLOSE, function(e) closeCount++);
		var called = 0;
		win._confirmFn = function() called++;
		win.keyEnter(new KeyboardEvent(KeyboardEvent.KEY_UP));
		Assert.equals(1, called);
		Assert.equals(1, closeCount); // super.close() :150
		Assert.isNull(win._confirmFn); // :155 用后即清

		// 二次 keyEnter：_confirmFn 已清，只关窗不再回调
		win.keyEnter(new KeyboardEvent(KeyboardEvent.KEY_UP));
		Assert.equals(1, called);
		Assert.equals(2, closeCount);

		// 按钮禁用：门 :148 直接拦，回调/关窗都不发生
		var win2 = buildWindow();
		win2._confirmButton = new Button();
		win2._confirmButton.enabled = false;
		var closeCount2 = 0;
		win2.addEventListener(Event.CLOSE, function(e) closeCount2++);
		var called2 = 0;
		win2._confirmFn = function() called2++;
		win2.keyEnter(new KeyboardEvent(KeyboardEvent.KEY_UP));
		Assert.equals(0, called2);
		Assert.equals(0, closeCount2);
		Assert.notNull(win2._confirmFn); // 未清空
	}
}
