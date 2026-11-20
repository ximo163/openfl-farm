package module.uitools.widgets.profile;

import common.misc.Utils;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/**
 * module.uitools.widgets.profile.ExpBar —— ExpBar.as 逐句对应（issue #9）。
 * 经验条：blue/yellow 双色底（ExpBlueBg/ExpBlue、ExpYellowBg/ExpYellow），
 * 百分比画条宽，中央 "next / exp" 文本。
 */
class ExpBar extends Sprite {
	// ExpBar.as:12
	public static final BLUE:String = "blue";

	// ExpBar.as:14
	public static final YELLOW:String = "yellow";

	// ExpBar.as:16
	private var _yellowBar:Sprite;

	// ExpBar.as:18
	private var _percent:Int;

	// ExpBar.as:20
	private var _blueBar:Sprite;

	// ExpBar.as:22
	private var _exp:Int;

	// ExpBar.as:24
	private var _color:String;

	// ExpBar.as:26
	private var _nextExp:Int;

	// ExpBar.as:28
	private var _yellowBarBg:Sprite;

	// ExpBar.as:30
	private var _expText:TextField;

	// ExpBar.as:32
	private var _blueBarBg:Sprite;

	// ExpBar.as:34-48
	public function new(param1:String = "") {
		super();
		this._exp = 0;
		this._nextExp = 0;
		this._percent = 0;
		if (param1 != "") {
			this.color = param1;
		} else {
			this.color = BLUE;
		}
	}

	// ExpBar.as:50-113（createView：按色装底条与文本）
	private function createView():Void {
		if (this.color == BLUE) {
			if (this._yellowBarBg != null) {
				this.removeChild(this._yellowBarBg);
				this._yellowBarBg = null;
			}
			if (this._yellowBar != null) {
				this.removeChild(this._yellowBar);
				this._yellowBar = null;
			}
			if (this._blueBarBg == null) {
				this._blueBarBg = cast(Utils.getMaterial("ExpBlueBg"), Sprite);
				this._blueBarBg.mouseEnabled = false;
			}
			this.addChild(this._blueBarBg);
			if (this._blueBar == null) {
				this._blueBar = cast(Utils.getMaterial("ExpBlue"), Sprite);
				this._blueBar.mouseEnabled = false;
			}
			this._blueBar.x = 1;
			this.addChild(this._blueBar);
		} else {
			if (this._blueBarBg != null) {
				this.removeChild(this._blueBarBg);
				this._blueBarBg = null;
			}
			if (this._blueBar != null) {
				this.removeChild(this._blueBar);
				this._blueBar = null;
			}
			if (this._yellowBarBg == null) {
				this._yellowBarBg = cast(Utils.getMaterial("ExpYellowBg"), Sprite);
				this._yellowBarBg.mouseEnabled = false;
			}
			this.addChild(this._yellowBarBg);
			if (this._yellowBar == null) {
				this._yellowBar = cast(Utils.getMaterial("ExpYellow"), Sprite);
				this._yellowBar.mouseEnabled = false;
			}
			this._yellowBar.x = 1;
			this.addChild(this._yellowBar);
		}
		this._expText = new TextField();
		this._expText.selectable = false;
		this._expText.mouseEnabled = false;
		this._expText.defaultTextFormat = new TextFormat("Verdana", 10, null, null, null, null, null, null, TextFormatAlign.CENTER);
		this._expText.y = -3;
		this._expText.width = 120;
		this._expText.height = 18;
		this._expText.text = Std.string(this.nextExp) + " / " + Std.string(this.exp);
		this.addChild(this._expText);
	}

	// ExpBar.as:115-124
	public var color(get, set):String;

	private function set_color(param1:String):String {
		if (this._color == param1) {
			return param1;
		}
		this._color = param1;
		this.createView();
		this.drawPercentage();
		return param1;
	}

	// ExpBar.as:143-146
	private function get_color():String {
		return this._color;
	}

	// ExpBar.as:126-130/:148-151（get+set 都在）
	public var percent(get, set):Int;

	private function set_percent(param1:Int):Int {
		this._percent = param1;
		this.drawPercentage();
		return param1;
	}

	// ExpBar.as:148-151
	private function get_percent():Int {
		return this._percent;
	}

	// ExpBar.as:132-136
	public var nextExp(get, set):Int;

	private function set_nextExp(param1:Int):Int {
		this._nextExp = param1;
		this._expText.text = Std.string(this.nextExp) + " / " + Std.string(this.exp);
		return param1;
	}

	// ExpBar.as:153-156
	private function get_nextExp():Int {
		return this._nextExp;
	}

	// ExpBar.as:138-141
	public var exp(get, set):Int;

	private function get_exp():Int {
		return this._exp;
	}

	// ExpBar.as:158-162
	private function set_exp(param1:Int):Int {
		this._exp = param1;
		this._expText.text = Std.string(this.nextExp) + " / " + Std.string(this.exp);
		return param1;
	}

	// ExpBar.as:164-174（119px 满条宽 × 百分比）
	private function drawPercentage():Void {
		if (this._yellowBar != null) {
			this._yellowBar.width = 119 * (this.percent * 0.01);
		} else if (this._blueBar != null) {
			this._blueBar.width = 119 * (this.percent * 0.01);
		}
	}
}
