package com.qzone.qui.effects;

import com.qzone.utils.DisplayUtil;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;

/**
 * com.qzone.qui.effects.TweenEffect —— V3b 顺手翻（issue #8 闭包，
 * TweenEffect.as 40 loc ≤ 100；Move 的基类：快照位/显隐切换）。
 * legacy/decompiled/main3_v_221/scripts/com/qzone/qui/effects/TweenEffect.as
 * 逐句对应。
 */
class TweenEffect extends EventDispatcher {
	// TweenEffect.as:10
	public static var duration:Float = 300;

	public function new() {
		super();
	}

	// TweenEffect.as:16-19（protected → private + @:allow(Move)：Haxe 没有
	// protected，仅子类 Move 用）
	@:allow(com.qzone.qui.effects.Move)
	private static function setSnap(param1:DisplayObjectContainer, param2:DisplayObject, param3:DisplayObject):Void {
		param3.visible = true;
		param2.visible = false;
	}

	// TweenEffect.as:21-24
	@:allow(com.qzone.qui.effects.Move)
	private static function setPosition(param1:DisplayObject, param2:DisplayObject):Void {
		DisplayUtil.copyProperties(param1, param2, ["x", "y"]);
	}

	// TweenEffect.as:26-32（getSnap：目标矩形快照）
	@:allow(com.qzone.qui.effects.Move)
	private static function getSnap(param1:DisplayObjectContainer, param2:DisplayObject):BitmapData {
		var _loc3_:Rectangle = param2.getRect(param1);
		// AS3 BitmapData 形参 int 收 Number 隐式截断
		var _loc4_:BitmapData = new BitmapData(Std.int(_loc3_.width + 8), Std.int(_loc3_.height + 8), true, 0);
		_loc4_.draw(param2);
		return _loc4_;
	}
}
