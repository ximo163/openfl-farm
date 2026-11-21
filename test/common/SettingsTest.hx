package common;

import com.qzone.qfa.interfaces.IModel;
import utest.Assert;

/**
 * 预加载器的 flashvar 解析与 config URL 纯逻辑；#18 驳回返工追加
 * getCropByID 配置表查找（数字 id 的 AS3 松等钉子，出处见该用例注释）。
 *
 * 出处：
 * - legacy/deploy/QFarmFlash/source/core/view/qf_default/nc.htm:18-91 —— FLASH_VARS 的键与值
 * - legacy/decompiled/happyfarm3_v_149/scripts/common/Settings.as —— 解析与派生 getter
 *
 * 说明：AS3 的 loadFromFlashVars(loaderInfo) 把 loaderInfo.parameters 原样存进 m_params
 * （Settings.as:490-497）；loadLocalSettings 是同一个赋值（Settings.as:483-488）。
 * 所以这里用 loadLocalSettings 喂参数对象即可覆盖 flashvar 的解析语义，
 * 不需要构造 LoaderInfo（加载器/显示对象不进单测）。
 */
@:access(common.Settings)
class SettingsTest {
	public function new() {}

	// nc.htm:18-91 的 FLASH_VARS 字面量，只摘测试用到的键；值逐字照抄。
	// mode 不在字面量里：nc.htm:92 动态注入（isQzone ? 1 : 2，qzone 站点下为 "1"）。
	// config_url/config_data/config_addon 在 nc.htm:84-86 是 {:$xml} 模板串，这里用
	// common.php:68-69 的 gzipcompress 分支（$xml='xml.php?mod='）渲染后的形态；
	// FARM_DAY=20120905 出自 common.php:8-9（'7.0 Final Build 20120905.1700' 的
	// substr(16,8)）。
	static function ncFlashVars():Dynamic {
		return {
			"useflag": "11111111",
			"mode": "1",
			"uinMode": "1",
			"domian_qz": "farm.qzone",
			"domian_xy": "farm.xiaoyou",
			"config_url": "xml.php?mod=load_main_v_20120905.xml",
			"config_data": "xml.php?mod=data_zh_CN_v_20120905.xml",
			"config_addon": "xml.php?mod=addon_v_20120905.xml"
		};
	}

	static function withParams(params:Dynamic):Settings {
		var settings = Settings.getInstance();
		settings.loadLocalSettings(params);
		return settings;
	}

	// Settings.as:360-374 getStringAttribute：
	//   参数表为 null / 键为 null 或空 / 键不存在 / 值不是 String（Settings.as:368），
	//   一律返回 ""。
	public function test_missing_and_invalid_lookups_return_empty_string() {
		var cases:Array<{params:Dynamic, key:String}> = [
			{params: null, key: "config_url"},
			{params: {}, key: "config_url"},
			{params: {"config_url": null}, key: "config_url"},
			{params: {"config_url": 7}, key: "config_url"}
		];
		for (c in cases) {
			Assert.equals("", withParams(c.params).getStringAttribute(c.key),
				'params=${c.params} key=${c.key}');
		}
		var settings = withParams(ncFlashVars());
		Assert.equals("", settings.getStringAttribute(null)); // Settings.as:362
		Assert.equals("", settings.getStringAttribute("")); // Settings.as:362
		Assert.equals("", settings.getStringAttribute("noSuchKey")); // Settings.as:366
	}

	// Settings.as:366-371：参数表里的 String 值原样返回（nc.htm:87、nc.htm:65）
	public function test_nc_htm_flashvars_pass_through() {
		var settings = withParams(ncFlashVars());
		Assert.equals("11111111", settings.getStringAttribute("useflag"));
		Assert.equals("farm.qzone", settings.getStringAttribute("domian_qz"));
		Assert.equals("farm.xiaoyou", settings.getStringAttribute("domian_xy"));
	}

	// 覆盖：同名键以传入值为准（nc.htm:84 的 config_url 换成调用方给的值）
	public function test_provided_value_overrides_nc_value() {
		var vars = ncFlashVars();
		Reflect.setField(vars, "config_url", "custom/load_main_v_1.xml");
		Assert.equals("custom/load_main_v_1.xml",
			withParams(vars).getStringAttribute("config_url"));
	}

	// Settings.as:266-274 app_key：缺项/空串回落到 "happyfarm"
	public function test_app_key_falls_back_to_happyfarm() {
		var cases:Array<{params:Dynamic, expected:String}> = [
			{params: {}, expected: "happyfarm"},
			{params: {"app_key": ""}, expected: "happyfarm"},
			{params: {"app_key": "otherapp"}, expected: "otherapp"}
		];
		for (c in cases) {
			Assert.equals(c.expected, withParams(c.params).app_key, 'params=${c.params}');
		}
	}

	// Settings.as:112-132 mode：agent=qplus/weibo 或 mode=="1" 都是 qzone，其余 ""
	public function test_mode_maps_to_qzone_or_empty() {
		var cases:Array<{params:Dynamic, expected:String}> = [
			{params: {"mode": "1"}, expected: "qzone"},
			{params: {"mode": "2"}, expected: ""},
			{params: {}, expected: ""},
			{params: {"agent": "qplus"}, expected: "qzone"},
			{params: {"agent": "weibo"}, expected: "qzone"}
		];
		for (c in cases) {
			Assert.equals(c.expected, withParams(c.params).mode, 'params=${c.params}');
		}
	}

	// Settings.as:134-146 xymode：原版两个分支都返回 ""（保留逐字行为）
	public function test_xymode_is_always_empty() {
		Assert.equals("", withParams({"pageDomain": "qzone.qq.com"}).xymode);
		Assert.equals("", withParams({}).xymode);
	}

	// Settings.as:290-301 domain：qzone（agent=qplus 也算）取 domian_qz，否则 domian_xy
	public function test_domain_follows_mode() {
		Assert.equals("farm.qzone", withParams(ncFlashVars()).domain); // nc.htm:92 mode=1
		Assert.equals("farm.xiaoyou",
			withParams({"mode": "2", "domian_qz": "farm.qzone", "domian_xy": "farm.xiaoyou"}).domain);
		Assert.equals("farm.qzone",
			withParams({"agent": "qplus", "domian_qz": "farm.qzone", "domian_xy": "farm.xiaoyou"}).domain);
	}

	// Settings.as:285-288 dataConfigUrl、Settings.as:529-532 addonConfigUrl；
	// FarmLite.as:365 用 replaceAppImg(getStringAttribute("config_url")) 拼主配置地址。
	// appImgPrefix 为空时 replaceAppImg 原样返回（Settings.as:211）。
	public function test_config_urls_are_used_verbatim_without_appimg_prefix() {
		var settings = withParams(ncFlashVars());
		Assert.equals("xml.php?mod=data_zh_CN_v_20120905.xml", settings.dataConfigUrl);
		Assert.equals("xml.php?mod=addon_v_20120905.xml", settings.addonConfigUrl);
		Assert.equals("xml.php?mod=load_main_v_20120905.xml",
			settings.replaceAppImg(settings.getStringAttribute("config_url")));
	}

	// Settings.as:211 replaceAppImg：前缀为空、参数为空时都不改写
	public function test_replace_app_img_is_noop_without_prefix() {
		var settings = withParams(ncFlashVars());
		Assert.equals("http://appimg.qq.com/a.swf",
			settings.replaceAppImg("http://appimg.qq.com/a.swf"));
		settings.m_appImgPrefix = "x";
		Assert.equals("", settings.replaceAppImg(""));
	}

	// Settings.as:213 已以 "<prefix>." 开头时原样返回
	public function test_replace_app_img_keeps_urls_already_prefixed() {
		var settings = withParams({});
		settings.m_appImgPrefix = "x";
		Assert.equals("x.appimg.qq.com/a.swf",
			settings.replaceAppImg("x.appimg.qq.com/a.swf"));
	}

	// Settings.as:217-219 依次给 appimg./appimg1./appimg3. 主机名加前缀
	public function test_replace_app_img_prepends_prefix_to_cdn_hosts() {
		var settings = withParams({});
		settings.m_appImgPrefix = "x";
		Assert.equals("http://x.appimg.qq.com/a.swf",
			settings.replaceAppImg("http://appimg.qq.com/a.swf"));
		Assert.equals("http://x.appimg1.qq.com/a.swf",
			settings.replaceAppImg("http://appimg1.qq.com/a.swf"));
		Assert.equals("http://x.appimg3.qq.com/a.swf",
			settings.replaceAppImg("http://appimg3.qq.com/a.swf"));
	}

	// Settings.as:217 AS3 String.replace(String,String) 只替换第一个匹配：
	// 同一 URL 里出现两次 appimg. 时只改第一处。
	public function test_replace_app_img_only_replaces_first_occurrence() {
		var settings = withParams({});
		settings.m_appImgPrefix = "x";
		Assert.equals("http://x.appimg.qq.com/a?u=http://appimg.qq.com/b",
			settings.replaceAppImg("http://appimg.qq.com/a?u=http://appimg.qq.com/b"));
	}

	// Settings.as:217-219 三步替换串行作用在同一个参数串上：前缀本身含 "appimg3" 时，
	// 第 1 步插入的 "<prefix>.appimg." 会在第 3 步被再次改写（原版逐字行为）。
	public function test_replace_app_img_prefix_containing_appimg3_is_rewritten_again() {
		var settings = withParams({});
		settings.m_appImgPrefix = "appimg3";
		Assert.equals("http://appimg3.appimg3.appimg.qq.com/a.swf",
			settings.replaceAppImg("http://appimg.qq.com/a.swf"));
	}

	// Settings.as:486-487 loadLocalSettings 重置前缀与 resolveUrl
	public function test_load_local_settings_resets_derived_urls() {
		var settings = withParams({});
		settings.m_appImgPrefix = "x";
		settings.loadLocalSettings({});
		Assert.equals("", settings.appImgPrefix);
		Assert.equals("", settings.resolveUrl);
	}

	// Settings.as:376-396 getCropByID：真实配置 crops 的 id 是 JSON 数字
	// （nc_data.php:6020 `"id": 1` 草莓、:6257 `"id": 256` 石竹花），原版
	// `_loc3_["id"] == param1`（:390）是 AS3 松等——数字 256 == "256" 命中。
	// Haxe 对 Dynamic == String 走严格比较（eval/cpp 失配，js 偶然松等同，
	// lessons #8），译文需同款 As3.eqString（GetCropID.hx:212 先例）。
	// #18 review-tests 驳回返工的测试侧钉子：数字形状下 eqString 落地前
	// getCropByID 恒返回 null（LevelUpModel 过滤链 :102 第一步就全灭）；
	// 字符串 id 的直比分支等值不变（回归钉）。
	public function test_getCropByID_matches_numeric_config_id() {
		var settings = Settings.getInstance();
		var savedModel = settings.m_configDataModel;
		var crop1 = {"id": 1, "name": "草莓"}; // nc_data.php:6020 形状（裁剪）
		var crop256 = {"id": 256, "name": "石竹花"}; // nc_data.php:6257 形状（裁剪）
		var cropStr = {"id": "7"}; // 字符串 id：钉 eqString 的 String 直比分支
		var crops:Array<Dynamic> = [crop1, crop256, cropStr]; // id 键种混装，显式 Dynamic
		settings.m_configDataModel = new FakeConfigModel({"crops": crops});
		Assert.equals(crop1, settings.getCropByID("1"), "数字 id 1 松等命中（Settings.as:390）");
		Assert.equals(crop256, settings.getCropByID("256"), "数字 id 256 松等命中（exclude_seeds 同源 id）");
		Assert.equals(cropStr, settings.getCropByID("7"), "字符串 id 直比命中（等值不变）");
		Assert.isNull(settings.getCropByID("999"), "无匹配走空循环返回 null（Settings.as:395）");
		settings.m_configDataModel = savedModel; // Settings 全局单例，复位
	}
}

/**
 * 测试用 IModel：getData 按表名取 Reflect 字段，其余 no-op（同
 * LevelUpModelTest 的口径；Settings 只经 getData 读配置表）。
 */
private class FakeConfigModel implements IModel {
	var tables:Dynamic;

	public function new(tables:Dynamic) {
		this.tables = tables;
	}

	public function getData(param1:String):Dynamic {
		return Reflect.field(this.tables, param1);
	}

	public function flush():Void {}

	public function setData(param1:String, param2:Dynamic):Bool {
		return true;
	}

	public function notify(param1:String):Void {}

	public function removeNotifier(param1:String, param2:Dynamic):Void {}

	public function addNotifier(param1:String, param2:Dynamic):Void {}
}
