package common.view.tip;

import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.text.TextField;
import utest.Assert;

/**
 * MouseTip 鼠标提示纯逻辑（issue #42）：data 的 null→"" 归一与文本落位、
 * 无舞台时 mX/mY 的 -5/+20 跟随偏移。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/tip/MouseTip.as
 * （data :32-42、mX :44-67、mY :69-88）。
 *
 * ctor 取 TipBg 素材（:21）在 eval 无资源会抛 #2007——空实例 + 钉字段驱动
 * （ToolBarTest 先例）；openfl 的 x/y 走 __transform（DisplayObject.hx:1008，
 * ctors 未跑为 null），测试侧 Reflect 补一枚 Matrix 后即可读写坐标。
 * stage 恒 null → :61-65/:82-86 的无舞台分支（-=5 / +=20）。
 * stub 阶段失败点：data/mX/mY 是 throw stub。
 */
@:access(common.view.tip.MouseTip)
class MouseTipTest {
	public function new() {}

	private function makeTip():MouseTip {
		var tip = Type.createEmptyInstance(MouseTip);
		Reflect.setField(tip, "__transform", new Matrix());
		tip._tipBg = new Sprite();
		tip._tipText = new TextField();
		return tip;
	}

	// :32-42：data null 先归一 ""（:34-37），文本与 _data 都落 ""
	public function test_data_null_normalizes_to_empty_string() {
		var tip = makeTip();
		tip.data = null;
		Assert.equals("", tip.data); // :41 super.data = param1（归一后的 ""）
		Assert.equals("", tip._tipText.text); // :38
	}

	// :38/:41：文本原样落位，_data 同值
	public function test_data_sets_text_and_data() {
		var tip = makeTip();
		tip.data = "土地 6 级可开垦";
		Assert.equals("土地 6 级可开垦", tip._tipText.text);
		Assert.equals("土地 6 级可开垦", tip.data);
	}

	// :44-67（stage null → :61-65）：mX 记原值，x 落 m-5
	public function test_mX_stageless_offsets_minus_5() {
		var tip = makeTip();
		tip.mX = 100;
		Assert.equals(100, tip.mX); // :46 super.mX 记原始鼠标坐标
		Assert.equals(95.0, tip.x); // :65
	}

	// :69-88（stage null → :82-86）：mY 记原值，y 落 m+20
	public function test_mY_stageless_offsets_plus_20() {
		var tip = makeTip();
		tip.mY = 200;
		Assert.equals(200, tip.mY); // :71
		Assert.equals(220.0, tip.y); // :86
	}
}
