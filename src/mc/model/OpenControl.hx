package mc.model;

import common.CommonData;
import common.INI;
import shim.As3;

/**
 * mc.model.OpenControl —— OpenControl.as 逐句对应（issue #87「数据」片
 * 充真身）。功能开放控制：按 INI 配置的 openControl 项查 open/openlv/
 * openexp/time 四面，checkTime 按小时表、checkTime2 按日期窗比对
 * serverTime。
 * legacy/decompiled/Master2_v_142/scripts/mc/model/OpenControl.as。
 *
 * PORT-NOTE(E4X)：原版 `xmlData.openControl.item.(@name == val).@open`
 * 是 E4X 属性过滤——手译为沿 elements() 匹配 nodeName/@name 后取属性串
 * （FarmLite.hx:149 先例）；XML 属性缺位时 E4X 得空 XMLList、String() 化
 * 为 ""，Number("") 为 NaN——Haxe 侧 get() 缺位返 null 按 "" 归一后再
 * 数值化，NaN 形态保住。INI.data 测试注入的是 Xml.parse 的 Document，
 * openControl 在其根元素 <main> 之下——elements() 先剥 Document 一层。
 */
@:keep
class OpenControl {
	// OpenControl.as:8-11
	public function new() {}

	// openControl.item 里 @name==val 的首个 item 的 attrName 属性串
	// （E4X `xmlData.openControl.item.(@name==val).@attr` 的等价手译；
	// xmlData null 由调用方先判——本助手只在非 null 路径进）。属性缺位/
	// 无匹配项返 ""（E4X 空 XMLList 的 String 化）
	private static function itemAttr(xmlData:Xml, val:String, attrName:String):String {
		// Xml.parse 的注入是 Document——先剥到根元素 <main>；注入本身即
		// 根元素（Element）时直接用
		var root:Xml = xmlData.nodeType == Xml.Document ? xmlData.firstElement() : xmlData;
		if (root == null) {
			return "";
		}
		for (openControl in root.elements()) {
			if (openControl.nodeName != "openControl") {
				continue;
			}
			for (item in openControl.elements()) {
				if (item.nodeName == "item" && item.get("name") == val) {
					var attr:String = item.get(attrName);
					return attr == null ? "" : attr;
				}
			}
			return "";
		}
		return "";
	}

	// OpenControl.as:14-25（serverTime*1000 落 "start|end" 闭区间。
	// PORT-NOTE(Date)：AS3 `new Date(串)` 的美式 m/d/Y 解析走 As3.dateOf
	// ——解析失败回 null（原版 Invalid Date time=NaN），NaN 参与比较恒
	// false、闭区间必不成立，本函数照语义等价落到 false 返回）
	public static function checkTime2(param1:String):Bool {
		// `serverTime * 1000` 写 *1000.0 防 eval 的 Int32 回绕
		// （FarmApplication.hx:895/FarmLand._goldLand 同款先例——整数浮点
		// 乘整数字面量在 eval 落 TInt 按 32 位回绕）
		var _loc2_:Float = CommonData.serverTime * 1000.0;
		var _loc3_:Array<String> = OpenControl.getOpenTime(param1).split("|");
		if (_loc3_.length < 2) {
			// PORT-NOTE：原文 `_loc3_[1]` 越界读 undefined、`new Date(undefined)`
			// 得 Invalid Date（time NaN）——比较恒 false 落 return false，等价
			return false;
		}
		var _loc4d:Date = As3.dateOf(_loc3_[0]);
		var _loc5d:Date = As3.dateOf(_loc3_[1]);
		var _loc4_:Float = _loc4d == null ? Math.NaN : _loc4d.getTime();
		var _loc5_:Float = _loc5d == null ? Math.NaN : _loc5d.getTime();
		if (_loc2_ >= _loc4_ && _loc2_ <= _loc5_) {
			return true;
		}
		return false;
	}

	// OpenControl.as:27-42（当前小时数与 "|" 分隔小时表逐段比较。
	// PORT-NOTE(松等)：`_loc3_[_loc5_] == _loc4_` 是 AS3 字符串==数的宽松
	// 相等——数先数值化再比（"7"==7 为真、"07" 按 Number("07")==7 亦真）；
	// 等价形态走 As3.floatOf 双数值化比较）
	public static function checkTime(param1:String):Bool {
		// PORT-NOTE(eval-ms-channel)：`serverTime * 1000` 逐字照抄——eval 上
		// 整数值 Float 乘整数字面量落 TInt 算术按 2^32 回绕（Probe 实证），
		// 测试扫描同通道（test OpenControlTest.test_checkTime_hour_table
		// 的 `t * 1000` 同型回绕），两侧回绕一致、小时差仍然正确（+3600s
		// 在模环上恰推进一小时）；html5/cpp 无回绕、生产语义正确。本函数
		// 只做小时表内比较，绝对纪元无消费——与 checkTime2 的 1000.0
		// （绝对毫秒窗比对必须真纪元）分工不同，勿拉齐。
		var _loc2_:Date = Date.fromTime(CommonData.serverTime * 1000);
		var _loc3_:Array<String> = OpenControl.getOpenTime(param1).split("|");
		var _loc4_:Float = _loc2_.getHours();
		var _loc5_:Int = 0;
		while (_loc5_ < _loc3_.length) {
			// ToNumber（ECMA 松等字符串侧）：空串/纯空白 → 0（""==0 为真——
			// 空 time 属性在午夜 0 点原版误判 true 的怪癖照留），否则数值化
			var seg:String = _loc3_[_loc5_];
			var segNum:Float = StringTools.trim(seg) == "" ? 0 : As3.floatOf(seg);
			if (segNum == _loc4_) {
				return true;
			}
			_loc5_++;
		}
		return false;
	}

	// OpenControl.as:44-55（xmlData null 才 9999；否则 Number(@openexp)
	// ——属性缺位 Number("") AS3 得 NaN 照返，floatOf("") 同 NaN）
	public static function getOpenExpLv(param1:String):Float {
		var explv:Float = Math.NaN;
		var val:String = param1;
		var xmlData:Xml = cast(INI.getInstance().data, Xml);
		if (xmlData != null) {
			explv = As3.floatOf(itemAttr(xmlData, val, "openexp"));
			return explv;
		}
		return 9999;
	}

	// OpenControl.as:57-74（@open=="true" 才 true；xmlData null/无匹配/
	// 属性缺位全落 false）
	public static function open(param1:String):Bool {
		var val:String = param1;
		var openBoolean:Bool = false;
		var xmlData:Xml = cast(INI.getInstance().data, Xml);
		if (xmlData != null) {
			if (itemAttr(xmlData, val, "open") == "true") {
				openBoolean = true;
			} else {
				openBoolean = false;
			}
		}
		return openBoolean;
	}

	// OpenControl.as:76-87（@time 原样返；xmlData null → ""）
	public static function getOpenTime(param1:String):String {
		var timeArray:String = null;
		var val:String = param1;
		var xmlData:Xml = cast(INI.getInstance().data, Xml);
		if (xmlData != null) {
			timeArray = itemAttr(xmlData, val, "time");
			return timeArray;
		}
		return "";
	}

	// OpenControl.as:89-100（同 getOpenExpLv 形，读 @openlv）
	public static function getOpenYellowLv(param1:String):Float {
		var lv:Float = Math.NaN;
		var val:String = param1;
		var xmlData:Xml = cast(INI.getInstance().data, Xml);
		if (xmlData != null) {
			lv = As3.floatOf(itemAttr(xmlData, val, "openlv"));
			return lv;
		}
		return 9999;
	}
}
