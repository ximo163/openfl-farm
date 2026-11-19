package entities;

import common.Settings;

// Player.as —— 后续模块翻译，stub 同 module/Main 先例（issue #7 闭包类：StartupDataParser
// 构造 _user = new Player(...) 并写 _user._exp，这里只保证可编译、不抛）。
// 翻译阶段（V3a 启动链 Main/FarmApplication 引用）补齐被引用的 public 字段与
// fid/exportObject（Player.as:66-73/:80-94）；importObject/clone/level 是
// issue #8 write-tests 补的签名 stub（体 throw，V3b 片翻译实现）。
class Player {
	// StartupDataParser.as:52 写入（_loc2_._user._exp = ...），翻译阶段保留该字段。
	public var _exp:Int;

	// Session 的 me/hostId/hostUin 读取（Session.as:108-118/:441-448/:130-137，
	// FarmLandModel.buildCommonPostParams :307-308 也读 _uId/_userName）。
	// 出处 Player.as:22（_uId:uint）、:42（_userName:String）、:12（_uinLogin:uint）。
	public var _uId:UInt;
	public var _userName:String;
	public var _uinLogin:UInt;

	// FarmLandModel.operate_addBug/floatHandler 读 host._canbad（Player.as:40，
	// :107 从回包 canbad 解析；floatHandler :663 写回）
	public var _canbad:Int;

	// FarmApplication.onReloadGameSuccess 读写（Player.as:16/:26/:32/:28/:36/:38/:44/:18/:20）
	public var _pf:Int;
	public var _healthMode:Dynamic;
	public var _moralExp:Int;
	public var _money:Float;
	public var _headPic:String;
	public var _yellowlevel:Int;
	public var _yellowstatus:Int;
	public var uin:UInt;
	public var me:Bool;
	public var sort:Int;

	// Player.as:44（pf2：克隆清单里有它、ctor 默认 true）
	public var pf2:Bool;

	// Player.as:34/:50/:52/:46/:24（issue #8 write-tests 补齐的字段：importObject
	// 的 missionTime/lvup/userId/FB 落点与 _rawData；clone 不带走 _levelup/_fb/_rawData）
	public var _missionTime:Int;
	public var _levelup:Array<Dynamic>;
	public var _userId:UInt;
	public var _fb:Int;
	public var _rawData:Dynamic;

	// Player.as:75-78（get level：expToGrade 截断；V3b 实现）
	public var level(get, never):Int;

	private function get_level():Int {
		throw new openfl.errors.Error("not implemented");
	}

	public function new(param1:Dynamic = null) {}

	// Player.as:101-141（importObject：user 下发块逐键解析（含 healthMode 实体化、
	// uin 跟 _uinLogin），V3b 实现）
	public function importObject(param1:Dynamic):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// Player.as:143-165（clone：身份字段拷贝，不含 _levelup/_fb/_rawData，V3b 实现）
	public function clone():Player {
		throw new openfl.errors.Error("not implemented");
	}

	// Player.as:66-73（FarmApplication.animalAttack/checkWildDataStatus 读 host.fid）
	public var fid(get, never):String;

	private function get_fid():String {
		if (Settings.getInstance().mode == "qzone" || Settings.getInstance().mode == "qplus") {
			return Std.string(this.uin);
		}
		return Std.string(this._uId);
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
}
