package common.view.tip;

import common.Consts;
import common.misc.Utils;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 * common.view.tip.MouseTip —— MouseTip.as 逐句对应（issue #42，替换 #7 的
 * 闭包 stub）。鼠标跟随文字提示：TipBg 底板 + 左上 (5,5) 的 autoSize 文本，
 * data 落文本并按文本尺寸撑底板；mX/mY 覆写按舞台边界钳位换算显示坐标。
 * （AS3 的 protected 字段 → Haxe private，子类可见性不变。）
 */
@:keep
class MouseTip extends Tip {
	// MouseTip.as:13
	private var _tipBg:Sprite;

	// MouseTip.as:15
	private var _tipText:TextField;

	// MouseTip.as:17-30
	public function new() {
		super();
		_tipName = Consts.TIP_NAME_MOUSE;
		// `Utils.getMaterial("TipBg") as Sprite`（HistoryItemTip 同款三分流：
		// 素材符号类 src/TipBg.hx，eval 无资源落 null）
		var _bgMat:Dynamic = Utils.getMaterial("TipBg");
		this._tipBg = Std.isOfType(_bgMat, Sprite) ? cast(_bgMat, Sprite) : null;
		addChild(this._tipBg);
		this._tipText = new TextField();
		this._tipText.selectable = false;
		this._tipText.x = 5;
		this._tipText.y = 5;
		this._tipText.autoSize = TextFieldAutoSize.LEFT;
		this._tipText.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		addChild(this._tipText);
	}

	// MouseTip.as:32-42
	override private function set_data(param1:Dynamic):Dynamic {
		if (param1 == null) {
			param1 = "";
		}
		this._tipText.text = Std.string(param1);
		this._tipBg.width = this._tipText.width + 10;
		this._tipBg.height = this._tipText.height + 10;
		super.data = param1;
		return param1;
	}

	// MouseTip.as:44-67（mX：左缘不越 0，右缘按宽回退，常态 -5）
	override private function set_mX(param1:Float):Float {
		super.mX = param1;
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

	// MouseTip.as:69-88（mY：常态 +20，底边越界翻到指针上方 -8）
	override private function set_mY(param1:Float):Float {
		super.mY = param1;
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
