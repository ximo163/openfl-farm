package entities;

import openfl.errors.Error;

// PoolFish.as —— issue #7 闭包 stub；#29 write-tests 阶段扩出被测面：
// 字段声明照抄 PoolFish.as:12-30，ctor/方法/getter 签名就位、函数体一律
// throw 未实现（本阶段不做任何实现，implement 阶段整类真身化替换）。
// legacy/decompiled/main3_v_221/scripts/entities/PoolFish.as
@:keep
class PoolFish {
	// PoolFish.as:12
	private var _st:Dynamic;

	// PoolFish.as:14
	public var _thief:Array<Dynamic>;

	// PoolFish.as:16
	public var _plantTime:Int;

	// PoolFish.as:18
	public var _output:Int;

	// PoolFish.as:20
	public var _left:Int;

	// PoolFish.as:22
	public var _type:Int;

	// PoolFish.as:24
	public var _nextStepTime:Float;

	// PoolFish.as:26
	private var _cycles:Array<Dynamic>;

	// PoolFish.as:28
	public var _fertilize:Bool;

	// PoolFish.as:30
	public var _id:Int;

	// PoolFish.as:32-40
	public function new(param1:Dynamic) {
		throw new Error("not implemented");
	}

	// PoolFish.as:42-60
	public function calcNextStepTime():Void {
		throw new Error("not implemented");
	}

	// PoolFish.as:62-93
	public function importObject(param1:Dynamic):Void {
		throw new Error("not implemented");
	}

	// PoolFish.as:96-99
	public var canHarvest(get, never):Bool;

	private function get_canHarvest():Bool {
		throw new Error("not implemented");
	}

	// PoolFish.as:101-132
	public var level(get, never):Int;

	private function get_level():Int {
		throw new Error("not implemented");
	}

	// PoolFish.as:134-161
	public var cycles(get, never):Array<Dynamic>;

	private function get_cycles():Array<Dynamic> {
		throw new Error("not implemented");
	}

	// PoolFish.as:168-175
	public var name(get, never):String;

	private function get_name():String {
		throw new Error("not implemented");
	}

	// PoolFish.as:177-194
	public var min(get, never):Int;

	private function get_min():Int {
		throw new Error("not implemented");
	}

	// PoolFish.as:196-217
	public function refreshStatus(param1:Dynamic):Void {
		throw new Error("not implemented");
	}

	// PoolFish.as:219-259
	public var leftTime(get, never):Array<Dynamic>;

	private function get_leftTime():Array<Dynamic> {
		throw new Error("not implemented");
	}

	// PoolFish.as:261-268
	public var poolSize(get, never):Int;

	private function get_poolSize():Int {
		throw new Error("not implemented");
	}
}
