package framework.layers;

import common.Consts;
import common.view.floating.FloatControl;
import framework.base.BaseLayer;
import openfl.errors.ArgumentError;

/**
 * framework.layers.FloatingLayer —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 飘字层（FloatingEvent 驱动的收获/加钱/经验飘字宿主，FloatingLayer.as
 * 108 loc）属于通用视图的飘字片；这里只保构造形态（super(
 * ctrl.getMsgControl())、mouseEnabled/mouseChildren = false、name =
 * LAYER_FLOATING、null 参抛 ArgumentError）让 FarmStage 建层编译，
 * 飘字行为随飘字片接入。
 */
@:keep
class FloatingLayer extends BaseLayer {
	// FloatingLayer.as:12
	private var m_ctrl:FloatControl;

	// FloatingLayer.as:22-38
	public function new(param1:FloatControl) {
		if (param1 != null) {
			super(param1.getMsgControl());
			mouseEnabled = false;
			mouseChildren = false;
			this.name = Consts.LAYER_FLOATING;
			this.m_ctrl = param1;
			return;
		}
		throw new ArgumentError("Null parameter");
	}

	// FloatingLayer.as:41-45（init：挂 FloatingEvent 监听，飘字片翻译）
	override private function init():Void {
		super.init();
	}
}
