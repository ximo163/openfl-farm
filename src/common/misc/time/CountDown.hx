package common.misc.time;

import openfl.errors.ArgumentError;

/**
 * common.misc.time.CountDown —— V3b 顺手翻（issue #8 闭包，CountDown.as
 * 39 loc ≤ 100；FarmLandController 的 10s 农田刷新节拍）。
 * legacy/decompiled/main3_v_221/scripts/common/misc/time/CountDown.as
 * 逐句对应。
 */
class CountDown {
	// CountDown.as:7
	private var m_counter:Int;

	// CountDown.as:9-13
	public function new(param1:UInt) {
		this.reset(param1);
	}

	// CountDown.as:15-23（isReady：自减计数，归零侧即就绪）
	public function isReady():Bool {
		--this.m_counter;
		if (this.m_counter <= 0) {
			return true;
		}
		return false;
	}

	// CountDown.as:25-27
	public function toString():String {
		return "count down left : " + this.m_counter;
	}

	// CountDown.as:29-37（reset：0 是非法节拍）
	public function reset(param1:UInt):Void {
		if (param1 == 0) {
			throw new ArgumentError("Invalid argument for a counter.");
		}
		this.m_counter = param1;
	}
}
