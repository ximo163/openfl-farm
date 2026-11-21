package com.qzone.qui.managers;

import com.qzone.qui.controls.ToolTip;
import com.qzone.qui.styles.Style;
import com.qzone.utils.DisplayUtil;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import shim.As3;

/**
 * com.qzone.qui.managers.ToolTipLayer —— ToolTipLayer.as 逐句对应（issue #18
 * qui 收尾：管理器片）。工具提示层：挂在 stage 的 MOUSE_OVER 上，对带
 * toolTip 属性的目标显示 ToolTipManager.toolTipClass 实例，flowMouse 模式
 * 跟随鼠标，否则锚在目标矩形上方并做边界钳制。原版是 internal class
 * （同包可见），Haxe 按文件即类需 public 供 ToolTipManager 引用。
 * PORT-NOTE:
 * - `_loc2_.hasOwnProperty("toolTip")` → As3.hasProp（Reflect.hasField 查不到
 *   UIComponent.toolTip 这类存取器属性，js/eval 上会漏）。
 * - `this._tipStr = _loc2_["toolTip"]` → Reflect.getProperty（走属性 getter）。
 * - EffectManager 第 4 参是 `...rest`：单参调用收成 [this._toolTip]。
 */
@:keep
class ToolTipLayer extends Sprite {
	// ToolTipLayer.as:16-22
	private var _currentComponent:DisplayObject;

	private var _toolTip:ToolTip;

	private var _rect:Rectangle;

	private var _tipStr:String;

	// :24-30
	public function new() {
		super();
		this.mouseEnabled = false;
		this.mouseChildren = false;
		this.addEventListener(Event.ADDED_TO_STAGE, this._added_TO_STAGE);
	}

	// :32-51
	private function setToolTip(param1:MouseEvent):Void {
		var _loc3_:Point = null;
		var _loc2_:DisplayObject = Std.isOfType(param1.target, DisplayObject) ? cast(param1.target, DisplayObject) : null;
		if (_loc2_ != null && As3.hasProp(_loc2_, "toolTip")) {
			this._tipStr = Reflect.getProperty(_loc2_, "toolTip");
			if (As3.truthy(this._tipStr)) {
				_loc3_ = _loc2_.parent.localToGlobal(new Point(_loc2_.x, _loc2_.y));
				this._rect.x = _loc3_.x;
				this._rect.y = _loc3_.y;
				this._rect.width = _loc2_.width;
				this._rect.height = _loc2_.height;
				this._currentComponent = _loc2_;
				this._currentComponent.addEventListener(MouseEvent.ROLL_OUT, this._MOUSE_OUT);
				this.showToolTip(param1);
			}
		}
	}

	// :53-55（空实现：子类覆写点）
	private function moveTip():Void {}

	// :57-89（AS3 int ← Number 表达式按原文逐处截断）
	private function setPosition(param1:MouseEvent):Void {
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		if (ToolTipManager.flowMouse) {
			_loc3_ = Std.int(param1.stageY + 30);
			_loc2_ = Std.int(param1.stageX);
		} else {
			_loc3_ = Std.int(this._rect.y - this._toolTip.height + this._toolTip.offset.y - Style.toolTipPaddingV);
			_loc2_ = Std.int(param1.stageX - this._toolTip.width / 2 + this._toolTip.offset.x);
		}
		if (_loc3_ < 0) {
			_loc3_ = Std.int(this._rect.y + this._rect.height + Style.toolTipPaddingV);
		} else if (_loc3_ > stage.stageHeight - this._toolTip.height - 30) {
			_loc3_ = Std.int(param1.stageY - this._toolTip.height - 10);
		}
		if (_loc2_ < 0) {
			_loc2_ = Style.toolTipPaddingH;
		} else if (_loc2_ + this._toolTip.width + Style.toolTipPaddingH > this.stage.stageWidth) {
			_loc2_ = Std.int(this.stage.stageWidth - this._toolTip.width - Style.toolTipPaddingH);
		}
		this._toolTip.x = _loc2_;
		this._toolTip.y = _loc3_;
	}

	// :91-99
	private function _MOUSE_MOVE(param1:MouseEvent):Void {
		if (param1.target != this._currentComponent) {
			this.hideToolTip();
			return;
		}
		this.setPosition(param1);
	}

	// :101-107
	public function hideToolTip():Void {
		if (this._toolTip != null && this._toolTip.parent != null) {
			EffectManager.Out(this, this._toolTip, this.removeEffectEnd);
		}
	}

	// :109-112
	private function _MOUSE_OVER(param1:MouseEvent):Void {
		this.setToolTip(param1);
	}

	// :114-119
	private function _added_TO_STAGE(param1:Event):Void {
		this._rect = new Rectangle();
		this.removeEventListener(Event.ADDED_TO_STAGE, this._added_TO_STAGE);
		this.stage.addEventListener(MouseEvent.MOUSE_OVER, this._MOUSE_OVER);
	}

	// :121-124
	private function addedEffectEnd(param1:DisplayObject):Void {
		this.addChild(this._toolTip);
	}

	// :126-130
	private function _MOUSE_OUT(param1:MouseEvent):Void {
		param1.currentTarget.removeEventListener(MouseEvent.ROLL_OUT, this._MOUSE_OUT);
		this.hideToolTip();
	}

	// :132-146（`new ToolTipManager.toolTipClass()` → Type.createInstance）
	private function showToolTip(param1:MouseEvent):Void {
		if (this._toolTip == null) {
			this._toolTip = cast Type.createInstance(ToolTipManager.toolTipClass, []);
			this.addChild(this._toolTip);
		}
		this._toolTip.text = this._tipStr;
		if (ToolTipManager.flowMouse) {
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this._MOUSE_MOVE);
		}
		this.setPosition(param1);
		EffectManager.In(this, this._toolTip, this.addedEffectEnd, [this._toolTip]);
	}

	// :148-155
	private function removeEffectEnd():Void {
		DisplayUtil.removeChild(this, this._toolTip);
		if (ToolTipManager.flowMouse) {
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this._MOUSE_MOVE);
		}
	}
}
