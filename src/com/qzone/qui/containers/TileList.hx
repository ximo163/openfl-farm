package com.qzone.qui.containers;

import com.qzone.qui.containers.tileClasses.TileBase;
import com.qzone.qui.containers.tileClasses.TileButton;
import com.qzone.qui.events.ScrollEvent;
import com.qzone.qui.skins.ListDefaultSkin;
import com.qzone.utils.DisplayUtil;
import openfl.display.DisplayObject;
import openfl.errors.Error;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import shim.As3;

/**
 * com.qzone.qui.containers.TileList —— TileList.as 逐句对应（issue #18 qui
 * 收尾：容器片）。瓦片列表（TileBase 的虚拟化重建：按行分组
 * groupInfo/groupChild，视口内行实例化 itemRenderer、视口外以 Point 占位，
 * 滚动时按行换入换出）。
 * PORT-NOTE:
 * - `_loc6_.x = ...` 瓦片可能是 Point（占位）或 DisplayObject，按名写统一走
 *   Reflect.setProperty（js 裸 Dynamic 写只落影子字段）。
 * - `_data[_loc2_ + _loc3_ * this.maxGrop]`：AS3 里 for-in 键 _loc2_ 是
 *   String，String + Number 是**拼接**不是数值加（"1"+12→"112"），再按
 *   字符串键取数组——"00"/"012" 这类非正则数字串落 undefined、"112" 这类
 *   正则串落错位元素，原版数据绑定本来就是坏的，照译不修（偏差只进
 *   spec/deviations.json，人维护）。As3.arrayIndex 复刻该取值语义。
 * - `for(_loc3_ in this.groupInfo)`：AS3 for-in 按现存下标升序枚举（分组建
 *   表按行号顺序写满），等价 0...length 索引遍历。
 */
class TileList extends TileBase {
	// TileList.as:13-18
	private var maxGrop:Int;

	// 原版 protected（TileList.as:14）→ Haxe private（子类可见同 AS3）。
	private var groupChild:Array<Dynamic> = [];

	private var scrolled:Bool;

	// 原版 protected（:17）→ private。
	private var groupInfo:Array<Dynamic> = [];

	// :20-27
	public function new() {
		super();
		this._width = 100;
		this._height = 100;
		this.defaultSkin = ListDefaultSkin.skin;
		this.itemRenderer = TileButton;
	}

	// :29-89
	private override function rebuild():Void {
		var _loc1_:Int = 0;
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		var _loc6_:Dynamic = null;
		var _loc7_:Int = 0;
		var _loc8_:Int = 0;
		var _loc9_:Int = 0;
		if (!As3.truthy(this.tileWidth) || !As3.truthy(this.tileHeight)) {
			throw new Error("TileList 需要设置 tileWidth 和 tileHeight 数值。");
		}
		removeAll();
		if (this.content != null) {
			while (this.content.numChildren > 0) {
				this.content.removeChildAt(0);
			}
		}
		this._childrenWidth = 0;
		this._childrenHeight = 0;
		this.groupChild = [];
		this.groupInfo = [];
		this.maxGrop = 0;
		if (this._data != null && this.content != null) {
			_loc1_ = this._data.length;
			_loc7_ = 0;
			while (_loc7_ < _loc1_) {
				if (this.groupInfo.length == 0
					|| cast(this.groupInfo[_loc5_], Rectangle).y + cast(this.groupInfo[_loc5_], Rectangle).height
					< this._scrollRect.y + this._scrollRect.height) {
					_loc6_ = Type.createInstance(this.itemRenderer, []);
				} else {
					_loc6_ = new Point();
				}
				this._childArray[_loc7_] = _loc6_;
				_loc2_ = As3.intOf(As3.or(Std.int(this.tileWidth), As3.intOf(Reflect.getProperty(_loc6_, "width"))));
				_loc3_ = As3.intOf(As3.or(Std.int(this.tileHeight), As3.intOf(Reflect.getProperty(_loc6_, "height"))));
				if (!As3.truthy(this.maxGrop)) {
					_loc8_ = Math.floor((this._width - this.paddingH) / (_loc2_ + this.gapH));
					_loc9_ = Math.ceil(_loc1_ / _loc8_);
					this.maxGrop = _loc8_;
				}
				_loc4_ = _loc7_ % _loc8_;
				_loc5_ = Math.floor(_loc7_ / _loc8_);
				Reflect.setProperty(_loc6_, "x", this.paddingH + _loc2_ * _loc4_ + this.gapH * _loc4_);
				Reflect.setProperty(_loc6_, "y", this.paddingV + _loc3_ * _loc5_ + this.gapV * _loc5_);
				if (this.groupInfo[_loc5_] == null) {
					this.groupInfo[_loc5_] = new Rectangle(0, Reflect.getProperty(_loc6_, "y"), 0, _loc3_);
					this.groupChild[_loc5_] = {};
				}
				Reflect.setField(this.groupChild[_loc5_], Std.string(_loc4_), _loc6_);
				_loc7_++;
			}
			this._childrenWidth = this.paddingH + _loc8_ * (_loc2_ + this.gapH) - this.gapH;
			this._childrenHeight = this.paddingV + _loc9_ * (_loc3_ + this.gapV) - this.gapV;
		}
		this.scrolled = true;
		this.layout();
		this.onRebuildComplete();
	}

	// :91-136
	private override function layout():Void {
		var _loc1_:DisplayObject = null;
		var _loc2_:String = null;
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		for (_loc3_ in 0...this.groupInfo.length) {
			if (cast(this.groupInfo[_loc3_], Rectangle).y + cast(this.groupInfo[_loc3_], Rectangle).height
				> this._scrollRect.y && cast(this.groupInfo[_loc3_], Rectangle).y
				< this._scrollRect.y + this._scrollRect.height) {
				for (_loc2_ in Reflect.fields(this.groupChild[_loc3_])) {
					var _loc5_:Dynamic = Reflect.field(this.groupChild[_loc3_], _loc2_);
					_loc1_ = Std.isOfType(_loc5_, DisplayObject) ? cast _loc5_ : null;
					if (_loc1_ == null) {
						_loc1_ = cast Type.createInstance(this.itemRenderer, []);
						DisplayUtil.copyProperties(Reflect.field(this.groupChild[_loc3_], _loc2_), _loc1_, ["x", "y"]);
						Reflect.setField(this.groupChild[_loc3_], _loc2_, _loc1_);
						_loc4_ = 0;
						while (_loc4_ < this._childArray.length) {
							if (Std.isOfType(this._childArray[_loc4_], this.itemRenderer) == false) {
								this._childArray[_loc4_] = _loc1_;
								break;
							}
							_loc4_++;
						}
					}
					if (_loc1_.parent == null) {
						// TileList.as:134 `_data[_loc2_ + _loc3_ * this.maxGrop]`：
						// String 键 + Number 是 AS3 拼接，字符串键按
						// As3.arrayIndex 取（PORT-NOTE 见类头）——照译不修
						Reflect.setProperty(_loc1_, this.dataField,
							As3.arrayIndex(this._data, _loc2_ + Std.string(_loc3_ * this.maxGrop)));
						eventHandle(_loc1_);
						this.content.addChild(_loc1_);
					}
				}
			} else {
				for (_loc2_ in Reflect.fields(this.groupChild[_loc3_])) {
					var _loc6_:Dynamic = Reflect.field(this.groupChild[_loc3_], _loc2_);
					_loc1_ = Std.isOfType(_loc6_, DisplayObject) ? cast _loc6_ : null;
					if (_loc1_ != null) {
						eventHandle(_loc1_, "removeEventListener");
						DisplayUtil.removeChild(this.content, _loc1_);
						Reflect.setProperty(_loc1_, this.dataField, null);
					}
				}
			}
		}
		if (this.scrolled) {
			this.validateNow();
			this.scrolled = false;
		}
	}

	// :138-140
	private override function onScrollChange(param1:ScrollEvent):Void {
		this.layout();
	}
}
