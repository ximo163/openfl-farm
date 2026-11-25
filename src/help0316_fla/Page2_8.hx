package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.MouseEvent;

// PORT-NOTE: help0316_fla.Page2_8 —— help.swf 第 2 页（SymbolClass 绑
// symbol45），一类对一类翻译自
// legacy/decompiled/help/scripts/help0316_fla/page2_8.as（issue #65）。
// 帧脚本只做按钮接线：nextButton/preButton 的 CLICK 各转发裸串事件
// "nextButtonClick"/"preButtonClick"（MainTimeline.frame1 监听它们翻页），
// openfl 不执行 swf 内部 ABC（根因 A），行为在翻译类里复原、帧脚本等价
// 执行由 shim 接线胶水显式调用（HelpGuideWiring）。
//
// 命名（write-tests 阶段的 ② @:native 回键法已被证伪、implement 撤掉）：
// 原文类名 page2_8 小写开头，Haxe 类型位词法不接受，类名只把首字母大写成
// Page2_8；不能加 @:native 回键——库实例化按 formatClassName 大写名
// resolveClass，恰等于 Haxe 默认注册名，@:native 注册小写原名反而让
// resolveClass 落 null、库回退裸 MovieClip（详见 Page1_9.hx 头注）。
//
// 语言差异同 MainTimeline.hx：internal frame1 → private、`: *` 返回落 Void。
class Page2_8 extends MovieClip {
	// page2_8.as:10
	public var nextButton:SimpleButton;

	// page2_8.as:12
	public var preButton:SimpleButton;

	// page2_8.as:14-17。原版构造器 addFrameScript(0, frame1)——等价执行由
	// 接线胶水显式调用
	public function new() {
		super();
	}

	// page2_8.as:20-24：nextButton/preButton 各挂 CLICK
	function frame1():Void {
		nextButton.addEventListener(MouseEvent.CLICK, nextButtonClick);
		preButton.addEventListener(MouseEvent.CLICK, preButtonClick);
	}

	// page2_8.as:26-29：dispatchEvent(new Event("nextButtonClick"))，不带
	// bubbles 实参（默认不冒泡）
	public function nextButtonClick(param1:MouseEvent):Void {
		dispatchEvent(new Event("nextButtonClick"));
	}

	// page2_8.as:31-34：dispatchEvent(new Event("preButtonClick"))，不带
	// bubbles 实参（默认不冒泡）
	public function preButtonClick(param1:MouseEvent):Void {
		dispatchEvent(new Event("preButtonClick"));
	}
}
