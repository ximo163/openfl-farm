package framework.net;

import com.qzone.qfa.control.Application;
import com.qzone.qfa.events.CommandEvent;
import common.Consts;
import common.misc.Utils;
import framework.commands.CommandList;
import framework.net.vo.ServiceResultVO;
import openfl.net.URLVariables;

// framework.net.NetHelper —— NetHelper.as 逐句对应。
// PORT-NOTE: for-in over Object → Reflect.fields；STATE["x"] → Reflect.field。
@:final
class NetHelper {
	// NetHelper.as:10
	public static var theApp:Application;

	// NetHelper.as:12
	private static var STATE:Dynamic;

	public function new() {}

	// NetHelper.as:23-43
	public static function reSendRequest(param1:Dynamic):Void {
		var _loc3_:String = null;
		if (STATE == null) {
			return;
		}
		var _loc2_:Dynamic = Reflect.field(STATE, "arg");
		if (_loc2_ != null) {
			for (_loc3_ in Reflect.fields(param1)) {
				Reflect.setField(_loc2_, _loc3_, Reflect.field(param1, _loc3_));
			}
		} else {
			_loc2_ = param1;
		}
		sendRequest(Reflect.field(STATE, "cmd"), Reflect.field(STATE, "arg"), Reflect.field(STATE, "success"), Reflect.field(STATE, "fail"));
	}

	// NetHelper.as:45-59
	public static function sendRequest(param1:Int, param2:Dynamic, param3:Dynamic, param4:Dynamic = null):Void {
		if (theApp == null) {
			return;
		}
		STATE = {
			"cmd": param1,
			"arg": param2,
			"success": param3,
			"fail": param4
		};
		var _loc5_:Dynamic = Utils.buildRequest(param1, param2);
		theApp.run(CommandList.SERVICE_REQUEST, _loc5_, "", null, param3, param4);
	}

	// NetHelper.as:61-75
	public static function getRequest(param1:Int, param2:URLVariables, param3:Dynamic, param4:Dynamic = null):Void {
		if (theApp == null) {
			return;
		}
		STATE = {
			"cmd": param1,
			"arg": param2,
			"success": param3,
			"fail": param4
		};
		var _loc5_:Dynamic = Utils.buildRequest(param1, param2, Consts.NET_HTTP_METHOD_GET);
		theApp.run(CommandList.SERVICE_REQUEST, _loc5_, "", null, param3, param4);
	}

	// NetHelper.as:77-93
	public static function getVOData(param1:CommandEvent):Dynamic {
		if (param1 == null || param1.result == null) {
			return null;
		}
		// NetHelper.as:78。PORT-NOTE: AS3 `as` 失配返回 null → Std.isOfType 门 +
		// 直取（eval 上裸 cast 不做运行时检查，语义不等价），`result is Array`
		// 回退分支因此保持可达
		var _loc2_:ServiceResultVO = null;
		if (Std.isOfType(param1.result, ServiceResultVO)) {
			_loc2_ = param1.result;
		}
		if (_loc2_ == null) {
			if (Std.isOfType(param1.result, Array)) {
				return param1.result;
			}
			return null;
		}
		return _loc2_.m_extra;
	}
}
