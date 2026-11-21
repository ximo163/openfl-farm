package common;

import com.qzone.qfa.interfaces.IModel;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import openfl.display.LoaderInfo;
import openfl.errors.ArgumentError;
import openfl.Lib.getTimer;
import shim.As3;

// Settings.as 逐句对应。getter 统一 `var x(get, never)` + `get_x()`。
class Settings {
	// Settings.as:13
	private static var _instance:Settings;

	// Settings.as:15
	public static final TIP_VALUE:String = "value";

	// Settings.as:17
	public static final TIP_URL:String = "url";

	// Settings.as:19
	private var m_initTime:Int;

	// Settings.as:21
	private var m_params:Dynamic;

	// Settings.as:23
	private var m_appImgPrefix:String;

	// Settings.as:25
	private var m_configDataModel:IModel;

	// Settings.as:27
	private var m_resolveUrl:String;

	// Settings.as:29
	private var m_mcCommUrl:String;

	// Settings.as:31
	private var m_ncCommUrl:String;

	// Settings.as:33-40
	public function new() {
		this.m_initTime = getTimer();
		this.m_params = null;
		this.m_appImgPrefix = "";
		this.m_resolveUrl = "";
	}

	// Settings.as:42-59
	public static var isQZoneUinMode(get, never):Bool;

	private static function get_isQZoneUinMode():Bool {
		if (_instance == null) {
			return false;
		}
		if (QzoneJSAPI.WB == true) {
			return false;
		}
		var _loc1_:String = _instance.getStringAttribute("uinMode");
		var _loc2_:String = _instance.mode;
		if (_loc1_ == "1" && _loc2_ == "qzone") {
			return true;
		}
		return false;
	}

	// Settings.as:61-69
	public static function getInstance():Settings {
		if (_instance != null) {
			return _instance;
		}
		_instance = new Settings();
		return _instance;
	}

	// Settings.as:71-78
	public function getWildCfg():Xml {
		if (this.m_configDataModel == null) {
			return null;
		}
		return this.m_configDataModel.getData("wild");
	}

	// Settings.as:80-83
	public function getSeedName(param1:Int):String {
		return "Crop_" + param1 + "_Seed";
	}

	// Settings.as:85-88
	public var appImgPrefix(get, never):String;

	private function get_appImgPrefix():String {
		return this.m_appImgPrefix;
	}

	// Settings.as:90-110
	public function getFishByID(param1:String):Dynamic {
		var _loc3_:Dynamic = null;
		if (this.m_configDataModel == null) {
			return null;
		}
		var _loc2_:Array<Dynamic> = this.m_configDataModel.getData("fish_info");
		if (_loc2_ == null) {
			return null;
		}
		for (_loc3_ in _loc2_) {
			if (Reflect.field(_loc3_, "id") == param1) {
				return _loc3_;
			}
		}
		return null;
	}

	// Settings.as:112-132
	public var mode(get, never):String;

	private function get_mode():String {
		if (this.getStringAttribute("agent") == "qplus") {
			return "qzone";
		}
		if (this.getStringAttribute("agent") == "weibo") {
			return "qzone";
		}
		var _loc1_:String = this.getStringAttribute("mode");
		if (_loc1_ == "1") {
			_loc1_ = "qzone";
		} else {
			_loc1_ = "";
		}
		return _loc1_;
	}

	// Settings.as:134-146（两个分支都返回 ""，原版逐字保留）
	public var xymode(get, never):String;

	private function get_xymode():String {
		var _loc1_:String = this.getStringAttribute("pageDomain");
		if (_loc1_ == "") {
			_loc1_ = "";
		} else {
			_loc1_ = "";
		}
		return _loc1_;
	}

	// Settings.as:148-168
	public function getSecondUrl(param1:String):String {
		var _loc3_:Dynamic = null;
		if (this.m_configDataModel == null) {
			return "";
		}
		var _loc2_:Array<Dynamic> = this.m_configDataModel.getData("secondList");
		if (_loc2_ == null || _loc2_.length == 0) {
			return "";
		}
		for (_loc3_ in _loc2_) {
			if (Reflect.field(_loc3_, "id") == param1) {
				return this.replaceAppImg(Reflect.field(_loc3_, "src"));
			}
		}
		return "";
	}

	// Settings.as:170-188
	public function getCardsGameRewardIDs():Array<Dynamic> {
		var _loc3_:Dynamic = null;
		var _loc1_:Array<Dynamic> = new Array();
		if (this.m_configDataModel == null) {
			return _loc1_;
		}
		var _loc2_:Dynamic = this.m_configDataModel.getData("cardsGameRewards");
		if (_loc2_ == null) {
			return _loc1_;
		}
		for (_loc3_ in Reflect.fields(_loc2_)) {
			_loc1_.push(Std.parseInt(Reflect.field(Reflect.field(_loc2_, _loc3_), "bid")));
		}
		return _loc1_.concat([]);
	}

	// Settings.as:190-193
	public function getCropName(param1:Int):String {
		return "Crop_" + param1;
	}

	// Settings.as:195-207
	public function getFreeGift(param1:String):Dynamic {
		if (this.m_configDataModel == null) {
			return "";
		}
		var _loc2_:Dynamic = this.m_configDataModel.getData("freegifts");
		if (_loc2_ == null) {
			return "";
		}
		return Reflect.field(_loc2_, param1);
	}

	// Settings.as:209-222。String.replace(String,String) 只换第一处 → As3.replaceFirst
	public function replaceAppImg(param1:String):String {
		if (this.appImgPrefix != "" && param1 != "") {
			if (param1.indexOf("" + this.appImgPrefix + ".") == 0 || param1.indexOf(this.appImgPrefix + ".") == 0) {
				return param1;
			}
			param1 = As3.replaceFirst(param1, "appimg.", this.appImgPrefix + ".appimg.");
			param1 = As3.replaceFirst(param1, "appimg1.", this.appImgPrefix + ".appimg1.");
			param1 = As3.replaceFirst(param1, "appimg3.", this.appImgPrefix + ".appimg3.");
		}
		return param1;
	}

	// Settings.as:224-244
	public function getDIYByID(param1:String):Dynamic {
		var _loc3_:Dynamic = null;
		if (this.m_configDataModel == null) {
			return null;
		}
		var _loc2_:Array<Dynamic> = this.m_configDataModel.getData("item_info");
		if (_loc2_ == null) {
			return null;
		}
		for (_loc3_ in _loc2_) {
			if (Reflect.field(_loc3_, "id") == param1) {
				return _loc3_;
			}
		}
		return null;
	}

	// Settings.as:246-249
	public function getCardName(param1:Int):String {
		return "Card_" + param1;
	}

	// Settings.as:251-254
	public function getCrystalName(param1:String, param2:Int):String {
		return "Nc_Drop_" + param1 + "_" + param2;
	}

	// Settings.as:256-259
	public function setConfigDataModel(param1:IModel):Void {
		this.m_configDataModel = param1;
	}

	// Settings.as:261-264
	public function getWeaponName(param1:String, param2:Int):String {
		return "Weapon_Icon_" + param1 + "_" + param2;
	}

	// Settings.as:266-274
	public var app_key(get, never):String;

	private function get_app_key():String {
		var _loc1_:String = this.getStringAttribute("app_key");
		if (_loc1_ == "") {
			_loc1_ = "happyfarm";
		}
		return _loc1_;
	}

	// Settings.as:276-283
	public function getBillBoardData():Array<Dynamic> {
		if (this.m_configDataModel == null) {
			return null;
		}
		return this.m_configDataModel.getData("boards");
	}

	// Settings.as:285-288
	public var dataConfigUrl(get, never):String;

	private function get_dataConfigUrl():String {
		return this.replaceAppImg(this.getStringAttribute("config_data"));
	}

	// Settings.as:290-301
	public var domain(get, never):String;

	private function get_domain():String {
		if (this.mode == "qzone") {
			return this.getStringAttribute("domian_qz");
		}
		if (this.mode == "qplus") {
			return this.getStringAttribute("domian_qz");
		}
		return this.getStringAttribute("domian_xy");
	}

	// Settings.as:303-321
	public function getFreeGiftID():Array<Dynamic> {
		var _loc3_:Dynamic = null;
		var _loc1_:Array<Dynamic> = new Array();
		if (this.m_configDataModel == null) {
			return _loc1_;
		}
		var _loc2_:Dynamic = this.m_configDataModel.getData("freegifts");
		if (_loc2_ == null) {
			return _loc1_;
		}
		for (_loc3_ in Reflect.fields(_loc2_)) {
			_loc1_.push(Std.parseInt(Reflect.field(Reflect.field(_loc2_, _loc3_), "bid")));
		}
		return _loc1_.concat([]);
	}

	// Settings.as:323-335
	public function getCardsGameReward(param1:String):Dynamic {
		if (this.m_configDataModel == null) {
			return "";
		}
		var _loc2_:Dynamic = this.m_configDataModel.getData("cardsGameRewards");
		if (_loc2_ == null) {
			return "";
		}
		return Reflect.field(_loc2_, param1);
	}

	// Settings.as:337-353
	public function getDynamicTip(param1:String, param2:String = "value"):String {
		if (this.m_configDataModel == null) {
			return "";
		}
		var _loc3_:Dynamic = this.m_configDataModel.getData("dynamicTips");
		if (_loc3_ == null) {
			return "";
		}
		if (Reflect.hasField(_loc3_, param1)) {
			return Reflect.field(Reflect.field(_loc3_, param1), param2);
		}
		return "";
	}

	// Settings.as:355-358
	public var allCfgData(get, never):Dynamic;

	private function get_allCfgData():Dynamic {
		return this.m_params;
	}

	// Settings.as:360-374。值非 String 一律回落 ""（含显式 null）
	public function getStringAttribute(param1:String):String {
		if (param1 == null || param1.length == 0) {
			return "";
		}
		if (this.m_params != null && Reflect.hasField(this.m_params, param1)) {
			if (Std.isOfType(Reflect.field(this.m_params, param1), String)) {
				return Reflect.field(this.m_params, param1);
			}
		}
		return "";
	}

	// Settings.as:376-396
	public function getCropByID(param1:String):Dynamic {
		var _loc3_:Dynamic = null;
		if (this.m_configDataModel == null) {
			return null;
		}
		var _loc2_:Array<Dynamic> = this.m_configDataModel.getData("crops");
		if (_loc2_ == null) {
			return null;
		}
		for (_loc3_ in _loc2_) {
			if (Reflect.field(_loc3_, "id") == param1) {
				return _loc3_;
			}
		}
		return null;
	}

	// Settings.as:398-401
	public var mcCommUrl(get, never):String;

	private function get_mcCommUrl():String {
		return this.m_mcCommUrl;
	}

	// Settings.as:403-406
	public var ncCommUrl(get, never):String;

	private function get_ncCommUrl():String {
		return this.m_ncCommUrl;
	}

	// Settings.as:408-425
	public function getUrlConfigByName(param1:String):String {
		var _loc3_:Dynamic = null;
		var _loc2_:String = "";
		if (param1 == "") {
			return _loc2_;
		}
		if (this.m_configDataModel != null) {
			_loc3_ = this.m_configDataModel.getData("environment");
			if (_loc3_ != null && Reflect.hasField(_loc3_, param1)
				&& Reflect.hasField(Reflect.field(_loc3_, param1), "url")) {
				_loc2_ = Reflect.field(Reflect.field(_loc3_, param1), "url");
			}
		}
		return _loc2_;
	}

	// Settings.as:427-443
	public function getMonthEnds(param1:String, param2:String):String {
		if (this.m_configDataModel == null) {
			return "";
		}
		var _loc3_:Dynamic = this.m_configDataModel.getData("monthEnds");
		// AS3 的 `_loc3_.length == 0`：普通对象上是 undefined（不等于 0），数组上
		// 才可能命中——按字段读 length 复刻
		if (_loc3_ == null || Reflect.field(_loc3_, "length") == 0) {
			return "";
		}
		if (Reflect.field(_loc3_, param1) == null) {
			return "";
		}
		return Reflect.field(Reflect.field(_loc3_, param1), param2);
	}

	// Settings.as:445-448
	public var resolveUrl(get, never):String;

	private function get_resolveUrl():String {
		return this.m_resolveUrl;
	}

	// Settings.as:450-453
	public var wildCfgUrl(get, never):String;

	private function get_wildCfgUrl():String {
		return Utils.addPrefix(this.getStringAttribute("wildXML"));
	}

	// Settings.as:455-458
	public function openZhaoHui():Bool {
		return this.getStringAttribute("zhaohuiOpen") == "1" ? true : false;
	}

	// Settings.as:460-481。Main.startup 会 setConfigDataModel（Main.as 同款
	// 调用），monthEnds[0] 的 start/end 是美式 "M/D/YYYY H:MM:SS" 串
	public function isGiftTime():Bool {
		if (this.m_configDataModel == null) {
			return false;
		}
		var _loc1_:Dynamic = this.m_configDataModel.getData("monthEnds");
		if (_loc1_ == null || Reflect.field(_loc1_, "length") == 0 || !Reflect.hasField(_loc1_, "0")) {
			return false;
		}
		var _loc2_:String = Reflect.field(Reflect.field(_loc1_, "0"), "start");
		var _loc3_:String = Reflect.field(Reflect.field(_loc1_, "0"), "end");
		// PORT-NOTE: AS3 `new Date(美式串)` 解析不了得 .time=NaN（下述比较恒
		// false、不抛）；Haxe 无此构造，经 As3.dateOf（M/D/YYYY[ H:M:S]，失败
		// 回 null 按 NaN 语义代入）。Date.fromString 只认 ISO 且对美式串直接
		// 抛——#9 启动链 ShortcutBar 构造时踩到
		var _loc4_:Float = As3.dateOf(_loc2_) == null ? Math.NaN : As3.dateOf(_loc2_).getTime();
		var _loc5_:Float = As3.dateOf(_loc3_) == null ? Math.NaN : As3.dateOf(_loc3_).getTime();
		var _loc6_:Float = CommonData.serverTime * 1000;
		if (_loc4_ < _loc6_ && _loc6_ < _loc5_) {
			return true;
		}
		return false;
	}

	// Settings.as:483-488
	public function loadLocalSettings(param1:Dynamic):Void {
		this.m_params = param1;
		this.m_resolveUrl = "";
		this.m_appImgPrefix = "";
	}

	// Settings.as:490-527
	public function loadFromFlashVars(param1:LoaderInfo):Void {
		var _loc2_:Dynamic = param1.parameters;
		if (_loc2_ == null) {
			throw new ArgumentError("Null parameters");
		}
		this.m_params = _loc2_;
		this.m_resolveUrl = this.getStringAttribute("resolveUrl");
		if (this.m_resolveUrl == "") {
			this.m_resolveUrl = "";
		}
		var _loc3_:String = param1.url;
		// 原版 regex "//(.+).appimg"（. 未转义，逐字保留）
		var _loc4_:EReg = new EReg("//(.+).appimg", "");
		if (_loc3_ != null && _loc4_.match(_loc3_)) {
			this.m_appImgPrefix = As3.or(_loc4_.matched(1), "");
		}
		var _loc5_:String = "";
		if (this.mode == "qzone") {
			_loc5_ = "qzone.qq";
		} else if (this.mode == "") {
			_loc5_ = "";
		}
		this.m_mcCommUrl = "" + _loc5_ + "mod=";
		this.m_ncCommUrl = "" + _loc5_ + "mod=";
		QzoneJSAPI.QPLUS = Reflect.field(param1.parameters, "agent") == "qplus";
		QzoneJSAPI.WB = Reflect.field(param1.parameters, "agent") == "weibo";
		if (QzoneJSAPI.WB == true) {
			this.m_mcCommUrl = "";
			this.m_ncCommUrl = "";
		}
	}

	// Settings.as:529-532
	public var addonConfigUrl(get, never):String;

	private function get_addonConfigUrl():String {
		return this.replaceAppImg(this.getStringAttribute("config_addon"));
	}

	// Settings.as:534-586。Dictionary<Dynamic,Dynamic> 落 StringMap；数字键与
	// 字符串键同样按属性名存取
	public function collectCropBySerials():openfl.utils.Dictionary<Dynamic, Dynamic> {
		var _loc4_:Dynamic = null;
		if (this.m_configDataModel == null) {
			return null;
		}
		var _loc1_:Array<Dynamic> = this.m_configDataModel.getData("crops");
		if (_loc1_ == null) {
			return null;
		}
		var _loc2_ = new openfl.utils.Dictionary<Dynamic, Dynamic>();
		_loc2_.set("other", new Array());
		_loc2_.set("normal", new Array());
		var _loc3_:Int = 0;
		for (_loc4_ in _loc1_) {
			if (Reflect.field(_loc4_, "type") != 11) {
				if (!Reflect.hasField(_loc4_, "qd") || Reflect.field(_loc4_, "qd") == 0) {
					if (!Reflect.hasField(_loc4_, "sr") || Reflect.field(_loc4_, "sr") == 0) {
						_loc2_.get("normal").push(Reflect.field(_loc4_, "id"));
					} else {
						_loc3_ = Reflect.field(_loc4_, "sr");
						if (_loc2_.get(_loc3_) == null) {
							_loc2_.set(_loc3_, new Array());
						}
						_loc2_.get(_loc3_).push(Reflect.field(_loc4_, "id"));
					}
				} else if (!Reflect.hasField(_loc4_, "sr") || Reflect.field(_loc4_, "sr") == 0) {
					_loc2_.get("other").push(Reflect.field(_loc4_, "id"));
				} else {
					_loc3_ = Reflect.field(_loc4_, "sr");
					if (_loc2_.get(_loc3_) == null) {
						_loc2_.set(_loc3_, new Array());
					}
					_loc2_.get(_loc3_).push(Reflect.field(_loc4_, "id"));
				}
			}
		}
		return _loc2_;
	}

	// Settings.as:588-607。E4X `param1..vars`：取第一个名为 vars 的后代节点再遍历
	// 子节点（本 swf 内 addon 配置只有一个 vars 节点）
	public function loadFromAddon(param1:Xml):Void {
		var _loc3_:Xml = null;
		if (param1 == null) {
			return;
		}
		var varsNode:Xml = null;
		var findVars:Xml->Xml = null;
		findVars = function(node:Xml):Xml {
			var child:Xml = null;
			for (child in node.elements()) {
				if (child.nodeName == "vars") {
					return child;
				}
				var found:Xml = findVars(child);
				if (found != null) {
					return found;
				}
			}
			return null;
		};
		varsNode = findVars(param1);
		if (varsNode == null) {
			return;
		}
		if (this.m_params == null) {
			this.m_params = {};
		}
		for (_loc3_ in varsNode.elements()) {
			if (_loc3_.firstChild() != null) {
				Reflect.setField(this.m_params, _loc3_.nodeName, _loc3_.firstChild().nodeValue);
			}
		}
	}

	// Settings.as:609-612
	public var snsAdAllowLvl(get, never):Int;

	private function get_snsAdAllowLvl():Int {
		return Std.parseInt(this.getStringAttribute("snsAdAllowLvl"));
	}

	// Settings.as:614-617
	public function getFishName(param1:Int):String {
		return "Fish_" + param1;
	}
}
