package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.MouseEvent;

// PORT-NOTE: help0316_fla.Page4_5 —— help.swf 第 4 页（SymbolClass 绑
// symbol74），一类对一类翻译自
// legacy/decompiled/help/scripts/help0316_fla/page4_5.as（issue #65）。
// 方法体与 page2_8 逐字同文（仅类名/Embed 符号不同，diff 可证），接线语义
// 与命名依据见 Page2_8.hx / Page1_9.hx 头注。
class Page4_5 extends MovieClip {
	// page4_5.as:10
	public var nextButton:SimpleButton;

	// page4_5.as:12
	public var preButton:SimpleButton;

	// page4_5.as:14-17。原版构造器 addFrameScript(0, frame1)——等价执行由
	// 接线胶水显式调用
	public function new() {
		super();
	}

	// page4_5.as:20-24：nextButton/preButton 各挂 CLICK
	function frame1():Void {
		nextButton.addEventListener(MouseEvent.CLICK, nextButtonClick);
		preButton.addEventListener(MouseEvent.CLICK, preButtonClick);
	}

	// page4_5.as:26-29：dispatchEvent(new Event("nextButtonClick"))，不带
	// bubbles 实参（默认不冒泡）
	public function nextButtonClick(param1:MouseEvent):Void {
		dispatchEvent(new Event("nextButtonClick"));
	}

	// page4_5.as:31-34：dispatchEvent(new Event("preButtonClick"))，不带
	// bubbles 实参（默认不冒泡）
	public function preButtonClick(param1:MouseEvent):Void {
		dispatchEvent(new Event("preButtonClick"));
	}
}
