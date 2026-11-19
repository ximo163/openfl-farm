package com.qzone.qfa.managers.operation;

import com.qzone.qfa.managers.errors.ConnectionError;
import com.qzone.qfa.managers.events.RequestEvent;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLVariables;
import shim.As3;

// com.qzone.qfa.managers.operation.HttpOperation —— HttpOperation.as 逐句对应。
// PORT-NOTE: AS3 protected 字段/方法按 CLAUDE.md 落 Haxe 默认可见性
//（private，子类可见），HttpOperationEx 跨包覆写依赖这一点。
// PORT-NOTE: `param1 is URLVariables` 判不了——openfl 的 URLVariables 是
// abstract(Dynamic)，运行时与普通对象同形。保 String 分支（可判），URLVariables
// 输入走「转抄到新 URLVariables」，键值相同，可观察行为等价。
class HttpOperation extends Operation implements IOperation {
	// HttpOperation.as:15-16
	public static final GET_METHOD:String = "get";
	public static final POST_METHOD:String = "post";

	// HttpOperation.as:18-24（AS3 protected）
	private var _urlLoader:URLLoader;
	private var _method:String;
	private var _urlReq:URLRequest;
	private var _format:String;

	// HttpOperation.as:26-36
	public function new(param1:String = "", param2:Dynamic = null) {
		super();
		_method = As3.truthy(param2) && Reflect.field(param2, "method") != null ? Reflect.field(param2, "method") : POST_METHOD;
		_format = As3.truthy(param2) && Reflect.field(param2, "format") != null ? Reflect.field(param2, "format") : URLLoaderDataFormat.TEXT;
		set_url(param1);
		open();
	}

	// HttpOperation.as:38-48
	private function handleError(param1:Event):Void {
		if (Std.isOfType(param1, SecurityErrorEvent)) {
			dispatchEvent(new RequestEvent(RequestEvent.FAULT, ConnectionError.ERR_SECURITY));
		} else {
			dispatchEvent(new RequestEvent(RequestEvent.FAULT, ConnectionError.ERR_IO));
		}
	}

	// HttpOperation.as:50-53
	private function handleComplete(param1:Event):Void {
		dispatchEvent(new RequestEvent(RequestEvent.RESULT, _urlLoader.data));
	}

	// HttpOperation.as:55-113
	public override function send(param1:Dynamic = null):Void {
		var _loc2_:Dynamic = null;
		var _loc3_:URLVariables = null;
		var _loc4_:String = null;
		var _loc6_:String = null;
		var _loc7_:String = null;
		if (_urlReq == null) {
			_urlReq = new URLRequest(_url);
		} else if (_url != _urlReq.url) {
			_urlReq.url = _url;
		}
		if (As3.truthy(param1)) {
			if (Std.isOfType(param1, String)) {
				_loc2_ = param1;
			} else {
				_loc3_ = new URLVariables();
				for (_loc4_ in Reflect.fields(param1)) {
					Reflect.setField(_loc3_, _loc4_, Reflect.field(param1, _loc4_));
				}
				_loc2_ = _loc3_;
			}
			_urlReq.method = _method;
			_urlReq.data = _loc2_;
			if (_method.toLowerCase() == GET_METHOD && _loc2_ != null) {
				var _loc5_:String = _url;
				if (_loc5_.indexOf("?") == -1) {
					_loc5_ += "?";
				} else {
					_loc7_ = _loc5_.charAt(_loc5_.length - 1);
					if (_loc7_ != "?" && _loc7_ != "&") {
						_loc5_ += "&";
					}
				}
				// PORT-NOTE: for-in 的 _loc2_ 此处只会是对象形态（String 入参在
				// main3 不与 GET 组合；AS3 对 String 的 for-in 产出字符下标，
				// Haxe Reflect.fields 不支持，此边角不复刻）
				for (_loc6_ in Reflect.fields(_loc2_)) {
					if (_loc6_ != "" && _loc6_ != null) {
						_loc5_ += _loc6_ + "=" + Reflect.field(_loc2_, _loc6_) + "&";
					}
				}
				_urlReq.url = _loc5_;
				_urlReq.data = null;
			}
		}
		_urlLoader.load(_urlReq);
	}

	// HttpOperation.as:115-120
	public var method(get, set):String;

	private function get_method():String {
		return _method;
	}

	// HttpOperation.as:122-140
	public function open():Void {
		if (_urlLoader != null) {
			close();
		}
		_urlLoader = new URLLoader();
		_urlLoader.dataFormat = _format;
		_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleError);
		_urlLoader.addEventListener(ErrorEvent.ERROR, handleError);
		_urlLoader.addEventListener(Event.COMPLETE, handleComplete);
		_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
	}

	// HttpOperation.as:142-144（override get url 只调 super）
	private override function get_url():String {
		return super.get_url();
	}

	// HttpOperation.as:141-144
	private function set_method(param1:String):String {
		_method = param1;
		return param1;
	}

	// HttpOperation.as:161-167（indexOf("") 恒为 0，分支永不进，照译）
	private override function set_url(param1:String):String {
		if (param1.indexOf("") == -1) {
			param1 = "" + param1;
		}
		super.set_url(param1);
		return param1;
	}

	// HttpOperation.as:154-167
	public override function close():Void {
		if (_urlLoader != null) {
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
			_urlLoader.removeEventListener(ErrorEvent.ERROR, handleError);
			_urlLoader.removeEventListener(Event.COMPLETE, handleComplete);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
			_urlLoader = null;
		}
	}
}
