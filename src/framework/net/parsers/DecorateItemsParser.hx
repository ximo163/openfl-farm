package framework.net.parsers;

import entities.DecorateItem;
import framework.net.vo.ServiceResultVO;
import interfaces.ILogicParser;

// framework.net.parsers.DecorateItemsParser —— DecorateItemsParser.as 逐句对应。
class DecorateItemsParser implements ILogicParser {
	// DecorateItemsParser.as:10
	private var _currDiy:Array<Dynamic>;

	// DecorateItemsParser.as:12
	private var _vo:ServiceResultVO;

	// DecorateItemsParser.as:14
	private var _result:Array<Dynamic>;

	// DecorateItemsParser.as:16
	private var _buyedDiy:Array<Dynamic>;

	// DecorateItemsParser.as:18-28
	public function new() {
		_vo = new ServiceResultVO();
		_vo.m_result = "";
		_vo.m_message = "";
		_vo.m_extra = null;
		_result = null;
		_currDiy = [];
		_buyedDiy = [];
	}

	// DecorateItemsParser.as:30-73
	public function parse(param1:Dynamic):ServiceResultVO {
		if (param1 == null) {
			return null;
		}
		if (_result == null) {
			_result = new Array<Dynamic>();
		} else {
			_result.splice(0, _result.length);
		}
		_currDiy.splice(0, _currDiy.length);
		_buyedDiy.splice(0, _buyedDiy.length);
		if (Std.isOfType(Reflect.field(param1, "current"), Array) == true) {
			for (_loc2_ in (Reflect.field(param1, "current") : Array<Dynamic>)) {
				var _loc3_:DecorateItem = new DecorateItem(_loc2_);
				_currDiy.push(_loc3_);
			}
		}
		_result.push(_currDiy);
		if (Std.isOfType(Reflect.field(param1, "items"), Array) == true) {
			for (_loc4_ in (Reflect.field(param1, "items") : Array<Dynamic>)) {
				var _loc5_:DecorateItem = new DecorateItem(_loc4_);
				_buyedDiy.push(_loc5_);
			}
		}
		_result.push(_buyedDiy);
		_vo.m_extra = _result;
		return _vo;
	}
}
