package mc.model;

import openfl.events.EventDispatcher;

/**
 * mc.model.MainData —— MainData.as 的签名面 stub（原类 1381 loc，牧场片
 * 真身待译——#pasture；issue #19 只保 profile 窗族用到的成员）。
 * legacy/decompiled/Master2_v_142/scripts/mc/model/MainData.as。
 * 事件名/静态开关（MainData.as:78-80、158-164）与 gradeToExp 公式
 * （MainData.as:401-404）按原文字面。只读 getter me/currentUserUin/
 * currentUserId/getHostId 原文就无 setter，逐句译体（不长 (get, set)）。
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

	// MainData.as:738（原文只读 getter：无 setter）
	public var currentUserUin(get, never):String;

	private function get_currentUserUin():String {
		if (this.currentUser != null) {
			return Reflect.field(this.currentUser, "uin");
		}
		return "";
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

	// MainData.as:825（原文只读 getter：无 setter）
	public var currentUserId(get, never):String;

	private function get_currentUserId():String {
		if (this.currentUser != null) {
			return Reflect.field(this.currentUser, "uId");
		}
		return "";
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

	// MainData.as:1140（原文只读 getter：无 setter）
	public var me(get, never):Bool;

	private function get_me():Bool {
		var _loc1_:Bool = true;
		if (this.currentUser != null && this.host != null) {
			// 原文 `currentUser["uId"] != host["uId"]`：uId 同源同型（profile
			// JSON 的字串），AS3 宽松 != 落严格比较等价（裸比形态，见 lessons #9）
			if (Reflect.field(this.currentUser, "uId") != Reflect.field(this.host, "uId")) {
				_loc1_ = false;
			}
		}
		return _loc1_;
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

	// MainData.as:1268（原文只读 getter：无 setter）
	public var getHostId(get, never):String;

	private function get_getHostId():String {
		if (this.host != null) {
			return Reflect.field(this.host, "uId");
		}
		return "";
	}

	// MainData.as:401-404
	public function gradeToExp(param1:Int):UInt {
		return 100 * param1 * (param1 + 1);
	}

	// —— issue #87 补面（网络/数据片充真身需要的成员；签名逐字取自
	// 反编译原文，方法体除已注明的 trivial 实现外随 implement 充真身）——

	// MainData.as:26-156 事件名常量（本组为测试与派发断言所引）
	public static final HOST_CHANGE:String = "hostChange";
	public static final CURRENT_USER_CHANGE:String = "currentUserChange";
	public static final FRIEND_CHANGE:String = "friendChange";
	public static final SESSION_TIMEOUT:String = "sessionTimeout";
	public static final ANIMAL_SHOUHUO:String = "animalShouhuo";

	// MainData.as:180（模块舞台标记，FloatingLayer 读写）
	public static var Stage:String = "farm";

	// MainData.as:188
	private var _sessionTimeout:String = "";

	// MainData.as:206/232
	private var _searchFriendValue:String = "";

	// MainData.as:343-346（getKey2：SHA1(serverTime)）
	public static function getKey2():String {
		throw new openfl.errors.Error("not implemented");
	}

	// MainData.as:859-885（getAnimalNum 窝/棚容量档位表）
	public function getAnimalNum(param1:Float, param2:String):Float {
		throw new openfl.errors.Error("not implemented");
	}

	// MainData.as:893-896（expToGrade 反解公式）
	public function expToGrade(param1:UInt):Int {
		throw new openfl.errors.Error("not implemented");
	}

	// MainData.as:491-506（showFriendSum 分页 ceil）
	public var showFriendSum(get, never):Int;

	private function get_showFriendSum():Int {
		throw new openfl.errors.Error("not implemented");
	}

	// MainData.as:1376-1379（friendPageNum 恒 10）
	public var friendPageNum(get, never):Int;

	private function get_friendPageNum():Int {
		throw new openfl.errors.Error("not implemented");
	}

	// MainData.as:1336-1341（filterFriendList：userName 正则过滤 +
	// qzone 时并入 uin 过滤 + uniq 去重）
	public var filterFriendList(get, never):Array<Dynamic>;

	private function get_filterFriendList():Array<Dynamic> {
		throw new openfl.errors.Error("not implemented");
	}

	// MainData.as:626-629/940-943（searchFriendValue 存取——原文
	// setter 无派发，纯赋值）
	public var searchFriendValue(get, set):String;

	private function get_searchFriendValue():String {
		return this._searchFriendValue;
	}

	private function set_searchFriendValue(param1:String):String {
		this._searchFriendValue = param1;
		return param1;
	}

	// MainData.as:898-905（hostFid：qzone 取 uin，否则 uId）
	public var hostFid(get, never):String;

	private function get_hostFid():String {
		throw new openfl.errors.Error("not implemented");
	}

	// MainData.as:1243-1250（currentFid：qzone 取 currentUserUin，
	// 否则 currentUserId）
	public var currentFid(get, never):String;

	private function get_currentFid():String {
		throw new openfl.errors.Error("not implemented");
	}

	// MainData.as:1286-1291/:1380-1384（sessionTimeout 存取——setter
	// 派发 SESSION_TIMEOUT）
	public var sessionTimeout(get, set):String;

	private function get_sessionTimeout():String {
		return this._sessionTimeout;
	}

	private function set_sessionTimeout(param1:String):String {
		throw new openfl.errors.Error("not implemented");
	}

	// MainData.as:485-489/:839-842（animalShouHuoIndex 存取——setter
	// 派发 ANIMAL_SHOUHUO）
	private var _animalShouHuoIndex:Int;

	public var animalShouHuoIndex(get, set):Int;

	private function get_animalShouHuoIndex():Int {
		return this._animalShouHuoIndex;
	}

	private function set_animalShouHuoIndex(param1:Int):Int {
		throw new openfl.errors.Error("not implemented");
	}
}
