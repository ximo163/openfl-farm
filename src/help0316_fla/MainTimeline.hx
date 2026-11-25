package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.MouseEvent;

// PORT-NOTE: issue #65 write-tests 阶段的 stub（函数体 not implemented；契约由
// test/help0316_fla/MainTimelineTest.hx 钉死，implement 原地填充）。
//
// help0316_fla.MainTimeline —— help.swf（help0316）的文档类（SymbolClass
// 绑 cid 0，无 ExportAssets），一类对一类翻译自
// legacy/decompiled/help/scripts/help0316_fla/MainTimeline.as。根时间轴只有
// 1 帧、五页（原文类名 page1_9/page2_8/page3_7/page4_5/page5_1，小写开头
// 在 Haxe 类型位不接受——Haxe 类相应为 Page1_9/Page2_8/Page3_7/Page4_5/
// Page5_1 + @:native 回键，见各页类头注）同帧全挂，原版全靠
// 本类帧脚本切 visible/挂翻页监听——openfl 的 swf 库只渲染时间轴、不执行
// swf 内部 ABC（issue #65 根因 A），所以行为在翻译类里复原，接线胶水
// （LocalSwfLoader 交给 WelcomeView 的 content 驱动）按 issue 在 shim 落。
//
// 语言差异（CLAUDE.md）：AS3 internal function frame1 → Haxe private；
// frame1 的 `: *` 返回值无消费者（帧脚本不返回），落 Void；`dynamic class`
// 无对应，具名子件以字段保持（AS3 类体声明了五个页字段 + closeButton1，
// 1:1 不增删公共 API）。
class MainTimeline extends MovieClip {
	// MainTimeline.as:10
	public var closeButton1:SimpleButton;

	// MainTimeline.as:12
	public var page2:MovieClip;

	// MainTimeline.as:14
	public var page3:MovieClip;

	// MainTimeline.as:16
	public var page1:MovieClip;

	// MainTimeline.as:18
	public var page5:MovieClip;

	// MainTimeline.as:20
	public var page4:MovieClip;

	// MainTimeline.as:22-25。原版构造器 addFrameScript(0, frame1)——openfl
	// 侧翻译实例不经库时间轴驱动（登记在无 Timeline 的实例上静默丢弃，
	// FrameScriptCompensation 头注同证），frame1 的等价执行由接线胶水显式
	// 调用，implement 阶段落位
	public function new() {
		super();
	}

	// MainTimeline.as:28-46：page1 显、page2..page5 隐、五页各挂
	// "nextButtonClick"/"preButtonClick" 两串事件、closeButton1 隐
	function frame1():Void {
		// issue #65 write-tests stub
		throw new haxe.Exception("not implemented");
	}

	// MainTimeline.as:48-71：五页全隐后按 currentTarget 分支（page1→page2、
	// page2→page3、page3→page4、page4→page5；无 page5 分支）
	public function nextClick(param1:Event):Void {
		// issue #65 write-tests stub
		throw new haxe.Exception("not implemented");
	}

	// MainTimeline.as:73-75。原版帧脚本从未接线（frame1 :45 只把 closeButton1
	// 藏起来，关闭入口只在 page5 的 closeButton2），照译不删；与 page5_1 的
	// bubbles=true 对照，这里的 closeEvent 不带 bubbles 实参（默认 false）
	public function closeButtonClick(param1:MouseEvent):Void {
		// issue #65 write-tests stub
		throw new haxe.Exception("not implemented");
	}

	// MainTimeline.as:78-101：五页全隐后按 currentTarget 分支（page5→page4、
	// page2→page1、page3→page2、page4→page3；无 page1 分支）
	public function preClick(param1:Event):Void {
		// issue #65 write-tests stub
		throw new haxe.Exception("not implemented");
	}
}
