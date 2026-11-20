package support;

import interfaces.IMsgCenter;
import openfl.events.Event;

// 测试侧 IMsgCenter 假实现：只记录派发的事件（issue #9）。原版
// FarmApplication 的 msgCenter 是全局面板/飘字/光标总线，单测只关心
// 派发内容本身。
class FakeMsgCenter implements IMsgCenter {
	public var events:Array<Event> = [];

	public function new() {}

	public function dispatchEvent(param1:Event):Void {
		this.events.push(param1);
	}

	public function removeEventListener(param1:String, param2:Dynamic):Void {}

	public function addEventListener(param1:String, param2:Dynamic, param3:Bool = false, param4:Int = 0, param5:Bool = false):Void {}
}
