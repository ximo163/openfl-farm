package common.view.tip;

import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.text.TextField;
import utest.Assert;

/**
 * CropInfoTip 作物信息提示纯逻辑（issue #42）：data 的 null→"" 归一与
 * htmlText 萅位。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/tip/CropInfoTip.as
 * （data :21-31；:23-26 null → ""；:27 _tipText.htmlText = param1.toString()；
 * :31 _data = param1）。
 *
 * MouseTip 一族：空实例 + 钉 _tipText/_tipBg（eval 上 TextField 只当
 * 字符串持有器，DogFoodWindowTest 先例；htmlText 原样回读）。
 * stub 阶段失败点：data 是 throw stub。
 */
@:access(common.view.tip.MouseTip)
class CropInfoTipTest {
	public function new() {}

	private function makeTip():CropInfoTip {
		var tip = Type.createEmptyInstance(CropInfoTip);
		Reflect.setField(tip, "__transform", new Matrix());
		tip._tipBg = new Sprite();
		tip._tipText = new TextField();
		return tip;
	}

	// :23-26/:27：data null 先归一 ""，htmlText 与 _data 都落 ""
	public function test_data_null_normalizes_to_empty_string() {
		var tip = makeTip();
		tip.data = null;
		Assert.equals("", tip.data); // :31
		Assert.equals("", tip._tipText.htmlText); // :27
	}

	// :27/:31：html 文本原样落位（增产标记的富文本形态，LandInfoTip.as:295
	// 同款 <font color="#FF6600"> 片段），_data 同值
	public function test_data_sets_html_text_and_data() {
		var tip = makeTip();
		tip.data = '<font color="#FF6600">增产10%</font>&nbsp;白萝卜';
		Assert.equals('<font color="#FF6600">增产10%</font>&nbsp;白萝卜', tip._tipText.htmlText);
		Assert.equals('<font color="#FF6600">增产10%</font>&nbsp;白萝卜', tip.data);
	}
}
