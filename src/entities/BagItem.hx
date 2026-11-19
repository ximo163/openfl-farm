package entities;

import common.misc.Utils;

// entities.BagItem —— BagItem.as 逐句对应。
// PORT-NOTE: `param1["x"] != undefined` 判键 → Reflect.field(...) != null。
@:final
class BagItem {
	// BagItem.as:7-21 字段
	public var _depict:String;
	public var _level:Int = 0; // AS3 int 默认值
	public var _lifeCycle:Int = 0; // AS3 int 默认值
	public var _name:String;
	public var _amount:Int = 0; // AS3 int 默认值
	public var _type:Int = 0; // AS3 int 默认值
	public var _sort:Int = 0; // AS3 int 默认值
	public var _cId:Int = 0; // AS3 int 默认值

	// BagItem.as:23-27
	public function new(param1:Dynamic) {
		importObject(param1);
	}

	// BagItem.as:29-74
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		if (Reflect.field(param1, "cId") != null) {
			_cId = Std.int(Utils.getIntAttribute(param1, "cId"));
		}
		if (Reflect.field(param1, "tId") != null) {
			_cId = Std.int(Utils.getIntAttribute(param1, "tId"));
		}
		if (Reflect.field(param1, "fId") != null) {
			_cId = Std.int(Utils.getIntAttribute(param1, "fId"));
		}
		_type = Std.int(Utils.getIntAttribute(param1, "type"));
		if (Reflect.field(param1, "cName") != null) {
			_name = Utils.getStrAttribute(param1, "cName");
		}
		if (Reflect.field(param1, "tName") != null) {
			_name = Utils.getStrAttribute(param1, "tName");
		}
		if (Reflect.field(param1, "amount") != null) {
			_amount = Std.int(Utils.getIntAttribute(param1, "amount"));
		}
		if (Reflect.field(param1, "level") != null) {
			_level = Std.int(Utils.getIntAttribute(param1, "level"));
		}
		if (Reflect.field(param1, "lifecycle") != null) {
			_lifeCycle = Std.int(Utils.getIntAttribute(param1, "lifecycle"));
		}
		_depict = Utils.getStrAttribute(param1, "depict");
		_sort = 0;
	}
}
