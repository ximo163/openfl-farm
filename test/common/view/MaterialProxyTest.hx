package common.view;

import utest.Assert;

/**
 * MaterialProxy 素材代理纯逻辑（issue #9）：ctor 尺寸档、内置类型（金币
 * "6"/经验 "7"）与占位类型 "5" 的 loaded 语义、去重早退门。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/MaterialProxy.as
 * （ctor :45-66：small→60 :54、CardsGame→80 :58、其余→120 :62；
 * setContent :106-219：早退门 :118-121、:182 `!= "5"` 门、setGold :234-238 /
 * setExp :291-295 置 _loaded、尾行 :218 currentId=param2）。
 *
 * eval 无资源：金币/经验图标走 Utils.getMaterial → ResourceManager 取类，
 * 取不到得 null，setChildObject 对 null 早退（:441-447）——_loaded 仍按
 * 原版置 true；"5" 不进任何分支，只写 currentType/currentId/_enable。
 * 断言经 @:access 读保护字段。
 */
@:access(common.view.MaterialProxy)
class MaterialProxyTest {
	public function new() {}

	// :52-63：默认 small 档 60×60，big 120×120，CardsGame 80×80
	public function test_ctor_size_dimensions() {
		var small = new MaterialProxy();
		Assert.equals(60, small._w); // :54
		Assert.equals(60, small._h);
		Assert.equals(MaterialProxy.SMALL, small.size); // :240-243

		var big = new MaterialProxy(MaterialProxy.BIG);
		Assert.equals(120, big._w); // :62
		Assert.equals(120, big._h);
		Assert.equals(MaterialProxy.BIG, big.size);

		var cards = new MaterialProxy(MaterialProxy.CARDSGAME);
		Assert.equals(80, cards._w); // :58
		Assert.equals(80, cards._h);
		Assert.equals(MaterialProxy.CARDSGAME, cards.size);
	}

	// :184-187 → setGold :234-238：金币内置位图，_loaded 即置 true；
	// :122-123/:218 记 currentType/currentId
	public function test_setContent_gold_type_marks_loaded() {
		var mp = new MaterialProxy();
		Assert.isFalse(mp.loaded); // ctor :65 初始 false

		mp.setContent("6", 5);

		Assert.isTrue(mp.loaded); // setGold 的 :237
		Assert.equals("6", mp.currentType); // :123
		Assert.equals(5, mp.currentId); // :218 尾行
	}

	// :188-191 → setExp :291-295：经验内置位图同理
	public function test_setContent_exp_type_marks_loaded() {
		var mp = new MaterialProxy();
		mp.setContent("7", 9);
		Assert.isTrue(mp.loaded); // setExp 的 :294
		Assert.equals("7", mp.currentType);
		Assert.equals(9, mp.currentId);
	}

	// :182：类型 "5" 被 `!= "5"` 门挡在所有素材分支外——只记类型/编号，
	// _loaded 保持 false（留待外层另挂内容）
	public function test_setContent_placeholder_type_stays_unloaded() {
		var mp = new MaterialProxy();
		mp.setContent("5", 12);
		Assert.isFalse(mp.loaded); // 没有任何分支置位
		Assert.equals("5", mp.currentType);
		Assert.equals(12, mp.currentId); // :218 尾行仍写
	}

	// :118-121：同 (type, id, enable) 重复 setContent 直接早退——把 _loaded
	// 手工翻回 false 后重放同参，早退使其不再被置回 true
	public function test_setContent_same_type_id_enable_returns_early() {
		var mp = new MaterialProxy();
		mp.setContent("6", 5);
		Assert.isTrue(mp.loaded);

		mp._loaded = false; // 抹掉 setGold 的置位，制造可观察差异
		mp.setContent("6", 5); // 同三元组 → :118-121 早退

		Assert.isFalse(mp.loaded); // setGold 未再执行
	}
}
