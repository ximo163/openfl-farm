package mc.view.common;

import openfl.display.Sprite;

/**
 * mc.view.common.MaterialProxyBig —— MaterialProxyBig.as 逐句对应（issue
 * #87 牧场「通用视图」片；#19 签名面 stub 充真身）。大素材格：薄壳持
 * 一个 MaterialProxy 转发 setContent。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/MaterialProxyBig.as。
 */
@:keep
class MaterialProxyBig extends Sprite {
	// MaterialProxyBig.as:8
	private var materialProxy:MaterialProxy;

	// MaterialProxyBig.as:10-15
	public function new() {
		super();
		this.materialProxy = new MaterialProxy();
		addChild(this.materialProxy);
	}

	// MaterialProxyBig.as:17-26
	public function setContent(param1:String, param2:Int, param3:Bool = true):Void {
		this.materialProxy.setContent(param1, param2, param3);
	}
}
