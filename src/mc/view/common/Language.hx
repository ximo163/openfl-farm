package mc.view.common;

import common.INI;

/**
 * mc.view.common.Language —— Language.as 逐句对应（issue #87「通用视图」片
 * 充真身）。多语文本：内置 _l 模板表，lang 取 INI version.@language
 * （空/缺省落 "cn"），replaceText 按 {key} 替换并在键循环内做 #1#→1st
 * 等序号替换。成员签名逐字取自反编译原文。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/Language.as。
 *
 * PORT-NOTE(E4X)：lang 的 `_loc1_.version.@language` 按等价遍历改写
 * （FarmLite.hx:149 先例）；INI.getInstance().data 在测试里注入的是
 * haxe Xml **Document** 节点（Xml.parse 产物），firstElement() 才是
 * <main> 根元素——读取时按 Document/Element 两态归一。
 * PORT-NOTE(main3 侧)：另有 common/Language.as（不同类、不同表），本类是
 * 牧场 mc.view.common.Language——import 时注意按包区分。
 */
@:keep
class Language {
	// Language.as:8-10
	public static final CN:String = "cn";
	public static final EN:String = "en";

	// Language.as:12-27（内置模板表逐字抄录；原文只建 "cn" 一档，"en" 无表
	// ——lang 解出 "en" 时 L 为 undefined→null，与原版一致）
	private static var _l:Dynamic = {"cn":{
			"buySeedFnText": "领养成功，共花费金币<font color=\"#FF6600\"> <b>{money}</b> </font>，领养<font color=\"#047D20\"> <b>{num}</b> </font>个<font color=\"#047D20\"> <b>{cName}</b> </font>幼仔。",
			"buySeedFnTextNew": "购买成功，共花费金币<font color=\"#FF6600\"> <b>{money}</b> </font>，<font color=\"#047D20\"> <b>{num}</b> </font>个<font color=\"#047D20\"> <b>{cName}</b> </font>幼仔已放入包裹。",
			"saleAllFnText": "成功卖出和捐赠仓库里的所有产品和动物，共获得收入和感谢金<font color=\"#FF6600\"> <b>{money}</b> </font>金币。",
			"reclaimPayText": "需要牧场等级<font color=\'#047D20\'> {level} </font>级和金币<font color=\'#FF6600\'> {money}</font>。",
			"reclaimPayText2": "扩建效果：可饲养住{house}动物+{num},{house}样式变更。",
			"cropSeedName": "{cName}种子",
			"buyNum": "输入数量（{minNum}~{maxNum}）",
			"sellNum": "输入数量（{minNum}~{maxNum}）",
			"allSellText": "当前动物产品的总价值（不包含锁定）：<font color=\'#FF6600\'>{goldValue}</font><br>是否全部卖出或捐赠？",
			"lovesallSellText": "<font color=\'#FF0000\'>注：情人节活动9倍收购产物“情果”默认不锁定</font><br>当前动物产品的总价值（不包含锁定）：<font color=\'#FF6600\'>{goldValue}</font><br>是否全部卖出或捐赠？",
			"allSellTextMaterial": "当前材料的总价值（不包含锁定）：<br><font color=\'#FF6600\'>{goldValue}</font><br>是否全部卖出？<br><font color=\'#FF6600\'size=\'12\'>提示：农场和牧场的材料都统一存放在材料专区里，若全部卖出，所有材料（不包含锁定）均将被卖出</font>",
			"saleAllMaterialFnText": "成功卖出仓库里所有未锁定材料，得到金币 <font color=\"#FF6600\"> <b>{money}</b> </font>。"
		}};

	// Language.as:28
	private static var _currentLang:String = "";

	// Language.as:30-32
	public function new() {}

	// Language.as:34-47（replaceText：模板 = L[param1]；对 param2 每个键先把
	// "{key}" 全局正则替换为值，随后在同一轮对整个串做 #1#→"1st" 等四处
	// 串替换——序号替换在键循环内，param2 无键时一次都不跑）
	public static function replaceText(param1:String, param2:Dynamic):String {
		var _loc4_:String = null;
		var _loc5_:EReg = null;
		var _loc3_:String = "";
		_loc3_ = Reflect.field(Language.L, param1);
		for (_loc4_ in Reflect.fields(param2)) {
			// AS3 "\{" 是「反斜杠+花括号」两字符（未知转义原样保留），Haxe 需
			// "\\{" 才得到同样两字符——正则里才是转义的花括号（common/Language.hx
			// 同款先例）
			_loc5_ = new EReg("\\{" + _loc4_ + "\\}", "g");
			_loc3_ = _loc5_.replace(_loc3_, Std.string(Reflect.field(param2, _loc4_)));
			// .replace("#N#",...) 是 AS3 字符串模式 replace——只换第一处，
			// Haxe StringTools.replace 是全局替换，不等价；走 As3.replaceFirst
			// （模板值里同序号多次出现时与原版的差别在此通道保真）
			_loc3_ = shim.As3.replaceFirst(shim.As3.replaceFirst(shim.As3.replaceFirst(shim.As3.replaceFirst(_loc3_, "#1#", "1st"), "#2#", "2nd"), "#3#", "3rd"), "#4#", "4th");
		}
		return _loc3_;
	}

	// Language.as:49-52（L：_l[lang]）
	public static var L(get, never):Dynamic;

	private static function get_L():Dynamic {
		return Reflect.field(_l, lang);
	}

	// Language.as:54-69（lang：_currentLang 非空直返——缓存；否则读 INI
	// version.@language，空串或缺省落 "cn"，非空取配置值并缓存）
	public static var lang(get, never):String;

	private static function get_lang():String {
		if (_currentLang != "") {
			return _currentLang;
		}
		var _loc1_:Dynamic = INI.getInstance().data;
		// E4X `_loc1_.version.@language`：version 子元素的 language 属性。
		// 属性缺失时 AS3 得空 XMLList→String 化 ""（`== "" || == null` 双条件
		// 并列里 `== null` 一支对 XMLList 恒假、空串一支兜底——两分支同落 cn，
		// 等价物合并为 null/"" 同判）
		var _loc2_:String = null;
		var root:Xml = xmlRoot(_loc1_);
		if (root != null) {
			for (e in root.elementsNamed("version")) {
				_loc2_ = e.get("language");
				break;
			}
		}
		if (_loc2_ == "" || _loc2_ == null) {
			_currentLang = "cn";
		} else {
			_currentLang = _loc2_;
		}
		return _currentLang;
	}

	// INI.data 的 Xml 归一：测试注入 Xml.parse 产物（Document 节点），
	// firstElement() 才是配置根 <main>；生产经 XML() 转换注入时本身即根
	// 元素。两态归一、不改写注入物。
	private static function xmlRoot(x:Dynamic):Xml {
		if (x == null) {
			return null;
		}
		var xml:Xml = cast x;
		if (xml.nodeType == Xml.Document) {
			return xml.firstElement();
		}
		return xml;
	}
}
