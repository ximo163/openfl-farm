package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.MouseEvent;

// PORT-NOTE: help0316_fla.MainTimeline —— help.swf（help0316）的文档类
// （SymbolClass 绑 cid 0，无 ExportAssets），一类对一类翻译自
// legacy/decompiled/help/scripts/help0316_fla/MainTimeline.as（issue #65）。
// 根时间轴只有 1 帧、五页 + closeButton1 同帧全挂（导出 data.json 可证），
// 原版全靠本类帧脚本切 visible/挂翻页监听——openfl 的 swf 库只渲染时间轴、
// 不执行 swf 内部 ABC（根因 A），行为在翻译类里复原，帧脚本的等价执行由
// shim 接线胶水（HelpGuideWiring，挂在 LocalSwfLoader.attachContent）显式
// 调用——addFrameScript 在无 Timeline 的翻译实例上静默丢弃
// （FrameScriptCompensation 头注同证）。
//
// 类注册名：库按 SymbolUtils.formatClassName（类名段首字母大写）resolveClass
// —— help0316_fla.MainTimeline 恰是 Haxe 默认注册名，无需 @:native（页类
// 名小写开头、formatClassName 把首字母大写后恰等于 Haxe 默认注册名，同理；
// 详见 HelpGuideWiring 头注）。
//
// 语言差异（CLAUDE.md）：AS3 internal function frame1 → Haxe private；
// frame1 的 `: *` 返回值无消费者（帧脚本不返回），落 Void；`dynamic class`
// 无对应，具名子件以字段保持（AS3 类体声明了五个页字段 + closeButton1，
// 1:1 不增删公共 API）。库装好后 AnimateTimeline.__updateInstanceFields 会
// 按字段名从 PlaceObject 命名子件自动回填这些字段（implement 探针实证）。
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
	// 侧翻译实例不经库时间轴驱动（登记在无 Timeline 的实例上静默丢弃），
	// frame1 的等价执行由接线胶水显式调用
	public function new() {
		super();
	}

	// MainTimeline.as:28-46：page1 显、page2..page5 隐、五页各挂
	// "nextButtonClick"/"preButtonClick" 两串事件、closeButton1 隐
	function frame1():Void {
		// MainTimeline.as:30-34
		page1.visible = true;
		page2.visible = false;
		page3.visible = false;
		page4.visible = false;
		page5.visible = false;
		// MainTimeline.as:35-39
		page1.addEventListener("nextButtonClick", nextClick);
		page2.addEventListener("nextButtonClick", nextClick);
		page3.addEventListener("nextButtonClick", nextClick);
		page4.addEventListener("nextButtonClick", nextClick);
		page5.addEventListener("nextButtonClick", nextClick);
		// MainTimeline.as:40-44
		page1.addEventListener("preButtonClick", preClick);
		page2.addEventListener("preButtonClick", preClick);
		page3.addEventListener("preButtonClick", preClick);
		page4.addEventListener("preButtonClick", preClick);
		page5.addEventListener("preButtonClick", preClick);
		// MainTimeline.as:45
		closeButton1.visible = false;
	}

	// MainTimeline.as:48-71：五页全隐后按 currentTarget 分支（page1→page2、
	// page2→page3、page3→page4、page4→page5；无 page5 分支——落空即全隐）
	public function nextClick(param1:Event):Void {
		// MainTimeline.as:50-54
		page1.visible = false;
		page2.visible = false;
		page3.visible = false;
		page4.visible = false;
		page5.visible = false;
		// MainTimeline.as:55-70
		if (param1.currentTarget == page1) {
			page2.visible = true;
		} else if (param1.currentTarget == page2) {
			page3.visible = true;
		} else if (param1.currentTarget == page3) {
			page4.visible = true;
		} else if (param1.currentTarget == page4) {
			page5.visible = true;
		}
	}

	// MainTimeline.as:73-75。原版帧脚本从未接线（frame1 :45 只把 closeButton1
	// 藏起来，关闭入口只在 page5 的 closeButton2），照译不删；与 page5_1 的
	// bubbles=true 对照，这里的 closeEvent 不带 bubbles 实参（默认 false）
	public function closeButtonClick(param1:MouseEvent):Void {
		dispatchEvent(new Event("closeEvent"));
	}

	// MainTimeline.as:78-101：五页全隐后按 currentTarget 分支（分支次序原文即
	// page5 最先、其后 page2/page3/page4；无 page1 分支——落空即全隐）
	public function preClick(param1:Event):Void {
		// MainTimeline.as:80-84
		page1.visible = false;
		page2.visible = false;
		page3.visible = false;
		page4.visible = false;
		page5.visible = false;
		// MainTimeline.as:85-100
		if (param1.currentTarget == page5) {
			page4.visible = true;
		} else if (param1.currentTarget == page2) {
			page1.visible = true;
		} else if (param1.currentTarget == page3) {
			page2.visible = true;
		} else if (param1.currentTarget == page4) {
			page3.visible = true;
		}
	}
}
