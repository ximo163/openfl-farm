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
// PORT-NOTE(E4X)：new XMLDocument() + ignoreWhite=true + parseXML → Xml.parse。
// 两点语义差都在导航上补齐：
// 1) ignoreWhite 丢纯空白文本节点——真实 xml.php 下发的 nc_data 里
//    <crops>/<item_info> 都是「换行缩进 + CDATA(JSON) + 换行」形态，AS3 的
//    firstChild 取到 CDATA，而 haxe.xml.Parser 保留空白 PCData，firstChild()
//    会取到 "\n\t\t"。firstChild → firstChildIgnoreWhite()（首个非纯空白子
//    节点）；childNodes 在 ignoreWhite 下与本处只按元素名比较的用法等同
//    elements()；localName → nodeName；attributes.x → get("x")。
// 2) 局部变量必须静态类型 Xml（原版就是 XMLNode/Array 的组合）：html5 走
//    -dce full，Xml 的 inline 方法（firstChild 等）只被静态调用时才内联保留，
//    Dynamic 调用会在产物里找不到原型方法（CI 实测 `_loc7_.firstChild is not
//    a function`）。
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
		var _loc4_:Array<Xml> = null;
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
						_loc5_ = JSON.decode(firstChildIgnoreWhite(_loc7_).nodeValue);
						if (_loc5_ != null) {
							_loc6_ = Reflect.field(_loc5_, "crops");
						}
						break;
					}
				}
				_loc8_ = "";
				// 原版 for each(_loc9_ in _loc6_)：_loc6_ 取 item_info JSON 的
				// "crops" 键，真实 nc_data 的 item_info JSON（{"item_info":[…]}）没有
				// 这个键，AS3 对 undefined 做 for-each 零次迭代；Haxe 迭代 null 在
				// js 上抛错，null 守卫对齐原语义
				if (_loc6_ != null) {
					for (_loc9_ in (_loc6_ : Array<Dynamic>)) {
						if (Reflect.field(_loc9_, "id") == Reflect.field(_loc2_, "itemId")
							&& Reflect.field(Reflect.field(_loc9_, "asset_id"), "m") != null) {
							_loc8_ = Reflect.field(Reflect.field(_loc9_, "asset_id"), "m");
							break;
						}
					}
				}
				for (_loc7_ in _loc4_) {
					if (_loc7_.nodeName == "assets") {
						// 原版在此重赋 _loc4_（外层循环随后立即 break，重赋不影响
						// 外层迭代次数，与 AS3「for-each 启动时取一次数组」等价）
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
		var _loc4_:Array<Xml> = null;
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
					_loc5_ = JSON.decode(firstChildIgnoreWhite(_loc6_).nodeValue);
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

	// XMLDocument(ignoreWhite=true) 语义下的 firstChild：AS3 解析时丢弃纯空白
	// 文本节点（空格/\t/\n/\r，XMLNode.ignoreWhite 的字符集），firstChild 即
	// CDATA/正文；haxe.xml.Parser 保留空白 PCData，这里导航时跳过它们
	private static function firstChildIgnoreWhite(param1:Xml):Xml {
		var _loc1_:Xml = null;
		for (_loc1_ in param1) {
			if (_loc1_.nodeType == Xml.PCData && isWhiteSpace(_loc1_.nodeValue)) {
				continue;
			}
			return _loc1_;
		}
		return null;
	}

	private static function isWhiteSpace(param1:String):Bool {
		var _loc1_:Int = 0;
		var _loc2_:String = null;
		while (_loc1_ < param1.length) {
			_loc2_ = param1.charAt(_loc1_);
			if (_loc2_ != " " && _loc2_ != "\t" && _loc2_ != "\n" && _loc2_ != "\r") {
				return false;
			}
			_loc1_++;
		}
		return true;
	}

	// FarmLiteModel.as:399-404
	public function finalize():Void {
		this._farmJson = null;
		this._config = null;
		this._seedConfig = null;
	}
}
