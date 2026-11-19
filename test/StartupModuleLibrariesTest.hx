package;

import shim.LocalSwfLoader;
import sys.io.File;
import utest.Assert;

/**
 * 启动窗口 module swf URL ↔ 资产库声明的一致性门（issue #7）。
 *
 * 原版部署里 module/*.swf 由站点 HTTP 提供（build.sh 把 source/core rsync 到
 * www/home/qqfarm/core/，xml.php 侧 common.php:15-17 的 $url 指回站点自身）。
 * 移植后这些 swf 是构建期入库的资产库：CLAUDE.md 规定 Loader.load 远程 swf
 * 统一走 Assets.getLibrary（// issue #7，shim.LocalSwfLoader 按 URL 尾段映射
 * 库名），调用方只把 `new Loader()` 换成 LocalSwfLoader，URL 原样传递。
 *
 * 启动窗口（module.Main 第一帧 + 冒烟等待的 500ms）内请求的 module swf 若没有
 * 对应 <library> 声明，翻译代码就会对未本地化的 URL 发真实网络请求：冒烟页的
 * 静态服务器（harness/smoke.mjs 只把 *.php 代理给旧后端）上没有该路径，浏览器
 * 记 console.error「Failed to load resource: 404」，web-smoke 直接 FAIL——
 * implement 阶段连续两轮即以此失败（WildShellNc_v_5.swf 未入库，见下）。
 *
 * 因此两条不变式：
 * 1. URL 必须能被 LocalSwfLoader.libraryIdForUrl 映射出库名（映射语义，含
 *    相对/绝对两种形态；宿主与映射无关）；
 * 2. 该库名必须在根目录 libraries.xml 里声明（本地化资产确实入库——只换
 *    LocalSwfLoader 不入库时 ioError 静默吞掉，但原版启动时这个 swf 是真实
 *    加载成功的，行为保真要求入库）。
 *
 * 覆盖范围 = 启动窗口会请求的全部 module swf。懒加载模块（shop/decorate/
 * warehouse/loading2，nc_main.php:7/16-18）不在窗口内（implement 阶段 25s
 * node 冒烟确认未请求），其入库随各自模块片处理。
 */
@:access(shim.LocalSwfLoader)
class StartupModuleLibrariesTest {
	// 绝对 URL 形态的前缀：common.php:15-17 `$url = 'http://'.HTTP_HOST.PHP_SELF
	// 去掉首个 core 起的尾段再 +'core'`，部署路径 /home/qqfarm/core/xml.php →
	// `http://<HTTP_HOST>/home/qqfarm/core`。host 取占位值（映射与 host 无关）。
	static final CORE_URL:String = "http://page.host/home/qqfarm/core";

	// 启动窗口请求的全部 module swf（URL 形态按各出处原样）。
	static final STARTUP_WINDOW:Array<{url:String, id:String}> = [
		// FarmLite.as:366（相对 URL 形态）：预加载器 boot 的 lite_ui
		{url: "module/ui/lite_ui_v_0.swf", id: "lite_ui_v_0"},
		// nc_main.php:10-13：main 模块与三件 material（$url 绝对形态下发）
		{url: CORE_URL + "/module/main3_v_221.swf", id: "main3_v_221"},
		{url: CORE_URL + "/module/ui/main/farmui_full_v_40.swf", id: "farmui_full_v_40"},
		{url: CORE_URL + "/module/ui/main/farmui2_v_58.swf", id: "farmui2_v_58"},
		{url: CORE_URL + "/module/ui/water_ui_v_0.swf", id: "water_ui_v_0"},
		// nc_main.php:20-23：FarmApplication.startup 的 500/1400ms setTimeout
		// 自动派发 MSG_LOAD_QUICKSHOOT/CARDSGAME/FREEGIFT/WATER → 启动窗口必发
		{url: CORE_URL + "/module/ui/quickshoot_v_0.swf", id: "quickshoot_v_0"},
		{url: CORE_URL + "/module/ui/cards_v_1.swf", id: "cards_v_1"},
		{url: CORE_URL + "/module/ui/gifts_v_11.swf", id: "gifts_v_11"},
		{url: CORE_URL + "/module/ui/pool_v_13.swf", id: "pool_v_13"},
		// FarmLiteModel.as:207（相对 URL 形态）：背景默认 module/ui/farm/diy/1.swf
		{url: "module/ui/farm/diy/1.swf", id: "1"},
		// nc_addon.php:81 beastLoaderUrl。启动窗口必发：Main.as:354 启动数据
		// 到位即调 loadAsyncWildModule（:173），:188-190 无论 _beast 是否为空
		// 都 loadWildShell（加载不受 param1 门控；FarmApplication.as:766-771
		// 在 _beast 非空时同样触发）。uid=1 的 user_run 无 _beast 也照样请求。
		{url: CORE_URL + "/module/mc/farm/wild/WildShellNc_v_5.swf", id: "WildShellNc_v_5"}
	];

	public function new() {}

	// 不变式 1：LocalSwfLoader.libraryIdForUrl 对启动窗口的全部 URL 都能给出
	// 与 swf 文件名（去 .swf）一致的库名——相对/绝对两种形态都要能映射。
	public function test_library_id_mapping_covers_startup_window_module_swf_urls() {
		for (r in STARTUP_WINDOW) {
			Assert.equals(r.id, LocalSwfLoader.libraryIdForUrl(r.url), 'url=${r.url}');
		}
	}

	// 映射的非目标（LocalSwfLoader 的契约：不是 .swf 或不含 module/ 的返回
	// null）：xml 配置与 *.php 不得被当成库，否则会抢占各自的真实加载通道
	//（wild_v_37.xml 是 BeastAPI 的 wildCfgUrl（nc_addon.php:82，V3b 片接
	// 入），mync.php 走 SwfUrlBase 的后端代理）。
	public function test_library_id_mapping_rejects_non_library_urls() {
		var cases:Array<{url:String, why:String}> = [
			{url: null, why: "null URL"}, // 契约：url == null → null
			{url: CORE_URL + "/module/mc/farm/wild/wild_v_37.xml", why: "wildXML 配置（xml 非库）"},
			{url: "mync.php?mod=user_run", why: "php 走后端代理（不含 module/）"}
		];
		for (c in cases) {
			Assert.isNull(LocalSwfLoader.libraryIdForUrl(c.url), 'url=${c.url}（${c.why}）');
		}
	}

	// 不变式 2：启动窗口的每个 module swf 都在 libraries.xml 声明为资产库。
	// 2026-11-19 现状：WildShellNc_v_5 缺声明——module/Main.loadWildShell 与
	// FarmApplication.loadWildShell 仍是裸 `new Loader()`（未换 LocalSwfLoader），
	// html5 下对绝对 URL 发真实请求 → web-smoke 404 FAIL（implement 连续两轮
	// 卡在这里；本条在入库前保持失败）。
	public function test_startup_window_module_swf_libraries_are_declared() {
		var declared:Map<String, Bool> = new Map<String, Bool>();
		try {
			var project = Xml.parse(File.getContent("libraries.xml")).firstElement();
			for (library in project.elementsNamed("library")) {
				declared.set(library.get("id"), true);
			}
		} catch (e:Dynamic) {
			Assert.fail('读不到 libraries.xml（测试须从仓库根目录跑）：${e}');
			return;
		}
		for (r in STARTUP_WINDOW) {
			Assert.isTrue(declared.exists(r.id),
				'libraries.xml 缺 <library id="${r.id}">：启动窗口会请求 ${r.url}，'
				+ '未入库的 module swf 在 html5 下发真实网络请求（冒烟静态服务器无此路径'
				+ '→ console.error 404 → web-smoke FAIL）');
		}
	}
}
