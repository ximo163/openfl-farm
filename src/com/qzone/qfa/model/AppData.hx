package com.qzone.qfa.model;

import com.qzone.qfa.interfaces.IModel;
import com.qzone.qfa.interfaces.INotifier;
import shim.As3;

// AppData.as 逐句对应。
// PORT-NOTE: Dictionary（String 键）→ Map<String,Dynamic>；`x is Function` →
// Reflect.isFunction；toString 里对 dataList 值的 for-in → Reflect.fields（仅
// 调试输出，Array 值在 AS3 会枚举出索引，这里不会——无行为影响）。
class AppData implements IModel implements INotifier {
	// AppData.as:8
	private static var _instance:AppData;

	// AppData.as:12
	private var dataList:Map<String, Dynamic>;

	// AppData.as:14
	private var notifierMap:Map<String, Array<Dynamic>>;

	// AppData.as:16-20（SingletonEnforcer 是同文件包外可见性挡板，见文件尾）
	public function new(param1:SingletonEnforcer) {
		this.dataList = new Map();
		this.notifierMap = new Map();
	}

	// AppData.as:22-25
	public static function gi():AppData {
		return _instance = _instance != null ? _instance : new AppData(new SingletonEnforcer());
	}

	// AppData.as:27-30
	public static var instance(get, never):AppData;

	private static function get_instance():AppData {
		return gi();
	}

	// AppData.as:32-34
	public function getData(param1:String):Dynamic {
		return this.dataList.get(param1);
	}

	// AppData.as:36-40
	public function flush():Void {
		this.dataList = new Map();
		this.notifierMap = new Map();
	}

	// AppData.as:42-67
	public function removeNotifier(param1:String, param2:Dynamic):Void {
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		if (!this.hasData(param1)) {
			return;
		}
		var _loc3_:Array<Dynamic> = this.notifierMap.get(param1);
		if (As3.truthy(_loc3_)) {
			_loc5_ = 0;
			_loc4_ = _loc3_.length;
			while (_loc5_ < _loc4_) {
				if (_loc3_[_loc5_] == param2) {
					_loc3_.splice(_loc5_, 1);
					break;
				}
				_loc5_++;
			}
		}
	}

	// AppData.as:69-71
	public function hasData(param1:String):Bool {
		return this.dataList.exists(param1);
	}

	// AppData.as:73-82
	public function setData(param1:String, param2:Dynamic):Bool {
		if (As3.truthy(param1)) {
			this.dataList.set(param1, param2);
			this.notify(param1);
			return true;
		}
		return false;
	}

	// AppData.as:84-104
	public function notify(param1:String):Void {
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		if (!this.hasData(param1)) {
			return;
		}
		var _loc2_:Array<Dynamic> = this.notifierMap.get(param1);
		if (As3.truthy(_loc2_)) {
			_loc4_ = 0;
			_loc3_ = _loc2_.length;
			while (_loc4_ < _loc3_) {
				if (Reflect.isFunction(_loc2_[_loc4_])) {
					var _loc6_:Dynamic = _loc2_[_loc4_];
					_loc6_(this.dataList.get(param1));
				}
				_loc4_++;
			}
		}
	}

	// AppData.as:106-119
	public function toString():String {
		var _loc2_:String = null;
		var _loc3_:String = null;
		var _loc1_:String = "";
		for (_loc2_ in this.dataList.keys()) {
			_loc1_ += _loc2_ + ":" + this.dataList.get(_loc2_) + "\n";
			for (_loc3_ in Reflect.fields(this.dataList.get(_loc2_))) {
				_loc1_ += "|-" + _loc3_ + ":" + Reflect.field(this.dataList.get(_loc2_), _loc3_) + "\n";
			}
		}
		return _loc1_;
	}

	// AppData.as:121-141
	public function addNotifier(param1:String, param2:Dynamic):Void {
		if (!As3.truthy(this.notifierMap.get(param1))) {
			this.notifierMap.set(param1, []);
		}
		var _loc6_:Dynamic = param2;
		_loc6_(this.dataList.get(param1));
		var _loc3_:Array<Dynamic> = this.notifierMap.get(param1);
		var _loc4_:Int = 0;
		var _loc5_:Int = _loc3_.length;
		while (_loc4_ < _loc5_) {
			if (_loc3_[_loc4_] == param2) {
				return;
			}
			_loc4_++;
		}
		_loc3_.push(param2);
	}
}

// AppData.as:144-151（文件级包外类，挡住直接 new AppData）
private class SingletonEnforcer {
	public function new() {}
}
