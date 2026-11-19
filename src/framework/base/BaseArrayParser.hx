package framework.base;

import framework.net.vo.ServiceResultVO;
import interfaces.ILogicParser;

// framework.base.BaseArrayParser —— BaseArrayParser.as 逐句对应。
// PORT-NOTE: `new this._class(_loc2_)` 反射构造 → Type.createInstance。
class BaseArrayParser implements ILogicParser {
	// BaseArrayParser.as:10-16
	private var _vo:ServiceResultVO;
	private var _class:Class<Dynamic>;
	private var _result:Array<Dynamic>;

	// BaseArrayParser.as:18-26
	public function new() {
		_class = null;
		_vo = new ServiceResultVO();
		_vo.m_result = "";
		_vo.m_message = "";
		_vo.m_extra = null;
		_result = null;
	}

	// BaseArrayParser.as:28-56
	public function parse(param1:Dynamic):ServiceResultVO {
		if (param1 == null) {
			return null;
		}
		if (_class == null) {
			return null;
		}
		if (_result == null) {
			_result = new Array<Dynamic>();
		} else {
			_result.splice(0, _result.length);
		}
		if (Std.isOfType(param1, Array) == true) {
			for (_loc2_ in (param1 : Array<Dynamic>)) {
				var _loc3_:Dynamic = Type.createInstance(_class, [_loc2_]);
				_result.push(_loc3_);
			}
		} else {
			_result.push(Type.createInstance(_class, [param1]));
		}
		_vo.m_extra = _result;
		return _vo;
	}
}
