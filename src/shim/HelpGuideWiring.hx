package shim;

import help0316_fla.MainTimeline;
import help0316_fla.Page1_9;
import help0316_fla.Page2_8;
import help0316_fla.Page3_7;
import help0316_fla.Page4_5;
import help0316_fla.Page5_1;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
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
 *
 * #77 真机复验（2026-11-25，#75 合并后的 APK）收口两个盲区——41 个字段
 * 全部仍在告警，修复在真实加载流一条都没生效：
 *
 * 1. walk 必须下钻 SimpleButton 状态子树（盲区一）：41 = 32 页直挂 +
 *    **9 个 DefineButton2 状态字段**（下一页 5/7/9、上一页 25/27/29、
 *    我明白了 76/78/80，各按钮 up/over/down 态各一份）。#75 教训条说它们
 *    「任何时间轴都没放置、永不实例化」是误判：swf 库
 *    AnimateButtonSymbol.__createObject 经 SimpleButton.__constructor
 *    静态钩子把状态子件建出来（openfl 9.5.2 SimpleButton.hx 构造器消费
 *    钩子）——这 9 个字段真实例化、真参与布局（原版 Flash 里按钮文字
 *    就是渲染的）。SimpleButton 不是 DisplayObjectContainer，只在容器上
 *    递归的 walk 到按钮就停，必须特判遍历 upState/overState/downState/
 *    hitTestState（真按钮 hitTest 是纯 shape 无文字，但修复方向点名
 *    四态都遍历，防御同族 swf）。
 * 2. 修复时点两级（盲区二，node 真实流探针闭合——issue 验收 4 第一条
 *    交付物 tools/HelpRealFlowProbe.hx 的实证）：**布局的真正首次发生点
 *    不在渲染帧，而在加载完成路径里**——openfl 9.5.2 Loader_onComplete
 *    （Loader.hx:783-784）为补 contentLoaderInfo.width/height 读
 *    content.width/content.height，递归量测整棵子树、逐字段触发
 *    __updateLayout 真实布局。attach 挂在 Loader_onComplete 之后的任何
 *    修复都已晚（洞已告警、布局组已残缺，range 簿记补上也救不回——这
 *    就是 issue「显示不对称的注记」缺的那一环）。所以接线侧
 *    （LocalSwfLoader.attachContent）把本 attach 调到 Loader_onComplete
 *    **之前**：量测走到的都是补过洞的 range。attach 后第一个
 *    ENTER_FRAME 的一次性重放仍保留（真机帧相位 ENTER_FRAME 派发 →
 *    时间轴推进 → render，重放落在首帧渲染前）兜「帧内挂载/帧脚本翻开
 *    的页」形态；只放一次即自摘——page5 的 88 号三帧轮换无文字，常驻
 *    监听是白挂。同族先例 Harness.markMainFirstFrame 的 once 自摘法。
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
		// 2. DefineEditText 的 range 补洞（见类头注 2）：attach 时刻走一遍
		//    兜「附着时已齐」的序（#75 探针验证的形态），再挂一次性重放兜
		//    真实流（盲区二——attach 后第一个 ENTER_FRAME 自摘，why 见头注）
		repairTextRanges(content);
		var once:Event->Void = null;
		once = function(param1:Event):Void {
			content.removeEventListener(Event.ENTER_FRAME, once);
			repairTextRanges(content);
			// 诊断转储（diag，不入 main）：布局已随首帧推进发生，此时读
			// 各字段的引擎组态，一次 logcat 定位断点（issue #97）
			dumpTextDiagnostics(content);
		};
		content.addEventListener(Event.ENTER_FRAME, once);
	}

	// 【诊断专用，不入 main】issue #97：真机文字空白断点定位。对树上每个
	// TextField 强制刷新布局后 trace 一行 HTD 结构化数据，覆盖五个嫌疑环：
	//   rng   = 末 range.end / text.length（range 簿记是否补齐，<1 即未补）
	//   grp   = layoutGroups 数（0=布局循环没产出任何组）
	//   pos   = 各组 positions.length 列表（全 0=字形/positions 链断，cpp 特有）
	//   first = 首行组 x,y,w,h（h<=0 即首行高度坍缩——单段字段最可疑形态）
	//   font  = getFontInstance 解析结果（null=字体兜底链断，查 DeviceFonts）
	// 真机 logcat 过滤 "HTD|" 即得全字段账，与 cid 对照（文本前缀可认）。
	private static function dumpTextDiagnostics(content:MovieClip):Void {
		#if android
		var count = 0;
		walkForDiag(content, function(tf:TextField):Void {
			count++;
			try {
				tf.__updateLayout();
			} catch (e:Dynamic) {}
			var engine:TextEngine = tf.__textEngine;
			var textLen = (engine.text == null) ? 0 : engine.text.length;
			var ranges = engine.textFormatRanges;
			var lastEnd = (ranges != null && ranges.length > 0) ? ranges[ranges.length - 1].end : -1;
			var grpCount = (engine.layoutGroups == null) ? 0 : engine.layoutGroups.length;
			var posList = "";
			var firstInfo = "none";
			// 决定性补充（issue #97 第二轮）：positions.length 已证正常却仍不显示，
			// 唯一剩下的机制是 cairo 渲染循环 CairoTextField.hx:312 `position.glyph == 0`
			// 跳过 .notdef 字形。抓首组逐 position 的 glyph id + advance.x ——
			// 全 0/全同 = 字形未塑形（harfbuzz 断）；有效 = 断点在更下游。
			var glyphInfo = "none";
			if (engine.layoutGroups != null) {
				for (i in 0...engine.layoutGroups.length) {
					var g = engine.layoutGroups[i];
					if (posList != "") posList += ",";
					posList += (g.positions == null) ? "n" : Std.string(g.positions.length);
				}
				if (engine.layoutGroups.length > 0) {
					var f0 = engine.layoutGroups[0];
					firstInfo = "x" + Std.int(f0.offsetX) + ",y" + Std.int(f0.offsetY)
						+ ",w" + Std.int(f0.width * 10) / 10 + ",h" + f0.height;
					// 首组逐字形: g<glyph id>a<advance.x 整数>
					if (f0.positions != null) {
						glyphInfo = "";
						var gi = 0;
						for (pos in f0.positions) {
							if (gi >= 12) { glyphInfo += "…"; break; }
							if (glyphInfo != "") glyphInfo += ",";
							if (pos == null) {
								glyphInfo += "null";
							} else {
								glyphInfo += Std.int(pos.glyph) + "@" + Std.int(pos.advance.x);
							}
							gi++;
						}
					}
				}
			}
			var fi = openfl.text._internal.TextEngine.getFontInstance(
				(ranges != null && ranges.length > 0) ? ranges[0].format : null);
			var fontName = (fi == null) ? "NULL" : fi.fontName;
			var preview = (engine.text == null) ? "" : engine.text.substr(0, 6);
			// preview 里的 \n 会把 trace 拆行（真机 logcat 每条 trace 前缀重复），
			// 换成可见符便于单行解析（不影响语义，诊断专用）
			preview = StringTools.replace(preview, "\n", "~");
			// 显示树/变换链（最后一个未抓变量）：glyph 若有效却仍不显示，唯一剩
			// 的就是渲染被变换/可见性/裁剪干掉。抓 tf 的 visible/alpha/世界坐标宽高/
			// 父链 visible，以及 textBounds（cairo 裁剪框）。
			var vis = tf.visible ? "T" : "F";
			var alpha = Std.int(tf.alpha * 100);
			var wx = 0.0; var wy = 0.0; var ww = 0.0; var wh = 0.0;
			try {
				var wb = tf.getBounds(tf.stage);
				wx = Std.int(wb.x); wy = Std.int(wb.y); ww = Std.int(wb.width); wh = Std.int(wb.height);
			} catch (e:Dynamic) {}
			var chain = "";
			var par = tf.parent;
			var depth = 0;
			while (par != null && depth < 8) {
				chain += (par.visible ? "." : "!");
				par = par.parent;
				depth++;
			}
			var tb = engine.textBounds;
			var tbInfo = (tb == null) ? "null" : (Std.int(tb.x) + "," + Std.int(tb.y) + "," + Std.int(tb.width) + "," + Std.int(tb.height));
			trace("HTD|" + count + "|" + preview + "|rng" + lastEnd + "/" + textLen
				+ "|grp" + grpCount + "|pos[" + posList + "]|f0[" + firstInfo + "]|font=" + fontName
				+ "|gl[" + glyphInfo + "]"
				+ "|vis" + vis + alpha + "|wb[" + wx + "," + wy + "," + ww + "," + wh + "]|par" + chain
				+ "|tb[" + tbInfo + "]"
				+ "|sv" + tf.scrollV + "/" + tf.bottomScrollV + "/" + tf.maxScrollV);
		});
		#end
	}

	private static function walkForDiag(obj:DisplayObject, fn:TextField->Void):Void {
		if (obj == null) return;
		if (Std.isOfType(obj, TextField)) {
			fn(cast obj);
			return;
		}
		if (Std.isOfType(obj, SimpleButton)) {
			var b:SimpleButton = cast obj;
			walkForDiag(b.upState, fn);
			walkForDiag(b.overState, fn);
			walkForDiag(b.downState, fn);
			walkForDiag(b.hitTestState, fn);
			return;
		}
		if (Std.isOfType(obj, DisplayObjectContainer)) {
			var c:DisplayObjectContainer = cast obj;
			for (i in 0...c.numChildren) {
				walkForDiag(c.getChildAt(i), fn);
			}
		}
	}

	// 树上每个 TextField：textFormatRanges（openfl.Vector，非 Array——裸
	// 下标/裸 length 在 js 上是 undefined，cpp 上更没有裸通道，必须类型化
	// 访问）最后一个 range 的 end 补到 text.length。HTMLParser 产物 range
	// 顺序无缝，唯一的洞就是文末换行，一次补齐。重复跑幂等（last.end 已
	// 到位的条件不命中），attach 时刻 + 重放两轮无叠加效应
	private static function repairTextRanges(container:DisplayObjectContainer):Void {
		for (i in 0...container.numChildren) {
			repairChild(container.getChildAt(i));
		}
	}

	// 盲区一的分流（见类头注 #77-1）：TextField 补洞；SimpleButton 不是容器
	// 但状态子件真实例化真参与布局，四态（是容器就）继续走；普通容器递归。
	// 状态态的判空/判容器边界：默认构造的 SimpleButton upState 是裸
	// DisplayObject（非容器，走不到递归）、over/down 是 null，都须无操作通过
	private static function repairChild(child:DisplayObject):Void {
		if (child == null) {
			return;
		}
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
			// issue #97：htmlText 赋值把 caret 放到文末空行（TextField.hx:2604），
			// 此后每次 __updateLayout 都 setSelection→__updateScrollV 把字段滚到
			// caret 行（:2388/:2509），内容行被渲染跳过（CairoTextField.hx:264）。
			// Flash 不随 htmlText 自动滚动；caret 归 0 后每次布局都维持 scrollV=1
			tf.setSelection(0, 0);
		} else if (Std.isOfType(child, SimpleButton)) {
			var btn:SimpleButton = cast child;
			repairChild(btn.upState);
			repairChild(btn.overState);
			repairChild(btn.downState);
			repairChild(btn.hitTestState);
		} else if (Std.isOfType(child, DisplayObjectContainer)) {
			repairTextRanges(cast child);
		}
	}
}
