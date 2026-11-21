package entities;

import common.CommonData;
import common.Consts;
import common.GetCropID;
import common.Settings;
import common.misc.Utils;
import shim.As3;

/**
 * entities.PoolFish —— PoolFish.as 逐句对应（issue #29 替换 8 行 stub）。
 * 鱼塘格位鱼实体：导入 cgi_fish_index 状态（fid/o/l/p/s/f 键），按 fish_info
 * 配置行的 cycle 段算等级/剩余时间/最少产量。
 * legacy/decompiled/main3_v_221/scripts/entities/PoolFish.as。
 */
final class PoolFish {
	// PoolFish.as:12
	private var _st:Dynamic;

	// PoolFish.as:14
	public var _thief:Array<Dynamic>;

	// PoolFish.as:16
	public var _plantTime:Int;

	// PoolFish.as:18
	public var _output:Int;

	// PoolFish.as:20
	public var _left:Int;

	// PoolFish.as:22
	public var _type:Int;

	// PoolFish.as:24
	public var _nextStepTime:Float;

	// PoolFish.as:26
	private var _cycles:Array<Dynamic>;

	// PoolFish.as:28
	public var _fertilize:Bool;

	// PoolFish.as:30
	public var _id:Int;

	// PoolFish.as:32-40（importObject 里 level 会先把 _st 填上，ctor 末尾再清）
	public function new(param1:Dynamic) {
		this._fertilize = true;
		this.importObject(param1);
		this._nextStepTime = 0;
		this._st = null;
		this._cycles = null;
	}

	// PoolFish.as:42-60
	public function calcNextStepTime():Void {
		var _loc1_:Int = this.level;
		if (_loc1_ < 0) {
			return;
		}
		if (_loc1_ == 3) {
			this._nextStepTime = Math.POSITIVE_INFINITY;
			return;
		}
		var _loc2_:Array<Dynamic> = this.cycles;
		if (_loc2_ == null || _loc2_.length == 0) {
			return;
		}
		this._nextStepTime = this._plantTime + _loc2_[_loc1_];
	}

	// PoolFish.as:62-93
	public function importObject(param1:Dynamic):Void {
		var _loc3_:Int = 0;
		if (param1 == null) {
			return;
		}
		this._id = Std.int(Utils.getIntAttribute(param1, "i"));
		this._type = Std.int(Utils.getIntAttribute(param1, "fid"));
		this._left = Std.int(Utils.getIntAttribute(param1, "l"));
		this._output = Std.int(Utils.getIntAttribute(param1, "o"));
		this._plantTime = Std.int(Utils.getIntAttribute(param1, "p"));
		// `param1["s"] as Array`：单次取值进局部再过类型门（as 失配落 null，
		// lessons #18 双调条），同引用不拷贝
		var _locS_:Dynamic = Reflect.field(param1, "s");
		this._thief = Std.isOfType(_locS_, Array) ? cast(_locS_, Array<Dynamic>) : null;
		if (this._thief == null) {
			this._thief = new Array<Dynamic>();
		}
		this.calcNextStepTime();
		var _loc2_:Int = Std.int(Utils.getIntAttribute(param1, "f"));
		if (_loc2_ == 1 || _loc2_ == 2 || _loc2_ == 3) {
			_loc3_ = this.level;
			this._fertilize = _loc2_ == _loc3_ + 1 ? true : false;
			if (_loc3_ == Consts.FISH_MAX_LEVEL) {
				this._fertilize = false;
			}
		} else {
			this._fertilize = false;
		}
	}

	// PoolFish.as:96-99
	public var canHarvest(get, never):Bool;

	private function get_canHarvest():Bool {
		// PORT-NOTE: 原文 `this.level >= Consts.FISH_MAX_LEVEL`（uint 常量）。
		// AS3 int/uint 比较先升 Number（level=-1 时 -1 >= 3 为假）；Haxe 的
		// Int 对 UInt 比较是无符号域（-1 当 0xFFFFFFFF 恒真，eval probe 证实）
		//——常量显式回 Int 复刻 AS3 数值域
		return this.level >= (Consts.FISH_MAX_LEVEL:Int);
	}

	// PoolFish.as:101-132
	public var level(get, never):Int;

	private function get_level():Int {
		if (this._st == null) {
			// `this._type.toString()`：AS3 int.toString() → Std.string（lessons #19）
			this._st = Settings.getInstance().getFishByID(Std.string(this._type));
		}
		if (this._st == null) {
			return -1;
		}
		var _loc1_:Array<Dynamic> = this.cycles;
		if (_loc1_ == null || _loc1_.length == 0) {
			return -1;
		}
		var _loc2_:Float = CommonData.serverTime;
		var _loc3_:Float = _loc2_ - this._plantTime;
		if (_loc3_ < 0) {
			return -1;
		}
		var _loc4_:Int = 0;
		while (_loc4_ < _loc1_.length) {
			if (_loc3_ < _loc1_[_loc4_]) {
				return _loc4_;
			}
			_loc4_++;
		}
		return _loc1_.length;
	}

	// PoolFish.as:134-161
	public var cycles(get, never):Array<Dynamic>;

	private function get_cycles():Array<Dynamic> {
		if (this._cycles != null) {
			return this._cycles;
		}
		if (this._st == null) {
			this._st = Settings.getInstance().getFishByID(Std.string(this._type));
		}
		// `this._st["cycle"] == undefined` 的完整映射：hasField && 值 != null
		//（AS3 null == undefined，两查都要——lessons #8）
		if (this._st == null || !(Reflect.hasField(this._st, "cycle") && Reflect.field(this._st, "cycle") != null)) {
			return null;
		}
		var _loc1_:Array<Dynamic> = (Reflect.field(this._st, "cycle"):String).split(",");
		if (_loc1_ == null || _loc1_.length == 0) {
			return null;
		}
		this._cycles = new Array<Dynamic>();
		var _loc2_:Int = 0;
		while (_loc2_ < _loc1_.length) {
			this._cycles.push(As3.floatOf(_loc1_[_loc2_]));
			_loc2_++;
		}
		return this._cycles;
	}

	// PoolFish.as:163-166
	public var animationUrl(get, never):String;

	private function get_animationUrl():String {
		return GetCropID.getFishUrl(this._type, false);
	}

	// PoolFish.as:168-175
	public var name(get, never):String;

	private function get_name():String {
		if (this._st == null) {
			this._st = Settings.getInstance().getFishByID(Std.string(this._type));
		}
		return cast(Reflect.field(this._st, "crop_name"), String);
	}

	// PoolFish.as:177-194
	public var min(get, never):Int;

	private function get_min():Int {
		var _loc1_:Float = 0;
		if (this._output > 0) {
			_loc1_ = this._output;
		} else {
			if (this._st == null) {
				this._st = Settings.getInstance().getFishByID(Std.string(this._type));
			}
			_loc1_ = As3.floatOf(Reflect.field(this._st, "output"));
		}
		_loc1_ *= 0.6;
		// `Math.ceil(_loc1_) as int`：整数值 Number → int 截断
		return Std.int(Math.ceil(_loc1_));
	}

	// PoolFish.as:196-217
	public function refreshStatus(param1:Dynamic):Void {
		var _loc3_:Int = 0;
		this._left = Std.int(Utils.getIntAttribute(param1, "l"));
		this._output = Std.int(Utils.getIntAttribute(param1, "o"));
		this._plantTime = Std.int(Utils.getIntAttribute(param1, "p"));
		this.calcNextStepTime();
		var _loc2_:Int = Std.int(Utils.getIntAttribute(param1, "f"));
		if (_loc2_ == 1 || _loc2_ == 2 || _loc2_ == 3) {
			_loc3_ = this.level;
			this._fertilize = _loc2_ == _loc3_ + 1 ? true : false;
			if (_loc3_ == Consts.FISH_MAX_LEVEL) {
				this._fertilize = false;
			}
		} else {
			this._fertilize = false;
		}
	}

	// PoolFish.as:219-259
	public var leftTime(get, never):Array<Dynamic>;

	private function get_leftTime():Array<Dynamic> {
		if (this._st == null) {
			this._st = Settings.getInstance().getFishByID(Std.string(this._type));
		}
		if (this._st == null) {
			return null;
		}
		var _loc1_:Array<Dynamic> = this.cycles;
		if (_loc1_ == null || _loc1_.length == 0) {
			return null;
		}
		var _loc2_:Float = CommonData.serverTime;
		var _loc3_:Float = _loc2_ - this._plantTime;
		if (_loc3_ <= 0) {
			return null;
		}
		var _loc4_:Float = 0;
		var _loc5_:Int = 0;
		while (_loc5_ < _loc1_.length) {
			if (_loc3_ < _loc1_[_loc5_]) {
				if (_loc5_ > 0) {
					_loc4_ = _loc1_[_loc5_] - _loc1_[_loc5_ - 1];
				} else {
					// 原文 `Number(_loc1_[_loc5_])`：段全长取首段原值
					_loc4_ = _loc1_[_loc5_];
				}
				return [_loc1_[_loc5_] - _loc3_, _loc4_];
			}
			_loc5_++;
		}
		return [0, 0];
	}

	// PoolFish.as:261-268（`this._st["pool_size"]` 经 AS3 int 隐式截断）
	public var poolSize(get, never):Int;

	private function get_poolSize():Int {
		if (this._st == null) {
			this._st = Settings.getInstance().getFishByID(Std.string(this._type));
		}
		return As3.intOf(Reflect.field(this._st, "pool_size"));
	}
}
