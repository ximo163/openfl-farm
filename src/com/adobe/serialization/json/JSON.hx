package com.adobe.serialization.json;

// JSON.as 逐句对应（as3corelib 门面）。解析器/编码器本体（JSONDecoder/
// JSONEncoder/JSONTokenizer…）不逐类移植，等价落到 haxe.Json：
// PORT-NOTE: haxe.Json 是严格 JSON；as3corelib 的 decode(param1, param2) 第二参
// 允许注释/尾逗号等宽松语法（默认开）。本 swf 的 decode 输入全部来自自家
// mync.php/宿主 getAppParams，都是标准 JSON 字符串，等价（deviations 候选）。
class JSON {
	public function new() {
	}

	// JSON.as:11-14
	public static function decode(param1:String, param2:Bool = true):Dynamic {
		return haxe.Json.parse(param1);
	}

	// JSON.as:16-19
	public static function encode(param1:Dynamic):String {
		return haxe.Json.stringify(param1);
	}
}
