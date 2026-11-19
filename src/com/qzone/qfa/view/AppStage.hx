package com.qzone.qfa.view;

import com.qzone.qfa.events.CommandEvent;
import com.qzone.qfa.interfaces.IApplication;
import com.qzone.qfa.managers.ResourceManager;
import openfl.display.Sprite;
import openfl.events.Event;
import shim.As3;

// AppStage.as 逐句对应。getter/setter 统一 `var x(get, set)` + get_x/set_x。
class AppStage extends Sprite {
	// AppStage.as:16（protected）
	private var resources:ResourceManager = ResourceManager.gi();

	// AppStage.as:18（protected）
	private var _owner:IApplication;

	// AppStage.as:20-27
	public function new(param1:IApplication = null) {
		super();
		if (param1 != null) {
			this._owner = param1;
		}
		this.addEventListener(Event.ADDED_TO_STAGE, this.__init);
	}

	// AppStage.as:29-38。PORT-NOTE: `param1.body is Object`（AS3 一切非 null 都
	// 是 Object）→ `param1.body != null`；`body.requester = target` → Reflect.setField。
	private function handleRequestCommand(param1:CommandEvent):Void {
		if (param1.command != null) {
			if (param1.body != null) {
				Reflect.setField(param1.body, "requester", param1.target);
			}
			this.owner.run(param1.command, param1.body, param1.dataBindStr, param1.dataBindCall, param1.completeHandler, param1.errorHandler);
		}
	}

	// AppStage.as:40-43
	public var owner(get, set):IApplication;

	private function set_owner(param1:IApplication):IApplication {
		this._owner = param1;
		return param1;
	}

	private function get_owner():IApplication {
		return this._owner;
	}

	// AppStage.as:45-49
	private function removeEventListeners():Void {
		this.removeEventListener(CommandEvent.REQUEST, this.handleRequestCommand);
		stage.removeEventListener(Event.RESIZE, this.handleResized);
	}

	// AppStage.as:51-55（REQUEST 用捕获阶段监听，照抄）
	private function addEventListeners():Void {
		this.addEventListener(CommandEvent.REQUEST, this.handleRequestCommand, true);
		stage.addEventListener(Event.RESIZE, this.handleResized);
	}

	// AppStage.as:57-58
	private function handleResized(param1:Event):Void {}

	// AppStage.as:60-64
	private function __init(param1:Event):Void {
		this.removeEventListener(Event.ADDED_TO_STAGE, this.__init);
		this.addEventListeners();
	}

	// AppStage.as:66-67
	public function init():Void {}

	// AppStage.as:69-70
	private function handleRemoved(param1:Event):Void {}

	// AppStage.as:72-75（原版拼写 destory，照抄）
	public function destory():Void {
		this.removeEventListeners();
		this._owner = null;
	}

	// AppStage.as:77-78
	private function handleAdded(param1:Event):Void {}
}
