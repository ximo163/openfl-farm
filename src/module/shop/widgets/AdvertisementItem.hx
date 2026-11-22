package module.shop.widgets;

import com.qzone.corelib.controls.ExtLoader;
import com.qzone.qui.controls.Button;
import common.misc.Utils;
import entities.AdItem;
import framework.base.BaseTileItem;
import openfl.text.TextField;

/**
 * module.shop.widgets.AdvertisementItem —— AdvertisementItem.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。合作专区页瓦片子项：AdItem 的外链图
 * 直挂 ExtLoader，「现在去」按钮点击由基类冒 CHILD_CLICK（data = _item）
 * 给 ShopView 开落地页。
 */
class AdvertisementItem extends BaseTileItem {
	// AdvertisementItem.as:9
	private var _priceText:TextField;

	// AdvertisementItem.as:11
	private var _gotoBtn:Button;

	// AdvertisementItem.as:13-20
	public function new() {
		super();
		createBackground("ItemBg", 147, 140);
		this._material.x = (this._bg.width - this._material.width) / 2;
		this._material.y = 90 - this._material.height;
	}

	// AdvertisementItem.as:22-44
	override private function set_data(param1:Dynamic):Dynamic {
		var _loc2_:AdItem = null;
		if (param1 == null || param1 == this._item) {
			return param1;
		}
		super.set_data(param1);
		_loc2_ = new AdItem(this._item);
		// 原版 new 之后判 null（死代码，照抄保留）
		if (_loc2_ == null) {
			return param1;
		}
		var _loc3_:ExtLoader = new ExtLoader();
		_loc3_.y = 3;
		_loc3_.x = 3.5;
		var _loc4_:String = _loc2_._img;
		_loc3_.load(_loc4_);
		addChild(_loc3_);
		this._gotoBtn = new Button();
		this._gotoBtn.defaultSkin = Utils.getClass("ButtonOrange");
		this._gotoBtn.width = 54;
		this._gotoBtn.height = 25;
		this._gotoBtn.x = (this._bg.width - this._gotoBtn.width) / 2;
		this._gotoBtn.y = 102;
		this._gotoBtn.text = "现在去";
		addChild(this._gotoBtn);
		registerListeners();
		return param1;
	}
}
