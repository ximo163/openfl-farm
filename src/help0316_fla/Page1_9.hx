package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.MouseEvent;

// PORT-NOTE: issue #65 write-tests 阶段的 stub（函数体 not implemented；契约由
// test/help0316_fla/PagesTest.hx 钉死，implement 原地填充）。
//
// help0316_fla.Page1_9 —— help.swf 第 1 页（SymbolClass 绑 symbol21），一类
// 对一类翻译自 legacy/decompiled/help/scripts/help0316_fla/page1_9.as。帧
// 脚本只做按钮接线：nextButton 的 CLICK 转发裸串事件 "nextButtonClick"
// （MainTimeline.frame1 监听它翻页），openfl 不执行 swf 内部 ABC（issue #65
// 根因 A），行为在翻译类里复原、接线胶水按 issue 在 shim 落。
//
// 命名（assets.md ② / Task1、MonthEndArrow 同款）：原文类名 page1_9 小写
// 开头，Haxe 类型位词法不接受（new/类型标注直接解析红，4.3.6 实测）——
// 类名只把首字母大写成 Page1_9，@:native 把运行时注册键改回原文全名
// help0316_fla.page1_9（Type.getClassName/resolveClass 都按原名走）。
//
// 语言差异同 MainTimeline.hx：internal frame1 → private、`: *` 返回落 Void。
@:native("help0316_fla.page1_9")
class Page1_9 extends MovieClip {
	// page1_9.as:10
	public var nextButton:SimpleButton;

	// page1_9.as:12-15。原版构造器 addFrameScript(0, frame1)——等价执行由
	// 接线胶水显式调用，implement 阶段落位
	public function new() {
		super();
	}

	// page1_9.as:18-21：nextButton 挂 CLICK
	function frame1():Void {
		// issue #65 write-tests stub
		throw new haxe.Exception("not implemented");
	}

	// page1_9.as:23-26：dispatchEvent(new Event("nextButtonClick"))，不带
	// bubbles 实参（默认不冒泡）
	public function nextButtonClick(param1:MouseEvent):Void {
		// issue #65 write-tests stub
		throw new haxe.Exception("not implemented");
	}
}
