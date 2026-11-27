package com.qzone.corelib.js;

import common.misc.QzoneJSAPI;

/**
 * com.qzone.corelib.js.JSProxy —— JSProxy.as（mcloader_v_53/scripts，
 * 预加载器与 Master2 同应用域共享，Master2 反编译里无此文件）的签名面
 * stub（原类 384 loc，mcloader 片真身待译——后续模块；issue #19 只保
 * ProfileHead 头像 URL 用到的 getHead）。真身是 ExternalInterface 门面。
 */
@:keep
class JSProxy {
	public function new() {}

	// JSProxy.as:269-276（getHead：ExternalInterface.call(GET_HEAD,uin,size)
	// 回 String，available=false 回 ""）。
	// PORT-NOTE(qq-outlet)：ExternalInterface 仅 html5 可用，main3 侧同款
	// JS 门面已落在 common.misc.QzoneJSAPI（含 available 判空路径），复用。
	public static function getHead(param1:String, param2:Int):String {
		return QzoneJSAPI.getHead(param1, param2);
	}

	// JSProxy.as:361-364（addGToken：ExternalInterface.call(
	// "SwfAppLib.method.attachDefParam",url) as String——宿主 JS 给 URL 加
	// g_tk 鉴权参）。issue #86 为 com.minutes.net.HTTPRequest 编译链补签名。
	// PORT-NOTE(qq-outlet)：宿主集成出口按统一决策落 shim.QQOutlets.call——
	// 独立部署无宿主返 null，HTTPRequest 的 `tk != null && tk != ""` 判空
	// 支原样落空、URL 不加参（与原版在非 QZone 页面的兜底一致）。
	public static function addGToken(param1:String):String {
		var _loc1_:Dynamic = shim.QQOutlets.call("SwfAppLib.method.attachDefParam", param1);
		return Std.isOfType(_loc1_, String) ? cast(_loc1_, String) : null;
	}

	// JSProxy.as:93-99（openWindow：available 时 ExternalInterface.call(
	// "window.open",url)——无返回值通道）。issue #87 为 mc.view.common.
	// AlertWindow.onLinkClicked 的 wildInfo 链接分支编译链补签名。
	// PORT-NOTE(qq-outlet)：同 addGToken 决策族——QQOutlets.available
	// 恒 false（独立部署无宿主），调用原样落空，与原版在非 QZone
	// 页面的兜底一致。
	public static function openWindow(param1:String):Void {
		if (shim.QQOutlets.available) {
			shim.QQOutlets.call("window.open", param1);
		}
	}
}
