package interfaces;

import framework.base.BaseLayer;
import module.FarmApplication;

// IModule.as 逐句对应。
interface IModule {
	var container(get, never):BaseLayer;
	var loaded(get, never):Bool;
	var app(get, never):FarmApplication;
	var name(get, never):String;

	function onGameLoop(param1:Float):Void;
	function loadLater(param1:Array<Dynamic>, param2:BaseLayer):Void;
	function onNetRequestStopped():Void;
	function load(param1:BaseLayer):Void;
	function unload():Void;
}
