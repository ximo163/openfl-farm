package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.MouseEvent;
import utest.Assert;

/**
 * help0316_fla.MainTimeline 纯面（issue #65 write-tests 阶段，对 stub 失败；
 * 契约：五页 visible 翻页状态机 + 根级 closeEvent 的非冒泡极性 + 组合链）。
 *
 * 出处：legacy/decompiled/help/scripts/help0316_fla/MainTimeline.as（FFDec
 * 24.0.1 从 help.swf 导出，行号以该文件为准）：
 * - frame1 :28-46（:30-34 page1 显 page2..5 隐、:35-39 五页挂
 *   "nextButtonClick"、:40-44 五页挂 "preButtonClick"、:45 closeButton1 隐）；
 * - nextClick :48-71（:50-54 先五页全隐，:55-70 按 currentTarget 分支
 *   page1→page2 / page2→page3 / page3→page4 / page4→page5，无 page5 分支）；
 * - closeButtonClick :73-75（new Event("closeEvent") 不带 bubbles 实参）；
 * - preClick :78-101（:80-84 先全隐，:85-100 分支 page5→page4 / page2→page1
 *   / page3→page2 / page4→page3，无 page1 分支）。
 * issue #65 的验收原文（next 按 1→2→3→4→5 顺序翻页、pre 回退、第 5 页
 * closeButton2 触发 closeEvent → 收尾链）即本文件末两条组合链。
 *
 * 载体：openfl MovieClip/SimpleButton 实例当纯数据用（无舞台无渲染——
 * visible 是布尔字段、Event 走 EventDispatcher 内存监听表，openfl
 * DisplayObject.__dispatchEvent 沿内存 parent 链冒泡，不碰 stage）；
 * test/module/GameGuideTest.hx 的「空实例 + 钉字段 + 显示载体」与
 * DragManagerTest 的脱树 MouseEvent 派发先例同款。AS3 原版五页/closeButton1
 * 由库根时间轴的 PlaceObject 命名填充；openfl 侧由接线胶水（issue 修复
 * 路径 2：从 content 驱动 5 页与按钮——具名子件 / SymbolClass 取符号两条
 * 路 implement 验证后择一）喂进本类字段，喂的是哪只不影响本测试钉的
 * frame1/nextClick/preClick 语义。
 *
 * 不在单测里的：接线胶水的显示层行为与 41 个 DefineEditText 的文字渲染
 * （issue 根因 B，openfl TextEngine 在 cpp 的 bug，implement 需在 linux/cpp
 * 重现）由 CI web-smoke（uid=1 fixture "welcome":1 必经 showNewGuide，
 * handbook/architecture/tasks.md）与真机验收负责。
 */
@:access(help0316_fla.MainTimeline)
@:access(help0316_fla.Page1_9)
@:access(help0316_fla.Page2_8)
@:access(help0316_fla.Page3_7)
@:access(help0316_fla.Page4_5)
@:access(help0316_fla.Page5_1)
class MainTimelineTest {
	public function new() {}

	// frame1 前把 AS3 类体声明的公共字段全钉上载体（MainTimeline.as:10-20
	// 的五个页字段 + closeButton1——1:1 不增删公共 API，字段必有），再跑
	// frame1（:28-46）。stub 阶段 frame1 抛 not implemented，本文件全红
	private function makeRoot():MainTimeline {
		var mt = new MainTimeline();
		mt.closeButton1 = new SimpleButton();
		mt.page1 = new MovieClip();
		mt.page2 = new MovieClip();
		mt.page3 = new MovieClip();
		mt.page4 = new MovieClip();
		mt.page5 = new MovieClip();
		mt.frame1();
		return mt;
	}

	// 可见性向量 [page1..page5]：nextClick/preClick 的全部输出都落在这五个
	// 字段上，矩阵断言的比较面
	private function vis(mt:MainTimeline):Array<Bool> {
		return [mt.page1.visible, mt.page2.visible, mt.page3.visible, mt.page4.visible, mt.page5.visible];
	}

	private function pageOf(mt:MainTimeline, index:Int):MovieClip {
		return switch (index) {
			case 1: mt.page1;
			case 2: mt.page2;
			case 3: mt.page3;
			case 4: mt.page4;
			case 5: mt.page5;
			default: throw new haxe.Exception("page index " + index);
		};
	}

	// MainTimeline.as:30-34（page1.visible=true、page2..page5.visible=false）
	// + :45（closeButton1.visible=false——根级关闭钮原版永远隐藏，关闭入口
	// 只在 page5 的 closeButton2；issue #65 症状 4「右上角出现关闭按钮」
	// 就是这行没跑）
	public function test_frame1_shows_only_page1_and_hides_closeButton1() {
		var mt = makeRoot();
		Assert.same([true, false, false, false, false], vis(mt), "frame1 后只有 page1 可见（:30-34）");
		Assert.isFalse(mt.closeButton1.visible, "closeButton1.visible = false（:45）");
	}

	// MainTimeline.as:48-71 nextClick，经 :35-39（frame1 给五页都挂了
	// "nextButtonClick"）的真实派发路径驱动：nextButtonClick 从 pageN 派发
	// → currentTarget==pageN（:55-70 的比对基准）→ 先五页全隐（:50-54）再显
	// 下一页。page5 行是 if/else 链落空的原文字面行为：帧脚本也给 page5 挂
	// 了 next 监听（:39），但 nextClick 没有 page5 分支——全隐后不显任何页
	public function test_nextClick_forward_matrix() {
		var rows:Array<{from:Int, expect:Array<Bool>}> = [
			{from: 1, expect: [false, true, false, false, false]}, // :55-58 page1→page2
			{from: 2, expect: [false, false, true, false, false]}, // :59-62 page2→page3
			{from: 3, expect: [false, false, false, true, false]}, // :63-66 page3→page4
			{from: 4, expect: [false, false, false, false, true]}, // :67-70 page4→page5
			{from: 5, expect: [false, false, false, false, false]}, // 落空：无 page5 分支
		];
		for (row in rows) {
			var mt = makeRoot();
			pageOf(mt, row.from).dispatchEvent(new Event("nextButtonClick"));
			Assert.same(row.expect, vis(mt), "nextButtonClick 从 page" + row.from + " 派发后的可见性");
		}
	}

	// MainTimeline.as:78-101 preClick，经 :40-44（五页全挂 "preButtonClick"）
	// 的派发路径驱动。分支次序原文即 page5 最先（:85-88）、其后 page2/3/4
	// （:89-100）——互斥的相等比对次序不影响输出，期望向量只按落点。
	// page1 行是落空分支：preClick 没有 page1 分支（第一页没有回退去处），
	// 全隐后不显任何页
	public function test_preClick_backward_matrix() {
		var rows:Array<{from:Int, expect:Array<Bool>}> = [
			{from: 5, expect: [false, false, false, true, false]}, // :85-88 page5→page4
			{from: 4, expect: [false, false, true, false, false]}, // :97-100 page4→page3
			{from: 3, expect: [false, true, false, false, false]}, // :93-96 page3→page2
			{from: 2, expect: [true, false, false, false, false]}, // :89-92 page2→page1
			{from: 1, expect: [false, false, false, false, false]}, // 落空：无 page1 分支
		];
		for (row in rows) {
			var mt = makeRoot();
			pageOf(mt, row.from).dispatchEvent(new Event("preButtonClick"));
			Assert.same(row.expect, vis(mt), "preButtonClick 从 page" + row.from + " 派发后的可见性");
		}
	}

	// MainTimeline.as:73-75 closeButtonClick：dispatchEvent(new Event("closeEvent"))
	// 不带 bubbles 实参 → 不冒泡，父级收不到。与 page5_1.as:28 的
	// new Event("closeEvent", true) 对照（bubbles=true 只在 page5 一处）。
	// 原版帧脚本从未把本方法接到 closeButton1（frame1 只把钮藏了），1:1
	// 照译保留死方法；本例钉「别把 bubbles=true 抄错位」
	public function test_closeButtonClick_dispatches_non_bubbling_closeEvent() {
		var mt = makeRoot();
		var parent = new MovieClip();
		parent.addChild(mt);
		var got = 0;
		var sawBubbles:Null<Bool> = null;
		mt.addEventListener("closeEvent", function(e:Event):Void {
			got++;
			sawBubbles = e.bubbles;
		});
		var parentGot = 0;
		parent.addEventListener("closeEvent", function(e:Event):Void parentGot++);
		mt.closeButtonClick(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, got, "自身恰收一发 closeEvent（:75）");
		if (Assert.notNull(sawBubbles)) {
			Assert.isFalse(sawBubbles, "不带 bubbles 实参（:75，默认 false）");
		}
		Assert.equals(0, parentGot, "不冒泡：父级收不到——对照 page5_1.as:28 的 bubbles=true");
	}

	// 组合链 1（issue #65 验收原文「next 按 1→2→3→4→5 顺序翻页、pre 回退」
	// 的单实例连续版）：一帧内五页的监听与可见性状态跨步推进不残留——
	// 每步向量与矩阵行一致（MainTimeline.as:48-71/:78-101）
	public function test_guide_sequence_next_forward_then_pre_backward() {
		var mt = makeRoot();
		var forward:Array<{from:Int, expect:Array<Bool>}> = [
			{from: 1, expect: [false, true, false, false, false]},
			{from: 2, expect: [false, false, true, false, false]},
			{from: 3, expect: [false, false, false, true, false]},
			{from: 4, expect: [false, false, false, false, true]},
		];
		for (step in forward) {
			pageOf(mt, step.from).dispatchEvent(new Event("nextButtonClick"));
			Assert.same(step.expect, vis(mt), "连续 next：page" + step.from + " 派发后");
		}
		var backward:Array<{from:Int, expect:Array<Bool>}> = [
			{from: 5, expect: [false, false, false, true, false]},
			{from: 4, expect: [false, false, true, false, false]},
			{from: 3, expect: [false, true, false, false, false]},
			{from: 2, expect: [true, false, false, false, false]},
		];
		for (step in backward) {
			pageOf(mt, step.from).dispatchEvent(new Event("preButtonClick"));
			Assert.same(step.expect, vis(mt), "连续 pre：page" + step.from + " 派发后");
		}
	}

	// 组合链 2：页类实例当页载体（MainTimeline.pageN 字段与派发方同一只，
	// :55-70 的 currentTarget 比对才成立；页挂在根下——原版根时间轴 1 帧
	// 五页全挂，closeEvent 要沿这棵树冒到根）。按钮 CLICK 的完整链路＝
	// page.frame1 接线（page1_9.as:20 / page5_1.as:23）→ page 转发裸串事件
	// → MainTimeline.nextClick/preClick 翻页；末步 closeButton2 →
	// closeEvent bubbles=true（page5_1.as:28）冒到根——content 上监听
	// "closeEvent" 的 WelcomeView.onGuideFinished（WelcomeView.hx:252，issue
	// #65 症状 5 的收尾链）就靠这一跳
	public function test_full_guide_click_chain_reaches_root_close() {
		var mt = new MainTimeline();
		mt.closeButton1 = new SimpleButton();

		var p1 = new Page1_9();
		p1.nextButton = new SimpleButton();
		var p2 = new Page2_8();
		p2.nextButton = new SimpleButton();
		p2.preButton = new SimpleButton();
		var p3 = new Page3_7();
		p3.nextButton = new SimpleButton();
		p3.preButton = new SimpleButton();
		var p4 = new Page4_5();
		p4.nextButton = new SimpleButton();
		p4.preButton = new SimpleButton();
		var p5 = new Page5_1();
		p5.closeButton2 = new SimpleButton();
		p5.preButton = new SimpleButton();

		mt.page1 = p1;
		mt.page2 = p2;
		mt.page3 = p3;
		mt.page4 = p4;
		mt.page5 = p5;
		mt.addChild(p1);
		mt.addChild(p2);
		mt.addChild(p3);
		mt.addChild(p4);
		mt.addChild(p5);

		p1.frame1();
		p2.frame1();
		p3.frame1();
		p4.frame1();
		p5.frame1();
		mt.frame1();

		Assert.same([true, false, false, false, false], vis(mt), "初态只有第一页（MainTimeline.as:30-34）");

		p1.nextButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.same([false, true, false, false, false], vis(mt), "点 page1 的 next → 第二页");
		p2.nextButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.same([false, false, true, false, false], vis(mt), "点 page2 的 next → 第三页");
		p3.nextButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.same([false, false, false, true, false], vis(mt), "点 page3 的 next → 第四页");
		p4.nextButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.same([false, false, false, false, true], vis(mt), "点 page4 的 next → 末页");

		p5.preButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.same([false, false, false, true, false], vis(mt), "末页 pre 回退一页");

		var rootGot = 0;
		mt.addEventListener("closeEvent", function(e:Event):Void rootGot++);
		p5.closeButton2.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, rootGot, "closeButton2 的 closeEvent 冒泡到根（page5_1.as:28 bubbles=true）");
	}
}
