package entities;

import common.misc.Utils;

// entities.WarehouseSeed —— WarehouseSeed.as 逐句对应。
// PORT-NOTE: `param1["x"] != undefined` 判键 → Reflect.field(...) != null。
@:final
class WarehouseSeed {
	// WarehouseSeed.as:7-21 字段
	public var _isVip:Int;
	public var _ext:Dynamic;
	public var _lvl:Int = 0; // AS3 int 默认值
	public var _price:Int = 0; // AS3 int 默认值
	public var _lifecycle:Int = 0; // AS3 int 默认值
	public var _name:String;
	public var _amount:Int = 0; // AS3 int 默认值
	public var _type:Int = 0; // AS3 int 默认值
	public var _id:Int = 0; // AS3 int 默认值

	// WarehouseSeed.as:23-27
	public function new(param1:Dynamic) {
		_isVip = -1;
		importObject(param1);
	}

	// WarehouseSeed.as:29-61
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		if (Reflect.field(param1, "cId") != null) {
			_id = Std.int(Utils.getIntAttribute(param1, "cId"));
		} else if (Reflect.field(param1, "tId") != null) {
			_id = Std.int(Utils.getIntAttribute(param1, "tId"));
		}
		_name = Utils.getStrAttribute(param1, "cName");
		_lifecycle = Std.int(Utils.getIntAttribute(param1, "lifecycle"));
		_lvl = Std.int(Utils.getIntAttribute(param1, "level"));
		_price = Std.int(Utils.getIntAttribute(param1, "price"));
		_amount = Std.int(Utils.getIntAttribute(param1, "amount"));
		_type = Std.int(Utils.getIntAttribute(param1, "type"));
		_ext = Reflect.field(param1, "ext");
		if (Reflect.field(param1, "isVIP") != null) {
			_isVip = Std.int(Utils.getIntAttribute(param1, "isVIP"));
		}
	}
}
