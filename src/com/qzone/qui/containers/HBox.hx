package com.qzone.qui.containers;

import com.qzone.qui.containers.boxClasses.Box;
import com.qzone.qui.core.Direction;

// com.qzone.qui.containers.HBox —— HBox.as 逐句对应（issue #9 qui 子集片）。
// 横向盒子（ToolBar/ToolBoxBar 的基类）。
class HBox extends Box {
	// HBox.as:9-13
	public function new(param1:Float = 200, param2:Float = 200) {
		super(param1, param2);
		this.direction = Direction.HORIZONTAL;
	}
}
