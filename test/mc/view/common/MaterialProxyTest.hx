package mc.view.common;

import mc.view.common.MaterialProxy;
import utest.Assert;

/**
 * mc.view.common.MaterialProxy 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * ctor 尺寸、setContent 的同参跳过守卫与类型分派记录。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/common/MaterialProxy.as
 * —— ctor :31-34（_w=_h=61）；setContent :228-258（同 type+id+enable 提前
 * return——currentType/currentId 在分派后更新，跳过语义依赖滞后值；类型
 * 分派表："1"→setCrop("Seed"+id)、"11"→setCrop2、"4"/"7"→setTool(id,type)、
 * "5"→setWareHouse(idToWareName)、"6_6"→setGold、"7_7"→setExp、"25"→
 * setTool2("Food"+id)、"2525"→setTool2x、"5_5"→setTool(id,"5")、"2" 落穿
 * 无操作——`param1 != "2"` 的反括号结构）；素材居中 (w-width)/2（:60-63
 * setCrop 同款各 setXxx）；禁用态灰度 ColorMatrixFilter [0.3086,0.6094,
 * 0.082,...]（:66-70）。
 *
 * 素材通道（MaterialLib 注册表）在测试环境为空——setXxx 取不到素材提前
 * return，装配/居中/滤镜面不可达；本测试钉不依赖素材的面：ctor 尺寸、
 * 跳过守卫的 currentType/currentId 滞后更新语义、缺失素材不炸。
 * 居中/灰度的真值由 implement 期画面比对门禁负责（fixture 素材入库前
 * 单测不可证——见 CLAUDE.md 测试规则「显示层不在单测证明」）。
 */
@:access(mc.view.common.MaterialProxy)
class MaterialProxyTest {
	public function new() {}

	// ctor 尺寸（MaterialProxy.as:31-34——字段声明 60、ctor 覆写 61）
	public function test_ctor_size_is_61() {
		var mp = new MaterialProxy();
		Assert.equals(61, mp._w);
		Assert.equals(61, mp._h);
	}

	// 初态（:17-29）：currentType ""/currentId 0/_enable true
	public function test_initial_state() {
		var mp = new MaterialProxy();
		Assert.equals("", mp.currentType);
		Assert.equals(0, mp.currentId);
		Assert.isTrue(mp._enable);
	}

	// 同参跳过（:229-232）：首次 setContent("1",5) 后 currentType/currentId
	// 记录为 "1"/5；同参再调提前 return——无观察面差异但重入安全；
	// 异参（换 id）更新记录
	public function test_setContent_records_type_and_id() {
		var mp = new MaterialProxy();
		mp.setContent("1", 5);
		Assert.equals("1", mp.currentType);
		Assert.equals(5, mp.currentId);
		mp.setContent("1", 5); // 同参跳过半路——记录不变
		Assert.equals("1", mp.currentType);
		mp.setContent("4", 9);
		Assert.equals("4", mp.currentType);
		Assert.equals(9, mp.currentId);
	}

	// enable 参与跳过判（:229 `param3 == this._enable`）：同 type+id 但
	// enable 翻转 → 不跳过（重新走分派——观察面：_enable 更新）
	public function test_enable_participates_in_skip_guard() {
		var mp = new MaterialProxy();
		mp.setContent("1", 5, true);
		Assert.isTrue(mp._enable);
		mp.setContent("1", 5, false); // enable 变 → 不跳过
		Assert.isFalse(mp._enable);
	}

	// "2" 类型落穿无操作（:247 反括号——素材缺失语境下与其他类型同不炸，
	// 但 currentType 照记）
	public function test_type2_falls_through() {
		var mp = new MaterialProxy();
		mp.setContent("2", 5);
		Assert.equals("2", mp.currentType);
	}
}
