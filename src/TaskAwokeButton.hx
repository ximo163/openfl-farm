package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// taskAwokeButton —— task_v_2.swf（nc_data.php:39 fresherTask 的 src）的
// SymbolClass 导出符号（char#7，6 帧 DefineSprite）。原符号名小写开头
// （monthEndArrow 先例）：@:native 把 js 运行时注册键改回原符号名，
// getMaterial("taskAwokeButton") 的反射字符串一字不动。WelcomeView.
// createBookButton 的 flag==2 分支经 Utils.getMaterial 反射构造（待领任务
// 书页按钮），requestClass("taskAwokeButton",…) 先行短路的类定义也由它供。
@:keep
@:native("taskAwokeButton")
class TaskAwokeButton extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "task_v_2", "taskAwokeButton");
	}
}
