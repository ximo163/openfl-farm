package shim;

import openfl.net.URLRequest;

/**
 * flash.net.navigateToURL 的目标相关等价物（CLAUDE.md：openfl 对
 * navigateToURL 支持不完整，等价物进 shim）。
 *
 * 为什么这样分目标：原版调用点开外部网页（PersonInfo.as:343 的 VIP 特权
 * 详情链接，窗口名走浏览器默认）。html5 是浏览器环境，window.open 语义
 * 等价（window 传 null 时浏览器按 _blank 处理，同 AS3 默认）；非浏览器
 * 目标（cpp/android/eval）没有可开的浏览器，原版在这类环境也无从打开，
 * 留痕不抛、静默降级一致。
 */
class NavigateToURL {
	public static function navigateToURL(param1:URLRequest, param2:String = null):Void {
		#if html5
		js.Browser.window.open(param1.url, param2);
		#else
		trace("NavigateToURL: 无浏览器目标不打开 " + param1.url);
		#end
	}
}
