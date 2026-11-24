package common.view.tip;

import events.TipEvent;
import interfaces.IMsgCenter;

/**
 * common.view.tip.TipControl —— TipControl.as 逐句对应（issue #42，替换 #7
 * 的闭包 stub）。提示控制面：tip 名 → 类的注册表（FarmStage 建层时灌入），
 * show/update/hide 把请求派发成 TipEvent，由 TipLayer 监听落地。
 */
@:keep
class TipControl {
	// TipControl.as:9
	private var m_msgCenter:IMsgCenter;

	// TipControl.as:11（null 起手，register 才建对象——getClass 的 null 门）
	private var m_lib:Dynamic;

	// TipControl.as:13-18
	public function new(param1:IMsgCenter) {
		this.m_lib = null;
		this.m_msgCenter = param1;
	}

	// TipControl.as:20-23
	public function getMsgCenter():IMsgCenter {
		return this.m_msgCenter;
	}

	// TipControl.as:25-31
	public function update(param1:String, param2:Dynamic):Void {
		var _loc3_:TipEvent = new TipEvent(TipEvent.TIP_UPDATE);
		_loc3_.tipArgument = param2;
		_loc3_.tipType = param1;
		this.m_msgCenter.dispatchEvent(_loc3_);
	}

	// TipControl.as:33-40
	public function getClass(param1:String):Class<Dynamic> {
		if (this.m_lib == null) {
			return null;
		}
		return Reflect.field(this.m_lib, param1);
	}

	// TipControl.as:42-46
	public function hide():Void {
		var _loc1_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
		this.m_msgCenter.dispatchEvent(_loc1_);
	}

	// TipControl.as:48-55
	public function register(param1:String, param2:Class<Dynamic>):Void {
		if (this.m_lib == null) {
			this.m_lib = {};
		}
		Reflect.setField(this.m_lib, param1, param2);
	}

	// TipControl.as:57-65
	public function show(param1:String, param2:Dynamic, param3:Int = 0, param4:Int = 0):Void {
		var _loc5_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
		_loc5_.tipArgument = param2;
		_loc5_.tipType = param1;
		_loc5_.tX = param3;
		_loc5_.tY = param4;
		this.m_msgCenter.dispatchEvent(_loc5_);
	}
}
