package common.view.tip;

import openfl.errors.Error;

/**
 * common.view.tip.CropInfoTip —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 作物信息提示（CropInfoTip.as）；FarmStage 建层时按 Consts 注册进控件表，
 * 本片只保类形态（继承 MouseTip、data 覆写签名），窗体随提示片接入。
 * write-tests（#42）：签名按原文补齐，方法体 throw 待实现。
 */
@:keep
class CropInfoTip extends MouseTip {
	public function new() {
		super();
	}

	// CropInfoTip.as:21-31（data：htmlText 装载，提示片翻译）
	override private function set_data(param1:Dynamic):Dynamic {
		throw new Error("not implemented");
	}
}
