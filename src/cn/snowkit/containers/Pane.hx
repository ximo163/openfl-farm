package cn.snowkit.containers;

import openfl.display.DisplayObject;
import openfl.display.Sprite;
import shim.As3;

// cn.snowkit.containers.Pane —— Pane.as 逐句对应（issue #86 牧场库底座，
// snowkit 片）。九宫格排布容器：内嵌 _container 承载子件，H/V 两种流式
// 排布 + 三向对齐，底板 _border 自绘填充/边框。
// `_loc3_.hasOwnProperty("visibleWidth")`（动态属性存在性）→ As3.hasProp，
// 读取 → Reflect.field（Pane.as:96-98/103-105/238/249）。
@:keep
class Pane extends Sprite {
	// Pane.as:9-23
	public static final ALIGN_LEFT:Int = 0;

	public static final ALIGN_CNETER:Int = 1;

	public static final ALIGN_RIGHT:Int = 2;

	public static final VALIGN_TOP:Int = 0;

	public static final VALIGN_MIDDLE:Int = 1;

	public static final VALIGN_BUTTOM:Int = 2;

	public static final MODE_H:Int = 0;

	public static final MODE_V:Int = 1;

	// Pane.as:25-53（AS3 protected → Haxe private，子类可见）
	private var _totalWidth:Float;

	private var _mode:Int;

	private var _align:Int;

	private var _container:Sprite;

	private var _fillColor:UInt;

	private var _fillAlpha:Float;

	// Pane.as:37-39（public 字段）
	public var topSpace:Int = -1;

	public var leftSpace:Int = -1;

	private var _border:Sprite;

	private var _totalHeight:Float;

	private var _vAlign:Int = 0; // AS3 int 默认值（原版无初始化式，构造器也不赋值）

	private var _borderAlpha:Float;

	private var _blank:Int;

	private var _paneWidth:Float;

	private var _paneHeight:Float;

	// Pane.as:55-72
	public function new(param1:Float = 100, param2:Float = 100, param3:Bool = false, param4:UInt = 0, param5:Float = 0) {
		super();
		this._paneWidth = param1;
		this._paneHeight = param2;
		this._fillColor = param4;
		this._fillAlpha = param5;
		this._borderAlpha = param3 ? 1 : 0;
		this._mode = 0;
		this._align = 0;
		this._blank = 2;
		this._border = new Sprite();
		this._drawBorder();
		this._border.mouseChildren = this._border.mouseEnabled = false;
		addChild(this._border);
		this._container = new Sprite();
		addChild(this._container);
	}

	// Pane.as:74-77
	public var align(never, set):Int;

	private function set_align(param1:Int):Int {
		this._align = param1;
		return param1;
	}

	// Pane.as:79-110
	private function _orderChilds():Void {
		var _loc3_:DisplayObject = null;
		var _loc4_:Float = Math.NaN;
		var _loc5_:Float = Math.NaN;
		var _loc1_:Int = this._container.numChildren;
		this._totalWidth = 0;
		this._totalHeight = 0;
		var _loc2_:Int = 0;
		while (_loc2_ < _loc1_) {
			_loc3_ = Std.isOfType(this._container.getChildAt(_loc2_), DisplayObject) ? cast this._container.getChildAt(_loc2_) : null;
			if (_loc3_ != null) {
				if (this._mode == MODE_H) {
					_loc3_.x = Std.int(this._totalWidth + this._blank);
					this._totalWidth += (As3.hasProp(_loc3_, "visibleWidth") ? Reflect.field(_loc3_, "visibleWidth") : _loc3_.width) + this._blank;
					_loc4_ = As3.hasProp(_loc3_, "visibleHeight") ? cast(Reflect.field(_loc3_, "visibleHeight"), Float) : _loc3_.height;
					this._totalHeight = _loc4_ > this._totalHeight ? _loc4_ : this._totalHeight;
				} else {
					_loc3_.y = Std.int(this._totalHeight + this._blank);
					this._totalHeight += (As3.hasProp(_loc3_, "visibleHeight") ? Reflect.field(_loc3_, "visibleHeight") : _loc3_.height) + this._blank;
					_loc5_ = As3.hasProp(_loc3_, "visibleWidth") ? cast(Reflect.field(_loc3_, "visibleWidth"), Float) : _loc3_.width;
					this._totalWidth = _loc5_ > this._totalWidth ? _loc5_ : this._totalWidth;
				}
			}
			_loc2_++;
		}
	}

	// Pane.as:112-118
	public function setSizeWH(param1:Float, param2:Float):Void {
		this._paneWidth = param1;
		this._paneHeight = param2;
		this._drawBorder();
		this._setChildsXY();
	}

	// Pane.as:120-123
	public var fillAlpha(get, set):Float;

	private function get_fillAlpha():Float {
		return this._fillAlpha;
	}

	// Pane.as:125-132
	public override function contains(param1:DisplayObject):Bool {
		if (this._container.contains(param1)) {
			return true;
		}
		return false;
	}

	// Pane.as:134-137
	public var fillColor(get, set):UInt;

	private function get_fillColor():UInt {
		return this._fillColor;
	}

	// Pane.as:139-144
	public function appendChild(param1:DisplayObject):DisplayObject {
		var _loc2_:DisplayObject = this._container.addChild(param1);
		this._setChildsXY();
		return _loc2_;
	}

	// Pane.as:146-149
	public override function get_numChildren():Int {
		return this._container.numChildren;
	}

	// Pane.as:151-154
	public var blank(get, set):Int;

	private function set_blank(param1:Int):Int {
		this._blank = param1;
		return param1;
	}

	// Pane.as:156-159
	public var paneHeight(get, set):Float;

	private function get_paneHeight():Float {
		return this._paneHeight;
	}

	// Pane.as:161-168
	private function _drawBorder():Void {
		this._border.graphics.clear();
		this._border.graphics.lineStyle(0, 0, this._borderAlpha);
		this._border.graphics.beginFill(this._fillColor, this._fillAlpha);
		this._border.graphics.drawRect(0, 0, this._paneWidth, this._paneHeight);
		this._border.graphics.endFill();
	}

	// Pane.as:170-174
	private function set_fillAlpha(param1:Float):Float {
		this._fillAlpha = param1;
		this._drawBorder();
		return param1;
	}

	// Pane.as:176-179
	public var paneWidth(get, set):Float;

	private function get_paneWidth():Float {
		return this._paneWidth;
	}

	// Pane.as:181-185
	private function set_fillColor(param1:UInt):UInt {
		this._fillColor = param1;
		this._drawBorder();
		return param1;
	}

	// Pane.as:187-190
	public var mode(never, set):Int;

	private function set_mode(param1:Int):Int {
		this._mode = param1;
		return param1;
	}

	// Pane.as:192-196
	public function revalidate():Void {
		this._drawBorder();
		this._setChildsXY();
	}

	// Pane.as:198-203
	public override function removeChildAt(param1:Int):DisplayObject {
		var _loc2_:DisplayObject = this._container.removeChildAt(param1);
		this.revalidate();
		return _loc2_;
	}

	// Pane.as:205-208
	private function get_blank():Int {
		return this._blank;
	}

	// Pane.as:210-254
	private function _setChildsXY():Void {
		var _loc1_:Int = 0;
		var _loc2_:Int = 0;
		var _loc3_:DisplayObject = null;
		this._orderChilds();
		switch (this._align) {
			case ALIGN_LEFT:
				this._container.x = this.leftSpace == -1 ? this._blank : this.leftSpace;
			case ALIGN_CNETER:
				this._container.x = Std.int((this._paneWidth - this._totalWidth) / 2);
			case ALIGN_RIGHT:
				this._container.x = Std.int(this._paneWidth - this._totalWidth - this._blank * 2);
		}
		switch (this._vAlign) {
			case VALIGN_TOP:
				this._container.y = this.topSpace == -1 ? this._blank : this.topSpace;
			case VALIGN_MIDDLE:
				_loc1_ = this._container.numChildren;
				_loc2_ = 0;
				while (_loc2_ < _loc1_) {
					_loc3_ = Std.isOfType(this._container.getChildAt(_loc2_), DisplayObject) ? cast this._container.getChildAt(_loc2_) : null;
					_loc3_.y = Std.int((this._totalHeight - (As3.hasProp(_loc3_, "visibleHeight") ? Reflect.field(_loc3_, "visibleHeight") : _loc3_.height)) / 2);
					_loc2_++;
				}
				this._container.y = Std.int((this._paneHeight - this._totalHeight) / 2);
			case VALIGN_BUTTOM:
				_loc1_ = this._container.numChildren;
				_loc2_ = 0;
				while (_loc2_ < _loc1_) {
					_loc3_ = Std.isOfType(this._container.getChildAt(_loc2_), DisplayObject) ? cast this._container.getChildAt(_loc2_) : null;
					_loc3_.y = Std.int(this._totalHeight - (As3.hasProp(_loc3_, "visibleHeight") ? Reflect.field(_loc3_, "visibleHeight") : _loc3_.height));
					_loc2_++;
				}
				this._container.y = Std.int(this._paneHeight - this._totalHeight);
		}
	}

	// Pane.as:256-259
	private function set_paneHeight(param1:Float):Float {
		this._paneHeight = param1;
		return param1;
	}

	// Pane.as:261-264
	public var vAlign(never, set):Int;

	private function set_vAlign(param1:Int):Int {
		this._vAlign = param1;
		return param1;
	}

	// Pane.as:266-274
	public override function removeChild(param1:DisplayObject):DisplayObject {
		if (this._container.contains(param1)) {
			this._container.removeChild(param1);
			this.revalidate();
		}
		return param1;
	}

	// Pane.as:276-279
	private function set_paneWidth(param1:Float):Float {
		this._paneWidth = param1;
		return param1;
	}
}
