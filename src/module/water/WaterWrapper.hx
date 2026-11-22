package module.water;

import openfl.display.Sprite;

/**
 * module.water.WaterWrapper —— WaterWrapper.as 逐句对应（issue #37）。独立
 * 播放包装文档类（pool_v_13.swf 直接打开时的根，尺寸元数据只影响单播），
 * 鱼塘逻辑全在 WaterController 链上；空类照译。
 */
// PORT-NOTE: [SWF(width=500,height=375,backgroundColor="#869ca7",
// frameRate=24)] 编译期元数据，嵌入 main3 工程时无效，不移植
class WaterWrapper extends Sprite {
	public function new() {
		super();
	}
}
