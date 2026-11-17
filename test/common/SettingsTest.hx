package common;

import utest.Assert;

/**
 * 预加载器的 flashvar 解析与 config URL 纯逻辑。
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

	// nc.htm:18-91 的 FLASH_VARS，只摘测试用到的键；值逐字照抄。
	// config_url/config_data/config_addon 在 nc.htm 里是模板串，这里用 common.php:66
	// 的 gzipcompress 分支渲染后的形态（xml.php?mod=...，FARM_DAY=20120905）。
	static function ncFlashVars():Dynamic {
		return {
			"useflag": "11111111",
			"mode": "1",
			"uinMode": "1",
			"app_key": "happyfarm",
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
}
