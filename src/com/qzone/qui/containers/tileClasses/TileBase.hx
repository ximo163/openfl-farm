package com.qzone.qui.containers.tileClasses;

import com.qzone.qui.containers.Canvas;
import com.qzone.qui.core.Direction;
import com.qzone.qui.events.ScrollEvent;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import shim.As3;

/**
 * com.qzone.qui.containers.tileClasses.TileBase —— TileBase.as 逐句对应
 * （issue #18 qui 收尾：容器片）。瓦片容器基类：itemRenderer 反射成批重建、
 * 网格布局（水平/垂直折行）、瓦片级 click/rollover/rollout 事件挂接。
 * PORT-NOTE: `_loc3_[this.dataField] = v`（按名写瓦片属性）走
 * Reflect.setProperty——js 上裸 Dynamic 写只落影子字段（ScrollThumb 同注）；
 * `param1[param2](...)` 按/移除事件监听 → Reflect.callMethod 保持 this 绑定。
 */
class TileBase extends Canvas {
	// TileBase.as:11-33
	private var _contentHeight:Float;

	private var _childrenWidth:Int;

	// 原版 protected（TileBase.as:19/31）→ Haxe private（子类可见同 AS3）。
	private var _data:Array<Dynamic>;

	public var itemRollOverFn:Dynamic;

	private var _childrenHeight:Int;

	private var _contentWidth:Float;

	public var gapH:Int = 10;

	public var tileWidth:Float;

	private var _childArray:Array<Dynamic> = [];

	public var gapV:Int = 10;

	public var itemClickFn:Dynamic;

	public var itemRollOutFn:Dynamic;

	public var labelField:String = "label";

	public var dataField:String = "data";

	public var tileHeight:Float;

	public var itemRenderer:Class<Dynamic>;

	public var direction:String = "horizontal";

	// :35-39
	public function new() {
		super();
		this.paddingH = 10;
		this.paddingV = 10;
	}

	// :41-48
	public function removeAll():Void {
		var _loc1_:Int = this._childArray.length - 1;
		while (_loc1_ >= 0) {
			this.removeElementAt(_loc1_);
			_loc1_--;
		}
	}

	// :50-53
	private override function get_contentHeight():Float {
		this._contentHeight = this._childrenHeight + this.paddingV;
		return cast(As3.or(this._contentHeight, this.content.height), Float);
	}

	// :55-58
	private function onRebuildComplete():Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}

	// :60-62
	public function getElementAt(param1:UInt):Dynamic {
		return this.content.getChildAt(param1);
	}

	// :64-79
	private function rebuild():Void {
		var _loc1_:Int = 0;
		var _loc2_:Int = 0;
		var _loc3_:DisplayObject = null;
		this.removeAll();
		if (this._data != null && this.content != null) {
			_loc1_ = this._data.length;
			while (_loc2_ < _loc1_) {
				_loc3_ = cast Type.createInstance(this.itemRenderer, []);
				this._childArray[_loc2_] = _loc3_;
				Reflect.setProperty(_loc3_, this.dataField, this._data[_loc2_]);
				this.eventHandle(_loc3_);
				_loc2_++;
			}
		}
		this.layout();
		this.onRebuildComplete();
	}

	// :81-83
	public function addElement(param1:DisplayObject):Void {
		this.addElementAt(param1, this._childArray.length);
	}

	// :85-124
	private function layout():Void {
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		var _loc6_:Int = 0;
		var _loc7_:Int = 0;
		var _loc8_:Int = 0;
		var _loc9_:DisplayObject = null;
		var _loc1_:Int = this._childArray.length;
		while (_loc8_ < _loc1_) {
			_loc9_ = cast this._childArray[_loc8_];
			Reflect.setProperty(_loc9_, this.dataField, this._data[_loc8_]);
			_loc2_ = As3.intOf(As3.or(Std.int(this.tileWidth), Std.int(_loc9_.width)));
			_loc3_ = As3.intOf(As3.or(Std.int(this.tileHeight), Std.int(_loc9_.height)));
			if (this.direction == Direction.HORIZONTAL) {
				_loc5_ = Math.floor((this._width - this.paddingH) / (_loc2_ + this.gapH));
				_loc4_ = Math.ceil(_loc1_ / _loc5_);
				_loc6_ = _loc8_ % _loc5_;
				_loc7_ = Math.floor(_loc8_ / _loc5_);
			} else if (this.direction == Direction.VERTICAL) {
				_loc4_ = Math.floor((this._height - this.paddingV) / (_loc3_ + this.gapV));
				_loc5_ = Math.ceil(_loc1_ / _loc4_);
				_loc6_ = Std.int(_loc8_ / _loc4_);
				_loc7_ = Math.floor(_loc8_ % _loc4_);
			}
			_loc9_.x = this.paddingH + _loc2_ * _loc6_ + this.gapH * _loc6_;
			_loc9_.y = this.paddingV + _loc3_ * _loc7_ + this.gapV * _loc7_;
			this.content.addChild(_loc9_);
			_loc8_++;
		}
		this._childrenWidth = this.paddingH + _loc5_ * (_loc2_ + this.gapH) - this.gapH;
		this._childrenHeight = this.paddingV + _loc4_ * (_loc3_ + this.gapV) - this.gapV;
		this.validateNow();
	}

	// :126-141
	public function removeElementAt(param1:Int):DisplayObject {
		var _loc2_:DisplayObject = null;
		if (param1 < this._childArray.length && param1 > -1) {
			_loc2_ = cast this._childArray.splice(param1, 1)[0];
			if (_loc2_ != null) {
				this.eventHandle(_loc2_, "removeEventListener");
				if (_loc2_.parent != null) {
					_loc2_.parent.removeChild(_loc2_);
				}
				this.delayCall(this.layout);
			}
		}
		return _loc2_;
	}

	// :143-149
	public function addElementAt(param1:DisplayObject, param2:Int):Void {
		if (param2 <= this._childArray.length && param2 > -1) {
			// AS3 splice(pos, 0, item) 的「零删插入」= Haxe Array.insert。
			this._childArray.insert(param2, param1);
			this.eventHandle(param1);
			this.delayCall(this.layout);
		}
	}

	// :151-153 + :168-174（AS3 public get/set dataProvider 对）
	public var dataProvider(get, set):Array<Dynamic>;

	private function get_dataProvider():Array<Dynamic> {
		return this._data;
	}

	// :176-179
	public function scrollVerticalReset():Void {
		this._scrollRect.y = 0;
		this.rebuild();
	}

	// :181-183
	public var items(get, never):Array<Dynamic>;

	private function get_items():Array<Dynamic> {
		return this._childArray;
	}

	// :185-188
	private override function get_contentWidth():Float {
		this._contentWidth = this._childrenWidth + this.paddingH;
		return cast(As3.or(this._contentWidth, this.content.width), Float);
	}

	// :190-192
	private override function onScrollChange(param1:ScrollEvent):Void {}

	// :194-203
	public function removeElement(param1:DisplayObject):Int {
		var _loc2_:Int = -1;
		if (this.content == param1.parent) {
			_loc2_ = this.content.getChildIndex(param1);
			this.removeElementAt(_loc2_);
		}
		return _loc2_;
	}

	// :205-209（`this.itemClickFn && param1[param2](...)`：短路 + 按名调用）
	private function eventHandle(param1:DisplayObject, param2:String = "addEventListener"):Void {
		if (this.itemClickFn != null) {
			Reflect.callMethod(param1, Reflect.field(param1, param2), [MouseEvent.CLICK, this.itemClickFn]);
		}
		if (this.itemRollOverFn != null) {
			Reflect.callMethod(param1, Reflect.field(param1, param2), [MouseEvent.ROLL_OVER, this.itemRollOverFn]);
		}
		if (this.itemRollOutFn != null) {
			Reflect.callMethod(param1, Reflect.field(param1, param2), [MouseEvent.ROLL_OUT, this.itemRollOutFn]);
		}
	}

	// :211-218
	private function set_dataProvider(param1:Array<Dynamic>):Array<Dynamic> {
		this._data = param1;
		if (this._inited) {
			this._scrollRect.y = 0;
			this._scrollRect.x = 0;
		}
		this.rebuild();
		this._inited = false;
		return param1;
	}

	// :220-224（int ← Math.max 的 Number 截断）
	private override function updateBackGround():Void {
		var _loc1_:Int = Std.int(Math.max(this._childrenWidth + this.paddingH, this._width - this._scrollW));
		var _loc2_:Int = Std.int(Math.max(this._childrenHeight + this.paddingV, this._height - this._scrollH));
		this.drawBackGround(_loc1_, _loc2_);
	}
}
