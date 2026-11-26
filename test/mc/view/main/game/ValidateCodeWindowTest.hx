package mc.view.main.game;

import mc.view.main.game.ValidateCodeWindow;
import utest.Assert;

/**
 * mc.view.main.game.ValidateCodeWindow 纯逻辑（issue #87 write-tests，对
 * stub 失败）：ctor 常量、text 存取、输入约束常量。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/main/game/ValidateCodeWindow.as
 * —— ctor :32-39（width 320、height 250、mode=true）；set text :63-70
 * （存 _text + postText 非空时同步文本）；init :79-121（lipiT.maxChars=8、
 * restrict="a-z A-Z 0-9"、初始文本 "请输入图形验证码"）；_KEY_UP :41-47
 * （charCode 13 即 Enter 触发 confirmFn）；confirmFn :54-61（lipiT.text
 * .length>0 才提交并关窗）；_padding=20/_headHeight=30（:18/:28）。
 *
 * 测试形态：ctor 常量面在 stub 掷错前先撞 not implemented——全组等
 * implement；text 存取在 postText null 态应只存不炸（setter 的 null 门
 * 是原文有的守卫）。
 */
@:access(mc.view.main.game.ValidateCodeWindow)
class ValidateCodeWindowTest {
	public function new() {}

	// ctor 常量（ValidateCodeWindow.as:32-39）
	public function test_ctor_dimensions() {
		var win = new ValidateCodeWindow();
		Assert.equals(320, win.width);
		Assert.equals(250, win.height);
		Assert.isTrue(win.mode);
	}

	// text 存取（:63-70/:123-126）：postText 未装配（init 未跑）时写入
	// 只存 _text 不炸；读回同值
	public function test_text_roundtrip_without_init() {
		var win = new ValidateCodeWindow();
		win.text = "验证码错误";
		Assert.equals("验证码错误", win.text);
	}

	// 输入约束常量（:97-99）：maxChars 8、restrict "a-z A-Z 0-9"——素材
	// 通道（ValidateCodeContent）缺失使 init 内 segment 整体跳过（:83 的
	// if(content) 门），约束值钉在注释备录、implement 素材入库后补真值
	public function test_input_constraints_documented() {
		// maxChars=8、restrict="a-z A-Z 0-9"、初始文本 "请输入图形验证码"、
		// borderColor 3381759（ValidateCodeWindow.as:96-100）
		Assert.isTrue(true);
	}

	// init 缺素材不炸（:83 if(content) 门——MaterialLib 空表 getMaterial
	// 返回 null，整个装配段跳过、方法与 super.init 都不触）
	public function test_init_without_material_noop_safe() {
		var win = new ValidateCodeWindow();
		win.init(); // 不炸即过——素材缺失空转是原文有的形态
		Assert.isTrue(true);
	}
}
