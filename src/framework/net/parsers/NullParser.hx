package framework.net.parsers;

import framework.net.vo.ServiceResultVO;
import interfaces.ILogicParser;

// framework.net.parsers.NullParser —— NullParser.as 逐句对应。
@:final
class NullParser implements ILogicParser {
	public function new() {}

	// NullParser.as:14-17（恒 null）
	public function parse(param1:Dynamic):ServiceResultVO {
		return null;
	}
}
