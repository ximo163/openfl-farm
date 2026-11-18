package com.qzone.qfa.commands;

import com.qzone.qfa.core.Command;
import com.qzone.qfa.debug.Debugger;
import com.qzone.qfa.events.LoaderEvent;
import com.qzone.qfa.managers.LoadManager;
import com.qzone.qfa.managers.ResourceManager;
import openfl.events.IEventDispatcher;
import openfl.system.ApplicationDomain;
import shim.As3;

// CmdLoadFile.as 逐句对应。
class CmdLoadFile extends Command {
	// CmdLoadFile.as:14
	private var _dispatcher:IEventDispatcher;

	// CmdLoadFile.as:16
	private var params:Dynamic;

	// CmdLoadFile.as:18
	private var _loader:LoadManager;

	// CmdLoadFile.as:20
	private var _resManager:ResourceManager;

	// CmdLoadFile.as:22-25
	public function new() {
		super();
	}

	// CmdLoadFile.as:27-45
	private function handleEvents(param1:LoaderEvent):Void {
		if (As3.truthy(this._dispatcher)) {
			this._dispatcher.dispatchEvent(param1);
		}
		switch (param1.type) {
			case LoaderEvent.COMPLETE:
				this._resManager.addResource(param1.item);
			case LoaderEvent.QUEUE_COMPLETE:
				finish(this.params);
			case LoaderEvent.ERROR:
				Debugger.log("[CmdLoadFile]load fail,url:" + param1.item.url);
				error(param1.item);
		}
	}

	// CmdLoadFile.as:47-54
	override public function init():Void {
		super.init();
		this._loader = new LoadManager(ApplicationDomain.currentDomain);
		this._resManager = ResourceManager.gi();
		this._loader.addEventListeners(this.handleEvents);
		this.params = {};
	}

	// CmdLoadFile.as:56-79。for-in 反射遍历动态对象
	override public function execute(param1:Dynamic = null):Void {
		var _loc2_:String = null;
		var _loc3_:Dynamic = null;
		if (param1 == null) {
			param1 = super.body;
		}
		for (_loc2_ in Reflect.fields(param1)) {
			_loc3_ = Reflect.field(param1, _loc2_);
			if (Std.isOfType(_loc3_, String) && _loc2_ != "type" && _loc3_ != "") {
				Debugger.log("[CmdLoadFile]load " + _loc3_);
				this._loader.add(_loc3_, ApplicationDomain.currentDomain);
			}
			Reflect.setField(this.params, _loc2_, _loc3_);
		}
		if (As3.truthy(param1) && As3.truthy(param1.dispatcher)) {
			this._dispatcher = cast(param1.dispatcher, IEventDispatcher);
		}
		this._loader.start();
	}

	// CmdLoadFile.as:81-90
	override public function destroy():Void {
		if (As3.truthy(this._loader)) {
			this._loader.removeEventListeners(this.handleEvents);
			this._loader.removeAll();
			this._loader = null;
		}
		this._dispatcher = null;
	}
}
