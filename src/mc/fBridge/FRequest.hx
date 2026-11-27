package mc.fBridge;

import com.minutes.net.HTTPRequest;
import common.CommonData;
import common.LocalData;
import mc.control.Command;
import mc.model.MData;
import mc.model.MainData;
import shim.As3;

/**
 * mc.fBridge.FRequest —— FRequest.as 逐句对应（issue #87「网络」片）。
 * 牧场网络出口：postRequest/postRequest2/getRequest 三通道与 httpUrl 转发；
 * post 系请求统一附 farmTime/farmKey/pastureKey/uIdx 装饰（key 算法照抄），
 * act 非空时先过 RequestManager 熔断；validateCode/session 错误在应答闭包
 * 里分派。legacy/decompiled/Master2_v_142/scripts/mc/FBridge/FRequest.as。
 *
 * PORT-NOTE（动态键读写）：value/errData 是 AS3 Object——`value["uId"]`
 * 读 → Reflect.field、`value["farmTime"]=…` 写 → Reflect.setField
 * （仓内 Dynamic 键通道通行做法）。`_loc2_.hasOwnProperty("errorType")` →
 * As3.hasProp（密封/匿名对象含原型链判定，lessons #45 条）；`_loc2_
 * ["errorType"] == "validateCode"` 的宽松等值 → As3.eqString（动态一侧
 * 是 String 时即严格比，数值 coercion 语义保留）。
 * PORT-NOTE（熔断 try 段，:111-138）：`value["uId"]` 在 value null 时
 * AS3 抛 TypeError 被 catch 吞、熔断整段跳过；eval 的 Reflect.field(null)
 * 返 null 不抛——checkAction(act, null) 查不到记录同样返 null，两路汇于
 * 同结局（errStr null → 放行），逐字翻译不构成行为差。
 * PORT-NOTE(命名)：原包 `mc.FBridge` 的 FBridge 段首字母大写，Haxe 包段
 * 必须小写开头，落 `fBridge`（windowControl 同款先例，deviations 候选）。
 */
@:keep
class FRequest {
	// FRequest.as:13
	private static var instance:FRequest;

	// FRequest.as:15-22（单例守卫——原文构造器即完整实现）
	public function new() {
		if (instance != null) {
			throw new openfl.errors.Error("实例化单例类出错-FRequest");
		}
	}

	// FRequest.as:24-31
	public static function getInstance():FRequest {
		if (instance == null) {
			instance = new FRequest();
		}
		return instance;
	}

	// FRequest.as:33-36（postRequest2：timeout 12000）
	public function postRequest2(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:String = null):Void {
		this.request(param1, param2, param3, 12000, false, "text", param4);
	}

	// FRequest.as:38-41（postRequest：timeout 60000）
	public function postRequest(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:String = null):Void {
		this.request(param1, param2, param3, 60000, false, "text", param4);
	}

	// FRequest.as:48-87（lastRequest 四件在 HTTPRequest 调用之前赋值
	// :56-59；"?" 非末尾且有 value 时 url 补 "&" :60-63）
	public function getRequest(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:Int = 60000, param5:Bool = false,
			param6:String = "text"):Void {
		var url:String = param1;
		var value:Dynamic = param2;
		var handlerFun:Dynamic->Void = param3;
		var timeout:Int = param4;
		var reload:Bool = param5;
		var dataFormat:String = param6;
		LocalData.lastRequestValue = value;
		LocalData.lastRequestUrl = url;
		LocalData.lastRequestHandle = handlerFun;
		LocalData.lastRequestFn = this.getRequest;
		if (As3.truthy(value) && As3.truthy(url.indexOf("?") != -1) && url.indexOf("?") != url.length - 1) {
			url += "&";
		}
		HTTPRequest.getInstance().getRequest(url, value, function(param1:Dynamic):Void {
			var _loc2_:Dynamic = param1;
			if (As3.truthy(_loc2_)) {
				if (As3.hasProp(_loc2_, "errorType")) {
					if (As3.eqString(Reflect.field(_loc2_, "errorType"), "validateCode")) {
						Command.getInstance().mainCommand.showWin("validateCode");
					} else if (As3.eqString(Reflect.field(_loc2_, "errorType"), "session")) {
						MData.getInstance().mainData.sessionTimeout = Reflect.field(_loc2_, "errorContent");
					}
				}
				handlerFun(_loc2_);
			} else {
				trace("数据为空!");
			}
		}, timeout, reload, dataFormat);
	}

	// FRequest.as:43-46/:89-92（httpUrl 转发 HTTPRequest 单例）
	public var httpUrl(get, set):String;

	private function get_httpUrl():String {
		return HTTPRequest.getInstance().httpUrl;
	}

	private function set_httpUrl(param1:String):String {
		HTTPRequest.getInstance().httpUrl = param1;
		return param1;
	}

	// FRequest.as:94-186（熔断早退 :111-133：errStr 非空 → handler 收
	// {errorType:"system", errorContent, post_data:value} 且提前 return；
	// 装饰 :143-161：farmTime=String(int(serverTime))、farmKey、pastureKey、
	// value null → 新对象三件，uIdx 无条件补 :162）
	private function request(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:Int = 60000, param5:Bool = false,
			param6:String = "text", param7:String = null):Void {
		var mainData:MainData;
		var farmKey:String;
		var farmTime:String;
		var _timeValue:Int;
		var pastureKey:String;
		var rqManager:RequestManager = null;
		var errStr:String = null;
		var errData:Dynamic = null;
		var url:String = param1;
		var value:Dynamic = param2;
		var handlerFun:Dynamic->Void = param3;
		var timeout:Int = param4;
		var reload:Bool = param5;
		var dataFormat:String = param6;
		var act:String = param7;
		try {
			rqManager = RequestManager.getInstance();
			if (As3.truthy(act)) {
				if (act == RequestManager.ENTER) {
					errStr = rqManager.checkAction(act, Reflect.field(value, "uId"));
				} else {
					errStr = rqManager.checkAction(act);
				}
				if (As3.truthy(errStr)) {
					errData = {
						"errorType": "system",
						"errorContent": errStr,
						"post_data": value
					};
					handlerFun(errData);
					return;
				}
			}
		} catch (e:Dynamic) {}
		LocalData.lastRequestValue = value;
		LocalData.lastRequestUrl = url;
		LocalData.lastRequestHandle = handlerFun;
		LocalData.lastRequestFn = this.postRequest;
		_timeValue = As3.intOf(CommonData.serverTime);
		mainData = MData.getInstance().mainData;
		farmKey = CommonData.getKey();
		farmTime = Std.string(_timeValue);
		pastureKey = MainData.getKey2();
		if (As3.truthy(value)) {
			Reflect.setField(value, "farmTime", farmTime);
			Reflect.setField(value, "farmKey", farmKey);
			Reflect.setField(value, "pastureKey", pastureKey);
		} else {
			value = {
				"farmKey": farmKey,
				"farmTime": farmTime,
				"pastureKey": pastureKey
			};
		}
		Reflect.setField(value, "uIdx", mainData.getHostId);
		HTTPRequest.getInstance().postRequest(url, value, function(param1:Dynamic):Void {
			var _loc2_:Dynamic = param1;
			if (As3.truthy(_loc2_)) {
				if (As3.hasProp(_loc2_, "errorType")) {
					if (As3.eqString(Reflect.field(_loc2_, "errorType"), "validateCode")) {
						Command.getInstance().mainCommand.showWin("validateCode");
					} else if (As3.hasProp(_loc2_, "errorType") && As3.eqString(Reflect.field(_loc2_, "errorType"), "session")) {
						MData.getInstance().mainData.sessionTimeout = Reflect.field(_loc2_, "errorContent");
					}
				}
				handlerFun(_loc2_);
			} else {
				trace("数据为空!");
			}
		}, timeout, reload, dataFormat);
	}
}
