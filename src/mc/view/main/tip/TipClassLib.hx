package mc.view.main.tip;

import mc.view.farm.animals.HunterInfo;
import mc.view.farm.land.AnimalInfo;
import mc.view.farm.land.HouseTip;
import mc.view.farm.land.ProductInfo;

/**
 * mc.view.main.tip.TipClassLib —— TipClassLib.as 逐句对应（issue #19
 * Master2 闭包顺手译）。名字→类 的静态注册表；AnimalInfo/HunterInfo/
 * ProductInfo 为牧场片 stub。
 */
@:keep
class TipClassLib {
	// TipClassLib.as:11-17
	private static var _lib:Dynamic = {
		"MouseTip": MouseTip,
		"AnimalInfo": AnimalInfo,
		"HunterInfo": HunterInfo,
		"ProductInfo": ProductInfo,
		"HouseTip": HouseTip
	};

	public function new() {}

	// TipClassLib.as:24-31
	public static function getClass(param1:String):Class<Dynamic> {
		if (_lib == null) {
			return null;
		}
		return Reflect.field(_lib, param1);
	}

	// TipClassLib.as:33-40
	public static function register(param1:String, param2:Class<Dynamic>):Void {
		if (_lib == null) {
			_lib = {};
		}
		Reflect.setField(_lib, param1, param2);
	}
}
