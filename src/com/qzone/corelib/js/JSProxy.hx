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
}
