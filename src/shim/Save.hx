package shim;

import openfl.net.SharedObject;

/**
 * SharedObject 的统一入口（CLAUDE.md：openfl 的 SharedObject 各目标的存储路径与
 * 行为有差异，读写集中到 shim 封装，原版调用点照翻、指向这里）。
 *
 * 原版唯一入口是 Cookies.intialize 的 SharedObject.getLocal("FarmWorld2")
 * （Cookies.as:186-198）。openfl 在 html5 用 localStorage、原生目标用本地文件，
 * 后续要统一路径/容量处理时只改本文件。
 */
class Save {
	public static function getLocal(name:String):SharedObject {
		try {
			return SharedObject.getLocal(name);
		} catch (e:Dynamic) {
			// 原版调用方 Cookies.intialize 自带 try/catch + trace（Cookies.as:194-196），
			// 这里返回 null 让它按 Cookie == null 的原版分支继续
			return null;
		}
	}
}
