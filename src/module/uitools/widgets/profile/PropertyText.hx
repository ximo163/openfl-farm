package module.uitools.widgets.profile;

import common.misc.Utils;
import common.view.MoneyIcon;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;

/**
 * module.uitools.widgets.profile.PropertyText —— PropertyText.as 逐句对应
 * （issue #9）。金币/人民币数值条：MoneyIcon + 数值文本（textGlowFilter 白描）。
 */
class PropertyText extends Sprite {
	// PropertyText.as:13
	private var _goldText:TextField;

	// PropertyText.as:15-46
	public function new(param1:String = "gold", param2:Int = 80, param3:Bool = true) {
		super();
		var _loc4_:MoneyIcon = new MoneyIcon(param1);
		_loc4_.y = 4;
		// Array<Dynamic> → filters 的数组合变，cast 对齐
		_loc4_.filters = cast Utils.textGlowFilter;
		this.addChild(_loc4_);
		var _loc5_:UInt = 16737792;
		if (param1 == "rp") {
			_loc5_ = 4160774;
		}
		this._goldText = new TextField();
		this._goldText.selectable = false;
		this._goldText.width = param2;
		this._goldText.height = 25;
		if (param3 == true) {
			this._goldText.defaultTextFormat = new TextFormat("embedFontA", 14, _loc5_, null, null, null, null, null, TextFormatAlign.LEFT);
			this._goldText.embedFonts = true;
		} else {
			this._goldText.defaultTextFormat = new TextFormat("", 14, _loc5_, null, null, null, null, null, TextFormatAlign.LEFT);
			this._goldText.embedFonts = false;
		}
		this._goldText.filters = cast Utils.textGlowFilter;
		this._goldText.x = 40;
		this._goldText.y = 2;
		this._goldText.text = "0";
		this.addChild(this._goldText);
	}

	// PropertyText.as:48-51
	public var goldValue(get, set):Float;

	private function get_goldValue():Float {
		// 原版 `Number(this._goldText.text)`：串非法得 NaN 照走
		return As3.floatOf(this._goldText.text);
	}

	// PropertyText.as:53-60
	private function set_goldValue(param1:Float):Float {
		if (param1 < 0) {
			param1 = 0;
		}
		this._goldText.text = Std.string(param1);
		return param1;
	}

	// PropertyText.as:62-65
	public var text(never, set):String;

	private function set_text(param1:String):String {
		this._goldText.htmlText = param1;
		return param1;
	}
}
