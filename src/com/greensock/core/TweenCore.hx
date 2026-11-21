package com.greensock.core;

import com.greensock.TweenLite;
import shim.As3;

/**
 * com.greensock.core.TweenCore —— TweenCore.as 逐句对应（issue #18 TweenLite
 * core 片）。补间基类（GreenSock v1.1）：缓存时长/时轴/启停状态，链表节点
 * （prevNode/nextNode）挂在 SimpleTimeline 上；paused/reversed/delay 等
 * 存取器在 setTotalTime/renderTime 上联动。不进单测（时间轴推进由 CI
 * 时间轴比对覆盖）。
 * PORT-NOTE:
 * - `this.vars.xxx`（vars:Object）读写 → Reflect.field（值可能缺位）。
 * - `vars.onComplete.apply(null, vars.onCompleteParams)`：AS3 apply 第二参
 *   undefined 等于无参调用；Haxe Reflect.callMethod 不接受 null 参数表，
 *   缺位时收成 []。
 */
@:keep
class TweenCore {
	// TweenCore.as:8-10
	private static var _classInitted:Bool;

	public static final version:Float = 1.1;

	// :12-52
	public var initted:Bool;

	private var _hasUpdate:Bool;

	public var active:Bool;

	private var _delay:Float;

	public var cachedTime:Float;

	public var cachedReversed:Bool;

	public var nextNode:TweenCore;

	private var _rawPrevTime:Float = -1;

	public var vars:Dynamic;

	public var cachedTotalTime:Float;

	public var timeline:SimpleTimeline;

	public var data:Dynamic;

	public var cachedStartTime:Float;

	public var prevNode:TweenCore;

	public var cachedDuration:Float;

	public var gc:Bool;

	// TweenCore.as:44（AS3 Number 字段默认 NaN——setTotalTime :274 的
	// `Boolean(_pauseTime) || _pauseTime == 0` 门靠 NaN 才走 timeline 分支；
	// Haxe Float 零初始化成 0.0 会误命中 `== 0`）
	private var _pauseTime:Float = Math.NaN;

	public var cacheIsDirty:Bool;

	public var cachedPaused:Bool;

	public var cachedTimeScale:Float;

	public var cachedTotalDuration:Float;

	// :54-84（`return` 分支：原版原样——initClass 已跑而 _classInitted 仍假
	// 不可达（同块内先后置位），保结构不保可达性）
	public function new(param1:Float = 0, param2:Dynamic = null) {
		this.vars = As3.or(param2, {});
		this.cachedDuration = this.cachedTotalDuration = As3.or(param1, 0);
		this._delay = As3.or(As3.floatOf(Reflect.field(this.vars, "delay")), 0);
		this.cachedTimeScale = As3.or(As3.floatOf(Reflect.field(this.vars, "timeScale")), 1);
		this.active = param1 == 0 && this._delay == 0 && Reflect.field(this.vars, "immediateRender") != false;
		this.cachedTotalTime = this.cachedTime = 0;
		this.data = Reflect.field(this.vars, "data");
		if (_classInitted == false) {
			if (!Math.isNaN(TweenLite.rootFrame)) {
				return;
			}
			TweenLite.initClass();
			_classInitted = true;
		}
		var _loc3_:SimpleTimeline = Std.isOfType(Reflect.field(this.vars, "timeline"), SimpleTimeline)
			? cast(Reflect.field(this.vars, "timeline"), SimpleTimeline)
			: (As3.truthy(Reflect.field(this.vars, "useFrames")) ? TweenLite.rootFramesTimeline : TweenLite.rootTimeline);
		this.cachedStartTime = _loc3_.cachedTotalTime + this._delay;
		_loc3_.addChild(this);
		if (As3.truthy(Reflect.field(this.vars, "reversed"))) {
			this.cachedReversed = true;
		}
		if (As3.truthy(Reflect.field(this.vars, "paused"))) {
			this.paused = true;
		}
	}

	// :86-88（空实现：子类覆写点）
	public function renderTime(param1:Float, param2:Bool = false, param3:Bool = false):Void {}

	// :90-93 + :126-130（AS3 public get/set delay 对）
	public var delay(get, set):Float;

	private function get_delay():Float {
		return this._delay;
	}

	// :95-98 + :148-152（AS3 public get/set duration 对）
	public var duration(get, set):Float;

	private function get_duration():Float {
		return this.cachedDuration;
	}

	// :100-105
	public function restart(param1:Bool = false, param2:Bool = true):Void {
		this.reversed = false;
		this.paused = false;
		this.setTotalTime(param1 ? -this._delay : 0, param2);
	}

	// :107-114 + :191-194（AS3 public get/set reversed 对）
	public var reversed(get, set):Bool;

	private function set_reversed(param1:Bool):Bool {
		if (param1 != this.cachedReversed) {
			this.cachedReversed = param1;
			this.setTotalTime(this.cachedTotalTime, true);
		}
		return param1;
	}

	// :116-124 + :196-199（AS3 public get/set startTime 对）
	public var startTime(get, set):Float;

	private function set_startTime(param1:Float):Float {
		var _loc2_:Bool = this.timeline != null && (param1 != this.cachedStartTime || this.gc);
		this.cachedStartTime = param1;
		if (_loc2_) {
			this.timeline.addChild(this);
		}
		return param1;
	}

	// :126-130
	private function set_delay(param1:Float):Float {
		this.startTime += param1 - this._delay;
		this._delay = param1;
		return param1;
	}

	// :132-135
	public function resume():Void {
		this.paused = false;
	}

	// :137-140 + :229-251（AS3 public get/set paused 对）
	public var paused(get, set):Bool;

	private function get_paused():Bool {
		return this.cachedPaused;
	}

	// :142-146
	public function play():Void {
		this.reversed = false;
		this.paused = false;
	}

	// :148-152
	private function set_duration(param1:Float):Float {
		this.cachedDuration = this.cachedTotalDuration = param1;
		this.setDirtyCache(false);
		return param1;
	}

	// :154-180
	public function complete(param1:Bool = false, param2:Bool = false):Void {
		if (!param1) {
			this.renderTime(this.cachedTotalDuration, param2, false);
			return;
		}
		if (this.timeline.autoRemoveChildren) {
			this.setEnabled(false, false);
		} else {
			this.active = false;
		}
		if (!param2) {
			if (Reflect.field(this.vars, "onComplete") != null && this.cachedTime == this.cachedDuration
				&& !this.cachedReversed) {
				var _loc3_:Dynamic = Reflect.field(this.vars, "onCompleteParams");
				if (_loc3_ != null) {
					Reflect.callMethod(null, Reflect.field(this.vars, "onComplete"), _loc3_);
				} else {
					Reflect.callMethod(null, Reflect.field(this.vars, "onComplete"), []);
				}
			} else if (this.cachedReversed && this.cachedTotalTime == 0
				&& Reflect.field(this.vars, "onReverseComplete") != null) {
				var _loc4_:Dynamic = Reflect.field(this.vars, "onReverseCompleteParams");
				if (_loc4_ != null) {
					Reflect.callMethod(null, Reflect.field(this.vars, "onReverseComplete"), _loc4_);
				} else {
					Reflect.callMethod(null, Reflect.field(this.vars, "onReverseComplete"), []);
				}
			}
		}
	}

	// :182-184（空实现：子类覆写点）
	public function invalidate():Void {}

	// :186-189 + :258-261（AS3 public get/set totalTime 对）
	public var totalTime(get, set):Float;

	private function get_totalTime():Float {
		return this.cachedTotalTime;
	}

	// :191-194
	private function get_reversed():Bool {
		return this.cachedReversed;
	}

	// :196-199
	private function get_startTime():Float {
		return this.cachedStartTime;
	}

	// :201-204 + :263-266（AS3 public get/set currentTime 对）
	public var currentTime(get, set):Float;

	private function set_currentTime(param1:Float):Float {
		this.setTotalTime(param1, false);
		return param1;
	}

	// :206-214
	private function setDirtyCache(param1:Bool = true):Void {
		var _loc2_:TweenCore = param1 ? this : this.timeline;
		while (_loc2_ != null) {
			_loc2_.cacheIsDirty = true;
			_loc2_ = _loc2_.timeline;
		}
	}

	// :216-227
	public function reverse(param1:Bool = true):Void {
		this.reversed = true;
		if (param1) {
			this.paused = false;
		} else if (this.gc) {
			this.setEnabled(true, false);
		}
	}

	// :229-251
	private function set_paused(param1:Bool):Bool {
		if (param1 != this.cachedPaused && this.timeline != null) {
			if (param1) {
				this._pauseTime = this.timeline.rawTime;
			} else {
				this.cachedStartTime += this.timeline.rawTime - this._pauseTime;
				this._pauseTime = Math.NaN;
				this.setDirtyCache(false);
			}
			this.cachedPaused = param1;
			this.active = !this.cachedPaused && this.cachedTotalTime > 0 && this.cachedTotalTime < this.cachedTotalDuration;
		}
		if (!param1 && this.gc) {
			this.setTotalTime(this.cachedTotalTime, false);
			this.setEnabled(true, false);
		}
		return param1;
	}

	// :253-256
	public function kill():Void {
		this.setEnabled(false, false);
	}

	// :258-261
	private function set_totalTime(param1:Float):Float {
		this.setTotalTime(param1, false);
		return param1;
	}

	// :263-266
	private function get_currentTime():Float {
		return this.cachedTime;
	}

	// :268-293（`Boolean(this._pauseTime) || this._pauseTime == 0`）
	private function setTotalTime(param1:Float, param2:Bool = false):Void {
		var _loc3_:Float = Math.NaN;
		var _loc4_:Float = Math.NaN;
		if (this.timeline != null) {
			_loc3_ = As3.truthy(this._pauseTime) || this._pauseTime == 0 ? this._pauseTime : this.timeline.cachedTotalTime;
			if (this.cachedReversed) {
				_loc4_ = this.cacheIsDirty ? this.totalDuration : this.cachedTotalDuration;
				this.cachedStartTime = _loc3_ - (_loc4_ - param1) / this.cachedTimeScale;
			} else {
				this.cachedStartTime = _loc3_ - param1 / this.cachedTimeScale;
			}
			if (!this.timeline.cacheIsDirty) {
				this.setDirtyCache(false);
			}
			if (this.cachedTotalTime != param1) {
				this.renderTime(param1, param2, false);
			}
		}
	}

	// :295-298
	public function pause():Void {
		this.paused = true;
	}

	// :300-303 + :305-308（AS3 public get/set totalDuration 对）
	public var totalDuration(get, set):Float;

	private function set_totalDuration(param1:Float):Float {
		this.duration = param1;
		return param1;
	}

	// :305-308
	private function get_totalDuration():Float {
		return this.cachedTotalDuration;
	}

	// :310-333
	public function setEnabled(param1:Bool, param2:Bool = false):Bool {
		if (param1 == this.gc) {
			if (param1) {
				this.active = !this.cachedPaused && this.cachedTotalTime > 0 && this.cachedTotalTime < this.cachedTotalDuration;
				if (!param2) {
					this.timeline.addChild(this);
				}
			} else {
				this.active = false;
				if (!param2) {
					this.timeline.remove(this, true);
				}
			}
			this.gc = !param1;
		}
		return false;
	}
}
