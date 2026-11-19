package com.qzone.qfa.interfaces;

import com.qzone.qfa.view.AppStage;

// IApplication.as 逐句对应（AS3 interface 的 get/set 属性 → Haxe interface 的
// `var x(get, set)` 属性声明，实现方提供 get_x/set_x）。
interface IApplication {
	var model(get, set):IModel;

	var view(get, set):AppStage;

	var name(get, set):String;

	function run(param1:Class<Dynamic>, param2:Dynamic = null, param3:String = "", param4:Dynamic = null, param5:Dynamic = null, param6:Dynamic = null):Void;

	function kill(param1:Class<Dynamic>):Void;
}
