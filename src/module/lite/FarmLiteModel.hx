package module.lite;

import com.adobe.serialization.json.JSON;
import com.qzone.qfa.commands.CmdHttpRequest;
import com.qzone.qfa.data.Resource;
import com.qzone.qfa.events.QFAEvent;
import com.qzone.qfa.managers.CommandManager;
import com.qzone.qfa.managers.ResourceManager;
import common.Settings;
import common.misc.QzoneJSAPI;
import openfl.events.DataEvent;
import openfl.events.EventDispatcher;
import shim.As3;

// FarmLiteModel.as 逐句对应。
// PORT-NOTE(E4X)：XMLDocument(ignoreWhite)+parseXML → Xml.parse。firstChild
// 取根节点、childNodes 取 elements()（ignoreWhite 下等同）、localName →
// nodeName、firstChild.nodeValue → firstChild().nodeValue、attributes.x →
// get("x")。
class FarmLiteModel extends EventDispatcher {
	// FarmLiteModel.as:19
	public static final EVENT_HARVEST:String = "HarvestResult";

	// FarmLiteModel.as:21
	public static final EVENT_HARVEST_ERROR:String = "HarvestError";

	// FarmLiteModel.as:23
	private var _config:String;

	// FarmLiteModel.as:25
	private var _seedConfig:Dynamic;

	// FarmLiteModel.as:27
	private var _requesting:Bool;

	// FarmLiteModel.as:29
	private var _farmJson:Dynamic;

	// FarmLiteModel.as:31-48
	public function new(param1:Dynamic) {
		super(null);
		this._farmJson = param1;
		var _loc2_:String = Settings.getInstance().getStringAttribute("config_data");
		var _loc3_:Resource = ResourceManager.gi().getResource(_loc2_);
		if (_loc3_ != null && _loc3_.loaded == true) {
			this._config = _loc3_.data;
		}
		if (this._farmJson != null && Reflect.hasField(this._farmJson, "user")) {
			if (Reflect.field(Reflect.field(this._farmJson, "user"), "userName") == null
				|| Reflect.field(Reflect.field(this._farmJson, "user"), "userName") == "") {
				Reflect.setField(Reflect.field(this._farmJson, "user"), "userName", QzoneJSAPI.getNickname());
			}
		}
	}

	// FarmLiteModel.as:50-86
	private function updateLandStatus(param1:Dynamic, param2:Dynamic):Void {
		var _loc4_:String = null;
		if (param1 == null || param2 == null) {
			return;
		}
		var _loc3_:Dynamic = {
			"a": "cId",
			"b": "cropStatus",
			"f": "weed",
			"g": "pest",
			"h": "humidity",
			"i": "health",
			"j": "harvestTimes",
			"k": "output",
			"l": "min",
			"m": "leavings",
			"n": "thief",
			"p": "action",
			"q": "plantTime",
			"r": "updateTime",
			"bitmap": "bitmap",
			"pId": "pId",
			"o": "fertilize",
			"c": "oldweed",
			"d": "oldpest",
			"e": "oldhumidity"
		};
		for (_loc4_ in Reflect.fields(_loc3_)) {
			if (Reflect.hasField(param2, Reflect.field(_loc3_, _loc4_))) {
				Reflect.setField(param1, _loc4_, Reflect.field(param2, Reflect.field(_loc3_, _loc4_)));
			}
		}
	}

	// FarmLiteModel.as:88-195
	public function harvest(param1:Int):Void {
		var st:Settings;
		var mode:String;
		var harvest:CmdHttpRequest;
		var url:String;
		var postValue:Dynamic;
		var me:Dynamic;
		var version:String;
		var onSuccess:Dynamic = null;
		var onFailed:Dynamic = null;
		var index:Int = param1;
		onSuccess = function(param1:QFAEvent):Void {
			var _loc6_:Int = 0;
			var _loc7_:Dynamic = null;
			_requesting = false;
			var _loc2_:String = param1.data;
			if (_loc2_ == null || _loc2_ == "") {
				return;
			}
			var _loc3_:Dynamic = JSON.decode(_loc2_);
			var _loc4_:DataEvent = null;
			if (_loc3_ == null || Reflect.field(_loc3_, "code") == 0) {
				_loc4_ = new DataEvent(EVENT_HARVEST_ERROR);
				if (Reflect.hasField(_loc3_, "farmlandIndex")) {
					_loc4_.data = Std.string(Reflect.field(_loc3_, "farmlandIndex"));
				}
				dispatchEvent(_loc4_);
				return;
			}
			if (Reflect.hasField(_loc3_, "status")) {
				_loc6_ = As3.intOf(Reflect.field(_loc3_, "farmlandIndex"));
				if (_loc6_ < 0 || _loc6_ >= this._farmJson.farmlandStatus.length) {
					return;
				}
				_loc7_ = this._farmJson.farmlandStatus[_loc6_];
				updateLandStatus(_loc7_, Reflect.field(_loc3_, "status"));
				_loc4_ = new DataEvent(EVENT_HARVEST);
				_loc4_.data = Std.string(_loc6_) + "," + Std.string(Reflect.field(_loc3_, "harvest"));
				dispatchEvent(_loc4_);
			}
			var _loc5_:Dynamic = this._farmJson.user;
			if (Reflect.hasField(_loc3_, "money")) {
				Reflect.setField(_loc5_, "money", Reflect.field(_loc5_, "money") + Reflect.field(_loc3_, "money"));
			}
			if (Reflect.hasField(_loc3_, "exp")) {
				Reflect.setField(_loc5_, "exp", Reflect.field(_loc5_, "exp") + Reflect.field(_loc3_, "exp"));
			}
		};
		onFailed = function(param1:QFAEvent):Void {
			_requesting = false;
		};
		if (index < 0 || index >= 24) {
			return;
		}
		if (this._farmJson == null || this._requesting == true) {
			return;
		}
		me = this._farmJson.user;
		if (me == null) {
			return;
		}
		harvest = new CmdHttpRequest();
		postValue = {
			"ownerId": Reflect.field(me, "uId"),
			"place": index,
			"tName": Reflect.field(me, "userName"),
			"fName": Reflect.field(me, "userName")
		};
		url = "";
		st = Settings.getInstance();
		mode = st.mode;
		if (mode == "qplus") {
			mode = "qzone";
		}
		version = mode;
		if (version == "qzone") {
			version = "qzone.qq";
		} else if (version == "") {
			version = st.xymode;
		}
		url = "" + version + "mync.php?mod=farmlandstatus&act=harvest";
		url = QzoneJSAPI.addGToken(url);
		CommandManager.getInstance().run(harvest, {
			"url": url,
			"method": "post",
			"params": postValue,
			"complete": onSuccess,
			"error": onFailed
		});
		this._requesting = true;
	}

	// FarmLiteModel.as:197-260
	public var background(get, never):String;

	private function get_background():String {
		var _loc2_:Dynamic = null;
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:Dynamic = null;
		var _loc6_:Dynamic = null;
		var _loc7_:Xml = null;
		var _loc8_:String = null;
		var _loc9_:Dynamic = null;
		var _loc1_:String = "module/ui/farm/diy/1.swf";
		if (Reflect.field(this._farmJson, "items") != null) {
			_loc2_ = Reflect.field(Reflect.field(this._farmJson, "items"), "1");
			if (_loc2_ != null && Reflect.hasField(_loc2_, "itemId") && this._config != null && this._config != "") {
				_loc1_ = "module/ui/farm/diy/" + Reflect.field(_loc2_, "itemId") + ".swf";
				var root:Xml = Xml.parse(this._config).firstElement();
				_loc4_ = [for (node in root.elements()) node];
				_loc5_ = null;
				_loc7_ = null;
				for (_loc7_ in _loc4_) {
					if (_loc7_.nodeName == "item_info") {
						_loc5_ = JSON.decode(_loc7_.firstChild().nodeValue);
						if (_loc5_ != null) {
							_loc6_ = Reflect.field(_loc5_, "crops");
						}
						break;
					}
				}
				_loc8_ = "";
				// 迭代目标按 Array 显式标注（Haxe 不允许迭代 Dynamic）
				for (_loc9_ in (_loc6_ : Array<Dynamic>)) {
					if (Reflect.field(_loc9_, "id") == Reflect.field(_loc2_, "itemId")
						&& Reflect.field(Reflect.field(_loc9_, "asset_id"), "m") != null) {
						_loc8_ = Reflect.field(Reflect.field(_loc9_, "asset_id"), "m");
						break;
					}
				}
				for (_loc7_ in _loc4_) {
					if (_loc7_.nodeName == "assets") {
						// 原版在此重赋 _loc4_（外层循环按原数组继续迭代）
						_loc4_ = [for (node in _loc7_.elements()) node];
						for (_loc7_ in _loc4_) {
							if (_loc7_.get("id") == _loc8_) {
								_loc1_ = _loc7_.get("url");
								break;
							}
						}
						break;
					}
				}
			}
		}
		return Settings.getInstance().replaceAppImg(_loc1_);
	}

	// FarmLiteModel.as:262-273
	public var landCount(get, never):Int;

	private function get_landCount():Int {
		if (this._farmJson == null || !Reflect.hasField(this._farmJson, "farmlandStatus")) {
			return 0;
		}
		if (Std.isOfType(Reflect.field(this._farmJson, "farmlandStatus"), Array)) {
			return Reflect.field(Reflect.field(this._farmJson, "farmlandStatus"), "length");
		}
		return 0;
	}

	// FarmLiteModel.as:275-343
	public function idState(param1:Int, param2:Float, param3:Int, param4:Int, param5:Int):Int {
		var _loc8_:Array<Dynamic> = null;
		var _loc15_:Int = 0;
		var _loc16_:Int = 0;
		if (param1 == 0) {
			return 0;
		}
		if (param3 == 7) {
			return 7;
		}
		var _loc6_:Dynamic = this.getCropByID(Std.string(param1));
		if (_loc6_ == null) {
			return 0;
		}
		var _loc7_:String = Reflect.field(_loc6_, "cropGrow");
		if (_loc7_ == "") {
			return 0;
		}
		_loc8_ = _loc7_.split(",");
		var _loc9_:Float;
		var _loc10_:Float = _loc9_ = Std.parseFloat(Reflect.field(Reflect.field(this._farmJson, "serverTime"), "time"));
		var _loc11_:Float = _loc10_ - param2;
		var _loc12_:Int = _loc8_.length;
		var _loc13_:Int = 0;
		var _loc14_:Int = _loc12_ - 1;
		while (_loc14_ >= 0) {
			if (param4 != 2) {
				_loc13_ = As3.intOf(_loc8_[_loc14_]);
			} else if (Reflect.field(_loc6_, "isRed") == "2") {
				_loc13_ = As3.intOf(_loc8_[_loc14_]);
			} else if (_loc14_ < _loc12_ - 2) {
				_loc13_ = Std.int(Math.floor(_loc8_[_loc14_] * 0.8));
			} else {
				_loc13_ = Std.int(Math.floor(_loc8_[_loc14_] * 0.8));
				_loc15_ = _loc13_ % 600;
				if (_loc13_ > _loc15_) {
					_loc13_ -= _loc15_;
				}
			}
			if (_loc11_ >= _loc13_) {
				_loc16_ = _loc14_ + 1;
				if (param5 > 0) {
					if (_loc16_ < 3) {
						return 3;
					}
				}
				return _loc14_ + 1;
			}
			_loc14_--;
		}
		return 0;
	}

	// FarmLiteModel.as:345-387
	private function getCropByID(param1:String):Dynamic {
		var _loc2_:Dynamic = null;
		var _loc3_:Xml = null;
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:Dynamic = null;
		var _loc6_:Xml = null;
		if (this._config == null || this._config == "") {
			return null;
		}
		if (this._seedConfig == null) {
			var root:Xml = Xml.parse(this._config).firstElement();
			_loc4_ = [for (node in root.elements()) node];
			for (_loc6_ in _loc4_) {
				if (_loc6_.nodeName == "crops") {
					_loc5_ = JSON.decode(_loc6_.firstChild().nodeValue);
					if (_loc5_ != null) {
						this._seedConfig = Reflect.field(_loc5_, "crops");
					}
					break;
				}
			}
		}
		if (this._seedConfig == null) {
			return null;
		}
		for (_loc2_ in (this._seedConfig : Array<Dynamic>)) {
			if (Reflect.field(_loc2_, "id") == param1) {
				return _loc2_;
			}
		}
		return null;
	}

	// FarmLiteModel.as:389-397
	public function getLandByIndex(param1:Int):Dynamic {
		var _loc2_:Array<Dynamic> = this._farmJson.farmlandStatus;
		if (_loc2_ == null || param1 >= _loc2_.length) {
			return null;
		}
		return _loc2_[param1];
	}

	// FarmLiteModel.as:399-404
	public function finalize():Void {
		this._farmJson = null;
		this._config = null;
		this._seedConfig = null;
	}
}
