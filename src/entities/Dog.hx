package entities;

import common.misc.Utils;

// entities.Dog —— Dog.as 逐句对应（闭包规则：32 loc ≤ 100，随翻译整体翻）。
@:final
class Dog {
	// Dog.as:7-11 字段（int 默认 0）
	public var _isHungry:Int = 0; // AS3 int 默认值
	public var _dogId:Int = 0; // AS3 int 默认值
	public var _validTime:Int = 0; // AS3 int 默认值

	// Dog.as:13-17
	public function new(param1:Dynamic) {
		importObject(param1);
	}

	// Dog.as:19-29
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this._dogId = Std.int(Utils.getIntAttribute(param1, "dogId"));
		this._isHungry = Std.int(Utils.getIntAttribute(param1, "isHungry"));
		this._validTime = Std.int(Utils.getIntAttribute(param1, "validTime"));
	}
}
