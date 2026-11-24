package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// ConfirmIcon —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#414，
// 单帧 DefineSprite）。确认窗左上角大图标：ConfirmWindow.customizeIcon 经
// Utils.getMaterial("ConfirmIcon") 反射构造（SuccessIcon/ErrorIcon 同款
// 纯符号绑定，宿主 farmui_full）。（#41）
@:keep
class ConfirmIcon extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "ConfirmIcon");
	}
}
