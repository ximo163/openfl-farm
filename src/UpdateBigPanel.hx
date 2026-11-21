package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// Update.bigPanel —— levelUpUI_v_1.swf 的 SymbolClass 导出符号（char#45）。
// 符号名是「大写包段.小写类段」点路径：Haxe 点路径把大写开头段当模块名，
// 原路径声明不了（deviations monthend-package-lowercase 同因），@:native 把
// 运行时注册键改回原符号名，LevelUpWindow 经 Utils.getMaterial
// ("Update.bigPanel") 的反射字符串一字不动。@:keep + dceAnchor 锚住。
@:keep
@:native("Update.bigPanel")
class UpdateBigPanel extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "levelUpUI_v_1", "Update.bigPanel");
	}
}
