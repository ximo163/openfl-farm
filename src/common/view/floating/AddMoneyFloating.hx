package common.view.floating;

import common.Consts;
import common.misc.Utils;
import interfaces.IMsgCenter;
import openfl.Lib.getTimer;
import openfl.display.MovieClip;
import openfl.events.Event;
import shim.As3;

/**
 * common.view.floating.AddMoneyFloating —— AddMoneyFloating.as 逐句对应
 * （issue #9）。加钱飘字：AddAnimationEx 素材 + 加值文本，5000ms 自关。
 * 素材内层链 addValueBox.addValue 经 Reflect 取（swf 符号子件，动态名）。
 * AS3 protected（_addAddAnimation）→ Haxe private（子类可见）。
 */
@:keep
class AddMoneyFloating extends FloatingBase {
	// AddMoneyFloating.as:13
	private var _preTime:Int = 0;

	// AddMoneyFloating.as:15
	private var _addAddAnimation:MovieClip;

	// AddMoneyFloating.as:17-29
	public function new(param1:IMsgCenter) {
		super(param1);
		this.floatName = Consts.FLOAT_TYPE_MONEY;
		this._addAddAnimation = cast Utils.getMaterial("AddAnimationEx");
		if (this._addAddAnimation != null) {
			// 原版 `this._addAddAnimation.addValueBox.addValue.width = 100;`
			// 时间轴具名子实例链，经 As3.childOf（#8 Crop step1 先例）
			var _loc2_:Dynamic = As3.childOf(this._addAddAnimation, "addValueBox");
			var addValue:Dynamic = As3.childOf(_loc2_, "addValue");
			addValue.width = 100;
			addChild(this._addAddAnimation);
		}
		this._preTime = 0;
		this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemoved, false, 0, true);
	}

	// AddMoneyFloating.as:31-39（超 5000ms 摘帧听 + close）
	private function onEnterFrame(param1:Event):Void {
		if (getTimer() - this._preTime > 5000) {
			this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			this._preTime = 0;
			super.close();
		}
	}

	// AddMoneyFloating.as:41-45
	private function onRemoved(param1:Event):Void {
		this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		this._preTime = 0;
	}

	// AddMoneyFloating.as:47-65（正数带 + 前缀；首启计时，素材第 2 帧起播）
	override public function start(param1:Dynamic):Void {
		super.start(param1);
		// 原版 `var _loc2_:int = super._data["value"] as Number;`（as Number 后
		// 隐式截断回 int）。素材缺位时这里与原版同样在子件访问处抛错，不加
		// 原版没有的判空
		var _loc2_:Int = As3.intOf(Reflect.field(this._data, "value"));
		var _loc3_:Dynamic = As3.childOf(this._addAddAnimation, "addValueBox");
		var addValue:Dynamic = As3.childOf(_loc3_, "addValue");
		if (_loc2_ >= 0) {
			addValue.text = "+" + _loc2_;
		} else {
			addValue.text = Std.string(_loc2_);
		}
		if (this._preTime == 0) {
			this._preTime = getTimer();
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);
		}
		this._addAddAnimation.gotoAndPlay(2);
	}
}
