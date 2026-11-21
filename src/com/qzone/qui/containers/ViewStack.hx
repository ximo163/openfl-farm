package com.qzone.qui.containers;

import openfl.display.DisplayObject;
import openfl.utils.Dictionary;

/**
 * com.qzone.qui.containers.ViewStack —— ViewStack.as 逐句对应（issue #18
 * qui 收尾：容器片）。视图栈：子视图索引切换，未选中即从显示列表摘除。
 * _childObject 是按 DisplayObject 对象键的 Dictionary（对象身份键，非名）。
 */
class ViewStack extends Container {
	// ViewStack.as:11-18
	private var _currentChild:DisplayObject;

	private var _childObject:Dictionary<DisplayObject, Bool>;

	private var _currentIndex:Int = -1;

	private var _childArray:Array<Dynamic> = [];

	// :20-24
	public function new() {
		super();
		this._childObject = new Dictionary<DisplayObject, Bool>();
	}

	// :26-39
	public function addView(param1:DisplayObject):DisplayObject {
		if (this._childObject.get(param1) != true) {
			this._childArray.push(param1);
			this._childObject.set(param1, true);
			if (this._childArray.length == 1) {
				this._currentChild = this.content.addChild(param1);
				this._currentIndex = 0;
			}
		}
		return param1;
	}

	// :41-59
	public function removeView(param1:DisplayObject):Bool {
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		if (this.content.contains(param1)) {
			_loc2_ = this._childArray.length;
			_loc3_ = 0;
			while (_loc3_ < _loc2_) {
				if (this._childArray[_loc3_] == param1) {
					this._childArray.splice(_loc3_, 1);
					this._childObject.remove(param1);
					this.content.removeChild(param1);
					return true;
				}
				_loc3_++;
			}
		}
		return false;
	}

	// :61-65 + :101-103（AS3 public get/set selectedItem 对）
	public var selectedItem(get, set):DisplayObject;

	private function set_selectedItem(param1:DisplayObject):DisplayObject {
		this.unselect(this._currentChild);
		this.select(param1);
		return param1;
	}

	// :67-71（AS3 Boolean(x) 显式取真）
	private function unselect(param1:DisplayObject):Void {
		if (param1 != null && param1.parent != null) {
			param1.parent.removeChild(param1);
		}
	}

	// :73-79（AS3 public set selectedIndex；getter :105-107）
	public var selectedIndex(get, set):Int;

	private function set_selectedIndex(param1:Int):Int {
		this.unselect(this._currentChild);
		this._currentChild = this._childArray[param1];
		this.select(this._currentChild);
		this._currentIndex = param1;
		return param1;
	}

	// :81-87
	private function select(param1:DisplayObject):Void {
		if (param1 != null) {
			this.content.addChild(param1);
			this._currentChild = param1;
		}
	}

	// :101-103
	private function get_selectedItem():DisplayObject {
		return this._currentChild;
	}

	// :105-107
	private function get_selectedIndex():Int {
		return this._currentIndex;
	}
}
