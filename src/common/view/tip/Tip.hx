package common.view.tip;

/**
 * common.view.tip.Tip —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 提示基类（Tip.as，ITip 实现的公共底座）；FarmStage 建层时按 Consts 注册进控件表，本片只保类形态
 * （@:keep 防 dce，供 register/Type.resolveClass 拿到类引用），窗体/动效
 * 随对应片接入。
 */
@:keep
class Tip extends openfl.display.Sprite {
	public function new() {
		super();
	}
}
