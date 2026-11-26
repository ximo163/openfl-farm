package com.minutes.ui.control;

import com.minutes.ui.constant.ScrollBarDirection;
import com.minutes.ui.core.LipiContainer;
import com.minutes.ui.core.LipiSkin;
import com.minutes.ui.core.LipiUIComponent;
import com.minutes.ui.core.UIEvent;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.geom.Rectangle;
import openfl.utils.Timer;

/**
 * com.minutes.ui.control.LipiScrollBar —— LipiScrollBar.as 逐句对应
 * （issue #86 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/control/LipiScrollBar.as。
 *
 * 文件尾的 ThumbBar 内部类（LipiScrollBar.as:513-560）按仓内先例放同文件
 * 模块子类型（LoadManager.hx 的 LoadItem / LipiContainer.hx 的 ScrollBarSkin
 * 同款）。
 *
 * PORT-NOTE（maxScrollPosition/scrollPosition 的 Number→int 截断）：
 * get maxScrollPosition（LipiScrollBar.as:212-215）返 int 但算式全是
 * Number——AS3 隐式 ToInt32 截断（向零），Haxe 经 shim.As3.intOf 等价
 * （NaN→0）。scrollPosition 的 set/get 是 Number 通道，不截。
 * PORT-NOTE（`this.scrollPosition -= x` / `+= x`，:319/:332/:363/:459）：
 * AS3 属性读写复合——先 get 再 set，getter 返 Number，Haxe 显式拆开写
 * （读 scrollPosition 再赋回）。thumbBarEnterFrame 的
 * `this.scrollPosition = this.scrollPosition`（:257）自赋值照抄——靠
 * setter 的派发副作用拖滚动内容。
 * PORT-NOTE（updateDisplayList 尾部，:139-143）：五个 change 标志全置
 * true（不是 false——每次重绘后仍标脏，下一帧再跑一遍全部分支）。原版
 * 缺陷/特性逐字保留。
 * PORT-NOTE(shadow)（_widthChange/_heightChange → m_widthChange/
 * m_heightChange）：基类 LipiUIComponent 已声明同名 private 槽
 * （LipiUIComponent.as:17/19）——AS3 private 不进子类作用域，两对槽
 * 互不相干（基类 updateDisplayList 管基类对、本类管本类对）；Haxe
 * private 子类可见、同名重定义直接红，按 lessons #21「同名遮蔽拆槽」
 * 先例改名 m_ 前缀，读写点与原文一一对应。
 */
@:keep
class LipiScrollBar extends LipiUIComponent {
	// LipiScrollBar.as:18
	public static final SCROLL:String = "scrollEvent";

	// :20-68
	private var _container:LipiContainer;
	private var _upButton:LipiUIComponent;
	private var _direction:String = ScrollBarDirection.VERTICAL;
	private var _downButton:LipiUIComponent;
	private var _trackBarTimer2:Timer;
	private var m_heightChange:Bool = false;
	private var _downSkin:Class<Dynamic>;
	private var _trackBarTimer1:Timer;
	private var _trackBar:LipiUIComponent;
	private var _buttonHeightChange:Bool = false;
	private var _thumbBar:ThumbBar;
	private var _visibleHeight:Float = 0;
	private var _pageHeight:Float = 0;
	private var timer:Timer = new Timer(250);
	private var oldHeight:Float;
	private var _pageHeightChange:Bool = false;
	private var m_widthChange:Bool = false;
	private var _upSkin:Class<Dynamic>;
	private var oldWidth:Float;
	private var _trackSkin:Class<Dynamic>;
	private var _barIcon:Class<Dynamic>;
	private var _barSkin:Class<Dynamic>;
	private var _thumbIcon:Sprite;
	private var _buttonHeight:Float = 12;
	private var _visibleHeightChange:Bool = false;

	// :70-74
	public function new() {
		super();
		this.init();
	}

	// :76-79
	public var buttonHeight(get, set):Float;

	private function get_buttonHeight():Float {
		return this._buttonHeight;
	}

	// :81-86
	public var visibleHeight(get, set):Float;

	private function set_visibleHeight(param1:Float):Float {
		this._visibleHeight = param1;
		this._visibleHeightChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :88-93
	private function thumbBarMouseUp(param1:MouseEvent):Void {
		this._thumbBar.stopDrag();
		stage.removeEventListener(MouseEvent.MOUSE_UP, this.thumbBarMouseUp);
		removeEventListener(Event.ENTER_FRAME, this.thumbBarEnterFrame);
	}

	// :95-106
	public var direction(get, set):String;

	private function set_direction(param1:String):String {
		this._direction = param1;
		if (param1 == ScrollBarDirection.VERTICAL) {
			rotation = 0;
		} else {
			rotation = 270;
		}
		return param1;
	}

	// :108-144（尾部五标志置 true 见类头 PORT-NOTE；`this.pageHeight =`
	// 走 setter 递归 invalidateDisplayList，原版如此）
	private override function updateDisplayList(param1:Float, param2:Float):Void {
		super.updateDisplayList(param1, param2);
		if (this.m_widthChange) {
			this._downButton.width = this.width;
			this._upButton.width = this.width;
			this._trackBar.width = this.width;
			this._thumbBar.width = this.width;
		}
		if (this.m_heightChange) {
			this._downButton.y = this.height - this._downButton.height;
			this._trackBar.height = this.height;
		}
		if (this._buttonHeightChange) {
			this._upButton.height = this._buttonHeight;
			this._downButton.height = this._buttonHeight;
		}
		if (this._pageHeightChange || this._visibleHeightChange) {
			if (this.pageHeight != 0) {
				if (this.pageHeight < this.visibleHeight) {
					this.pageHeight = this.visibleHeight;
				}
				this._thumbBar.height = this.visibleHeight / this.pageHeight * (this.height - this._upButton.height - this._downButton.height);
			}
		}
		this._pageHeightChange = true;
		this._visibleHeightChange = true;
		this._buttonHeightChange = true;
		this.m_widthChange = true;
		this.m_heightChange = true;
	}

	// :146-149
	public function rollUp():Void {
		this.upButtonClick();
	}

	// :151-154
	public var container(get, set):LipiContainer;

	private function get_container():LipiContainer {
		return this._container;
	}

	// :156-160
	private function set_container(param1:LipiContainer):LipiContainer {
		this._container = param1;
		this.height = param1.height;
		return param1;
	}

	// :162-165
	private function trackBarClickHandler(param1:MouseEvent):Void {
		this.trackBarMouseHandler();
	}

	// :167-170
	private function get_direction():String {
		return this._direction;
	}

	// :172-190
	private function init():Void {
		this.timer.start();
		this.oldWidth = this.width;
		this.oldHeight = this.height;
		this.bgAlpha = 0;
		this.width = 17;
		addEventListener(UIEvent.RESIZE, this.resizeHandler);
		this._barSkin = LipiScrollBarSkin.BarSkin;
		this._barIcon = LipiScrollBarSkin.BarIcon;
		this._upSkin = LipiScrollBarSkin.UpSkin;
		this._downSkin = LipiScrollBarSkin.DownSkin;
		this._trackSkin = LipiScrollBarSkin.TrackSkin;
		this.createTrackBar();
		this.createUpButton();
		this.createDownButton();
		this.createThumbBar();
		this.updateSkin();
	}

	// :192-198
	private function thumbBarMouseDown(param1:MouseEvent):Void {
		var _loc2_:Float = Math.ceil(this.height - this._thumbBar.height - this._downButton.height - this._upButton.height);
		this._thumbBar.startDrag(false, new Rectangle(0, this._upButton.height, 0, _loc2_));
		stage.addEventListener(MouseEvent.MOUSE_UP, this.thumbBarMouseUp);
		addEventListener(Event.ENTER_FRAME, this.thumbBarEnterFrame);
	}

	// :200-210
	private function createDownButton():Void {
		this._downButton = new LipiUIComponent();
		this._downButton.addEventListener(MouseEvent.CLICK, this.downButtonClick);
		this._downButton.addEventListener(MouseEvent.MOUSE_DOWN, this.downButtonMouseDown);
		this._downButton.width = this.width;
		this._downButton.height = this.buttonHeight;
		this._downButton.x = 0;
		this._downButton.y = this.height - this._downButton.height;
		addChild(this._downButton);
	}

	// :212-215（Number→int 截断见类头 PORT-NOTE）
	public var maxScrollPosition(get, never):Int;

	private function get_maxScrollPosition():Int {
		return shim.As3.intOf(this.height - this._downButton.height - this._thumbBar.height - this._upButton.height);
	}

	// :217-220
	private function downButtonMouseUp(param1:Event):Void {
		this.timer.removeEventListener(TimerEvent.TIMER, this.downButtonTimer);
	}

	// :222-225
	public var scrollPosition(get, set):Float;

	private function get_scrollPosition():Float {
		return this._thumbBar.y - this._upButton.height;
	}

	// :227-230
	private function upButtonTimer(param1:TimerEvent):Void {
		this.upButtonClick();
	}

	// :232-235
	public var pageHeight(get, set):Float;

	private function get_pageHeight():Float {
		return this._pageHeight;
	}

	// :237-242
	private function set_buttonHeight(param1:Float):Float {
		this._buttonHeight = param1;
		this._buttonHeightChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :244-248
	public function enforceScrollPosition(param1:Float):Void {
		var _loc2_:Float = param1 * (this.height - this._upButton.height - this._downButton.height);
		this._thumbBar.y = _loc2_ + this._upButton.height;
	}

	// :250-253
	private function downButtonTimer(param1:TimerEvent):Void {
		this.downButtonClick();
	}

	// :255-258（自赋值见类头 PORT-NOTE）
	private function thumbBarEnterFrame(param1:Event):Void {
		this.scrollPosition = this.scrollPosition;
	}

	// :260-263
	private function get_visibleHeight():Float {
		return this._visibleHeight;
	}

	// :265-269
	private function upButtonMouseDown(param1:MouseEvent):Void {
		stage.addEventListener(MouseEvent.MOUSE_UP, this.upButtonMouseUp);
		this.timer.addEventListener(TimerEvent.TIMER, this.upButtonTimer);
	}

	// :271-277（`param1 / (…)`——Number 除法得比例进 data，container 端
	// 乘 contentPane 高还原像素）
	private function set_scrollPosition(param1:Float):Float {
		this._thumbBar.y = param1 + this._upButton.height;
		var _loc2_:UIEvent = new UIEvent(LipiScrollBar.SCROLL);
		_loc2_.data = param1 / (this.height - this._upButton.height - this._downButton.height);
		dispatchEvent(_loc2_);
		return param1;
	}

	// :279-284
	private function trackBarMouse(param1:Event = null):Void {
		this._trackBarTimer2 = new Timer(150);
		this._trackBarTimer2.addEventListener(TimerEvent.TIMER, this.trackBarMouseHandler);
		this._trackBarTimer2.start();
	}

	// :286-289
	public function rollDown():Void {
		this.downButtonClick();
	}

	// :291-294
	private function upButtonMouseUp(param1:Event):Void {
		this.timer.removeEventListener(TimerEvent.TIMER, this.upButtonTimer);
	}

	// :296-306
	private function createUpButton():Void {
		this._upButton = new LipiUIComponent();
		this._upButton.addEventListener(MouseEvent.CLICK, this.upButtonClick);
		this._upButton.addEventListener(MouseEvent.MOUSE_DOWN, this.upButtonMouseDown);
		this._upButton.width = this.width;
		this._upButton.height = this.buttonHeight;
		this._upButton.x = 0;
		this._upButton.y = 0;
		addChild(this._upButton);
	}

	// :308-334（`scrollPosition -=/+=` 读写复合见类头 PORT-NOTE）
	private function trackBarMouseHandler(param1:Event = null):Void {
		var _loc2_:Float = mouseY;
		if (_loc2_ > this._thumbBar.y && _loc2_ < this._thumbBar.y + this._thumbBar.height) {
			return;
		}
		if (_loc2_ < this._thumbBar.y) {
			if (this.scrollPosition - this._thumbBar.height > 0) {
				this.scrollPosition = this.scrollPosition - this._thumbBar.height;
			} else {
				this.scrollPosition = 0;
			}
		} else if (this.scrollPosition + this._thumbBar.height > this.height - this._downButton.height - this._thumbBar.height - this._upButton.height) {
			this.scrollPosition = this.height - this._downButton.height - this._thumbBar.height - this._upButton.height;
		} else {
			this.scrollPosition = this.scrollPosition + this._thumbBar.height;
		}
	}

	// :336-339
	public var trackSkin(never, set):Class<Dynamic>;

	private function set_trackSkin(param1:Class<Dynamic>):Class<Dynamic> {
		this._trackSkin = param1;
		return param1;
	}

	// :341-345
	private function downButtonMouseDown(param1:MouseEvent):Void {
		stage.addEventListener(MouseEvent.MOUSE_UP, this.downButtonMouseUp);
		this.timer.addEventListener(TimerEvent.TIMER, this.downButtonTimer);
	}

	// :347-350
	public var barIcon(never, set):Class<Dynamic>;

	private function set_barIcon(param1:Class<Dynamic>):Class<Dynamic> {
		this._barIcon = param1;
		return param1;
	}

	// :352-357
	private function set_pageHeight(param1:Float):Float {
		this._pageHeight = param1;
		this._pageHeightChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :359-369
	private function upButtonClick(param1:MouseEvent = null):Void {
		if (this._thumbBar.y - this._upButton.height - this._thumbBar.height / 10 > 0) {
			this.scrollPosition = this.scrollPosition - this._thumbBar.height / 10;
		} else {
			this.scrollPosition = 0;
		}
	}

	// :371-381
	private function createTrackBar():Void {
		this._trackBar = new LipiUIComponent();
		this._trackBar.addEventListener(MouseEvent.CLICK, this.trackBarClickHandler);
		this._trackBar.addEventListener(MouseEvent.MOUSE_DOWN, this.trackBarMouseDown);
		this._trackBar.width = this.width;
		this._trackBar.height = this.height;
		this._trackBar.x = 0;
		this._trackBar.y = 0;
		addChild(this._trackBar);
	}

	// :383-426
	public function updateSkin():Void {
		if (this._trackSkin == null) {
			this._trackBar.bgColor = 15658734;
			this._trackBar.bgAlpha = 0.5;
		} else {
			this._trackBar.bgAlpha = 0;
			this._trackBar.bgSkin = new LipiSkin(this._trackSkin);
		}
		if (this._upSkin == null) {
			this._upButton.bgColor = 10027008;
		} else {
			this._upButton.bgAlpha = 0;
			this._upButton.bgSkin = new LipiSkin(this._upSkin);
		}
		if (this._downSkin == null) {
			this._downButton.bgColor = 10027008;
		} else {
			this._downButton.bgAlpha = 0;
			this._downButton.bgSkin = new LipiSkin(this._downSkin);
		}
		if (this._barSkin == null) {
			this._thumbBar.bgColor = 16711680;
		} else {
			this._thumbBar.bgAlpha = 0;
			this._thumbBar.bgSkin = new LipiSkin(this._barSkin);
		}
		if (this._barIcon != null) {
			this._thumbBar.iconSkin = this._barIcon;
		}
	}

	// :428-431
	public var barSkin(never, set):Class<Dynamic>;

	private function set_barSkin(param1:Class<Dynamic>):Class<Dynamic> {
		this._barSkin = param1;
		return param1;
	}

	// :433-436
	public var upSkin(never, set):Class<Dynamic>;

	private function set_upSkin(param1:Class<Dynamic>):Class<Dynamic> {
		this._upSkin = param1;
		return param1;
	}

	// :438-453
	private function trackBarMouseUpHandler(param1:MouseEvent):Void {
		stage.removeEventListener(MouseEvent.MOUSE_UP, this.trackBarMouseUpHandler);
		if (this._trackBarTimer1 != null) {
			this._trackBarTimer1.removeEventListener(TimerEvent.TIMER, this.trackBarMouse);
			this._trackBarTimer1.stop();
			this._trackBarTimer1 = null;
		}
		if (this._trackBarTimer2 != null) {
			this._trackBarTimer2.removeEventListener(TimerEvent.TIMER, this.trackBarMouseHandler);
			this._trackBarTimer2.stop();
			this._trackBarTimer2 = null;
		}
	}

	// :455-465
	private function downButtonClick(param1:MouseEvent = null):Void {
		if (this._thumbBar.y + this._thumbBar.height / 10 < this.height - this._downButton.height - this._thumbBar.height) {
			this.scrollPosition = this.scrollPosition + this._thumbBar.height / 10;
		} else {
			this.scrollPosition = this.height - this._downButton.height - this._thumbBar.height - this._upButton.height;
		}
	}

	// :467-481
	private function resizeHandler(param1:UIEvent):Void {
		if (this.height != this.oldHeight) {
			this.m_heightChange = true;
			this.oldHeight = this.height;
			invalidateDisplayList();
		}
		if (this.width != this.oldWidth) {
			this.m_widthChange = true;
			this.oldWidth = this.width;
			invalidateDisplayList();
		}
	}

	// :483-492
	private function createThumbBar():Void {
		this._thumbBar = new ThumbBar();
		this._thumbBar.addEventListener(MouseEvent.MOUSE_DOWN, this.thumbBarMouseDown);
		this._thumbBar.width = this.width;
		this._thumbBar.height = this.height - this._upButton.height - this._downButton.height;
		this._thumbBar.x = 0;
		this._thumbBar.y = this._upButton.height;
		addChild(this._thumbBar);
	}

	// :494-497
	public var downSkin(never, set):Class<Dynamic>;

	private function set_downSkin(param1:Class<Dynamic>):Class<Dynamic> {
		this._downSkin = param1;
		return param1;
	}

	// :499-505
	private function trackBarMouseDown(param1:MouseEvent):Void {
		this._trackBarTimer1 = new Timer(300, 1);
		this._trackBarTimer1.addEventListener(TimerEvent.TIMER, this.trackBarMouse);
		this._trackBarTimer1.start();
		stage.addEventListener(MouseEvent.MOUSE_UP, this.trackBarMouseUpHandler);
	}
}

// LipiScrollBar.as:513-560：AS3 与 LipiScrollBar 同文件的无修饰类（文件级
// internal）。Haxe 里保持同文件；不加 private（LoadManager.hx 的 LoadItem
// 同款先例）。
//
// PORT-NOTE（iconSkin 的 `new param1()`，:550）：AS3 Class 实例化 →
// Type.createInstance；实例总是 Sprite 符号类（barIcon 皮肤），isOfType 门
// + 直取。
// PORT-NOTE（iconSkin setter 首分支，:541-545）：`param1 == null && iconButton
// != null` 时 removeChild+置 null 后**直接落进 else 分支**？——原文 if/else
// 结构：条件成立走 removeChild 分支，否则（含 param1==null && iconButton==null
// 的无效调用）走 else 重新 addChild。原版逻辑逐字保留（null Class 进 else 时
// `new param1()` 会抛——`iconButton == null` 守卫先行，null+null 态第一次
// 调用也在 `new param1()` 抛 TypeError，原版如此）。
class ThumbBar extends LipiUIComponent {
	// :516
	private var iconButton:Sprite;

	// :518-522
	public function new() {
		super();
		addEventListener(UIEvent.RESIZE, this.thumbBarResize);
	}

	// :524-537
	private function thumbBarResize(param1:UIEvent):Void {
		if (this.iconButton != null) {
			this.iconButton.width = this.width;
			this.iconButton.height = this.width;
			this.iconButton.x = 0;
			this.iconButton.y = (this.height - this.iconButton.height) / 2;
			if (this.height < this.width) {
				this.iconButton.visible = false;
			}
		}
	}

	// :539-559（原文 `trace(this.iconButton.x,this.iconButton.y)` 调试输出
	// 逐字保留）
	public var iconSkin(never, set):Class<Dynamic>;

	private function set_iconSkin(param1:Class<Dynamic>):Class<Dynamic> {
		if (param1 == null && this.iconButton != null) {
			removeChild(this.iconButton);
			this.iconButton = null;
		} else {
			if (this.iconButton == null) {
				var _loc2_:Dynamic = Type.createInstance(param1, []);
				this.iconButton = Std.isOfType(_loc2_, Sprite) ? cast(_loc2_, Sprite) : null;
			}
			this.iconButton.width = this.width;
			this.iconButton.height = this.width;
			this.iconButton.x = 0;
			this.iconButton.y = (this.height - this.iconButton.height) / 2;
			trace(this.iconButton.x, this.iconButton.y);
			addChild(this.iconButton);
		}
		return param1;
	}
}
