package module.decorate;

import openfl.display.Sprite;

/**
 * module.decorate.DecorateWrapper —— DecorateWrapper.as 逐句对应（issue
 * #38 功能 swf 翻译：DIY 装饰）。decorate_v_0.swf 的 SymbolClass 根类
 * （char#0，全 swf 唯一导出符号）：main3 侧加载本 swf 后经
 * Utils.getClass("module.decorate.DecorateWrapper") 反射构造，本身是空
 * Sprite——模块真正入口在 ModuleDecorate 的
 * Utils.getClass("module.decorate.DecorateController") 链。
 * [SWF(width="500", height="375", backgroundColor="#869ca7", frameRate="24")]
 * 元数据即 swf 头（swf.xml 头部核实一致），构建参数在 Project.xml/库声明，
 * 不在类里复制。
 */
class DecorateWrapper extends Sprite {
	// DecorateWrapper.as:10-13
	public function new() {
		super();
	}
}
