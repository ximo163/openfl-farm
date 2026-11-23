package module;

import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.text.TextField;
import utest.Assert;

/**
 * module.GameGuide 步进纯面（issue #43）：九步坐标表、showStep 的四道门、
 * 箭头落位/偏移/朝向、容器缺失抛错、hide/autoHide(0)、tip 只在
 * WATER_FISH_ITEM 步挂载。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/module/GameGuide.as
 * （toggle_water :18、fishGuideStep :42-87、showStep :163-260、
 * resetTimeout :262-269、container setter :271-279、autoHide :127-141、
 * hide :148-161）。
 *
 * ctor 取 Arrow 素材（:108 Utils.getMaterial）在 eval 无资源会炸——空实例
 * + 钉字段驱动（ToolBarTest/MouseTipTest 先例）；container 走 public setter，
 * eval 上 Sprite 无 stage → :274-277 的阈值分支自然跳过。引导数据来源即
 * 本类私有静态表 fishGuideStep（服务端只给 toggle_water 开关，
 * WaterGrayOpen.onTutorialClosed 置位——见 #37 片），无网络步骤下发。
 * stub 阶段失败点：showStep/autoHide/hide 是 #35 可调不抛空体、
 * fishGuideStep 为 null——落位/抛错/tip/表长门用例红（表长门断言 _step
 * 先记后判），toggle_water/_stop/前进向三门的早退用例靠空体通过（实现期
 * 回归钉）。
 */
@:access(module.GameGuide)
class GameGuideTest {
	public function new() {}

	// 空实例 + 钉 ctor 初态（:105-115）：_step=-1、_stop=false、_timeout=0、
	// 两偏移档 false、箭头给真 MovieClip（显示载体，#42 先例）
	private function makeGuide():{g:GameGuide, c:Sprite, arrow:MovieClip} {
		var g = Type.createEmptyInstance(GameGuide);
		Reflect.setField(g, "_step", -1);
		Reflect.setField(g, "_stop", false);
		Reflect.setField(g, "_bigMode", false);
		Reflect.setField(g, "_normalView", false);
		Reflect.setField(g, "_timeout", 0);
		var arrow = new MovieClip();
		Reflect.setField(g, "_arrow", arrow);
		var c = new Sprite();
		g.container = c;
		GameGuide.toggle_water = true; // :18 引导总开关打开
		return {g: g, c: c, arrow: arrow};
	}

	public function teardown() {
		GameGuide.toggle_water = false; // :18 声明初值，用完复位防跨用例泄漏
	}

	// :42-87 fishGuideStep：九步表；步 0 是商店鱼 icon 锚，步 8 的 (-1,-1)
	// 是动态锚（showStep 参数位 :204-208）
	public function test_fishGuideStep_table_shape() {
		var table = GameGuide.fishGuideStep;
		Assert.equals(9, table.length);
		var s0 = table[0];
		Assert.equals(0, Reflect.field(s0, "id"));
		Assert.equals(710, Reflect.field(s0, "x"));
		Assert.equals(55, Reflect.field(s0, "y"));
		Assert.equals(0, Reflect.field(s0, "dir"));
		var s8 = table[8];
		Assert.equals(8, Reflect.field(s8, "id"));
		Assert.equals(-1, Reflect.field(s8, "x")); // 动态锚哨兵
		Assert.equals(-1, Reflect.field(s8, "y"));
		Assert.equals(1, Reflect.field(s8, "dir"));
	}

	// :166-169 toggle_water=false：第一步就被门挡住，_step 不动、不挂箭头
	public function test_showStep_blocked_while_toggle_water_off() {
		var t = makeGuide();
		GameGuide.toggle_water = false;
		t.g.showStep(GameGuide.WATER_SHOP_ICON);
		Assert.equals(-1, t.g.currentStep);
		Assert.equals(0, t.c.numChildren);
	}

	// :166 _stop=true（教程已走完/关闭）：同上早退
	public function test_showStep_blocked_after_stop() {
		var t = makeGuide();
		Reflect.setField(t.g, "_stop", true);
		t.g.showStep(GameGuide.WATER_SHOP_ICON);
		Assert.equals(-1, t.g.currentStep);
		Assert.equals(0, t.c.numChildren);
	}

	// :174-177 前进向门：param1 <= _step 直接回（步号只升不降不重来）
	public function test_showStep_forward_only() {
		var t = makeGuide();
		Reflect.setField(t.g, "_step", 3);
		t.g.showStep(3); // 等值不重放
		Assert.equals(3, t.g.currentStep);
		t.g.showStep(1); // 倒退不放
		Assert.equals(3, t.g.currentStep);
		Assert.equals(0, t.c.numChildren);
	}

	// :178-182 表长上限：_step 先记后判，越界（>= 9）直接回——不挂箭头也
	// 不吃 :259 的容器抛错（长度门在容器门之前）
	public function test_showStep_step_beyond_table_records_but_renders_nothing() {
		var t = makeGuide();
		t.g.showStep(9);
		Assert.equals(9, t.g.currentStep); // :178 先写 _step
		Assert.equals(0, t.c.numChildren); // :179-182 越界回
	}

	// :259 容器未设：合法步号直接抛 Error（引导层没接就是配置错误）
	public function test_showStep_without_container_throws() {
		var g = Type.createEmptyInstance(GameGuide);
		Reflect.setField(g, "_step", -1);
		Reflect.setField(g, "_stop", false);
		Reflect.setField(g, "_arrow", new MovieClip());
		GameGuide.toggle_water = true;
		var threw:Error = null;
		try {
			g.showStep(0);
		} catch (e:Error) {
			threw = e;
		}
		if (Assert.notNull(threw)) {
			Assert.equals("Container property must be set first!", threw.message);
		}
	}

	// :183-187 + :209-215 基准落位：步 0 无偏移档 → 箭头挂上、坐标原样、
	// dir 0 不翻不转
	public function test_showStep_step0_places_arrow_from_table() {
		var t = makeGuide();
		t.g.showStep(GameGuide.WATER_SHOP_ICON);
		Assert.equals(0, t.g.currentStep);
		Assert.equals(1, t.c.numChildren);
		Assert.isTrue(t.c.contains(t.arrow));
		Assert.equals(710.0, t.arrow.x); // fishGuideStep[0]["x"]
		Assert.equals(55.0, t.arrow.y);
		Assert.equals(1.0, t.arrow.scaleX); // dir 0 → :210-214
		Assert.equals(1.0, t.arrow.scaleY);
		Assert.equals(0.0, t.arrow.rotation);
	}

	// :188-195 大视图档（stageWidth > 820）：x +60；商店鱼 icon 步再 +68
	public function test_showStep_big_mode_offsets() {
		var t = makeGuide();
		Reflect.setField(t.g, "_bigMode", true);
		t.g.showStep(GameGuide.WATER_SHOP_ICON);
		Assert.equals(838.0, t.arrow.x); // 710 + 60 + 68（:190 + :192-194）
		Assert.equals(55.0, t.arrow.y);
		var t2 = makeGuide();
		Reflect.setField(t2.g, "_bigMode", true);
		t2.g.showStep(1);
		Assert.equals(295.0, t2.arrow.x); // 235 + 60，非 icon 步无特加
		Assert.equals(120.0, t2.arrow.y);
	}

	// :196-203 小视图档（stageWidth < 720）：x -50；商店鱼 icon 步再 -50
	public function test_showStep_small_mode_offsets() {
		var t = makeGuide();
		Reflect.setField(t.g, "_normalView", true);
		t.g.showStep(GameGuide.WATER_SHOP_ICON);
		Assert.equals(610.0, t.arrow.x); // 710 - 50 - 50（:198 + :200-202）
		var t2 = makeGuide();
		Reflect.setField(t2.g, "_normalView", true);
		t2.g.showStep(1);
		Assert.equals(185.0, t2.arrow.x); // 235 - 50
	}

	// :204-208 动态锚：步 8 表值 (-1,-1) → 坐标改用 showStep 的 param2/param3
	public function test_showStep_dynamic_anchor_step8() {
		var t = makeGuide();
		t.g.showStep(GameGuide.WATER_POOL_CENTER, 333, 444);
		Assert.equals(8, t.g.currentStep);
		Assert.equals(333.0, t.arrow.x);
		Assert.equals(444.0, t.arrow.y);
		Assert.equals(-1.0, t.arrow.scaleY); // 步 8 dir 1 → :216-220 纵向翻转
	}

	// :209-233 朝向四档里的表内两档：dir 1 纵翻、dir 3 右转 90
	// （dir 2 表内无实例，不测）
	public function test_showStep_dir_transforms() {
		var t1 = makeGuide();
		t1.g.showStep(1); // dir 1
		Assert.equals(1.0, t1.arrow.scaleX);
		Assert.equals(-1.0, t1.arrow.scaleY);
		Assert.equals(0.0, t1.arrow.rotation);
		var t2 = makeGuide();
		t2.g.showStep(2); // dir 3
		Assert.equals(1.0, t2.arrow.scaleX);
		Assert.equals(1.0, t2.arrow.scaleY);
		Assert.equals(90.0, t2.arrow.rotation);
	}

	// :148-161 hide：箭头与 tip 都从容器摘掉；容器为 null 时静默（:150 门）
	public function test_hide_removes_arrow_and_tip() {
		var t = makeGuide();
		var tip = new TextField();
		Reflect.setField(t.g, "_tip", tip);
		t.c.addChild(t.arrow);
		t.c.addChild(tip);
		t.g.hide();
		Assert.equals(0, t.c.numChildren);
		Assert.isNull(t.arrow.parent);
		Assert.isNull(tip.parent);

		var bare = Type.createEmptyInstance(GameGuide); // _container null
		bare.hide(); // 不抛即通过
		Assert.isTrue(true);
	}

	// :127-134 autoHide：sec <= 0 立即 hide（不经 setTimeout，可直测）
	public function test_autoHide_nonpositive_hides_immediately() {
		var t = makeGuide();
		t.g.showStep(GameGuide.WATER_SHOP_ICON);
		Assert.equals(1, t.c.numChildren); // 前置：箭头已挂
		t.g.autoHide(0);
		Assert.equals(0, t.c.numChildren); // :132 立即摘
	}

	// :234-251 tip 只在 WATER_FISH_ITEM(2) 步挂载：懒建 TextField、text 落
	// param4、锚点 = 箭头左上外偏 (-10,-20)（tip 宽高是 eval 度量，按公式断）
	public function test_showStep_tip_on_fish_item_step() {
		var t = makeGuide();
		t.g.showStep(GameGuide.WATER_FISH_ITEM, 0, 0, "去买鱼苗");
		var tip:TextField = cast Reflect.field(t.g, "_tip");
		if (Assert.notNull(tip)) { // :236-243 首次懒建
			Assert.equals("去买鱼苗", tip.text); // :246
			Assert.isTrue(t.c.contains(tip)); // :249
			Assert.equals(t.arrow.x - tip.width - 10, tip.x); // :247（箭头在 183）
			Assert.equals(t.arrow.y - tip.height - 20, tip.y); // :248（箭头在 220）
		}
		Assert.equals(183.0, t.arrow.x);
		Assert.equals(220.0, t.arrow.y);
	}

	// :236-243 vs :244：非 WATER_FISH_ITEM 步带文案 → tip 懒建但不挂载
	// （param1 == WATER_FISH_ITEM 门在挂载外）
	public function test_showStep_text_on_other_step_creates_tip_without_adding() {
		var t = makeGuide();
		t.g.showStep(GameGuide.WATER_SHOP_ICON, 0, 0, "文案");
		var tip:TextField = cast Reflect.field(t.g, "_tip");
		if (Assert.notNull(tip)) { // 懒建仍在
			Assert.isNull(tip.parent); // 不挂载
		}
		Assert.equals(1, t.c.numChildren); // 只有箭头
	}

	// :234 + :252-255 空文案：已挂的 tip 被摘（else-if 分支）
	public function test_showStep_empty_text_removes_existing_tip() {
		var t = makeGuide();
		var tip = new TextField();
		Reflect.setField(t.g, "_tip", tip);
		t.c.addChild(tip);
		t.g.showStep(GameGuide.WATER_SHOP_ICON, 0, 0, "");
		Assert.isNull(tip.parent);
		Assert.equals(1, t.c.numChildren); // 只剩箭头
	}
}
