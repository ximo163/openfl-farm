package module.messages.widgets;

import com.qzone.qui.containers.TileList;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import openfl.display.Sprite;

/**
 * module.messages.widgets.ProfileHistory —— ProfileHistory.as 逐句对应
 * （issue #19）。成果/成鱼页：TileList（90×100 瓦片、ItemBg 无背景、
 * HistoryItem 渲染）+ dataList 转发 dataProvider。
 */
class ProfileHistory extends Sprite {
	// ProfileHistory.as:11
	private var _tile:TileList;

	public function new() {
		super();
		this._tile = new TileList();
		this._tile.itemRenderer = HistoryItem;
		this._tile.tileWidth = 90;
		this._tile.tileHeight = 100;
		this._tile.horizontalScrollPolicy = ScrollPolicy.OFF;
		this._tile.gapH = 0;
		this._tile.gapV = 0;
		this._tile.x = 20;
		this._tile.y = 2;
		this._tile.defaultSkin = null;
		this._tile.width = 470;
		this._tile.height = 210;
		addChild(this._tile);
	}

	// ProfileHistory.as:38-46（AS3 public get/set dataList 对）
	public var dataList(get, set):Array<Dynamic>;

	private function get_dataList():Array<Dynamic> {
		return this._tile.dataProvider;
	}

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		this._tile.dataProvider = param1;
		return param1;
	}
}
