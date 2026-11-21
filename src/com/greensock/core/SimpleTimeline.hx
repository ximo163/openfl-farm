package com.greensock.core;

/**
 * com.greensock.core.SimpleTimeline —— SimpleTimeline.as 逐句对应（issue #18
 * TweenLite core 片）。时间轴（TweenCore 子类持子补间双向链表）：renderTime
 * 按各子节点的时间缩放/倒放推到同一时刻，addChild 头插 + 摘旧轴，
 * remove 走链表摘除（末节点回退 _lastChild）。
 */
@:keep
class SimpleTimeline extends TweenCore {
	// SimpleTimeline.as:6-10
	public var autoRemoveChildren:Bool;

	private var _lastChild:TweenCore;

	private var _firstChild:TweenCore;

	// :12-15
	public function new(param1:Dynamic = null) {
		super(0, param1);
	}

	// :17-41（`param1 >= _loc4_.cachedStartTime && !_loc4_.cachedPaused`：
	// && 优先级低于 ||，判真即渲染）
	override public function renderTime(param1:Float, param2:Bool = false, param3:Bool = false):Void {
		var _loc5_:Float = Math.NaN;
		var _loc6_:TweenCore = null;
		var _loc4_:TweenCore = this._firstChild;
		this.cachedTotalTime = param1;
		this.cachedTime = param1;
		while (_loc4_ != null) {
			_loc6_ = _loc4_.nextNode;
			if (_loc4_.active || param1 >= _loc4_.cachedStartTime && !_loc4_.cachedPaused) {
				if (!_loc4_.cachedReversed) {
					_loc4_.renderTime((param1 - _loc4_.cachedStartTime) * _loc4_.cachedTimeScale, param2, false);
				} else {
					_loc5_ = _loc4_.cacheIsDirty ? _loc4_.totalDuration : _loc4_.cachedTotalDuration;
					_loc4_.renderTime(_loc5_ - (param1 - _loc4_.cachedStartTime) * _loc4_.cachedTimeScale, param2, false);
				}
			}
			_loc4_ = _loc6_;
		}
	}

	// :43-61
	public function addChild(param1:TweenCore):Void {
		if (!param1.gc && param1.timeline != null) {
			param1.timeline.remove(param1, true);
		}
		param1.timeline = this;
		if (param1.gc) {
			param1.setEnabled(true, true);
		}
		if (this._firstChild != null) {
			this._firstChild.prevNode = param1;
		}
		param1.nextNode = this._firstChild;
		this._firstChild = param1;
		param1.prevNode = null;
	}

	// :63-85
	public function remove(param1:TweenCore, param2:Bool = false):Void {
		if (!param1.gc && !param2) {
			param1.setEnabled(false, true);
		}
		if (param1.nextNode != null) {
			param1.nextNode.prevNode = param1.prevNode;
		} else if (this._lastChild == param1) {
			this._lastChild = param1.prevNode;
		}
		if (param1.prevNode != null) {
			param1.prevNode.nextNode = param1.nextNode;
		} else if (this._firstChild == param1) {
			this._firstChild = param1.nextNode;
		}
	}

	// :87-90
	public var rawTime(get, never):Float;

	private function get_rawTime():Float {
		return this.cachedTotalTime;
	}
}
