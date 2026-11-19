package framework.net.parsers;

import entities.WarehouseCrop;
import framework.base.BaseArrayParser;
import framework.net.vo.ServiceResultVO;

// framework.net.parsers.WarehouseCropsParser —— WarehouseCropsParser.as 逐句对应。
// PORT-NOTE: `param1["x"] != undefined` 判键 → Reflect.field(...) != null
// （JSON 里 undefined 与缺失同形）。
class WarehouseCropsParser extends BaseArrayParser {
	public function new() {
		super();
		_class = WarehouseCrop;
	}

	// WarehouseCropsParser.as:16-42
	override public function parse(param1:Dynamic):ServiceResultVO {
		if (Reflect.field(param1, "crop") != null) {
			super.parse(Reflect.field(param1, "crop"));
		}
		if (Reflect.field(param1, "flowerPath") != null) {
			_vo.m_extra = {
				"flowerPath": Reflect.field(param1, "flowerPath"),
				"crops": _result,
				"allFlower": Reflect.field(param1, "allFlower")
			};
		} else {
			_vo.m_extra = {
				"flowerPath": "",
				"crops": _result,
				"allFlower": Reflect.field(param1, "allFlower")
			};
		}
		return _vo;
	}
}
