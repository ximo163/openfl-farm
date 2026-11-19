package framework.net.parsers;

import entities.BagItem;
import framework.base.BaseArrayParser;

// framework.net.parsers.BagDataParser —— BagDataParser.as 逐句对应。
class BagDataParser extends BaseArrayParser {
	public function new() {
		super();
		_class = BagItem;
	}
}
