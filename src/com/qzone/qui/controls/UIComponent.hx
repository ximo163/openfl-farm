package com.qzone.qui.controls;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.Dictionary;

/**
 * com.qzone.qui.controls.UIComponent —— UIComponent.as 逐句对应（issue #9
 * qui 子集片）。qui 控件基类：_width/_height 存储位 + RENDER 帧节流的
 * delayCall（width/height/enabled 的变更统一压到渲染帧统一应用）。
 * _width/_height 无显式初值（AS3 Number 默认 NaN，Haxe Float 同为 NaN）。
 */
class UIComponent extends Sprite {
	// UIComponent.as:10
	public static var isRenderCalling:Bool;

	// UIComponent.as:12-26（AS3 protected → Haxe private，子类可见）
	private var _added:Bool;
	private var _height:Float;
	private var _width:Float;
	private var _enabled:Bool;
	private var _inited:Bool;
	private var _toolTip:String;
	// 原文无类型参（new Dictionary()，键是方法闭包）。K 必须是对象类型：
	// Dictionary 是 @:multiType，K=Dynamic 会落到 StringMap——函数键被 JS 对象
	// 键强转成字符串，RENDER 帧重放时 key.apply 直接 TypeError（#9 nodeboot
	// 踩到）。函数类型键落 ObjectMap（LoadManager 的 Dictionary<EventDispatcher,…>
	// 同款），与 AS3 Dictionary 对象键语义一致
	private var renderCalls:Dictionary<Dynamic->Void, Array<Dynamic>> = new Dictionary<Dynamic->Void, Array<Dynamic>>();
	private var _resized:Bool;

	// UIComponent.as:28-37
	public function new() {
		super();
		this._added = false;
		this._enabled = true;
		this._inited = false;
		this._resized = false;
		this._toolTip = "";
		this.addEventListener(Event.ADDED, this.addedFn);
	}

	// UIComponent.as:39-41（空实现，子类覆写）
	private function setSize():Void {}

	// UIComponent.as:43-46
	private override function get_width():Float {
		return this._width;
	}

	// UIComponent.as:48-66。PORT-NOTE: AS3 `...rest` 收集成数组再进
	// renderCalls；Haxe 侧收成 rest 参数数组（默认 []，调用点 delayCall(fn) 无
	// 参时等价空 rest）。`param1.apply(param1,rest)` 的 thisArg 是函数自身，
	// 照抄（Reflect.callMethod 的首参）。
	private function delayCall(param1:Dynamic, rest:Array<Dynamic> = null):Void {
		if (rest == null) {
			rest = [];
		}
		if (isRenderCalling) {
			trace("isRenderCalling");
			Reflect.callMethod(param1, param1, rest);
			return;
		}
		this.renderCalls.set(param1, rest);
		if (this.stage != null) {
			this.stage.addEventListener(Event.RENDER, this.delayCallFn, false, 0, true);
			this.stage.invalidate();
		} else {
			this.addEventListener(Event.ADDED_TO_STAGE, this.delayCallFn, false, 0, true);
		}
	}

	// UIComponent.as:68-71
	public function move(param1:Float, param2:Float):Void {
		this.x = param1;
		this.y = param2;
	}

	// UIComponent.as:74-83
	private override function set_width(param1:Float):Float {
		if (this._width == param1) {
			return param1;
		}
		this._width = param1;
		this.delayCall(this.setSize);
		this._resized = true;
		return param1;
	}

	// UIComponent.as:85-87（空实现，子类覆写）
	private function setSkin():Void {}

	// UIComponent.as:89-98
	public var enabled(get, set):Bool;

	private function get_enabled():Bool {
		return this._enabled;
	}

	private function set_enabled(param1:Bool):Bool {
		this._enabled = param1;
		this.delayCall(this.setEnabled);
		return param1;
	}

	// UIComponent.as:100-109
	private override function set_height(param1:Float):Float {
		if (this._height == param1) {
			return param1;
		}
		this._height = param1;
		this.delayCall(this.setSize);
		this._resized = true;
		return param1;
	}

	// UIComponent.as:111-127
	public var toolTip(get, set):String;

	private function get_toolTip():String {
		return this._toolTip;
	}

	private function set_toolTip(param1:String):String {
		this._toolTip = param1;
		return param1;
	}

	// UIComponent.as:116-122
	private function init():Void {
		this.setSkin();
		this.setSize();
		this.setEnabled();
		this._inited = true;
	}

	// UIComponent.as:129-132
	private override function get_height():Float {
		return this._height;
	}

	// UIComponent.as:134-142
	private function addedFn(param1:Event):Void {
		if (param1.target == this) {
			this.removeEventListener(Event.ADDED, this.addedFn);
			this._added = true;
			this.init();
		}
	}

	// UIComponent.as:144-162。PORT-NOTE: renderCalls 以函数闭包为键——AS3
	// 同一方法的两次闭包提取相等（去重），Haxe 闭包是各自独立的对象；同一
	// 方法在两帧间被 delayCall 两次会存两条、应用两次（setSize/setEnabled
	// 幂等，行为等价），跨帧不残留。
	private function delayCallFn(param1:Event):Void {
		var _loc2_:Dynamic = null;
		if (param1.type == Event.ADDED_TO_STAGE) {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.delayCallFn);
			this.stage.addEventListener(Event.RENDER, this.delayCallFn);
			this.stage.invalidate();
			return;
		}
		param1.currentTarget.removeEventListener(Event.RENDER, this.delayCallFn);
		isRenderCalling = true;
		// PORT-NOTE: 原文边迭代边 delete；Haxe 侧先快照键再逐个应用+移除，
		// 避免迭代器在删除下跳键（应用集合相同）。openfl Dictionary 的
		// iterator() 按 AS3 for-in 语义迭代键
		var _loc3_:Array<Dynamic> = [for (_loc2_ in this.renderCalls) _loc2_];
		for (_loc2_ in _loc3_) {
			Reflect.callMethod(null, _loc2_, this.renderCalls.get(_loc2_));
			this.renderCalls.remove(_loc2_);
		}
		isRenderCalling = false;
	}

	// UIComponent.as:164-166（空实现，子类覆写）
	private function setEnabled():Void {}
}
