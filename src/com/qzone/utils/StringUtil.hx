package com.qzone.utils;

// com.qzone.utils.StringUtil —— StringUtil.as 逐句对应（issue #9 按 main3
// 变体翻译；issue #86 并入 Master2 变体差异：tirmCallBack/
// getFixedLengthString 两个 main3 没有的方法、getFloatNumber 按参截位——
// #7/#8 惯例共有类不一致时以 Master2 变体为准）。AS3
// `final class`（Haxe 无 final 类，语义只差禁止继承，无运行时影响）。
// PORT-NOTE: 原版依赖 flash.xml 的 XMLDocument/XMLNode（E4X 文本节点序列
// 化做 HTML 转义）；openfl 本版本无 openfl.xml 包，htmlEscape/htmlUnescape
// 用 StringTools 的同五字符转义/反转义等价（& < > " '）。
class StringUtil {
	// StringUtil.as:8-11
	public function new() {}

	// StringUtil.as:15-25（模板 "{key}" 占位替换；AS3 for-in 遍历键 →
	// Reflect.fields，RegExp "g" 全局替换 → EReg "g"）
	public static function replaceText(param1:String, param2:Dynamic):String {
		var _loc3_:String = null;
		for (_loc3_ in Reflect.fields(param2)) {
			var _loc4_:EReg = new EReg("\\{" + _loc3_ + "\\}", "g");
			param1 = _loc4_.replace(param1, Std.string(Reflect.field(param2, _loc3_)));
		}
		return param1;
	}

	// StringUtil.as:27-31（秒值 → "YYYY-MM-DD HH:mm" 本地时区）
	public static function dateFormat(param1:Int):String {
		var _loc2_:Date = Date.fromTime(param1 * 1000);
		return doubleString(_loc2_.getFullYear()) + "-" + doubleString(_loc2_.getMonth() + 1) + "-" + doubleString(_loc2_.getDate()) + " "
			+ doubleString(_loc2_.getHours()) + ":" + doubleString(_loc2_.getMinutes());
	}

	// StringUtil.as:33-36
	public static function trim(param1:String):String {
		return ltrim(rtrim(param1));
	}

	// StringUtil.as:38-41
	public static function htmlEscape(param1:String):String {
		return StringTools.htmlEscape(param1, true);
	}

	// StringUtil.as:43-60（charCode > 32 为实字；整串无实字回 ""）
	public static function ltrim(param1:String):String {
		if (param1 == null) {
			return "";
		}
		var _loc2_:Int = param1.length;
		var _loc3_:Int = 0;
		while (_loc3_ < _loc2_) {
			if (param1.charCodeAt(_loc3_) > 32) {
				return param1.substring(_loc3_);
			}
			_loc3_++;
		}
		return "";
	}

	// StringUtil.as:62-70（左侧补零到 param2 位）
	public static function getZeroString(param1:Float, param2:UInt = 2):String {
		var _loc3_:String = Std.string(param1);
		while (param2 > _loc3_.length) {
			_loc3_ = "0" + _loc3_;
		}
		return _loc3_;
	}

	// StringUtil.as:72-79
	private static function doubleString(param1:Int):String {
		if (param1 < 10) {
			return "0" + param1;
		}
		return Std.string(param1);
	}

	// StringUtil.as:81-98
	public static function rtrim(param1:String):String {
		if (param1 == null) {
			return "";
		}
		var _loc2_:Int = param1.length;
		var _loc3_:Int = _loc2_;
		while (_loc3_ > 0) {
			if (param1.charCodeAt(_loc3_ - 1) > 32) {
				return param1.substring(0, _loc3_);
			}
			_loc3_--;
		}
		return "";
	}

	// StringUtil.as:100-111。PORT-NOTE: 原版 `_loc3_[_loc4_]` 以拆分数组
	// **整体**为键（Array→String "5" 或 "2,3"）：个位数数字串键命中数字表，
	// 多位数查不到键得 undefined，`+=` 拼成 "undefined"——原版如此（xfl 同），
	// 照抄怪癖而非改写成逐位映射
	public static function getChineseNum(param1:Float):String {
		var _loc2_:String = "";
		var _loc3_:Array<Dynamic> = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];
		var _loc4_:Array<Dynamic> = Std.string(param1).split("");
		for (_loc5_ in (_loc4_ : Array<Dynamic>)) {
			// AS3 下标键的数组强转走 toString()=join(",")（"5"/"2,3"）；Haxe
			// Std.string(Array) 出 "[5]"，永远查不中数字表
			var key:String = (_loc4_ : Array<Dynamic>).join(",");
			var v:Dynamic = null;
			// Null<Int>：Std.parseInt 无效输入回 null，CLAUDE.md 禁止在静态
			// 目标上对 Int 判 null（cpp typer 直接红）
			var idx:Null<Int> = Std.parseInt(key);
			if (idx != null && Std.string(idx) == key && idx >= 0 && idx < _loc3_.length) {
				v = _loc3_[idx];
			}
			_loc2_ += v == null ? "undefined" : Std.string(v);
		}
		return _loc2_;
	}

	// StringUtil.as:113-116。PORT-NOTE: 原版 XMLDocument(param1).firstChild
	// .nodeValue（lenient 解析取首子节点文本）；无 openfl.xml，用
	// StringTools 反转义等价（五实体）
	public static function htmlUnescape(param1:String):String {
		return StringTools.htmlUnescape(param1);
	}

	// Master2 变体并入（issue #86，Master2 StringUtil.as:86-98，main3 无）：
	// `_callback(...)` 包装剥离——前缀命中则剥前 10 字符，末位非 `}` 则截到
	// 最后一个 `}`（含）。PORT-NOTE: `substr(0,10).toLocaleLowerCase()` 与
	// `lastIndexOf`/`substr` 是 AS3 String 旧式索引语义；Haxe 的 substr 同
	// 语义直用
	public static function tirmCallBack(param1:String):String {
		if (param1.substr(0, 10).toLowerCase() == "_callback(") {
			param1 = param1.substr(10);
		}
		var _loc2_:Int = param1.lastIndexOf("}");
		if (_loc2_ != param1.length - 1) {
			param1 = param1.substr(0, _loc2_ + 1);
		}
		return param1;
	}

	// Master2 变体并入（issue #86，Master2 StringUtil.as:136-146，main3 无）：
	// 左侧补零到 param2 位（与 getZeroString 同效果不同实现路径，照抄）
	public static function getFixedLengthString(param1:Int, param2:Int):String {
		var _loc3_:String = Std.string(param1);
		var _loc4_:Int = param2 - _loc3_.length;
		var _loc5_:Int = 1;
		while (_loc5_ <= _loc4_) {
			_loc3_ = "0" + _loc3_;
			_loc5_++;
		}
		return _loc3_;
	}

	// StringUtil.as:118-121（Master2 变体 :151：Master2 是
	// `param1.toFixed(param2)` 按参截位，main3 是 `param1.toFixed(2)` 无视
	// param2——#7/#8 惯例以 Master2 变体为准；两变体在 param2=2 缺省调用时
	// 同值）。PORT-NOTE: Haxe 无 toFixed，手工定 param2 位小数四舍五入
	public static function getFloatNumber(param1:Float, param2:UInt = 2):String {
		var scale:Int = 1;
		var i:Int = 0;
		while (i < param2) {
			scale *= 10;
			i++;
		}
		var scaled:Int = Math.round(Math.abs(param1) * scale);
		var intPart:Int = Std.int(scaled / scale);
		var frac:Int = scaled % scale;
		var fracStr:String = Std.string(frac);
		while (fracStr.length < param2) {
			fracStr = "0" + fracStr;
		}
		return (param1 < 0 ? "-" : "") + intPart + "." + fracStr;
	}

	// StringUtil.as:123-138
	public static function getByteSize(param1:Int, param2:UInt = 2):String {
		if (param1 > 1024 * 1024 * 1024) {
			return getFloatNumber(param1 / 1024 / 1024 / 1024, param2) + " GB";
		}
		if (param1 > 1024 * 1024) {
			return getFloatNumber(param1 / 1024 / 1024, param2) + " MB";
		}
		if (param1 > 1024) {
			return getFloatNumber(param1 / 1024, param2) + " KB";
		}
		return Std.string(param1) + " B";
	}
}
