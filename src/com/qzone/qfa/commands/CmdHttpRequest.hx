package com.qzone.qfa.commands;

import com.qzone.qfa.core.Command;
import com.qzone.qfa.debug.Debugger;
import com.qzone.qfa.events.QFAEvent;
import com.qzone.qfa.net.HttpRequest;

// CmdHttpRequest.as 逐句对应。
class CmdHttpRequest extends Command {
	// CmdHttpRequest.as:11。Function → Dynamic
	private var _errorHandler:Dynamic;

	// CmdHttpRequest.as:13
	private var _params:Dynamic;

	// CmdHttpRequest.as:15。Function → Dynamic
	private var _completeHandler:Dynamic;

	// CmdHttpRequest.as:17
	private var _req:HttpRequest;

	// CmdHttpRequest.as:19-22
	public function new() {
		super();
	}

	// CmdHttpRequest.as:24-33
	private function handleError(param1:QFAEvent):Void {
		this._req.removeEventListener(QFAEvent.COMPLETE, this.handleEvents);
		this._req.removeEventListener(QFAEvent.ERROR, this.handleError);
		if (this._errorHandler != null) {
			this._errorHandler(param1);
		}
		finish();
	}

	// CmdHttpRequest.as:35-44
	private function handleEvents(param1:QFAEvent):Void {
		this._req.removeEventListener(QFAEvent.COMPLETE, this.handleEvents);
		this._req.removeEventListener(QFAEvent.ERROR, this.handleError);
		if (this._completeHandler != null) {
			this._completeHandler(param1);
		}
		finish();
	}

	// CmdHttpRequest.as:46-61
	override public function execute(param1:Dynamic = null):Void {
		if (param1 == null) {
			param1 = super.body;
		}
		Debugger.log("[QFA]request, url:" + param1.url);
		this._req = new HttpRequest(param1.url, param1.method);
		this._errorHandler = param1.error;
		this._completeHandler = param1.complete;
		this._req.addEventListener(QFAEvent.COMPLETE, this.handleEvents);
		this._req.addEventListener(QFAEvent.ERROR, this.handleError);
		this._params = param1.params;
		this._req.send(this._params);
		// Command._running 对子类可见（Haxe private ≈ AS3 protected），super 直写
		super._running = true;
	}
}
