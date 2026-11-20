package common.view.cursor;

import com.qzone.utils.DisplayUtil;
import common.Consts;
import common.Settings;
import common.misc.Utils;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import shim.As3;

/**
 * common.view.cursor.CursorCropSeed —— CursorCropSeed.as 逐句对应（issue #9）。
 * 种子/鱼苗光标：cursorArgument "类型,id" → 取苗素材挂本体。
 */
@:keep
class CursorCropSeed extends MovieClip {
	// CursorCropSeed.as:13
	private var _cursor:Sprite;

	// CursorCropSeed.as:15-19
	public function new() {
		super();
		this._cursor = null;
	}

	// CursorCropSeed.as:21-55（"类型,id"；seed/fish 查名，缺名/缺素材早退；
	// 素材 cacheAsBitmap + 禁鼠标后挂载）
	public var cursorArgument(never, set):String;

	private function set_cursorArgument(param1:String):String {
		if (param1 == null || param1 == "") {
			return param1;
		}
		var _loc2_:Array<Dynamic> = param1.split(",");
		if (_loc2_ == null || _loc2_.length < 2) {
			return param1;
		}
		var _loc3_:String = _loc2_[0];
		// 原版 `parseInt(_loc2_[1])`（Number）赋给 int 形参的隐式截断
		var _loc4_:Int = As3.intOf(As3.parseInt(_loc2_[1]));
		var _loc5_:String = "";
		if (_loc3_ == Consts.ITEM_TYPE_SEED) {
			_loc5_ = Settings.getInstance().getSeedName(_loc4_);
		} else if (_loc3_ == Consts.ITEM_TYPE_FISH) {
			_loc5_ = Settings.getInstance().getFishName(_loc4_);
		}
		if (_loc5_ == "") {
			return param1;
		}
		this._cursor = cast Utils.getMaterial(_loc5_);
		if (this._cursor == null) {
			return param1;
		}
		this._cursor.cacheAsBitmap = true;
		DisplayUtil.disableMouse(this._cursor);
		addChild(this._cursor);
		return param1;
	}
}
