package module.mainScene.farmLand.widgets;

import openfl.display.DisplayObjectContainer;
import openfl.errors.Error;

/**
 * module.mainScene.farmLand.widgets.Byproduct —— V3b 翻译，issue #8 write-tests
 * 签名 stub（原版 157 loc > 100，issue 闭包规则走 stub）。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/widgets/Byproduct.as
 * 只声明测试断言用到的字段（_insect/_weed，:10/:20）与 clear（:58，clearAll 链）；
 * insect/weed 的 AS3 setter（:114/:119，min(3,·) 后 updateInsect/updateWeed 播草/虫）
 * 随 V3b 整类翻译补齐——setter 体里无素材环境会死循环（numChildren 永不增长），
 * 测试只碰计数 0 的路径。
 */
@:keep
class Byproduct {
	// Byproduct.as:10/:20（计数，测试经 @:access 读）
	private var _insect:Int;
	private var _weed:Int;

	// Byproduct.as:24-32（ctor：建虫/草精灵容器）
	public function new(param1:DisplayObjectContainer) {
		throw new Error("not implemented");
	}

	// Byproduct.as:58-75（clear：移除全部虫/草精灵）
	public function clear():Void {
		throw new Error("not implemented");
	}
}
