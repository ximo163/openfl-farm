package com.minutes.net;

import cn.snowkit.utils.ObjectCopy;
import com.adobe.serialization.json.JSON;
import com.qzone.corelib.js.JSProxy;
import mc.fBridge.DataURLLoader;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.TimerEvent;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.utils.ByteArray;
import openfl.utils.Timer;

/**
 * com.minutes.net.HTTPRequest —— HTTPRequest.as 逐句对应（issue #86 牧场
 * 库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/net/HTTPRequest.as。
 *
 * PORT-NOTE（`param1 is ByteArray`/`as ByteArray`，HTTPRequest.as:76-80）：
 * eval 裸 cast 不做运行时检查——isOfType 门 + 直取。`_loc2_.position = 0`
 * 是 openfl ByteArray 真属性写（cast 真类型通道）。
 * PORT-NOTE（:93 与 :235 的正则字面量，前者形如「^[\{\[].*」后者
 * 形如「^http.*」——不写全形因正则收尾的星斜线对会撞块注释终结符）：
 * Haxe EReg 等价（构造串转义不同、语义同——`[`/`{` 字面）。
 * PORT-NOTE（for-in 遍历对象键，:259/:279）：`_uv[_name] = value[_name]`
 * 动态键读写 → Reflect.setField/field（URLVariables 是 abstract(Dynamic)，
 * 与匿名对象同通道）。:279 的 `for(k in _postData)`——_postData 运行时
 * 三态（String/URLVariables/匿名对象转来的 _uv）：AS3 for-in 走可枚举
 * 自有键，String 原语无键可枚举（循环体零次）——String 态显式跳过，
 * 其余 Reflect.fields。
 * PORT-NOTE（AS3 闭包变量捕获，:136-232）：clearAll/ioerrorHandler/
 * httpStatusHandler/loadCompHandler/timerFn 是同函数局部变量互指的闭包
 * 族——clearAll 定义在前、引用后赋值的 ioerrorHandler 等，AS3 Function
 * 变量按引用捕获；Haxe 局部变量闭包同为引用捕获（eval/js/cpp 一致），
 * 逐字照抄。各闭包内层 param1 遮蔽外层 request 的 param1 形参——Haxe
 * 内层作用域遮蔽合法，照抄（类型各异：IOErrorEvent/HTTPStatusEvent/
 * Event/TimerEvent，openfl addEventListener 是泛型 <T> 通道）。
 * PORT-NOTE（`param1.target as DataURLLoader` 多处）：事件目标恒为本
 * 函数自造的 aURLLoader，isOfType 门 + 直取（失配 null 时 .postData 上
 * 抛与原行为等价——实践中不可达）。
 * PORT-NOTE（`param1.currentTarget.data`（:182）与 `param1.target` 动态
 * 读）：currentTarget/target 在 openfl 是 Dynamic 通道——读不属禁条
 * （禁条只管写），cast 真类型取 data 与 postData。
 * PORT-NOTE(命名)：原文 import mc.FBridge.DataURLLoader——FBridge 段
 * 首字母大写 Haxe 包段不合法，落 mc.fBridge（见该文件头注）。
 */
@:keep
class HTTPRequest {
	// HTTPRequest.as:21
	private static var instance:HTTPRequest;

	// :23-31
	public static var REQUEST_ERROR:String = "requestError";
	public static var OVER_TIME:String = "overTime";
	public static final IOERROR:String = "IOError";
	public static final HTTPSTATUS:String = "httpStatus";
	public static final TIMEOUT:String = "timeOut";

	// :33-35
	private var _timer:Timer;
	private var _httpUrl:String = "";

	// :37-46
	public function new() {
		if (instance != null) {
			throw new Error("实例化单例类出错-HTTPRequest");
		}
		this._timer = new Timer(1000);
		this._timer.start();
	}

	// :48-55
	public static function getInstance():HTTPRequest {
		if (instance == null) {
			instance = new HTTPRequest();
		}
		return instance;
	}

	// :57-60
	public var httpUrl(get, set):String;

	private function set_httpUrl(param1:String):String {
		this._httpUrl = param1;
		return param1;
	}

	// :62-65
	private function get_httpUrl():String {
		return this._httpUrl;
	}

	// :67-70
	public function getRequest(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:UInt = 60000, param5:Bool = false,
			param6:String = "text"):Void {
		this.request(URLRequestMethod.GET, param1, param2, param3, param4, param5, param6);
	}

	// :72-83（`param1 is ByteArray` 见类头 PORT-NOTE——openfl 9.5.2 的
	// ByteArray 是 abstract（底层 ByteArrayData），运行时判型对底层类做，
	// framework/net/protocol/Protocol.hx:82 同款先例）
	private function dataToString(param1:Dynamic):String {
		var _loc2_:ByteArray = null;
		if (Std.isOfType(param1, openfl.utils.ByteArrayData)) {
			_loc2_ = param1;
			_loc2_.position = 0;
			return _loc2_.readUTFBytes(_loc2_.length);
		}
		return Std.string(param1);
	}

	// :85-105（try/catch 吞错返 null 原版如此；正则语义见类头 PORT-NOTE。
	// `catch(e:Error)`——Haxe catch(Dynamic) 同形兜底）
	private function decode(param1:Dynamic):Dynamic {
		var _data:Dynamic = null;
		var loadStr:String = null;
		var data:Dynamic = param1;
		try {
			loadStr = this.dataToString(data);
			if (~/^[\{\[].*/.match(loadStr) == false) {
				loadStr = "{\"errorType\":\"PHPError\",\"errorContent\":\"" + loadStr + "\"}";
			}
			_data = JSON.decode(loadStr);
			return _data;
		} catch (e:Dynamic) {
			trace("JSON解码错误:" + e + "\n" + loadStr);
		}
		return null;
	}

	// :107-110
	public function postRequest(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:UInt = 60000, param5:Bool = false,
			param6:String = "text"):Void {
		this.request(URLRequestMethod.POST, param1, param2, param3, param4, param5, param6);
	}

	// :112-296（闭包捕获/for-in/正则/as/动态读各点见类头 PORT-NOTE。
	// `getTimer()` → shim.As3.getTimer（int 通道，超时差值比较直翻）。
	// timerFn 里 `_loc2_ = null` 空赋值原样保留（reload 分支首行））
	private function request(param1:String, param2:String, param3:Dynamic, param4:Dynamic->Void, param5:UInt = 60000, param6:Bool = false,
			param7:String = "text"):Void {
		var tk:String = null;
		var _postData:Dynamic = null;
		var isHandler:Bool = false;
		var aURLRequest:URLRequest = null;
		var aURLLoader:DataURLLoader = null;
		var ioerrorHandler:IOErrorEvent->Void = null;
		var httpStatusHandler:HTTPStatusEvent->Void = null;
		var loadCompHandler:Event->Void = null;
		var timerFn:TimerEvent->Void = null;
		var timerValue:Int = 0;
		var requestNum:Int = 0;
		var _uv:URLVariables = null;
		var _name:String = null;
		var tmp:String = null;
		var k:String = null;
		var method:String = param1;
		var url:String = param2;
		var value:Dynamic = param3;
		var handlerFun:Dynamic->Void = param4;
		var timeout:UInt = param5;
		var reload:Bool = param6;
		var dataFormat:String = param7;
		var clearAll:Void->Void = function():Void {
			aURLLoader.close();
			aURLLoader.postData = null;
			_timer.removeEventListener(TimerEvent.TIMER, timerFn);
			aURLLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioerrorHandler);
			aURLLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			aURLLoader.removeEventListener(Event.COMPLETE, loadCompHandler);
		};
		ioerrorHandler = function(param1:IOErrorEvent):Void {
			var _loc2_:Dynamic = null;
			if (!isHandler) {
				_loc2_ = {
					"errorType": "IOError",
					"errorContent": ""
				};
				var _loc3_:Dynamic = param1.target;
				var _loc4_:DataURLLoader = Std.isOfType(_loc3_, DataURLLoader) ? cast(_loc3_, DataURLLoader) : null;
				Reflect.setField(_loc2_, "post_data", ObjectCopy.copy(_loc4_.postData));
				handlerFun(_loc2_);
				isHandler = true;
			}
			clearAll();
		};
		httpStatusHandler = function(param1:HTTPStatusEvent):Void {
			var _loc2_:Dynamic = null;
			if (param1.status != 0 && param1.status != 200) {
				if (!isHandler) {
					_loc2_ = {
						"errorType": "httpStatus",
						"errorContent": param1.status
					};
					var _loc3_:Dynamic = param1.target;
					var _loc4_:DataURLLoader = Std.isOfType(_loc3_, DataURLLoader) ? cast(_loc3_, DataURLLoader) : null;
					Reflect.setField(_loc2_, "post_data", ObjectCopy.copy(_loc4_.postData));
					handlerFun(_loc2_);
					isHandler = true;
				}
			}
		};
		loadCompHandler = function(param1:Event):Void {
			var _loc2_:Dynamic = null;
			if (!isHandler) {
				_loc2_ = this.decode(cast(param1.currentTarget, DataURLLoader).data);
				if (_loc2_ != null) {
					var _loc3_:Dynamic = param1.target;
					var _loc4_:DataURLLoader = Std.isOfType(_loc3_, DataURLLoader) ? cast(_loc3_, DataURLLoader) : null;
					Reflect.setField(_loc2_, "post_data", ObjectCopy.copy(_loc4_.postData));
				}
				handlerFun(_loc2_);
				isHandler = true;
			}
			clearAll();
		};
		timerFn = function(param1:TimerEvent):Void {
			var _loc2_:Dynamic = null;
			if (reload) {
				_loc2_ = null;
				if (shim.As3.getTimer() - timerValue > timeout && requestNum == 0) {
					aURLLoader.load(aURLRequest);
					timerValue = shim.As3.getTimer();
					requestNum = 1;
				} else if (shim.As3.getTimer() - timerValue > timeout && requestNum == 1) {
					if (!isHandler) {
						_loc2_ = {
							"errorType": "timeOut",
							"content": ""
						};
						Reflect.setField(_loc2_, "post_data", ObjectCopy.copy(aURLLoader.postData));
						handlerFun(_loc2_);
						isHandler = true;
					}
					clearAll();
				}
			} else if (shim.As3.getTimer() - timerValue > timeout) {
				if (!isHandler) {
					_loc2_ = {
						"errorType": "timeOut",
						"content": ""
					};
					Reflect.setField(_loc2_, "post_data", ObjectCopy.copy(aURLLoader.postData));
					handlerFun(_loc2_);
					isHandler = true;
				}
				clearAll();
			}
		};
		var completeUrl:String = "";
		if (~/^http.*/.match(url)) {
			completeUrl = url;
		} else {
			completeUrl = this.httpUrl + url;
		}
		tk = JSProxy.addGToken(completeUrl);
		if (tk != null && tk != "") {
			completeUrl = tk;
		}
		// PORT-NOTE: 原版三分支 `value is String` / `value is URLVariables` /
		// 拷贝——openfl 的 URLVariables 是 abstract(Dynamic)，运行时与普通
		// 对象同形无从识别；保 String 分支（可判），URLVariables 输入落进
		// 「转抄到新 URLVariables」分支，键值相同、可观察行为等价
		//（com.qzone.qfa.managers.operation.HttpOperation / qfa.net.HttpRequest
		// 两处同款先例）
		if (Std.isOfType(value, String)) {
			_postData = value;
		} else {
			_uv = new URLVariables();
			for (_name in Reflect.fields(value)) {
				Reflect.setField(_uv, _name, Reflect.field(value, _name));
			}
			_postData = _uv;
		}
		isHandler = false;
		aURLRequest = new URLRequest(completeUrl);
		aURLRequest.method = method;
		aURLRequest.data = _postData;
		aURLLoader = new DataURLLoader();
		aURLLoader.dataFormat = dataFormat;
		aURLLoader.postData = _postData;
		if (method.toLowerCase() == "get" && completeUrl != null) {
			tmp = completeUrl;
			if (tmp.charAt(tmp.length - 1) != "&") {
				tmp += "&";
			}
			if (!Std.isOfType(_postData, String)) {
				for (k in Reflect.fields(_postData)) {
					if (k != "" && k != null) {
						tmp += k + "=" + Std.string(Reflect.field(_postData, k)) + "&";
					}
				}
			}
			aURLRequest.url = tmp;
			aURLRequest.data = null;
		}
		aURLLoader.addEventListener(IOErrorEvent.IO_ERROR, ioerrorHandler);
		aURLLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
		aURLLoader.addEventListener(Event.COMPLETE, loadCompHandler);
		aURLLoader.load(aURLRequest);
		timerValue = shim.As3.getTimer();
		requestNum = 0;
		this._timer.addEventListener(TimerEvent.TIMER, timerFn);
	}
}
