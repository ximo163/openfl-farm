package com.qzone.qui.containers.boxClasses;

import com.qzone.qui.containers.Canvas;
import com.qzone.qui.core.Align;
import com.qzone.qui.core.Direction;
import com.qzone.qui.styles.Style;
import com.qzone.utils.AlignUtil;
import openfl.display.DisplayObject;
import shim.As3;

/**
 * com.qzone.qui.containers.boxClasses.Box —— Box.as 逐句对应（issue #9
 * qui 子集片）。盒式布局容器：addElement 按 alignV/alignH 九宫（TL/TC/TR/
 * ML/MC/MR/BL/BC/BR）重排 content 全部子件；每次 addElement 累加
 * _childrenWidth/_childrenHeight 再整列重定位。原文 MR 横向分支带
 * specialGapH/specialGapHIndex 插空；updateBackGround 的宽高公式里 gapV/
 * gapH 与 Container 对称位互换（:571-572），均照抄。addSpecialGapH 字段
 * 原文声明后无引用，照抄保留。
 */
class Box extends Canvas {
	// Box.as:13-39
	public var gapV:Int = Style.boxGapV;
	private var _contentHeight:Float;
	private var nextX:Int;
	private var _childrenWidth:Int;
	public var specialGapH:Int = 0;
	private var nextY:Int;
	public var specialGapHIndex:Int = 0;
	public var alignH:String = "center";
	private var _childrenHeight:Int;
	private var addSpecialGapH:Bool = true;
	private var _contentWidth:Float;
	public var alignV:String = "middle";
	public var gapH:Int = Style.boxGapH;
	private var direction:String = "horizontal";

	// Box.as:41-48
	public function new(param1:Float = 200, param2:Float = 200) {
		super(param1, param2);
		this.paddingH = Style.boxPaddingH;
		this.paddingV = Style.boxPaddingV;
		this.backgroundColor = Style.boxBackgroundColor;
		this.backgroundAlpha = Style.boxBackgroundAlpha;
	}

	// Box.as:50-99
	private function BL(param1:DisplayObject):Void {
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		this.nextX = this.paddingH;
		if (Direction.HORIZONTAL == this.direction) {
			this._childrenWidth += Std.int(param1.width + this.gapH);
			this._childrenHeight += Std.int(param1.height + this.gapV);
			_loc3_ = Std.int(this._height - this.paddingV - this._scrollH);
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (_loc3_ < this.paddingV) {
				_loc3_ = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.x = this.nextX;
				param1.y = _loc3_ - param1.height;
				this.nextX += Std.int(param1.width + this.gapH);
				_loc2_++;
			}
		} else {
			this._childrenWidth = Std.int(Math.max(param1.width + this.gapH, this._childrenWidth));
			this._childrenHeight += Std.int(param1.height + this.gapV);
			_loc3_ = Std.int(this._height - this.paddingV - (this._childrenHeight - this.gapV));
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (_loc3_ < this.paddingV) {
				_loc3_ = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.y = _loc3_;
				param1.x = this.nextX;
				_loc3_ += Std.int(param1.height + this.gapV);
				_loc2_++;
			}
		}
	}

	// Box.as:101-105（`|| _content.height`：0/NaN 时取右值）
	private override function get_contentHeight():Float {
		this._contentHeight = this._childrenHeight - this.gapV + this.paddingV * 2;
		return As3.or(this._contentHeight, this._content.height);
	}

	// Box.as:107-119
	public function removeAllElements():Void {
		if (this.content == null) {
			return;
		}
		while (this.content.numChildren > 0) {
			this.content.removeChildAt(0);
		}
		this.nextX = this.nextY = 0;
		this._childrenWidth = this._childrenHeight = 0;
	}

	// Box.as:121-176
	private function BR(param1:DisplayObject):Void {
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		if (Direction.HORIZONTAL == this.direction) {
			this._childrenWidth += Std.int(param1.width + this.gapH);
			this._childrenHeight += Std.int(param1.height + this.gapV);
			_loc4_ = Std.int(this._width - this.paddingH - (this._childrenWidth - this.gapH));
			_loc3_ = Std.int(this._height - this.paddingV - this._scrollH);
			if (_loc4_ < this.paddingH) {
				_loc4_ = this.paddingH;
			}
			if (_loc3_ < this.paddingV) {
				_loc3_ = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.x = _loc4_;
				param1.y = _loc3_ - param1.height;
				_loc4_ += Std.int(param1.width + this.gapH);
				_loc2_++;
			}
		} else {
			this._childrenWidth = Std.int(Math.max(param1.width + this.gapH, this._childrenWidth));
			this._childrenHeight += Std.int(param1.height + this.gapV);
			_loc4_ = Std.int(this._width - this.paddingH - this._scrollW);
			_loc3_ = Std.int(this._height - this.paddingV - (this._childrenHeight - this.gapV));
			if (this._childrenWidth > this._width) {
				_loc4_ = this._childrenWidth;
			}
			if (_loc4_ < this.paddingH) {
				_loc4_ = this.paddingH;
			}
			if (_loc3_ < this.paddingV) {
				_loc3_ = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.y = _loc3_;
				param1.x = _loc4_ - param1.width;
				_loc3_ += Std.int(param1.height + this.gapV);
				_loc2_++;
			}
		}
	}

	// Box.as:178-227
	private function BC(param1:DisplayObject):Void {
		var _loc2_:Int = 0;
		this.nextY = Std.int(this._height - this.paddingV - this._scrollH);
		if (Direction.HORIZONTAL == this.direction) {
			this._childrenWidth += Std.int(param1.width + this.gapH);
			this._childrenHeight = Std.int(Math.max(param1.height + this.gapV, this._childrenHeight));
			this.nextX = Std.int(AlignUtil.middle(this._width, this._childrenWidth - this.gapH));
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (this.nextY < this.paddingV) {
				this.nextY = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.x = this.nextX;
				param1.y = this.nextY - param1.height;
				this.nextX += Std.int(param1.width + this.gapH);
				_loc2_++;
			}
		} else {
			this._childrenWidth = Std.int(Math.max(param1.width + this.gapH, this._childrenWidth));
			this._childrenHeight += Std.int(param1.height + this.gapV);
			this.nextX = Math.floor((this._width - this._scrollW) / 2);
			this.nextY = Std.int(this._height - this.paddingV - (this._childrenHeight - this.gapV));
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (this.nextY < this.paddingV) {
				this.nextY = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.y = this.nextY;
				param1.x = Math.max(this.paddingV, Math.floor(this.nextX - param1.width / 2));
				this.nextY += Std.int(param1.height + this.gapV);
				_loc2_++;
			}
		}
	}

	// Box.as:229-279
	public function addElement(param1:DisplayObject):DisplayObject {
		this.content.addChild(param1);
		if (Align.MIDDLE == this.alignV) {
			if (Align.CENTER == this.alignH) {
				this.MC(param1);
			} else if (Align.LEFT == this.alignH) {
				this.ML(param1);
			} else if (Align.RIGHT == this.alignH) {
				this.MR(param1);
			}
		} else if (Align.TOP == this.alignV) {
			if (Align.CENTER == this.alignH) {
				this.TC(param1);
			} else if (Align.LEFT == this.alignH) {
				this.TL(param1);
			} else if (Align.RIGHT == this.alignH) {
				this.TR(param1);
			}
		} else if (Align.BOTTOM == this.alignV) {
			if (Align.CENTER == this.alignH) {
				this.BC(param1);
			} else if (Align.LEFT == this.alignH) {
				this.BL(param1);
			} else if (Align.RIGHT == this.alignH) {
				this.BR(param1);
			}
		}
		this.validateNow();
		return param1;
	}

	// Box.as:281-285
	private override function get_contentWidth():Float {
		this._contentWidth = this._childrenWidth - this.gapH + this.paddingH * 2;
		return As3.or(this._contentWidth, this._content.width);
	}

	// Box.as:287-336
	private function MC(param1:DisplayObject):Void {
		var _loc2_:Int = 0;
		if (Direction.HORIZONTAL == this.direction) {
			this._childrenWidth += Std.int(param1.width + this.gapH);
			this._childrenHeight = Std.int(Math.max(param1.height + this.gapV, this._childrenHeight));
			this.nextX = Std.int(AlignUtil.middle(this._width, this._childrenWidth - this.gapH));
			this.nextY = Math.floor((this._height - this._scrollH) / 2);
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (this.nextY < this.paddingV) {
				this.nextY = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.x = this.nextX;
				param1.y = Math.floor(this.nextY - param1.height / 2);
				this.nextX += Std.int(param1.width + this.gapH);
				_loc2_++;
			}
		} else {
			this._childrenWidth = Std.int(Math.max(param1.width + this.gapH, this._childrenWidth));
			this._childrenHeight += Std.int(param1.height + this.gapV);
			this.nextY = Std.int(AlignUtil.middle(this._height, this._childrenHeight - this.gapV));
			this.nextX = Math.floor((this._width - this._scrollW) / 2);
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (this.nextY < this.paddingV) {
				this.nextY = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.y = this.nextY;
				param1.x = Math.max(this.paddingV, Math.floor(this.nextX - param1.width / 2));
				this.nextY += Std.int(param1.height + this.gapV);
				_loc2_++;
			}
		}
	}

	// Box.as:338-391
	private function TR(param1:DisplayObject):Void {
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		this.nextY = this.paddingV;
		if (Direction.HORIZONTAL == this.direction) {
			this._childrenWidth += Std.int(param1.width + this.gapH);
			this._childrenHeight += Std.int(param1.height + this.gapV);
			_loc3_ = Std.int(this._width - this.paddingH - (this._childrenWidth - this.gapH));
			if (_loc3_ < this.paddingH) {
				_loc3_ = this.paddingH;
			}
			if (this.nextY < this.paddingV) {
				this.nextY = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.x = _loc3_;
				param1.y = this.nextY;
				_loc3_ += Std.int(param1.width + this.gapH);
				_loc2_++;
			}
		} else {
			this._childrenWidth = Std.int(Math.max(param1.width + this.gapH, this._childrenWidth));
			this._childrenHeight += Std.int(param1.height + this.gapV);
			_loc3_ = Std.int(this._width - this.paddingH - this._scrollW);
			if (this._childrenWidth > this._width) {
				_loc3_ = this._childrenWidth;
			}
			if (_loc3_ < this.paddingH) {
				_loc3_ = this.paddingH;
			}
			if (this.nextY < this.paddingV) {
				this.nextY = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.y = this.nextY;
				param1.x = _loc3_ - param1.width;
				this.nextY += Std.int(param1.height + this.gapV);
				_loc2_++;
			}
		}
	}

	// Box.as:393-441
	private function ML(param1:DisplayObject):Void {
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		this.nextX = this.paddingH;
		if (Direction.HORIZONTAL == this.direction) {
			this._childrenWidth += Std.int(param1.width + this.gapH);
			this._childrenHeight = Std.int(Math.max(param1.height + this.gapV, this._childrenHeight));
			_loc3_ = Math.floor((this._height - this._scrollH) / 2);
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (_loc3_ < this.paddingV) {
				_loc3_ = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.x = this.nextX;
				param1.y = Math.floor(_loc3_ - param1.height / 2);
				this.nextX += Std.int(param1.width + this.gapH);
				_loc2_++;
			}
		} else {
			this._childrenHeight += Std.int(param1.height + this.gapV);
			_loc3_ = Std.int(AlignUtil.middle(this._height, this._childrenHeight - this.gapV));
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (_loc3_ < this.paddingV) {
				_loc3_ = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.y = _loc3_;
				param1.x = this.nextX;
				_loc3_ += Std.int(param1.height + this.gapV);
				_loc2_++;
			}
		}
	}

	// Box.as:443-449
	public function removeElement(param1:DisplayObject):DisplayObject {
		this._childrenWidth -= Std.int(param1.width);
		this.content.removeChild(param1);
		this.validateNow();
		return param1;
	}

	// Box.as:451-499
	private function TC(param1:DisplayObject):Void {
		var _loc2_:Int = 0;
		this.nextY = this.paddingV;
		if (Direction.HORIZONTAL == this.direction) {
			this._childrenWidth += Std.int(param1.width + this.gapH);
			this._childrenHeight = Std.int(Math.max(param1.height + this.gapV, this._childrenHeight));
			this.nextX = Std.int(AlignUtil.middle(this._width, this._childrenWidth - this.gapH));
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (this.nextY < this.paddingV) {
				this.nextY = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.x = this.nextX;
				param1.y = this.nextY;
				this.nextX += Std.int(param1.width + this.gapH);
				_loc2_++;
			}
		} else {
			this._childrenHeight += Std.int(param1.height + this.gapV);
			this._childrenWidth = Std.int(Math.max(param1.width + this.gapH, this._childrenWidth));
			this.nextX = Math.floor((this._width - this._scrollW) / 2);
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (this.nextY < this.paddingV) {
				this.nextY = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.y = this.nextY;
				param1.x = Math.max(this.paddingV, Math.floor(this.nextX - param1.width / 2));
				this.nextY += Std.int(param1.height + this.gapV);
				_loc2_++;
			}
		}
	}

	// Box.as:501-567
	private function MR(param1:DisplayObject):Void {
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		if (Direction.HORIZONTAL == this.direction) {
			this._childrenWidth += Std.int(param1.width + this.gapH);
			this._childrenHeight += Std.int(param1.height + this.gapV);
			_loc4_ = Std.int(this._width - this.paddingH - (this._childrenWidth - this.gapH));
			_loc3_ = Math.floor((this._height - this._scrollH) / 2);
			if (_loc4_ < this.paddingH) {
				_loc4_ = this.paddingH;
			}
			if (_loc3_ < this.paddingV) {
				_loc3_ = this.paddingV;
			}
			_loc5_ = 0;
			while (_loc2_ < this.content.numChildren) {
				if (_loc2_ == this.specialGapHIndex) {
					_loc5_ = this.specialGapH;
				} else {
					_loc5_ = 0;
				}
				this._childrenWidth += _loc5_;
				param1 = cast this._content.getChildAt(_loc2_);
				param1.x = _loc4_;
				param1.y = Math.floor(_loc3_ - param1.height / 2);
				_loc4_ += Std.int(param1.width + this.gapH + _loc5_);
				_loc2_++;
			}
		} else {
			this._childrenWidth = Std.int(Math.max(param1.width + this.gapH, this._childrenWidth));
			this._childrenHeight += Std.int(param1.height + this.gapV);
			_loc4_ = Std.int(this._width - this.paddingH - this._scrollW);
			_loc3_ = Std.int(AlignUtil.middle(this._height, this._childrenHeight - this.gapV));
			if (this._childrenWidth > this._width) {
				_loc4_ = this._childrenWidth;
			}
			if (_loc4_ < this.paddingH) {
				_loc4_ = this.paddingH;
			}
			if (_loc3_ < this.paddingV) {
				_loc3_ = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.y = _loc3_;
				param1.x = _loc4_ - param1.width;
				_loc3_ += Std.int(param1.height + this.gapV);
				_loc2_++;
			}
		}
	}

	// Box.as:569-574（gapV/gapH 与 Container 对称位互换，原文如此）
	private override function updateBackGround():Void {
		var _loc1_:Int = Std.int(Math.max(this._childrenWidth + this.paddingH * 2 - this.gapV, this._width
			- this._scrollW));
		var _loc2_:Int = Std.int(Math.max(this._childrenHeight + this.paddingV * 2 - this.gapH, this._height
			- this._scrollH));
		this.drawBackGround(_loc1_, _loc2_);
	}

	// Box.as:576-622
	private function TL(param1:DisplayObject):Void {
		var _loc2_:Int = 0;
		this.nextY = this.paddingV;
		this.nextX = this.paddingH;
		if (Direction.HORIZONTAL == this.direction) {
			this._childrenWidth += Std.int(param1.width + this.gapH);
			this._childrenHeight += Std.int(param1.height + this.gapV);
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (this.nextY < this.paddingV) {
				this.nextY = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.x = this.nextX;
				param1.y = this.nextY;
				this.nextX += Std.int(param1.width + this.gapH);
				_loc2_++;
			}
		} else {
			this._childrenHeight += Std.int(param1.height + this.gapV);
			if (this.nextX < this.paddingH) {
				this.nextX = this.paddingH;
			}
			if (this.nextY < this.paddingV) {
				this.nextY = this.paddingV;
			}
			while (_loc2_ < this.content.numChildren) {
				param1 = cast this._content.getChildAt(_loc2_);
				param1.y = this.nextY;
				param1.x = this.nextX;
				this.nextY += Std.int(param1.height + this.gapV);
				_loc2_++;
			}
		}
	}
}
