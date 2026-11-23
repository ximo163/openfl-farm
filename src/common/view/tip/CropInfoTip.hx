package common.view.tip;

import common.Consts;
import openfl.filters.GlowFilter;
import openfl.text.TextFormat;

/**
 * common.view.tip.CropInfoTip —— CropInfoTip.as 逐句对应（issue #42，替换
 * #7 的闭包 stub）。作物信息提示：MouseTip 换富文本形态——leading 10 的
 * 12px 灰字 + 白辉光描边 + 多行，data 落 htmlText。注意 :30 直写 _data
 * （不走 super.data，与 MouseTip 的 super.data 不同）。
 */
@:keep
class CropInfoTip extends MouseTip {
	// CropInfoTip.as:10-19
	public function new() {
		super();
		_tipName = Consts.TIP_NAME_CROPINFO_MOUSE;
		var _loc1_:TextFormat = new TextFormat("Verdana", 12, 6710886);
		_loc1_.leading = 10;
		_tipText.defaultTextFormat = _loc1_;
		_tipText.filters = [new GlowFilter(16777215, 1, 3, 3)];
		_tipText.multiline = true;
	}

	// CropInfoTip.as:21-31
	override private function set_data(param1:Dynamic):Dynamic {
		if (param1 == null) {
			param1 = "";
		}
		_tipText.htmlText = Std.string(param1);
		_tipBg.width = _tipText.width + 10;
		_tipBg.height = _tipText.height + 10;
		_data = param1;
		return param1;
	}
}
