package shim;

import haxe.Json;
import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import sys.io.File;
import utest.Assert;

/**
 * shim.HelpGuideWiring 的 range 补洞契约（issue #77 write-tests 阶段，对带
 * 盲区的现行实现失败）。#65/#75 已把修复挂上（LocalSwfLoader.attachContent
 * libraryId=="help" → attach，attach 时刻对树走一遍修复），真机
 * 2026-11-25 复验收口：
 * 41 个 DefineEditText 仍全部告警「You found a bug in OpenFL's text code!」，
 * 修复在真实加载流一条都没生效——本文件钉 issue #77 点名的两个盲区：
 *
 * - 盲区一（修复方向 1，代码级实锤）：repairTextRanges 只递归
 *   DisplayObjectContainer，SimpleButton 不是容器，walk 到按钮就停——
 *   9 个字段（下一页 5/7/9、上一页 25/27/29、我明白了 76/78/80）埋在
 *   DefineButton2 的 up/over/down 状态子 sprite 里，真例化真参与布局
 *   （swf 库 AnimateButtonSymbol.__createObject 经 SimpleButton.__constructor
 *   静态钩子建四态子件，openfl 9.5.2 SimpleButton.hx 构造器消费钩子；原版
 *   Flash 里按钮文字就是渲染的——#65 教训条「9 个死符号」系误判），
 *   永远修不到。修复方向：遇 SimpleButton 特判，遍历
 *   upState/overState/downState/hitTestState（是容器就继续走）。
 * - 盲区二（修复方向 2，真机证据指向）：attachContent 回调时刻树上还没
 *   有这些字段（真机 41 条 = 修复在真实流一条未生效），修复必须改到
 *   「attach 后第一个 ENTER_FRAME」重放一次再自摘（一次性监听）。
 *
 * 期望值出处（CLAUDE.md 出处规则）：
 * - 41 个字段的 HTML 原文/属性与挂载账：test/fixtures/help-fields.json，
 *   由 legacy/decompiled/help/swf.xml 提取——DefineEditTextTag initialText
 *   （41 条）、DefineSpriteTag 21/45/64/74/94 的 PlaceObject2（32 条页直挂）、
 *   DefineButton2Tag 11/30/82/98 的 BUTTONRECORD buttonStateUp/Over/Down
 *   （9 条状态字段，各按钮三态各一份）。issue #77 的字段账（32+9=41、
 *   显示/空白的 range 分界）即此文件，测试期望值一律以它为准。
 * - 洞源：openfl 9.5.2 openfl/text/_internal/HTMLParser.hx 关闭 </p> 追
 *   "\n" 不入任何 range（help 41 字段全是 <p>…</p><p></p> 双段形态）；
 *   告警位 openfl/text/_internal/TextEngine.hx setFormattedPositions/
 *   placeFormattedText（range 耗尽即告警 break）。issue #77 验收原文的断言
 *   面「最后 range end == text.length」即补洞后的不变式，本文件全部断言
 *   都是对它（控制组见 test_fixture_* 的天然覆盖行）。
 * - 一次性重放：issue #77 修复方向 2（「重放一次再自摘」原文）；驱动面
 *   定在 attach 收到的 content 上（LocalSwfLoader.attachContent 传进来的
 *   就是 content 根时间轴；真机帧相位 Stage.__processPhase 是
 *   ENTER_FRAME 派发 → __enterFrame 时间轴推进 → render 布局，重放落在
 *   首帧渲染前，覆盖 attach 时刻还不存在的挂载）。
 *
 * 载体：openfl 实例当纯数据用（无舞台无渲染——TextField 的 htmlText 解析
 * 是纯字符串处理，range 表即解析产物；SimpleButton 四态是普通字段），同款
 * 先例 test/help0316_fla/MainTimelineTest.hx（空实例钉字段）；ENTER_FRAME
 * 用 EventDispatcher 内存监听表手动派发，同款先例 FrameTimerTest 的
 * FakeStage。node 真实流测试（LocalSwfLoader 加载真库、真帧推进、
 * console.warn 0 命中——issue 验收 1「不许再用探针手工触发 textWidth 代替
 * 真实流」）与真机复验按 issue 走 implement 阶段 + owner。
 */
@:access(openfl.text.TextField)
class HelpGuideWiringTest {
	// legacy/decompiled/help/swf.xml 的提取产物（见类头注出处节）：41 字段
	// HTML + 挂载账。fixture 相对仓库根（haxe test.hxml 的运行目录）解析，
	// TimelineSpecTest 的同款约定
	static final FIXTURE:String = "test/fixtures/help-fields.json";

	// fixture 的页次序（sprite 21/45/64/74/94 = page1..page5 的放置序）
	static final PAGE_ORDER:Array<Int> = [21, 45, 64, 74, 94];
	// 按钮状态键（BUTTONRECORD 里挂文字的三态）：AnimateButtonSymbol.
	// __constructor 经 SimpleButton.__constructor 钩子写四态，openfl SimpleButton
	// 的公共属性落点名即 upState/overState/downState/hitTestState——文字只在
	// up/over/down 三态（hitTest 是纯 shape，单独处理见 buildHelpTree）
	static final STATE_ORDER:Array<String> = ["up", "over", "down"];

	static var fixtureCache:Dynamic = null;

	public function new() {}

	private static function fixture():Dynamic {
		if (fixtureCache == null) {
			fixtureCache = Json.parse(File.getContent(FIXTURE));
		}
		return fixtureCache;
	}

	// 按 fixture 里该 cid 的 DefineEditText 属性建字段（multiline 先于
	// htmlText 置位：HTMLParser 只在 multiline 下追段尾 "\n"，洞才有形）
	private function makeField(cid:Int):TextField {
		var spec:Dynamic = Reflect.field(Reflect.field(fixture(), "fields"), Std.string(cid));
		var tf = new TextField();
		tf.multiline = spec.multiline == true;
		tf.htmlText = spec.html;
		return tf;
	}

	// issue #77 验收原文的断言面：树上每个 TextField 的最后一个 range 的
	// end 补到 text.length
	private function lastRangeEnd(tf:TextField):Int {
		var ranges = tf.__textEngine.textFormatRanges;
		return ranges[ranges.length - 1].end;
	}

	private function textLength(tf:TextField):Int {
		return tf.__textEngine.text.length;
	}

	private function assertCovered(tf:TextField, label:String):Void {
		var ranges = tf.__textEngine.textFormatRanges;
		Assert.isTrue(ranges != null && ranges.length > 0, label + "：range 表非空");
		if (ranges != null && ranges.length > 0) {
			Assert.equals(textLength(tf), lastRangeEnd(tf),
				label + "：末 range end 须补到 text.length（issue #77 验收原文；"
				+ "HTMLParser 关闭 </p> 追 \\n 不入 range 是洞源）");
		}
	}

	/**
	 * 按 fixture 挂载账把 help.swf 的字段树建进 content：content（根时间轴）
	 * → 五页 sprite → 每页直挂字段 + 按钮实例（up/over/down 状态 sprite 里
	 * 各一份该态的 DefineEditText 实例，hitTest 状态 sprite 无文字——真按钮
	 * 的 hitTest 是纯 shape cid 10/81）+ page5 内嵌的 88 号三帧 shape 轮换
	 * sprite；根级另有 closeButton1（按钮 98，四态纯 shape 无文字，
	 * MainTimeline.frame1 :45 隐藏）。返回全部 TextField 实例（断言面）：
	 * 32 个直挂实例（每定义恰放置一次）+ 27 个按钮状态实例（按钮 11 放
	 * 4 页、30 放 4 页、82 放 1 页，11/30/82 各 3 态；98 无文字不出账）。
	 */
	private function buildHelpTree(content:MovieClip):Array<TextField> {
		var fix = fixture();
		var instances = new Array<TextField>();
		var pages:Dynamic = Reflect.field(fix, "pages");
		var buttonStates:Dynamic = Reflect.field(fix, "button_states");
		for (pageId in PAGE_ORDER) {
			var page = new MovieClip();
			content.addChild(page);
			var spec:Dynamic = Reflect.field(pages, Std.string(pageId));
			for (cid in (spec.texts:Array<Int>)) {
				var tf = makeField(cid);
				page.addChild(tf);
				instances.push(tf);
			}
			for (nested in (spec.nested:Array<Int>)) {
				// 页内嵌套 sprite（page5 的 88）：无文字，walk 须穿透无害
				page.addChild(new MovieClip());
			}
			for (bid in (spec.buttons:Array<Int>)) {
				var states:Dynamic = Reflect.field(buttonStates, Std.string(bid));
				var btn = new SimpleButton();
				for (state in STATE_ORDER) {
					var holder = new Sprite();
					// 按钮定义无文字态时该态留空 sprite，walk 须无操作
					var stateCid:Int = states == null ? -1 : Reflect.field(states, state);
					if (stateCid > 0) {
						var tf = makeField(stateCid);
						holder.addChild(tf);
						instances.push(tf);
					}
					switch (state) {
						case "up": btn.upState = holder;
						case "over": btn.overState = holder;
						case "down": btn.downState = holder;
					}
				}
				btn.hitTestState = new Sprite();
				page.addChild(btn);
			}
		}
		// 根时间轴直属的 closeButton1（按钮 98）：四态纯 shape 无文字，
		// 真树在根上，walk 须无操作通过
		var rootSpec:Dynamic = Reflect.field(fix, "root");
		for (bid in (rootSpec.buttons:Array<Int>)) {
			var rootBtn = new SimpleButton();
			rootBtn.upState = new Sprite();
			rootBtn.overState = new Sprite();
			rootBtn.downState = new Sprite();
			rootBtn.hitTestState = new Sprite();
			content.addChild(rootBtn);
		}
		return instances;
	}

	// ---- fixture 账与前提（洞确实存在）：对现行实现是绿的，钉住修复的
	// 意义与断言面；openfl 升级若改变 HTMLParser 行为，这里先红。

	/**
	 * fixture 必须与 issue #77 的字段账逐项一致：41 条 DefineEditText =
	 * 32 页直挂 + 9 按钮状态；五页 sprite 次序 21/45/64/74/94；根级
	 * closeButton1（按钮 98）四态无文字。
	 * 出处：legacy/decompiled/help/swf.xml（DefineEditTextTag、主时间轴与
	 * DefineSpriteTag subTags 的 PlaceObject2、DefineButton2Tag
	 * BUTTONRECORD）；issue #77「字段账」节。
	 */
	public function test_fixture_field_account_matches_issue() {
		var fix = fixture();
		Assert.equals(41, Reflect.fields(Reflect.field(fix, "fields")).length,
			"help.swf 全部 41 个 DefineEditText（issue #77 字段账）");
		Assert.same(PAGE_ORDER, (fix.pageOrder:Array<Int>),
			"五页 sprite 次序（fixture 提取自 swf.xml 主时间轴 PlaceObject2 的 page1..page5）");
		var direct = 0;
		var pages:Dynamic = Reflect.field(fix, "pages");
		for (pid in Reflect.fields(pages)) {
			direct += (Reflect.field(pages, pid).texts:Array<Int>).length;
		}
		Assert.equals(32, direct, "32 个页直挂字段（五页 sprite subTags 的 PlaceObject2）");
		var bs:Dynamic = Reflect.field(fix, "button_states");
		var stateDefs = 0;
		for (bid in Reflect.fields(bs)) {
			stateDefs += Reflect.fields(Reflect.field(bs, bid)).length;
		}
		Assert.equals(9, stateDefs, "9 个按钮状态字段定义（下一页 5/7/9、上一页 25/27/29、我明白了 76/78/80）");
		// closeButton1 在根时间轴（depth 145），四态纯 shape（95/96/97）、无文字
		var rootSpec:Dynamic = Reflect.field(fix, "root");
		Assert.same([98], (rootSpec.buttons:Array<Int>),
			"根级唯一按钮是 closeButton1（98；closeButton2 在 page5 内）");
		Assert.isNull(Reflect.field(bs, "98"),
			"closeButton1 四态无文字（真机 41 条告警不含它——按钮状态账恰 9 条）");
	}

	/**
	 * 修复前提：41 个字段的真实 HTML 在 openfl 9.5.2 HTMLParser 下全都留洞
	 * （末 range end < text.length——关闭 </p> 追 "\n" 不入 range，help 41
	 * 字段全是 <p>…</p><p></p> 双段形态，字字命中）。控制组：无标签纯文本
	 * 单 range 本就覆盖全文，修复条件天然不命中（HelpGuideWiring 头注 2 的
	 * 「非分段 HTML 字段天然跳过」——防实现把补洞写成无差别重建）。
	 * 出处：legacy/decompiled/help/swf.xml DefineEditTextTag initialText；
	 * openfl 9.5.2 HTMLParser.hx:131-144（issue #77 代码证据链）。
	 */
	public function test_fixture_all_41_leave_uncovered_tail_and_plain_text_does_not() {
		var fields:Dynamic = Reflect.field(fixture(), "fields");
		for (cid in Reflect.fields(fields)) {
			var tf = makeField(Std.parseInt(cid));
			Assert.isTrue(lastRangeEnd(tf) < textLength(tf),
				"cid " + cid + " 修复前末 range 不达文末（HTMLParser 洞，fixture 即修复存在的前提）");
		}
		var plain = new TextField();
		plain.multiline = true;
		plain.htmlText = "新手引导";
		Assert.equals(textLength(plain), lastRangeEnd(plain),
			"无标签纯文本天然覆盖，修复不得无差别动 range（控制组）");
	}

	// ---- 盲区一（issue #77 修复方向 1）：walk 下钻 SimpleButton 状态子树

	/**
	 * walk 对 SimpleButton 状态子树的可达性（issue 验收 4 单测侧原文「模拟
	 * 一个 SimpleButton + 状态内 TextField」）：按钮 up/over/down 态用真实
	 * 账的 cid 5/7/9（按钮 11 三态各一份，swf.xml BUTTONRECORD），hitTest
	 * 真资产是纯 shape 无文字、但修复方向 1 点名四态都遍历，用同款 HTML
	 * 钉可达性。对现行实现红：walk 不是容器递归不到按钮就停。
	 */
	public function test_walk_reaches_all_four_simplebutton_states() {
		var content = new MovieClip();
		var page = new MovieClip();
		content.addChild(page);
		var bs:Dynamic = Reflect.field(fixture(), "button_states");
		var states:Dynamic = Reflect.field(bs, "11");
		var btn = new SimpleButton();
		var stateTfs = new Array<TextField>();
		// up/over/down 按真实账；hitTest 真按钮无文字，此处挂同款字段钉遍历
		var statePlan:Array<{state:String, cid:Int}> = [
			{state: "up", cid: states.up},
			{state: "over", cid: states.over},
			{state: "down", cid: states.down},
			{state: "hitTest", cid: states.up},
		];
		for (plan in statePlan) {
			var holder = new Sprite();
			var tf = makeField(plan.cid);
			holder.addChild(tf);
			stateTfs.push(tf);
			switch (plan.state) {
				case "up": btn.upState = holder;
				case "over": btn.overState = holder;
				case "down": btn.downState = holder;
				case "hitTest": btn.hitTestState = holder;
			}
		}
		page.addChild(btn);
		HelpGuideWiring.attach(content);
		content.dispatchEvent(new Event(Event.ENTER_FRAME));
		for (i in 0...stateTfs.length) {
			assertCovered(stateTfs[i],
				"SimpleButton " + statePlan[i].state + "State 里的字段（walk 盲区一："
				+ "SimpleButton 不是 DisplayObjectContainer，只在容器上递归的 walk 到按钮就停）");
		}
	}

	/**
	 * 全树挂载账对拍（issue 验收 1 的单测侧对应面：树上全部 41 个字段定义
	 * 的实例，含按钮状态里的 9 个定义）：按 fixture 建全树——32 直挂 +
	 * 27 按钮状态实例（11×4 页 + 30×4 页 + 82×1 页，各 3 态），attach +
	 * 首帧后逐实例断言。对现行实现红在 27 个状态实例（32 直挂经 attach
	 * 时刻的修复已绿——本例同时是直挂面的回归锚）。
	 */
	public function test_first_frame_repairs_full_tree_including_button_states() {
		var content = new MovieClip();
		var instances = buildHelpTree(content);
		HelpGuideWiring.attach(content);
		content.dispatchEvent(new Event(Event.ENTER_FRAME));
		Assert.equals(59, instances.length,
			"32 直挂 + 27 按钮状态实例（按钮 11 放 4 页、30 放 4 页、82 放 1 页，各 3 态；98 无文字）");
		for (i in 0...instances.length) {
			assertCovered(instances[i], "树上实例 " + i);
		}
	}

	// ---- 盲区二（issue #77 修复方向 2）：attach 后第一个 ENTER_FRAME 重放

	/**
	 * 真机证据形态（issue「盲区二」原文：attachContent 时刻树上还没有这些
	 * 字段）：attach 先行、字段后挂（页面时间轴子件挂载晚于 attach 回调），
	 * 修复必须由 attach 后第一个 ENTER_FRAME 的一次性重放补到。对现行实现
	 * 全红（无重放，59 实例一个都修不到——真机 41 条告警即此形态）。
	 */
	public function test_first_frame_replay_repairs_fields_mounted_after_attach() {
		var content = new MovieClip();
		HelpGuideWiring.attach(content);
		// attach 之后、首帧之前才挂上树（真机盲区二的挂载时点）
		var instances = buildHelpTree(content);
		content.dispatchEvent(new Event(Event.ENTER_FRAME));
		for (i in 0...instances.length) {
			assertCovered(instances[i], "attach 后挂载的实例 " + i);
		}
	}

	/**
	 * 「重放一次再自摘」的一次性钉板（issue 修复方向 2 原文）：首个
	 * ENTER_FRAME 重放修到此前挂上的字段；重放自摘后，后续帧对新挂上的
	 * 带洞字段不再修（不许把一次性监听写成常驻监听）。对现行实现红在
	 * 第一段断言（无重放）。
	 */
	public function test_replay_fires_once_then_self_removes() {
		var content = new MovieClip();
		HelpGuideWiring.attach(content);
		var page1 = new MovieClip();
		content.addChild(page1);
		var first = makeField(3);
		page1.addChild(first);
		content.dispatchEvent(new Event(Event.ENTER_FRAME));
		assertCovered(first, "首个 ENTER_FRAME 的重放修到 attach 后挂上的字段");
		var page2 = new MovieClip();
		content.addChild(page2);
		var second = makeField(3);
		page2.addChild(second);
		content.dispatchEvent(new Event(Event.ENTER_FRAME));
		Assert.isTrue(lastRangeEnd(second) < textLength(second),
			"重放一次后监听自摘，第二个 ENTER_FRAME 不再重放（后续帧新挂的带洞字段保持原样）");
	}

	/**
	 * walk 健壮性（cpp null 安全同款门，#37/#63 家族）：默认构造的
	 * SimpleButton（upState 是裸 DisplayObject、over/down 为 null、hitTest
	 * 非 null 非容器）与无文字态按钮（98 形态）在树上不得让 walk 抛错，
	 * 同页正常字段仍须修到。对现行实现绿（现行 walk 直接绕过按钮），
	 * 钉住下钻实现必须的判空/判容器边界。
	 */
	public function test_walk_tolerates_textless_and_partial_state_buttons() {
		var content = new MovieClip();
		var page = new MovieClip();
		content.addChild(page);
		page.addChild(new SimpleButton());
		var bare = new SimpleButton();
		bare.upState = new Sprite();
		bare.overState = new Sprite();
		bare.downState = new Sprite();
		bare.hitTestState = new Sprite();
		page.addChild(bare);
		var tf = makeField(3);
		page.addChild(tf);
		HelpGuideWiring.attach(content);
		content.dispatchEvent(new Event(Event.ENTER_FRAME));
		assertCovered(tf, "按钮缺文字/缺态不影响同页字段修复");
	}
}
