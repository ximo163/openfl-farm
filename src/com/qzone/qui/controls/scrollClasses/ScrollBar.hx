package com.qzone.qui.controls.scrollClasses;

import com.qzone.qui.controls.UIComponent;

/**
 * com.qzone.qui.controls.scrollClasses.ScrollBar —— 签名 stub（issue #9
 * qui 子集片；ScrollBar.as 423 loc > 100 且不在本片清单，滚动交互行为随
 * 后续模块翻译）。原版 extends UIComponent；HScrollBar/VScrollBar（本片）
 * 与 ScrollBase（本片）触碰的成员——皮肤类字段、_direction、位置/页大小
 * 的存取签名——逐字照抄；纯存取器直接落存储，拖拽/步进/换算体
 * （setSize/setSkin/setThumbSize/scrollChange 等）留空待译。
 */
@:keep
class ScrollBar extends UIComponent {
	// ScrollBar.as:20
	public static var updateAfterEvent:Bool;

	// ScrollBar.as:22-80（字段默认值照抄；Class → Class<Dynamic>）
	public var lineScrollSize:Int = 1;
	public var thumbIconSkin:Class<Dynamic>;
	public var repeatInterval:Int = 40;
	public var scrollMode:String = "pixel";
	public var repeatDelay:Int = 500;
	public var upArrowSkin:Class<Dynamic>;
	public var pageScrollSize:Float = 5;
	public var trackSkin:Class<Dynamic>;
	public var downArrowSkin:Class<Dynamic>;
	public var thumbSkin:Class<Dynamic>;

	// ScrollBar.as:42（HScrollBar/VScrollBar ctor 写入）
	private var _direction:String;

	// ScrollBar.as:82-85
	public function new() {
		super();
	}

	// ScrollBar.as:216-219 / :316-320（纯存储存取）
	public var pageSize(get, set):Float;

	private function get_pageSize():Float {
		return this._pageSize;
	}

	private function set_pageSize(param1:Float):Float {
		this._pageSize = param1;
		return param1;
	}

	private var _pageSize:Float = 1;

	// ScrollBar.as:164-167 / :263-267（maxScrollPosition 同为存储位）
	public var maxScrollPosition(get, set):Float;

	private function get_maxScrollPosition():Float {
		return this._maxScrollPosition;
	}

	private function set_maxScrollPosition(param1:Float):Float {
		this._maxScrollPosition = param1;
		return param1;
	}

	private var _maxScrollPosition:Float = 1;

	// ScrollBar.as:303-314（scrollPosition 存储）
	public var scrollPosition(get, set):Int;

	private function get_scrollPosition():Int {
		return this._scrollPosition;
	}

	private function set_scrollPosition(param1:Int):Int {
		this._scrollPosition = param1;
		return param1;
	}

	private var _scrollPosition:Int = 0;

	// ScrollBar.as:187-190 / :246-261（thumbPosition：滑块位置——滑块显示
	// 未接入，这里只存值；_MOUSE_WHEEL 的增减语义因此退化为赋值）
	public var thumbPosition(get, set):Int;

	private function get_thumbPosition():Int {
		return this._thumbPosition;
	}

	private function set_thumbPosition(param1:Int):Int {
		this._thumbPosition = param1;
		return param1;
	}

	private var _thumbPosition:Int = 0;

	// ScrollBar.as:336-343（setScrollProperties：三参写入，行为体待译）
	public function setScrollProperties(param1:Float, param2:Float, param3:Float):Void {
		this._pageSize = param1;
		this._scrollPosition = Std.int(param2);
		this._maxScrollPosition = param3;
	}

	// ScrollBar.as:418-421
	public var direction(get, never):String;

	private function get_direction():String {
		return this._direction;
	}
}
