package framework.net.parsers;

import entities.ShopFish;
import framework.base.BaseArrayParser;

// framework.net.parsers.FishDataParser —— FishDataParser.as 逐句对应。
class FishDataParser extends BaseArrayParser {
	public function new() {
		super();
		_class = ShopFish;
	}
}
