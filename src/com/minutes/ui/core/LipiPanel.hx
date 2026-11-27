package com.minutes.ui.core;

import com.minutes.ui.control.LipiDefaultSkin;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 * com.minutes.ui.core.LipiPanel —— LipiPanel.as 逐句对应（issue #86 牧场库
 * 底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/core/LipiPanel.as。
 *
 * PORT-NOTE（titleIMG 属性形态）：AS3 原文只有 setter（LipiPanel.as:212），
 * 无 getter——Haxe 用 (never, set) 写-only 属性表达，赋值语法兼容（签名面
 * stub 期曾误加 getter；原文没有，按原文）。setter 形参 Class、背存字段
 * _titleIMG 是 DisplayObject（:31），实例化即 `new param1()`（Class 实例化
 * → Type.createInstance，CLAUDE.md 语言差异清单）。
 * PORT-NOTE（addChild/addChildAt/removeChild/removeChildAt/getChildAt/
 * getChildByName/getChildIndex/numChildren 重定向）：与 LipiContainer 同款，
 * 外部 addChild 进的子件投进 _contentPane 内容区（头部/关闭钮走 super
 * 通道留在自身）。
 * PORT-NOTE（`new param1()` 的显示对象性，:222）：AS3 `new param1()` 返
 * `*`，赋进 DisplayObject 字段隐式检查；实例总是符号类（MaterialLib 取
 * 出的 NoticeWindowTitle 等），isOfType 门 + 直取，失配 null 在 addChild
 * 上抛与原行为等价。
 * PORT-NOTE（closeVisible setter，:157-163）：原版 setter 里三行恒写
 * false（不看 param1——closeVisible=true 也照藏），原版缺陷逐字保留。
 * PORT-NOTE（dragDown 的 Rectangle 参数，:301）：`stage.stageWidth - this.mouseY`
 * 宽高参数里减的都是 mouseY（不是 stageWidth - mouseX），原版缺陷逐字保留。
 */
@:keep
class LipiPanel extends LipiUIComponent {
	// LipiPanel.as:15-49
	private var _dragBar:Sprite;
	private var _closeButton:LipiUIComponent;
	private var _closeHeight:Int = 18;
	private var _closeSkin:LipiSkin;
	private var _closeTop:Int = 5;
	private var _closeRight:Int = 7;
	private var _headHeightChange:Bool = false;
	private var _titleText:TextField;
	private var _titleIMG:DisplayObject;
	private var _sizeChange:Bool = false;
	private var _closeVisible:Bool = true;
	private var _contentPane:Sprite = null;
	private var _closeWidth:Int = 18;
	private var closePositionChange:Bool = false;
	private var _headHeight:Int = 25;
	private var _title:String = "";
	private var _titleChange:Bool = false;
	private var childChange:Bool = false;

	// :51-55（构造期走 initPanel 而非 this.init——见 init 行 PORT-NOTE：
	// AS3 private 静态绑定语义的等价通道，绕开 Haxe 私有方法的虚拟派发）
	public function new(param1:Rectangle = null) {
		super();
		this.initPanel(param1);
	}

	// :57-62
	public var closeRight(get, set):Int;

	private function set_closeRight(param1:Int):Int {
		this._closeRight = param1;
		this.closePositionChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :64-72
	public override function addChildAt(param1:DisplayObject, param2:Int):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		this._contentPane.addChildAt(param1, param2);
		return param1;
	}

	// :74-106
	// PORT-NOTE（AS3 private 静态绑定语义 → initPanel 助手通道）：AS3 的
	// private 方法不进继承虚表——mc.view.common.BaseWindow 族另立**同名零参**
	// public init()（窗首开时 WindowLayer 调的初始化钩子），两者在 AS3 无
	// 冲突。Haxe 的 private 不豁免 override 检查、私有方法也虚拟派发（eval
	// 实证：父类构造器 this.init() 会落进子类覆写——PostWindow.init 会在
	// width/windowName 赋值前的构造期误跑、首开时再跑一遍，双重建子件，
	// 行为偏离原版）。等价方案：init 本体保持原样但构造器改调私有助手
	// initPanel（无原版成员与其同名、永不会被覆写 = AS3 静态绑定语义）；
	// 实例 init 委托 initPanel，子类覆写只影响外部零参调用通道（与 AS3
	// 一致——该私有方法除构造器外无调用点）。覆写签名须一致，mc 窗口族
	// init 统一带 `param1:Rectangle = null`（调用方全部零参，形参不可见）。
	private function init(param1:Rectangle = null):Void {
		this.initPanel(param1);
	}

	// PORT-NOTE（super.addChild → super.addChildAt(child, super.numChildren)，
	// 本方法三处 + addChildToSuper 一处，#87 实证修正）：AVM2 的 super.addChild
	// 直进父类原生实现、**不经** public 覆写派发——子件落在面板自身显示列表。
	// openfl 9.5.2 的 addChild 方法体是一行 `addChildAt(child, numChildren)`
	// 虚拟调用（Haxe super 只上溯方法体、this 不变）：虚拟派发落回本类
	// addChildAt 覆写（:64-72 重定向进 _contentPane）——initPanel 第一句即成
	// `_contentPane.addChildAt(_contentPane, …)` 自加，构造即抛 Error #2024
	// （eval 实证：`new LipiPanel()` 裸构造即崩，牧场窗口族全部 ctor 撞死）。
	// super.addChildAt 直进父类方法体、不再二次派发（eval 探针实证），索引取
	// super.numChildren（面板自身真实子数——本类 get_numChildren 覆写已被
	// 重定向成 _contentPane.numChildren，不能用）= AVM2 的尾部追加语义。
	private function initPanel(param1:Rectangle = null):Void {
		this._contentPane = new Sprite();
		this._contentPane.x = 0;
		this._contentPane.y = 0;
		super.addChildAt(this._contentPane, super.numChildren);
		this._dragBar = new Sprite();
		this._dragBar.graphics.beginFill(0, 0);
		this._dragBar.graphics.drawRect(0, 0, 10, 10);
		this._dragBar.graphics.endFill();
		this._dragBar.width = width;
		this._dragBar.height = this.headHeight;
		this._dragBar.addEventListener(MouseEvent.MOUSE_DOWN, this.dragDown);
		super.addChildAt(this._dragBar, super.numChildren);
		this._closeButton = new LipiUIComponent();
		this._closeButton.addEventListener(MouseEvent.CLICK, this._closeButtonClick);
		this._closeButton.width = this.closeWidth;
		this._closeButton.height = this.closeHeight;
		this._closeButton.x = this.width - this._closeButton.width - this.closeRight;
		this._closeButton.y = this.closeTop;
		this._closeButton.buttonMode = true;
		this._closeButton.useHandCursor = true;
		super.addChildAt(this._closeButton, super.numChildren);
		addEventListener(UIEvent.RESIZE, this.onResize);
		if (LipiDefaultSkin.WindowBg != null) {
			bgSkin = new LipiSkin(LipiDefaultSkin.WindowBg, param1);
		}
		if (LipiDefaultSkin.WindowCloseBg != null) {
			this.closeSkin = new LipiSkin(LipiDefaultSkin.WindowCloseBg);
		}
	}

	// :108-111
	public var titleFormat(get, set):TextFormat;

	private function get_titleFormat():TextFormat {
		return this._titleText.defaultTextFormat;
	}

	// :113-116
	private function get_closeRight():Int {
		return this._closeRight;
	}

	// :118-121
	public var closeSkin(get, set):LipiSkin;

	private function get_closeSkin():LipiSkin {
		return this._closeSkin;
	}

	// :123-130
	public override function getChildByName(param1:String):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		return this._contentPane.getChildByName(param1);
	}

	// :132-139
	public override function getChildIndex(param1:DisplayObject):Int {
		if (this._contentPane == null) {
			return -1;
		}
		return this._contentPane.getChildIndex(param1);
	}

	// :141-144
	public var headHeight(get, set):Int;

	private function get_headHeight():Int {
		return this._headHeight;
	}

	// :146-149
	public var closeWidth(get, set):Int;

	private function get_closeWidth():Int {
		return this._closeWidth;
	}

	// :151-155
	private function set_closeSkin(param1:LipiSkin):LipiSkin {
		this._closeSkin = param1;
		this._closeButton.bgSkin = param1;
		return param1;
	}

	// :157-163（三行恒 false 见类头 PORT-NOTE）
	public var closeVisible(get, set):Bool;

	private function set_closeVisible(param1:Bool):Bool {
		this._closeVisible = param1;
		this._closeButton.visible = false;
		this._closeButton.mouseEnabled = false;
		this._closeButton.mouseChildren = false;
		return param1;
	}

	// :165-191（`this.addChild/removeChild` 走重定向通道进 _contentPane——
	// 标题 TextField 也在内容区，原版如此）
	public var title(get, set):String;

	private function set_title(param1:String):String {
		if (param1 == null) {
			param1 = "";
		}
		this._title = param1;
		if (param1 == "" && this._titleText != null) {
			this.removeChild(this._titleText);
			this._titleText = null;
		}
		if (this._titleText == null && param1 != "") {
			this._titleText = new TextField();
			this._titleText.defaultTextFormat = new TextFormat("Verdana", 16, 16777215, true);
			this._titleText.mouseEnabled = false;
			this._titleText.autoSize = TextFieldAutoSize.LEFT;
			this.addChild(this._titleText);
		}
		if (this._titleText != null) {
			this._titleText.text = param1;
		}
		this._titleChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :193-196
	public var closeTop(get, set):Int;

	private function get_closeTop():Int {
		return this._closeTop;
	}

	// :198-201
	public var closeHeight(get, set):Int;

	private function get_closeHeight():Int {
		return this._closeHeight;
	}

	// :203-210
	public override function getChildAt(param1:Int):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		return this._contentPane.getChildAt(param1);
	}

	// :212-226（写-only 属性形态与 Class 实例化见类头 PORT-NOTE；
	// `if(!param1)`/`Boolean(this._titleIMG)` 是 null 真值判，直翻）
	public var titleIMG(never, set):Class<Dynamic>;

	private function set_titleIMG(param1:Class<Dynamic>):Class<Dynamic> {
		if (param1 == null) {
			return param1;
		}
		if (this._titleIMG != null && contains(this._titleIMG)) {
			this.removeChild(this._titleIMG);
		}
		var _loc2_:Dynamic = Type.createInstance(param1, []);
		this._titleIMG = Std.isOfType(_loc2_, DisplayObject) ? cast(_loc2_, DisplayObject) : null;
		this.addChild(this._titleIMG);
		this._titleChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :228-232
	private function _closeButtonClick(param1:MouseEvent):Void {
		var _loc2_:UIEvent = new UIEvent(UIEvent.CLOSE);
		dispatchEvent(_loc2_);
	}

	// :234-237（super.addChild 的等价通道见 initPanel 行 PORT-NOTE——
	// 本方法名就叫「加到 super」，语义正是绕过重定向落面板自身列表）
	public function addChildToSuper(param1:DisplayObject):Void {
		super.addChildAt(param1, super.numChildren);
	}

	// :239-242
	public override function get_numChildren():Int {
		return this._contentPane.numChildren;
	}

	// :244-251
	public override function removeChildAt(param1:Int):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		return this._contentPane.removeChildAt(param1);
	}

	// :253-258
	private function set_headHeight(param1:Int):Int {
		this._headHeight = param1;
		this._headHeightChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :260-263
	private function get_title():String {
		return this._title;
	}

	// :265-268
	private function get_closeVisible():Bool {
		return this._closeVisible;
	}

	// :270-275
	private function set_closeWidth(param1:Int):Int {
		this._closeWidth = param1;
		this.closePositionChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :277-281
	private function set_titleFormat(param1:TextFormat):TextFormat {
		this._titleText.defaultTextFormat = param1;
		this.title = this._title;
		return param1;
	}

	// :283-287
	private function dragUp(param1:MouseEvent):Void {
		stopDrag();
		stage.removeEventListener(MouseEvent.MOUSE_UP, this.dragUp);
	}

	// :289-293
	private function onResize(param1:UIEvent):Void {
		this._sizeChange = true;
		invalidateDisplayList();
	}

	// :295-306（Rectangle 宽高参数见类头 PORT-NOTE；
	// `parent.addChild(this)`——parent 的 addChild 若同为 LipiPanel 族
	// 重定向则进对方内容区，原版动态派发语义照抄）
	private function dragDown(param1:MouseEvent):Void {
		if (parent != null) {
			parent.addChild(this);
		}
		startDrag(false, new Rectangle(this.mouseX * -1, this.mouseY * -1, stage.stageWidth - this.mouseY, stage.stageHeight - this.mouseY));
		if (stage != null) {
			stage.addEventListener(MouseEvent.MOUSE_UP, this.dragUp, false, 0, true);
		}
	}

	// :308-347
	private override function updateDisplayList(param1:Float, param2:Float):Void {
		super.updateDisplayList(param1, param2);
		if (this._headHeightChange || this._titleChange) {
			if (this._titleText != null) {
				this._titleText.x = (param1 - this._titleText.width) / 2;
				this._titleText.y = (this._headHeight - this._titleText.height) / 2;
			}
			if (this._titleIMG != null) {
				this._titleIMG.x = (param1 - this._titleIMG.width) / 2;
				this._titleIMG.y = (this._headHeight - this._titleIMG.height) / 2;
			}
			if (this._headHeightChange) {
				this._contentPane.y = this._headHeight;
				this._dragBar.width = width;
				this._dragBar.height = this._headHeight;
			}
			this._titleChange = false;
			this._headHeightChange = false;
		}
		if (this._sizeChange) {
			this._closeButton.x = this.width - this._closeButton.width - this.closeRight;
			this._closeButton.y = this.closeTop;
			this._dragBar.width = width;
			this._sizeChange = false;
		}
		if (this.closePositionChange) {
			this._closeButton.width = this.closeWidth;
			this._closeButton.height = this.closeHeight;
			this._closeButton.x = this.width - this._closeButton.width - this.closeRight;
			this._closeButton.y = this.closeTop;
			this.closePositionChange = false;
		}
	}

	// :349-357
	public override function removeChild(param1:DisplayObject):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		this._contentPane.removeChild(param1);
		return param1;
	}

	// :359-364
	private function set_closeTop(param1:Int):Int {
		this._closeTop = param1;
		this.closePositionChange = true;
		invalidateDisplayList();
		return param1;
	}

	// :366-374
	public override function addChild(param1:DisplayObject):DisplayObject {
		if (this._contentPane == null) {
			return null;
		}
		this._contentPane.addChild(param1);
		return param1;
	}

	// :376-381
	private function set_closeHeight(param1:Int):Int {
		this._closeHeight = param1;
		this.closePositionChange = true;
		invalidateDisplayList();
		return param1;
	}
}
