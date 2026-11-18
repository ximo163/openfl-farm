package com.qzone.qfa.managers;

import com.qzone.qfa.core.Command;
import com.qzone.qfa.events.CommandEvent;
import openfl.utils.Dictionary;
import shim.As3;

// CommandManager.as 逐句对应。
class CommandManager {
	// CommandManager.as:16
	private static var _instance:CommandManager;

	// CommandManager.as:18。键是 Command 实例（对象键），Dictionary<K,V> 的 K
	// 必须是对象类型才落 ObjectMap（write-tests 容器内实测）
	private var _listeners:Dictionary<Command, Dynamic>;

	// CommandManager.as:20-24
	public function new(param1:Enforcer) {
		this._listeners = new Dictionary();
	}

	// CommandManager.as:26-29
	public static function getInstance():CommandManager {
		return _instance = _instance != null ? _instance : new CommandManager(new Enforcer());
	}

	// CommandManager.as:31-60
	public function run(param1:Dynamic, param2:Dynamic = null, param3:Dynamic = null, param4:Dynamic = null,
			param5:Int = 0):Void {
		var _loc6_:Command = null;
		if (As3.truthy(param1)) {
			if (Std.isOfType(param1, Class)) {
				_loc6_ = cast(Type.createInstance(param1, []), Command);
			} else {
				_loc6_ = cast(param1, Command);
			}
			_loc6_.body = param2;
			this._listeners.set(_loc6_, {});
			if (param3 != null) {
				Reflect.setField(this._listeners.get(_loc6_), "complete", param3);
				_loc6_.addEventListener(CommandEvent.COMPLETE, param3, false, param5, true);
			}
			if (param4 != null) {
				Reflect.setField(this._listeners.get(_loc6_), "error", param4);
				_loc6_.addEventListener(CommandEvent.ERROR, param4, false, param5, true);
			}
		}
		_loc6_.addEventListener(CommandEvent.COMPLETE, this.handleCommandEvents, false, param5, true);
		_loc6_.addEventListener(CommandEvent.ERROR, this.handleCommandEvents, false, param5, true);
		_loc6_.execute();
	}

	// CommandManager.as:62-81。removeEventListener(COMPLETE, error) 是原版笔误
	// （错卸 COMPLETE 监听），照抄
	private function handleCommandEvents(param1:CommandEvent):Void {
		var _loc2_:Command = cast(param1.target, Command);
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

// CommandManager.as:83-90：AS3 文件级 internal 类（每个 .as 文件一个同名
// Enforcer），Haxe 落为各文件内的模块私有类
private class Enforcer {
	public function new() {
	}
}
