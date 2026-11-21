package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// task5 —— task_v_2.swf（nc_data.php:39 fresherTask 的 src）的 SymbolClass
// 导出符号，第 5 个新手任务的插图。小写符号名 → @:native 改回原注册键
// （monthEndArrow 先例）。WelcomeTaskWindow.setData/rslCallBack 经
// Utils.getMaterial("task" + id) 反射构造，缺号时 requestClass("task"+id,…)

@:keep
@:native("task5")
class Task5 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "task_v_2", "task5");
	}
}
