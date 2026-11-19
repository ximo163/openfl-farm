package entities;

import common.misc.Utils;

// entities.DIYDecor —— DIYDecor.as 逐句对应。
// PORT-NOTE: `param1["x"] != undefined` 判键 → Reflect.field(...) != null；
// importFromCache 的 param1:Object 跨实例取字段 → Reflect.field。
@:final
class DIYDecor {
	// DIYDecor.as:7-29 字段（_alreadyOwn 带内联默认值）
	public var _yfb:Int = 0; // AS3 int 默认值
	public var _price:Int = 0; // AS3 int 默认值
	public var _isNew:Int;
	public var _type:Int = 0; // AS3 int 默认值
	public var _exp:Int = 0; // AS3 int 默认值
	public var _fb:Int = 0; // AS3 int 默认值
	public var _lvl:Int = 0; // AS3 int 默认值
	public var _validTime:Int = 0; // AS3 int 默认值
	public var _alreadyOwn:Bool = false;
	public var _desc:String;
	public var _name:String;
	public var _id:Int = 0; // AS3 int 默认值

	// DIYDecor.as:31-35
	public function new(param1:Dynamic) {
		_isNew = -1;
		importObject(param1);
	}

	// DIYDecor.as:37-58
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		_id = Std.int(Utils.getIntAttribute(param1, "itemId"));
		_name = Utils.getStrAttribute(param1, "itemName");
		_type = Std.int(Utils.getIntAttribute(param1, "itemType"));
		_desc = Utils.getStrAttribute(param1, "itemDesc");
		_fb = Std.int(Utils.getIntAttribute(param1, "FBPrice"));
		_yfb = Std.int(Utils.getIntAttribute(param1, "YFBPrice"));
		_price = Std.int(Utils.getIntAttribute(param1, "price"));
		_exp = Std.int(Utils.getIntAttribute(param1, "exp"));
		_validTime = Std.int(Utils.getIntAttribute(param1, "itemValidTime"));
		_lvl = Std.int(Utils.getIntAttribute(param1, "level"));
		if (Reflect.field(param1, "isNew") != null) {
			_isNew = Std.int(Utils.getIntAttribute(param1, "isNew"));
		}
	}

	// DIYDecor.as:60-79
	public function importFromCache(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		_id = Reflect.field(param1, "_id");
		_name = Reflect.field(param1, "_name");
		_type = Reflect.field(param1, "_type");
		_desc = Reflect.field(param1, "_desc");
		_fb = Reflect.field(param1, "_fb");
		_yfb = Reflect.field(param1, "_yfb");
		_price = Reflect.field(param1, "_price");
		_exp = Reflect.field(param1, "_exp");
		_validTime = Reflect.field(param1, "_validTime");
		_lvl = Reflect.field(param1, "_lvl");
		_isNew = Reflect.field(param1, "_isNew");
	}
}
