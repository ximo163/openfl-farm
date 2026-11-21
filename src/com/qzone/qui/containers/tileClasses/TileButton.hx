package com.qzone.qui.containers.tileClasses;

import com.qzone.qui.controls.Button;

/**
 * com.qzone.qui.containers.tileClasses.TileButton —— TileButton.as 逐句对应
 * （issue #18 qui 收尾：容器片）。TileList 的默认瓦片渲染器。
 * PORT-NOTE: `this._data.toString()` —— AS3 Object.toString 匿名对象是
 * "[object Object]"、字符串原样；Haxe Std.string 对匿名结构输出字段展开，
 * 数据项按原用法是字符串标签（WindowTabBarMaker/商店列表），字符串路径
 * 等价，匿名对象路径输出形态与原版不同（无渲染面差异）。
 */
class TileButton extends Button {
	// TileButton.as:10
	public var labelField:String = "label";

	private var _data:Dynamic;

	// :12-16
	public function new() {
		super();
		this._width = 44;
		this._resized = true;
	}

	// :18-30（AS3 public get/set data 对）
	public var data(get, set):Dynamic;

	private function set_data(param1:Dynamic):Dynamic {
		this._data = param1;
		if (Reflect.hasField(this._data, this.labelField)) {
			this.text = Reflect.field(this._data, this.labelField);
		} else {
			this.text = Std.string(this._data);
		}
		this.toolTip = this.text;
		return param1;
	}

	private function get_data():Dynamic {
		return this._data;
	}
}
