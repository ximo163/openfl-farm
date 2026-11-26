package;

import openfl.display.Sprite;

// Animal_1502_1 —— CursorToolTest 的素材假面（issue #87 write-tests）。
// CursorTool.set cursorArgument 的 type==9 分支在无 cId 键时以 tId 兜底
// 拼 "Animal_"+tId+"_1"（CursorTool.as:38-41）——本类即 {type:9, tId:1502}
// 走兜底支推导出的名字面落 root 包（MaterialLib 假域注入按名字面解析，
// support.MaterialFakes 头注释）；子件命名 a1502 与 Animal_1001_1 区分。
// 真实符号在牧场 farm/aswf 库（#pasture 资产片），本类不进 src/（不造产品树）。
@:keep
class Animal_1502_1 extends Sprite {
	public function new() {
		super();
		var child = new Sprite();
		child.name = "a1502";
		addChild(child);
	}
}
