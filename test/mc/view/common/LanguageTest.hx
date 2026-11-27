package mc.view.common;

import common.INI;
import mc.view.common.Language;
import utest.Assert;

/**
 * mc.view.common.Language 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 多语模板表的 lang 解析与 replaceText 的 {key}/#N# 替换语义。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/common/Language.as
 * —— 常量 :8-10（CN "cn"、EN "en"）；lang :54-69（_currentLang 非空直返
 * ——缓存；否则读 INI version.@language，空串或缺省落 "cn"，非空取
 * 配置值并缓存）；L :49-52（_l[lang]）；replaceText :34-47（模板 =
 * L[param1]；对 param2 每个键：先把 "{key}" 全局正则替换为值，随后在
 * 同一轮对整个串做 #1#→"1st"、#2#→"2nd"、#3#→"3rd"、#4#→"4th" 四处
 * 串替换——序号替换在键循环内，param2 无键时一次都不跑）；内置表
 * :12-25（buyNum "输入数量（{minNum}~{maxNum}）" :19）。
 *
 * INI 注入同 GetCropIDTest。fixture 的 <version> 抄录 mc_main.php:9——
 * 原文 **没有 language 属性**（`value="" loginurl="http://i.qzone.qq.com/"`
 * 仅此而已），language="" 是 round 1 的编造值，本轮已删。lang 的缺省
 * 解析因此走**属性缺失分支**（`== null`），这才是生产形态；空串分支
 * （`== ""`）另用 Xml.set 现场注入驱动。_currentLang 是静态缓存位——
 * setup 经 @:access 复位 "" 逼 lang 重解析，避免跨用例污染。
 *
 * stub 期 replaceText/L/lang 全 throw not implemented——本测试必然等
 * implement 充真身才绿（write-tests 的意图即如此）。
 */
@:access(mc.view.common.Language)
class LanguageTest {
	static var FIXTURE:String = sys.io.File.getContent("test/fixtures/mc-ini.xml");

	public function new() {}

	function setup() {
		INI.getInstance().data = Xml.parse(FIXTURE);
		Language._currentLang = "";
	}

	// 常量面值（Language.as:8-10）
	public function test_constants() {
		Assert.equals("cn", Language.CN);
		Assert.equals("en", Language.EN);
	}

	// lang（:54-69）：fixture 的 version **无 language 属性**（生产形态——
	// mc_main.php:9）→ 缺失分支（`== null`）落 "cn"
	public function test_lang_defaults_cn_when_attr_missing() {
		Assert.equals("cn", Language.lang);
	}

	// lang 空串分支（:64 `== "" || == null` 同落 cn——AS3 双条件并列）。
	// fixture 不含该属性，现场注入 "" 驱动空串半边：生产虽不走此支，源码
	// 显式写出这个守卫、implement 的等价物须保留同形
	public function test_lang_defaults_cn_when_attr_empty_string() {
		var xml = Xml.parse(FIXTURE);
		for (e in xml.firstElement().elementsNamed("version")) {
			e.set("language", "");
		}
		INI.getInstance().data = xml;
		Language._currentLang = "";
		Assert.equals("cn", Language.lang);
	}

	// lang 缓存（:56-58）：首次解析后 _currentLang 缓存 "cn"，后续不再读
	// INI——把 INI 清 null 后 lang 仍 "cn"
	public function test_lang_caches_after_first_resolve() {
		Assert.equals("cn", Language.lang);
		INI.getInstance().data = null;
		Assert.equals("cn", Language.lang); // 缓存命中——_currentLang != "" 直返
	}

	// lang 非空配置分支（:67-68）：version language="en" → "en"
	public function test_lang_reads_config_value() {
		var xml = Xml.parse(FIXTURE);
		// 改 fixture 的 version language 为 "en"——Xml 树就地改写
		var main = xml.firstElement();
		for (e in main.elementsNamed("version")) {
			e.set("language", "en");
		}
		INI.getInstance().data = xml;
		Language._currentLang = "";
		Assert.equals("en", Language.lang);
	}

	// replaceText 基本替换（:34-47 + :19）：buyNum 模板两键替换。
	// "输入数量（{minNum}~{maxNum}）" + {minNum:1, maxNum:5}
	// → "输入数量（1~5）"
	public function test_replaceText_buyNum() {
		var out = Language.replaceText("buyNum", {minNum: 1, maxNum: 5});
		Assert.equals("输入数量（1~5）", out);
	}

	// 全局替换（:42 "g" 标志）：同一键在模板中出现多次时全换。
	// cropSeedName "{cName}种子" 只一处——用 buyNum 钉双键各一处已足；
	// 全局性用同一键多现的自造路径无法钉（模板表内置不可注），改为钉
	// replace 语义的正则形态：模板键名含正则元字符 {} 字面——"{minNum}"
	// 的花括号在正则里是量词起始但后随字母非法，AS3 按字面容错解析
	// （原文如此依赖），implement 等价物保同形即可。此注备录不断言。

	// #N# 序号替换在键循环内（:43-44）：替换值里含 "#1#" 时，同一轮
	// 键迭代内先插值后序号替换——"buyNum" 模板 + minNum "#1#x"：
	// 第一轮（minNum）："{minNum}"→"#1#x" 得 "输入数量（#1#x~{maxNum}）"，
	// 随后 #1#→"1st" 得 "输入数量（1stx~{maxNum}）"；第二轮（maxNum）：
	// "{maxNum}"→"2" 得 "输入数量（1stx~2）"，序号替换无命中幂等。
	// 终态 "输入数量（1stx~2）"（注意 #1# 与 x 间无空格——replace 是
	// 直接子串替换）。
	public function test_replaceText_ordinal_inside_key_loop() {
		var out = Language.replaceText("buyNum", {minNum: "#1#x", maxNum: 2});
		Assert.equals("输入数量（1stx~2）", out);
	}

	// #N# 替换的循环内语义——param2 无键时序号替换一次都不跑（:40-45
	// for-in 零迭代）：模板串若含 "#1#" 原样保留。内置表无含 #N# 的模板，
	// 此钉用反向形态：单键 param2 时值里 #2# 也替换（四处替换全在一轮内）
	public function test_replaceText_all_ordinals_in_one_iteration() {
		var out = Language.replaceText("buyNum", {minNum: "#2##3##4#", maxNum: 1});
		Assert.equals("输入数量（2nd3rd4th~1）", out);
	}

	// replaceText 未命中键的替换值不进串（模板无该占位符时替换无效果）：
	// buyNum 模板无 {extra} 占位——多给的键不改变结果
	public function test_replaceText_extra_param_ignored() {
		var out = Language.replaceText("buyNum", {minNum: 1, maxNum: 5, extra: "zz"});
		Assert.equals("输入数量（1~5）", out);
	}

	// L（:49-52）：_l[lang]——cn 表的 buyNum 键可读（模板原文 :19）
	public function test_L_returns_cn_table() {
		Assert.equals("输入数量（{minNum}~{maxNum}）", Reflect.field(Language.L, "buyNum"));
	}
}
