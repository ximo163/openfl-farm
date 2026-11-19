package framework.net.core;

import com.qzone.qfa.managers.events.RequestEvent;
import com.qzone.qfa.managers.operation.HttpOperation;
import framework.net.CommandDefs;
import shim.As3.getTimer; // PORT-NOTE: 同 CommonData——eval 上 openfl getTimer 为负
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.TimerEvent;
import openfl.net.URLLoader;
import openfl.utils.Timer;

// framework.net.core.HttpOperationEx —— HttpOperationEx.as 逐句对应。
//（字段/方法名保持原版：测试直排 m_isHandled/m_timerValue/_timer 等私有成员）
class HttpOperationEx extends HttpOperation {
	// HttpOperationEx.as:12
	private static var _timer:Timer;

	// HttpOperationEx.as:14-22
	private var m_isHandled:Bool;
	private var m_requestNum:Int;
	private var m_reload:Bool;
	private var m_timeout:Int;
	private var m_timerValue:Int;

	// HttpOperationEx.as:24-42
	public function new(param1:String = "", param2:Dynamic = null) {
		super(param1, param2);
		m_timerValue = 0;
		m_timeout = 60 * 1000;
		m_requestNum = 0;
		m_reload = false;
		m_isHandled = false;
		if (_timer == null) {
			_timer = new Timer(1000);
			_timer.start();
		}
	}

	// HttpOperationEx.as:44-55
	private override function handleComplete(param1:Event):Void {
		var _loc2_:Dynamic = null;
		if (m_isHandled == false) {
			_loc2_ = Reflect.field(param1.currentTarget, "data");
			dispatchEvent(new RequestEvent(RequestEvent.RESULT, _loc2_));
			m_isHandled = true;
		}
		clearAll();
	}

	// HttpOperationEx.as:57-60
	private override function handleError(param1:Event):Void {
		clearAll();
	}

	// HttpOperationEx.as:62-77
	public override function send(param1:Dynamic = null):Void {
		var arg:Dynamic = param1;
		try {
			super.send(arg);
		} catch (e:openfl.errors.Error) {
			// PORT-NOTE: IOErrorEvent.NETWORK_ERROR 在 openfl 被裁（值 "networkError"
			// 恒定），此事件只直传 ioerrorHandler 读 .text，类型串不可观察
			var ev:IOErrorEvent = new IOErrorEvent("networkError");
			ev.text = e.message;
			ioerrorHandler(ev);
			return;
		}
		m_timerValue = getTimer();
		m_requestNum = 0;
		m_isHandled = false;
		_timer.addEventListener(TimerEvent.TIMER, timerFn, false, 0, true);
	}

	// HttpOperationEx.as:79-103
	public override function open():Void {
		try {
			if (_urlLoader != null) {
				close();
			}
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = _format;
			_urlLoader.addEventListener(Event.COMPLETE, handleComplete, false, 0, true);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError, false, 0, true);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioerrorHandler, false, 0, true);
			_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
		} catch (e:openfl.errors.Error) {
			var ev:IOErrorEvent = new IOErrorEvent("networkError");
			ev.text = e.message;
			ioerrorHandler(ev);
		}
	}

	// HttpOperationEx.as:105-146
	private function timerFn(param1:TimerEvent):Void {
		var _loc2_:Int = getTimer();
		var _loc3_:Dynamic = null;
		if (m_reload == true) {
			if (_loc2_ - m_timerValue > m_timeout && m_requestNum == 0) {
				_urlLoader.load(_urlReq);
				m_timerValue = _loc2_;
				m_requestNum = 1;
			} else if (_loc2_ - m_timerValue > m_timeout && m_requestNum == 1) {
				if (m_isHandled == false) {
					_loc3_ = {
						"errorType": CommandDefs.HTTP_ERR_TIMEOUT,
						"content": ""
					};
					dispatchEvent(new RequestEvent(RequestEvent.FAULT, _loc3_));
					m_isHandled = true;
				}
				clearAll();
			}
		} else if (_loc2_ - m_timerValue > m_timeout) {
			if (m_isHandled == false) {
				_loc3_ = {
					"errorType": CommandDefs.HTTP_ERR_TIMEOUT,
					"content": ""
				};
				dispatchEvent(new RequestEvent(RequestEvent.FAULT, _loc3_));
				m_isHandled = true;
			}
			clearAll();
		}
	}

	// HttpOperationEx.as:148-174
	private function httpStatusHandler(param1:HTTPStatusEvent):Void {
		var _loc2_:Dynamic = null;
		if (param1.status > 400 && param1.status <= 510) {
			if (m_isHandled == false) {
				_loc2_ = {
					"errorType": CommandDefs.HTTP_ERR_HTTPSTATUS,
					"errorContent": param1.status
				};
				dispatchEvent(new RequestEvent(RequestEvent.FAULT, _loc2_));
				m_isHandled = true;
			}
			if (_timer != null) {
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, timerFn);
			}
			if (_urlLoader != null) {
				_urlLoader.removeEventListener(Event.COMPLETE, handleComplete);
				_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
				_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			}
		}
	}

	// HttpOperationEx.as:176-179
	public var reload(get, set):Bool;

	private function get_reload():Bool {
		return m_reload;
	}

	// HttpOperationEx.as:181-183
	private function clearAll():Void {
		close();
		if (_timer != null) {
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, timerFn);
		}
	}

	// HttpOperationEx.as:191-204
	private function ioerrorHandler(param1:IOErrorEvent):Void {
		var _loc2_:Dynamic = null;
		if (m_isHandled == false) {
			_loc2_ = {
				"errorType": CommandDefs.HTTP_ERR_IOERROR,
				"errorContent": param1.text
			};
			dispatchEvent(new RequestEvent(RequestEvent.FAULT, _loc2_));
			m_isHandled = true;
		}
		clearAll();
	}

	// HttpOperationEx.as:207-218
	public override function close():Void {
		if (_urlLoader == null) {
			return;
		}
		_urlLoader.removeEventListener(Event.COMPLETE, handleComplete);
		_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
		_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioerrorHandler);
		_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
		_urlLoader = null;
	}

	// HttpOperationEx.as:219-222
	private function set_reload(param1:Bool):Bool {
		m_reload = param1;
		return param1;
	}
}
