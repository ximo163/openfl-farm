package shim;

import utest.Assert;

/**
 * cpp linux 环境变量基址入口的纯逻辑（issue #64 write-tests 阶段，对
 * stub 失败）——QFARM_BASE_URL 存在时相对 *.php 指到 CI 后端。
 *
 * 出处：
 * - 入口形态与「各目标通用、不存在时行为不变，html5 同源路径不受影响」：
 *   // issue #64 A.2（linux 二进制的相对 URL（mync.php/xml.php）需要指到
 *   CI 后端——web 靠同源自动可达，cpp 二进制没有「源」）。
 * - 只改写「相对的 *.php」的匹配规则：shim/SwfUrlBase.hx resolve 的同款
 *   契约（无 scheme、不以 / 或 # 开头、? 之前的路径以 .php 结尾——issue
 *   要求 implement 先读这份解析逻辑再定合并点，归并后纯逻辑同一款）。
 * - <base>/home/qqfarm/core/ 拼接：legacy/deploy/QFarmFlash/build.sh:40
 *   `rsync -a source/core/ www/home/qqfarm/core/`（与 SwfUrlBase.CORE_BASE、
 *   AndroidBackend.CORE_PATH 是同一部署事实的第三份拷贝——issue #64 方案
 *   节点名 QFARM_BASE_URL「作为基址覆盖」，基址语义与 android 局域网后端
 *   一致：只写 scheme://host[:port]）。
 * - 原版相对 URL 形态实例：legacy/decompiled/happyfarm3_v_149/scripts/
 *   FarmLite.as get_startCGIUrl（"mync.php?mod=user&act=run"）与宿主页
 *   legacy/deploy/QFarmFlash/source/core/view/qf_default/nc.htm:84-86
 *   （config_url "xml.php?mod=..."）。
 *
 * 读环境变量（Sys.getEnv，sys 边界不进单测）与合并点接线归 implement；
 * 本门只钉归并后的纯逻辑：base 非空 + 相对 *.php → 拼到后端 core 下，
 * 其余输入（base 空/null、绝对 URL、非 php 相对、null url）原样不动。
 */
class SwfUrlBaseCppTest {
	public function new() {}

	// base 非空 + 相对 *.php（含查询串）→ <base>/home/qqfarm/core/<原 url>；
	// base 尾部 / 容忍（不产生双斜杠）。CI 冒烟形态：QFARM_BASE_URL=
	// http://127.0.0.1:8089（// issue #64——ci/legacy-backend-up.sh 的
	// PORT=8089 与 web.yml 的 LEGACY_BACKEND_URL 同端口）
	public function test_relative_php_rebased_under_backend_core() {
		var cases:Array<{base:String, url:String, expected:String}> = [
			{
				// FarmLite.as:324 的启动 CGI 形态（// issue #64 A.2 点名 mync.php）
				base: "http://127.0.0.1:8089",
				url: "mync.php?mod=user&act=run",
				expected: "http://127.0.0.1:8089/home/qqfarm/core/mync.php?mod=user&act=run"
			},
			{
				// nc.htm:84-86 的 config 形态（// issue #64 A.2 点名 xml.php）
				base: "http://127.0.0.1:8089/",
				url: "xml.php?mod=load_main_v_20120905.xml",
				expected: "http://127.0.0.1:8089/home/qqfarm/core/xml.php?mod=load_main_v_20120905.xml"
			},
			{
				// 无查询串的裸相对 php（SwfUrlBase.resolve 同款匹配面）
				base: "http://10.0.0.2:9000",
				url: "mync.php",
				expected: "http://10.0.0.2:9000/home/qqfarm/core/mync.php"
			}
		];
		for (c in cases) {
			Assert.equals(c.expected, SwfUrlBase.resolveCpp(c.base, c.url), 'base=${c.base} url=${c.url}');
		}
	}

	// 绝对 URL / 根相对 / 锚点原样返回（SwfUrlBase.resolve 同款豁免）——
	// 后端 nc_data 按 HTTP_HOST 下发的 postUrl（common.php:15-17）已是绝对
	// 地址，改写不得碰（AndroidBackendTest 同族断言的出处）
	public function test_absolute_and_rooted_urls_untouched() {
		var base:String = "http://127.0.0.1:8089";
		var urls:Array<String> = [
			"http://127.0.0.1:8089/home/qqfarm/core/mync.php?mod=farmlandstatus&act=harvest",
			"https://example.com/other.php",
			"/home/qqfarm/core/xml.php?mod=nc_main",
			"#anchor"
		];
		for (url in urls) {
			Assert.equals(url, SwfUrlBase.resolveCpp(base, url), 'url=${url}');
		}
	}

	// 非 *.php 的相对 URL 原样返回——module swf 已本地化（LocalSwfLoader→
	// Assets，不发网络请求）、页面/二进制资产不该拼到后端 core 下
	// （SwfUrlBase.hx 头注「只改写相对的 *.php」的同款边界）
	public function test_non_php_relative_urls_untouched() {
		var base:String = "http://127.0.0.1:8089";
		Assert.equals("module/ui/lite_ui_v_0.swf", SwfUrlBase.resolveCpp(base, "module/ui/lite_ui_v_0.swf"));
		Assert.equals("data/xml/load_main_v_20120905.xml",
			SwfUrlBase.resolveCpp(base, "data/xml/load_main_v_20120905.xml"));
	}

	// base 缺位（null/空串）= 环境变量没设——// issue #64「不存在时行为
	// 不变」：原样返回，不发明地址。html5 同源路径不受影响（html5 根本不
	// 走这条入口，这里只钉 cpp 侧的缺省语义）
	public function test_missing_base_leaves_url_unchanged() {
		Assert.equals("mync.php?mod=user&act=run",
			SwfUrlBase.resolveCpp(null, "mync.php?mod=user&act=run"), "base=null 不改写");
		Assert.equals("mync.php?mod=user&act=run",
			SwfUrlBase.resolveCpp("", "mync.php?mod=user&act=run"), "base=空串 不改写");
		Assert.equals("xml.php?mod=nc_main",
			SwfUrlBase.resolveCpp(null, "xml.php?mod=nc_main"));
	}

	// null url 原样穿（SwfUrlBase.resolve 的同款防御，resolve:54-56）
	public function test_null_url_passes_through() {
		Assert.equals(null, SwfUrlBase.resolveCpp("http://127.0.0.1:8089", null));
	}

	// 环境变量名钉死（// issue #64 A.2 原文）：冒烟脚本设置侧与本类读取侧
	// 靠同一常量对齐——错一个字母冒烟静默测不到后端路径
	public function test_env_var_name_is_qfarm_base_url() {
		Assert.equals("QFARM_BASE_URL", SwfUrlBase.BASE_URL_ENV);
	}
}
