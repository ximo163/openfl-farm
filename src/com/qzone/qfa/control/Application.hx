package com.qzone.qfa.control;

import com.qzone.qfa.core.Command;
import com.qzone.qfa.events.CommandEvent;
import com.qzone.qfa.interfaces.IApplication;
import com.qzone.qfa.interfaces.IModel;
import com.qzone.qfa.model.AppData;
import com.qzone.qfa.view.AppStage;
import openfl.display.DisplayObjectContainer;
import haxe.ds.ObjectMap;
import shim.As3;

// Application.as 逐句对应。
// PORT-NOTE: Dictionary（Command 实例键）→ haxe.ds.ObjectMap（对象键按引用
// 相等，等价 Dictionary 默认非弱引用键；Map<Dynamic,Dynamic> 在 eval 上无法
// new，ObjectMap 即对象键字典）。
class Application implements IApplication {
	// Application.as:11
	private var _listeners:ObjectMap<Dynamic, Dynamic>;

	// Application.as:13
	private var _view:AppStage;

	// Application.as:15
	private var _runningCmds:ObjectMap<Dynamic, Dynamic>;

	// Application.as:17
	private var _name:String;

	// Application.as:19
	private var _model:IModel;

	// Application.as:21-34
	public function new(param1:String = "", param2:DisplayObjectContainer = null) {
		if (As3.truthy(param1)) {
			this._name = param1;
		}
		this._view = new AppStage(this);
		this._model = AppData.gi();
		this._runningCmds = new ObjectMap();
		this._listeners = new ObjectMap();
		if (As3.truthy(param2)) {
			param2.addChild(this._view);
		}
	}

	// Application.as:36-49
	public var view(get, set):AppStage;

	private function get_view():AppStage {
		return this._view;
	}

	private function set_view(param1:AppStage):AppStage {
		if (As3.truthy(param1)) {
			if (As3.truthy(this._view) && As3.truthy(this._view.parent)) {
				this._view.parent.addChild(param1);
				this._view.parent.removeChild(this._view);
			}
			this._view = param1;
		}
		return param1;
	}

	// Application.as:51-77（`new param1() as Command` → Type.createInstance + cast）
	public function run(param1:Class<Dynamic>, param2:Dynamic = null, param3:String = "", param4:Dynamic = null, param5:Dynamic = null, param6:Dynamic = null):Void {
		var _loc7_:Command = null;
		if (param1 != null) {
			_loc7_ = cast Type.createInstance(param1, []);
			_loc7_.body = param2;
			this._listeners.set(_loc7_, {});
			if (param5 != null) {
				Reflect.setField(this._listeners.get(_loc7_), "complete", param5);
				_loc7_.addEventListener(CommandEvent.COMPLETE, param5);
			}
			if (param6 != null) {
				Reflect.setField(this._listeners.get(_loc7_), "error", param6);
				_loc7_.addEventListener(CommandEvent.ERROR, param6);
			}
			if (param4 != null && As3.truthy(param3)) {
				this._model.addNotifier(param3, param4);
			}
			_loc7_.addEventListener(CommandEvent.COMPLETE, this.handleCommandEvents);
			_loc7_.addEventListener(CommandEvent.ERROR, this.handleCommandEvents);
			_loc7_.execute();
		}
	}

	// Application.as:79-81
	public var model(get, set):IModel;

	private function set_model(param1:IModel):IModel {
		this._model = param1;
		return param1;
	}

	private function get_model():IModel {
		return this._model;
	}

	// Application.as:83-89
	public var name(get, set):String;

	private function get_name():String {
		return this._name;
	}

	private function set_name(param1:String):String {
		this._name = param1;
		return param1;
	}

	// Application.as:91-92
	public function kill(param1:Class<Dynamic>):Void {}

	// Application.as:104-115
	public function isRunning(param1:Class<Dynamic>):Bool {
		var _loc2_:Dynamic = null;
		for (_loc2_ in this._runningCmds.keys()) {
			if (_loc2_ == param1) {
				return true;
			}
		}
		return false;
	}

	// Application.as:117-140。原版 bug 照抄：error 监听用 CommandEvent.COMPLETE
	// 类型移除（应为 ERROR），导致 error 监听实际留在 Command 上——与原版一致。
	private function handleCommandEvents(param1:CommandEvent):Void {
		var _loc2_:Command = cast param1.target;
		var _loc3_:Dynamic = this._listeners.get(_loc2_);
		if (!As3.truthy(_loc3_)) {
			return;
		}
		if (Reflect.field(_loc3_, "complete") != null) {
			_loc2_.removeEventListener(CommandEvent.COMPLETE, Reflect.field(_loc3_, "complete"));
			Reflect.setField(_loc3_, "complete", null);
		}
		if (Reflect.field(_loc3_, "error") != null) {
			_loc2_.removeEventListener(CommandEvent.COMPLETE, Reflect.field(_loc3_, "error"));
			Reflect.setField(_loc3_, "error", null);
		}
		this._listeners.remove(_loc2_);
	}
}
