package shim;

import openfl.display.MovieClip;
import swf.exporters.swflite.SWFLite;
import swf.exporters.swflite.SpriteSymbol;
import swf.exporters.swflite.timeline.SymbolTimeline;

/**
 * Flash SymbolClass 直 new 语义的等价物（平台差异胶水，非新架构）。
 *
 * 原版：lite_ui_v_0.swf 的 SymbolClass 把 Farmland_Lite 等导出符号绑到同名
 * AS3 类，视图代码 `new Farmland_Lite()` 构造出的实例天然带着符号时间轴。
 *
 * openfl（swf 3.4.0 / SWFLiteLibrary）：符号只在经 Assets.getMovieClip 实例化
 * 时挂时间轴——它按符号 className 反查 Haxe 同名类再 createInstance，靠
 * super() 里消费 Sprite.__constructor 完成绑定；直接 `new` 的实例是空剪辑。
 * （@:bind 元数据只对 AnimateLibrary 生效，SWFLite 库不走那条路。）
 *
 * 所以同名 Haxe 类的构造器补一步 bind：直接 new（__timeline 为空）时，按
 * SpriteSymbol.__constructor 的原样做法 new SymbolTimeline(swf, symbol) 再
 * attachTimeline 到自身——符号内容直接长在实例上，显示树结构与原版一致，
 * 不引入包装层。经库实例化进来的（__timeline 已在 super() 挂好）则跳过，
 * 不会二次绑定。
 */
class SymbolClass {
	public static function bind(target:MovieClip, libraryId:String, symbolName:String):Void {
		if (@:privateAccess target.__timeline != null) {
			return;
		}
		var swf:SWFLite = SWFLite.instances.get(libraryId);
		if (swf == null) {
			// 库未加载（eval 单测、缺 preload）时保持空剪辑并留痕，不抛——
			// 原版纯符号构造也不抛
			trace("SymbolClass: 库未加载 " + libraryId + ":" + symbolName);
			return;
		}
		var symbol:SpriteSymbol = cast @:privateAccess swf.symbolsByClassName.get(symbolName);
		if (symbol == null) {
			trace("SymbolClass: 符号不存在 " + libraryId + ":" + symbolName);
			return;
		}
		target.attachTimeline(new SymbolTimeline(swf, symbol));
	}
}
