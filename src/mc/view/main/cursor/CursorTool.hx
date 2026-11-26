package mc.view.main.cursor;

import openfl.display.MovieClip;
import openfl.errors.Error;

/**
 * mc.view.main.cursor.CursorTool —— CursorTool.as 的签名面 stub（原类 51 loc，
 * issue #87「光标」片充真身）。工具光标：cursorArgument.type!=9 取素材
 * "CursorTool_"+type+"_"+tId，type==9 拼 "Animal_"+id+"_1" 的第一子件进
 * 新 MovieClip；click 播第 2 帧。成员签名逐字取自反编译原文。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorTool.as。
 */
@:keep
class CursorTool extends BaseCursor {
	// CursorTool.as:9
	private var _cursor:MovieClip;

	// CursorTool.as:11-15（ctor 仅 cacheAsBitmap=true——原文即完整，入 stub）
	public function new() {
		super();
		this.cacheAsBitmap = true;
	}

	// CursorTool.as:17-20
	override public function click():Void {
		throw new Error("not implemented");
	}

	// CursorTool.as:22-49（type 两分拼装）
	override private function set_cursorArgument(param1:Dynamic):Dynamic {
		throw new Error("not implemented");
	}
}
