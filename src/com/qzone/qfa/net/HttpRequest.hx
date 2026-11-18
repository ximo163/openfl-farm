package com.qzone.qfa.net;

import com.qzone.qfa.config.QFAError;
import com.qzone.qfa.events.QFAEvent;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.net.URLVariables;
import shim.As3;

// HttpRequest.as 逐句对应。
class HttpRequest extends URLLoader implements IRequest {
	// HttpRequest.as:17
	private var _urlReq:URLRequest;

	// HttpRequest.as:19
	private var _method:String;

	// HttpRequest.as:21
	private var _url:String;

	// HttpRequest.as:23
	private var _format:String;

	// HttpRequest.as:25-36
	public function new(param1:String = "", param2:String = "post") {
		super();
		this._url = param1;
		this._method = param2;
		addEventListener(IOErrorEvent.IO_ERROR, this.handleError);
		addEventListener(ErrorEvent.ERROR, this.handleError);
		addEventListener(Event.COMPLETE, this.handleComplete);
		addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleError);
		addEventListener(HTTPStatusEvent.HTTP_STATUS, this.handleStatus);
	}

	// HttpRequest.as:38-41
	private function handleComplete(param1:Event):Void {
		dispatchEvent(new QFAEvent(QFAEvent.COMPLETE, data));
	}

	// HttpRequest.as:43-55
	private function handleError(param1:Event):Void {
		this.close();
		if (Std.isOfType(param1, SecurityErrorEvent)) {
			dispatchEvent(new QFAEvent(QFAEvent.ERROR, QFAError.ERR_SECURITY));
		} else {
			dispatchEvent(new QFAEvent(QFAEvent.ERROR, QFAError.ERR_IO));
		}
	}

	// HttpRequest.as:57-81
	public function send(param1:Dynamic = null):Void {
		var _loc2_:Dynamic = null;
		var _loc3_:URLVariables = null;
		var _loc4_:String = null;
		this._urlReq = new URLRequest(this._url);
		// PORT-NOTE: AS3 不校验 method 大小写（线路上浏览器统一大写）；lime 的
		// html5 后端按 `== "POST"` 判定，小写 "post"（boot 传的值）会把表单体丢
		// 掉——这里 toUpperCase 对齐原版线上行为，语义不变
		this._urlReq.method = this._method.toUpperCase();
		if (As3.truthy(param1)) {
			// PORT-NOTE: 原版 `param1 is String || param1 is URLVariables`——
			// openfl 的 URLVariables 是 abstract(Dynamic)，运行时无从识别；本
			// swf 的调用方只传 String 或普通对象，String 分支照译、其余全部进
			// URLVariables 拷贝分支
			if (Std.isOfType(param1, String)) {
				_loc2_ = param1;
			} else {
				_loc3_ = new URLVariables();
				for (_loc4_ in Reflect.fields(param1)) {
					Reflect.setField(_loc3_, _loc4_, Reflect.field(param1, _loc4_));
				}
				_loc2_ = _loc3_;
			}
			this._urlReq.data = _loc2_;
		}
		load(this._urlReq);
	}

	// HttpRequest.as:83-91
	override public function close():Void {
		super.close();
		removeEventListener(IOErrorEvent.IO_ERROR, this.handleError);
		removeEventListener(ErrorEvent.ERROR, this.handleError);
		removeEventListener(Event.COMPLETE, this.handleComplete);
		removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleError);
		removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.handleStatus);
	}

	// HttpRequest.as:93-101
	private function handleStatus(param1:HTTPStatusEvent):Void {
		if (param1.status > 400 && param1.status < 510) {
			this.close();
			dispatchEvent(new QFAEvent(QFAEvent.ERROR, QFAError.ERR_HTTP_STATUS));
		}
	}
}
