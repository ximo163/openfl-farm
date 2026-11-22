package common.cache;

import openfl.errors.Error;

/**
 * common.cache.ObjectPool —— ObjectPool.as 逐句对应（issue #37 功能 swf 翻译：
 * 鱼塘 pool_v_13；pool_v_13 特有的公共库本地副本，main3/Master2 均无
 * common.cache 包）。环形 ObjNode 链通用对象池：allocate 预建、borrow/restore
 * 借还、purge 收缩（idle 时裁回 initSize、有借出时只留借出节点重建环并补足
 * initSize）、grow=true 借满翻一档 initSize。供 FishMCPoolObjectMgr 回收鱼
 * MovieClip。
 */
class ObjectPool {
	// ObjectPool.as:6
	private var _factory:IObjectPoolFactory;

	// ObjectPool.as:8
	private var _usageCount:Int = 0;

	// ObjectPool.as:10
	private var _initSize:Int = 0;

	// ObjectPool.as:12
	private var _allocNode:ObjNode;

	// ObjectPool.as:14
	private var _tail:ObjNode;

	// ObjectPool.as:16
	private var _currSize:Int = 0;

	// ObjectPool.as:18
	private var _emptyNode:ObjNode;

	// ObjectPool.as:20（缺省 true）
	private var _grow:Bool = true;

	// ObjectPool.as:22
	private var _head:ObjNode;

	// ObjectPool.as:24-28
	public function new(param1:Bool = false) {
		this._grow = param1;
	}

	// ObjectPool.as:30-33
	public var size(get, never):Int;

	private function get_size():Int {
		return this._currSize;
	}

	// ObjectPool.as:35-113
	public function purge():Void {
		var _loc1_:Int = 0;
		var _loc2_:ObjNode = null;
		var _loc3_:Array<Dynamic> = null;
		var _loc4_:ObjNode = null;
		var _loc5_:ObjNode = null;
		var _loc6_:Int = 0;
		if (this._usageCount == 0) {
			if (this._currSize == this._initSize) {
				return;
			}
			if (this._currSize > this._initSize) {
				_loc1_ = 0;
				_loc2_ = this._head;
				while (++_loc1_ < this._initSize) {
					_loc2_ = _loc2_.next;
				}
				this._allocNode = this._emptyNode = this._head;
				this._tail = _loc2_;
				this._tail.next = this._head;
				this._currSize = this._initSize;
				return;
			}
		} else {
			// 有借出：沿环收集 data 非空的（=借出）节点，重链成环后补足到
			// initSize。`!_loc2_.data` 是 AS3 真值转换 → != null
			_loc3_ = [];
			_loc1_ = 0;
			_loc2_ = this._head;
			while (_loc2_ != null) {
				if (_loc2_.data != null) {
					_loc3_[_loc1_++] = _loc2_;
				}
				if (_loc2_ == this._tail) {
					break;
				}
				_loc2_ = _loc2_.next;
			}
			this._currSize = _loc3_.length;
			this._usageCount = this._currSize;
			this._head = this._tail = _loc3_[0];
			_loc1_ = 1;
			while (_loc1_ < this._currSize) {
				_loc2_ = _loc3_[_loc1_];
				_loc2_.next = this._head;
				this._head = _loc2_;
				_loc1_++;
			}
			this._allocNode = this._emptyNode = this._head;
			this._tail.next = this._head;
			if (this._usageCount < this._initSize) {
				this._currSize = this._initSize;
				_loc4_ = this._tail;
				_loc5_ = this._tail;
				_loc6_ = this._initSize - this._usageCount;
				_loc1_ = 0;
				while (_loc1_ < _loc6_) {
					_loc2_ = new ObjNode();
					_loc2_.data = this.createObject();
					_loc5_.next = _loc2_;
					_loc5_ = _loc2_;
					_loc1_++;
				}
				this._tail = _loc5_;
				this._tail.next = this._emptyNode = this._head;
				this._allocNode = _loc4_.next;
			}
		}
	}

	// ObjectPool.as:115-118
	public function setFactory(param1:IObjectPoolFactory):Void {
		this._factory = param1;
	}

	// ObjectPool.as:120-128
	public function restore(param1:Dynamic):Void {
		if (this._usageCount > 0) {
			--this._usageCount;
			this._emptyNode.data = param1;
			this._emptyNode = this._emptyNode.next;
		}
	}

	// ObjectPool.as:130-133
	public var wasteCount(get, never):Int;

	private function get_wasteCount():Int {
		return this._currSize - this._usageCount;
	}

	// ObjectPool.as:135-142
	private function createObject():Dynamic {
		if (this._factory == null) {
			return null;
		}
		return this._factory.create();
	}

	// ObjectPool.as:144-147
	public var usageCount(get, never):Int;

	private function get_usageCount():Int {
		return this._usageCount;
	}

	// ObjectPool.as:149-183
	public function borrow():Dynamic {
		var _loc2_:ObjNode = null;
		var _loc3_:ObjNode = null;
		var _loc4_:ObjNode = null;
		var _loc5_:Int = 0;
		if (this._usageCount == this._currSize) {
			if (!(this._grow == true && this._initSize > 0)) {
				throw new Error("object pool exhausted.");
			}
			this._currSize += this._initSize;
			_loc2_ = this._tail;
			_loc3_ = this._tail;
			_loc5_ = 0;
			while (_loc5_ < this._initSize) {
				_loc4_ = new ObjNode();
				_loc4_.data = this.createObject();
				_loc3_.next = _loc4_;
				_loc3_ = _loc4_;
				_loc5_++;
			}
			this._tail = _loc3_;
			this._tail.next = this._head;
			this._emptyNode = this._head;
			this._allocNode = _loc2_.next;
		}
		var _loc1_:Dynamic = this._allocNode.data;
		this._allocNode.data = null;
		this._allocNode = this._allocNode.next;
		++this._usageCount;
		return _loc1_;
	}

	// ObjectPool.as:185-197（方法名原版拼写如此）。AS3 的
	// `data[param1].apply(data, param2)` → Reflect.callMethod
	public function initialze(param1:String, param2:Array<Dynamic>):Void {
		var _loc3_:ObjNode = this._head;
		while (_loc3_ != null) {
			Reflect.callMethod(_loc3_.data, Reflect.field(_loc3_.data, param1), param2);
			if (_loc3_ == this._tail) {
				break;
			}
			_loc3_ = _loc3_.next;
		}
	}

	// ObjectPool.as:199-211
	public function destroy():Void {
		var _loc2_:ObjNode = null;
		var _loc1_:ObjNode = this._head;
		while (_loc1_ != null) {
			_loc2_ = _loc1_.next;
			_loc1_.next = null;
			_loc1_.data = null;
			_loc1_ = _loc2_;
		}
		this._head = this._tail = this._emptyNode = this._allocNode = null;
	}

	// ObjectPool.as:213-239
	public function allocate(param1:UInt, param2:Class<Dynamic> = null):Void {
		var _loc3_:ObjNode = null;
		this.destroy();
		if (param2 != null) {
			this._factory = new SimpleFactory(param2);
		} else if (this._factory == null) {
			throw new Error("nothing to instantiate.");
		}
		this._initSize = this._currSize = param1;
		this._head = this._tail = new ObjNode();
		this._head.data = this.createObject();
		var _loc4_:Int = 1;
		while (_loc4_ < this._initSize) {
			_loc3_ = new ObjNode();
			_loc3_.data = this.createObject();
			_loc3_.next = this._head;
			this._head = _loc3_;
			_loc4_++;
		}
		this._emptyNode = this._allocNode = this._head;
		this._tail.next = this._head;
	}
}

// ObjectPool.as:243-254（AS3 包级类 ObjNode）
private class ObjNode {
	// ObjectPool.as:246
	public var data:Dynamic;

	// ObjectPool.as:248
	public var next:ObjNode;

	public function new() {}
}
