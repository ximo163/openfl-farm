package framework.net.parsers;

import entities.Friend;
import framework.base.BaseArrayParser;

// framework.net.parsers.FriendsDataParser —— FriendsDataParser.as 逐句对应。
class FriendsDataParser extends BaseArrayParser {
	public function new() {
		super();
		_class = Friend;
	}
}
