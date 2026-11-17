package com.qzone.qfa.net;

// IRequest.as 逐句对应。接口方法不允许默认参数，默认值在 HttpRequest 实现上
interface IRequest {
	function send(param1:Dynamic):Void;

	function close():Void;
}
