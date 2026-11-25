package shim;

import openfl.Assets;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.MovieClip;
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
 * 取库、getMovieClip("") 取根时间轴，contentLoaderInfo 上补齐 LoadManager 读取
 * 的字段，其余（content 字段、显示树挂载、COMPLETE 派发）交给 openfl 原生完成
 * 路径 Loader_onComplete——LoadManager/RSLLoader 等调用方的代码保持
 * `loader.load(req, context)` 原形态，只把 `new Loader()` 换成本类。对不上的
 * URL 仍走父类原始网络路径。
 */
class LocalSwfLoader extends Loader {
	public function new() {
		super();
	}

	// URL → 资产库 id：取 "module/" 之后的尾段，再取最后一个 "/" 后的文件名，
	// 去掉 .swf 后缀（module/main3_v_221.swf → main3_v_221）。不是 .swf 或不
	// 含 module/ 的返回 null。例外：diy/board/ 下的看板素材与 diy/ 的装饰素材
	// 文件名同为纯数字（nc_data.php:2260 board/1.swf vs :51 diy/1.swf），文件名
	// id 会撞库——原版按整条 URL 网络加载没有这个问题，本地化后看板加 board_
	// 前缀消歧（libraries.xml 的 id="board_1" 同款）
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
		var id:String = filename.substr(0, filename.length - 4);
		if (tail.indexOf("diy/board/") != -1) {
			id = "board_" + id;
		}
		return id;
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
			// contentLoaderInfo 上补齐 LoadManager.processFile 读取的字段
			//（这些是 (default,null) 物理字段，各目标 Reflect 可写）
			Reflect.setField(this.contentLoaderInfo, "url", request.url);
			Reflect.setField(this.contentLoaderInfo, "applicationDomain", ApplicationDomain.currentDomain);
			Reflect.setField(this.contentLoaderInfo, "bytesLoaded", 1);
			Reflect.setField(this.contentLoaderInfo, "bytesTotal", 1);
			// content 字段、显示树挂载、COMPLETE 派发全走 openfl 原生完成路径
			//（Loader_onComplete：Loader.hx 的 content 装载段，内部 super.addChildAt
			// (content, 0) 从 Loader 自己出发、上溯到 DisplayObjectContainer）。
			// 不能在本子类里照抄 super.addChildAt：super 只上溯一层，这里命中的是
			// Loader 自己的 #2069 覆写（Flash 同款禁令：Loader 不许 addChild），
			// #21 attempt 2 的 CI web-smoke 就红在这（attachContent 抛
			// openfl.errors.Error #2069 → __openflFarmReady 永不置位）。Haxe 没有
			// super.super，经 @:access 调 openfl 的私有完成函数是唯一等价口。
			// super 调用/私有访问不能落在闭包里（Haxe 限制），抽成员方法。
			// openfl 版本耦合：Loader_onComplete 是 9.5.2 的私有函数名，升版若
			// 改名会编译红在这里（shim 定位就是这类版本胶水）。
			attachContent(content, libraryId);
		}).onError(function(e) {
			this.contentLoaderInfo.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, Std.string(e)));
		});
	}

	// openfl 原生完成路径的落点（见上：super./@:access 不能出现在本地函数内）
	@:access(openfl.display.Loader)
	private function attachContent(content:DisplayObject, libraryId:String):Void {
		Loader_onComplete(content);
		// #58 帧脚本补偿（根时间轴场景）：getMovieClip("") 的根符号无
		// SymbolClass 名，导出器不给 scriptSource（AnimateLibraryExporter
		// 只对 SymbolClass 绑定名跑 FrameScriptParser）——根轴帧脚本（RedUp
		// 主轴末帧 dispatchEvent("end")）查表回挂，库无登记则无操作
		if (Std.isOfType(content, MovieClip)) {
			FrameScriptCompensation.attach(cast(content, MovieClip), libraryId, "");
			// #65 help.swf 帧脚本等价 + DefineEditText 文字修复：help 自带完整
			// AS3（非 #58 那种原语帧脚本），已 1:1 翻译成 help0316_fla 类，
			// 等价执行/文字 range 补洞归 HelpGuideWiring（why 见其头注；只按
			// help 库挂，不向同族 swf 扩散）
			if (libraryId == "help") {
				HelpGuideWiring.attach(cast(content, MovieClip));
			}
		}
	}
}
