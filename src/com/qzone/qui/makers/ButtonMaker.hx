package com.qzone.qui.makers;

import com.qzone.qui.styles.Style;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

// com.qzone.qui.makers.ButtonMaker —— ButtonMaker.as 逐句对应（issue #44 真身，
// 原 #8 闭包 stub 退役）。qui 按钮状态机：setEnabled 撞 mouseEnabled != 门分流
// enable/disable（挂/摘 ROLL_OVER 监听 + Style 三张滤镜表），ROLL_OVER 再挂
// ROLL_OUT/MOUSE_DOWN/MOUSE_UP 三监听、ROLL_OUT 摘掉——滤镜数组赋值按仓库
// 惯例 unsafe cast Style.getXxxFilter()（Array<Dynamic> → Array<BitmapFilter>）。
// legacy/decompiled/main3_v_221/scripts/com/qzone/qui/makers/ButtonMaker.as
class ButtonMaker {
	public function new() {}

	// ButtonMaker.as:16-23（`param1.target as Sprite` → isOfType 门 + 直取）
	private static function onRollOver(param1:MouseEvent):Void {
		var _loc2_:Sprite = Std.isOfType(param1.target, Sprite) ? cast(param1.target, Sprite) : null;
		_loc2_.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		_loc2_.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
		_loc2_.addEventListener(MouseEvent.MOUSE_UP, onRelease);
		_loc2_.filters = cast Style.getRollOverFilter();
	}

	// ButtonMaker.as:25-31
	public static function addTarget(param1:Sprite, param2:Bool = true, param3:Bool = false):Void {
		setSelected(param1, param3);
		setEnabled(param1, param2);
		param1.buttonMode = true;
		param1.mouseChildren = false;
	}

	// ButtonMaker.as:33-37
	private static function onPress(param1:MouseEvent):Void {
		var _loc2_:Sprite = Std.isOfType(param1.target, Sprite) ? cast(param1.target, Sprite) : null;
		_loc2_.filters = cast Style.getHitFilter();
	}

	// ButtonMaker.as:39-46
	public static function removeTarget(param1:Sprite):Void {
		setSelected(param1, false);
		removeEvent(param1);
		param1.filters = cast Style.getRollOutFilter();
		param1.buttonMode = false;
		param1.mouseChildren = true;
	}

	// ButtonMaker.as:48-54
	private static function removeEvent(param1:Sprite):Void {
		param1.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
		param1.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
		param1.removeEventListener(MouseEvent.MOUSE_DOWN, onPress);
		param1.removeEventListener(MouseEvent.MOUSE_UP, onRelease);
	}

	// ButtonMaker.as:56-60
	private static function onRelease(param1:MouseEvent):Void {
		var _loc2_:Sprite = Std.isOfType(param1.target, Sprite) ? cast(param1.target, Sprite) : null;
		_loc2_.filters = cast Style.getRollOverFilter();
	}

	// ButtonMaker.as:62-65
	private static function addEvent(param1:Sprite):Void {
		param1.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
	}

	// ButtonMaker.as:67-74
	private static function onRollOut(param1:MouseEvent):Void {
		var _loc2_:Sprite = Std.isOfType(param1.target, Sprite) ? cast(param1.target, Sprite) : null;
		_loc2_.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
		_loc2_.removeEventListener(MouseEvent.MOUSE_DOWN, onPress);
		_loc2_.removeEventListener(MouseEvent.MOUSE_UP, onRelease);
		_loc2_.filters = cast Style.getRollOutFilter();
	}

	// ButtonMaker.as:76-82
	public static function setSelected(param1:Sprite, param2:Bool = true):Void {
		if (Std.isOfType(param1, MovieClip)) {
			cast(param1, MovieClip).gotoAndStop(param2 ? 2 : 1);
		}
	}

	// ButtonMaker.as:84-101
	public static function setEnabled(param1:Sprite, param2:Bool = false):Void {
		if (param1.mouseEnabled != param2) {
			if (false == param2) {
				removeEvent(param1);
				param1.filters = cast Style.getDisableFilter();
			} else if (true == param2) {
				addEvent(param1);
				param1.filters = cast Style.getRollOutFilter();
			}
			param1.mouseEnabled = param2;
			param1.tabEnabled = param2;
		}
	}
}
