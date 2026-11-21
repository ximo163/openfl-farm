package common;

import openfl.display.BitmapData;
import openfl.errors.Error;
import openfl.system.ApplicationDomain;
import shim.As3;

/**
 * common.MaterialLib —— MaterialLib.as（mcloader_v_53/scripts，预加载器与
 * Master2 同应用域共享，Master2 反编译里无此文件）逐句对应，issue #19
 * Master2 闭包顺手译。素材类注册表：各模块加载完往里 push ApplicationDomain，
 * 取类/取实例时顺序搜索。#pasture 片真身上线前 _materialArray 为空，
 * getClass 返回 null、getMaterial 返回 null（调用方各自行判空）。
 */
@:keep
class MaterialLib {
	private static var instance:MaterialLib;

	private var _cachedBitmapData:Dynamic = {};

	private var _materialArray:Array<ApplicationDomain> = [];

	private var _materialUrlArr:Array<String> = [];

	public function new() {
		if (instance != null) {
			throw new Error("实例化单例类出错-MaterialLib");
		}
	}

	// MaterialLib.as:26-33
	public static function getInstance():MaterialLib {
		if (instance == null) {
			instance = new MaterialLib();
		}
		return instance;
	}

	// MaterialLib.as:35-38
	public function getClass(param1:String):Class<Dynamic> {
		return this.searchClass(param1);
	}

	// MaterialLib.as:40-58（AS3 `new cls(w,h) as BitmapData`：非 BitmapData 时
	// as 得 null，用 isOfType 三元等价）
	public function getCachedBitmapData(param1:String, param2:Int, param3:Int):BitmapData {
		var _loc5_:BitmapData = null;
		if (As3.hasProp(this._cachedBitmapData, param1)) {
			return Reflect.field(this._cachedBitmapData, param1);
		}
		var _loc4_:Class<Dynamic> = this.getClass(param1);
		if (_loc4_ != null) {
			var _loc6_:Dynamic = Type.createInstance(_loc4_, [param2, param3]);
			if (Std.isOfType(_loc6_, BitmapData)) {
				_loc5_ = cast _loc6_;
				Reflect.setField(this._cachedBitmapData, param1, _loc5_);
			}
			return _loc5_;
		}
		return null;
	}

	// MaterialLib.as:60-74
	public function hasUrl(param1:String):Bool {
		var _loc2_:Bool = false;
		var _loc3_:Int = 0;
		var _loc4_:Int = this._materialUrlArr.length;
		while (_loc3_ < _loc4_) {
			if (this._materialUrlArr[_loc3_] == param1) {
				return true;
			}
			_loc3_++;
		}
		return false;
	}

	// MaterialLib.as:76-89
	private function searchClass(param1:String):Class<Dynamic> {
		var _loc2_:Int = 0;
		var _loc3_:Int = this._materialArray.length;
		while (_loc2_ < _loc3_) {
			if (this._materialArray[_loc2_].hasDefinition(param1)) {
				return cast(this._materialArray[_loc2_].getDefinition(param1), Class<Dynamic>);
			}
			_loc2_++;
		}
		return null;
	}

	// MaterialLib.as:91-98
	public function push(param1:ApplicationDomain, param2:String = ""):Void {
		if (param2 != "") {
			this._materialUrlArr.push(param2);
		}
		this._materialArray.push(param1);
	}

	// MaterialLib.as:100-108
	public function getMaterial(param1:String):Dynamic {
		var _loc2_:Class<Dynamic> = this.getClass(param1);
		if (_loc2_ != null) {
			return Type.createInstance(_loc2_, []);
		}
		return null;
	}
}
