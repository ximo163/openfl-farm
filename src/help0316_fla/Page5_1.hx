package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.MouseEvent;

// PORT-NOTE: help0316_fla.Page5_1 —— help.swf 第 5 页（末页，SymbolClass 绑
// symbol94），一类对一类翻译自
// legacy/decompiled/help/scripts/help0316_fla/page5_1.as（issue #65）。
// 帧脚本只做按钮接线：preButton 的 CLICK 转发 "preButtonClick"、closeButton2
// 的 CLICK 转发 "closeEvent"——后者带 bubbles=true 实参（page5_1.as:28），
// 是整个引导唯一的冒泡事件：靠它从页里冒到库根时间轴（content），才被
// WelcomeView 挂在 content 上的 "closeEvent" 监听接到（onGuideFinished →
// CMD_WELCOME_END / startNewTask 收尾链，issue #65 症状 5）。openfl 不执行
// swf 内部 ABC（根因 A），行为在翻译类里复原、帧脚本等价执行由 shim 接线
// 胶水显式调用（HelpGuideWiring）。
//
// 命名（write-tests 阶段的 ② @:native 回键法已被证伪、implement 撤掉）：
// 原文类名 page5_1 小写开头，Haxe 类型位词法不接受，类名只把首字母大写成
// Page5_1；不能加 @:native 回键——库实例化按 formatClassName 大写名
// resolveClass，恰等于 Haxe 默认注册名，@:native 注册小写原名反而让
// resolveClass 落 null、库回退裸 MovieClip（详见 Page1_9.hx 头注）。
//
// 语言差异同 MainTimeline.hx：internal frame1 → private、`: *` 返回落 Void。
class Page5_1 extends MovieClip {
	// page5_1.as:10
	public var closeButton2:SimpleButton;

	// page5_1.as:12
	public var preButton:SimpleButton;

	// page5_1.as:14-17。原版构造器 addFrameScript(0, frame1)——等价执行由
	// 接线胶水显式调用
	public function new() {
		super();
	}

	// page5_1.as:20-24：preButton/closeButton2 各挂 CLICK
	function frame1():Void {
		preButton.addEventListener(MouseEvent.CLICK, preButtonClick);
		closeButton2.addEventListener(MouseEvent.CLICK, closeButtonClick);
	}

	// page5_1.as:26-29：dispatchEvent(new Event("closeEvent", true))——
	// bubbles=true 别丢（issue #65 修复路径 1 的点名项）
	public function closeButtonClick(param1:MouseEvent):Void {
		dispatchEvent(new Event("closeEvent", true));
	}

	// page5_1.as:31-34：dispatchEvent(new Event("preButtonClick"))，不带
	// bubbles 实参（默认不冒泡）
	public function preButtonClick(param1:MouseEvent):Void {
		dispatchEvent(new Event("preButtonClick"));
	}
}
