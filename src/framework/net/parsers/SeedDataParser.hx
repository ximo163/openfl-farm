package framework.net.parsers;

import entities.Seed;
import framework.base.BaseArrayParser;

// framework.net.parsers.SeedDataParser —— SeedDataParser.as 逐句对应。
class SeedDataParser extends BaseArrayParser {
	public function new() {
		super();
		_class = Seed;
	}
}
