package entities;

import common.misc.Utils;

// entities.WarehouseFish —— WarehouseFish.as 逐句对应。
// PORT-NOTE: `param1["x"] != undefined` 判键 → Reflect.field(...) != null。
@:final
class WarehouseFish {
	// WarehouseFish.as:7-15 字段
	public var _sale:Int = 0; // AS3 int 默认值
	public var _name:String;
	public var _isLock:Int = 0; // AS3 int 默认值
	public var _amount:Int = 0; // AS3 int 默认值
	public var _type:Int = 0; // AS3 int 默认值
	public var _id:Int = 0; // AS3 int 默认值

	// WarehouseFish.as:17-21
	public function new(param1:Dynamic) {
		_name = "";
		importObject(param1);
	}

	// WarehouseFish.as:23-43
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		_id = Std.int(Utils.getIntAttribute(param1, "fid"));
		_type = Std.int(Utils.getIntAttribute(param1, "type"));
		_amount = Std.int(Utils.getIntAttribute(param1, "num"));
		if (Reflect.field(param1, "lock") != null) {
			_isLock = Std.int(Utils.getIntAttribute(param1, "lock"));
		}
	}
}
