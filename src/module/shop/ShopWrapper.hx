package module.shop;

import openfl.display.Sprite;

/**
 * module.shop.ShopWrapper —— ShopWrapper.as 逐句对应（issue #35 功能 swf
 * 翻译：商店）。shop_v_7.swf 的 SymbolClass 根类（char#0，全 swf 唯一导出
 * 符号）：main3 侧加载本 swf 后经 Utils.getClass("module.shop.ShopWrapper")
 * 反射构造，本身是空 Sprite——模块真正入口在 ModuleShop 的
 * Utils.getClass("module.shop.ShopController") 链。
 * [SWF(width="500", height="375", backgroundColor="#869ca7", frameRate="24")]
 * 元数据即 swf 头（swf.xml 头部核实一致），构建参数在 Project.xml/库声明，
 * 不在类里复制。
 */
class ShopWrapper extends Sprite {
	// ShopWrapper.as:10-13
	public function new() {
		super();
	}
}
