package mc.view.main.cursor;

import common.MaterialLib;
import openfl.display.MovieClip;

/**
 * mc.view.main.cursor.Cursor_Tanabata —— Cursor_Tanabata.as 逐句对应
 * （issue #87「光标」片真身）。七夕光标：ctor 用
 * MaterialLib.getClass("cusor_tanabata") 取类实例化当光标皮（注意原素材名
 * 拼写就是 cusor——少个 r，逐字照抄），无任何重写方法。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/Cursor_Tanabata.as。
 */
@:keep
class Cursor_Tanabata extends BaseCursor {
	// Cursor_Tanabata.as:9
	private var _cursor:MovieClip;

	// Cursor_Tanabata.as:11-18（`new (cls as Class)()` 反射构造——Haxe 走
	// Type.createInstance；类缺失时 AS3 new null 抛 TypeError，createInstance
	// 同样抛错，崩溃语义等价）
	public function new() {
		super();
		this._cursor = cast Type.createInstance(MaterialLib.getInstance().getClass("cusor_tanabata"), []);
		this._cursor.cacheAsBitmap = true;
		addChild(this._cursor);
		this.cacheAsBitmap = true;
	}
}
