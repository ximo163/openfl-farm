package common.view.window;

import common.Consts;
import common.view.window.ValidateCodeWindow;
import openfl.events.Event;
import openfl.text.TextField;
import utest.Assert;

/**
 * ValidateCodeWindow 纯逻辑（issue #41）：onOK 的验证码合法性门（空串/
 * /^[a-z0-9]*$/ig）、text 访问器镜像、setData 的回调提取与输入框复位。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/window/
 * ValidateCodeWindow.as（onOK :55-73：:58-61 空串早退、:62-66 正则
 * `/^[a-z0-9]*$/ig` 不过早退、:67-72 通过后 removePicture + super.close() +
 * `_callback(_loc1_)`；INPUT_TIP :32 "输入图形验证码"；text 访问器
 * :167-196；setData :176-191 的 lipiT 复位门与 callback 提取）。
 *
 * ctor 链（AddButtonWindow→BaseWindow）在 eval 可构造；lipiT/postText 产自
 * init()（需素材符号），单测按 DogFoodWindowTest 先例钉 TextField 扮演
 * 字符串持有器，_callback 钉闭包。loadCodePicture 的 `getChildByName
 * ("__content__")` 在未挂素材的实例上得 null 早退（:94-98），不触发 Loader。
 */
@:access(common.view.window.ValidateCodeWindow)
class ValidateCodeWindowTest {
	public function new() {}

	private function buildWindow():ValidateCodeWindow {
		var win = new ValidateCodeWindow(null);
		win.lipiT = new TextField();
		win._callback = null;
		return win;
	}

	// :40-53：构造器常量（窗形、提示语标题、控件名、模态）
	public function test_ctor_constants() {
		var win = new ValidateCodeWindow(null);
		Assert.equals(320, win.width);
		Assert.equals(250, win.height);
		Assert.equals("输入图形验证码", win.title); // :46 = INPUT_TIP :32
		Assert.equals(Consts.WINDOW_NAME_VALIDATE, win.windowName); // :47
		Assert.isTrue(win.mode); // :45
	}

	// :55-73：正则门与回调/close 语义表
	public function test_onOK_validates_input_and_fires_callback() {
		//（ig 标志：i 放行大写；* 放行空串但空串已被 :58-61 先拦）
		var cases:Array<{input:String, ok:Bool, why:String}> = [
			{input: "", ok: false, why: "空串 :58-61 早退"},
			{input: "abc123", ok: true, why: "小写字母+数字"},
			{input: "ABC123", ok: true, why: "i 标志放行大写"},
			{input: "a1B2c3", ok: true, why: "混合大小写数字"},
			{input: "a-b", ok: false, why: "连字符不在 [a-z0-9]"},
			{input: " ab", ok: false, why: "空格不匹配"},
			{input: "验证码", ok: false, why: "中文不匹配"}
		];
		for (c in cases) {
			var win = buildWindow();
			win.lipiT.text = c.input;
			var closeCount = 0;
			win.addEventListener(Event.CLOSE, function(e) closeCount++);
			var got:String = null;
			var called = 0;
			win._callback = function(code:String) {
				called++;
				got = code;
			};
			win.onOK();
			Assert.equals(c.ok ? 1 : 0, called, 'input=${c.input}（${c.why}）');
			Assert.equals(c.ok ? 1 : 0, closeCount, 'input=${c.input} close 次数');
			if (c.ok) {
				Assert.equals(c.input, got);
			} else {
				Assert.isNull(got);
			}
		}
	}

	// :167-174 + :193-196：text 直存 _text；postText 建好后镜像
	public function test_text_setter_stores_and_mirrors_to_postText() {
		var win = new ValidateCodeWindow(null);
		Assert.isNull(win.text); // ctor 未赋
		win.text = "请输入下方验证码";
		Assert.equals("请输入下方验证码", win.text);
		// postText null（init 未跑）：不崩、只存 _text
		Assert.isNull(win.postText);
		// postText 建好后（init :123 之后的生产形态）镜像写入
		win.postText = new TextField();
		win.text = "第二次提示";
		Assert.equals("第二次提示", win.postText.text);
		Assert.equals("第二次提示", win.text);
	}

	// :176-191：setData 提取 data["callback"]、复位 lipiT（非提示文案才清）
	public function test_setData_extracts_callback_and_resets_input() {
		// 非提示文案的残留输入 → 清空（:178-181）
		var win = buildWindow();
		win.lipiT.text = "旧输入";
		var fn = function(code:String) {};
		win.data = {callback: fn};
		Assert.equals("", win.lipiT.text);
		Assert.isTrue(Reflect.compareMethods(win._callback, fn));

		// 恰为提示文案 → 保持（:178 的 != INPUT_TIP 门）
		var win2 = buildWindow();
		win2.lipiT.text = "输入图形验证码"; // :32
		win2.data = {};
		Assert.equals("输入图形验证码", win2.lipiT.text);
		Assert.isNull(win2._callback); // :187-190 缺键 → null

		// 已有回调被无 callback 的数据重置为 null（:183-190）
		var win3 = buildWindow();
		win3._callback = fn;
		win3.data = {};
		Assert.isNull(win3._callback);
	}
}
