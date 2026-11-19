package entities;

import common.misc.Utils;

// entities.DecorateItem —— DecorateItem.as 逐句对应。
class DecorateItem {
	// DecorateItem.as:7-23 字段
	public var _created:Int = 0; // AS3 int 默认值
	public var _name:String;
	public var _validTime:Int = 0; // AS3 int 默认值
	public var _itemId:Int = 0; // AS3 int 默认值
	public var _price:Int = 0; // AS3 int 默认值
	public var _status:Int = 0; // AS3 int 默认值
	public var _type:Int = 0; // AS3 int 默认值
	public var _id:Int = 0; // AS3 int 默认值
	public var _exp:Int = 0; // AS3 int 默认值

	// DecorateItem.as:25-29
	public function new(param1:Dynamic) {
		importObject(param1);
	}

	// DecorateItem.as:31-50
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		_id = Std.int(Utils.getIntAttribute(param1, "id"));
		_itemId = Std.int(Utils.getIntAttribute(param1, "itemId"));
		_name = Utils.getStrAttribute(param1, "itemName");
		_type = Std.int(Utils.getIntAttribute(param1, "itemType"));
		_price = Std.int(Utils.getIntAttribute(param1, "price"));
		_exp = Std.int(Utils.getIntAttribute(param1, "exp"));
		_status = Std.int(Utils.getIntAttribute(param1, "status"));
		_validTime = Std.int(Utils.getIntAttribute(param1, "validTime"));
		_created = Std.int(Utils.getIntAttribute(param1, "created"));
	}
}
