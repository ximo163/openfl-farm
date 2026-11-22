package module.water;

import common.cache.ObjectPool;
import openfl.system.ApplicationDomain;
import openfl.utils.Dictionary;

/**
 * module.water.FishMCPoolObjectMgr —— FishMCPoolObjectMgr.as 逐句对应
 * （issue #37 功能 swf 翻译：鱼塘 pool_v_13 鱼动画符号池）。_linkageClasses
 * 记「符号名→Class」，_map 记「Class→ObjectPool(可增长)」；getObject 首借
 * allocate(2)，returnObject 按运行时类型（`is Class`）找池归还，gc 全池
 * purge。ApplicationDomain.hasDefinition/getDefinition 在 openfl 是
 * Type.resolveClass——鱼符号（FS_xx_x_x 等）需先以同名 Haxe 类注册才会命中
 * （见 FishAnimationMgr 头注释的已知缺口说明）。
 */
class FishMCPoolObjectMgr {
	// FishMCPoolObjectMgr.as:10
	private static final POOL_GROW_SIZE:UInt = 2;

	// FishMCPoolObjectMgr.as:12
	private var _linkageClasses:Dictionary<String, Class<Dynamic>>;

	// FishMCPoolObjectMgr.as:14
	private var _map:Dictionary<Class<Dynamic>, ObjectPool>;

	// FishMCPoolObjectMgr.as:16-21
	public function new() {
		this._linkageClasses = new Dictionary();
		this._map = new Dictionary();
	}

	// FishMCPoolObjectMgr.as:23-42。for-in 遍历 Dictionary = 键遍历
	public function destroy():Void {
		var _loc3_:String = null;
		var _loc1_:ObjectPool = null;
		var _loc2_:Class<Dynamic> = null;
		for (_loc3_ in this._linkageClasses) {
			_loc2_ = this._linkageClasses.get(_loc3_);
			this._linkageClasses.remove(_loc3_);
			if (_loc2_ != null) {
				_loc1_ = this._map.get(_loc2_);
				if (_loc1_ != null) {
					_loc1_.destroy();
				}
				this._map.remove(_loc2_);
			}
		}
	}

	// FishMCPoolObjectMgr.as:44-72
	public function register(param1:String):ObjectPool {
		var _loc3_:ObjectPool = null;
		if (param1 == null || param1 == "") {
			return null;
		}
		if (ApplicationDomain.currentDomain.hasDefinition(param1) == false) {
			return null;
		}
		var _loc2_:Class<Dynamic> = this._linkageClasses.get(param1);
		if (_loc2_ != null) {
			if (this._map.get(_loc2_) != null) {
				return this._map.get(_loc2_);
			}
		}
		_loc2_ = ApplicationDomain.currentDomain.getDefinition(param1);
		if (_loc2_ != null) {
			_loc3_ = new ObjectPool(true);
			this._linkageClasses.set(param1, _loc2_);
			this._map.set(_loc2_, _loc3_);
			return _loc3_;
		}
		return null;
	}

	// FishMCPoolObjectMgr.as:74-95
	public function getObject(param1:String):Dynamic {
		if (param1 == null || param1 == "") {
			return null;
		}
		var _loc2_:Class<Dynamic> = this._linkageClasses.get(param1);
		if (_loc2_ == null) {
			return null;
		}
		var _loc3_:ObjectPool = this._map.get(_loc2_);
		if (_loc3_ == null) {
			return null;
		}
		if (_loc3_.size == 0) {
			_loc3_.allocate(POOL_GROW_SIZE, _loc2_);
		}
		return _loc3_.borrow();
	}

	// FishMCPoolObjectMgr.as:97-118。`param1 is _loc3_` → Std.isOfType
	public function returnObject(param1:Dynamic):Void {
		var _loc4_:String = null;
		var _loc2_:ObjectPool = null;
		var _loc3_:Class<Dynamic> = null;
		for (_loc4_ in this._linkageClasses) {
			_loc3_ = this._linkageClasses.get(_loc4_);
			if (_loc3_ != null) {
				if (Std.isOfType(param1, _loc3_)) {
					_loc2_ = this._map.get(_loc3_);
					if (_loc2_ != null) {
						_loc2_.restore(param1);
					}
					break;
				}
			}
		}
	}

	// FishMCPoolObjectMgr.as:120-137
	public function gc():Void {
		var _loc3_:String = null;
		var _loc1_:ObjectPool = null;
		var _loc2_:Class<Dynamic> = null;
		for (_loc3_ in this._linkageClasses) {
			_loc2_ = this._linkageClasses.get(_loc3_);
			if (_loc2_ != null) {
				_loc1_ = this._map.get(_loc2_);
				if (_loc1_ != null) {
					_loc1_.purge();
				}
			}
		}
	}

	// FishMCPoolObjectMgr.as:139-159。PORT-NOTE: 原版 :153 用字符串 param1
	// 当键读以 Class 为键的 _map——AS3 严格相等下永不命中（恒 undefined，
	// 返回值恒 null），删除两张表后返回 null；静态目标 ObjectMap 不收
	// String 键，按结果等价译作 null，行为不变
	public function unregister(param1:String):ObjectPool {
		var _loc3_:ObjectPool = null;
		if (param1 == null || param1 == "") {
			return null;
		}
		if (ApplicationDomain.currentDomain.hasDefinition(param1) == false) {
			return null;
		}
		var _loc2_:Class<Dynamic> = this._linkageClasses.get(param1);
		if (_loc2_ != null) {
			_loc3_ = null;
			this._linkageClasses.remove(param1);
			this._map.remove(_loc2_);
			return _loc3_;
		}
		return null;
	}

	// FishMCPoolObjectMgr.as:161-172
	public function contains(param1:String):Bool {
		if (param1 == null || param1 == "") {
			return false;
		}
		if (this._linkageClasses.get(param1) == null) {
			return false;
		}
		return true;
	}
}
