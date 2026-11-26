package mc.view.main.cursor;

import openfl.errors.Error;

/**
 * mc.view.main.cursor.Cursor —— Cursor.as 的签名面 stub（原类 82 loc，
 * issue #87「光标」片充真身）。光标调度静态面：useSystem 派 "system"/
 * "customize" USE_TYPE 事件，setCursor 派 CURSOR 事件并按
 * cursorArgument.type=="7" 补派 animalStop/animalMov，delaySetCursor
 * 经 setTimeout 80ms 延迟转 setCursor。成员签名逐字取自反编译原文。
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
		throw new Error("not implemented");
	}

	// Cursor.as:42-45
	public static function setAPICurosr(param1:String, param2:Dynamic = null, param3:String = null):Void {
		throw new Error("not implemented");
	}

	// Cursor.as:47-60
	public static function setCursorForAPI(param1:String, param2:Dynamic = null, param3:String = null):Void {
		throw new Error("not implemented");
	}

	// Cursor.as:62-65
	public static function delaySetCursor(param1:String, param2:String = ""):Void {
		throw new Error("not implemented");
	}

	// Cursor.as:67-80
	public static function setCursor(param1:String, param2:Dynamic = null):Void {
		throw new Error("not implemented");
	}
}
