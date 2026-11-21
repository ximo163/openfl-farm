package com.qzone.qui.controls.scrollClasses;

import com.qzone.qui.controls.HScrollBar;
import com.qzone.qui.controls.UIComponent;
import com.qzone.qui.controls.VScrollBar;
import com.qzone.qui.core.Direction;
import com.qzone.qui.events.ScrollEvent;
import com.qzone.qui.styles.Style;
import com.qzone.qui.utils.EventUtil;
import com.qzone.utils.AlignUtil;
import openfl.display.DisplayObjectContainer;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import shim.As3;

/**
 * com.qzone.qui.controls.scrollClasses.ScrollBase —— ScrollBase.as 逐句对应
 * （issue #9 qui 子集片）。滚动容器基类：滚动条显隐策略（checkScrollBar）、
 * 视口 scrollRect 换算（updateScrollRect）、滚轮（_MOUSE_WHEEL）。
 * checkScrollBar 的 v-policy 块在原文出现两次（:256-281 与 :308-333，第二
 * 遍先跑 h-policy 后重跑 v-policy），照抄不改。
 */
class ScrollBase extends UIComponent {
	// ScrollBase.as:18-56
	private var _maxScrollPositionH:Float = 0;
	private var hScrollMode:String;
	private var _pageSizeH:Float = 0;
	private var _maxScrollPositionV:Float = 0;
	public var borderSizeH:Int;
	private var vScrollMode:String;
	private var _pageSizeV:Float = 0;
	public var borderSizeV:Int;
	public var vScrollBar:VScrollBar;
	private var _scrollPositionH:Float = 0;
	private var _scrollPositionV:Float = 0;
	private var _content:DisplayObjectContainer;
	public var paddingH:Int;
	private var _scrollH:Int;
	public var paddingV:Int;
	private var _hScrollPolicy:String = "auto";
	private var _scrollW:Int;
	private var _scrollRect:Rectangle;
	private var _vScrollPolicy:String = "auto";
	public var hScrollBar:HScrollBar;

	// ScrollBase.as:58-63
	public function new() {
		super();
		this._scrollRect = new Rectangle(0, 0, this._width - this._scrollW - this.borderSizeH * 2, this._height
			- this._scrollH - this.borderSizeV * 2);
	}

	// ScrollBase.as:64-71
	private var contentHeight(get, never):Float;

	private function get_contentHeight():Float {
		if (this._content.scrollRect != null) {
			return this._content.transform.pixelBounds.height;
		}
		return this._content.height;
	}

	// ScrollBase.as:73-103
	private override function setSize():Void {
		if (this.vScrollBar != null) {
			this.vScrollBar.height = this._height;
			this.vScrollBar.x = AlignUtil.right(this._width, this.vScrollBar.width);
			if (this.vScrollMode == ScrollBarMode.LINE) {
				this.vScrollBar.pageSize = this._pageSizeV;
			} else {
				this.vScrollBar.pageSize = this._height - this._scrollH;
			}
		}
		if (this.hScrollBar != null) {
			this.hScrollBar.width = this._width;
			this.hScrollBar.y = AlignUtil.right(this._height, this.hScrollBar.height);
			if (this.hScrollMode == ScrollBarMode.LINE) {
				this.hScrollBar.pageSize = this._pageSizeH;
			} else {
				this.hScrollBar.pageSize = this._width - this._scrollW;
			}
		}
		this.updateScrollRect();
		this.scrollBarChange();
	}

	// ScrollBase.as:105-108。PORT-NOTE: 原文只有 get content（ScrollBase.as:105），
	// 子类 Container 加 set content（Container.as:79）——Haxe 属性覆写不允许
	// (get,never)→(get,set) 扩 accessor，基类挂 no-op set 保 Container 的覆写
	// 形态；原版对 ScrollBase 形态写 content 编译不过，该路径无调用方，写值被
	// 丢弃不影响任何既有链路
	public var content(get, set):DisplayObjectContainer;

	private function get_content():DisplayObjectContainer {
		return this._content;
	}

	private function set_content(param1:DisplayObjectContainer):DisplayObjectContainer {
		return param1;
	}

	// ScrollBase.as:110-113
	private override function init():Void {
		super.init();
	}

	// ScrollBase.as:115-125
	private function showHScroll():Void {
		if (this.hScrollBar == null) {
			this.hScrollBar = new HScrollBar();
			this.hScrollBar.addEventListener(ScrollEvent.SCROLL, this._scroll);
			this.hScrollBar.scrollMode = this.hScrollMode;
			super.addChild(this.hScrollBar);
		}
		this.hScrollBar.visible = true;
	}

	// ScrollBase.as:127-130
	public var horizontalScrollPolicy(get, set):String;

	private function get_horizontalScrollPolicy():String {
		return this._hScrollPolicy;
	}

	// ScrollBase.as:132-142
	private function showVScroll():Void {
		if (this.vScrollBar == null) {
			this.vScrollBar = new VScrollBar();
			this.vScrollBar.addEventListener(ScrollEvent.SCROLL, this._scroll);
			this.vScrollBar.scrollMode = this.vScrollMode;
			super.addChild(this.vScrollBar);
		}
		this.vScrollBar.visible = true;
	}

	// ScrollBase.as:144-158（AS3 int 位置的 -=：Number 差隐式截断回 int）
	private function _MOUSE_WHEEL(param1:MouseEvent):Void {
		if (As3.truthy(this._scrollW) || As3.truthy(this._scrollH)) {
			EventUtil.stopAll(param1);
		}
		if (As3.truthy(this.vScrollBar) && this.vScrollBar.visible) {
			this.vScrollBar.thumbPosition = this.vScrollBar.thumbPosition
				- Std.int(param1.delta * this.vScrollBar.pageScrollSize);
		} else if (As3.truthy(this.hScrollBar) && this.hScrollBar.visible) {
			this.hScrollBar.thumbPosition = this.hScrollBar.thumbPosition
				- Std.int(param1.delta * this.hScrollBar.pageScrollSize);
		}
	}

	// ScrollBase.as:160-206
	private function updateScrollBar():Void {
		this.checkScrollBar();
		if (this._content != null) {
			if (this._scrollW != 0) {
				this.showVScroll();
			} else if (this.vScrollBar != null) {
				this.vScrollBar.visible = false;
			}
			if (this._scrollH != 0) {
				this.showHScroll();
			} else if (this.hScrollBar != null) {
				this.hScrollBar.visible = false;
			}
			if (As3.truthy(this.vScrollBar) && As3.truthy(this._scrollRect)) {
				if (this.vScrollMode == ScrollBarMode.LINE) {
					this.vScrollBar.setScrollProperties(this._pageSizeV, this._scrollPositionV, this._maxScrollPositionV);
				} else {
					this.vScrollBar.setScrollProperties(this._height - this._scrollH, this._scrollRect.y,
						this.contentHeight);
				}
			}
			if (this.hScrollBar != null) {
				if (this.hScrollMode == ScrollBarMode.LINE) {
					this.hScrollBar.setScrollProperties(this._pageSizeH, this._scrollPositionH, this._maxScrollPositionH);
				} else {
					this.hScrollBar.setScrollProperties(this._width - this._scrollW, this._scrollRect.x,
						this.contentWidth);
				}
			}
			this.scrollBarChange();
			this.updateScrollRect();
		}
	}

	// ScrollBase.as:208-211
	private function set_horizontalScrollPolicy(param1:String):String {
		this._hScrollPolicy = param1;
		return param1;
	}

	// ScrollBase.as:213-220
	private var contentWidth(get, never):Float;

	private function get_contentWidth():Float {
		if (this._content.scrollRect != null) {
			return this._content.transform.pixelBounds.width;
		}
		return this._content.width;
	}

	// ScrollBase.as:222-250
	private function scrollBarChange():Void {
		if (As3.truthy(this.hScrollBar != null && this.hScrollBar.visible) && As3.truthy(this.vScrollBar)
			&& this.vScrollBar.visible) {
			this.hScrollBar.width = this._width - this.vScrollBar.width;
			this.vScrollBar.height = this._height - this.hScrollBar.height;
		} else if (As3.truthy(this.vScrollBar) && As3.truthy(this.hScrollBar) && this.hScrollBar.visible) {
			this.hScrollBar.width = this._width;
			this.vScrollBar.height = this._height - this.hScrollBar.height;
		} else if (As3.truthy(this.hScrollBar) && As3.truthy(this.vScrollBar) && this.vScrollBar.visible) {
			this.hScrollBar.width = this._width - this.vScrollBar.width;
			this.vScrollBar.height = this._height;
		} else {
			if (this.hScrollBar != null) {
				this.hScrollBar.width = this._width;
			}
			if (this.vScrollBar != null) {
				this.vScrollBar.height = this._height;
			}
		}
	}

	// ScrollBase.as:252-335（v-policy 块原文跑两遍——:256-281 与 h-policy
	// :282-307 之后的 :308-333——第二遍把 h 判定的 _scrollH 影响再吃进
	// v 判定；照抄不改）
	private function checkScrollBar():Void {
		if (this._content != null) {
			if (this._vScrollPolicy == ScrollPolicy.AUTO) {
				if (this.vScrollMode == ScrollBarMode.LINE) {
					if (this._maxScrollPositionV > this._pageSizeV) {
						this._scrollW = Style.vScrollBarWidth;
					} else {
						this._scrollW = 0;
					}
				} else if (this.contentHeight > this._height - this._scrollH) {
					this._scrollW = Style.vScrollBarWidth;
				} else {
					this._scrollW = 0;
				}
			} else if (this._vScrollPolicy == ScrollPolicy.ON) {
				this._scrollW = Style.vScrollBarWidth;
			}
			if (this._hScrollPolicy == ScrollPolicy.AUTO) {
				if (this.hScrollMode == ScrollBarMode.LINE) {
					if (this._maxScrollPositionH > this._pageSizeH) {
						this._scrollH = Style.hScrollBarHeight;
					} else {
						this._scrollH = 0;
					}
				} else if (this.contentWidth > this._width - this._scrollW) {
					this._scrollH = Style.hScrollBarHeight;
				} else {
					this._scrollH = 0;
				}
			} else if (this._hScrollPolicy == ScrollPolicy.ON) {
				this._scrollH = Style.hScrollBarHeight;
			}
			if (this._vScrollPolicy == ScrollPolicy.AUTO) {
				if (this.vScrollMode == ScrollBarMode.LINE) {
					if (this._maxScrollPositionV > this._pageSizeV) {
						this._scrollW = Style.vScrollBarWidth;
					} else {
						this._scrollW = 0;
					}
				} else if (this.contentHeight > this._height - this._scrollH) {
					this._scrollW = Style.vScrollBarWidth;
				} else {
					this._scrollW = 0;
				}
			} else if (this._vScrollPolicy == ScrollPolicy.ON) {
				this._scrollW = Style.vScrollBarWidth;
			}
		}
	}

	// ScrollBase.as:337-339（空实现，子类覆写）
	private function onScrollChange(param1:ScrollEvent):Void {}

	// ScrollBase.as:341-344
	public var verticalScrollPolicy(get, set):String;

	private function set_verticalScrollPolicy(param1:String):String {
		this._vScrollPolicy = param1;
		return param1;
	}

	// ScrollBase.as:346-372
	private function _scroll(param1:ScrollEvent):Void {
		if (param1.direction == Direction.VERTICAL) {
			if (this.vScrollMode == ScrollBarMode.LINE) {
				this._scrollPositionV = param1.position;
			} else {
				this._scrollRect.y = param1.position;
			}
		} else if (param1.direction == Direction.HORIZONTAL) {
			if (this.hScrollMode == ScrollBarMode.LINE) {
				this._scrollPositionH = param1.position;
			} else {
				this._scrollRect.x = param1.position;
			}
		}
		this._content.scrollRect = this._scrollRect;
		this.onScrollChange(param1);
	}

	// ScrollBase.as:374-377
	private function get_verticalScrollPolicy():String {
		return this._vScrollPolicy;
	}

	// ScrollBase.as:379-382
	private function addEvent():Void {
		this.addEventListener(MouseEvent.MOUSE_WHEEL, this._MOUSE_WHEEL);
	}

	// ScrollBase.as:384-424
	private function updateScrollRect():Void {
		if (this._scrollRect != null) {
			this._scrollRect = this._scrollRect.clone();
			if (this.vScrollMode == ScrollBarMode.LINE) {
				if (this._scrollW > 0) {
					this._scrollRect.width = this._width - this._scrollW;
				} else {
					this._scrollRect.width = this._width - this.borderSizeH;
				}
			} else {
				this._scrollRect.width = this._width - this._scrollW - this.borderSizeH * 2;
			}
			if (this.hScrollMode == ScrollBarMode.LINE) {
				if (this._scrollH > 0) {
					this._scrollRect.height = this._height - this._scrollH;
				} else {
					this._scrollRect.height = this._height - this.borderSizeV;
				}
			} else {
				this._scrollRect.height = this._height - this._scrollH - this.borderSizeV * 2;
			}
		}
		if (this._content != null) {
			this._content.scrollRect = this._scrollRect;
		}
	}

	// ScrollBase.as:426-429
	private function removeEvent():Void {
		this.removeEventListener(MouseEvent.MOUSE_WHEEL, this._MOUSE_WHEEL);
	}

	// ScrollBase.as:431-445
	private override function setEnabled():Void {
		if (false == this._enabled) {
			this.removeEvent();
			this.filters = cast Style.getDisableFilter();
			this.mouseChildren = false;
		} else {
			this.addEvent();
			this.filters = cast Style.getRollOutFilter();
			this.mouseChildren = true;
		}
	}
}
