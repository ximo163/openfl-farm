package;

import openfl.display.MovieClip;

// CursorTool_1_101 —— CursorToolTest 的素材假面（issue #87 write-tests）。
// CursorTool.set cursorArgument 的 type!=9 分支按
// "CursorTool_"+type+"_"+tId 推导素材名取素材（CursorTool.as:29-31），
// MaterialLib 假域注入按名字面解析（support.MaterialFakes 头注释）——本类
// 即以 {type:1, tId:101} 推导出的名字面落 root 包，素材名推导错一位假域就
// 取空、`_cursor.cacheAsBitmap` 随即炸 null，测试据此红。真实符号在牧场
// farmui 库（#pasture 资产片），本类不进 src/（不造产品树）。空 MovieClip：
// 测试只断言装配/父子结构与标志位，不涉时间轴。
@:keep
class CursorTool_1_101 extends MovieClip {
	public function new() {
		super();
	}
}
