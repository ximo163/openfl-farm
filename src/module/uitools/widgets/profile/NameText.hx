package module.uitools.widgets.profile;

import com.qzone.utils.StringUtil;
import common.misc.Utils;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 * module.uitools.widgets.profile.NameText —— NameText.as 逐句对应（issue #9）。
 * 昵称 + VIP 标（getCachedBitmapData 位图，随文本宽度右移）。
 */
class NameText extends Sprite {
	// NameText.as:15
	private var _textField:TextField;

	// NameText.as:17
	private var _vipBitmap:Bitmap;

	// NameText.as:19
	private var _vipDiamond:Sprite;

	// NameText.as:21
	private var _vip:String;

	// NameText.as:23-30
	public function new() {
		super();
		this._vip = "";
		this._textField = null;
		this._vipBitmap = null;
		this._vipDiamond = null;
	}

	// NameText.as:32-39
	private function setVipPosition():Void {
		if (this._vipBitmap != null && this._textField != null) {
			this._vipBitmap.x = this._textField.width + 5;
			this._vipBitmap.y = 3;
		}
	}

	// NameText.as:41-73（vip 标：空串/null 摘除，换标重建，同标重摆位）
	public var vip(get, set):String;

	private function set_vip(param1:String):String {
		var _loc2_:BitmapData = null;
		if (param1 == "" || param1 == null) {
			if (this._vipBitmap != null) {
				this._vipDiamond.removeChild(this._vipBitmap);
				this._vipBitmap = null;
			}
		} else if (param1 != this._vip) {
			if (this._vipBitmap != null) {
				this._vipDiamond.removeChild(this._vipBitmap);
				this._vipBitmap = null;
			}
			this._vipDiamond = new Sprite();
			this._vipDiamond.name = "__vip__";
			this._vipDiamond.buttonMode = true;
			_loc2_ = Utils.getCachedBitmapData(param1, 16, 13);
			this._vipBitmap = new Bitmap(_loc2_);
			this._vipDiamond.addChild(this._vipBitmap);
			this.addChild(this._vipDiamond);
			this.setVipPosition();
		} else if (this._vipBitmap != null) {
			this.setVipPosition();
		}
		this._vip = param1;
		return param1;
	}

	// NameText.as:100-103
	private function get_vip():String {
		return this._vip;
	}

	// NameText.as:75-82
	public var text(get, set):String;

	private function get_text():String {
		if (this._textField == null) {
			return "";
		}
		return this._textField.text;
	}

	// NameText.as:84-98
	private function set_text(param1:String):String {
		if (this._textField == null) {
			this._textField = new TextField();
			// Array<Dynamic> → filters 的数组合变，cast 对齐
			this._textField.filters = cast Utils.textGlowFilter;
			this._textField.selectable = false;
			this._textField.multiline = false;
			this._textField.autoSize = TextFieldAutoSize.LEFT;
			this._textField.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
			this.addChild(this._textField);
		}
		this._textField.htmlText = StringUtil.htmlEscape(param1);
		this.setVipPosition();
		return param1;
	}
}
