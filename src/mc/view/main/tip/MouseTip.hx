package mc.view.main.tip;

import common.MaterialLib;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 * mc.view.main.tip.MouseTip —— MouseTip.as 逐句对应（issue #19 Master2
 * 闭包顺手译）。通用鼠标提示：文本宽高 + 10 撑背景，贴鼠标翻转防出屏。
 */
@:keep
class MouseTip extends Tip {
	private var tipBg:Sprite;
	private var tipText:TextField;

	public function new() {
		super();
		this.tipBg = cast MaterialLib.getInstance().getMaterial("TipBg");
		addChild(this.tipBg);
		this.tipText = new TextField();
		this.tipText.selectable = false;
		this.tipText.x = 5;
		this.tipText.y = 5;
		this.tipText.autoSize = TextFieldAutoSize.LEFT;
		this.tipText.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		addChild(this.tipText);
	}

	// MouseTip.as:30-40
	override public function set_data(param1:Dynamic):Dynamic {
		if (param1 == null) {
			param1 = "";
		}
		this.tipText.htmlText = Std.string(param1);
		this.tipBg.width = this.tipText.width + 10;
		this.tipBg.height = this.tipText.height + 10;
		return super.set_data(param1);
	}

	// MouseTip.as:42-65
	override public function set_mX(param1:Float):Float {
		super.set_mX(param1);
		if (stage != null) {
			if (param1 - 5 <= 0) {
				param1 = 0;
			} else if (param1 - 5 + width > stage.stageWidth) {
				param1 = stage.stageWidth - width;
			} else {
				param1 -= 5;
			}
		} else {
			param1 -= 5;
		}
		x = param1;
		return param1;
	}

	// MouseTip.as:67-86
	override public function set_mY(param1:Float):Float {
		super.set_mY(param1);
		if (stage != null) {
			if (param1 + height + 30 > stage.stageHeight) {
				param1 = param1 - height - 8;
			} else {
				param1 += 20;
			}
		} else {
			param1 += 20;
		}
		y = param1;
		return param1;
	}
}
