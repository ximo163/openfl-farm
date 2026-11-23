package common.view.tip;

import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.text.TextField;

/**
 * common.view.tip.MouseTip —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 鼠标提示（MouseTip.as）；FarmStage 建层时按 Consts 注册进控件表，本片只保类
 * 形态（继承 Tip、字段表、data/mX/mY 覆写签名），窗体/跟随随提示片接入。
 * write-tests（#42）：签名按原文补齐，方法体 throw 待实现。
 */
@:keep
class MouseTip extends Tip {
	// MouseTip.as:13
	private var _tipBg:Sprite;

	// MouseTip.as:15
	private var _tipText:TextField;

	public function new() {
		super();
	}

	// MouseTip.as:32-42（data：文本与底图尺寸，提示片翻译）
	override private function set_data(param1:Dynamic):Dynamic {
		throw new Error("not implemented");
	}

	// MouseTip.as:44-67（mX：舞台边界钳位的横向跟随，提示片翻译）
	override private function set_mX(param1:Float):Float {
		throw new Error("not implemented");
	}

	// MouseTip.as:69-88（mY：底边翻转的纵向跟随，提示片翻译）
	override private function set_mY(param1:Float):Float {
		throw new Error("not implemented");
	}
}
