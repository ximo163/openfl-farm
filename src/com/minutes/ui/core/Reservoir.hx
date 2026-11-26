package com.minutes.ui.core;

/**
 * com.minutes.ui.core.Reservoir —— Reservoir.as 逐句对应（issue #86 牧场
 * 库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/core/Reservoir.as。
 *
 * PORT-NOTE: `new this.ClassObject()`（Reservoir.as:48）是 AS3 的 Class
 * 实例化——Haxe 等价是 Type.createInstance（getDefinitionByName 同款映射，
 * 见 CLAUDE.md 语言差异清单）。
 */
@:keep
class Reservoir {
	// Reservoir.as:5-9
	private var useArray:Array<Dynamic>;
	private var ClassObject:Class<Dynamic>;
	private var unusedArray:Array<Dynamic>;

	// :11-17
	public function new(param1:Class<Dynamic>) {
		this.ClassObject = param1;
		this.useArray = [];
		this.unusedArray = [];
	}

	// :19-31
	public function delInstance(param1:Dynamic):Void {
		var _loc2_:Int = 0;
		while (_loc2_ < this.useArray.length) {
			if (this.useArray[_loc2_] == param1) {
				this.unusedArray.push(this.useArray.splice(_loc2_, 1)[0]);
				break;
			}
			_loc2_++;
		}
	}

	// :33-48（ClassObject 实例化见类头 PORT-NOTE）
	public function getInstance():Dynamic {
		var _loc1_:Dynamic = null;
		if (this.unusedArray.length > 0) {
			_loc1_ = this.unusedArray.pop();
		} else {
			_loc1_ = Type.createInstance(this.ClassObject, []);
		}
		this.useArray.push(_loc1_);
		return _loc1_;
	}
}
