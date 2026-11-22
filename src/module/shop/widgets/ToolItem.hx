package module.shop.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.styles.Style;
import entities.Item;
import framework.base.BaseTileItem;
import openfl.display.Shape;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * module.shop.widgets.ToolItem —— ToolItem.as 逐句对应（issue #35 功能
 * swf 翻译：商店）。道具页瓦片子项：金币/元宝/免费价格 html，售完置灰
 * 「已售完」、缺货整格置灰（_shortage 字段声明见 entities/Item.hx 补齐注释）。
 */
class ToolItem extends BaseTileItem {
	// ToolItem.as:9
	private var _priceText:TextField;

	// ToolItem.as:11-34
	public function new() {
		super();
		createBackground("ItemBg");
		this._priceText = new TextField();
		this._priceText.selectable = false;
		this._priceText.width = this.width + 10;
		this._priceText.height = 20;
		addChild(this._priceText);
		this._priceText.x = -5;
		if (this._bg != null) {
			this._priceText.y = this._bg.height + 2;
		} else {
			this._priceText.y = 62;
		}
		var _loc1_:Shape = new Shape();
		_loc1_.graphics.beginFill(16711680, 0);
		_loc1_.graphics.drawRect(0, 0, 10, 1);
		_loc1_.graphics.endFill();
		_loc1_.y = 100;
		addChild(_loc1_);
	}

	// ToolItem.as:36-83
	override private function set_data(param1:Dynamic):Dynamic {
		var _loc3_:Label = null;
		if (param1 == null || param1 == this._item) {
			return param1;
		}
		super.set_data(param1);
		var _loc2_:Item = Std.isOfType(this._item, Item) ? cast(this._item, Item) : null;
		if (_loc2_ == null) {
			return param1;
		}
		if (_loc2_._price != 0) {
			this._priceText.htmlText = "<p align=\"center\"><font face=\"Verdana\" color=\"#CC3300\">金币<font/> <font color=\"#FF6600\" face=\"Verdana\" size=\"11\"><b>"
				+ Std.string(_loc2_._price) + "</b><font/></p>";
		} else if (_loc2_._fb != 0) {
			this._priceText.htmlText = "<p align=\"center\"><font face=\"Verdana\" color=\"#003366\">元宝<font/> <font color=\"#0099FF\" face=\"Verdana\" size=\"11\"><b>"
				+ Std.string(_loc2_._fb) + "</b><font/></p>";
		} else {
			this._priceText.htmlText = "<p align=\"center\"><font face=\"Verdana\" color=\"#CC3300\">免费<font/></p>";
		}
		this._material.setContent(Std.string(_loc2_._type), _loc2_._id);
		if (_loc2_._saleOut == true) {
			this._material.filters = cast Style.getDisableFilter();
			_loc3_ = new Label("已售完");
			addChild(_loc3_);
			_loc3_.x = 10;
			_loc3_.y = 40;
			_loc3_.textField.setTextFormat(new TextFormat("Verdana", 12, 13369344));
			_loc3_.textField.filters = cast Style.getTextGlowFilter();
		}
		if (_loc2_._shortage == true) {
			this._bg.filters = cast Style.getDisableFilter();
		} else {
			this._bg.filters = null;
		}
		registerListeners();
		return param1;
	}
}
