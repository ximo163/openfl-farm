package framework.net.parsers;

import entities.DIYDecor;
import framework.base.BaseArrayParser;

// framework.net.parsers.DIYDataParser —— DIYDataParser.as 逐句对应。
class DIYDataParser extends BaseArrayParser {
	public function new() {
		super();
		_class = DIYDecor;
	}
}
