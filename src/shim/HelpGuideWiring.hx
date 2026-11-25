package shim;

import help0316_fla.MainTimeline;
import help0316_fla.Page1_9;
import help0316_fla.Page2_8;
import help0316_fla.Page3_7;
import help0316_fla.Page4_5;
import help0316_fla.Page5_1;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.text.TextField;
import openfl.text._internal.TextEngine;

/**
 * help.swf 新手引导的接线胶水（issue #65；为什么在 shim：原版 help.swf 自带
 * 完整 AS3——Flash 在装库时执行 swf 内部 ABC，openfl 的 swf 资产管线
 * （AnimateLibrary/AnimateTimeline）只渲染时间轴、不执行 ABC，两处原版行为
 * 在 openfl 侧都没有发生点，只能由 shim 显式复原，且都是「平台差异薄胶水」
 * 而非新架构）：
 *
 * 1. 帧脚本等价执行（根因 A）：help0316_fla 6 类已按反编译原文 1:1 翻译在
 *    src/help0316_fla/，库按 SymbolClass 名实例化它们
 *    （AnimateSpriteSymbol.__createObject → resolveClass(formatClassName 大写
 *    名)——Haxe 默认注册名恰为该大写名，故翻译类不加 @:native，加了反而
 *    注册成小写原名、resolveClass 落 null、库静默回退裸 MovieClip，探针
 *    实证见 lessons）。实例化本身不跑帧脚本：原版构造器
 *    addFrameScript(0, frame1) 登记的 frame1 在 openfl 侧被静默丢弃
 *    （无 Timeline 的实例），这里按「先页后根」显式调用——Flash 里帧脚本
 *    在显示树构造完、首帧渲染前收尾执行，本调用点在 loadLibrary 的同步
 *    onComplete 里、任何渲染之前，语义等价且无中间帧可见（不会闪出五页
 *    同帧全叠）。closeEvent 收尾链由此通：page5 的 closeButtonClick 派发
 *    bubbles=true 的 "closeEvent"，沿页 → content 冒泡，接到
 *    WelcomeView.onLoadHelpCompleted 挂在 content 上的裸串监听（252 行）。
 *
 * 2. DefineEditText 文字渲染修复（根因 B）：41 个 DefineEditText 的 htmlText
 *    形如 `<p …>正文</font></p><p …></p>`，openfl 9.5.2 的 HTMLParser
 *    （HTMLParser.hx:128-133）在关闭 `</p>`/`</li>` 时向文本追 "\n"，但只
 *    在 `start < segment.length` 才 push 覆盖该段的 TextFormatRange——段尾
 *    的 `</p>` 追加的换行不在任何 range 里。TextEngine 布局循环
 *    （TextEngine.hx:1184）走到 range 未覆盖的文本时 nextFormatRange 耗尽
 *    → "You found a bug in OpenFL's text code!" 警告 + 布局中断（真机 41
 *    条日志即此，node 探针对拍 32 个实例化字段全 uncovered=2、修复后 0
 *    告警）。修复选 issue 的路径 b（不动文字内容与格式）：把最后一个
 *    range 的 end 补到 text.length——纯簿记，追加的换行本就该沿用前段
 *    格式（Flash 对文末空段的语义），修复后布局循环走到 endIndex 正常
 *    收尾。补一次即持久（range 是引擎状态，update 只读不再重建）。
 *    非分段 HTML 字段最后一段 range 本就覆盖全文，条件不命中、天然跳过。
 *
 * 范围按 issue 边界只挂在 help 库（LocalSwfLoader.attachContent 里按
 * libraryId=="help" 调用），同族 swf 的同款 HTMLParser 缺口不在此扩散。
 * help 全库仅根时间轴 1 帧、五页各 1 帧、唯一多帧符号 88 是三张 shape 的
 * 轮换（无文字）——附着时树上的 TextField 集合即全集，一次性修复完备，
 * 无需后续帧补漏（9 个 DefineEditText 是从未被任何时间轴放置的死符号，
 * 永不实例化、也不渲染）。
 */
@:access(help0316_fla.MainTimeline)
@:access(help0316_fla.Page1_9)
@:access(help0316_fla.Page2_8)
@:access(help0316_fla.Page3_7)
@:access(help0316_fla.Page4_5)
@:access(help0316_fla.Page5_1)
@:access(openfl.text.TextField)
class HelpGuideWiring {
	// LocalSwfLoader.attachContent 在 COMPLETE 派发后同步调用（帧脚本等价
	// 与文字修复都得赶在首帧渲染前）。content = 库根时间轴
	public static function attach(content:MovieClip):Void {
		// 1. 帧脚本等价：先五页 frame1（按钮接线），再根 frame1（翻页监听 +
		//    初态可见性 + 藏根级 closeButton1）——次序无交叉依赖，与 Flash
		//    帧脚本收尾时序等价
		if (Std.isOfType(content, MainTimeline)) {
			var mt:MainTimeline = cast content;
			if (Std.isOfType(mt.page1, Page1_9)) {
				cast(mt.page1, Page1_9).frame1();
			}
			if (Std.isOfType(mt.page2, Page2_8)) {
				cast(mt.page2, Page2_8).frame1();
			}
			if (Std.isOfType(mt.page3, Page3_7)) {
				cast(mt.page3, Page3_7).frame1();
			}
			if (Std.isOfType(mt.page4, Page4_5)) {
				cast(mt.page4, Page4_5).frame1();
			}
			if (Std.isOfType(mt.page5, Page5_1)) {
				cast(mt.page5, Page5_1).frame1();
			}
			mt.frame1();
		}
		// 2. DefineEditText 的 range 补洞（见类头注 2）
		repairTextRanges(content);
	}

	// 树上每个 TextField：textFormatRanges（openfl.Vector，非 Array——裸
	// 下标/裸 length 在 js 上是 undefined，cpp 上更没有裸通道，必须类型化
	// 访问）最后一个 range 的 end 补到 text.length。HTMLParser 产物 range
	// 顺序无缝，唯一的洞就是文末换行，一次补齐
	private static function repairTextRanges(container:DisplayObjectContainer):Void {
		for (i in 0...container.numChildren) {
			var child = container.getChildAt(i);
			if (Std.isOfType(child, TextField)) {
				var tf:TextField = cast child;
				var engine:TextEngine = tf.__textEngine;
				var ranges = engine.textFormatRanges;
				if (ranges != null && ranges.length > 0 && engine.text != null) {
					var last = ranges[ranges.length - 1];
					if (last.end < engine.text.length) {
						last.end = engine.text.length;
						// 布局还没首跑（htmlText 置位后本就是脏的），这里再
						// 置一次兜「附着前已有测量」的极端序
						tf.__layoutDirty = true;
					}
				}
			} else if (Std.isOfType(child, DisplayObjectContainer)) {
				repairTextRanges(cast child);
			}
		}
	}
}
