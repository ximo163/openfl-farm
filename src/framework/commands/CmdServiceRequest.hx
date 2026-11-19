package framework.commands;

import com.qzone.qfa.core.Command;
import com.qzone.qfa.debug.Debugger;
import com.qzone.qfa.managers.events.RequestEvent;
import common.Consts;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import framework.net.ServerServices;
import framework.net.core.HttpConnectionPool;
import framework.net.core.HttpOperationEx;
import framework.net.core.RequestChecker;
import framework.net.protocol.Protocol;
import framework.net.vo.ServiceResultVO;
import interfaces.IMsgCenter;

// framework.commands.CmdServiceRequest —— CmdServiceRequest.as 逐句对应。
// PORT-NOTE: `super.body["x"] != undefined` 判键 → Reflect.field(super.body, "x") != null。
class CmdServiceRequest extends Command {
	// CmdServiceRequest.as:21
	private static var CLASS_NAME:String = Consts.CMD_NAME_REQUESTSERVICE;

	// CmdServiceRequest.as:23/:25
	private var m_protocol:Protocol;
	private var m_request:HttpOperationEx;

	// CmdServiceRequest.as:27-32
	public function new() {
		super();
		this.m_protocol = null;
		this.m_request = null;
	}

	// CmdServiceRequest.as:34-74
	private function onRequestSuccess(param1:RequestEvent):Void {
		var _loc3_:IMsgCenter = null;
		if (param1.data == null) {
			Debugger.log("INFO: server return null");
			return;
		}
		RequestChecker.clean(this.m_request.url);
		var _loc2_:ServiceResultVO = null;
		if (this.m_protocol != null) {
			this.m_protocol.importResponseObject(param1.data);
			_loc2_ = ServerServices.getInstance().decodeResult(this.m_protocol);
			if (_loc2_ != null) {
				_loc3_ = cast NetHelper.theApp;
				if (_loc2_.m_result == "validateCode") {
					_loc3_.dispatchEvent(new CommonEvent(Consts.MSG_NEED_VALIDATE_CODE, _loc2_.m_message));
				} else if (_loc2_.m_result == "session") {
					_loc3_.dispatchEvent(new CommonEvent(Consts.MSG_SESSION_TIMEOUT, _loc2_.m_message));
				} else if (_loc2_.m_result != "") {
					error(_loc2_);
				} else {
					finish(_loc2_);
				}
			}
		} else {
			Debugger.log("ERROR: can not decode reponse with an empty protocol.");
		}
		this.destroy();
	}

	// CmdServiceRequest.as:76-98
	override public function execute(param1:Dynamic = null):Void {
		if (this.prepare() == false) {
			Debugger.log("ERROR: init request [" + Reflect.field(super.body, "cmdID") + "] failed.");
			return;
		}
		if (this.m_request == null) {
			Debugger.log("ERROR: request [" + Reflect.field(super.body, "cmdID") + "] is null.");
			return;
		}
		if (super.body != null && Reflect.field(super.body, "cmdID") != null) {
			this.m_protocol = ServerServices.getInstance().encodeRequest(Reflect.field(super.body, "cmdID"), Reflect.field(super.body, "__body"));
			if (this.m_protocol == null) {
				Debugger.log("ERROR: create protocol object [" + Reflect.field(super.body, "cmdID") + "] failed.");
				return;
			}
			this.m_request.send(this.m_protocol.encodeForHttp(this.m_request.method));
		}
	}

	// CmdServiceRequest.as:100-131
	private function prepare():Bool {
		if (this.m_request != null) {
			return true;
		}
		if (super.body == null || Reflect.field(super.body, "cmdID") == null) {
			return false;
		}
		var _loc1_:String = ServerServices.getInstance().getRequestUrl(Reflect.field(super.body, "cmdID"));
		if (this.checkRequest(_loc1_) == false) {
			return false;
		}
		var _loc2_:String = Consts.NET_HTTP_METHOD_POST;
		if (Reflect.field(super.body, "__method") != null) {
			_loc2_ = Reflect.field(super.body, "__method");
		}
		this.m_request = HttpConnectionPool.getInstance().borrow();
		if (this.m_request != null) {
			this.m_request.method = _loc2_;
			this.m_request.url = _loc1_;
			this.m_request.addEventListener(RequestEvent.RESULT, this.onRequestSuccess, false, 0, true);
			this.m_request.addEventListener(RequestEvent.FAULT, this.onRequestFailed, false, 0, true);
			this.m_request.open();
			return true;
		}
		return false;
	}

	// CmdServiceRequest.as:133-143
	override public function destroy():Void {
		if (this.m_request != null) {
			this.m_request.removeEventListener(RequestEvent.RESULT, this.onRequestSuccess);
			this.m_request.removeEventListener(RequestEvent.FAULT, this.onRequestFailed);
			HttpConnectionPool.getInstance().free(this.m_request);
			this.m_request = null;
		}
		super.destroy();
	}

	// CmdServiceRequest.as:145-179
	private function checkRequest(param1:String):Bool {
		var _loc3_:Dynamic = null;
		var _loc4_:IMsgCenter = null;
		if (param1 == null || param1.length == 0) {
			return false;
		}
		var _loc2_:String = param1;
		if (param1.indexOf("cgi_farm_index") != -1) {
			_loc3_ = null;
			if (super.body != null && Reflect.field(super.body, "__body") != null) {
				_loc3_ = Reflect.field(super.body, "__body");
			}
			if (_loc3_ != null && Reflect.field(_loc3_, "ownerId") != null) {
				_loc2_ = _loc2_ + "&" + Reflect.field(_loc3_, "ownerId");
			}
		}
		if (RequestChecker.checkRequest(_loc2_) == false) {
			_loc4_ = cast NetHelper.theApp;
			if (_loc4_ != null) {
				_loc4_.dispatchEvent(new CommonEvent(Consts.MSG_REQUEST_CHECK_ERROR, {
					"cmdID": Reflect.field(super.body, "cmdID"),
					"url": _loc2_
				}));
			}
			return false;
		}
		return true;
	}

	// CmdServiceRequest.as:181-202
	private function onRequestFailed(param1:RequestEvent):Void {
		var _loc2_:Int = 0;
		var _loc3_:ServiceResultVO = null;
		if (param1 == null) {
			return;
		}
		if (Reflect.field(param1.data, "errorType") != null) {
			_loc2_ = Reflect.field(param1.data, "errorType");
			if (_loc2_ == CommandDefs.HTTP_ERR_IOERROR || _loc2_ == CommandDefs.HTTP_ERR_HTTPSTATUS || _loc2_ == CommandDefs.HTTP_ERR_TIMEOUT) {
				RequestChecker.addErrorRequest(this.m_request.url);
				_loc3_ = new ServiceResultVO();
				_loc3_.m_result = Std.string(_loc2_);
				_loc3_.m_extra = {"errorType": Consts.MSG_REQUEST_NET_CLIENT_ERROR};
				error(_loc3_);
			}
		}
		this.destroy();
	}
}
