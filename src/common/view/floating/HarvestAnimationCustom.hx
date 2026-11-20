package common.view.floating;

/**
 * common.view.floating.HarvestAnimationCustom —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 自定义收获飘字（HarvestAnimationCustom.as）；FarmStage 建层时按 Consts 注册进控件表，本片只保类形态
 * （@:keep 防 dce，供 register/Type.resolveClass 拿到类引用），窗体/动效
 * 随对应片接入。issue #9 write-tests：ctor 补成原版
 * FloatingBase(param1) 签名（#7 壳误写为无参）。
 */
@:keep
class HarvestAnimationCustom extends FloatingBase {
	public function new(param1:interfaces.IMsgCenter) {
		super(param1);
	}
}
