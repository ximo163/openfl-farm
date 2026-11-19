package framework.layers;

import common.Consts;
import common.view.tip.TipControl;
import framework.base.BaseLayer;
import openfl.errors.ArgumentError;

/**
 * framework.layers.TipLayer —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 提示层（TipEvent 驱动、300ms 延时显示、跟随鼠标，TipLayer.as 177 loc）
 * 属于通用视图的提示片；这里只保构造形态（super(ctrl.getMsgCenter())、
 * mouseEnabled/mouseChildren = false、name = LAYER_TIP、null 参抛
 * ArgumentError）让 FarmStage 建层编译，提示行为随提示片接入。
 */
@:keep
class TipLayer extends BaseLayer {
	// TipLayer.as:29
	private var m_ctrl:TipControl;

	// TipLayer.as:31-49
	public function new(param1:TipControl) {
		if (param1 != null) {
			super(param1.getMsgCenter());
			this.m_ctrl = param1;
			this.m_libs = {};
			this.m_waitArg = null;
			this.m_waitTX = this.m_waitTY = 0;
			this.m_waitTip = "";
			this.m_timer = null;
			this.m_tip = null;
			mouseEnabled = false;
			mouseChildren = false;
			name = Consts.LAYER_TIP;
			return;
		}
		throw new ArgumentError("Null parameter");
	}

	// TipLayer.as:15-27
	private var m_libs:Dynamic;
	private var m_tip:Dynamic;
	private var m_waitTX:Int;
	private var m_waitTY:Int;
	private var m_waitArg:Dynamic;
	private var m_timer:Dynamic;
	private var m_waitTip:String;

	// TipLayer.as:106-115（init：挂 TipEvent/鼠标监听，提示片翻译）
	override private function init():Void {
		super.init();
	}
}
