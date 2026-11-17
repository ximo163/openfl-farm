package shim;

import openfl.Assets;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;

/**
 * 远程 swf 加载的本地化映射（CLAUDE.md：原版资产已本地化，Loader.load 远程 swf
 * 统一走 Assets.getLibrary()；这个映射只写在加载器对应的类里）。
 *
 * 原版 `new Loader().load(new URLRequest(url))` 跨网络拉 module/*.swf；本部署
 * 里这些 swf 是构建期入库的资产库。这里以 Loader 子类包住同名 load()：URL 能对
 * 上 module 库（形如 .../module/<路径>/<名>.swf）的，改由 Assets.loadLibrary
 * 取库、getMovieClip("") 取根时间轴，再在 contentLoaderInfo 上补齐原版字段并派
 * 发 COMPLETE——LoadManager/RSLLoader 等调用方的代码保持 `loader.load(req,
 * context)` 原形态，只把 `new Loader()` 换成本类。对不上的 URL 仍走父类原始
 * 网络路径。
 */
class LocalSwfLoader extends Loader {
	public function new() {
		super();
	}

	// URL → 资产库 id：取 "module/" 之后的尾段，再取最后一个 "/" 后的文件名，
	// 去掉 .swf 后缀（module/main3_v_221.swf → main3_v_221）。不是 .swf 或不
	// 含 module/ 的返回 null
	private static function libraryIdForUrl(url:String):String {
		if (url == null) {
			return null;
		}
		var marker:Int = url.indexOf("module/");
		if (marker == -1) {
			return null;
		}
		var tail:String = url.substr(marker + "module/".length);
		var slash:Int = tail.lastIndexOf("/");
		var filename:String = slash == -1 ? tail : tail.substr(slash + 1);
		if (!new EReg("\\.swf$", "i").match(filename)) {
			return null;
		}
		return filename.substr(0, filename.length - 4);
	}

	override public function load(request:URLRequest, context:LoaderContext = null):Void {
		var libraryId:String = libraryIdForUrl(request.url);
		if (libraryId == null) {
			// 原版网络路径（本部署的加载链不会走到）
			super.load(request, context);
			return;
		}
		Assets.loadLibrary(libraryId).onComplete(function(lib) {
			var content = lib.getMovieClip("");
			// Flash 里 content 由播放器挂进 Loader（loader.content / contentLoaderInfo.content
			// 可读，content 的 parent 是 loader）；openfl 的 Loader 按原版语义把
			// addChild 覆写为抛 #2069，所以走字段直设而不是 addChild
			Reflect.setField(this, "content", content);
			// contentLoaderInfo 上补齐 LoadManager.processFile 读取的字段
			//（(default,null) 在 JS 里是普通实例字段，Reflect 可写）
			Reflect.setField(this.contentLoaderInfo, "url", request.url);
			Reflect.setField(this.contentLoaderInfo, "content", content);
			Reflect.setField(this.contentLoaderInfo, "applicationDomain", ApplicationDomain.currentDomain);
			Reflect.setField(this.contentLoaderInfo, "bytesLoaded", 1);
			Reflect.setField(this.contentLoaderInfo, "bytesTotal", 1);
			this.contentLoaderInfo.dispatchEvent(new Event(Event.COMPLETE));
		}).onError(function(e) {
			this.contentLoaderInfo.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, Std.string(e)));
		});
	}
}
