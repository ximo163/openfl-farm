package shim;

import openfl.display.DisplayObject;
import openfl.events.Event;

/**
 * harness 冒烟约定的注入点（平台差异胶水，非新架构）。
 *
 * window.__openflFarmReady 原是 issue #1 探针页的约定（进第一帧置位）；V2 起
 * 预加载器文档类替换探针页，标记改到「主程序 main3 第一帧出现」置位（issue #3
 * 任务书）：FarmLite.startMain 把 module.Main 实例 addChild 后，其第一个
 * ENTER_FRAME 到来时置位——此刻主程序首帧已进入显示列表。
 *
 * 调用点在 module.Main（现为 main3 最小 stub）构造器；main3 正式翻译后该调用
 * 仍是保留的 harness 注入点（stub/正式类头注释都标了）。
 */
class Harness {
	public static function markMainFirstFrame(main:DisplayObject):Void {
		// `once` 先声明再赋值：匿名函数自引用的惯用写法（同 LoadManager 的
		// arguments.callee 注）
		var once:Event->Void = null;
		once = function(param1:Event):Void {
			main.removeEventListener(Event.ENTER_FRAME, once);
			#if html5
			Reflect.setField(js.Browser.window, "__openflFarmReady", true);
			#end
		};
		main.addEventListener(Event.ENTER_FRAME, once);
	}
}
