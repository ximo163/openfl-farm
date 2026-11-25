package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.MouseEvent;

// PORT-NOTE: help0316_fla.Page1_9 —— help.swf 第 1 页（SymbolClass 绑
// symbol21），一类对一类翻译自
// legacy/decompiled/help/scripts/help0316_fla/page1_9.as（issue #65）。
// 帧脚本只做按钮接线：nextButton 的 CLICK 转发裸串事件 "nextButtonClick"
// （MainTimeline.frame1 监听它翻页），openfl 不执行 swf 内部 ABC（根因 A），
// 行为在翻译类里复原、帧脚本等价执行由 shim 接线胶水显式调用
// （HelpGuideWiring，挂在 LocalSwfLoader.attachContent）。
//
// 命名（write-tests 阶段的 ② @:native 回键法已被证伪、implement 撤掉）：
// 原文类名 page1_9 小写开头，Haxe 类型位词法不接受（4.3.6 实测），类名只把
// 首字母大写成 Page1_9；**不能**加 @:native("help0316_fla.page1_9") 回键——
// 库实例化走 AnimateSpriteSymbol.__createObject →
// Type.resolveClass(SymbolUtils.formatClassName(className))，formatClassName
// 把类名段首字母大写（"help0316_fla.page1_9" → "help0316_fla.Page1_9"），
// 恰等于 Haxe 的默认注册名；加 @:native 反而把注册键改成小写原名、
// resolveClass 大写名落 null，库静默回退成裸 MovieClip，翻译类永不实例化
// （探针实证：resolveClass("…Page1_9")=null / resolveClass("…page1_9")=类）。
// ② @:native 回键只适用于 ExportAssets 小写符号名直查的场合
// （getMaterial("task1") 一类，见 tasks.md 的 Task 垫片）。
//
// 语言差异同 MainTimeline.hx：internal frame1 → private、`: *` 返回落 Void。
class Page1_9 extends MovieClip {
	// page1_9.as:10
	public var nextButton:SimpleButton;

	// page1_9.as:12-15。原版构造器 addFrameScript(0, frame1)——等价执行由
	// 接线胶水显式调用
	public function new() {
		super();
	}

	// page1_9.as:18-21：nextButton 挂 CLICK
	function frame1():Void {
		nextButton.addEventListener(MouseEvent.CLICK, nextButtonClick);
	}

	// page1_9.as:23-26：dispatchEvent(new Event("nextButtonClick"))，不带
	// bubbles 实参（默认不冒泡）
	public function nextButtonClick(param1:MouseEvent):Void {
		dispatchEvent(new Event("nextButtonClick"));
	}
}
