package com.qzone.qui.makers;

import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import shim.As3;

/**
 * com.qzone.qui.makers.RadioGroup —— RadioGroup.as 逐句对应（issue #18 qui
 * 收尾：makers 片）。单选组：登记一组带 selected/inGroup 属性的目标
 * （RadioButton），CHANGE 时互斥置 selected。
 * PORT-NOTE: `param1["inGroup"] = v`、`_loc2_.selected = false`（for-each 的
 * `*` 变量）按名写 → Reflect.setProperty（Button.selected 是 get/set 属性，
 * js 裸 Dynamic 写只落影子字段，不会走到 set_selected）。
 */
@:keep
class RadioGroup extends EventDispatcher {
	// RadioGroup.as:10-12
	private var _targets:Array<Dynamic>;

	private var _target:DisplayObject;

	// :14-18
	public function new() {
		super();
		this._targets = [];
	}

	// :20-34
	public function getTargetIndex(param1:DisplayObject):Int {
		var _loc3_:DisplayObject = null;
		var _loc2_:Int = 0;
		while (_loc2_ < this._targets.length) {
			_loc3_ = Std.isOfType(this._targets[_loc2_], DisplayObject) ? cast(this._targets[_loc2_], DisplayObject) : null;
			if (_loc3_ == param1) {
				return _loc2_;
			}
			_loc2_++;
		}
		return -1;
	}

	// :36-39
	public function getTargets():Array<Dynamic> {
		return this._targets;
	}

	// :41-45（`param1.currentTarget as DisplayObject`）
	private function _CHANGE(param1:Event):Void {
		this.selectedTarget = Std.isOfType(param1.currentTarget, DisplayObject) ? cast(param1.currentTarget, DisplayObject) : null;
		this.dispatchEvent(param1);
	}

	// :47-55
	public function addTarget(param1:DisplayObject):Void {
		this._targets.push(param1);
		if (As3.hasProp(param1, "inGroup")) {
			Reflect.setProperty(param1, "inGroup", true);
		}
		this.addEvent(param1);
	}

	// :57-69
	public function removeTarget(param1:DisplayObject):Void {
		var _loc2_:Int = this.getTargetIndex(param1);
		if (As3.hasProp(param1, "inGroup")) {
			Reflect.setProperty(param1, "inGroup", false);
		}
		if (_loc2_ != -1) {
			this._targets.splice(_loc2_, 1);
		}
		this.removeEvent(param1);
	}

	// :71-74
	private function removeEvent(param1:DisplayObject):Void {
		param1.removeEventListener(Event.CHANGE, this._CHANGE);
	}

	// :76-87 + :99-102（AS3 public get/set selectedTarget 对）；
	// for-each 的 `*` 元素按名写 selected
	public var selectedTarget(get, set):DisplayObject;

	private function set_selectedTarget(param1:DisplayObject):DisplayObject {
		var _loc2_:Dynamic = null;
		this._target = param1;
		// AS3 for-each：按值遍历
		for (_loc2_ in this._targets) {
			if (param1 != _loc2_) {
				Reflect.setProperty(_loc2_, "selected", false);
			}
		}
		return param1;
	}

	// :89-92
	private function addEvent(param1:DisplayObject):Void {
		param1.addEventListener(Event.CHANGE, this._CHANGE);
	}

	// :94-97
	public function getTargetAt(param1:Int):DisplayObject {
		return this._targets[param1];
	}

	// :99-102
	private function get_selectedTarget():DisplayObject {
		return this._target;
	}
}
