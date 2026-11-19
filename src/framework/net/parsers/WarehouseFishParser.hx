package framework.net.parsers;

import entities.WarehouseFish;
import framework.base.BaseArrayParser;

// framework.net.parsers.WarehouseFishParser —— WarehouseFishParser.as 逐句对应。
class WarehouseFishParser extends BaseArrayParser {
	public function new() {
		super();
		_class = WarehouseFish;
	}
}
