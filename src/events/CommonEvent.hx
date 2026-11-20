package events;

import openfl.events.Event;

// events.CommonEvent —— CommonEvent.as 逐句对应。
class CommonEvent extends Event {
	// CommonEvent.as:8/:10（_data/_result 为 AS3 存储字段；Haxe 侧用 @:isVar
	// 让 data/result 有物理字段：AS3 的动态访问 e.data 会走访问器，Haxe 普通
	// property 在 eval/js 上经 Dynamic 读是 null，@:isVar 才同语义）
	@:isVar
	public var data(get, set):Dynamic;
	@:isVar
	public var result(get, set):Dynamic;

	// CommonEvent.as:12-17（param2 必填，无默认值）
	public function new(param1:String, param2:Dynamic, param3:Dynamic = null, param4:Bool = false, param5:Bool = false) {
		super(param1, param4, param5);
		this.data = param2;
		this.result = param3;
	}

	// CommonEvent.as:19-37（result set / data set+get）
	private function get_data():Dynamic {
		return this.data;
	}

	private function set_data(param1:Dynamic):Dynamic {
		this.data = param1;
		return param1;
	}

	private function get_result():Dynamic {
		return this.result;
	}

	private function set_result(param1:Dynamic):Dynamic {
		this.result = param1;
		return param1;
	}
}
