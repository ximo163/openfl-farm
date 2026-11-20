package entities;

import com.qzone.utils.ObjectUtil;
import common.Settings;
import common.misc.Utils;
import shim.As3;

// Player.as —— V3a 落字段与 fid/exportObject，V3b（issue #8）补齐
// ctor/importObject/level/clone 实体逻辑，逐句对应
// legacy/decompiled/main3_v_221/scripts/entities/Player.as。
class Player {
	// Player.as:10/:12/:14/:16/:18/:20/:22/:24/:26/:28（eval/js 上未赋值基元是
	// null 而非 AS3 VM 默认值，逐字段显式落 AS3 默认：int/uint 0、Number NaN、
	// Boolean false；ctor 覆写的再按原顺序覆写）
	public var pf2:Bool = false;
	public var _uinLogin:UInt = 0;
	public var xystr:String;
	public var _pf:Int = 0;
	public var me:Bool = false;
	public var sort:Int = 0;
	public var _uId:UInt = 0;
	public var _rawData:Dynamic;
	public var _healthMode:HealthMode;
	public var _money:Float = Math.NaN;

	// Player.as:30/:32/:34/:36/:38/:40/:42/:44
	public var _yellowstatus:Int = 0;
	public var _moralExp:Int = 0;
	public var _missionTime:Int = 0;
	public var _headPic:String;
	public var _yellowlevel:Int = 0;
	public var _canbad:Int = 0;
	public var _userName:String;
	public var uin:UInt = 0;

	// Player.as:46/:48/:50/:52
	public var _fb:Int = 0;
	public var _exp:Int = 0;
	public var _levelup:Array<Dynamic>;
	public var _userId:UInt = 0;

	// Player.as:54-64（默认值顺序：先落 5 个默认，再 importObject，_rawData 存参）
	public function new(param1:Dynamic) {
		this._userId = 0;
		this.me = true;
		this.sort = 0;
		this.uin = 0;
		this.pf2 = true;
		this.importObject(param1);
		this._rawData = param1;
	}

	// Player.as:66-73（FarmApplication.animalAttack/checkWildDataStatus 读 host.fid）
	public var fid(get, never):String;

	private function get_fid():String {
		if (Settings.getInstance().mode == "qzone" || Settings.getInstance().mode == "qplus") {
			return Std.string(this.uin);
		}
		return Std.string(this._uId);
	}

	// Player.as:75-78（get level：expToGrade 截断）
	public var level(get, never):Int;

	private function get_level():Int {
		return this.expToGrade(this._exp);
	}

	// Player.as:80-94（FarmApplication.setExpressUser 传给牧场的跨壳数据）
	public function exportObject():Dynamic {
		return {
			"uId": this._uId,
			"uin": this.uin,
			"exp": this._exp,
			"money": this._money,
			"pf": this._pf,
			"me": this.me,
			"userName": this._userName,
			"headPic": this._headPic,
			"yellowlevel": this._yellowlevel,
			"yellowstatus": this._yellowstatus
		};
	}

	// Player.as:96-99（AS3 返回值处隐式 Number→int 截断，Std.int 复刻）
	private function expToGrade(param1:UInt):Int {
		return Std.int(Math.sqrt((param1 + 25) / 100) - 0.5);
	}

	// Player.as:101-141（user 下发块逐键映射，healthMode 实体化，uin 跟 _uinLogin）
	public function importObject(param1:Dynamic):Void {
		var _loc2_:Dynamic = null;
		if (param1 == null) {
			return;
		}
		this._canbad = Std.int(Utils.getIntAttribute(param1, "canbad"));
		this._exp = Std.int(Utils.getIntAttribute(param1, "exp"));
		this._missionTime = Std.int(Utils.getIntAttribute(param1, "missionTime"));
		// :110 原版裸 parseFloat：undefined/垃圾串得 NaN，As3.floatOf 保持
		this._money = As3.floatOf(Reflect.field(param1, "money"));
		this._fb = Std.int(Utils.getIntAttribute(param1, "FB"));
		this._pf = Std.int(Utils.getIntAttribute(param1, "pf"));
		this._uId = Std.int(Utils.getIntAttribute(param1, "uId"));
		this._uinLogin = Std.int(Utils.getIntAttribute(param1, "uinLogin"));
		this._yellowlevel = Std.int(Utils.getIntAttribute(param1, "yellowlevel"));
		this._yellowstatus = Std.int(Utils.getIntAttribute(param1, "yellowstatus"));
		this._moralExp = Std.int(Utils.getIntAttribute(param1, "moralexp"));
		// PORT-NOTE: 原版 `param1["k"] != undefined` —— JSON 解析只会出现键缺省
		// 与值 null（宽松等 undefined）两种跳过形态，hasField && 非 null 等价
		if (Reflect.hasField(param1, "userId") && Reflect.field(param1, "userId") != null) {
			this._userId = Std.int(Utils.getIntAttribute(param1, "userId"));
		}
		this._headPic = Utils.getStrAttribute(param1, "headPic");
		this._userName = Utils.getStrAttribute(param1, "userName");
		if (Reflect.hasField(param1, "healthMode") && Reflect.field(param1, "healthMode") != null) {
			this._healthMode = new HealthMode(Reflect.field(param1, "healthMode"));
		} else {
			this._healthMode = null;
		}
		if (Reflect.hasField(param1, "lvup") && Reflect.field(param1, "lvup") != null) {
			_loc2_ = Reflect.field(param1, "lvup");
			this._levelup = Std.isOfType(_loc2_, Array) ? cast(_loc2_, Array<Dynamic>) : null;
		} else {
			this._levelup = null;
		}
		this.uin = this._uinLogin;
	}

	// Player.as:143-165（身份字段拷贝清单；_levelup/_fb/_rawData 不带走）
	public function clone():Player {
		var _loc1_:Player = new Player(null);
		var _loc2_:Dynamic = null;
		_loc1_._canbad = this._canbad;
		_loc1_._exp = this._exp;
		_loc1_._missionTime = this._missionTime;
		_loc1_._money = this._money;
		_loc1_._pf = this._pf;
		_loc1_._uId = this._uId;
		_loc1_._uinLogin = this._uinLogin;
		_loc1_._yellowlevel = this._yellowlevel;
		_loc1_._yellowstatus = this._yellowstatus;
		_loc1_._headPic = this._headPic;
		_loc1_._userName = this._userName;
		_loc2_ = ObjectUtil.clone(this._healthMode);
		_loc1_._healthMode = Std.isOfType(_loc2_, HealthMode) ? cast(_loc2_, HealthMode) : null;
		_loc1_._userId = this._userId;
		_loc1_._moralExp = this._moralExp;
		_loc1_.me = this.me;
		_loc1_.sort = this.sort;
		_loc1_.uin = this.uin;
		_loc1_.pf2 = this.pf2;
		return _loc1_;
	}
}
