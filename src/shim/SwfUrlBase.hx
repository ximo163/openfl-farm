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
}
