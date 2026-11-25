package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.MouseEvent;

// PORT-NOTE: help0316_fla.Page3_7 —— help.swf 第 3 页（SymbolClass 绑
// symbol64），一类对一类翻译自
// legacy/decompiled/help/scripts/help0316_fla/page3_7.as（issue #65）。
// 方法体与 page2_8 逐字同文（仅类名/Embed 符号不同，diff 可证），接线语义
// 与命名依据见 Page2_8.hx / Page1_9.hx 头注。
class Page3_7 extends MovieClip {
	// page3_7.as:10
	public var nextButton:SimpleButton;

	// page3_7.as:12
	public var preButton:SimpleButton;

	// page3_7.as:14-17。原版构造器 addFrameScript(0, frame1)——等价执行由
	// 接线胶水显式调用
	public function new() {
		super();
	}

	// page3_7.as:20-24：nextButton/preButton 各挂 CLICK
	function frame1():Void {
		nextButton.addEventListener(MouseEvent.CLICK, nextButtonClick);
		preButton.addEventListener(MouseEvent.CLICK, preButtonClick);
	}

	// page3_7.as:26-29：dispatchEvent(new Event("nextButtonClick"))，不带
	// bubbles 实参（默认不冒泡）
	public function nextButtonClick(param1:MouseEvent):Void {
		dispatchEvent(new Event("nextButtonClick"));
	}

	// page3_7.as:31-34：dispatchEvent(new Event("preButtonClick"))，不带
	// bubbles 实参（默认不冒泡）
	public function preButtonClick(param1:MouseEvent):Void {
		dispatchEvent(new Event("preButtonClick"));
	}
}
