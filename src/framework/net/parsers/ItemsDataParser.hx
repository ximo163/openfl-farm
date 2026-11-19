package framework.net.parsers;

import entities.Item;
import framework.base.BaseArrayParser;

// framework.net.parsers.ItemsDataParser —— ItemsDataParser.as 逐句对应。
class ItemsDataParser extends BaseArrayParser {
	public function new() {
		super();
		_class = Item;
	}
}
