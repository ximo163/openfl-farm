package com.qzone.qfa.core;

// ICommand.as 逐句对应。AS3 接口方法自带默认参数（param1:* = null），Haxe 写
// `?param1:Dynamic`（实现类的 `param1:Dynamic = null` 与之匹配）
interface ICommand {
	function execute(?param1:Dynamic):Void;
}
