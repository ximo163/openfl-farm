package entities;

import common.misc.Utils;

// entities.Seed —— Seed.as 逐句对应。
@:final
class Seed {
	// Seed.as:11-51 字段（public var 原样）
	public var _isMill:Int;
	public var _isRed:Bool;
	public var _vipDesc:String;
	public var _isVip:Int;
	public var _isNew:Int;
	public var _type:Int;
	public var _sellTime:String;
	public var _output:Int;
	public var _sellLimit:String;
	public var _growCycle:Int;
	public var _sale:Int;
	public var _matureTime:Int;
	public var _isBlack:Bool;
	public var _isGreen:Bool;
	public var _sellLimitDaily:String;
	public var _high_sale:Int;
	public var _isFood:Int;
	public var _id:Int;
	public var _price:Int;
	public var _rl:String;
	public var _isAdSeed:Int;
	public var _exp:Int;
	public var _lvl:Int;
	public var _isRestaurant:Int;
	public var _name:String;
	public var _expect:Int;
	public var _sort:Int;
	public var _isActivity:Int;

	// Seed.as:53-82
	public function new(param1:Dynamic) {
		_isRestaurant = -1;
		_isFood = -1;
		_isActivity = -1;
		_sort = 0;
		_isRed = false;
		_isBlack = false;
		_isGreen = false;
		_high_sale = -1;
		_isMill = -1;
		_isVip = -1;
		_isNew = -1;
		_isAdSeed = -1;
		_rl = "";
		_sellTime = "";
		_sellLimit = "";
		_sellLimitDaily = "";
		importObject(param1);
	}

	// Seed.as:84-145。PORT-NOTE: `param1["x"] != undefined` 判键 →
	// Reflect.field(...) != null（JSON 里 undefined 与缺失同形）。
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		_id = Std.int(Utils.getIntAttribute(param1, "cId"));
		_lvl = Std.int(Utils.getIntAttribute(param1, "cLevel"));
		_name = Utils.getStrAttribute(param1, "cName");
		_type = Std.int(Utils.getIntAttribute(param1, "cType"));
		_exp = Std.int(Utils.getIntAttribute(param1, "cropExp"));
		_expect = Std.int(Utils.getIntAttribute(param1, "expect"));
		_growCycle = Std.int(Utils.getIntAttribute(param1, "growthCycle"));
		_matureTime = Std.int(Utils.getIntAttribute(param1, "maturingTime"));
		_output = Std.int(Utils.getIntAttribute(param1, "output"));
		_price = Std.int(Utils.getIntAttribute(param1, "price"));
		_sale = Std.int(Utils.getIntAttribute(param1, "sale"));
		if (Reflect.field(param1, "isFood") != null) {
			_isFood = Std.int(Utils.getIntAttribute(param1, "isFood"));
		}
		if (Reflect.field(param1, "isRestaurant") != null) {
			_isRestaurant = Std.int(Utils.getIntAttribute(param1, "isRestaurant"));
		}
		if (Reflect.field(param1, "isActivity") != null) {
			_isActivity = Std.int(Utils.getIntAttribute(param1, "isActivity"));
		}
		if (Reflect.field(param1, "high_sale") != null) {
			_high_sale = Std.int(Utils.getIntAttribute(param1, "high_sale"));
		}
		if (Reflect.field(param1, "isMill") != null) {
			_isMill = Std.int(Utils.getIntAttribute(param1, "isMill"));
		}
		if (Reflect.field(param1, "isNew") != null) {
			_isNew = Std.int(Utils.getIntAttribute(param1, "isNew"));
		}
		if (Reflect.field(param1, "isVIP") != null) {
			_isVip = Std.int(Utils.getIntAttribute(param1, "isVIP"));
		}
		if (Reflect.field(param1, "vipDesc") != null) {
			_vipDesc = Utils.getStrAttribute(param1, "vipDesc");
		}
		if (Reflect.field(param1, "actPeroid") != null) {
			_sellTime = Utils.getStrAttribute(param1, "actPeroid");
		}
		if (Reflect.field(param1, "actProvideAmt") != null) {
			_sellLimitDaily = Utils.getStrAttribute(param1, "actProvideAmt");
		}
		if (Reflect.field(param1, "actTotalAmt") != null) {
			_sellLimit = Utils.getStrAttribute(param1, "actTotalAmt");
		}
	}

	// Seed.as:147-174
	public function importFromCache(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		_id = Reflect.field(param1, "_id");
		_lvl = Reflect.field(param1, "_lvl");
		_name = Reflect.field(param1, "_name");
		_type = Reflect.field(param1, "_type");
		_exp = Reflect.field(param1, "_exp");
		_expect = Reflect.field(param1, "_expect");
		_growCycle = Reflect.field(param1, "_growCycle");
		_matureTime = Reflect.field(param1, "_matureTime");
		_output = Reflect.field(param1, "_output");
		_price = Reflect.field(param1, "_price");
		_sale = Reflect.field(param1, "_sale");
		_isFood = Reflect.field(param1, "_isFood");
		_isRestaurant = Reflect.field(param1, "_isRestaurant");
		_isActivity = Reflect.field(param1, "_isActivity");
		_isMill = Reflect.field(param1, "_isMill");
		_sort = Reflect.field(param1, "_sort");
		_isRed = Reflect.field(param1, "_isRed");
		_isBlack = Reflect.field(param1, "_isBlack");
		_isVip = Reflect.field(param1, "_isVip");
		_high_sale = Reflect.field(param1, "_high_sale");
		_vipDesc = Reflect.field(param1, "_vipDesc");
	}
}
