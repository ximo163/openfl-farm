package events;

import openfl.events.Event;

/**
 * events.CommonEvent —— write-tests stub（issue #7）：签名与
 * legacy/decompiled/main3_v_221/scripts/events/CommonEvent.as 一致
 * （_data :8、_result :10、构造 :12-17、data/result get/set :19-37），
 * 方法体 `throw new Error("not implemented")`，实现在翻译阶段完成。
 *
 * FarmLandModel 派发全部用这个事件（FarmLandModel.as:24 import），闭包内
 * 39 行（≤100）按规则随翻译阶段整体翻译。
 */
class CommonEvent extends Event {
	// CommonEvent.as:8/:10
	private var _data:Dynamic;
	private var _result:Dynamic;

	public function new(param1:String, param2:Dynamic, param3:Dynamic = null, param4:Bool = false, param5:Bool = false) {
		super(param1, param4, param5);
		throw new openfl.errors.Error("not implemented");
	}

	// CommonEvent.as:19-32（result set / data set+get）
	public var data(get, set):Dynamic;
	public var result(get, set):Dynamic;

	private function get_data():Dynamic {
		throw new openfl.errors.Error("not implemented");
	}

	private function set_data(param1:Dynamic):Dynamic {
		throw new openfl.errors.Error("not implemented");
	}

	private function get_result():Dynamic {
		throw new openfl.errors.Error("not implemented");
	}

	private function set_result(param1:Dynamic):Dynamic {
		throw new openfl.errors.Error("not implemented");
	}
}
