package framework.net.parsers;

import framework.net.vo.ServiceResultVO;
import interfaces.ILogicParser;

// framework.net.parsers.CommonParser —— CommonParser.as 逐句对应。
//（注意原版复用同一个 _result 实例，照抄）
class CommonParser implements ILogicParser {
	// CommonParser.as:10
	private var _result:ServiceResultVO;

	// CommonParser.as:12-16
	public function new() {
		_result = new ServiceResultVO();
	}

	// CommonParser.as:18-22
	public function parse(param1:Dynamic):ServiceResultVO {
		_result.m_extra = param1;
		return _result;
	}
}
