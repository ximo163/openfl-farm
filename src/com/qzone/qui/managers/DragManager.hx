package com.qzone.qui.managers;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import shim.As3;

// com.qzone.qui.managers.DragManager —— DragManager.as 逐句对应（issue #44
// 真身，原 #7 闭包 stub 退役）。_targets 是 AS3 `Object = {}` 按命中区名登记的
// 表：读写/删除全走 Reflect（Dynamic 裸写在静态目标按类字段表查找、openfl
// 符号壳会抛 Invalid field，CLAUDE.md 三选一的 Reflect 通道）；值是
// {rect,parent,target} 匿名对象，字段取同样走 Reflect。触屏下拖拽事件流的
// 合成交互归 shim 输入适配层（spec/interaction-map.json），不进本类。
// legacy/decompiled/main3_v_221/scripts/com/qzone/qui/managers/DragManager.as
class DragManager {
	// DragManager.as:13
	private static var _hitArea:InteractiveObject;

	// DragManager.as:15
	private static var _rect:Rectangle;

	// DragManager.as:17（AS3 Boolean 静态零值 false；eval 未赋值静态是
	// null，显式落 false 同 AS3——Main.setup 会写 true）
	public static var updateAfterEvent:Bool = false;

	// DragManager.as:19
	private static var _parent:DisplayObjectContainer;

	// DragManager.as:21
	private static var _draging:Bool = false;

	// DragManager.as:23
	private static var _target:Sprite;

	// DragManager.as:25（legacy 无赋值点，恒 false）
	public static var autoToFront:Bool = false;

	// DragManager.as:27
	private static var _targets:Dynamic = {};

	public function new() {}

	// DragManager.as:34-49
	private static function loader_MOUSE_MOVE(param1:MouseEvent):Void {
		if (!_draging) {
			_draging = true;
			_target.startDrag(false, _rect);
		}
		if (updateAfterEvent) {
			param1.updateAfterEvent();
		} else {
			_parent.removeEventListener(MouseEvent.MOUSE_MOVE, loader_MOUSE_MOVE);
		}
	}

	// DragManager.as:51-55
	private static function addEvent():Void {
		_parent.addEventListener(MouseEvent.MOUSE_MOVE, loader_MOUSE_MOVE);
		_parent.addEventListener(MouseEvent.MOUSE_UP, loader_MOUSE_UP);
	}

	// DragManager.as:57-66（`param2 || param1` 是 AS3 对象真值或；AS3 Object
	// 的 hasOwnProperty/delete → 匿名对象 hasField/deleteField 等价）
	public static function removeTarget(param1:Sprite, param2:InteractiveObject = null):Void {
		var _loc3_:InteractiveObject = As3.or(param2, param1);
		var _loc4_:String = _loc3_.name;
		if (Reflect.hasField(_targets, _loc4_)) {
			_loc3_.removeEventListener(MouseEvent.MOUSE_DOWN, loader_MOUSE_DOWN);
			Reflect.deleteField(_targets, _loc4_);
		}
	}

	// DragManager.as:68-72
	private static function removeEvent():Void {
		_parent.removeEventListener(MouseEvent.MOUSE_UP, loader_MOUSE_UP);
		_parent.removeEventListener(MouseEvent.MOUSE_MOVE, loader_MOUSE_MOVE);
	}

	// DragManager.as:74-84（currentTarget 静态是 Object=Dynamic，按名路由读
	// 一律强类型化起手——#9 教训；表值字段取走 Reflect）
	private static function loader_MOUSE_DOWN(param1:MouseEvent):Void {
		_target = Reflect.field(Reflect.field(_targets, (param1.currentTarget : DisplayObject).name), "target");
		_rect = Reflect.field(Reflect.field(_targets, (param1.currentTarget : DisplayObject).name), "rect");
		_parent = As3.or(Reflect.field(Reflect.field(_targets, (param1.currentTarget : DisplayObject).name), "parent"), _target.stage);
		if (autoToFront) {
			PopUpManager.bringToFront(_target);
		}
		addEvent();
	}

	// DragManager.as:86-98
	public static function addTarget(param1:Sprite, param2:Rectangle = null, param3:InteractiveObject = null, param4:DisplayObjectContainer = null):Void {
		_target = param1;
		_parent = param4;
		_rect = param2;
		_hitArea = As3.or(param3, param1);
		Reflect.setField(_targets, _hitArea.name, {
			"rect": _rect,
			"parent": _parent,
			"target": _target
		});
		_hitArea.addEventListener(MouseEvent.MOUSE_DOWN, loader_MOUSE_DOWN);
	}

	// DragManager.as:100-109
	private static function loader_MOUSE_UP(param1:MouseEvent):Void {
		removeEvent();
		_target.stopDrag();
		if (_draging) {
			_target.dispatchEvent(new Event("LOCATION_CHANGE"));
		}
		_draging = false;
	}
}
