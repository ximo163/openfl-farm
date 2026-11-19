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
 *
 * 库还没装载的情况分两种：farmui 系素材库由启动链（FarmLite.startLiteUI →
 * CmdLoadFile）先行拉起，视图构造时已在 Assets 里；作物分档 swf（Crop_*_*）
 * 原版是 requestClass 按需网络加载后才有类定义，而移植版类编译期即注册、
 * requestClass 的 URL 加载被 getClass 短路——这里把「库到位后符号可用」的
 * 原版时序补回来：库不在就按需 Assets.loadLibrary（html5 的非 preload 库在
 * libraryPaths 里，文件已随构建入库，无网络），同一个库的并发 bind 合并成
 * 一次加载。绑上的时刻晚于构造器返回，与原版「远程加载后 new」的时序差
 * 一个本就是异步的加载窗口。
 */
class SymbolClass {
	// 按需加载中的库：libraryId → 等待绑定的 (symbolName, target) 列表
	private static var pending:Array<{libraryId:String, symbolName:String, target:MovieClip}> = [];

	// DCE 引用锚。Haxe 只编译从 main 可达（被引用/import）的类型；符号 shim
	// 只经反射字符串取用（getMaterial/getClass → ApplicationDomain →
	// Type.resolveClass），编译期零引用时 @:keep 也救不了——类整体不进产物
	// （in-pipeline probe 证实：零引用的 @:keep 类在 bundle 里不存在，反射恒
	// null，LandTile 为此抛 "Can not get land res!"）。AS3 无此问题：Loader
	// 装载 swf 即把 SymbolClass 类注册进 ApplicationDomain。bind 在启动链上
	// 必然执行，首次调用把全部符号 shim 拉进类型图，各自的 @:keep 负责在
	// dce full 下保命。新增符号 shim 时同步补一行。
	// 仅生产目标：eval 按惯例是「无资源」环境（LandItemRenderTest 以
	// updateLandStatus 的素材缺失抛出为前提断言），锚不能把这个前提翻掉。
	#if !eval
	private static var dceAnchor:Array<Class<Dynamic>>;
	#end

	public static function bind(target:MovieClip, libraryId:String, symbolName:String):Void {
	#if !eval
		if (dceAnchor == null) {
			dceAnchor = [
				com.qzone.ui.FarmlandS, com.qzone.ui.FarmlandS2, com.qzone.ui.FarmlandG, com.qzone.ui.FarmlandG2,
				com.qzone.ui.red.FarmlandS, com.qzone.ui.red.FarmlandS2, com.qzone.ui.red.FarmlandG, com.qzone.ui.red.FarmlandG2,
				com.qzone.ui.black.FarmlandS, com.qzone.ui.black.FarmlandS2, com.qzone.ui.black.FarmlandG, com.qzone.ui.black.FarmlandG2,
				com.qzone.ui.JPLandS, com.qzone.ui.JPLandS2, com.qzone.ui.JPLandG, com.qzone.ui.JPLandG2,
				com.qzone.ui.Wasteland,
				CursorFishNet, CursorFishNetAll,
				Crop_1_0, Crop_1_1, Crop_1_2, Crop_1_3, Crop_1_4,
				Crop_6_0, Crop_6_1, Crop_6_2, Crop_6_3, Crop_6_4,
				Insect, Weed, Reclaim, CanPickIcon
			];
		}
#end
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
		if (library != null) {
			attach(library, libraryId, symbolName, target);
			return;
		}
		var alreadyLoading:Bool = false;
		for (entry in pending) {
			if (entry.libraryId == libraryId) {
				alreadyLoading = true;
				break;
			}
		}
		pending.push({libraryId: libraryId, symbolName: symbolName, target: target});
		if (alreadyLoading) {
			return;
		}
		Assets.loadLibrary(libraryId).onComplete(function(lib:AssetLibrary):Void {
			// 该库这一批等绑的目标全部挂上；再进来的 bind 走上面的同步路径
			var stillQueued:Array<{libraryId:String, symbolName:String, target:MovieClip}> = [];
			for (entry in pending) {
				if (entry.libraryId == libraryId) {
					attach(lib, entry.libraryId, entry.symbolName, entry.target);
				} else {
					stillQueued.push(entry);
				}
			}
			pending = stillQueued;
		}).onError(function(err:Dynamic):Void {
			// 库拉不起来（未声明/文件缺失）：按原版「类不存在」处理，留痕不抛
			trace("SymbolClass: 库加载失败 " + libraryId + " (" + Std.string(err) + ")");
			pending = [for (entry in pending) if (entry.libraryId != libraryId) entry];
		});
#end
	}

	private static function attach(library:AssetLibrary, libraryId:String, symbolName:String, target:MovieClip):Void {
#if !eval
		if (@:privateAccess target.__timeline != null) {
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
