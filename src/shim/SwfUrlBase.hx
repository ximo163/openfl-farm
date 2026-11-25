package shim;

/**
 * Flash 播放器的「相对 URL 按 swf 所在 URL 解析」在浏览器页面的等价物
 * （宿主页/平台差异胶水，非新架构）。
 *
 * 原版：播放器把游戏代码里的相对 URL（"mync.php?mod=..."、"xml.php?mod=..."
 * 等，见 FarmLite.startCGIUrl / FLASH_VARS.config_url）按 swf 自身位置解析。
 * 仓库对此的权威说明：legacy/manifest.json 对 source/core 的注——
 * 「swf 里的相对 URL 对应站点 URL /home/qqfarm/core/ 下的路径」
 * （部署关系：build.sh 把 source/core rsync 到 www/home/qqfarm/core/）。
 *
 * openfl 页面：URL 由浏览器解析，基是页面自身（静态服务器根），相对 php 会
 * 落到站点根——旧后端在那里什么都没有（xml.php/mync.php 都在
 * /home/qqfarm/core/ 下），请求必 404。CI 冒烟（harness/smoke.mjs，受保护）
 * 的代理按「*.php 原样转发路径」设计，契约就是「移植侧不用改 URL 形态」；
 * 因此补基的做法放在网络边界（XMLHttpRequest.open），游戏代码的相对 URL
 * 字符串一个都不动。
 *
 * 只改写「相对的 *.php」：
 * - swf 模块资产按 CLAUDE.md 已本地化（LocalSwfLoader→Assets，不发网络请求）；
 * - 页面自身的资产（lib/*.zip 等）也走相对 URL，基必须保持在页面根——
 *   一并改基会把资产加载打 404。*.php 恰好也是冒烟代理转发的全部范围。
 */
class SwfUrlBase {
	// legacy/deploy/QFarmFlash/build.sh:40 `rsync -a source/core/ www/home/qqfarm/core/`
	// 相对前缀（不带起始 /）：与任意 host:port 组合，落在当前站点下的 core 目录
	private static final CORE_BASE:String = "home/qqfarm/core/";

	private static var installed:Bool = false;

	public static function install():Void {
		#if html5
		if (installed) {
			return;
		}
		installed = true;
		// 用原生 JS 包装而不是 Haxe 闭包：原型方法里的 this（xhr 实例）和
		// arguments（open 的全部形参）要原样透传，Haxe 闭包拿不到调用方 this
		js.Syntax.code("
			var resolve = {0};
			var orig = XMLHttpRequest.prototype.open;
			XMLHttpRequest.prototype.open = function () {
				arguments[1] = resolve(arguments[1]);
				return orig.apply(this, arguments);
			}", resolve);
		#end
	}

	// 匹配「相对的 *.php」：无 scheme（http:/https:/data:/blob:…）、不以 / 或 //
	// 开头，且 ? 之前的路径以 .php 结尾。其余 URL 原样返回
	private static function resolve(url:String):String {
		#if html5
		if (url == null) {
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
			return CORE_BASE + url;
		}
		#end
		return url;
	}

	// issue #64（cpp linux 启动冒烟）：linux 二进制的相对 *.php（mync.php/
	// xml.php）需要指到 CI 后端——web 靠同源自动可达，cpp 二进制没有「源」。
	// 环境变量 QFARM_BASE_URL 存在则作为基址覆盖（各目标通用、不存在时行为
	// 不变，html5 同源路径不受影响）。读环境变量与接线（合并点）归 implement
	// （issue 要求先读本文件解析逻辑再定）；本函数是归并后的纯逻辑：
	// base 非空 + 相对 *.php → <base>/home/qqfarm/core/<原 url>；其余原样
	// （与 AndroidBackend.rebase 同一部署事实：build.sh:40 source/core →
	// www/home/qqfarm/core/）。base 尾部的 / 容忍（不产生双斜杠）。

	// 环境变量名（// issue #64 A.2 原文钉死）：冒烟脚本（tools/cpp-boot-
	// smoke.sh）设置侧与本类读取侧靠它对齐——两处各写一份字面量时错一个
	// 字母冒烟就静默测不到后端路径，常量钉单点。implement 读环境变量时用
	// 本常量，别另起字面量。
	public static final BASE_URL_ENV:String = "QFARM_BASE_URL";

	public static function resolveCpp(base:String, url:String):String {
		throw new haxe.Exception("not implemented");
	}
}
