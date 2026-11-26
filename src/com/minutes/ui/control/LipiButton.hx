package com.minutes.ui.control;

import com.minutes.ui.core.LipiSkin;
import com.minutes.ui.core.LipiUIComponent;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.filters.ColorMatrixFilter;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 * com.minutes.ui.control.LipiButton —— LipiButton.as 逐句对应（issue #86
 * 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/LipiButton.as。
 *
 * PORT-NOTE（`this.labelText.text = this._label || ""`，LipiButton.as:229）：
 * AS3 的 `a || b` 动态真值短路——空串/null 都落 ""。Haxe 经 shim.As3.or
 * 等价（返回 Dynamic，赋进 String 属性须再 Std.string——null 不落进来
 * 因为 or 的 fallback 是 ""）。
 * PORT-NOTE（width setter 的顺序，:61-69）：先置 _sizeChange 再读 width
 * 比较再写 super.width——width 的读是自身 override 的 _width 存储通道
 * （LipiUIComponent），与 textWidth 比较的是**旧**宽度。原版语义逐字。
 * PORT-NOTE（`this._label || ""` 的 labelText 写入）：label 为 null 时
 * 写 ""——set label(null) 后 get label 仍返 null（_label 原值），text
 * 显示空串。原版缺陷/特性逐字保留。
 */
@:keep
class LipiButton extends LipiUIComponent {
	// LipiButton.as:15-41
	private var formatChange:Bool = false;
	private var _textStyleChange:Bool = false;
	private var _enable:Bool = true;
	private var _textSize:Int = 12;
	private var _sizeChange:Bool = false;
	private var _textBold:Bool = false;
	private var _filters:Array<Dynamic>;
	private var _textColor:UInt = 0;
	private var labelText:TextField;
	private var _icon:DisplayObject;
	private var _textModeChange:Bool = false;
	private var _label:String = "";
	private var _textFont:String = null;
	private var _iconLeft:Int = 0;

	// :43-47
	public function new() {
		super();
		this.init();
	}

	// :49-52
	public var enable(get, set):Bool;

	private function get_enable():Bool {
		return this._enable;
	}

	// :54-59
	private function set_enable(param1:Bool):Bool {
		this._enable = param1;
		this._textModeChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :61-69（见类头 PORT-NOTE）
	private override function set_width(param1:Float):Float {
		this._sizeChange = true;
		if (this.labelText != null && this.labelText.textWidth > width) {
			param1 = this.labelText.textWidth + 12;
		}
		super.set_width(param1);
		return param1;
	}

	// :71-78（`new TextFormat(font,size,color,bold)` 位置参原样——
	// textFont 为 null 时 TextFormat 首参 null，原版如此）
	private function setTextFormat():Void {
		if (this.labelText == null) {
			return;
		}
		this.labelText.setTextFormat(new TextFormat(this.textFont, this.textSize, this.textColor, this.textBold));
	}

	// :80-87
	private function init():Void {
		this.height = 30;
		this.width = 100;
		this.bgColor = 16711680;
		this.buttonMode = true;
		this.useHandCursor = true;
	}

	// :89-107（/ 2.5 原文如此——非笔误修正对象）
	private function setTextPosition():Void {
		if (this.labelText == null) {
			return;
		}
		if (this._icon != null) {
			this._icon.x = this.iconLeft + this._icon.width / 2;
			this._icon.y = (this.height - this._icon.height) / 2;
			this.labelText.x = this.iconLeft + this._icon.width * 2;
			this.labelText.y = (this.height - this.labelText.height) / 2;
		} else {
			this.labelText.x = (this.width - this.labelText.width) / 2;
			this.labelText.y = (this.height - this.labelText.height) / 2.5;
		}
	}

	// :109-114
	public var textSize(get, set):Int;

	private function set_textSize(param1:Int):Int {
		this._textSize = param1;
		this.formatChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :116-119
	public var iconLeft(get, set):Int;

	private function get_iconLeft():Int {
		return this._iconLeft;
	}

	// :121-124
	public var textFont(get, set):String;

	private function get_textFont():String {
		return this._textFont;
	}

	// :126-131
	public var textBold(get, set):Bool;

	private function set_textBold(param1:Bool):Bool {
		this._textBold = param1;
		this.formatChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :133-136
	public var textColor(get, set):UInt;

	private function get_textColor():UInt {
		return this._textColor;
	}

	// :138-148
	private function createTextField():Void {
		this.labelText = new TextField();
		this.labelText.mouseEnabled = false;
		this.labelText.autoSize = TextFieldAutoSize.LEFT;
		this.labelText.selectable = false;
		this.labelText.defaultTextFormat = new TextFormat("Verdana");
		addChild(this.labelText);
		this.formatChange = true;
		invalidateDisplayList();
	}

	// :150-155
	private function set_textFont(param1:String):String {
		this._textFont = param1;
		this.formatChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :157-177（灰度矩阵逐字；`filters = []`/`[mat]`——Sprite 的 filters
	// 属性直通）
	private function textModeChange():Void {
		if (this._enable) {
			this.buttonMode = true;
			this.useHandCursor = true;
			this.mouseEnabled = true;
			filters = [];
		} else {
			this.buttonMode = false;
			this.useHandCursor = false;
			this.mouseEnabled = false;
			filters = [
				new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0])
			];
		}
		if (bgSkin != null) {
			bgSkin.enableMouse = this.enable;
		}
	}

	// :179-184
	private function set_iconLeft(param1:Int):Int {
		this._iconLeft = param1;
		this._sizeChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :186-193（AS3 override set bgSkin——Haxe 属性覆写：基类访问器
	// 重载后须保持同签名）
	private override function set_bgSkin(param1:LipiSkin):LipiSkin {
		super.set_bgSkin(param1);
		if (bgSkin != null) {
			bgSkin.enableMouse = this.enable;
		}
		return param1;
	}

	// :195-199
	public var labelFilters(get, set):Array<Dynamic>;

	private function set_labelFilters(param1:Array<Dynamic>):Array<Dynamic> {
		this._filters = param1;
		// AS3 的 filters 是类型自由 Array——openfl 收 Array<BitmapFilter>，
		// Array<Dynamic> 经 cast 直通（FarmLiteView.hx:270 同款先例）
		this.labelText.filters = cast this._filters;
		return param1;
	}

	// :201-204
	private function get_textBold():Bool {
		return this._textBold;
	}

	// :206-210
	private override function set_height(param1:Float):Float {
		this._sizeChange = true;
		super.set_height(param1);
		return param1;
	}

	// :212-215
	private function get_textSize():Int {
		return this._textSize;
	}

	// :217-220
	private function get_labelFilters():Array<Dynamic> {
		return this._filters;
	}

	// :222-232（`this._label || ""` 见类头 PORT-NOTE）
	public var label(get, set):String;

	private function set_label(param1:String):String {
		if (this.labelText == null) {
			this.createTextField();
		}
		this._label = param1;
		this.labelText.text = Std.string(shim.As3.or(this._label, ""));
		this.formatChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :234-239
	private function set_textColor(param1:UInt):UInt {
		this._textColor = param1;
		this.formatChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :241-259（:243-247 原版缺陷逐字保留：先把 _icon 置 null 再
	// removeChild(null)——removeChild 收到 null 抛 ArgumentError，原版
	// 在「换 icon」路径必崩；`param1 is Sprite` 门内 mouseEnabled=false）
	public var icon(get, set):DisplayObject;

	private function set_icon(param1:DisplayObject):DisplayObject {
		if (this._icon != null) {
			this._icon = null;
			removeChild(this._icon);
		}
		if (param1 != null) {
			this._icon = param1;
			if (Std.isOfType(param1, Sprite)) {
				cast(param1, Sprite).mouseEnabled = false;
			}
			addChild(param1);
		}
		this._sizeChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :261-264
	private function get_label():String {
		return this._label;
	}

	// :266-285
	private override function updateDisplayList(param1:Float, param2:Float):Void {
		super.updateDisplayList(param1, param2);
		if (this.formatChange) {
			this.setTextFormat();
			this.setTextPosition();
			this.formatChange = false;
		}
		if (this._sizeChange) {
			this.setTextPosition();
			this._sizeChange = false;
		}
		if (this._textModeChange) {
			this.textModeChange();
			this._textModeChange = false;
		}
	}

	// :287-290
	private function get_icon():DisplayObject {
		return this._icon;
	}
}
