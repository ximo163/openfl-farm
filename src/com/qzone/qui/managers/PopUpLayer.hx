package com.qzone.qui.managers;

import com.qzone.qui.containers.TitleWindow;
import com.qzone.qui.styles.Style;
import com.qzone.utils.GraphicsUtil;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import shim.As3;

/**
 * com.qzone.qui.managers.PopUpLayer —— PopUpLayer.as 逐句对应（issue #18
 * qui 收尾：管理器片）。弹窗宿主层（Sprite）：登记 popUp/modal 记录表
 * （_targets 按显示对象 name 键的动态对象）、模态遮罩、进出场效果回调、
 * Enter 键派发给顶层弹窗的 keyEnter。原版是 internal class（同包可见），
 * Haxe 按文件即类需 public 供 PopUpManager 引用，可见性等价于包内。
 * PORT-NOTE:
 * - `this._targets[name]`（Object 按名键）→ Reflect.field/setField/deleteField。
 * - `this["root"].tabChildren` → root 是 DisplayObject，cast 到容器后写。
 * - `param1["disableAnimation"] == true` 等 hasOwnProperty 检查 → As3.hasProp
 *   （Reflect.hasField 查不到原型方法/存取器属性）。
 * - EffectManager 第 4 参是 `...rest`：单参调用收成 [param1]。
 */
@:keep
class PopUpLayer extends Sprite {
	// PopUpLayer.as:16
	private var _items:Array<Dynamic> = [];

	// :18
	private var _targets:Dynamic = {};

	// :20-24
	public function new() {
		super();
		this.mouseEnabled = false;
	}

	// :26-29
	public var items(get, never):Array<Dynamic>;

	private function get_items():Array<Dynamic> {
		return this._items;
	}

	// :31-73
	public function removePopUp(param1:DisplayObjectContainer):Void {
		var _loc2_:String;
		var _loc3_:Bool = false;
		var _loc4_:Dynamic = null;
		var _loc5_:Int = 0;
		if (this.contains(param1)) {
			_loc2_ = param1.name;
			if (Reflect.hasField(this._targets, _loc2_)) {
				if (As3.truthy(Reflect.field(Reflect.field(this._targets, _loc2_), "modal"))) {
					this.removeChild(Reflect.field(Reflect.field(this._targets, _loc2_), "modal"));
				}
				_loc5_ = this._items.indexOf(Reflect.field(this._targets, _loc2_));
				this._items.splice(_loc5_, 1);
				Reflect.deleteField(this._targets, _loc2_);
			}
			_loc3_ = false;
			// AS3 for-each：按值遍历 items
			for (_loc4_ in this.items) {
				if (As3.truthy(Reflect.field(_loc4_, "modal"))) {
					_loc3_ = true;
					break;
				}
			}
			if (_loc3_ == false) {
				cast(this.root, DisplayObjectContainer).tabChildren = true;
			}
			if (As3.hasProp(param1, "disableAnimation") == true && Reflect.field(param1, "disableAnimation") == true) {
				this.removedEffectEnd(param1);
			} else {
				EffectManager.Out(this, param1, this.removedEffectEnd, [param1]);
			}
			param1.removeEventListener(Event.CLOSE, this._CLOSE);
		}
	}

	// :75-91
	private function removedEffectEnd(param1:DisplayObjectContainer):Void {
		var _loc2_:TitleWindow;
		if (param1 == null) {
			return;
		}
		if (param1.parent != null) {
			param1.parent.removeChild(param1);
		}
		if (Std.isOfType(param1, TitleWindow)) {
			_loc2_ = cast param1;
			DragManager.removeTarget(_loc2_, _loc2_.headArea);
		}
	}

	// :93-119
	public function addPopUp(param1:DisplayObject, param2:DisplayObjectContainer, param3:Bool = false):Void {
		var _loc4_:Sprite = null;
		if (param3) {
			_loc4_ = new Sprite();
			GraphicsUtil.draw(_loc4_, Style.popUpModalColor, Style.popUpModalAlpha,
				new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight), true);
			this.addChild(_loc4_);
		}
		stage.addEventListener(KeyboardEvent.KEY_UP, this.stageKeyUp);
		param1.addEventListener(Event.CLOSE, this._CLOSE);
		param1.filters = cast Style.getShadowFilter();
		Reflect.setField(this._targets, param1.name, {
			"popUp": param1,
			"modal": _loc4_
		});
		this._items.push(Reflect.field(this._targets, param1.name));
		this.addChild(param1);
		if (As3.hasProp(param1, "disableAnimation") == true && Reflect.field(param1, "disableAnimation") == true) {
			this.addedEffectEnd(param1);
		} else {
			EffectManager.In(this, param1, this.addedEffectEnd, [param1]);
		}
	}

	// :121-131（`param1["onEffectEnd"] is Function`）
	private function addedEffectEnd(param1:DisplayObject):Void {
		if (param1 == null) {
			return;
		}
		if (As3.hasProp(param1, "onEffectEnd") == true && Reflect.isFunction(Reflect.field(param1, "onEffectEnd"))) {
			Reflect.callMethod(param1, Reflect.field(param1, "onEffectEnd"), []);
		}
	}

	// :133-142
	private function _CLOSE(param1:Event):Void {
		var _loc2_:DisplayObjectContainer = Std.isOfType(param1.currentTarget, DisplayObjectContainer)
			? cast(param1.currentTarget, DisplayObjectContainer) : null;
		if (_loc2_ != null) {
			_loc2_.removeEventListener(Event.CLOSE, this._CLOSE);
			ToolTipManager.hide();
			this.removePopUp(_loc2_);
		}
	}

	// :144-155（keyCode 13 = Enter）
	private function stageKeyUp(param1:KeyboardEvent):Void {
		var _loc2_:DisplayObject = null;
		if (numChildren > 0 && param1.keyCode == 13) {
			_loc2_ = Std.isOfType(getChildAt(numChildren - 1), DisplayObject) ? cast(getChildAt(numChildren - 1), DisplayObject) : null;
			if (_loc2_ != null && As3.hasProp(_loc2_, "keyEnter")) {
				Reflect.callMethod(_loc2_, Reflect.field(_loc2_, "keyEnter"), [param1]);
			}
		}
	}
}
