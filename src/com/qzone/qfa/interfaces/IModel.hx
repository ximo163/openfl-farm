package com.qzone.qfa.interfaces;

// IModel.as 逐句对应。
interface IModel extends INotifier {
	function getData(param1:String):Dynamic;

	function flush():Void;

	function setData(param1:String, param2:Dynamic):Bool;
}
