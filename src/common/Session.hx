package common;

import entities.Player;

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
}
