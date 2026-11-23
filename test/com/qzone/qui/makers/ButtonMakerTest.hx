package com.qzone.qui.makers;

import com.qzone.qui.styles.Style;
import openfl.display.Sprite;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.events.MouseEvent;
import utest.Assert;

/**
 * ButtonMaker 状态表纯逻辑（issue #44）：setEnabled 的 `mouseEnabled !=
 * param2` 门（:86，Flash 缺省 mouseEnabled=true → 对新 Sprite 的
 * setEnabled(true) 是 no-op）、enable/disable 两分支的监听与滤镜
 * （:88-99）、ROLL_OVER → 挂 ROLL_OUT/MOUSE_DOWN/MOUSE_UP + rollOver 滤镜
 * （:16-23）、ROLL_OUT → 摘三监听 + rollOut 滤镜（:67-74）、MOUSE_DOWN →
 * hit 滤镜（:33-37）、MOUSE_UP → 回 rollOver 滤镜（:56-60）、addTarget 三连
 * （:25-31）与 removeTarget 复位（:39-46）。
 *
 * 测法：真 new Sprite()（eval 无素材可构造，MouseTipTest 同款）+ 直接
 * dispatchEvent 驱动状态机（MouseEvent 不需要舞台，openfl 派发链实测通）。
 * 滤镜断言走结构比对——openfl 的 set_filters 克隆数组（DisplayObject.hx
 * set_filters），引用比对恒假；Style 的滤镜表是缓存单例（Style.hx :118 起），
 * 期望值直接取 Style.getXxxFilter()[0] 的 matrix 对 Std.string。
 * setSelected 的 MovieClip gotoAndStop 分支（:76-82）不进单测（fresh
 * MovieClip 只有 1 帧，gotoAndStop(2) 被钳回 1，无可观测量）——Sprite 分支
 * （非 MovieClip no-op）钉一条。滤镜的视觉渲染归 CI 画面比对。
 *
 * stub 阶段失败点：四静态方法全是 no-op，标志位/监听/滤镜全都不动。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/qzone/qui/makers/ButtonMaker.as
 * （onRollOver :16-23、addTarget :25-31、onPress :33-37、removeTarget :39-46、
 * removeEvent :48-54、onRelease :56-60、addEvent :62-65、onRollOut :67-74、
 * setSelected :76-82、setEnabled :84-101）
 */
class ButtonMakerTest {
	public function new() {}

	// 结构比对：长度 + 首滤镜 ColorMatrix（Style 三张表都是单元素矩阵滤镜）；
	// 长度已败（stub 期 filters 为空）时跳过取元素，避免把断言失败变成 Null Access
	private function assertFilterIs(expected:Array<Dynamic>, actual:Array<BitmapFilter>, why:String):Void {
		Assert.equals(expected.length, actual.length, why);
		if (expected.length > 0 && actual.length == expected.length) {
			var exp = cast(expected[0], ColorMatrixFilter).matrix;
			var act = cast(actual[0], ColorMatrixFilter).matrix;
			Assert.equals(Std.string(exp), Std.string(act), why);
		}
	}

	// :27-30：addTarget 缺省（enabled=true, selected=false）——buttonMode/
	// mouseChildren 落位；setEnabled(true) 撞上 Sprite 缺省 mouseEnabled=true
	// 的 `!=` 门（:86）是 no-op：无 ROLL_OVER 监听、滤镜不动、tabEnabled
	// 保持缺省 false
	public function test_addTarget_defaults_set_flags_and_skip_noop_enable() {
		var sprite = new Sprite();
		ButtonMaker.addTarget(sprite);
		Assert.isTrue(sprite.buttonMode); // :29
		Assert.isFalse(sprite.mouseChildren); // :30
		Assert.isFalse(sprite.hasEventListener(MouseEvent.ROLL_OVER)); // :86 no-op，未挂监听
		Assert.isFalse(sprite.tabEnabled); // :99 未触达
		Assert.equals(0, sprite.filters.length); // 滤镜未动
	}

	// :88-92 + :98-99：addTarget(param2=false) 走 disable 分支——摘监听 +
	// disable 滤镜 + mouseEnabled/tabEnabled 双落 false
	public function test_addTarget_disabled_sets_disable_state() {
		var sprite = new Sprite();
		ButtonMaker.addTarget(sprite, false);
		Assert.isFalse(sprite.mouseEnabled); // :98
		Assert.isFalse(sprite.tabEnabled); // :99
		Assert.isFalse(sprite.hasEventListener(MouseEvent.ROLL_OVER)); // :90 removeEvent
		assertFilterIs(Style.getDisableFilter(), sprite.filters, "disable 滤镜 :91");
		Assert.isTrue(sprite.buttonMode); // :29 仍落位
		Assert.isFalse(sprite.mouseChildren); // :30
	}

	// :93-97 + :98-99：disable 后再 setEnabled(true) 走 enable 分支——挂
	// ROLL_OVER 监听 + rollOut 滤镜（空表）+ 双标志回 true
	public function test_setEnabled_false_then_true_reenables() {
		var sprite = new Sprite();
		ButtonMaker.setEnabled(sprite, false);
		ButtonMaker.setEnabled(sprite, true);
		Assert.isTrue(sprite.mouseEnabled); // :98
		Assert.isTrue(sprite.tabEnabled); // :99
		Assert.isTrue(sprite.hasEventListener(MouseEvent.ROLL_OVER)); // :95 addEvent
		Assert.equals(0, sprite.filters.length); // :96 rollOut 空滤镜表
	}

	// :16-23：ROLL_OVER 挂 ROLL_OUT/MOUSE_DOWN/MOUSE_UP 三监听 + rollOver
	// 滤镜（亮度矩阵 +15）
	public function test_rollover_adds_three_listeners_and_over_filter() {
		var sprite = new Sprite();
		ButtonMaker.setEnabled(sprite, false);
		ButtonMaker.setEnabled(sprite, true);
		sprite.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
		Assert.isTrue(sprite.hasEventListener(MouseEvent.ROLL_OUT)); // :19
		Assert.isTrue(sprite.hasEventListener(MouseEvent.MOUSE_DOWN)); // :20
		Assert.isTrue(sprite.hasEventListener(MouseEvent.MOUSE_UP)); // :21
		assertFilterIs(Style.getRollOverFilter(), sprite.filters, "rollOver 滤镜 :22");
	}

	// :67-74：ROLL_OUT 摘三监听 + rollOut 滤镜（回到无滤镜）
	public function test_rollout_removes_three_listeners_and_clears_filter() {
		var sprite = new Sprite();
		ButtonMaker.setEnabled(sprite, false);
		ButtonMaker.setEnabled(sprite, true);
		sprite.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
		sprite.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
		Assert.isFalse(sprite.hasEventListener(MouseEvent.ROLL_OUT)); // :70
		Assert.isFalse(sprite.hasEventListener(MouseEvent.MOUSE_DOWN)); // :71
		Assert.isFalse(sprite.hasEventListener(MouseEvent.MOUSE_UP)); // :72
		Assert.equals(0, sprite.filters.length); // :73
	}

	// :33-37 + :56-60：按下换 hit 滤镜（压暗矩阵 -5），弹起回 rollOver 滤镜
	public function test_press_and_release_swap_hit_then_over_filter() {
		var sprite = new Sprite();
		ButtonMaker.setEnabled(sprite, false);
		ButtonMaker.setEnabled(sprite, true);
		sprite.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
		sprite.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		assertFilterIs(Style.getHitFilter(), sprite.filters, "hit 滤镜 :36");
		sprite.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		assertFilterIs(Style.getRollOverFilter(), sprite.filters, "回 rollOver 滤镜 :59");
	}

	// :39-46：removeTarget 复位——摘监听、rollOut 滤镜、buttonMode 回
	// false、mouseChildren 回 true
	public function test_removeTarget_resets_flags() {
		var sprite = new Sprite();
		ButtonMaker.addTarget(sprite, true, false);
		ButtonMaker.removeTarget(sprite);
		Assert.isFalse(sprite.hasEventListener(MouseEvent.ROLL_OVER)); // :41 removeEvent
		Assert.equals(0, sprite.filters.length); // :43 rollOut 空表
		Assert.isFalse(sprite.buttonMode); // :44
		Assert.isTrue(sprite.mouseChildren); // :45
	}

	// :76-82：setSelected 对非 MovieClip 是 no-op（不挂监听不动滤镜），
	// MovieClip 的 gotoAndStop 分支无可观测量不进单测（类头注）
	public function test_setSelected_on_plain_sprite_is_noop() {
		var sprite = new Sprite();
		ButtonMaker.setSelected(sprite, true);
		Assert.isFalse(sprite.hasEventListener(MouseEvent.ROLL_OVER));
		Assert.equals(0, sprite.filters.length);
		Assert.isTrue(sprite.mouseEnabled); // 标志不受影响
	}
}
