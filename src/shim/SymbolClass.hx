package shim;

import openfl.display.MovieClip;
import openfl.utils.AssetLibrary;
import openfl.utils.Assets;
#if !eval
import swf.exporters.animate.AnimateLibrary;
#end

/**
 * Flash SymbolClass 直 new 语义的等价物（平台差异胶水，非新架构）。
 *
 * 原版：lite_ui_v_0.swf 的 SymbolClass 把 Farmland_Lite 等导出符号绑到同名
 * AS3 类，视图代码 `new Farmland_Lite()` 构造出的实例天然带着符号时间轴。
 *
 * openfl（swf 3.4.0，构建期 AnimateLibraryExporter，运行时
 * swf.exporters.animate.AnimateLibrary——swf 库的 SWFLite 路径已整体注释掉，
 * 本仓库构建产物 lib/*.zip 的 libraryType 即 AnimateLibrary）：符号只在经
 * Assets.getMovieClip 实例化时挂时间轴；直接 `new` 的同名 Haxe 类是空剪辑。
 * AnimateLibrary 提供了 `bind(className, instance)`（openfl 9.1+，@:bind 元
 * 数据同款入口）：把符号时间轴挂到已构造的实例上。
 *
 * 所以同名 Haxe 类的构造器补一步 bind：直接 new 时按上面入口挂时间轴——符号
 * 内容直接长在实例上，显示树结构与原版一致，不引入包装层。经库实例化进来的
 * （super() 消费 Sprite.__constructor 已挂好）则跳过，不会二次绑定。
 */
class SymbolClass {
	public static function bind(target:MovieClip, libraryId:String, symbolName:String):Void {
#if eval
		// eval 单测（test.hxml 无 -lib swf）：无库可查，保持空剪辑并留痕，
		// 不抛——原版纯符号构造也不抛
		trace("SymbolClass: eval 目标无库 " + libraryId + ":" + symbolName);
#else
		if (@:privateAccess target.__timeline != null) {
			return;
		}
		// Assets.getLibrary 静态类型是 lime 的 AssetLibrary（无 bind）；
		// 本流水线的库实例都是 openfl 侧库（AnimateLibrary），收窄后走
		// openfl AssetLibrary.bind（AnimateLibrary 覆写）
		var library:AssetLibrary = cast Assets.getLibrary(libraryId);
		if (library == null) {
			// 库未加载（缺 preload）时保持空剪辑并留痕，不抛——原版纯符号
			// 构造也不抛
			trace("SymbolClass: 库未加载 " + libraryId + ":" + symbolName);
			return;
		}
		if (!library.bind(symbolName, target)) {
			trace("SymbolClass: 符号不存在 " + libraryId + ":" + symbolName);
		}
#end
	}

	/**
	 * SymbolClass 把类名绑到**根时间轴**（tag id 0，即文档类）时的对应绑定：
	 * Animate 导出器不给根符号记 className（AnimateLibraryExporter 只处理有
	 * character 的符号，id 0 不是 character），`bind(类名, …)` 查不到。按
	 * Assets.getMovieClip("<库>:") 同款做法（root.__createObject 的内部路径）
	 * 把根符号时间轴挂到实例上——实例本身就是根时间轴，不加包装层。
	 */
	public static function bindRoot(target:MovieClip, libraryId:String):Void {
#if eval
		trace("SymbolClass: eval 目标无库 " + libraryId + ":(root)");
#else
		if (@:privateAccess target.__timeline != null) {
			return;
		}
		var library:AssetLibrary = cast Assets.getLibrary(libraryId);
		if (library == null) {
			trace("SymbolClass: 库未加载 " + libraryId);
			return;
		}
		if (Std.isOfType(library, AnimateLibrary)) {
			var animate:AnimateLibrary = cast library;
			@:privateAccess animate.root.__initObject(animate, target);
		} else {
			trace("SymbolClass: 非 AnimateLibrary，无法绑根 " + libraryId);
		}
#end
	}
}
