package com.qzone.qui.containers;

import openfl.display.DisplayObject;
import openfl.utils.Dictionary;
import shim.As3;

/**
 * com.qzone.qui.containers.ViewStack —— ViewStack.as 逐句对应（issue #18
 * qui 收尾：容器片）。视图栈：子视图索引切换，未选中即从显示列表摘除。
 * PORT-NOTE: _childObject 原版是 AS3 Dictionary 混键种一表两用——addView
 * 的读门（ViewStack.as:25）按 **name 字符串键**读、写入（:28）与 removeView
 * 的 delete（:52）按**对象键**。字符串键从未写入 → 读门恒过，原版去重从未
 * 生效（同视图重复 addView 会重复入列），照译死门不修（偏差只进
 * spec/deviations.json，人维护）。Haxe 侧用 Dictionary<{}, Bool>
 * （对象身份键）同存两种键形，字符串读恒 miss → null，与 AS3 段一致。
 */
class ViewStack extends Container {
	// ViewStack.as:11-18
	private var _currentChild:DisplayObject;

	private var _childObject:Dictionary<{}, Bool>;

	private var _currentIndex:Int = -1;

	private var _childArray:Array<Dynamic> = [];

	// :20-24
	public function new() {
		super();
		this._childObject = new Dictionary<{}, Bool>();
	}

	// :26-39
	public function addView(param1:DisplayObject):DisplayObject {
		// `!this._childObject[param1.name]`：name 为 null 时 AS3 读
		// dict[null] 得 undefined 同过门，短路先判，防静态目标
		// ObjectMap.get(null) 未定义行为
		if (param1.name == null || !As3.truthy(this._childObject.get(param1.name))) {
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
