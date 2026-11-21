package mc.model;

import openfl.events.EventDispatcher;

/**
 * mc.model.MainData —— MainData.as 的签名面 stub（原类 1381 loc，牧场片
 * 真身待译——#pasture；issue #19 只保 profile 窗族用到的成员）。
 * legacy/decompiled/Master2_v_142/scripts/mc/model/MainData.as。
 * 事件名/静态开关（MainData.as:78-80、158-164）与 gradeToExp 公式
 * （MainData.as:401-404）按原文字面。
 */
@:keep
class MainData extends EventDispatcher {
	// MainData.as:78-80
	public static final PROFILE:String = "profile";
	public static final PROFILE_LOADING:String = "profileLoading";
	public static final PROFILE_ERR:String = "profileErr";

	// MainData.as:158-164
	public static var loadedProfile:Bool = false;
	public static var loadedMsg:Bool = false;
	public static var loadedLog:Bool = false;
	public static var loadedSystemMsg:Bool = false;

	// MainData.as:184/224/236/240/278/306（backing）
	private var _friendList:Array<Dynamic>;
	private var _profile:Dynamic;
	private var _host:Dynamic;
	private var _profileErr:String = "";
	private var _currentUser:Dynamic;
	private var _profileLoading:Bool = false;

	public function new() {
		super();
	}

	// MainData.as:529
	public var friendList(get, set):Array<Dynamic>;

	private function get_friendList():Array<Dynamic> {
		return this._friendList;
	}

	private function set_friendList(param1:Array<Dynamic>):Array<Dynamic> {
		this._friendList = param1;
		return param1;
	}

	// MainData.as:738
	public var currentUserUin(get, set):String;

	private function get_currentUserUin():String {
		return this._currentUserUin;
	}

	private var _currentUserUin:String = "";

	private function set_currentUserUin(param1:String):String {
		this._currentUserUin = param1;
		return param1;
	}

	// MainData.as:763
	public var currentUser(get, set):Dynamic;

	private function get_currentUser():Dynamic {
		return this._currentUser;
	}

	private function set_currentUser(param1:Dynamic):Dynamic {
		this._currentUser = param1;
		return param1;
	}

	// MainData.as:768
	public var profileErr(get, set):String;

	private function get_profileErr():String {
		return this._profileErr;
	}

	private function set_profileErr(param1:String):String {
		this._profileErr = param1;
		return param1;
	}

	// MainData.as:825
	public var currentUserId(get, set):String;

	private var _currentUserId:String = "";

	private function get_currentUserId():String {
		return this._currentUserId;
	}

	private function set_currentUserId(param1:String):String {
		this._currentUserId = param1;
		return param1;
	}

	// MainData.as:935
	public var profileLoading(get, set):Bool;

	private function get_profileLoading():Bool {
		return this._profileLoading;
	}

	private function set_profileLoading(param1:Bool):Bool {
		this._profileLoading = param1;
		return param1;
	}

	// MainData.as:1140
	public var me(get, set):Bool;

	private var _me:Bool = false;

	private function get_me():Bool {
		return this._me;
	}

	private function set_me(param1:Bool):Bool {
		this._me = param1;
		return param1;
	}

	// MainData.as:1174
	public var host(get, set):Dynamic;

	private function get_host():Dynamic {
		return this._host;
	}

	private function set_host(param1:Dynamic):Dynamic {
		this._host = param1;
		return param1;
	}

	// MainData.as:1195
	public var profile(get, set):Dynamic;

	private function get_profile():Dynamic {
		return this._profile;
	}

	private function set_profile(param1:Dynamic):Dynamic {
		this._profile = param1;
		return param1;
	}

	// MainData.as:1268
	public var getHostId(get, set):String;

	private var _getHostId:String = "";

	private function get_getHostId():String {
		return this._getHostId;
	}

	private function set_getHostId(param1:String):String {
		this._getHostId = param1;
		return param1;
	}

	// MainData.as:401-404
	public function gradeToExp(param1:Int):UInt {
		return 100 * param1 * (param1 + 1);
	}
}
