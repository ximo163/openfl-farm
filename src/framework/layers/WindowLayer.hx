package framework.layers;

import common.Consts;
import common.view.window.WindowControl;
import framework.base.BaseLayer;
import openfl.errors.ArgumentError;

/**
 * framework.layers.WindowLayer —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 窗口层（WindowEvent 驱动的弹窗宿主 + PopUpManager 挂载，WindowLayer.as
 * 165 loc）属于通用视图的窗口片；这里只保构造形态（super(ctrl.getMsgCenter())、
 * name = LAYER_WINDOW、null 参抛 ArgumentError）让 FarmStage 建层编译，
 * 弹窗行为随窗口片接入。
 */
@:keep
class WindowLayer extends BaseLayer {
	// WindowLayer.as:18
	private var m_windowCtrl:WindowControl;

	// WindowLayer.as:22-33
	public function new(param1:WindowControl) {
		if (param1 != null) {
			super(param1.getMsgCenter());
			this.m_windowCtrl = param1;
			this.m_winInstances = {};
			this.name = Consts.LAYER_WINDOW;
			return;
		}
		throw new ArgumentError("Null parameter");
	}

	// WindowLayer.as:20
	private var m_winInstances:Dynamic;

	// WindowLayer.as:99-110（init：挂 WindowEvent 监听，窗口片翻译）
	override private function init():Void {
		super.init();
	}
}
