package com.qzone.qfa.core;

import com.qzone.qfa.events.CommandEvent;
import openfl.events.EventDispatcher;
import shim.As3;

// Command.as 逐句对应。getter/setter 统一用 `var x(get, never)` + `get_x()`
// （本文件内所有属性一致）。
class Command extends EventDispatcher implements ICommand {
	// Command.as:13（protected）。CmdHttpRequest.execute 里有跨包子类直接写
	// `_running = true`（CmdHttpRequest.as:60）；Haxe 的 private 本就对子类
	// 可见，无需额外放开
	private var _running:Bool;

	// Command.as:15
	private var _body:Dynamic;

	// Command.as:17-21
	public function new() {
		super();
		this.init();
	}

	// Command.as:23-26,42-45
	public var body(get, set):Dynamic;

	// Command.as:28-40
	private function error(param1:Dynamic = null):Void {
		this._running = false;
		var _loc2_:CommandEvent = new CommandEvent(CommandEvent.ERROR);
		if (As3.truthy(param1)) {
			_loc2_.result = param1;
		}
		if (this._body != null) {
			_loc2_.body = this._body;
		}
		dispatchEvent(_loc2_);
	}

	private function get_body():Dynamic {
		return this._body;
	}

	private function set_body(param1:Dynamic):Dynamic {
		this._body = param1;
		return param1;
	}

	// Command.as:47-59
	private function finish(param1:Dynamic = null):Void {
		this._running = false;
		var _loc2_:CommandEvent = new CommandEvent(CommandEvent.COMPLETE);
		if (As3.truthy(param1)) {
			_loc2_.result = param1;
		}
		if (this._body != null) {
			_loc2_.body = this._body;
		}
		dispatchEvent(_loc2_);
	}

	// Command.as:61-62
	public function init():Void {
	}

	// Command.as:64-68
	public function execute(param1:Dynamic = null):Void {
		this._running = true;
		this.finish();
	}

	// Command.as:70-73
	public function destroy():Void {
		this._running = false;
	}

	// Command.as:75-78
	public var running(get, never):Bool;

	private function get_running():Bool {
		return this._running;
	}
}
