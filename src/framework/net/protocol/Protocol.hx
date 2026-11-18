package framework.net.protocol;

import com.adobe.serialization.json.JSON;
import com.qzone.qfa.debug.Debugger;
import common.CommonData;
import common.Consts;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import openfl.net.URLVariables;
import openfl.utils.ByteArray;

// framework.net.protocol.Protocol —— Protocol.as 逐句对应。
// PORT-NOTE: URLVariables 在 openfl 9.5.2 是 abstract URLVariables(Dynamic)，
// `_loc6_["k"] = v` 的动态键写经 Reflect.setField 等价复刻（语义一致：
// 键值都落在底层对象上）。
class Protocol {
	// Protocol.as:10
	public static var _userUin:String = "";

	// Protocol.as:12-16
	private var m_cmdID:UInt;
	private var m_response:Dynamic;
	private var m_request:Dynamic;

	public function new(param1:UInt) {
		m_request = null;
		m_response = null;
		m_cmdID = param1;
	}

	// Protocol.as:32-57
	public function decodeForHttp():Dynamic {
		var loadStr:String = null;
		var data:Dynamic = null;
		if (m_response == null) {
			return null;
		}
		loadStr = "";
		try {
			data = null;
			loadStr = dataToString(m_response);
			if (new EReg("^[\\{\\[].*", "").match(loadStr) == false) {
				loadStr = "{\"errorType\" : \"ReponseError\", \"errorContent\":\"" + loadStr + "\"}";
			}
			data = JSON.decode(loadStr, false);
			return data;
		} catch (e:Dynamic) {
			Debugger.log("JSON解码错误:" + e + "\n" + loadStr);
		}
		return null;
	}

	// Protocol.as:59-61
	public function importResponseObject(param1:Dynamic):Void {
		m_response = param1;
	}

	// Protocol.as:63-65
	public function importRequestObject(param1:Dynamic):Void {
		m_request = param1;
	}

	// Protocol.as:67-75
	public var cmdID(get, set):UInt;

	private function get_cmdID():UInt {
		return m_cmdID;
	}

	private function set_cmdID(param1:UInt):UInt {
		m_cmdID = param1;
		return param1;
	}

	// Protocol.as:77-88。PORT-NOTE: Object.toString() → Std.string
	//（String 入参即原串，ByteArray 分支在前面）
	private function dataToString(param1:Dynamic):String {
		var _loc2_:ByteArray = null;
		if (Std.isOfType(param1, ByteArray)) {
			_loc2_ = param1;
			_loc2_.position = 0;
			return _loc2_.readUTFBytes(_loc2_.length);
		}
		return Std.string(param1);
	}

	// Protocol.as:92-131
	public function encodeForHttp(param1:String, param2:String = "text"):URLVariables {
		var _loc7_:String = null;
		var _loc8_:String = null;
		var _loc3_:Session = Session.getInstance();
		var _loc4_:String = "";
		if (CommonData.getKey != null) {
			_loc4_ = CommonData.getKey();
		}
		var _loc5_:String = Std.string(CommonData.serverTime);
		var _loc6_:URLVariables = new URLVariables();
		if (param1 != "" && param1.toUpperCase() == Consts.NET_HTTP_METHOD_POST) {
			Reflect.setField(_loc6_, "farmKey", _loc4_);
			Reflect.setField(_loc6_, "farmTime", _loc5_);
			Reflect.setField(_loc6_, "uIdx", _loc3_.hostId);
		}
		if (Settings.getInstance().mode == "qzone" && param1.toUpperCase() == Consts.NET_HTTP_METHOD_POST) {
			_loc7_ = _userUin;
			if (_loc7_ != "") {
				Reflect.setField(_loc6_, "uinX", _loc7_);
			}
			Reflect.setField(_loc6_, "uinY", _loc3_.hostUin);
		}
		if (QzoneJSAPI.WB == true) {
			Reflect.setField(_loc6_, "platform", 3);
		}
		if (m_request != null) {
			for (_loc8_ in Reflect.fields(m_request)) {
				Reflect.setField(_loc6_, _loc8_, Reflect.field(m_request, _loc8_));
			}
		}
		return _loc6_;
	}

	// Protocol.as:133-136
	public function encodeForSocks():Dynamic {
		return null;
	}
}
