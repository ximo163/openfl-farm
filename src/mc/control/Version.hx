package mc.control;

import common.INI;

/**
 * mc.control.Version —— Version.as（mcloader_v_53/scripts，预加载器与
 * Master2 同应用域共享，Master2 反编译里无此文件）逐句对应，issue #19
 * Master2 闭包顺手译。INI 为 mcloader 片 stub。
 */
@:keep
class Version {
	// Version.as:8-14（AS3 里还有一个无名 `public static const :String = ""`，
	// FFDec 丢了常量名，Haxe 无法声明无名常量，略——无引用点，不影响行为）
	public static var _sns:String;

	public static final QQ:String = "qq";
	public static final QZONE:String = "qzone";

	public function new() {}

	// Version.as:21-24
	public static var SNS(get, set):String;

	private static function set_SNS(param1:String):String {
		_sns = param1;
		return param1;
	}

	// Version.as:26-30
	public static var value(get, never):String;

	private static function get_value():String {
		// PORT-NOTE(E4X): 原版 `INI.getInstance().data.version.@value` 读 XML
		// 属性；INI 为 stub、data 为空，部署包配置里该属性本就是空串
		// （legacy/deploy/QFarmFlash/source/core/source/xml/mod/mc_main.php
		// `version value=""`），固定返回 ""，与生产环境行为一致。
		var _loc1_:Dynamic = INI.getInstance().data;
		if (_loc1_ != null) {
			var _loc2_:Dynamic = Reflect.field(_loc1_, "version");
			if (_loc2_ != null && Reflect.field(_loc2_, "value") != null) {
				return Std.string(Reflect.field(_loc2_, "value"));
			}
		}
		return "";
	}

	// Version.as:32-46
	private static function get_SNS():String {
		var _loc2_:String = Version.value;
		var _loc3_:String = "xiaonei";
		if (_loc2_ == "51" || _loc2_ == "xiaonei" || _loc2_ == "manyou" || _loc2_ == "facebook") {
			_loc3_ = "xiaonei";
		} else if (_loc2_ == "" || _loc2_ == "qzone") {
			_loc3_ = "qq";
		}
		return _loc3_;
	}
}
