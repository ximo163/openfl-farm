package common.view.tip;

import com.qzone.utils.StringUtil;
import common.Consts;
import common.misc.Utils;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * common.view.tip.DiyMouseTip —— DiyMouseTip.as 逐句对应（issue #42，替换
 * #7 的闭包 stub）。装饰编辑（DIY 摆放）的鼠标提示：TipBg 底板 + 装饰名/
 * 到期时间两行文本，底板高固定 50、宽按两行文本较大者 +20。
 * :53 的 `"…dateFormat(…) + "11"` 尾串 "11" 是原文笔误，逐字保留
 * （照抄不修，偏差只进 spec/deviations.json——lessons #8 条）。
 */
@:keep
class DiyMouseTip extends Tip {
	// DiyMouseTip.as:13
	private var m_tipText2:TextField;

	// DiyMouseTip.as:15
	private var m_tipBg:Sprite;

	// DiyMouseTip.as:17
	private var m_tipText:TextField;

	// DiyMouseTip.as:19-36
	public function new() {
		super();
		_tipName = Consts.TIP_NAME_DIY_MOUSE;
		// `Utils.getMaterial("TipBg") as Sprite`（MouseTip 同款）
		var _bgMat:Dynamic = Utils.getMaterial("TipBg");
		this.m_tipBg = Std.isOfType(_bgMat, Sprite) ? cast(_bgMat, Sprite) : null;
		addChild(this.m_tipBg);
		this.m_tipText = new TextField();
		this.m_tipText.x = 15;
		this.m_tipText.y = 5;
		this.m_tipText.defaultTextFormat = new TextFormat("Verdana", 12, 0);
		addChild(this.m_tipText);
		this.m_tipText2 = new TextField();
		this.m_tipText2.x = 5;
		this.m_tipText2.y = 25;
		this.m_tipText2.width = 140;
		this.m_tipText2.defaultTextFormat = new TextFormat("Verdana", 12, 0);
		addChild(this.m_tipText2);
	}

	// DiyMouseTip.as:38-42
	override private function set_mX(param1:Float):Float {
		super.mX = param1;
		x = param1 - 5;
		return param1;
	}

	// DiyMouseTip.as:44-65（validTime 0 = 无限期；`== 0` 按 AS3 松等照写，
	// 载荷恒带 Int validTime——DecorateView.as:213-218）
	override private function set_data(param1:Dynamic):Dynamic {
		this.m_tipText.text = Reflect.field(param1, "itemName");
		if (Reflect.field(param1, "validTime") == 0) {
			this.m_tipText2.text = "到期时间：无限期";
		} else {
			this.m_tipText2.text = "到期时间：" + StringUtil.dateFormat(Reflect.field(param1, "validTime")) + "11";
		}
		if (this.m_tipText.width > this.m_tipText2.width) {
			this.m_tipBg.width = this.m_tipText.width + 20;
		} else {
			this.m_tipBg.width = this.m_tipText2.width + 20;
		}
		this.m_tipBg.height = 50;
		super.data = param1;
		return param1;
	}

	// DiyMouseTip.as:67-71
	override private function set_mY(param1:Float):Float {
		super.mY = param1;
		y = param1 + 20;
		return param1;
	}
}
