package com.qzone.qfa.core;

// ICommand.as 逐句对应。接口方法不允许默认参数（Haxe），默认值落在实现类上
interface ICommand {
	function execute(param1:Dynamic):Void;
}
