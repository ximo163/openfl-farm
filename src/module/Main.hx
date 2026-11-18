package module;

import openfl.display.MovieClip;
import shim.Harness;
import shim.SymbolClass;

/**
 * main3_v_221.swf 的文档类（SymbolClass id 0 → "module.Main"）——**最小
 * stub，不是翻译**：main3 本体是后续模块（本仓库尚无其翻译），V2 加载链路
 * （issue #3）只需要它「拉起到第一帧」：
 *
 * - ResourceManager.getClassInstance("module.Main") 走 ApplicationDomain
 *   getDefinition，openfl 里即 Type.resolveClass——@:keep 保裁剪，FarmLite 头上
 *   的 import 保编译（纯字符串引用两头都不保）；
 * - 原版实例 = 文档类绑着 main3 根时间轴（SymbolClass id 0 绑定），这里用
 *   SymbolClass.bindRoot 等价挂上，主程序第一帧照常显示；
 * - startGame（Main.as:308 起，StartupDataParser/FarmApplication 全链）待
 *   后续模块翻译，空实现只保证 FarmLite.startMain 的动态调用不抛。
 *
 * 构造器里的 Harness.markMainFirstFrame 是 harness 冒烟约定的注入点
 * （__openflFarmReady 在主程序第一帧置位）——正式翻译替换本文件时保留该调用。
 */
@:keep
class Main extends MovieClip {
	public function new() {
		super();
		SymbolClass.bindRoot(this, "main3_v_221");
		Harness.markMainFirstFrame(this);
	}

	// Main.as:308-…（后续模块翻译，见类头注释）
	public function startGame(param1:Dynamic):Void {}
}
