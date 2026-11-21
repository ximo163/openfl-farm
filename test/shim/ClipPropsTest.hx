package shim;

import utest.Assert;

/**
 * 素材剪辑动态属性侧表的纯逻辑（issue #10 真机闪退修复）。
 *
 * 背景：原版 AS3 在 swf 素材剪辑上随手挂动态属性（ToolBar/NavigationBar/
 * ToolBoxBar 的 tipText、FarmLandController 的 dogTip.effect）。翻译后素材
 * 剪辑是编译类实例：html5/JS 上 Dynamic 裸写还能落自有字段，静态目标
 * （android/cpp）上对不存在的字段写入报 "Invalid field"（真机 logcat：
 * 3 次 Invalid field:tipText 后进程死亡）。ClipProps 用侧表在所有目标给出
 * 同一语义，读写同通道。
 */
class ClipPropsTest extends utest.Test {
	function testSetGetHasRoundtrip() {
		var a:Dynamic = {};
		var b:Dynamic = {};
		ClipProps.set(a, "tipText", "浇水");
		Assert.isTrue(ClipProps.has(a, "tipText"));
		Assert.equals("浇水", ClipProps.get(a, "tipText"));
		Assert.isFalse(ClipProps.has(b, "tipText"));
		Assert.isNull(ClipProps.get(b, "tipText"));
	}

	function testOverwriteSameKey() {
		var a:Dynamic = {};
		ClipProps.set(a, "tipText", "浇水");
		ClipProps.set(a, "tipText", "锄地");
		Assert.equals("锄地", ClipProps.get(a, "tipText"));
	}

	function testObjectsDoNotLeakIntoEachOther() {
		var a:Dynamic = {};
		var b:Dynamic = {};
		ClipProps.set(a, "tipText", "浇水");
		ClipProps.set(b, "tipText", "收获");
		Assert.equals("浇水", ClipProps.get(a, "tipText"));
		Assert.equals("收获", ClipProps.get(b, "tipText"));
	}

	function testMultipleFieldsOnSameObject() {
		var a:Dynamic = {};
		ClipProps.set(a, "tipText", "浇水");
		ClipProps.set(a, "effect", "Move");
		Assert.equals("浇水", ClipProps.get(a, "tipText"));
		Assert.equals("Move", ClipProps.get(a, "effect"));
		Assert.isFalse(ClipProps.has(a, "txt"));
	}
}
