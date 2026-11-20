package common.view.floating;

import common.Consts;
import common.misc.Utils;
import interfaces.IMsgCenter;
import openfl.Lib.getTimer;
import openfl.display.MovieClip;
import openfl.events.Event;

/**
 * common.view.floating.AddHealthAnimation —— AddHealthAnimation.as 逐句对应
 * （issue #9）。健康模式提醒飘字：AddHealth 素材，3000ms 自关。
 */
@:keep
class AddHealthAnimation extends FloatingBase {
	// AddHealthAnimation.as:13
	private var _preTime:Int;

	// AddHealthAnimation.as:15
	private var _addHealth:MovieClip;

	// AddHealthAnimation.as:17-28
	public function new(param1:IMsgCenter) {
		super(param1);
		this.floatName = Consts.FLOAT_TYPE_HEALTH;
		this._addHealth = cast Utils.getMaterial("AddHealth");
		if (this._addHealth != null) {
			addChild(this._addHealth);
		}
		this._preTime = 0;
		this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemoved, false, 0, true);
	}

	// AddHealthAnimation.as:30-38（超 3000ms 摘帧听 + close）
	private function onEnterFrame(param1:Event):Void {
		if (getTimer() - this._preTime > 3000) {
			this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			this._preTime = 0;
			super.close();
		}
	}

	// AddHealthAnimation.as:40-44
	private function onRemoved(param1:Event):Void {
		this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		this._preTime = 0;
	}

	// AddHealthAnimation.as:46-58（素材第 2 帧起播；首启计时）
	override public function start(param1:Dynamic):Void {
		super.start(param1);
		if (this._addHealth != null) {
			this._addHealth.gotoAndPlay(2);
		}
		if (this._preTime == 0) {
			this._preTime = getTimer();
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
	}
}
