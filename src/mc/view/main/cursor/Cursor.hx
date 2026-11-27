package mc.view.main.cursor;

import mc.control.ViewControl;
import mc.events.CursorEvent;
import openfl.events.Event;
import shim.As3;

/**
 * mc.view.main.cursor.Cursor —— Cursor.as 逐句对应（issue #87「光标」片真身）。
 * 光标调度静态面：useSystem 派 "system"/"customize" USE_TYPE 事件，setCursor
 * 派 CURSOR 事件并按 cursorArgument.type=="7" 补派 animalStop/animalMov，
 * delaySetCursor 经 setTimeout 80ms 延迟转 setCursor。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/Cursor.as。
 */
@:keep
class Cursor {
	// Cursor.as:10-20
	public static var currentCursor:BaseCursor;
	public static var cursorArgument:Dynamic;
	public static var preName:String = "";
	public static var name:String = "";
	public static var system:Bool = false;
	public static var useDrag:Bool = false;

	// Cursor.as:23-26
	public function new() {}

	// Cursor.as:28-40
	public static function useSystem(param1:Bool = true):Void {
		var _loc2_:CursorEvent = new CursorEvent(CursorEvent.USE_TYPE);
		if (param1) {
			_loc2_.cursorName = "system";
		} else {
			_loc2_.cursorName = "customize";
		}
		ViewControl.getInstance().dispatchEvent(_loc2_);
	}

	// Cursor.as:42-45（setAPICurosr 是原文拼写，逐字照译）
	public static function setAPICurosr(param1:String, param2:Dynamic = null, param3:String = null):Void {
		Cursor.setCursorForAPI(param1, param2, param3);
	}

	// Cursor.as:47-60（PORT-NOTE：`preName == name;` 是原版笔误——比较表达式
	// 语句无赋值效果（应为 `preName = name`），两份反编译一致（xfl/ 与 scripts/
	// diff 同），照抄不「修好」；preName 因此永远不更新，原版行为如此）
	public static function setCursorForAPI(param1:String, param2:Dynamic = null, param3:String = null):Void {
		if (name != "") {
			preName == name;
		}
		name = param1;
		cursorArgument = param2;
		var _loc4_:CursorEvent = new CursorEvent(CursorEvent.API);
		_loc4_.cursorName = param1;
		_loc4_.cursorArgument = cursorArgument;
		_loc4_.materialName = param3;
		ViewControl.getInstance().dispatchEvent(_loc4_);
	}

	// Cursor.as:62-65（AS3 setTimeout 的 rest 参：80ms 后以 param1/param2 调
	// setCursor——As3.setTimeout 只收无参闭包，包一层转发，NPCView 先例）
	public static function delaySetCursor(param1:String, param2:String = ""):Void {
		As3.setTimeout(function():Void {
			Cursor.setCursor(param1, param2);
		}, 80);
	}

	// Cursor.as:67-80（`cursorArgument["type"] == "7"` 是 Dynamic 松等——
	// 数值 7 也命中，走 As3.eqString，lessons #8 条）
	public static function setCursor(param1:String, param2:Dynamic = null):Void {
		if (name != "") {
			preName == name;
		}
		name = param1;
		cursorArgument = param2;
		var _loc3_:CursorEvent = new CursorEvent(CursorEvent.CURSOR);
		_loc3_.cursorName = param1;
		_loc3_.cursorArgument = cursorArgument;
		ViewControl.getInstance().dispatchEvent(_loc3_);
		if (cursorArgument != null && As3.hasProp(cursorArgument, "type") && As3.eqString(Reflect.field(cursorArgument, "type"), "7")) {
			ViewControl.getInstance().dispatchEvent(new Event("animalStop"));
		} else {
			ViewControl.getInstance().dispatchEvent(new Event("animalMov"));
		}
	}
}
