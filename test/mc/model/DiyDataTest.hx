package mc.model;

import mc.model.DiyData;
import utest.Assert;

/**
 * mc.model.DiyData 纯逻辑（issue #87 write-tests——本类成员面即真身，
 * src/mc/model/DiyData.hx 已完整翻译，本测试直接绿）：牧场 DIY 数据
 * 单例——getInstance 同一性、currentDiy 缺省 false 与可写。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/model/DiyData.as
 * —— currentDiy 初值 false :8；getInstance :15-23（instance null 才
 * new，此后恒返同一实例）。
 *
 * 单例态跨测试污染：currentDiy 是 public 直写位——setup 复位 false。
 */
class DiyDataTest {
	public function new() {}

	function setup() {
		DiyData.getInstance().currentDiy = false;
	}

	// 单例同一性（DiyData.as:15-23）
	public function test_getInstance_identity() {
		Assert.equals(DiyData.getInstance(), DiyData.getInstance());
	}

	// currentDiy 缺省 false（:8）
	public function test_currentDiy_default_false() {
		Assert.isFalse(DiyData.getInstance().currentDiy);
	}

	// currentDiy 可写（public 位直写直读）
	public function test_currentDiy_settable() {
		var dd = DiyData.getInstance();
		dd.currentDiy = true;
		Assert.isTrue(dd.currentDiy);
		dd.currentDiy = false;
		Assert.isFalse(dd.currentDiy);
	}
}
