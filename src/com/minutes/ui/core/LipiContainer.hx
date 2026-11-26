package com.minutes.ui.core;

import com.minutes.ui.constant.ScrollBarDirection;
import com.minutes.ui.constant.ScrollPolicy;
import com.minutes.ui.control.LipiScrollBar;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

/**
 * com.minutes.ui.core.LipiContainer —— LipiContainer.as 逐句对应
 * （issue #86 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/core/LipiContainer.as。
 *
 * 文件尾的 ScrollBarSkin 内部类（LipiContainer.as:568-586）按仓内先例
 * 放同文件模块子类型（LoadManager.hx 的 LoadItem 同款，见该文件尾注释）。
 *
 * PORT-NOTE(qq-outlet)（scrollOver/scrollOut，LipiContainer.as:361-371/384-394）：
 * 原版的 ExternalInterface.call("isRoll", true/false) 是通知 QZone 宿主页面
 * 禁用/恢复页面级滚动——宿主集成出口，按本仓统一决策落 shim.QQOutlets.call
 * （deviations no-qzone-jsapi；独立部署无宿主页面）。原文本有 try/catch
 * 吞错，QQOutlets 不抛、两分支语义兼容。
 * PORT-NOTE（addChild/addChildAt/removeChild/removeChildAt/getChildAt/
 * getChildByName/getChildIndex/numChildren 重定向）：原版把这族显示列表
 * 接口全部改写到 _contentPane——外部 addChild 进的子件不进自身显示列表
 * 而是进内容区（遮罩/滚动统一作用）。Haxe 覆写同名 override，语义逐字。
 */
@:keep
class LipiContainer extends LipiUIComponent {
	// LipiContainer.as:14-48
	private var _vBarWidth:Int = 17;
	private var _sSkin:ScrollBarSkin;
	private var _horizontalScrollPolicyChange:Bool = false;
	private var _clipContentChange:Bool = false;
	private var _verticalScrollPolicyChange:Bool = false;
	private var _sizeChange:Bool = false;
	public var verticalScrollBar:LipiScrollBar;
	private var _contentPane:Sprite = null;
	public var horizontalScrollBar:LipiScrollBar;
	private var _clipContent:Bool = true;
	private var _mask:Sprite = new Sprite();
	private var _hBarWidthChange:Bool = false;
	private var _horizontalScrollPolicy:Int = 2;
	private var _verticalScrollPolicy:Int = 2;
	private var _vBarWidthChange:Bool = false;
	private var childChange:Bool = false;
	private var _contentPaneSizeChange:Bool = false;
	private var _hBarWidth:Int = 17;

	// :50-54
	public function new() {
		super();
		this.init();
	}

	// :56-59
	public var contentPane(get, never):Sprite;

	private function get_contentPane():Sprite {
		return this._contentPane;
	}

	// :61-68
	public override function getChildByName(param1:String):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		return this._contentPane.getChildByName(param1);
	}

	// :70-73
	public var vBarWidth(get, set):Int;

	private function get_vBarWidth():Int {
		return this._vBarWidth;
	}

	// :75-82
	public override function getChildIndex(param1:DisplayObject):Int {
		if (this._contentPane == null) {
			return -1;
		}
		return this._contentPane.getChildIndex(param1);
	}

	// :84-138（:117 的 `if(this._sSkin.barIcon != null)` 门内赋 trackSkin
	// ——原版缺陷（应为 trackSkin != null 的门），逐字保留）
	private function _setBarSkin():Void {
		if (this._sSkin == null) {
			return;
		}
		if (this.verticalScrollBar != null) {
			if (this._sSkin.trackSkin != null) {
				this.verticalScrollBar.trackSkin = this._sSkin.trackSkin;
			}
			if (this._sSkin.upSkin != null) {
				this.verticalScrollBar.upSkin = this._sSkin.upSkin;
			}
			if (this._sSkin.downSkin != null) {
				this.verticalScrollBar.downSkin = this._sSkin.downSkin;
			}
			if (this._sSkin.barSkin != null) {
				this.verticalScrollBar.barSkin = this._sSkin.barSkin;
			}
			if (this._sSkin.barIcon != null) {
				this.verticalScrollBar.barIcon = this._sSkin.barIcon;
			}
			this.verticalScrollBar.updateSkin();
		}
		if (this.horizontalScrollBar != null) {
			if (this._sSkin.barIcon != null) {
				this.horizontalScrollBar.trackSkin = this._sSkin.trackSkin;
			}
			if (this._sSkin.upSkin != null) {
				this.horizontalScrollBar.upSkin = this._sSkin.upSkin;
			}
			if (this._sSkin.downSkin != null) {
				this.horizontalScrollBar.downSkin = this._sSkin.downSkin;
			}
			if (this._sSkin.barSkin != null) {
				this.horizontalScrollBar.barSkin = this._sSkin.barSkin;
			}
			if (this._sSkin.barIcon != null) {
				this.horizontalScrollBar.barIcon = this._sSkin.barIcon;
			}
			this.horizontalScrollBar.updateSkin();
		}
	}

	// :140-150
	public override function addChildAt(param1:DisplayObject, param2:Int):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		this._contentPane.addChildAt(param1, param2);
		this._contentPaneSizeChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :152-161
	private function addVerticalScrollBar():Void {
		this.verticalScrollBar = new LipiScrollBar();
		this.verticalScrollBar.addEventListener(LipiScrollBar.SCROLL, this.verticalScroll);
		this.verticalScrollBar.visible = false;
		this.verticalScrollBar.container = this;
		this.verticalScrollBar.updateSkin();
		super.addChild(this.verticalScrollBar);
		this._setBarSkin();
	}

	// :163-186
	private function init():Void {
		this._contentPane = new Sprite();
		this._contentPane.x = 0;
		this._contentPane.y = 0;
		super.addChild(this._contentPane);
		this._mask = new Sprite();
		this._mask.x = 0;
		this._mask.y = 0;
		super.addChild(this._mask);
		this._contentPane.mask = this._mask;
		this._clipContentChange = true;
		this._verticalScrollPolicyChange = true;
		this._horizontalScrollPolicyChange = true;
		this._contentPaneSizeChange = true;
		this._sizeChange = true;
		invalidateDisplayList();
		addEventListener(UIEvent.RESIZE, this.onResize);
		addEventListener(MouseEvent.MOUSE_WHEEL, this.mouseWheelHandler);
		this.graphics.beginFill(0, 0.5);
		this.graphics.drawRect(0, 0, this.width, this.height);
		addEventListener(MouseEvent.MOUSE_OVER, this.scrollOver);
		addEventListener(MouseEvent.MOUSE_OUT, this.scrollOut);
	}

	// :188-193
	private function set_vBarWidth(param1:Int):Int {
		this._vBarWidth = param1;
		this._vBarWidthChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :195-202
	public var verticalScrollVisible(get, never):Bool;

	private function get_verticalScrollVisible():Bool {
		if (this.verticalScrollBar == null) {
			return false;
		}
		return this.verticalScrollBar.visible;
	}

	// :204-207（`Number(param1.data)`——data 是滚动比例浮点，Dynamic 经
	// As3.floatOf 等价转 Number）
	private function horizontalScroll(param1:UIEvent):Void {
		this._contentPane.x = shim.As3.floatOf(param1.data) * this._contentPane.width * -1;
	}

	// :209-216
	public var horizontalScrollVisible(get, never):Bool;

	private function get_horizontalScrollVisible():Bool {
		if (this.horizontalScrollBar == null) {
			return false;
		}
		return this.horizontalScrollBar.visible;
	}

	// :218-221
	public var horizontalScrollPolicy(get, set):Int;

	private function get_horizontalScrollPolicy():Int {
		return this._horizontalScrollPolicy;
	}

	// :223-226
	public override function get_numChildren():Int {
		return this._contentPane.numChildren;
	}

	// :228-233
	public var clipContent(get, set):Bool;

	private function set_clipContent(param1:Bool):Bool {
		this._clipContent = param1;
		this._clipContentChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :235-242
	public var vScrollPosition(get, set):Float;

	private function get_vScrollPosition():Float {
		if (this.verticalScrollBar != null) {
			return this.verticalScrollBar.scrollPosition;
		}
		return 0;
	}

	// :244-322
	private function resizeScrollBar():Void {
		if (this.verticalScrollPolicy == ScrollPolicy.OFF || this._clipContent == false) {
			if (this.verticalScrollBar != null) {
				this.verticalScrollBar.visible = false;
			}
		} else if (this.verticalScrollPolicy == ScrollPolicy.AUTO && this.height >= this._contentPane.height) {
			if (this.verticalScrollBar != null) {
				this.verticalScrollBar.visible = false;
			}
		} else {
			if (this.verticalScrollBar == null) {
				this.addVerticalScrollBar();
			}
			this.verticalScrollBar.visible = true;
			this.verticalScrollBar.width = this._vBarWidth;
			this.verticalScrollBar.x = this.width - this.verticalScrollBar.width;
			this.verticalScrollBar.y = 0;
			this.verticalScrollBar.visibleHeight = this.height;
			this.verticalScrollBar.pageHeight = this._contentPane.height;
		}
		if (this.horizontalScrollPolicy == ScrollPolicy.OFF || this._clipContent == false) {
			if (this.horizontalScrollBar != null) {
				this.horizontalScrollBar.visible = false;
			}
		} else if (this.horizontalScrollPolicy == ScrollPolicy.AUTO && this.width >= this._contentPane.width) {
			if (this.horizontalScrollBar != null) {
				this.horizontalScrollBar.visible = false;
			}
		} else {
			if (this.horizontalScrollBar == null) {
				this.addHorizontalScrollBar();
			}
			this.horizontalScrollBar.visible = true;
			this.horizontalScrollBar.width = this._hBarWidth;
			this.horizontalScrollBar.x = 0;
			this.horizontalScrollBar.y = this.height;
			this.horizontalScrollBar.visibleHeight = this.width;
			this.horizontalScrollBar.pageHeight = this._contentPane.width;
		}
		if (this.horizontalScrollBar != null && this.horizontalScrollBar.visible == true) {
			if (this.verticalScrollBar != null) {
				this.verticalScrollBar.height = this.height - this.verticalScrollBar.width;
			}
		} else if (this.verticalScrollBar != null) {
			this.verticalScrollBar.height = this.height;
		}
		if (this.verticalScrollBar != null && this.verticalScrollBar.visible == true) {
			if (this.horizontalScrollBar != null) {
				this.horizontalScrollBar.height = this.width - this.horizontalScrollBar.width;
			}
		} else if (this.horizontalScrollBar != null) {
			this.horizontalScrollBar.height = this.width;
		}
	}

	// :324-327
	private function get_clipContent():Bool {
		return this._clipContent;
	}

	// :329-334（:332 原文即 `_vBarWidthChange = true`——hBar 宽度改动
	// 误置 vBar 标志位，原版缺陷逐字保留；updateDisplayList 里两标志
	// 是 || 关系，行为等价）
	public function setHBarWidth(param1:Int):Void {
		this._hBarWidth = param1;
		this._vBarWidthChange = true;
		invalidateDisplayList();
	}

	// :336-350
	private function mouseWheelHandler(param1:MouseEvent):Void {
		if (this.verticalScrollBar == null || this.verticalScrollBar.visible == false) {
			return;
		}
		if (param1.delta > 0) {
			this.verticalScrollBar.rollUp();
		} else {
			this.verticalScrollBar.rollDown();
		}
	}

	// :352-359
	public override function getChildAt(param1:Int):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		return this._contentPane.getChildAt(param1);
	}

	// :361-371（ExternalInterface → QQOutlets，见类头 PORT-NOTE）
	private function scrollOut(param1:MouseEvent):Void {
		var e:MouseEvent = param1;
		try {
			shim.QQOutlets.call("isRoll", true);
		} catch (e2:Dynamic) {}
	}

	// :373-382
	private function set_horizontalScrollPolicy(param1:Int):Int {
		if (param1 > 3 || param1 < 0) {
			param1 = 3;
		}
		this._horizontalScrollPolicy = param1;
		this._horizontalScrollPolicyChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :384-394
	private function scrollOver(param1:MouseEvent):Void {
		var e:MouseEvent = param1;
		try {
			shim.QQOutlets.call("isRoll", false);
		} catch (e2:Dynamic) {}
	}

	// :396-406
	public override function removeChildAt(param1:Int):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		var _loc2_:DisplayObject = this._contentPane.removeChildAt(param1);
		this._contentPaneSizeChange = true;
		invalidateDisplayList();
		return _loc2_;
	}

	// :408-414
	private function set_vScrollPosition(param1:Float):Float {
		if (this.verticalScrollBar != null) {
			this.verticalScrollBar.scrollPosition = param1;
		}
		return param1;
	}

	// :416-425
	private function addHorizontalScrollBar():Void {
		this.horizontalScrollBar = new LipiScrollBar();
		this.horizontalScrollBar.direction = ScrollBarDirection.HORIZONTAL;
		this.horizontalScrollBar.addEventListener(LipiScrollBar.SCROLL, this.horizontalScroll);
		this.horizontalScrollBar.visible = false;
		this.horizontalScrollBar.container = this;
		super.addChild(this.horizontalScrollBar);
		this._setBarSkin();
	}

	// :427-430
	private function verticalScroll(param1:UIEvent):Void {
		this._contentPane.y = shim.As3.floatOf(param1.data) * this._contentPane.height * -1;
	}

	// :432-441
	public var verticalScrollPolicy(get, set):Int;

	private function set_verticalScrollPolicy(param1:Int):Int {
		if (param1 > 3 || param1 < 0) {
			param1 = 3;
		}
		this._verticalScrollPolicy = param1;
		this._verticalScrollPolicyChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :443-455
	public function setBarSkin(param1:Class<Dynamic>, param2:Class<Dynamic>, param3:Class<Dynamic>, param4:Class<Dynamic>,
			param5:Class<Dynamic> = null):Void {
		if (this._sSkin == null) {
			this._sSkin = new ScrollBarSkin();
		}
		this._sSkin.trackSkin = param1;
		this._sSkin.upSkin = param2;
		this._sSkin.downSkin = param3;
		this._sSkin.barSkin = param4;
		this._sSkin.barIcon = param5;
		this._setBarSkin();
	}

	// :457-461
	public function resetSize():Void {
		this._contentPaneSizeChange = true;
		invalidateDisplayList();
	}

	// :463-466
	private function get_verticalScrollPolicy():Int {
		return this._verticalScrollPolicy;
	}

	// :468-520
	private override function updateDisplayList(param1:Float, param2:Float):Void {
		var _loc3_:Bool = false;
		if (this._clipContentChange == true) {
			if (this._clipContent == true) {
				this._mask.visible = true;
				this._contentPane.mask = this._mask;
			} else {
				this._mask.visible = false;
				this._contentPane.mask = null;
			}
			_loc3_ = true;
		}
		if (this._verticalScrollPolicyChange == true) {
			_loc3_ = true;
		} else if (this._horizontalScrollPolicyChange == true) {
			_loc3_ = true;
		} else if (this._contentPaneSizeChange == true) {
			_loc3_ = true;
		}
		if (this._sizeChange == true) {
			this._mask.graphics.clear();
			this._mask.graphics.beginFill(0);
			this._mask.graphics.drawRect(0, 0, width, height);
			_loc3_ = true;
		}
		if (this._vBarWidthChange || this._hBarWidthChange) {
			_loc3_ = true;
			this._vBarWidthChange = false;
			this._hBarWidthChange = false;
		}
		if (_loc3_ == true) {
			this.resizeScrollBar();
		}
		this._clipContentChange = false;
		this._verticalScrollPolicyChange = false;
		this._horizontalScrollPolicyChange = false;
		this._contentPaneSizeChange = false;
		this._sizeChange = false;
		super.updateDisplayList(param1, param2);
	}

	// :522-526
	private function onResize(param1:UIEvent):Void {
		this._sizeChange = true;
		invalidateDisplayList();
	}

	// :528-538
	public override function addChild(param1:DisplayObject):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		this._contentPane.addChild(param1);
		this._contentPaneSizeChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :540-552
	public function removeAll():Void {
		if (this._contentPane == null) {
			return;
		}
		while (this._contentPane.numChildren > 0) {
			this._contentPane.removeChildAt(0);
		}
		this._contentPaneSizeChange = true;
		invalidateDisplayList();
	}

	// :554-564
	public override function removeChild(param1:DisplayObject):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		this._contentPane.removeChild(param1);
		this._contentPaneSizeChange = true;
		invalidateDisplayList();
		return param1;
	}
}

// LipiContainer.as:568-586：AS3 与 LipiContainer 同文件的无修饰类（文件级
// internal）。Haxe 里保持同文件；不加 private——private 会把可见性锁死在本
// 模块内（LoadManager.hx 的 LoadItem 同款先例）。
class ScrollBarSkin {
	// :571-579
	public var barSkin:Class<Dynamic>;
	public var downSkin:Class<Dynamic>;
	public var trackSkin:Class<Dynamic>;
	public var barIcon:Class<Dynamic>;
	public var upSkin:Class<Dynamic>;

	// :581-584
	public function new() {}
}
