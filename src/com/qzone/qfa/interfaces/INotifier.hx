package com.qzone.qfa.interfaces;

// INotifier.as 逐句对应（Function → Dynamic）。
interface INotifier {
	function notify(param1:String):Void;

	function removeNotifier(param1:String, param2:Dynamic):Void;

	function addNotifier(param1:String, param2:Dynamic):Void;
}
