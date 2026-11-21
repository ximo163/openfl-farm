package shim;

import common.Settings;
import utest.Assert;

/**
 * android 真机侧接线的纯逻辑（issue #10，config 路线：局域网后端）——
 * 后端基址的 flashvar 默认/覆盖解析、相对 *.php 的改写契约。
 *
 * 出处：
 * - 相对 URL 的形态：legacy/decompiled/happyfarm3_v_149/scripts/FarmLite.as
 *   get_startCGIUrl（"mync.php?mod=user&act=run"）与宿主页
 *   legacy/deploy/QFarmFlash/source/core/view/qf_default/nc.htm:84-86 的
 *   config_url/config_data/config_addon（"xml.php?mod=..."，FlashVars.hx 头注释
 *   记了渲染规则）
 * - 固定 core 拼接路径：legacy/deploy/QFarmFlash/build.sh:40（source/core →
 *   www/home/qqfarm/core/）；与 shim/SwfUrlBase.hx 的 CORE_BASE 是同一部署事实
 * - 只改写「相对的 *.php」的契约：shim/SwfUrlBase.hx resolve 的同款规则
 *   （module swf 已本地化走 Assets；绝对 URL 不碰）
 * - 非 php 的相对 config 形态：common.php:59-69 的 gzipcompress=0 分支
 *   （$xml='data/xml/'，请求 data/xml/load_main_*.xml）——不属于 *.php，
 *   本改写不认领
 * - 默认值回落语义：与 Settings.getStringAttribute 的缺项处理对齐
 *   （Settings.as:376-396：缺键/非 String 一律当未设置）
 */
class AndroidBackendTest {
	public function new() {}

	// resolveBase：parameters 已带非空 farm_backend → 覆盖默认（flashvar
	// 覆盖优先）；缺键/空串/非 String/null 表 → DEFAULT_BASE
	public function testResolveBaseFlashVarOverridesDefault() {
		var cases:Array<{params:Dynamic, expected:String}> = [
			{params: {"farm_backend": "http://10.0.0.2:9000"}, expected: "http://10.0.0.2:9000"},
			{params: {"farm_backend": "http://10.0.0.2:9000/"}, expected: "http://10.0.0.2:9000/"},
			{params: {}, expected: AndroidBackend.DEFAULT_BASE},
			{params: {"farm_backend": ""}, expected: AndroidBackend.DEFAULT_BASE},
			{params: {"farm_backend": 7}, expected: AndroidBackend.DEFAULT_BASE},
			{params: null, expected: AndroidBackend.DEFAULT_BASE}
		];
		for (c in cases) {
			Assert.equals(c.expected, AndroidBackend.resolveBase(c.params), 'params=${c.params}');
		}
	}

	// rebase：相对 *.php（含查询串）拼到 <base>/home/qqfarm/core/ 下；
	// base 尾部的 / 容忍（不产生双斜杠）
	public function testRebaseRelativePhpGetsBackendCorePath() {
		var cases:Array<{base:String, url:String, expected:String}> = [
			{
				base: "http://192.168.1.100:8089",
				url: "mync.php?mod=user&act=run",
				expected: "http://192.168.1.100:8089/home/qqfarm/core/mync.php?mod=user&act=run"
			},
			{
				base: "http://192.168.1.100:8089/",
				url: "xml.php?mod=load_main_v_20120905.xml",
				expected: "http://192.168.1.100:8089/home/qqfarm/core/xml.php?mod=load_main_v_20120905.xml"
			},
			{
				base: "http://10.0.0.2:9000",
				url: "mync.php",
				expected: "http://10.0.0.2:9000/home/qqfarm/core/mync.php"
			}
		];
		for (c in cases) {
			Assert.equals(c.expected, AndroidBackend.rebase(c.base, c.url), 'base=${c.base} url=${c.url}');
		}
	}

	// rebase：绝对 URL / 根相对路径原样返回——后端 nc_data 按 HTTP_HOST 下发的
	// postUrl（common.php:15-17）已是绝对地址，改写不得碰
	public function testRebaseLeavesAbsoluteAndRootedUrlsAlone() {
		var base:String = "http://192.168.1.100:8089";
		var urls:Array<String> = [
			"http://192.168.1.100:8089/home/qqfarm/core/mync.php?mod=farmlandstatus&act=harvest",
			"https://example.com/other.php",
			"/home/qqfarm/core/xml.php?mod=nc_main"
		];
		for (url in urls) {
			Assert.equals(url, AndroidBackend.rebase(base, url), 'url=${url}');
		}
	}

	// rebase：非 *.php 的相对 URL 原样返回——module swf 已本地化
	// （LocalSwfLoader→Assets），gzip 静态分支的 data/xml/*.xml 也不认领；
	// null URL / 空 base 不改写（空 base = 没配后端，不发明地址）
	public function testRebaseLeavesNonPhpAndMissingInputsAlone() {
		var base:String = "http://192.168.1.100:8089";
		Assert.equals("module/ui/lite_ui_v_0.swf", AndroidBackend.rebase(base, "module/ui/lite_ui_v_0.swf"));
		Assert.equals("data/xml/load_main_v_20120905.xml",
			AndroidBackend.rebase(base, "data/xml/load_main_v_20120905.xml"));
		Assert.equals(null, AndroidBackend.rebase(base, null));
		Assert.equals("mync.php?mod=user&act=run", AndroidBackend.rebase("", "mync.php?mod=user&act=run"));
		Assert.equals("mync.php?mod=user&act=run",
			AndroidBackend.rebase(null, "mync.php?mod=user&act=run"));
	}

	// rebaseFromSettings：基址走 Settings 的 flashvar 表（FlashVars.inject 的
	// android 分支把 resolveBase 结果写进 farm_backend；表里没有时回落默认值）
	public function testRebaseFromSettingsReadsFlashvarStore() {
		var settings = Settings.getInstance();
		settings.loadLocalSettings({"farm_backend": "http://10.1.2.3:9999"});
		Assert.equals("http://10.1.2.3:9999/home/qqfarm/core/mync.php?mod=user&act=run",
			AndroidBackend.rebaseFromSettings("mync.php?mod=user&act=run"));
		settings.loadLocalSettings({});
		Assert.equals(AndroidBackend.DEFAULT_BASE + "/home/qqfarm/core/xml.php?mod=nc_main",
			AndroidBackend.rebaseFromSettings("xml.php?mod=nc_main"));
	}
}
