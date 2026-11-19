package common;

import common.misc.Cookies;
import entities.Dog;
import entities.Player;
import module.FarmApplication;
import openfl.errors.ArgumentError;

/**
 * common.Session —— 闭包 stub（issue #7，后续模块翻译，stub 同 module/Main 先例）。
 * 本片被测代码只经 Session.getInstance() 读这些成员：
 * - FarmLandModel.buildCommonPostParams（FarmLandModel.as:300-326）读
 *   currentUser/host/friendKeys；
 * - FarmLandModel.hasLandToScarify（:1828）读 me；
 * - Protocol.encodeForHttp（Protocol.as:96-118）读 hostId/hostUin。
 * 这些成员在 legacy/decompiled/main3_v_221/scripts/common/Session.as 里就是字段
 * 存取（set/get currentUser :326-329/:450-453、set/get host :332-338/:139-141、
 * get friendKeys :341-344）加两条一行推导（get me :108-118 比较 _uId、
 * get hostUin :130-137 取 _uinLogin、get hostId :441-448 取 _uId）。这里只提供
 * 同等的最小存取语义供单测钉状态；原版的 m_app 派发副作用（:328/:336）不在此
 * 列，完整翻译在后续片（spec/modules/farm-basic.json common.Session，521 loc）。
 */
class Session {
	// Session.as:78-87
	private static var _instance:Session;

	// Session.as:14（m_currentUser）/ :42（m_host）/ :36（m_friendsKey）
	private var m_currentUser:Player;
	private var m_host:Player;
	private var m_friendsKey:Dynamic;

	public function new() {
		m_friendsKey = {};
	}

	// Session.as:79-87
	public static function getInstance():Session {
		if (_instance != null) {
			return _instance;
		}
		_instance = new Session();
		return _instance;
	}

	// Session.as:108-118（currentUser._uId == host._uId 即到访自己农场）
	public var me(get, never):Bool;

	private function get_me():Bool {
		if (m_currentUser != null && m_host != null) {
			if (m_currentUser._uId == m_host._uId) {
				return true;
			}
		}
		return false;
	}

	// Session.as:130-137（host._uinLogin 非 0 才有值）
	public var hostUin(get, never):String;

	private function get_hostUin():String {
		if (m_host != null && m_host._uinLogin != 0) {
			return Std.string(m_host._uinLogin);
		}
		return "";
	}

	// Session.as:441-448
	public var hostId(get, never):String;

	private function get_hostId():String {
		if (m_host != null) {
			return Std.string(m_host._uId);
		}
		return "";
	}

	// Session.as:450-453（原版 setter :326-329 经 m_app 派发 MSG_CURRENT_USER_CHANGED，
	// stub 只存字段）
	public var currentUser(get, set):Player;

	private function get_currentUser():Player {
		return m_currentUser;
	}

	private function set_currentUser(param1:Player):Player {
		m_currentUser = param1;
		return param1;
	}

	// Session.as:139-141（原版 setter :332-338 顺带写 host.me/sort/uin 并经 m_app
	// 派发 MSG_HOST_CHANGED，stub 只存字段）
	public var host(get, set):Player;

	private function get_host():Player {
		return m_host;
	}

	private function set_host(param1:Player):Player {
		m_host = param1;
		return param1;
	}

	// Session.as:341-344
	public var friendKeys(get, never):Dynamic;

	private function get_friendKeys():Dynamic {
		return m_friendsKey;
	}

	// ---- 以下为 issue #7 实现阶段补的闭包成员（存取语义按原文；原版经 m_app
	// 的派发副作用不在此列，完整翻译在后续片）----

	// Session.as:94-96（get myFairy：宿主精灵道具，无则 null；写入侧是
	// Main/FarmApplication 的 model.setData(MY_FAIRY_OBJECT,…)）
	public var myFairy(get, never):Dynamic;

	private function get_myFairy():Dynamic {
		return this.m_app.model.getData(Consts.MY_FAIRY_OBJECT);
	}

	// Session.as:60（public var isExpLocked:Boolean = false，OperationQueue 用）
	public var isExpLocked:Bool = false;

	// Session.as:40+180+279（harvestAnimationPlaying 存取；setter 派发
	// MSG_* 的副作用不在 stub 里）
	public var harvestAnimationPlaying(get, set):Bool;

	private function get_harvestAnimationPlaying():Bool {
		return m_harvestAnimationPlaying;
	}

	private function set_harvestAnimationPlaying(param1:Bool):Bool {
		m_harvestAnimationPlaying = param1;
		return param1;
	}

	// Session.as:40（private var m_harvestAnimationPlaying:Boolean）
	private var m_harvestAnimationPlaying:Bool = false;

	// Session.as:54+171-178+455-471（expFullToday 存取：setter 值变更时写
	// Cookies 持久化，getter 为 false 时回读 cookie）
	public var expFullToday(get, set):Bool;

	private function get_expFullToday():Bool {
		if (m_expFullToday) {
			return m_expFullToday;
		}
		var _loc1_:Dynamic = Cookies.getObject("expFullToday");
		// PORT-NOTE: AS3 `_loc1_["full"] as Boolean == true` → isOfType 门 + 直取
		if (_loc1_ != null && Std.isOfType(Reflect.field(_loc1_, "full"), Bool) && Reflect.field(_loc1_, "full") == true) {
			m_expFullToday = true;
		} else {
			m_expFullToday = false;
		}
		return m_expFullToday;
	}

	private function set_expFullToday(param1:Bool):Bool {
		if (m_expFullToday != param1) {
			Cookies.setObject("expFullToday", {"full": param1}, 0, false);
		}
		m_expFullToday = param1;
		return param1;
	}

	// Session.as:54（private var m_expFullToday:Boolean = false）
	private var m_expFullToday:Bool = false;

	// Session.as:16（public var upGoldLandTime:int）——module.Main.startGame
	// 写 StartupData 的 upGoldLandTime（Session.as:46-52 一带）
	public var upGoldLandTime:Int;

	// Session.as:46（public var m_isDogHungry:Boolean = false）
	public var m_isDogHungry:Bool = false;

	// Session.as:50（public var m_welcomeMode:Boolean = false）
	public var m_welcomeMode:Bool = false;

	// Session.as:120-128（updateCurrentFriendsKeys：fkey 值按当前用户 uid 存键，
	// FarmLandModel.buildCommonPostParams :321-324 按同键取回）
	public function updateCurrentFriendsKeys(param1:Dynamic):Void {
		var _loc2_:Player = this.currentUser;
		if (_loc2_ == null) {
			return;
		}
		Reflect.setField(m_friendsKey, Std.string(_loc2_._uId), param1);
	}

	// Session.as:185-（addReward(Array)：收获礼包入包；V3c 片翻译，stub 空实现）
	public function addReward(param1:Array<Dynamic>):Void {}

	// Session.as:360-（updateHostAccount(money,exp,...)：宿主账户数值同步；
	// V3b 片翻译，stub 空实现——单测里钱/经验断言不经过它）
	public function updateHostAccount(param1:Int = 0, param2:Int = 0, param3:Int = 0, param4:Int = 0):Void {}

	// Session.as:416-（checkHealthMode：健康模式（未成年人防沉迷）窗口判定，
	// V3b 片翻译，stub 恒 false = 不在健康模式）
	public function checkHealthMode():Bool {
		return false;
	}

	// ---- issue #7 启动链补的闭包成员（同样字段存取语义）----

	// Session.as:48+265-268/:284-286（app：宿主应用引用，module.Main.init 注入）
	public var app(get, set):FarmApplication;

	private var m_app:FarmApplication;

	private function get_app():FarmApplication {
		return this.m_app;
	}

	private function set_app(param1:FarmApplication):FarmApplication {
		this.m_app = param1;
		return param1;
	}

	// Session.as:38（public var dog:Dog）——Main.startGame 存 StartupData._dog
	public var dog:Dog;

	// Session.as:28（public var isInWildStage:Boolean = false）——FarmStage
	// 场景切换处理器读写
	public var isInWildStage:Bool = false;

	// Session.as:44（public var isFromMail:Boolean = false）——Main.doMiscThings
	public var isFromMail:Bool = false;

	// Session.as:58（public var m_lockFishMouse:Boolean）——FarmApplication
	// 切换用户后复位
	public var m_lockFishMouse:Bool;

	// Session.as:22（public var m_buildVersion:String）——Main.init 存
	// VersionUtil.versionString
	public var m_buildVersion:String;

	// Session.as:24（public var healthModeValid:Boolean = false）——
	// FarmLandController 跨用户切换时复位
	public var healthModeValid:Bool = false;

	// Session.as:52（public var currentFarmHealthModeValid:Boolean = false）
	public var currentFarmHealthModeValid:Bool = false;

	// Session.as:349-358（isMeVIP：host._yellowstatus > 0）
	public var isMeVIP(get, never):Bool;

	private function get_isMeVIP():Bool {
		if (this.m_host != null && this.m_host._yellowstatus > 0) {
			return true;
		}
		return false;
	}

	// Session.as:270-277/:346-349（sceneDecorates：场景装饰走 model 的
	// UserDecorate 键，setter 空数据抛 ArgumentError 照抄）
	public var sceneDecorates(get, set):Dynamic;

	private function get_sceneDecorates():Dynamic {
		return this.m_app.model.getData(Consts.USER_DECORATE_OBJECT);
	}

	private function set_sceneDecorates(param1:Dynamic):Dynamic {
		if (param1 == null) {
			throw new ArgumentError("Invalid scene decorates data");
		}
		this.m_app.model.setData(Consts.USER_DECORATE_OBJECT, param1);
		return param1;
	}

	// Session.as:473-489（currentUserIdByUinMode：QZone uin 模式下取 uin）
	public var currentUserIdByUinMode(get, never):UInt;

	private function get_currentUserIdByUinMode():UInt {
		var _loc1_:UInt = 0;
		var _loc2_:Player = this.currentUser;
		if (_loc2_ == null) {
			return _loc1_;
		}
		_loc1_ = this.currentUser._uId;
		if (Settings.isQZoneUinMode == true) {
			_loc1_ = _loc2_.uin;
		}
		return _loc1_;
	}
}
