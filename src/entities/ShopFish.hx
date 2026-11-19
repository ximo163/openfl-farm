package entities;

import common.misc.Utils;

// entities.ShopFish —— ShopFish.as 逐句对应。
@:final
class ShopFish {
	// ShopFish.as:7-23 字段
	public var _lock_crystal:String;
	public var _pool_size:Int = 0; // AS3 int 默认值
	public var _lock:Int;
	public var _type:Int;
	public var _exp:Int = 0; // AS3 int 默认值
	public var _output:Int = 0; // AS3 int 默认值
	public var _price:Int = 0; // AS3 int 默认值
	public var _sale:Int = 0; // AS3 int 默认值
	public var _mature:Int = 0; // AS3 int 默认值
	public var _name:String;
	public var _lock_gold:Int = 0; // AS3 int 默认值
	public var _id:Int = 0; // AS3 int 默认值

	// ShopFish.as:25-31
	public function new(param1:Dynamic) {
		_lock = -1;
		_lock_gold = 0;
		_lock_crystal = "";
		_name = "";
		importObject(param1);
	}

	// ShopFish.as:33-44
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		_id = Std.int(Utils.getIntAttribute(param1, "fid"));
		_lock = Std.int(Utils.getIntAttribute(param1, "lock"));
		_type = Std.int(Utils.getIntAttribute(param1, "type"));
	}
}
