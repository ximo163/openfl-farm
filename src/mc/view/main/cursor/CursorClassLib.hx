package mc.view.main.cursor;

/**
 * mc.view.main.cursor.CursorClassLib —— CursorClassLib.as 逐句对应（issue #87
 * 「光标」片真身）。光标类名→Class 注册表：内置 11 个键值（原文对象字面量里
 * "CursorArrow" 写两遍——重复键后者盖前者，两值同为 CursorArrow 无差异；
 * Haxe 对象字面量不允许重复字段，去重写一次 + PORT-NOTE），register/getClass
 * 静态通道。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorClassLib.as。
 */
@:keep
class CursorClassLib {
	// CursorClassLib.as:6-19（PORT-NOTE(重复键)：原文 "CursorArrow" 键出现
	// 两次（:7 与 :11），AS3 对象字面量后写盖先写、两值相同；Haxe 字面量重复
	// 字段是编译错，去重保留一次，语义不变）
	private static var cusrsorLib:Dynamic = {
		"CursorArrow": CursorArrow,
		"Cursor_ShengChan": Cursor_ShengChan,
		"Cursor_ShouHuo": Cursor_ShouHuo,
		"Cursor_Theft": Cursor_Theft,
		"CursorTool": CursorTool,
		"Cursor_Fly": Cursor_Fly,
		"Cursor_Flapper": Cursor_Flapper,
		"Cursor_ClearBB": Cursor_ClearBB,
		"Cursor_ShouHuoAll": Cursor_ShouHuoAll,
		"Cursor_Donate": Cursor_Donate,
		"Cursor_Tanabata": Cursor_Tanabata
	};

	// CursorClassLib.as:21-24
	public function new() {}

	// CursorClassLib.as:26-33（缺键 AS3 取 undefined→null；`as Class` 语义
	// 由 Reflect.field + 调用点类型承载）
	public static function getClass(param1:String):Class<Dynamic> {
		if (cusrsorLib == null) {
			return null;
		}
		return Reflect.field(cusrsorLib, param1);
	}

	// CursorClassLib.as:35-40
	public static function register(param1:String, param2:Class<Dynamic>):Void {
		if (cusrsorLib == null) {
			cusrsorLib = {};
		}
		Reflect.setField(cusrsorLib, param1, param2);
	}
}
