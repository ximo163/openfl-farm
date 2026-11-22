package module.shop.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import common.view.window.WindowLabelMaker;
import framework.base.BasePage;
import openfl.display.DisplayObjectContainer;

/**
 * module.shop.widgets.AdSeedsPage —— AdSeedsPage.as 逐句对应（issue #35
 * 功能 swf 翻译：商店）。合作专区种子页：瓦片与 FishPage 同密度但
 * itemRenderer = CropItem，高 300、顶 23。
 */
class AdSeedsPage extends BasePage {
	// AdSeedsPage.as:10（AS3 实例 const → Haxe static final 字面量）
	private static final _tile_height:Int = 300;

	// AdSeedsPage.as:12
	private static final _tile_top:Int = 23;

	// AdSeedsPage.as:14-25
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		var _loc4_:Label = null;
		super(param1, param2, param3);
		_loc4_ = new Label("温馨提示：合作专区中的物品非全部用户可见，且限时限量供应，欲购从速哦~~");
		_loc4_.x = 2;
		_loc4_.width = param2 - 3;
		WindowLabelMaker.addTarget(_loc4_);
		addChild(_loc4_);
	}

	// AdSeedsPage.as:27-47
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
			this._tile.itemRenderer = CropItem;
			this._tile.y = _tile_top;
			this._tile.width = this._preferedWidth - 5;
			this._tile.height = _tile_height;
		}
	}
}
