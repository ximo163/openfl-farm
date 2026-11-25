package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.MouseEvent;

// PORT-NOTE: issue #65 write-tests 阶段的 stub（函数体 not implemented；契约由
// test/help0316_fla/PagesTest.hx 钉死，implement 原地填充）。
//
// help0316_fla.Page5_1 —— help.swf 第 5 页（末页，SymbolClass 绑 symbol94），
// 一类对一类翻译自 legacy/decompiled/help/scripts/help0316_fla/page5_1.as。
// 帧脚本只做按钮接线：preButton 的 CLICK 转发 "preButtonClick"、closeButton2
// 的 CLICK 转发 "closeEvent"——后者带 bubbles=true 实参（page5_1.as:28），
// 是整个引导唯一的冒泡事件：靠它从页里冒到库根时间轴（content），才被
// WelcomeView 挂在 content 上的 "closeEvent" 监听接到（onGuideFinished →
// CMD_WELCOME_END / startNewTask 收尾链，issue #65 症状 5）。openfl 不执行
// swf 内部 ABC，行为在翻译类里复原、接线胶水按 issue 在 shim 落。
//
// 命名（assets.md ② / Task1、MonthEndArrow 同款）：原文类名 page5_1 小写
// 开头，Haxe 类型位词法不接受（new/类型标注直接解析红，4.3.6 实测）——
// 类名只把首字母大写成 Page5_1，@:native 把运行时注册键改回原文全名
// help0316_fla.page5_1（Type.getClassName/resolveClass 都按原名走）。
//
// 语言差异同 MainTimeline.hx：internal frame1 → private、`: *` 返回落 Void。
@:native("help0316_fla.page5_1")
class Page5_1 extends MovieClip {
	// page5_1.as:10
	public var closeButton2:SimpleButton;

	// page5_1.as:12
	public var preButton:SimpleButton;

	// page5_1.as:14-17。原版构造器 addFrameScript(0, frame1)——等价执行由
	// 接线胶水显式调用，implement 阶段落位
	public function new() {
		super();
	}

	// page5_1.as:20-24：preButton/closeButton2 各挂 CLICK
	function frame1():Void {
		// issue #65 write-tests stub
		throw new haxe.Exception("not implemented");
	}

	// page5_1.as:26-29：dispatchEvent(new Event("closeEvent", true))——
	// bubbles=true 别丢（issue #65 修复路径 1 的点名项）
	public function closeButtonClick(param1:MouseEvent):Void {
		// issue #65 write-tests stub
		throw new haxe.Exception("not implemented");
	}

	// page5_1.as:31-34：dispatchEvent(new Event("preButtonClick"))，不带
	// bubbles 实参（默认不冒泡）
	public function preButtonClick(param1:MouseEvent):Void {
		// issue #65 write-tests stub
		throw new haxe.Exception("not implemented");
	}
}
