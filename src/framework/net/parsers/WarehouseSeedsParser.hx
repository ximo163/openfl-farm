package framework.net.parsers;

import entities.WarehouseSeed;
import framework.base.BaseArrayParser;

// framework.net.parsers.WarehouseSeedsParser —— WarehouseSeedsParser.as 逐句对应。
class WarehouseSeedsParser extends BaseArrayParser {
	public function new() {
		super();
		_class = WarehouseSeed;
	}
}
