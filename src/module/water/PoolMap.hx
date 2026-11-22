package module.water;

import common.misc.Utils;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.geom.Point;
import shim.As3;

/**
 * module.water.PoolMap —— PoolMap.as 逐句对应（issue #37 功能 swf 翻译：鱼塘
 * pool_v_13 池底图）。素材 PoolMap（water_v_5）：holder 挂鱼层、limit 池边界
 * （a1-a4 四角锚点）、c* 出生圈（构造即隐藏）。方向向量/中心向量/圆角半径
 * 全部从锚点算（initializeCalculations 缓存 _dirsVector）。
 * AS3 internal → private、protected → private（Haxe private 含子类可见，
 * WaterPool 继承本类直取 _pool/_fishContainer）。
 * `_pool["holder"]` 等时间轴具名子件读取按 CLAUDE.md 动态属性分流走
 * As3.childOf（ getChildByName 通道）。
 */
class PoolMap extends Sprite {
	// PoolMap.as:13（AS3 internal static const → private，CLAUDE.md 映射）
	private static final SPAWN_CIRCLE_NUM:UInt = 24;

	// PoolMap.as:15
	private var _dirsVector:Array<Dynamic>;

	// PoolMap.as:17
	private var _centerAnchor:Point;

	// PoolMap.as:19（AS3 protected → private：Haxe private 子类可见）
	private var _fishContainer:DisplayObjectContainer;

	// PoolMap.as:21
	private var _anchors:Array<Dynamic>;

	// PoolMap.as:23
	// AS3 Number 默认 NaN（eval/js 未赋值是 null/undefined，显式落）
	private var _cornerRadius:Float = Math.NaN;

	// PoolMap.as:25
	private var _pool:MovieClip;

	// PoolMap.as:27
	private var _limit:DisplayObject;

	// PoolMap.as:29-34
	public function new() {
		super();
		this.createPoolMap();
		this.hideCircles();
	}

	// PoolMap.as:36-54
	private function hideCircles():Void {
		if (this._pool == null) {
			return;
		}
		var _loc1_:UInt = this._pool.numChildren;
		var _loc2_:DisplayObject = null;
		var _loc3_:Int = 0;
		while (_loc3_ < _loc1_) {
			_loc2_ = this._pool.getChildAt(_loc3_);
			if ((_loc2_.name.length == 2 || _loc2_.name.length == 3) && _loc2_.name.charAt(0) == "c") {
				_loc2_.visible = false;
			}
			_loc3_++;
		}
	}

	// PoolMap.as:56-72
	private function createPoolMap():Void {
		this._pool = cast(Utils.getMaterial("PoolMap"), MovieClip);
		if (this._pool != null) {
			this._pool.mouseChildren = false;
			this._pool.mouseEnabled = false;
			this._fishContainer = cast(As3.childOf(this._pool, "holder"), DisplayObjectContainer);
			this._limit = cast(As3.childOf(this._pool, "limit"), DisplayObject);
			if (this._limit != null) {
				this._limit.visible = false;
				this._anchors = [As3.childOf(this._limit, "a1"), As3.childOf(this._limit, "a2"),
					As3.childOf(this._limit, "a3"), As3.childOf(this._limit, "a4")];
			}
			this.initializeCalculations();
		}
	}

	// PoolMap.as:74-79。`Math.floor(..) as int` → Std.int
	public function randSpawnCircle():DisplayObject {
		var _loc1_:Array<Dynamic> = ["c4", "c7", "c10", "c13", "c16", "c19"];
		var _loc2_:Int = Std.int(Math.floor(Math.random() * _loc1_.length));
		return cast(As3.childOf(this._pool, _loc1_[_loc2_]), DisplayObject);
	}

	// PoolMap.as:81-84
	public var fishContainer(get, never):DisplayObjectContainer;

	private function get_fishContainer():DisplayObjectContainer {
		return this._fishContainer;
	}

	// PoolMap.as:86-108。`_pool.hasOwnProperty("c"+n)`（具名子件存在性）→
	// childOf 判空；AS3 原文两次取同一子件，照抄
	public function cdWithCircles(param1:MovieClip, param2:Array<Dynamic>):Bool {
		if (param1 == null || param2 == null || param2.length == 0) {
			return false;
		}
		var _loc3_:Point = new Point(param1.width * 0.5, param1.height * 0.5);
		_loc3_ = param1.localToGlobal(_loc3_);
		var _loc4_:Int = param2.length;
		var _loc5_:Int = 0;
		while (_loc5_ < _loc4_) {
			if (As3.childOf(this._pool, "c" + param2[_loc5_]) != null) {
				if (cast(As3.childOf(this._pool, "c" + param2[_loc5_]),
					DisplayObject).hitTestPoint(_loc3_.x, _loc3_.y, true) == true) {
					return true;
				}
			}
			_loc5_++;
		}
		return false;
	}

	// PoolMap.as:110-133。_loc3_ 是平方距离，_cornerRadius 同量纲
	public function atCorner(param1:Float, param2:Float):Int {
		var _loc3_:Float = Math.NaN;
		var _loc4_:Float = Math.POSITIVE_INFINITY;
		var _loc5_:Int = -1;
		var _loc6_:Int = this._anchors.length;
		var _loc7_:DisplayObject = null;
		var _loc8_:Int = 0;
		while (_loc8_ < _loc6_) {
			_loc7_ = cast(this._anchors[_loc8_], DisplayObject);
			_loc3_ = (param1 - (_loc7_.x + this._limit.x)) * (param1 - (_loc7_.x + this._limit.x))
				+ (param2 - (_loc7_.y + this._limit.y)) * (param2 - (_loc7_.y + this._limit.y));
			if (_loc3_ <= this._cornerRadius) {
				if (_loc3_ < _loc4_) {
					_loc4_ = _loc3_;
					_loc5_ = _loc8_;
				}
			}
			_loc8_++;
		}
		return _loc5_;
	}

	// PoolMap.as:135-173
	public function calcNormalizedVelocity(param1:Int):Point {
		if (param1 < 0) {
			return null;
		}
		if (this._dirsVector != null && param1 < this._dirsVector.length) {
			return this._dirsVector[param1];
		}
		var _loc2_:Point = new Point();
		var _a_:Array<Dynamic> = this._anchors;
		if (param1 == 0) {
			_loc2_.x = cast(_a_[0], DisplayObject).x - cast(_a_[3], DisplayObject).x;
			_loc2_.y = cast(_a_[0], DisplayObject).y - cast(_a_[3], DisplayObject).y;
		} else if (param1 == 1) {
			_loc2_.x = cast(_a_[2], DisplayObject).x - cast(_a_[3], DisplayObject).x;
			_loc2_.y = cast(_a_[2], DisplayObject).y - cast(_a_[3], DisplayObject).y;
		} else if (param1 == 2) {
			_loc2_.x = cast(_a_[2], DisplayObject).x - cast(_a_[1], DisplayObject).x;
			_loc2_.y = cast(_a_[2], DisplayObject).y - cast(_a_[1], DisplayObject).y;
		} else if (param1 == 3) {
			_loc2_.x = cast(_a_[0], DisplayObject).x - cast(_a_[1], DisplayObject).x;
			_loc2_.y = cast(_a_[0], DisplayObject).y - cast(_a_[1], DisplayObject).y;
		}
		var _loc3_:Float = Math.sqrt(_loc2_.x * _loc2_.x + _loc2_.y * _loc2_.y);
		if (_loc3_ > 0) {
			_loc2_.x /= _loc3_;
			_loc2_.y /= _loc3_;
		}
		return _loc2_;
	}

	// PoolMap.as:175-189
	public function calcCenterVector(param1:MovieClip):Point {
		if (param1 == null) {
			return null;
		}
		var _loc2_:Point = new Point();
		_loc2_.x = param1.x + param1.width * 0.5 * param1.scaleX;
		_loc2_.y = param1.y + param1.height * 0.5 * param1.scaleY;
		var _loc3_:Point = new Point(this._centerAnchor.x - _loc2_.x, this._centerAnchor.y - _loc2_.y);
		var _loc4_:Float = Math.sqrt(_loc3_.x * _loc3_.x + _loc3_.y * _loc3_.y);
		_loc3_.x /= _loc4_;
		_loc3_.y /= _loc4_;
		return _loc3_;
	}

	// PoolMap.as:191-198
	public function cdWithPoolLimit(param1:Point):Bool {
		if (param1 == null || this._limit == null) {
			return false;
		}
		return this._limit.hitTestPoint(param1.x, param1.y, true);
	}

	// PoolMap.as:200-228。`new Array(4)` = 4 空槽 → 4 个 null
	private function initializeCalculations():Void {
		var _loc1_:Array<Dynamic> = null;
		var _loc2_:Int = 0;
		var _loc3_:Float = Math.NaN;
		var _loc4_:Float = Math.NaN;
		if (this._dirsVector == null) {
			_loc1_ = [null, null, null, null];
			_loc2_ = 0;
			while (_loc2_ < 4) {
				_loc1_[_loc2_] = this.calcNormalizedVelocity(_loc2_);
				_loc2_++;
			}
			this._dirsVector = _loc1_;
		}
		if (this._centerAnchor == null) {
			this._centerAnchor = new Point((cast(this._anchors[3], DisplayObject).x + cast(this._anchors[1],
				DisplayObject).x) * 0.5, (cast(this._anchors[0], DisplayObject).y + cast(this._anchors[2],
				DisplayObject).y) * 0.5);
			this._centerAnchor.x += this._limit.x;
			this._centerAnchor.y += this._limit.y;
			_loc3_ = (cast(this._anchors[1], DisplayObject).x - cast(this._anchors[0], DisplayObject).x)
				* (cast(this._anchors[1], DisplayObject).x - cast(this._anchors[0], DisplayObject).x)
				+ (cast(this._anchors[1], DisplayObject).y - cast(this._anchors[0], DisplayObject).y)
				* (cast(this._anchors[1], DisplayObject).y - cast(this._anchors[0], DisplayObject).y);
			_loc3_ /= 4;
			_loc4_ = (cast(this._anchors[3], DisplayObject).x - cast(this._anchors[2], DisplayObject).x)
				* (cast(this._anchors[3], DisplayObject).x - cast(this._anchors[2], DisplayObject).x)
				+ (cast(this._anchors[3], DisplayObject).y - cast(this._anchors[2], DisplayObject).y)
				* (cast(this._anchors[3], DisplayObject).y - cast(this._anchors[2], DisplayObject).y);
			_loc4_ = _loc4_ / 4;
			this._cornerRadius = (_loc3_ + _loc4_) / 2;
		}
	}
}
