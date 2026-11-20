package module.uitools.widgets.profile;

import common.misc.Utils;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/**
 * module.uitools.widgets.profile.Level —— Level.as 逐句对应（issue #9）。
 * 等级徽章：blue/yellow 双底素材（LevelBlue/LevelYellow）+ 中央等级数字。
 */
class Level extends Sprite {
	// Level.as:12
	public static final BLUE:String = "blue";

	// Level.as:14
	public static final YELLOW:String = "yellow";

	// Level.as:16
	private var _color:String = "blue";

	// Level.as:18
	private var _level:Int = 0;

	// Level.as:20
	private var _levelTextField:TextField;

	// Level.as:22
	private var _yellowBg:Sprite;

	// Level.as:24
	private var _blueBg:Sprite;

	// Level.as:26-42
	public function new(param1:String = "") {
		super();
		this._levelTextField = new TextField();
		this._levelTextField.selectable = false;
		this._levelTextField.mouseEnabled = false;
		this._levelTextField.width = 40;
		this._levelTextField.height = 30;
		this._levelTextField.defaultTextFormat = new TextFormat("embedFontA", 18, 39423, null, null, null, null, null,
			TextFormatAlign.CENTER);
		this._levelTextField.embedFonts = true;
		this._levelTextField.text = "0";
		this.addChild(this._levelTextField);
		if (param1 != "") {
			this.color = param1;
		}
	}

	// Level.as:44-48（原版 `String(param1)`）
	public var level(get, set):Int;

	private function set_level(param1:Int):Int {
		this._level = param1;
		this._levelTextField.text = Std.string(param1);
		return param1;
	}

	// Level.as:61-64
	private function get_level():Int {
		return this._level;
	}

	// Level.as:50-53
	public var color(get, set):String;

	private function get_color():String {
		return this._color;
	}

	// Level.as:55-59
	private function set_color(param1:String):String {
		this._color = param1;
		this.addBg();
		return param1;
	}

	// Level.as:66-104（addBg：换底图 + 数字着色；非 blue 一律走 yellow 支）
	private function addBg():Void {
		if (this.color == BLUE) {
			if (this._yellowBg != null) {
				this.removeChild(this._yellowBg);
				this._yellowBg = null;
			}
			if (this._blueBg == null) {
				this._blueBg = cast(Utils.getMaterial("LevelBlue"), Sprite);
				this._blueBg.mouseEnabled = false;
				this._blueBg.scaleX = this._blueBg.scaleY = 1.3;
				this._blueBg.x = 1;
				this._blueBg.y = -9;
			}
			this.addChildAt(this._blueBg, 0);
			this._levelTextField.textColor = 39423;
		} else {
			if (this._blueBg != null) {
				this.removeChild(this._blueBg);
				this._blueBg = null;
			}
			if (this._yellowBg == null) {
				this._yellowBg = cast(Utils.getMaterial("LevelYellow"), Sprite);
				this._yellowBg.mouseEnabled = false;
				this._yellowBg.scaleX = this._yellowBg.scaleY = 1.3;
				this._yellowBg.x = 1;
				this._yellowBg.y = -9;
			}
			this.addChildAt(this._yellowBg, 0);
			this._levelTextField.textColor = 13408512;
		}
	}
}
