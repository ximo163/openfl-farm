package com.minutes.ui.collections;

import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.errors.Error;

/**
 * com.minutes.ui.collections.SimpleCollection —— SimpleCollection.as 的
 * write-tests stub（issue #86 牧场库底座，LipiUI 组件库片）。本阶段只立
 * 签名面：字段照 AS3 声明（_width/_height 初值 100），测试触到的访问器
 * 方法体 throw，真身随 implement 补。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/collections/SimpleCollection.as。
 *
 * PORT-NOTE（AS3 override width/height → Haxe）：Sprite 的同名属性不允许
 * 子类重声明，只重载访问器——src/com/minutes/ui/core/LipiUIComponent.hx
 * 同款形态（:25-27/:49-63/:59-63 的三个 override）。
 */
@:keep
class SimpleCollection extends Sprite {
	// :9
	private var _bg:DisplayObject;

	// :11-13（AS3 Number 字段初值 100）
	private var _width:Float = 100;

	// :12
	private var _height:Float = 100;

	public function new() {
		super();
		throw new Error("not implemented");
	}

	// :20-23
	public var bg(get, set):DisplayObject;

	// :20-23（write-tests stub：真身随 implement）
	private function get_bg():DisplayObject {
		throw new Error("not implemented");
	}

	// :30-47（write-tests stub：真身随 implement）
	private function set_bg(param1:DisplayObject):DisplayObject {
		throw new Error("not implemented");
	}

	// :25-27（override 等价面，见类头 PORT-NOTE；write-tests stub：真身随 implement）
	private override function get_width():Float {
		throw new Error("not implemented");
	}

	// :64-72（write-tests stub：真身随 implement）
	private override function set_width(param1:Float):Float {
		throw new Error("not implemented");
	}

	// :59-63（write-tests stub：真身随 implement）
	private override function get_height():Float {
		throw new Error("not implemented");
	}

	// :49-57（write-tests stub：真身随 implement）
	private override function set_height(param1:Float):Float {
		throw new Error("not implemented");
	}
}
