package common.view.tip;

import com.qzone.utils.StringUtil;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.text.TextField;
import utest.Assert;

/**
 * DiyMouseTip 装饰编辑鼠标提示纯逻辑（issue #42）：data 的装饰名/到期文案
 * 拼装（含原文的 "11" 尾）、无舞台时 mX/mY 的 -5/+20 跟随偏移。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/tip/DiyMouseTip.as
 * （mX :38-42、data :44-65、mY :67-71）。
 *
 * 载荷形状：legacy/decompiled/decorate_v_0/scripts/module/decorate/
 * DecorateView.as:213-218 `{itemName: DecorateItem._name, validTime:
 * DecorateItem._validTime}`（validTime 0 = 无限期，:47-53 的分岔）。
 * :53 的 `"到期时间：" + dateFormat(...) + "11"` 尾串 "11" 是原文笔误，
 * 逐字保留（照抄不修，deviations 只进 spec/deviations.json—— lessons #8 条）。
 * 空实例 + 钉字段驱动（MouseTipTest 同款）；期望侧的 dateFormat 直接调
 * 已译工具（被测面是拼装，不是日期格式化）。
 * stub 阶段失败点：data/mX/mY 是 throw stub。
 */
@:access(common.view.tip.DiyMouseTip)
class DiyMouseTipTest {
	public function new() {}

	private function makeTip():DiyMouseTip {
		var tip = Type.createEmptyInstance(DiyMouseTip);
		Reflect.setField(tip, "__transform", new Matrix());
		tip.m_tipBg = new Sprite();
		tip.m_tipText = new TextField();
		tip.m_tipText2 = new TextField();
		return tip;
	}

	// :46/:49：itemName 落首行文本；validTime 0 → 「到期时间：无限期」
	public function test_data_zero_valid_time_reads_unlimited() {
		var tip = makeTip();
		tip.data = {itemName: "稻草人", validTime: 0};
		Assert.equals("稻草人", tip.m_tipText.text); // :46
		Assert.equals("到期时间：无限期", tip.m_tipText2.text); // :49
		Assert.equals("稻草人", Reflect.field(tip.data, "itemName")); // :64 super.data 原样
	}

	// :53：非零 validTime → 「到期时间：」+ dateFormat(秒) + 原文笔误 "11"
	public function test_data_finite_valid_time_appends_original_11_suffix() {
		var tip = makeTip();
		tip.data = {itemName: "木牌", validTime: 1293840000};
		Assert.equals("木牌", tip.m_tipText.text);
		Assert.equals("到期时间：" + StringUtil.dateFormat(1293840000) + "11", tip.m_tipText2.text); // :53
	}

	// :38-42：mX 记原值，x 落 m-5
	public function test_mX_stageless_offsets_minus_5() {
		var tip = makeTip();
		tip.mX = 50;
		Assert.equals(50, tip.mX); // :39
		Assert.equals(45.0, tip.x); // :41
	}

	// :67-71：mY 记原值，y 落 m+20
	public function test_mY_stageless_offsets_plus_20() {
		var tip = makeTip();
		tip.mY = 60;
		Assert.equals(60, tip.mY); // :69
		Assert.equals(80.0, tip.y); // :70
	}
}
