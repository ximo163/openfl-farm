package;

import openfl.Lib;
import shim.FlashVars;

/**
 * 预加载器文档类宿主——原 Flash 播放器对 happyfarm3_v_149.swf 做的事。
 *
 * 原版：nc.htm 用 swfobject 嵌 module/happyfarm3_v_149.swf，播放器实例化
 * SymbolClass id 0 绑定的文档类 FarmLite（legacy/decompiled/
 * happyfarm3_v_149/symbolclass/symbols.csv），宿主页 FlashVars（nc.htm:18-91）
 * 挂在 root 的 loaderInfo 上。
 *
 * openfl：入口类由 Project.xml <app main="Main"/> 固定（受保护），Main 直接
 * 继承移植的 FarmLite 充当文档类——openfl 生成的 DocumentClass 先 addChild
 * 再跑构造器，FarmLite 构造器里 this.stage 可用，与 Flash 文档类语义一致，
 * FarmLite 原文一行不动。flashvar openfl 页面没有，构造前按 nc.htm 渲染注入
 * root 的 loaderInfo（shim.FlashVars，宿主页差异胶水）。
 *
 * 探针页接口 __openflFarmAdvance/__openflFarmState 随探针页退役（issue #3）；
 * __openflFarmReady 移到主程序第一帧置位（shim.Harness）。
 */
class Main extends FarmLite {
	public function new() {
		FlashVars.inject(@:privateAccess Lib.current.__loaderInfo);
		super();
	}
}
