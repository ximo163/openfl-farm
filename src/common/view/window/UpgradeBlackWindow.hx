package common.view.window;

import common.view.window.BaseWindow;
/**
 * common.view.window.UpgradeBlackWindow —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 黑土地升级分享窗（UpgradeBlackWindow.as，FarmApplication 持单例复用）；FarmStage 建层时按 Consts 注册进控件表，本片只保类形态
 * （@:keep 防 dce，供 register/Type.resolveClass 拿到类引用），窗体/动效
 * 随对应片接入。
 */
@:keep
class UpgradeBlackWindow extends BaseWindow {
	public function new(param1:interfaces.IMsgCenter = null) {
		super(param1);
	}

	// UpgradeBlackWindow.as:68-86（issue #41 write-tests 补签名；万/亿位逗号
	// 分组格式化，待本片 implement）
	private function formatNumber(param1:UInt):String {
		throw new openfl.errors.Error("not implemented");
	}
}
