package entities;

import common.CommonData;
import common.GetCropID;
import common.Settings;
import common.misc.Utils;
import shim.As3;

// entities.FarmLand —— FarmLand.as 逐句对应。
// PORT-NOTE: AS3 `param1["x"] != undefined` 判键 → Reflect.field(...) != null
//（JSON 数据里 undefined 与缺失不可区分，AS3 里 undefined == null 也为真，
// 两边语义重合）；`param1["goldLand"] == true` 的松散相等（1/"1"/true 均真）
// 用 As3.truthy 等价复刻。
@:final
class FarmLand {
	// FarmLand.as:11-55 字段（public var 原样）
	public var _humidity:Int = 0; // AS3 int 默认值
	public var _min:Int = 0; // AS3 int 默认值
	public var _oldhumidity:Dynamic;
	public var _cId:Int = 0; // AS3 int 默认值
	public var _output:Int = 0; // AS3 int 默认值
	public var _waste:Bool = false; // AS3 Boolean 默认值
	public var _step:Int = 0; // AS3 int 默认值
	public var _fertilize:Bool;
	public var _harvestTimes:Int = 0; // AS3 int 默认值
	public var _cropStatus:Int = 0; // AS3 int 默认值
	public var _weed:Int = 0; // AS3 int 默认值
	public var _bitmap:UInt = 0; // AS3 uint 默认值
	public var _action:Dynamic;
	public var _thief:Dynamic;
	public var _plantTime:Int = 0; // AS3 int 默认值
	public var _oldweed:Dynamic;
	public var _updateTime:Int = 0; // AS3 int 默认值
	public var _left:Int = 0; // AS3 int 默认值

	// FarmLand.as:47（private var goldLand:int = 0）
	private var goldLand:Int = 0;

	public var _pId:Int = 0; // AS3 int 默认值
	public var _pest:Int = 0; // AS3 int 默认值
	public var _health:Int = 0; // AS3 int 默认值
	public var _oldpest:Dynamic;

	// FarmLand.as:57-61
	public function new(param1:Dynamic) {
		importObject(param1);
	}

	// FarmLand.as:63-66
	public var _goldLand(get, set):Int;

	// FarmLand.as:68-74。PORT-NOTE: `this._humidity == false` 是 AS3 松散相等
	//（false → Number 0），等价 _humidity == 0。
	private function get_needWater():Bool {
		if (_humidity == 0 && _step < 5) {
			return true;
		}
		return false;
	}

	public var needWater(get, never):Bool;

	// FarmLand.as:76-84
	private function get_hasWeed():Bool {
		if (_cId > 0 && _weed > 0 && _step < 5) {
			return true;
		}
		return false;
	}

	public var hasWeed(get, never):Bool;

	// FarmLand.as:86-185
	public function copyFrom(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		if (Reflect.field(param1, "cId") != null) {
			_cId = Std.int(Utils.getIntAttribute(param1, "cId"));
		}
		if (Reflect.field(param1, "cropStatus") != null) {
			_cropStatus = Std.int(Utils.getIntAttribute(param1, "cropStatus"));
		}
		if (Reflect.field(param1, "weed") != null) {
			_weed = Std.int(Utils.getIntAttribute(param1, "weed"));
		}
		if (Reflect.field(param1, "pest") != null) {
			_pest = Std.int(Utils.getIntAttribute(param1, "pest"));
		}
		if (Reflect.field(param1, "humidity") != null) {
			_humidity = Std.int(Utils.getIntAttribute(param1, "humidity"));
		}
		if (Reflect.field(param1, "health") != null) {
			_health = Std.int(Utils.getIntAttribute(param1, "health"));
		}
		if (Reflect.field(param1, "harvestTimes") != null) {
			_harvestTimes = Std.int(Utils.getIntAttribute(param1, "harvestTimes"));
		}
		if (Reflect.field(param1, "output") != null) {
			_output = Std.int(Utils.getIntAttribute(param1, "output"));
		}
		if (Reflect.field(param1, "min") != null) {
			_min = Std.int(Utils.getIntAttribute(param1, "min"));
		}
		if (Reflect.field(param1, "leavings") != null) {
			_left = Std.int(Utils.getIntAttribute(param1, "leavings"));
		}
		if (Reflect.field(param1, "thief") != null) {
			_thief = Reflect.field(param1, "thief");
		} else {
			_thief = {};
		}
		if (Reflect.field(param1, "action") != null) {
			_action = Reflect.field(param1, "action");
		}
		if (Reflect.field(param1, "plantTime") != null) {
			_plantTime = Std.int(Utils.getIntAttribute(param1, "plantTime"));
		}
		if (Reflect.field(param1, "updateTime") != null) {
			_updateTime = Std.int(Utils.getIntAttribute(param1, "updateTime") - 60 * 60);
		}
		if (Reflect.field(param1, "bitmap") != null) {
			_bitmap = Std.int(Utils.getIntAttribute(param1, "bitmap"));
		}
		if (_bitmap > 2) {
			_bitmap = 2;
		}
		if (Reflect.field(param1, "pId") != null) {
			_pId = Std.int(Utils.getIntAttribute(param1, "pId"));
		}
		_step = GetCropID.idState(_cId, _plantTime, _cropStatus, _bitmap, _harvestTimes);
		if (Reflect.field(param1, "fertilize") != null) {
			_fertilize = Utils.getIntAttribute(param1, "fertilize") == _step + 1 ? true : false;
		}
		if (Reflect.field(param1, "oldweed") != null) {
			_oldweed = Reflect.field(param1, "oldweed");
		}
		if (Reflect.field(param1, "oldpest") != null) {
			_oldpest = Reflect.field(param1, "oldpest");
		}
		if (Reflect.field(param1, "oldhumidity") != null) {
			_oldhumidity = Reflect.field(param1, "oldhumidity");
		}
		if (Reflect.hasField(param1, "goldLand")) {
			_goldLand = Reflect.field(param1, "goldLand");
		}
	}

	// FarmLand.as:187-223
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		_cId = Std.int(Utils.getIntAttribute(param1, "a"));
		_cropStatus = Std.int(Utils.getIntAttribute(param1, "b"));
		_weed = Std.int(Utils.getIntAttribute(param1, "f"));
		_pest = Std.int(Utils.getIntAttribute(param1, "g"));
		_humidity = Std.int(Utils.getIntAttribute(param1, "h"));
		_health = Std.int(Utils.getIntAttribute(param1, "i"));
		_harvestTimes = Std.int(Utils.getIntAttribute(param1, "j"));
		_output = Std.int(Utils.getIntAttribute(param1, "k"));
		_min = Std.int(Utils.getIntAttribute(param1, "l"));
		_left = Std.int(Utils.getIntAttribute(param1, "m"));
		_thief = Reflect.field(param1, "n") == null ? {} : Reflect.field(param1, "n");
		_action = Reflect.field(param1, "p") == null ? null : Reflect.field(param1, "p");
		_plantTime = Std.int(Utils.getIntAttribute(param1, "q"));
		_updateTime = Std.int(Utils.getIntAttribute(param1, "r") - 60 * 60);
		// AS3 `param1["goldLand"] == true`：松散相等（true→1），等价 truthy 判定
		if (As3.truthy(Reflect.field(param1, "goldLand"))) {
			_goldLand = 1;
		}
		_waste = false;
		_bitmap = Std.int(Utils.getIntAttribute(param1, "bitmap"));
		if (_bitmap > 2) {
			_bitmap = 2;
		}
		_pId = Std.int(Utils.getIntAttribute(param1, "pId"));
		_step = GetCropID.idState(_cId, _plantTime, _cropStatus, _bitmap, _harvestTimes);
		_fertilize = Utils.getIntAttribute(param1, "o") == _step + 1 ? true : false;
		_oldweed = Reflect.field(param1, "c");
		_oldpest = Reflect.field(param1, "d");
		_oldhumidity = Reflect.field(param1, "e");
	}

	// FarmLand.as:227-246。PORT-NOTE: 原版 `new Date(_loc3_[0])`（Date 单字符串
	// 参构造，解析 "7/10/2012" 这类美式日期串）→ As3.dateOf（Haxe Date.fromString
	// 只认 ISO，见 shim/As3.hx）；解析失败（AS3 Invalid Date，time=NaN）时
	// NaN 比较恒 false，等价跳过窗口判断。
	private function get__goldLand():Int {
		var _loc3_:Array<Dynamic> = null;
		var _loc4_:Date = null;
		var _loc5_:Date = null;
		var _loc6_:Float = Math.NaN;
		var _loc1_:Settings = Settings.getInstance();
		var _loc2_:String = _loc1_.getStringAttribute("jinPaiLand");
		if (As3.truthy(_loc2_)) {
			_loc3_ = _loc2_.split("-");
			_loc4_ = As3.dateOf(Std.string(_loc3_[0]));
			_loc5_ = As3.dateOf(Std.string(_loc3_[1]));
			if (_loc4_ != null && _loc5_ != null) {
				// PORT-NOTE: *1000.0 而非 *1000——eval 解释器对 Int 表示的 Float
				// 值乘 Int 字面量会按 Int32 回绕（同 As3.getTimer 遇到的纪元溢出，
				// 见 shim/As3.hx），*1000.0 强制 double 乘；AS3 Number 本就是 double，
				// 语义不变（js 目标两者一致）
				_loc6_ = CommonData.serverTime * 1000.0;
				if (_loc6_ >= _loc4_.getTime() && _loc6_ <= _loc5_.getTime() && goldLand == 1) {
					return 1;
				}
			}
		}
		return 0;
	}

	private function set__goldLand(param1:Int):Int {
		goldLand = param1;
		return param1;
	}

	// FarmLand.as:247-254
	private function get_hasPest():Bool {
		if (_cId > 0 && _pest > 0 && (_step == 3 || _step == 4)) {
			return true;
		}
		return false;
	}

	public var hasPest(get, never):Bool;
}
