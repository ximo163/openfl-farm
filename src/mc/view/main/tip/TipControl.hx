package mc.view.main.tip;

import mc.control.ViewControl;
import mc.events.TipEvent;

/**
 * mc.view.main.tip.TipControl —— TipControl.as 逐句对应（issue #19 Master2
 * 闭包顺手译）。提示开闭静态门面，经 ViewControl 派发 TipEvent。
 */
@:keep
class TipControl {
	public function new() {}

	// TipControl.as:14-18
	public static function hide():Void {
		var _loc1_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
		ViewControl.getInstance().dispatchEvent(_loc1_);
	}

	// TipControl.as:20-28
	public static function show(param1:String, param2:Dynamic, param3:Int = 0, param4:Int = 0):Void {
		var _loc5_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
		_loc5_.tipArgument = param2;
		_loc5_.tipType = param1;
		_loc5_.tX = param3;
		_loc5_.tY = param4;
		ViewControl.getInstance().dispatchEvent(_loc5_);
	}
}
