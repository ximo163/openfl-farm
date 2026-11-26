package mc.view.main.tip;

import mc.view.main.tip.MouseTip;
import support.MaterialFakes;
import utest.Assert;

/**
 * mc.view.main.tip.MouseTip 布局纯逻辑（issue #87 write-tests——MouseTip
 * 本体已在 #19 顺手译出真身，本组作回归钉，经假域注入后**当场可绿**）：
 * data 的 htmlText 写入、mX/mY 的贴鼠标偏移与防出屏翻转。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/main/tip/MouseTip.as
 * —— set data :30-40（null 落 ""、htmlText=param1.toString()）；
 * set mX :42-63（无 stage → x=param1-5；有 stage：param1-5<=0 → x=0、
 * param1-5+width>stageWidth → x=stageWidth-width、否则 x=param1-5）；
 * set mY :65-86（有 stage：param1+height+30>stageHeight → y=param1-height-8
 * （光标上方）否则 y=param1+20（下方）；无 stage → y=param1+20）。
 *
 * **不测的：tipBg.width=tipText.width+10 撑背景（:36-38）**。openfl 的
 * set_width 内部是 `scaleX = value / rect.width`——eval 上无图形内容的
 * Sprite rect.width=0 → scaleX=infinity → 读回恒 0（容器内最小复现实证：
 * 空 sprite 赋 14 读回 0，带 graphics 内容的正常）。TipBg 是符号绑定 shim
 * （eval 无库可装是既定平台事实、graphics 为空），三条宽高断言在 eval
 * 永不可观测——该公式备录于此，归 CI 画面比对/场景对拍核验。
 *
 * 素材通道：ctor 里 `addChild(getMaterial("TipBg"))`（MouseTip.hx:20）原文
 * **无 null 守卫**——MaterialLib 空表时 getMaterial 返 null，addChild(null)
 * 抛 Error #2007。support/MaterialFakes 假域注入——TipBg 按名命中（src root
 * 已有真符号类 TipBg，MaterialFakes.hx 类头的编译表锚定使其可解析），ctor
 * 走完装配。mX/mY 数学用无 stage 分支（eval 无真 stage 挂载）——
 * x=param1-5、y=param1+20。隔离：MaterialLib 单例，teardown reset 归位。
 */
@:access(mc.view.main.tip.MouseTip)
class MouseTipTest {
	public function new() {}

	function setup() {
		MaterialFakes.install();
	}

	function teardown() {
		MaterialFakes.reset();
	}

	// 构造：TipBg 素材经假域命中后 ctor 必须能走完（终态——素材缺失的
	// #2007 是注入要消除的态，不再兜底）
	public function test_constructible() {
		Assert.notNull(new MouseTip());
	}

	// mX/mY 无 stage 分支（:60-62/:82-84）：x=param1-5、y=param1+20
	public function test_mX_mY_without_stage() {
		var tip = new MouseTip();
		tip.mX = 105;
		Assert.equals(100, tip.x);
		tip.mY = 200;
		Assert.equals(220, tip.y);
	}

	// set data null 落 "" 不炸（:32-34）：htmlText 写入空串可观测
	public function test_data_null_writes_empty_htmlText() {
		var tip = new MouseTip();
		tip.data = null;
		Assert.equals("", tip.tipText.htmlText);
	}

	// set data 字符串经 toString 写入 htmlText（:35）
	public function test_data_string_writes_htmlText() {
		var tip = new MouseTip();
		tip.data = "提示文本";
		Assert.equals("提示文本", tip.tipText.htmlText);
	}

	// mX/mY 写入后读回经 super 通道（Tip.as 的 _mX/_mY 存原值而非钳后值
	// ——super.mX=param1 在钳制前调用，存的是未钳原值）
	public function test_mX_mY_readback_raw() {
		var tip = new MouseTip();
		tip.mX = 105;
		Assert.equals(105, tip.mX);
		tip.mY = 200;
		Assert.equals(200, tip.mY);
	}
}
