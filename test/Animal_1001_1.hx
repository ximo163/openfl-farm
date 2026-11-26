package;

import openfl.display.Sprite;

// Animal_1001_1 —— CursorToolTest 的素材假面（issue #87 write-tests）。
// CursorTool.set cursorArgument 的 type==9 分支按
// "Animal_"+(cId ?? tId)+"_1" 取 Sprite 并摘其第一子件（CursorTool.as:33-41），
// MaterialLib 假域注入按名字面解析（support.MaterialFakes 头注释）——本类
// 即 {type:9, cId:1001} 推导出的名字面落 root 包；子件命名 a1001 让测试能
// 区分 cId 分支与 tId 兜底分支（Animal_1502_1 的子件名不同）。真实符号在
// 牧场 farm/aswf 库（#pasture 资产片），本类不进 src/（不造产品树）。
@:keep
class Animal_1001_1 extends Sprite {
	public function new() {
		super();
		var child = new Sprite();
		child.name = "a1001";
		addChild(child);
	}
}
