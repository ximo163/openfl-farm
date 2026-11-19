package common.misc.time;

import shim.As3.getTimer; // PORT-NOTE: openfl 的 getTimer 在 eval 上纪元溢出为负，见 shim/As3.hx

// common.misc.time.GameTime —— GameTime.as 逐句对应（FarmApplication 主循环的
// 帧间隔时钟，平滑模式丢帧判定逐字照抄）。
class GameTime {
	// GameTime.as:7
	private var m_tStart:Float;

	// GameTime.as:9
	private var m_LastTimeElapsed:Float;

	// GameTime.as:11
	private var m_bSmoothUpdates:Bool;

	// GameTime.as:13
	private var m_bStarted:Bool;

	// GameTime.as:15
	private var m_tLast:Float;

	// GameTime.as:17
	private var m_TimeElapsed:Float;

	// GameTime.as:19-26
	public function new(param1:Bool) {
		this.m_bStarted = false;
		this.m_tStart = 0;
		this.m_LastTimeElapsed = 0;
		this.m_TimeElapsed = 0;
		this.m_bSmoothUpdates = param1;
	}

	// GameTime.as:28-31
	public var started(get, never):Bool;

	private function get_started():Bool {
		return this.m_bStarted;
	}

	// GameTime.as:33-37
	public function stop():Void {
		this.m_bStarted = false;
		this.m_LastTimeElapsed = this.m_TimeElapsed = 0;
	}

	// GameTime.as:39-45
	public function start():Void {
		this.m_bStarted = true;
		this.m_tStart = getTimer();
		this.m_tLast = this.m_tStart;
		this.m_LastTimeElapsed = this.m_TimeElapsed = 0;
	}

	// GameTime.as:47-50
	public var smooth(get, set):Bool;

	private function get_smooth():Bool {
		return this.m_bSmoothUpdates;
	}

	private function set_smooth(param1:Bool):Bool {
		this.m_bSmoothUpdates = param1;
		return param1;
	}

	// GameTime.as:52-73
	public function timeElapsed():Float {
		if (this.m_bStarted == false) {
			return 0;
		}
		this.m_LastTimeElapsed = this.m_TimeElapsed;
		var _loc1_:Float = getTimer();
		this.m_TimeElapsed = _loc1_ - this.m_tLast;
		this.m_tLast = _loc1_;
		var _loc2_:Float = 2.5;
		if (this.m_bSmoothUpdates) {
			if (this.m_TimeElapsed < this.m_LastTimeElapsed * _loc2_) {
				return this.m_TimeElapsed;
			}
			return 0;
		}
		return this.m_TimeElapsed;
	}

	// GameTime.as:75-78
	public function getCurrentTime():Float {
		return getTimer() - this.m_tStart;
	}
}
