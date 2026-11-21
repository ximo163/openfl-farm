package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// task10 —— task_v_2.swf（nc_data.php:39 fresherTask 的 src）的 SymbolClass
// 导出符号，第 10 个新手任务的插图。小写符号名 → @:native 改回原注册键
// （monthEndArrow 先例）。WelcomeTaskWindow.setData/rslCallBack 经
// Utils.getMaterial("task" + id) 反射构造，缺号时 requestClass("task"+id,…)

@:keep
@:native("task10")
class Task10 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "task_v_2", "task10");
	}
}
