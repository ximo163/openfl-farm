package help0316_fla;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.MouseEvent;
import utest.Assert;

/**
 * help0316_fla 五个页类的按钮接线纯面（issue #65 write-tests 阶段，对 stub
 * 失败；契约：frame1 的 CLICK → 裸串事件转发恰一发、bubbles 极性与
 * page5 closeEvent 的冒泡）。
 *
 * 出处：legacy/decompiled/help/scripts/help0316_fla/ 下各类（FFDec 24.0.1
 * 从 help.swf 导出；页 2/3/4 的 .as 逐字同文，仅类名/Embed 符号不同——
 * page2_8 绑 symbol45、page3_7 绑 symbol64、page4_5 绑 symbol74，diff 可证）：
 * - page1_9.as:18-21（frame1：nextButton 挂 CLICK）、:23-26
 *   （nextButtonClick：dispatchEvent(new Event("nextButtonClick"))，不带
 *   bubbles 实参 → 默认不冒泡）；
 * - page2_8.as（= page3_7.as = page4_5.as）:20-24（两枚按钮各挂 CLICK）、
 *   :26-29（nextButtonClick → "nextButtonClick"）、:31-34（preButtonClick →
 *   "preButtonClick"，同样不带 bubbles 实参）；
 * - page5_1.as:20-24（preButton/closeButton2 各挂 CLICK）、:26-29
 *   （closeButtonClick → new Event("closeEvent", true)——整个引导唯一的
 *   bubbles=true，issue #65 修复路径 1 的点名项「别丢，靠它冒泡到
 *   WelcomeView」）、:31-34（preButtonClick → "preButtonClick"）。
 * 这些字符串事件非 Event 常量，MainTimeline.frame1（MainTimeline.as:35-44）
 * 用裸串监听——handbook/architecture/tasks.md 的约定：别顺手换成常量。
 *
 * 载体：openfl SimpleButton/MovieClip 实例当纯数据用（无舞台无渲染；
 * DragManagerTest 的脱树 MouseEvent 派发先例同款）。AS3 原版按钮字段由
 * 页符号时间轴的 PlaceObject 命名填充；openfl 侧由接线胶水喂（issue
 * 修复路径 2，implement 验证后落），本测试只钉 frame1/各转发方法的语义。
 * 接线胶水的显示层行为与 41 个 DefineEditText 的文字渲染（issue 根因 B）
 * 不在单测——CI web-smoke 与真机验收负责（同 MainTimelineTest 类头注）。
 */
@:access(help0316_fla.Page1_9)
@:access(help0316_fla.Page2_8)
@:access(help0316_fla.Page3_7)
@:access(help0316_fla.Page4_5)
@:access(help0316_fla.Page5_1)
class PagesTest {
	public function new() {}

	// 三枚引导字符串事件的总听记录器：count(name) 计数、bubbles(name) 记
	// 首发时的 bubbles 旗标（未发过为 null——计数为 0 时别读它）。挂在页
	// 实例上，转发出来的事件全在本实例上派发（各 *Click 方法体都是
	// dispatchEvent，接收者 this）
	private function recorder(page:MovieClip):{count:String->Int, bubbles:String->Null<Bool>} {
		var counts = new Map<String, Int>();
		var flags = new Map<String, Bool>();
		for (name in ["nextButtonClick", "preButtonClick", "closeEvent"]) {
			counts.set(name, 0);
			page.addEventListener(name, function(e:Event):Void {
				counts.set(name, counts.get(name) + 1);
				if (!flags.exists(name)) {
					flags.set(name, e.bubbles);
				}
			});
		}
		return {
			count: function(name:String):Int {
				return counts.get(name);
			},
			bubbles: function(name:String):Null<Bool> {
				return flags.exists(name) ? flags.get(name) : null;
			}
		};
	}

	// page1_9.as:18-26：nextButton 的 CLICK 恰转发一发 "nextButtonClick"
	// （MainTimeline.frame1 靠它翻页，MainTimeline.as:35），其余两枚引导
	// 事件都不发，bubbles 默认 false
	public function test_page1_nextButton_click_forwards_nextButtonClick_only() {
		var p = new Page1_9();
		p.nextButton = new SimpleButton();
		var rec = recorder(p);
		p.frame1();
		p.nextButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, rec.count("nextButtonClick"), "nextButton CLICK → 恰一发 nextButtonClick（:20/:25）");
		Assert.isFalse(rec.bubbles("nextButtonClick"), "不带 bubbles 实参（:25，默认不冒泡）");
		Assert.equals(0, rec.count("preButtonClick"), "page1 无 preButton（:10 只声明 nextButton），也不许误发 pre");
		Assert.equals(0, rec.count("closeEvent"), "不触发关闭");
	}

	// page2_8.as:20-34：两枚按钮各转发各的事件，互不牵连；两枚都不带
	// bubbles 实参。page3_7/page4_5 同文同断言（见下两例）
	public function test_page2_buttons_forward_both_directions() {
		var p = new Page2_8();
		p.nextButton = new SimpleButton();
		p.preButton = new SimpleButton();
		var rec = recorder(p);
		p.frame1();
		p.nextButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, rec.count("nextButtonClick"), "nextButton CLICK → 恰一发 nextButtonClick（:22 接线）");
		Assert.equals(0, rec.count("preButtonClick"), "next 侧不牵连 pre");
		Assert.isFalse(rec.bubbles("nextButtonClick"), "不带 bubbles 实参（:28）");
		p.preButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, rec.count("preButtonClick"), "preButton CLICK → 恰一发 preButtonClick（:23 接线）");
		Assert.equals(1, rec.count("nextButtonClick"), "pre 点击不重发 next");
		Assert.isFalse(rec.bubbles("preButtonClick"), "不带 bubbles 实参（:33）");
		Assert.equals(0, rec.count("closeEvent"), "不触发关闭");
	}

	// page3_7.as:20-34（与 page2_8 逐字同文，仅类名/Embed 符号不同）
	public function test_page3_buttons_forward_both_directions() {
		var p = new Page3_7();
		p.nextButton = new SimpleButton();
		p.preButton = new SimpleButton();
		var rec = recorder(p);
		p.frame1();
		p.nextButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, rec.count("nextButtonClick"), "nextButton CLICK → 恰一发 nextButtonClick（:22 接线）");
		Assert.equals(0, rec.count("preButtonClick"), "next 侧不牵连 pre");
		Assert.isFalse(rec.bubbles("nextButtonClick"), "不带 bubbles 实参（:28）");
		p.preButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, rec.count("preButtonClick"), "preButton CLICK → 恰一发 preButtonClick（:23 接线）");
		Assert.equals(1, rec.count("nextButtonClick"), "pre 点击不重发 next");
		Assert.isFalse(rec.bubbles("preButtonClick"), "不带 bubbles 实参（:33）");
		Assert.equals(0, rec.count("closeEvent"), "不触发关闭");
	}

	// page4_5.as:20-34（与 page2_8 逐字同文，仅类名/Embed 符号不同）
	public function test_page4_buttons_forward_both_directions() {
		var p = new Page4_5();
		p.nextButton = new SimpleButton();
		p.preButton = new SimpleButton();
		var rec = recorder(p);
		p.frame1();
		p.nextButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, rec.count("nextButtonClick"), "nextButton CLICK → 恰一发 nextButtonClick（:22 接线）");
		Assert.equals(0, rec.count("preButtonClick"), "next 侧不牵连 pre");
		Assert.isFalse(rec.bubbles("nextButtonClick"), "不带 bubbles 实参（:28）");
		p.preButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, rec.count("preButtonClick"), "preButton CLICK → 恰一发 preButtonClick（:23 接线）");
		Assert.equals(1, rec.count("nextButtonClick"), "pre 点击不重发 next");
		Assert.isFalse(rec.bubbles("preButtonClick"), "不带 bubbles 实参（:33）");
		Assert.equals(0, rec.count("closeEvent"), "不触发关闭");
	}

	// page5_1.as:22 + :31-34：末页 preButton 只转发 "preButtonClick"（不冒泡），
	// 不触发关闭（关闭只归 closeButton2）
	public function test_page5_preButton_click_forwards_preButtonClick_only() {
		var p = new Page5_1();
		p.closeButton2 = new SimpleButton();
		p.preButton = new SimpleButton();
		var rec = recorder(p);
		p.frame1();
		p.preButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, rec.count("preButtonClick"), "preButton CLICK → 恰一发 preButtonClick（:22 接线）");
		Assert.isFalse(rec.bubbles("preButtonClick"), "不带 bubbles 实参（:33，默认不冒泡）");
		Assert.equals(0, rec.count("nextButtonClick"), "page5 无 nextButton（:10-12 只有 closeButton2/preButton）");
		Assert.equals(0, rec.count("closeEvent"), "pre 不触发关闭");
	}

	// page5_1.as:23 + :26-29：closeButton2 的 CLICK → closeEvent，bubbles=true
	// ——整个引导唯一的冒泡事件：沿页 → 库根时间轴（content）这棵树冒上去，
	// WelcomeView.onLoadHelpCompleted 挂在 content 上的裸串 "closeEvent"
	// 监听（WelcomeView.hx:252）才接得到 → onGuideFinished → CMD_WELCOME_END
	// + startNewTask（issue #65 症状 5「引导永久挂死」的收尾链）。父级载体
	// 收到即等价冒泡语义（openfl DisplayObject.__dispatchEvent 沿内存 parent
	// 链走，无舞台要求）
	public function test_page5_closeButton2_click_closeEvent_bubbles_to_parent() {
		var p = new Page5_1();
		p.closeButton2 = new SimpleButton();
		p.preButton = new SimpleButton();
		var parent = new MovieClip();
		parent.addChild(p);
		var rec = recorder(p);
		var parentGot = 0;
		parent.addEventListener("closeEvent", function(e:Event):Void parentGot++);
		p.frame1();
		p.closeButton2.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.equals(1, rec.count("closeEvent"), "closeButton2 CLICK → 恰一发 closeEvent（:23 接线）");
		Assert.isTrue(rec.bubbles("closeEvent"), "bubbles=true 别丢（:28，issue #65 修复路径 1 点名项）");
		Assert.equals(1, parentGot, "冒泡到父级——content 上的 WelcomeView 监听靠它收到");
		Assert.equals(0, rec.count("nextButtonClick"), "不牵连翻页事件");
		Assert.equals(0, rec.count("preButtonClick"), "不牵连翻页事件");
	}
}
