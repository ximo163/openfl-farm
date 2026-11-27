package mc.view.main.windowControl;

import mc.view.main.windowControl.WindowClassLib;
import utest.Assert;

/**
 * mc.view.main.windowControl.WindowClassLib 纯逻辑（issue #87 write-tests，
 * 对 stub 失败）：窗类名→Class 懒注册表——未注册键返 null、register
 * 后 getClass 回取同一 Class。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/main/
 * WindowControl/WindowClassLib.as —— getClass :13-20（_lib null → null；
 * 否则 _lib[param1]——键缺失时 Object 下标返 undefined，Haxe 等价 null）；
 * register :22-25（_lib null 时建 {}，随后 _lib[param1]=param2）。
 *
 * 静态态跨测试污染：_lib 是静态表——用各用例独占的键名（"WclT*"）避免
 * 相互踩踏；键名在测试进程内唯一即无顺序耦合。stub 期 getClass/register
 * 全 throw not implemented——本测试必然等 implement 充真身才绿。
 */
class WindowClassLibTest {
	public function new() {}

	// 未注册键 → null（:19 下标缺失路径；_lib 非空与否不影响该键的
	// 缺失语义——即便静态表已被其他用例填过，本键仍不在内）
	public function test_getClass_unregistered_returns_null() {
		Assert.isNull(WindowClassLib.getClass("WclTneverRegistered"));
	}

	// register → getClass 回取同一 Class（:22-28 建表+写入、:19 读出）
	public function test_register_then_getClass_roundtrip() {
		WindowClassLib.register("WclTFoo", WclTDummyWindow);
		Assert.equals(WclTDummyWindow, WindowClassLib.getClass("WclTFoo"));
	}

	// 多键共存互不覆盖：同表两键各取各的类
	public function test_register_multiple_keys_independent() {
		WindowClassLib.register("WclTA", WclTDummyWindow);
		WindowClassLib.register("WclTB", WclTOtherWindow);
		Assert.equals(WclTDummyWindow, WindowClassLib.getClass("WclTA"));
		Assert.equals(WclTOtherWindow, WindowClassLib.getClass("WclTB"));
	}

	// 同键覆写（:28 无条件赋值语义）：后注册覆盖先注册
	public function test_register_same_key_overwrites() {
		WindowClassLib.register("WclTOW", WclTDummyWindow);
		WindowClassLib.register("WclTOW", WclTOtherWindow);
		Assert.equals(WclTOtherWindow, WindowClassLib.getClass("WclTOW"));
	}

	// 键名大小写敏感（Object 下标语义）：注册 "WclTCase" 不影响 "wcltcase"
	public function test_getClass_case_sensitive() {
		WindowClassLib.register("WclTCase", WclTDummyWindow);
		Assert.isNull(WindowClassLib.getClass("wcltcase"));
	}
}

/** 测试用窗类——只作 Class 令牌，不实例化。 */
class WclTDummyWindow {
	public function new() {}
}

class WclTOtherWindow {
	public function new() {}
}
