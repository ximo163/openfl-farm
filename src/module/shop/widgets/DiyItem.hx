package module.shop.widgets;

import entities.DIYDecor;
import framework.base.BaseTileItem;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.text.TextField;

/**
 * module.shop.widgets.DiyItem —— DiyItem.as 逐句对应（issue #35 功能 swf
 * 翻译：商店）。装饰页瓦片子项：金币/元宝(VIP价)/已购买三段价格 html，
 * ItemBorder 背景加 60x60 遮罩。setContent("2", _id, true) 的 "2" 即
 * Consts.ITEM_TYPE_DECORATE 的原字面量（原版此处内联字符串，照抄）。
 */
class DiyItem extends BaseTileItem {
	// DiyItem.as:9
	private var _divMask:Sprite;

	// DiyItem.as:11
	private var _newMarkIcon:MovieClip;

	// DiyItem.as:13
	private var _priceText:TextField;

	// DiyItem.as:15
	private var _fbText:TextField;

	// DiyItem.as:17-27
	public function new() {
		super();
		createBackground("ItemBorder");
		this._priceText = new TextField();
		this._priceText.selectable = false;
		this._priceText.width = this.width + 19;
		this._priceText.height = 65;
		this._priceText.multiline = true;
		this._priceText.y = 60;
		addChild(this._priceText);
	}

	// DiyItem.as:29-69
	override private function set_data(param1:Dynamic):Dynamic {
		var _loc3_:String = null;
		if (param1 == null || param1 == this._item) {
			return param1;
		}
		super.set_data(param1);
		var _loc2_:DIYDecor = Std.isOfType(this._item, DIYDecor) ? cast(this._item, DIYDecor) : null;
		if (_loc2_ == null) {
			return param1;
		}
		this._material.setContent("2", _loc2_._id, true);
		_loc3_ = "";
		if (_loc2_._price > 0) {
			_loc3_ += "<p align=\"left\"><font face=\"Verdana\" color=\"#CC3300\">金币<font/> <font color=\"#FF6600\" face=\"Verdana\" size=\"11\"><b>"
				+ Std.string(_loc2_._price) + "</b><font/></p>";
		}
		if (_loc2_._fb != 0) {
			_loc3_ += "<textformat indent=\"2\"><p align=\"left\"><font face=\"Verdana\" color=\"#003366\">元宝<font/> <font color=\"#0099FF\" face=\"Verdana\" size=\"11\"><b>"
				+ Std.string(_loc2_._fb) + "</b><font/></p></textformat>";
			_loc3_ += "<p align=\"left\">(<font face=\"Verdana\">VIP价</font> <font size=\"11\" color=\"#FF6600\" face=\"Verdana\"><b>"
				+ Std.string(_loc2_._yfb) + "</b></font>)</p>";
		}
		if (_loc2_._alreadyOwn == true) {
			_loc3_ += "<p align=\"left\"><font face=\"Verdana\" color=\"#CC3300\">已购买<font/> <font color=\"#FF6600\" face=\"Verdana\" size=\"11\"><font/></p>";
		}
		this._priceText.htmlText = _loc3_;
		createMask("ItemBorder", 60, 60);
		if (this._mask != null) {
			this._mask.x = 1;
			this._mask.y = 1;
		}
		registerListeners();
		return param1;
	}
}
