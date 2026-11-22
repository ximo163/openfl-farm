package module.shop.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import common.view.window.WindowLabelMaker;
import framework.base.BasePage;
import openfl.display.DisplayObjectContainer;

/**
 * module.shop.widgets.FishPage —— FishPage.as 逐句对应（issue #35 功能
 * swf 翻译：商店）。鱼苗页：顶部解锁提示 Label，瓦片 90x98 密排
 *（paddingH 23 / paddingV 10 / gap 0），itemRenderer = FishItem。
 */
class FishPage extends BasePage {
	// FishPage.as:13-24
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		var _loc4_:Label = null;
		super(param1, param2, param3);
		_loc4_ = new Label("鱼苗需要解锁才可以进行购买，解锁鱼苗需要花费一定的资源。");
		_loc4_.x = 2;
		_loc4_.width = param2 - 3;
		WindowLabelMaker.addTarget(_loc4_);
		addChild(_loc4_);
	}

	// FishPage.as:26-46
	override private function onCreateTile():Void {
		if (this._tile != null) {
			this._tile.paddingH = 23;
			this._tile.paddingV = 10;
			this._tile.gapH = 0;
			this._tile.gapV = 0;
			this._tile.tileWidth = 90;
			this._tile.tileHeight = 98;
			this._tile.defaultSkin = null;
			this._tile.horizontalScrollPolicy = ScrollPolicy.OFF;
			this._tile.itemRenderer = FishItem;
			this._tile.y = 22;
			this._tile.width = this._preferedWidth - 5;
			this._tile.height = 273;
		}
	}
}
