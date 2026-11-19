package entities;

import common.Settings;

// Player.as —— 后续模块翻译，stub 同 module/Main 先例（issue #7 闭包类：StartupDataParser
// 构造 _user = new Player(...) 并写 _user._exp，这里只保证可编译、不抛）。
// 翻译阶段（V3a 启动链 Main/FarmApplication 引用）补齐被引用的 public 字段与
// fid/exportObject（Player.as:66-73/:80-94），importObject/clone 留给后续模块片。
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

	public function new(param1:Dynamic = null) {}

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
