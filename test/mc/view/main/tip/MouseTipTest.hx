package mc.view.main.tip;

import mc.view.main.tip.MouseTip;
import utest.Assert;

/**
 * mc.view.main.tip.MouseTip 布局纯逻辑（issue #87 write-tests——MouseTip
 * 本体已在 #19 顺手译出真身，本测试大半会当场绿，作回归钉；TipBg 素材
 * 缺失的分支形态若与原文不一致则留 implement 修正）：文本宽高 +10 撑
 * 背景、mX/mY 的贴鼠标偏移与防出屏翻转。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/main/tip/MouseTip.as
 * —— set data :30-40（null 落 ""、htmlText 后 tipBg.width=tipText.width
 * +10、height 同理）；set mX :42-63（无 stage → x=param1-5；有 stage：
 * param1-5<=0 → x=0、param1-5+width>stageWidth → x=stageWidth-width、
 * 否则 x=param1-5）；set mY :65-86（有 stage：param1+height+30>
 * stageHeight → y=param1-height-8（光标上方）否则 y=param1+20（下方）；
 * 无 stage → y=param1+20）。
 *
 * 素材通道：ctor 里 MaterialLib.getMaterial("TipBg") 在测试环境返回
 * null——addChild(null) 在 openfl 抛错，ctor 可能直接失败。若如此，
 * 本测试整组红——这正是 write-tests 期可接受的失败形态之一；implement
 * 期素材入库或构造守卫上线后转绿。mX/mY 数学用无 stage 分支（eval
 * 无真 stage 挂载）——x=param1-5、y=param1+20。
 */
@:access(mc.view.main.tip.MouseTip)
class MouseTipTest {
	public function new() {}

	function tryMake():MouseTip {
		try {
			return new MouseTip();
		} catch (e:Dynamic) {
			return null;
		}
	}

	// 构造：TipBg 素材缺失时 ctor 炸不炸是 implement 前的开放面——先把
	// 「能构造」钉为期望终态（implement 后素材入库或守卫上线必须能构造）
	public function test_constructible() {
		Assert.notNull(tryMake());
	}

	// mX/mY 无 stage 分支（:60-62/:82-84）：x=param1-5、y=param1+20
	public function test_mX_mY_without_stage() {
		var tip = tryMake();
		Assert.notNull(tip);
		if (tip == null) {
			return;
		}
		tip.mX = 105;
		Assert.equals(100, tip.x);
		tip.mY = 200;
		Assert.equals(220, tip.y);
	}

	// set data null 落 "" 不炸（:32-34）+ 背景随文本宽高 +10（:36-38）
	public function test_data_null_and_bg_sizing() {
		var tip = tryMake();
		Assert.notNull(tip);
		if (tip == null) {
			return;
		}
		tip.data = null;
		Assert.floatEquals(tip.tipText.width + 10, tip.tipBg.width);
		Assert.floatEquals(tip.tipText.height + 10, tip.tipBg.height);
		tip.data = "提示文本";
		Assert.floatEquals(tip.tipText.width + 10, tip.tipBg.width);
	}

	// mX/mY 写入后读回经 super 通道（Tip.as 的 _mX/_mY 存原值而非钳后值
	// ——super.mX=param1 在钳制前调用，存的是未钳原值）
	public function test_mX_mY_readback_raw() {
		var tip = tryMake();
		Assert.notNull(tip);
		if (tip == null) {
			return;
		}
		tip.mX = 105;
		Assert.equals(105, tip.mX);
		tip.mY = 200;
		Assert.equals(200, tip.mY);
	}
}
