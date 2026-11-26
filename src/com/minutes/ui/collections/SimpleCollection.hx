package com.minutes.ui.collections;

import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
 * com.minutes.ui.collections.SimpleCollection —— SimpleCollection.as 逐句
 * 对应（issue #86 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/collections/SimpleCollection.as。
 *
 * PORT-NOTE（AS3 override width/height → Haxe）：Sprite 的同名属性不允许
 * 子类重声明，只重载访问器——LipiUIComponent.hx / qui 控件同款形态。
 * _width/_height 是类的私有存储字段，与 Sprite 测量通道脱钩（原版如此）。
 */
@:keep
class SimpleCollection extends Sprite {
	// SimpleCollection.as:9
	private var _bg:DisplayObject;

	// :11-13（AS3 Number 字段初值 100）
	private var _width:Float = 100;

	// :12
	private var _height:Float = 100;

	// :15-18
	public function new() {
		super();
	}

	// :20-23
	public var bg(get, set):DisplayObject;

	private function get_bg():DisplayObject {
		return this._bg;
	}

	// :30-47（首装/换装两分支：换装先 removeChild 旧件再写透尺寸——
	// 两分支后段逐字相同，照抄不合并不重排）
	private function set_bg(param1:DisplayObject):DisplayObject {
		if (this._bg == null) {
			this._bg = param1;
			this._bg.width = this.width;
			this._bg.height = this.height;
			addChild(this._bg);
		} else {
			removeChild(this._bg);
			this._bg = param1;
			this._bg.width = this.width;
			this._bg.height = this.height;
			addChild(this._bg);
		}
		return param1;
	}

	// :25-27（override 等价面，见类头 PORT-NOTE）
	private override function get_width():Float {
		return this._width;
	}

	// :64-72（两维都写透 bg：先 width 后 height）
	private override function set_width(param1:Float):Float {
		this._width = param1;
		if (this._bg != null) {
			this._bg.width = this.width;
			this._bg.height = this.height;
		}
		return param1;
	}

	// :59-63
	private override function get_height():Float {
		return this._height;
	}

	// :49-57（两维都写透 bg：先 width 后 height——与 set width 同序）
	private override function set_height(param1:Float):Float {
		this._height = param1;
		if (this._bg != null) {
			this._bg.width = this.width;
			this._bg.height = this.height;
		}
		return param1;
	}
}
