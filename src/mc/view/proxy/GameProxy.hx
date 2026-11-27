package mc.view.proxy;

import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;

/**
 * mc.view.proxy.GameProxy —— GameProxy.as 逐句对应（issue #87「代理」片）。
 * 游戏代理单例：parameters/npcLand/iniData 三静态载荷，host/currentUser
 * 属性对，currentUser 换主派 CURRENT_USER_CHANGE；me 按 currentUser/host
 * 的 uId 比对出 Boolean。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/proxy/GameProxy.as。
 *
 * PORT-NOTE(XML)：AS3 XML 类型在 Haxe 无等价物，iniData 落 Dynamic——
 * 用法归 implement 时定夺（xml 解析走 shim 或 Xml 类）。
 */
@:keep
class GameProxy extends EventDispatcher {
	// GameProxy.as:11-17
	public static var parameters:Dynamic;
	public static var npcLand:Sprite;
	private static var instance:GameProxy;
	public static var iniData:Dynamic;
	public static final CURRENT_USER_CHANGE:String = "proxy_UserChange";

	// GameProxy.as:21-23
	private var _currentUser:Dynamic;
	private var _host:Dynamic;

	// GameProxy.as:25-33（单例守卫——原文构造器即完整实现：instance 非空
	// 抛 "实例化单例类出错-LifeData"（原文错误信息串就是 LifeData，照抄）。
	// PORT-NOTE(cpp)：同 MData——super() 前移到守卫外，等价）
	public function new(param1:IEventDispatcher = null) {
		super();
		if (instance == null) {
			return;
		}
		throw new Error("实例化单例类出错-LifeData");
	}

	// GameProxy.as:35-42
	public static function getInstance():GameProxy {
		if (instance == null) {
			instance = new GameProxy();
		}
		return instance;
	}

	// GameProxy.as:44-47/:67-70（host 存取——原文即纯字段读写，入 stub 不掷）
	public var host(get, set):Dynamic;

	private function set_host(param1:Dynamic):Dynamic {
		this._host = param1;
		return param1;
	}

	private function get_host():Dynamic {
		return this._host;
	}

	// GameProxy.as:49-60（me：currentUser/host 双非空且 uId 不同才 false。
	// 原文 `currentUser["uId"] != host["uId"]`：uId 同源同型（下发 JSON 的
	// 字串），AS3 宽松 != 落严格比较等价——裸比形态同 MainData.hx me 先例）
	public var me(get, never):Bool;

	private function get_me():Bool {
		var _loc1_:Bool = true;
		if (this.currentUser != null && this.host != null) {
			if (Reflect.field(this.currentUser, "uId") != Reflect.field(this.host, "uId")) {
				_loc1_ = false;
			}
		}
		return _loc1_;
	}

	// GameProxy.as:62-65
	// GameProxy.as:72-76（setter 赋值 + 派 CURRENT_USER_CHANGE）
	public var currentUser(get, set):Dynamic;

	private function get_currentUser():Dynamic {
		return this._currentUser;
	}

	private function set_currentUser(param1:Dynamic):Dynamic {
		this._currentUser = param1;
		dispatchEvent(new openfl.events.Event(GameProxy.CURRENT_USER_CHANGE));
		return param1;
	}
}
