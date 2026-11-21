package shim;

import openfl.display.Loader;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;

/**
 * QQ 相关出口的统一 no-op（spec/deviations.json：no-qzone-jsapi + no-qq-telemetry，
 * 2026-11-17 用户决定独立部署不做 QQ 相关请求与上报）。
 *
 * 原版 QzoneJSAPI / Utils / EventRecorder / FarmLite 里的 ExternalInterface.call、
 * ExternalInterface.addCallback、sendToURL 出口，翻译后的调用点保持原调用形态、
 * 全部指到这里：一律不发送、不向页面注入宿主调用。
 *
 * 取值型调用方拿到 null 后走自己的「宿主不可用」分支，与原版在非 QZone 页面里
 * 的兜底一致（如 QzoneJSAPI.addGToken 在 available=false 时原样返回传入 URL，
 * FarmLite.startCGIUrl 因此仍得到可用的 mync.php 地址）。
 *
 * 为什么不直接用 openfl 的 ExternalInterface：html5 下它 available=true 且会真的
 * eval 页面 JS——独立页面里没有 SwfAppLib/fusion2（QZone 宿主 JS），照发会在
 * 浏览器里抛 ReferenceError。CLAUDE.md 要求 ExternalInterface 的平台差异包在
 * src/shim 按 #if html5 处理，这里以常量 available=false 表达「宿主不存在」，
 * 各调用方自然落到不可用分支，不需要逐处 #if。
 */
class QQOutlets {
	public static final available:Bool = false;

	/** ExternalInterface.call 的同名出口：不向页面发起宿主调用，返回 null。 */
	public static function call(method:String, p1:Dynamic = null, p2:Dynamic = null, p3:Dynamic = null, p4:Dynamic = null,
			p5:Dynamic = null):Dynamic {
		return null;
	}

	/** ExternalInterface.addCallback 的同名出口：不向页面注册回调。 */
	public static function addCallback(functionName:String, closure:Dynamic):Void {}

	/** flash.net.sendToURL 的同名出口（openfl 没有这个顶层函数）：不发送。 */
	public static function sendToURL(request:URLRequest):Void {}

	/** 头像/宿主图片加载出口（PersonInfo 的 headPic 一族）：不发送。
	 *
	 * 原版 `Loader.load(url, new LoaderContext(true))` 直连宿主 ucenter 头像
	 * 服务——URL 是宿主环境数据（mync user_run 的 headPic 字段，PHP 侧由
	 * UC_API 前缀拼出）：正式 QZone 部署指向宿主站、同站可达。独立部署的快照
	 * 配置 UC_API 是参考部署的局域网地址（legacy/snapshot/home-config.php:45
	 * `192.168.218.129`），照发在任何部署外环境都挂死并记一条资源错（#9 两轮
	 * CI web-smoke 同点红的根因）。视觉语义不变：原版跑本部署包同样取不到
	 * 头像（IOErrorEvent 被 onPhotoLoadError 吞掉、留空头像框）。与
	 * QzoneJSAPI.getHead 在 available=false 回空串同一决策族；deviations 候选
	 * 待人登记。
	 */
	public static function loadImage(loader:Loader, request:URLRequest, context:LoaderContext = null):Void {}
}
