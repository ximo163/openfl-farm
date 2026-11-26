package mc.view.main.shield;

import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.TextEvent;
import openfl.text.TextField;

/**
 * mc.view.main.shield.InitLoading —— InitLoading.as 的签名面 stub（原类
 * 55 loc，issue #87「护盾层」片充真身）。初始化加载屏：ctor 摆
 * DataLoading(250,10) + "数据初始化中..." 文本（Verdana 14 居中 700x20
 * 不可选，挂 LINK 监听）；errorText 写入 htmlText 并藏 DataLoading；
 * linkClick 按 "reload"/"noreg" 转 mainCommand.run/register。成员签名
 * 逐字取自反编译原文，方法体随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/shield/InitLoading.as。
 */
@:keep
class InitLoading extends Sprite {
	// InitLoading.as:13-15
	private var dataLoading:mc.view.common.DataLoading;
	private var _textField:TextField;

	// InitLoading.as:17-33（ctor 摆 DataLoading + 文本——有显示树副作用，入 stub 掷）
	public function new() {
		super();
		throw new Error("not implemented");
	}

	// InitLoading.as:35-38
	public var errorText(never, set):String;

	private function set_errorText(param1:String):String {
		throw new Error("not implemented");
	}

	// InitLoading.as:40-53
	private function linkClick(param1:TextEvent):Void {
		throw new Error("not implemented");
	}
}
