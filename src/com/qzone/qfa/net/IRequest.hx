package com.qzone.qfa.net;

// IRequest.as 逐句对应。AS3 接口方法自带默认参数（param1:Object = null），
// Haxe 写 `?param1:Dynamic`（HttpRequest 实现的 `param1:Dynamic = null` 与之匹配）
interface IRequest {
	function send(?param1:Dynamic):Void;

	function close():Void;
}
