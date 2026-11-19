package framework.net.parsers;

import common.misc.Utils;
import entities.Dog;
import entities.FarmLand;
import entities.Player;
import entities.StartupData;
import entities.Task;
import entities.Weather;
import framework.net.vo.ServiceResultVO;
import interfaces.ILogicParser;
import shim.As3;

// framework.net.parsers.StartupDataParser —— StartupDataParser.as 逐句对应。
// PORT-NOTE: `param1["x"] != undefined` → Reflect.field(...) != null
//（JSON 里 undefined 与缺失同形）；hasOwnProperty → Reflect.hasField。
class StartupDataParser implements ILogicParser {
	// StartupDataParser.as:17
	private var _result:ServiceResultVO;

	// StartupDataParser.as:19-23
	public function new() {
		_result = new ServiceResultVO();
	}

	// StartupDataParser.as:25-54
	public function parse(param1:Dynamic):ServiceResultVO {
		var _loc2_:StartupData = null;
		if (param1 == null) {
			return null;
		}
		_loc2_ = new StartupData();
		_loc2_._dog = new Dog(Reflect.field(param1, "dog"));
		_loc2_._user = new Player(Reflect.field(param1, "user"));
		_loc2_._task = new Task(Reflect.field(param1, "task"));
		_loc2_._weather = new Weather(Reflect.field(param1, "weather"));
		_loc2_._serverTime = Std.int(Utils.getIntAttribute(Reflect.field(param1, "serverTime"), "time"));
		StartupData.serverTime = _loc2_._serverTime;
		_loc2_._landStatus = parseFarmLandStatus(Reflect.field(param1, "farmlandStatus"));
		_loc2_._decors = Reflect.field(param1, "items");
		_loc2_._welcome = Utils.getIntAttribute(param1, "welcome") > 0 ? true : false;
		_loc2_._unread = parseUnRead(param1);
		_loc2_._beast = Reflect.field(param1, "beast");
		if (Reflect.hasField(param1, "actInfo") && Reflect.hasField(Reflect.field(param1, "actInfo"), "goldLandCard")) {
			_loc2_.upGoldLandTime = Reflect.field(Reflect.field(param1, "actInfo"), "goldLandCard");
		}
		_result.m_extra = _loc2_;
		if (Reflect.field(param1, "exp") != null) {
			_loc2_._user._exp = Std.int(Utils.getIntAttribute(param1, "exp"));
		}
		return _result;
	}

	// StartupDataParser.as:56-67
	private function parseFarmLandStatus(param1:Dynamic):Array<Dynamic> {
		var _loc2_:Array<Dynamic> = new Array<Dynamic>();
		_loc2_ = _loc2_.concat(param1);
		var _loc3_:Array<Dynamic> = new Array<Dynamic>();
		var _loc4_:Int = 0;
		while (_loc4_ < _loc2_.length) {
			_loc3_.push(new FarmLand(_loc2_[_loc4_]));
			_loc4_++;
		}
		return _loc3_;
	}

	// StartupDataParser.as:69-87
	private function parseUnRead(param1:Dynamic):Dynamic {
		var _loc3_:Int = 0;
		if (param1 == null) {
			return null;
		}
		var _loc2_:Dynamic = {};
		Reflect.setField(_loc2_, "a", Reflect.field(param1, "a"));
		Reflect.setField(_loc2_, "b", Reflect.field(param1, "b"));
		Reflect.setField(_loc2_, "c", Reflect.field(param1, "c"));
		Reflect.setField(_loc2_, "d", Reflect.field(param1, "d"));
		if (Reflect.field(param1, "e") != null) {
			// AS3 parseInt：数字/数字串前缀解析（"8"→8、8→8），As3.intOf 等价
			_loc3_ = As3.intOf(Reflect.field(param1, "e"));
			Reflect.setField(_loc2_, "e", _loc3_ >> 3 & 1);
		}
		return _loc2_;
	}
}
