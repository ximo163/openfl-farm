package interfaces;

import openfl.events.Event;

// interfaces.IMsgCenter —— IMsgCenter.as 逐句对应（AS3 interface → Haxe interface；
// Function 参数 → Dynamic）。签名保持原版的 void 返回（FarmApplication 用自己的
// m_dispatcher 转发，不经 EventDispatcher 继承链）。
interface IMsgCenter {
	function dispatchEvent(param1:Event):Void;

	function removeEventListener(param1:String, param2:Dynamic):Void;

	function addEventListener(param1:String, param2:Dynamic, param3:Bool = false, param4:Int = 0, param5:Bool = false):Void;
}
