package;

import openfl.display.Sprite;

/**
 * write-tests 阶段的最小 stub（issue #3）：签名按
 * legacy/decompiled/happyfarm3_v_149/scripts/FarmLite.as（预加载器主文档类），
 * 函数体未实现。构造/setup/boot 及显示相关成员由实现阶段按原版补齐。
 *
 * _mainXML 的原版类型是 AS3 E4H 顶层 XML；openfl 9.5.2 没有这个类（不存在
 * openfl.xml 包），stub 先以 Haxe 标准库 Xml 占位。startLiteUI/onFilesLoadCompleted
 * 里的 E4H 查询（moduleList.module.(@name=="main")）怎么翻由实现阶段定；单测对
 * _mainXML 只判非空（checkStart 的门），赋值走 Reflect，不绑死类型。
 */
class FarmLite extends Sprite {
	// FarmLite.as:48
	private var _bootData:Dynamic;

	// FarmLite.as:52
	private var _mainXML:Xml;

	// FarmLite.as:127-152（单测用子类 override 记录 checkStart 是否放行到这里）
	private function startLiteUI():Void {
		throw new haxe.Exception("not implemented");
	}

	// FarmLite.as:380-387
	private function checkStart():Void {
		throw new haxe.Exception("not implemented");
	}

	// FarmLite.as:448-453
	private function openByFlashVar():Bool {
		throw new haxe.Exception("not implemented");
	}
}
