package mc.view.main.game;

import mc.view.main.game.ValidateCodeWindow;
import utest.Assert;

/**
 * mc.view.main.game.ValidateCodeWindow 纯逻辑（issue #87 write-tests，对
 * stub 失败）：ctor 常量、text 存取。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/main/game/ValidateCodeWindow.as
 * —— ctor :32-39（width 320、height 250、mode=true）；set text :63-70
 * （存 _text + postText 非空时同步文本）；_KEY_UP :41-47
 * （charCode 13 即 Enter 触发 confirmFn）；confirmFn :54-61（lipiT.text
 * .length>0 才提交并关窗）；_padding=20/_headHeight=30（:18/:28）。
 *
 * **输入约束面不可在 eval 单测——round 1 驳回处置（删除项备录）**：
 * round 1 的 test_input_constraints_documented 是 isTrue(true) 占位，本组
 * 已删。约束值（maxChars=8、restrict="a-z A-Z 0-9"、初始文本
 * "请输入图形验证码"、borderColor=3381759——ValidateCodeWindow.as:96-100）
 * 在 init 的装配段内，该段即便经 MaterialFakes 假域注入拿到
 * ValidateCodeContent，也在 `this.stage.focus = this.lipiT`（:117）崩
 * eval——eval 无真 stage、focus 写不进。约束面属素材装配+焦点行为，由
 * CI 画面比对覆盖，此处仅以注释备录期望值，implement 充真身时不回补
 * eval 断言。
 *
 * 测试形态：ctor 常量面在 stub 掷错前先撞 not implemented（ctor 末行
 * throw）——全组等 implement；text 存取在 postText null 态应只存不炸
 * （setter 的 null 门是原文有的守卫）。
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

	// init 缺素材不炸（:83 if(content) 门——MaterialLib 空表 getMaterial
	// 返回 null，整个装配段跳过、方法与 super.init 都不触）。注：本用例
	// 构造 ValidateCodeWindow 需 ctor 先通——stub 期 ctor 掷 not implemented，
	// 与上两条同属「等 implement」终态，非新增占位
	public function test_init_without_material_noop_safe() {
		var win = new ValidateCodeWindow();
		win.init(); // 不炸即过——素材缺失空转是原文有的形态
		Assert.isTrue(true);
	}
}
