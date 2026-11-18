package entities;

import utest.Assert;

/**
 * Seed 实体映射纯逻辑（issue #7）。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/entities/Seed.as
 *   （构造默认值 :64-82、importObject :84-145、importFromCache :147-174）
 * - legacy/deploy/QFarmFlash/source/core/config/nc/cropstype.php:4（id1 草莓）、
 *   :177（id180 战地之星，带 high_sale:0）
 * - usertool_getseedinfo.php:21 —— 商店回包就是 cropstype 行数组
 *   （array_values($cropstype)），键名与 cropstype 一致
 */
@:final
class SeedTest {
	public function new() {}

	// cropstype.php:4 逐字
	static function strawberry():Dynamic {
		return {
			cId: 1,
			cLevel: 10,
			cName: "草莓",
			cType: 1,
			cropExp: 20,
			expect: 1296,
			growthCycle: 86400,
			maturingTime: 2,
			output: 24,
			price: 605,
			sale: 27
		};
	}

	// Seed.as:90-100 必填键映射
	public function test_importObject_maps_cropstype_row() {
		var seed = new Seed(strawberry());
		Assert.equals(1, seed._id);
		Assert.equals(10, seed._lvl);
		Assert.equals("草莓", seed._name);
		Assert.equals(1, seed._type);
		Assert.equals(20, seed._exp);
		Assert.equals(1296, seed._expect);
		Assert.equals(86400, seed._growCycle);
		Assert.equals(2, seed._matureTime);
		Assert.equals(24, seed._output);
		Assert.equals(605, seed._price);
		Assert.equals(27, seed._sale);
	}

	// Seed.as:67-80 构造默认：可选键没给时保持 -1/""/false
	public function test_optional_keys_absent_keep_ctor_defaults() {
		var seed = new Seed(strawberry());
		Assert.equals(-1, seed._isFood);
		Assert.equals(-1, seed._isRestaurant);
		Assert.equals(-1, seed._isActivity);
		Assert.equals(-1, seed._isMill);
		Assert.equals(-1, seed._isVip);
		Assert.equals(-1, seed._isNew);
		Assert.equals(-1, seed._isAdSeed);
		Assert.equals(-1, seed._high_sale);
		Assert.equals(0, seed._sort);
		Assert.isFalse(seed._isRed);
		Assert.isFalse(seed._isBlack);
		Assert.isFalse(seed._isGreen);
		Assert.equals("", seed._rl);
		Assert.equals("", seed._sellTime);
		Assert.equals("", seed._sellLimit);
		Assert.equals("", seed._sellLimitDaily);
	}

	// cropstype.php:177（id180 战地之星 high_sale:0）：键存在且值为 0 → 写 0，
	// 不是缺省的 -1（Seed.as:113-116 只判断 != undefined）
	public function test_present_high_sale_zero_is_not_default() {
		var seed = new Seed({
			cId: 180, cLevel: 12, cName: "战地之星", cType: 1, cropExp: 25, expect: 1856,
			growthCycle: 111600, high_sale: 0, maturingTime: 2, output: 29, price: 900, sale: 32
		});
		Assert.equals(180, seed._id);
		Assert.equals(0, seed._high_sale);
	}

	// Seed.as:133-144：活动种子三键换名（actPeroid→_sellTime、
	// actProvideAmt→_sellLimitDaily、actTotalAmt→_sellLimit；值合成，出处即这三行）
	public function test_activity_keys_map_to_sell_fields() {
		var seed = new Seed({
			cId: 210, cLevel: 0, cName: "活动种", cType: 1, cropExp: 0, expect: 0,
			growthCycle: 36000, maturingTime: 1, output: 10, price: 100, sale: 10,
			actPeroid: "2010-11-11|2010-11-12", actProvideAmt: "10", actTotalAmt: "100"
		});
		Assert.equals("2010-11-11|2010-11-12", seed._sellTime);
		Assert.equals("10", seed._sellLimitDaily);
		Assert.equals("100", seed._sellLimit);
	}

	// Seed.as:86-89：null 直接返回，默认值不动
	public function test_null_import_keeps_defaults() {
		var seed = new Seed(null);
		Assert.equals(-1, seed._isFood);
		Assert.equals(0, seed._sort);
		Assert.equals("", seed._rl);
	}

	// Seed.as:147-174：importFromCache 按下划线字段名整体拷贝
	//（值合成；_isFood 0 / _isActivity 1 / _sort 2 / _high_sale 54）
	public function test_importFromCache_copies_all_cached_fields() {
		var seed = new Seed(strawberry());
		seed.importFromCache({
			_id: 5, _lvl: 4, _name: "土豆", _type: 1, _exp: 20, _expect: 432,
			_growCycle: 54000, _matureTime: 1, _output: 18, _price: 188, _sale: 24,
			_isFood: 0, _isRestaurant: -1, _isActivity: 1, _isMill: 0, _sort: 2,
			_isRed: true, _isBlack: false, _isVip: -1, _high_sale: 54, _vipDesc: "vip"
		});
		Assert.equals(5, seed._id);
		Assert.equals("土豆", seed._name);
		Assert.equals(0, seed._isFood);
		Assert.equals(1, seed._isActivity);
		Assert.equals(2, seed._sort);
		Assert.isTrue(seed._isRed);
		Assert.equals(54, seed._high_sale);
		Assert.equals("vip", seed._vipDesc);
	}

	// Seed.as:149-152：null 直接返回
	public function test_importFromCache_null_is_noop() {
		var seed = new Seed(strawberry());
		seed.importFromCache(null);
		Assert.equals("草莓", seed._name);
		Assert.equals(1, seed._id);
	}
}
