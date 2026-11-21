package common.view.floating;

import events.FloatingEvent;
import interfaces.IMsgCenter;

/**
 * common.view.floating.FloatControl —— FloatControl.as 逐句对应（issue #9）。
 * 飘字控件：类注册表 + open/close 经 msgCenter 派发 FloatingEvent。
 */
class FloatControl {
	// FloatControl.as:6
	private var m_msgCenter:IMsgCenter;

	// FloatControl.as:8
	private var m_lib:Dynamic;

	// FloatControl.as:13-18
	public function new(param1:IMsgCenter) {
		this.m_lib = null;
		this.m_msgCenter = param1;
	}

	// FloatControl.as:20-27（open：FLOATING_OPEN 带 floating/fid/data 派发）
	public function open(param1:String, param2:Int = 0, param3:Dynamic = null):Void {
		var _loc4_:FloatingEvent = new FloatingEvent(FloatingEvent.FLOATING_OPEN);
		_loc4_.floating = param1;
		_loc4_.fid = param2;
		_loc4_.data = param3;
		this.m_msgCenter.dispatchEvent(_loc4_);
	}

	// FloatControl.as:29-32
	public function getMsgControl():IMsgCenter {
		return this.m_msgCenter;
	}

	// FloatControl.as:34-41（getClass：注册表查类）
	public function getClass(param1:String):Class<Dynamic> {
		if (this.m_lib == null) {
			return null;
		}
		return Reflect.field(this.m_lib, param1);
	}

	// FloatControl.as:43-50（register：floating 名 → 类）
	public function register(param1:String, param2:Class<Dynamic>):Void {
		if (this.m_lib == null) {
			this.m_lib = {};
		}
		Reflect.setField(this.m_lib, param1, param2);
	}

	// FloatControl.as:52-58（close：FLOATING_CLOSE 只带 floating 名派发）
	public function close(param1:String):Void {
		var _loc2_:FloatingEvent = new FloatingEvent(FloatingEvent.FLOATING_CLOSE);
		_loc2_.floating = param1;
		this.m_msgCenter.dispatchEvent(_loc2_);
	}
}
