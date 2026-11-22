package module.shop.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import common.Language;
import common.view.window.WindowLabelMaker;
import framework.base.BasePage;
import openfl.display.DisplayObjectContainer;

/**
 * module.shop.widgets.AdvertisementPage —— AdvertisementPage.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。广告页：说明文案取动态配置
 * adTileDirection，瓦片 147x140、gap 10x10，itemRenderer = AdvertisementItem。
 */
class AdvertisementPage extends BasePage {
	// AdvertisementPage.as:13-24
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		var _loc4_:Label = null;
		super(param1, param2, param3);
		_loc4_ = new Label(Reflect.field(Language.L, "adTileDirection"));
		_loc4_.x = 2;
		_loc4_.width = param2 - 3;
		WindowLabelMaker.addTarget(_loc4_);
		addChild(_loc4_);
	}

	// AdvertisementPage.as:26-46
	override private function onCreateTile():Void {
		if (this._tile != null) {
			this._tile.paddingH = 17;
			this._tile.paddingV = 7;
			this._tile.gapH = 10;
			this._tile.gapV = 10;
			this._tile.tileWidth = 147;
			this._tile.tileHeight = 140;
			this._tile.defaultSkin = null;
			this._tile.horizontalScrollPolicy = ScrollPolicy.OFF;
			this._tile.itemRenderer = AdvertisementItem;
			this._tile.y = 22;
			this._tile.width = this._preferedWidth - 5;
			this._tile.height = 310;
		}
	}
}
