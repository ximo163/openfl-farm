package framework.net.parsers;

import entities.PoolFish;
import framework.net.vo.ServiceResultVO;
import interfaces.ILogicParser;
import shim.As3;

// framework.net.parsers.FishIndexParser —— FishIndexParser.as 逐句对应。
// PORT-NOTE: `param1["x"] != undefined` 判键 → Reflect.field(...) != null；
// parseInt → As3.intOf（字符串前缀解析语义）。
class FishIndexParser implements ILogicParser {
	// FishIndexParser.as:10
	private var _vo:ServiceResultVO;

	// FishIndexParser.as:12
	private var _result:Array<Dynamic>;

	// FishIndexParser.as:14-22
	public function new() {
		_vo = new ServiceResultVO();
		_vo.m_result = "";
		_vo.m_message = "";
		_vo.m_extra = null;
		_result = null;
	}

	// FishIndexParser.as:24-56
	public function parse(param1:Dynamic):ServiceResultVO {
		if (param1 == null) {
			return null;
		}
		if (Reflect.field(param1, "open") != null && As3.intOf(Reflect.field(param1, "open")) == 0) {
			_vo.m_extra = null;
			return _vo;
		}
		if (Reflect.field(param1, "fish") != null) {
			if (_result == null) {
				_result = new Array<Dynamic>();
			} else {
				_result.splice(0, _result.length);
			}
			for (_loc2_ in (Reflect.field(param1, "fish") : Array<Dynamic>)) {
				_result.push(new PoolFish(_loc2_));
			}
			_vo.m_extra = _result;
		}
		return _vo;
	}
}
