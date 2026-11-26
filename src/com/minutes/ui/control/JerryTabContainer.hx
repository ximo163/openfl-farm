package com.minutes.ui.control;

import com.minutes.ui.core.LipiUIComponent;
import openfl.display.DisplayObject;

/**
 * com.minutes.ui.control.JerryTabContainer —— JerryTabContainer.as 逐句
 * 对应（issue #86 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/JerryTabContainer.as。
 *
 * PORT-NOTE（`this.contains/removeChild/addChild` 直调，:34/:36/:51）：
 * JerryTabContainer 不重定向显示列表接口（不像 LipiPanel/LipiContainer），
 * 子件直接挂自身——`this._list` 元素经 addItem 入列但**不入显示列表**，
 * 显示由 refurbishDisplay 在 selectedIndex 变更时挂当前件。原版语义逐字。
 */
@:keep
class JerryTabContainer extends LipiUIComponent {
	// JerryTabContainer.as:9-13
	private var indexChange:Bool = false;
	private var _index:Int = 0;
	private var _list:Array<Dynamic> = [];

	// :15-19
	public function new() {
		super();
		this.bgAlpha = 0;
	}

	// :21-28
	public function getDisplayObject(param1:Int):DisplayObject {
		if (param1 >= 0 && this._list.length > 0 && param1 < this._list.length) {
			return this._list[param1];
		}
		return null;
	}

	// :30-42
	public var selectedIndex(get, set):Int;

	private function set_selectedIndex(param1:Int):Int {
		if (param1 >= 0 && this._list.length > 0 && param1 < this._list.length) {
			if (this.contains(this._list[this._index])) {
				this.removeChild(this._list[this._index]);
			}
			this._index = param1;
			this.indexChange = true;
			invalidateDisplayList();
		}
		return param1;
	}

	// :44-47
	public function addItem(param1:DisplayObject):Void {
		this._list.push(param1);
	}

	// :49-52
	private function refurbishDisplay():Void {
		this.addChild(this._list[this.selectedIndex]);
	}

	// :54-57
	private function get_selectedIndex():Int {
		return this._index;
	}

	// :59-67
	private override function updateDisplayList(param1:Float, param2:Float):Void {
		super.updateDisplayList(param1, param2);
		if (this.indexChange) {
			this.refurbishDisplay();
			this.indexChange = false;
		}
	}
}
