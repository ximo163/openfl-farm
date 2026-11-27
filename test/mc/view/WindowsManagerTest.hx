package mc.view;

import mc.view.WindowsManager;
import utest.Assert;

/**
 * mc.view.WindowsManager 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 单例与 leftPane 存取。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/WindowsManager.as
 * —— gi :17-24（懒单例）；leftPane :26-33 plain 存取对。
 */
class WindowsManagerTest {
	public function new() {}

	// gi 单例同一性（WindowsManager.as:17-24）
	public function test_gi_singleton() {
		Assert.equals(WindowsManager.gi(), WindowsManager.gi());
	}

	// leftPane plain 存取（:26-33）——Pane 类型 cn.snowkit.containers.Pane
	// 构造依赖显示链，测试以 null 往返钉通道（stub 期 setter 掷
	// not implemented 即失败，implement 充真身后转绿）
	public function test_leftPane_roundtrip() {
		var wm = WindowsManager.gi();
		wm.leftPane = null;
		Assert.isNull(wm.leftPane);
	}
}
