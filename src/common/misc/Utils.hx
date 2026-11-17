package common.misc;

import com.qzone.qfa.data.Resource;
import com.qzone.qfa.data.ResourceType;
import com.qzone.qfa.managers.ResourceManager;
import common.CommonData;
import common.Settings;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.filters.GlowFilter;
import shim.QQOutlets;

// Utils.as 逐句对应。
// PORT-NOTE: ExternalInterface → shim.QQOutlets（spec/deviations.json：
// no-qzone-jsapi）。
class Utils {
	// Utils.as:16
	private static var _textGlowFilter:Array<Dynamic>;

	// Utils.as:18
	private static var default_glow_filter:GlowFilter = new GlowFilter(16776960, 1, 6, 6, 4, 1, false, false);

	// Utils.as:20
	private static var _cachedBitmapData:Dynamic = {};

	// Utils.as:22
	private static var _nameMap:Dynamic = null;

	public function new() {
	}

	// Utils.as:29-41
	public static function buildRequest(param1:UInt, param2:Dynamic, param3:String = "POST",
			param4:String = "text"):Dynamic {
		if (param1 == 0) {
			throw new openfl.errors.ArgumentError("Invalid parameter");
		}
		return {
			"cmdID": param1,
			"__body": param2,
			"__method": param3,
			"__format": param4
		};
	}

	// Utils.as:43-50
	public static function getClass(param1:String):Class<Dynamic> {
		if (param1 == null || param1.length == 0) {
			return null;
		}
		return ResourceManager.gi().getClass(param1);
	}

	// Utils.as:52-60。原版把 <![CDATA[...]]> XML 字面量传给 ExternalInterface.call
	//（AS3 会转成字符串）；宿主端 JS 的 getPvid。CDATA → 等价字符串
	public static function getBrowserVersion():Dynamic {
		var _loc1_:String = "function() { return { \"appName\" : navigator.appName, \"version\" : navigator.appVersion }; }";
		return QQOutlets.call(_loc1_);
	}

	// Utils.as:62-82
	public static function shareWithCallBack(param1:String, param2:String, param3:String, param4:String,
			param5:Dynamic = null, param6:Dynamic = null, param7:Dynamic = null):Void {
		var _loc8_:String = null;
		if (param5 != null) {
			CommonData.addCallBackProxy("onSuccess", param5);
		}
		if (param6 != null) {
			CommonData.addCallBackProxy("onCancel", param6);
		}
		if (param7 != null) {
			CommonData.addCallBackProxy("onClose", param7);
		}
		if (QQOutlets.available) {
			_loc8_ = "fusion2.dialog.share(" + "{title:\'" + param1 + "\',summary:\'" + param2 + "\',pics:\'" + param3
				+ "\',desc:\'" + param4 + "\',onSuccess:function (opt){swfAppObject.onSuccess(opt);}"
				+ ",onCancel:function (opt){swfAppObject.onCancel(opt);}"
				+ ",onClose:function (opt){swfAppObject.onClose(opt);}})";
			QQOutlets.call(_loc8_);
		}
	}

	// Utils.as:84-105
	public static function isSafariOnMac():Bool {
		var _loc1_:Dynamic = getBrowserVersion();
		if (_loc1_ == null) {
			return false;
		}
		var _loc2_:String = Reflect.field(_loc1_, "version");
		if (_loc2_ == null || _loc2_ == "") {
			return false;
		}
		if (_loc2_.indexOf("Macintosh") == -1) {
			return false;
		}
		if (_loc2_.indexOf("Safari/") == -1) {
			return false;
		}
		return true;
	}

	// Utils.as:107-129
	public static function formatPhotoUrl50(param1:UInt, param2:String):String {
		var _loc5_:Int = 0;
		var _loc3_:String = param2;
		var _loc4_:Int = _loc3_.lastIndexOf("/30/30");
		if (_loc3_ == "") {
			_loc3_ = QzoneJSAPI.getHead(Std.string(param1), 50);
		} else if (_loc4_ == -1) {
			_loc5_ = _loc3_.lastIndexOf("/30");
			if (_loc5_ != -1) {
				_loc3_ = _loc3_.substring(0, _loc5_) + "ht" + _loc3_.substring(_loc5_ + 3, _loc3_.length);
			}
		} else {
			_loc3_ = _loc3_.substring(0, _loc4_) + "/50/30" + _loc3_.substring(_loc4_ + 6, _loc3_.length);
		}
		return _loc3_;
	}

	// Utils.as:131-145。String.replace(String,String) 只换第一处 → As3.replaceFirst
	public static function addPrefix(param1:String):String {
		if (param1 == null || param1 == "") {
			return param1;
		}
		var _loc2_:String = Settings.getInstance().appImgPrefix;
		if (_loc2_ != "" && param1.indexOf(".appimg") == -1) {
			param1 = shim.As3.replaceFirst(param1, "appimg.", _loc2_ + ".appimg.");
			param1 = shim.As3.replaceFirst(param1, "appimg1.", _loc2_ + ".appimg1.");
			param1 = shim.As3.replaceFirst(param1, "appimg3.", _loc2_ + ".appimg3.");
		}
		return param1;
	}

	// Utils.as:147-171。try/catch/finally 的 finally 里两个 return 等价于直接
	// return xml（Haxe 无 finally）
	public static function loadXMLData(param1:Dynamic):Xml {
		var xml:Xml = null;
		var e_target_data:Dynamic = param1;
		if (e_target_data == null) {
			return null;
		}
		try {
			xml = Xml.parse(e_target_data);
		} catch (e:Dynamic) {
			trace("ERROR: invalid XML file:" + e.message);
		}
		return xml;
	}

	// Utils.as:173-180
	public static function getMaterial(param1:String):Dynamic {
		if (param1 == null || param1.length == 0) {
			return null;
		}
		return ResourceManager.gi().getClassInstance(param1);
	}

	// Utils.as:182-190。int += Math.pow(...) 先按 Number 求和再截断回 int
	public static function formatNumber(param1:Int, param2:UInt):String {
		if (param2 == 0) {
			return "";
		}
		param1 = Std.int(param1 + Math.pow(10, param2));
		return Std.string(param1).substr(1, param2);
	}

	// Utils.as:192-207
	public static function getStrAttribute(param1:Dynamic, param2:String):String {
		if (param1 == null) {
			return "";
		}
		if (param2 == null || param2.length == 0) {
			return "";
		}
		if (!Reflect.hasField(param1, param2)) {
			return "";
		}
		return Reflect.field(param1, param2);
	}

	// Utils.as:209-224
	public static function getIntAttribute(param1:Dynamic, param2:String):Float {
		if (param1 == null) {
			return 0;
		}
		if (param2 == null || param2.length == 0) {
			return 0;
		}
		if (!Reflect.hasField(param1, param2)) {
			return 0;
		}
		return Std.parseInt(Reflect.field(param1, param2));
	}

	// Utils.as:226-244
	public static function getCachedBitmapData(param1:String, param2:Int, param3:Int):BitmapData {
		var _loc5_:BitmapData = null;
		if (Reflect.hasField(_cachedBitmapData, param1)) {
			return Reflect.field(_cachedBitmapData, param1);
		}
		var _loc4_:Class<Dynamic> = getClass(param1);
		if (_loc4_ != null) {
			_loc5_ = Type.createInstance(_loc4_, [param2, param3]);
			if (Std.isOfType(_loc5_, BitmapData)) {
				Reflect.setField(_cachedBitmapData, param1, _loc5_);
			}
			return _loc5_;
		}
		return null;
	}

	// Utils.as:246-253
	public static var textGlowFilter(get, never):Array<Dynamic>;

	private static function get_textGlowFilter():Array<Dynamic> {
		if (_textGlowFilter == null) {
			_textGlowFilter = [new GlowFilter(16777215, 1, 3, 3, 7)];
		}
		return _textGlowFilter;
	}

	// Utils.as:255-282。对象数字键在 AS3 里也被当成字符串属性访问
	public static function getNameById(param1:Int):String {
		var _loc2_:String = null;
		var _loc3_:String = null;
		if (_nameMap == null) {
			_nameMap = Cookies.getObject("nameMap", 1);
		}
		if (_nameMap != null && Reflect.hasField(_nameMap, Std.string(param1))) {
			_loc2_ = Reflect.field(Reflect.field(_nameMap, Std.string(param1)), "qz");
			_loc3_ = Reflect.field(Reflect.field(_nameMap, Std.string(param1)), "xy");
			if (Settings.getInstance().mode == "qzone" || Settings.getInstance().mode == "qplus") {
				if (_loc2_ != "") {
					return _loc2_;
				}
				return _loc3_;
			}
			if (_loc3_ != "") {
				return _loc3_;
			}
			return _loc2_;
		}
		return "";
	}

	// Utils.as:284-295
	public static function unStroke(param1:DisplayObject):Void {
		if (param1 == null) {
			return;
		}
		if (param1.filters == null) {
			return;
		}
		param1.filters = [];
	}

	// Utils.as:297-318
	public static function addResToManager(param1:String, param2:Dynamic):Bool {
		if (param2 == null) {
			return false;
		}
		if (param1 == null || param1.length == 0) {
			return false;
		}
		var _loc3_:String = ResourceType.getType(param1);
		if (_loc3_ == "") {
			return false;
		}
		var _loc4_:Resource = new Resource();
		_loc4_.type = _loc3_;
		_loc4_.url = param1;
		_loc4_.data = param2;
		ResourceManager.gi().addResource(_loc4_);
		return true;
	}

	// Utils.as:320-327
	public static function stroke(param1:DisplayObject):Void {
		if (param1 == null) {
			return;
		}
		param1.filters = [default_glow_filter];
	}
}
