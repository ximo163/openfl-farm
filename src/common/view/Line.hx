package common.view;

import openfl.display.Shape;

// common.view.Line —— Line.as 逐句对应（issue #36 功能 swf 翻译：仓库）。
// 分隔细线：PlantsPage/SendFlowerWindow 的赠送花束分区线。
class Line extends Shape {
	// Line.as:9-15（宽 param1、起点 x 偏移 param2、颜色 param3 默认白）
	public function new(param1:Int = 100, param2:Int = 0, param3:UInt = 16777215) {
		super();
		graphics.lineStyle(1, param3);
		graphics.moveTo(param2, 0);
		graphics.lineTo(param1, 0);
		graphics.endFill();
	}
}
