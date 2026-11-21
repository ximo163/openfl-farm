package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// taskingButton —— task_v_2.swf（nc_data.php:39 fresherTask 的 src）的
// SymbolClass 导出符号（char#2，单帧 DefineSprite；WelcomeView 按 Sprite 用，
// MovieClip 基类是它的超类）。小写符号名 → @:native 改回原注册键
// （monthEndArrow 先例）。WelcomeView.createBookButton 的 flag==1 分支经
// Utils.getMaterial 反射构造（进行中任务书页按钮）。
@:keep
@:native("taskingButton")
class TaskingButton extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "task_v_2", "taskingButton");
	}
}
