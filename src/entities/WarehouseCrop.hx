package entities;

import common.misc.Utils;
import shim.As3;

// entities.WarehouseCrop —— WarehouseCrop.as 逐句对应。
// PORT-NOTE: `param1["x"] != undefined` 判键 → Reflect.field(...) != null；
// `param1["isFlower"] == "1"` 松散相等 → As3.eqString。
@:final
class WarehouseCrop {
	// WarehouseCrop.as:7-31 字段
	public var _isFood:Int = 0; // AS3 int 默认值
	public var _price:Int = 0; // AS3 int 默认值
	public var _isFlower:Int = 0; // AS3 int 默认值
	public var _high_price:Int = 0; // AS3 int 默认值
	public var _type:Int = 0; // AS3 int 默认值
	public var _isVip:Int;
	public var _ext:Dynamic;
	public var _lvl:Int = 0; // AS3 int 默认值
	public var _name:String;
	public var _isLock:Int = 0; // AS3 int 默认值
	public var _amount:Int = 0; // AS3 int 默认值
	public var _id:Int = 0; // AS3 int 默认值
	public var _sort:Int = 0; // AS3 int 默认值

	// WarehouseCrop.as:33-45
	public function new(param1:Dynamic) {
		_isLock = -1;
		_isFlower = -1;
		_isFood = -1;
		_sort = 0;
		_high_price = -1;
		_type = -1;
		_isVip = -1;
		importObject(param1);
	}

	// WarehouseCrop.as:47-83
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		_id = Std.int(Utils.getIntAttribute(param1, "cId"));
		_name = Utils.getStrAttribute(param1, "cName");
		_ext = Reflect.field(param1, "ext");
		_lvl = Std.int(Utils.getIntAttribute(param1, "level"));
		_price = Std.int(Utils.getIntAttribute(param1, "price"));
		_amount = Std.int(Utils.getIntAttribute(param1, "amount"));
		_type = Std.int(Utils.getIntAttribute(param1, "type"));
		if (Reflect.field(param1, "isLock") != null) {
			_isLock = Std.int(Utils.getIntAttribute(param1, "isLock"));
		}
		if (Reflect.field(param1, "isFlower") != null) {
			_isFlower = As3.eqString(Reflect.field(param1, "isFlower"), "1") ? 1 : 0;
		}
		if (Reflect.field(param1, "isFood") != null) {
			_isFood = As3.eqString(Reflect.field(param1, "isFood"), "1") ? 1 : 0;
		}
		if (Reflect.field(param1, "high_price") != null) {
			_high_price = Std.int(Utils.getIntAttribute(param1, "high_price"));
		}
		if (Reflect.field(param1, "isVIP") != null) {
			_isVip = Std.int(Utils.getIntAttribute(param1, "isVIP"));
		}
	}
}
