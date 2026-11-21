package entities;

import common.Settings;
import common.misc.Utils;
import entities.Player;
import shim.As3;

// Friend.as —— 好友实体（#7 立字段 stub，#20 friends 模块按 Friend.as:37-131
// 补齐构造器初始化与五个成员：importObject/exportObject/importFromCache/
// importFromPlayer/_fid。被 FriendsModel（列表装载/缓存恢复/补自己行）、
// FriendsView/FriendItemRender（渲染数据源）使用）。
@:final
class Friend {
	// Friend.as:7-35（原版 public var，照抄字段区）
	public var _money:Float;
	public var _yellowstatus:Int;
	public var _pastureExp:Int;
	public var _moralExp:Int;
	public var _headPic:String;
	public var _userName:String;
	public var _yellowlevel:Int;
	public var _uin:UInt;
	public var _pf:Int;
	public var _exp:Int;
	public var me:Bool;
	public var _userId:UInt;
	public var sort:Int;
	public var _uId:UInt;
	public var status:Dynamic;

	public function new(param1:Dynamic = null) {
		// Friend.as:37-43
		this._userId = 0;
		this.status = null;
		this.me = false;
		this.sort = 0;
		this.importObject(param1);
	}

	// Friend.as:45-70
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		// PORT-NOTE: AS3 int/uint 字段收 Number 隐式截断，Haxe 显式 Std.int
		//（_money 是 Number 不截）
		this._uId = Std.int(Utils.getIntAttribute(param1, "uId"));
		this._uin = Std.int(Utils.getIntAttribute(param1, "uin"));
		this._exp = Std.int(Utils.getIntAttribute(param1, "exp"));
		this._money = Utils.getIntAttribute(param1, "money");
		this._pf = Std.int(Utils.getIntAttribute(param1, "pf"));
		this._userName = Utils.getStrAttribute(param1, "userName");
		this._headPic = Utils.getStrAttribute(param1, "headPic");
		this._yellowlevel = Std.int(Utils.getIntAttribute(param1, "yellowlevel"));
		this._yellowstatus = Std.int(Utils.getIntAttribute(param1, "yellowstatus"));
		this._pastureExp = Std.int(Utils.getIntAttribute(param1, "pastrueExp"));
		this._moralExp = Std.int(Utils.getIntAttribute(param1, "moralexp"));
		// Friend.as:61-68。PORT-NOTE: `param1["userId"] != undefined` → As3.hasProp
		if (As3.hasProp(param1, "userId")) {
			this._userId = Std.int(Utils.getIntAttribute(param1, "userId"));
			if (this._uId != this._userId) {
				this._uId = this._userId;
			}
		}
	}

	// Friend.as:72-88
	public function exportObject():Dynamic {
		return {
			"uId": this._uId,
			"uin": this._uin,
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

	// Friend.as:90-108。缓存值来自 SharedObject 里存下的好友行（Cookie 值侧，
	// 匿名对象形态），经 Reflect.field 直拷；键都是实体真字段。
	// _pastureExp 原版不拷、保持未设值（不初始化照抄）。
	public function importFromCache(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this._uId = Reflect.field(param1, "_uId");
		this._uin = Reflect.field(param1, "_uin");
		this._exp = Reflect.field(param1, "_exp");
		this._money = Reflect.field(param1, "_money");
		this._pf = Reflect.field(param1, "_pf");
		this._userName = Reflect.field(param1, "_userName");
		this._headPic = Reflect.field(param1, "_headPic");
		this._yellowlevel = Reflect.field(param1, "_yellowlevel");
		this._yellowstatus = Reflect.field(param1, "_yellowstatus");
		this._userId = Reflect.field(param1, "_userId");
		this._moralExp = Reflect.field(param1, "_moralExp");
		this.status = null;
		this.me = Reflect.field(param1, "me");
		this.sort = Reflect.field(param1, "sort");
	}

	// Friend.as:110-116（uinMode 之外的跳转主键：非 qzone/qplus 用 _uId）
	public var _fid(get, never):UInt;

	private function get__fid():UInt {
		if (Settings.getInstance().mode == "qzone" || Settings.getInstance().mode == "qplus") {
			return this._uin;
		}
		return this._uId;
	}

	// Friend.as:118-131（host 行拷进好友实体；_userId 原版赋两遍，照抄）
	public function importFromPlayer(param1:Player):Void {
		if (param1 == null) {
			return;
		}
		this._uId = param1._uId;
		this._uin = param1._uinLogin;
		this._userId = param1._userId;
		this._userName = param1._userName;
		this._exp = param1._exp;
		this._money = param1._money;
		this._pf = param1._pf;
		this._headPic = param1._headPic;
		this._yellowlevel = param1._yellowlevel;
		this._yellowstatus = param1._yellowstatus;
		this._moralExp = param1._moralExp;
		this._pastureExp = 0;
		this._userId = param1._userId;
		this.status = null;
		this.me = param1.me;
		this.sort = 0;
	}
}
