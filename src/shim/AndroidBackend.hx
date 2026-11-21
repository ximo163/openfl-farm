package shim;

import common.Settings;

/**
 * android 真机连局域网后端的基址解析与相对 URL 改写（issue #10，config 路线
 * 选了「局域网后端」，理由见 PR 说明）。纯逻辑，eval 单测覆盖
 * （test/shim/AndroidBackendTest.hx）。
 *
 * 为什么需要它：原版部署里宿主页 nmc.php、xml.php 和游戏 swf 同站，游戏代码
 * 里的相对 *.php（FarmLite.startCGIUrl 的 "mync.php?mod=user&act=run"、
 * FLASH_VARS 的 config_url "xml.php?mod=..."）由 Flash 播放器按 swf 所在 URL
 * 解析到同站后端。html5 由 SwfUrlBase 在 XMLHttpRequest.open 边界补
 * /home/qqfarm/core/ 基；android 没有这个边界——网络栈是 lime/curl
 * （NativeHTTPRequest 直把 uri 交给 curl），相对 URL 没有「swf 所在 URL」这个
 * 基，直接在 curl 层失败——真机卡预加载器、checkStart 的 _bootData 永远不来的
 * 根因。这里改成显式的后端基址：
 * - 默认值 DEFAULT_BASE：所有者按参考部署改（见 PR 说明的操作步骤），重出 APK；
 * - flashvar 覆盖优先：loaderInfo.parameters 已带 BACKEND_VAR 键时用传入值
 *   （键是 shim 自造的，nc.htm 没有——deviations 候选，人整理进
 *   spec/deviations.json）；
 * - 改写契约与 SwfUrlBase.resolve 同一款：只动「相对的 *.php」。绝对 URL
 *   （后端 nc_data 按 HTTP_HOST 下发的 postUrl 等）与已本地化的 module swf
 *   一律原样返回。
 *
 * 后端地址固定拼 CORE_PATH（build.sh:40 的部署关系 source/core →
 * www/home/qqfarm/core/，与 SwfUrlBase.CORE_BASE 是同一部署事实的两份拷贝）：
 * base 只写 scheme://host[:port]，如 http://192.168.1.100:8089。
 */
class AndroidBackend {
	// flashvar 键名（shim 自造，nc.htm:18-91 没有此键；android 分支专用）
	public static final BACKEND_VAR:String = "farm_backend";

	// 所有者按参考部署改这里：compose 端口默认 8089（legacy/snapshot/README.md
	// 的自检 curl 即 127.0.0.1:8089）。BIND_IP 只绑局域网、绝不暴露公网
	// （patches/002 下访问者即管理员）——那半边由人改，客户端只认这里的地址
	public static final DEFAULT_BASE:String = "http://192.168.1.100:8089";

	// legacy/deploy/QFarmFlash/build.sh:40 `rsync -a source/core/ www/home/qqfarm/core/`
	private static final CORE_PATH:String = "home/qqfarm/core/";

	// flashvar 覆盖优先：parameters 已带 BACKEND_VAR 且为非空 String → 用它；
	// 缺键 / 空串 / 非 String / params 为 null 一律回落默认值（与
	// Settings.getStringAttribute 的缺项语义对齐，Settings.as:376-396）
	public static function resolveBase(params:Dynamic):String {
		if (params != null) {
			var value:Dynamic = Reflect.field(params, BACKEND_VAR);
			if (Std.isOfType(value, String) && value != "") {
				return value;
			}
		}
		return DEFAULT_BASE;
	}

	// 相对 *.php → <base>/home/qqfarm/core/<原 URL>；其余原样返回。
	// 匹配规则与 SwfUrlBase.resolve 逐字同款（含 ? 之前取路径判 .php 后缀）
	public static function rebase(base:String, url:String):String {
		if (url == null || base == null || base == "") {
			return url;
		}
		var scheme:EReg = new EReg("^[a-zA-Z][a-zA-Z0-9+.-]*:", "");
		if (scheme.match(url) || url.charAt(0) == "/" || url.charAt(0) == "#") {
			return url;
		}
		var path:String = url;
		var q:Int = url.indexOf("?");
		if (q != -1) {
			path = url.substr(0, q);
		}
		if (path.length >= 4 && path.substr(path.length - 4) == ".php") {
			return joinCore(base) + url;
		}
		return url;
	}

	// Settings 侧入口（AndroidHttpRequest 的改写点用）：基址从 Settings 的
	// flashvar 表取——FlashVars.inject 的 android 分支已把 resolveBase 的结果写
	// 进 farm_backend，这里再走一遍 resolveBase 兜底 inject 未跑/表被清空的场景
	public static function rebaseFromSettings(url:String):String {
		return rebase(resolveBase(Settings.getInstance().allCfgData), url);
	}

	// base 尾部 / 容忍：有就不补，没有就补一个，再拼固定 core 路径
	static function joinCore(base:String):String {
		var joined:String = base.charAt(base.length - 1) == "/" ? base : base + "/";
		return joined + CORE_PATH;
	}
}
