package entities;

import haxe.Json;
import utest.Assert;

/**
 * FarmLand 实体映射纯逻辑（issue #7）。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/entities/FarmLand.as
 *   （构造 :57-61、importObject 字母键映射 :187-223、copyFrom 全键名映射 :86-185、
 *   bitmap>2 截断 :212-216/:156-159）
 * - legacy/snapshot/initialized.sql:5718 —— uid=1 的 6 块地 status 原始值
 *   （land0 {a:2,b:6,…,k:16,l:9,m:16,q:1794879866,r:1251351720,…}）
 * - legacy/deploy/QFarmFlash/source/core/source/nc/mod/user_run.php:71-79 —— 服务端
 *   对每块地补 bitmap/goldLand（pId 原样），即 test/fixtures/uid1_user_run.json 的
 *   farmlandStatus 形态
 * - legacy/deploy/QFarmFlash/source/core/source/nc/mod/farmlandstatus_harvest.php:95 ——
 *   收获回包里 status 的全键名形态（copyFrom 的真实输入）
 */
@:final
class FarmLandTest {
	public function new() {}

	static function landJson(idx:Int):Dynamic {
		var boot = Json.parse(sys.io.File.getContent("test/fixtures/uid1_user_run.json"));
		return boot.farmlandStatus[idx];
	}

	// FarmLand.as:187-193+199-207：字母键→字段；:206 _updateTime = r - 60*60
	//（snapshot land0 r=1251351720 → 1251348120）
	public function test_importObject_maps_snapshot_land0_letter_keys() {
		var land = new FarmLand(landJson(0));
		Assert.equals(2, land._cId); // a
		Assert.equals(6, land._cropStatus); // b
		Assert.equals(0, land._weed); // f
		Assert.equals(0, land._pest); // g
		Assert.equals(1, land._humidity); // h
		Assert.equals(100, land._health); // i
		Assert.equals(0, land._harvestTimes); // j
		Assert.equals(16, land._output); // k
		Assert.equals(9, land._min); // l
		Assert.equals(16, land._left); // m
		Assert.equals(1794879866, land._plantTime); // q
		Assert.equals(1251351720 - 3600, land._updateTime); // r（:206 减 60*60）
		Assert.equals(0, land._bitmap); // bitmap
		Assert.equals(0, land._pId);
		Assert.equals(0, land._oldweed); // c
		Assert.equals(0, land._oldpest); // d
		Assert.equals(1, land._oldhumidity); // e
	}

	// FarmLand.as:203-204：n 未定义→{}、p 未定义→null；snapshot 里 n/p 都给的是
	// 空数组 → 原样引用（数组本体）
	public function test_importObject_thief_and_action_defaults() {
		var withArrays = new FarmLand(landJson(0));
		Assert.isTrue(Std.is(withArrays._thief, Array)); // n:[] 原样
		Assert.isTrue(Std.is(withArrays._action, Array)); // p:[] 原样

		var bare = new FarmLand({a: 1, b: 1, q: 100, r: 200, bitmap: 0, pId: 0});
		Assert.isTrue(!Std.is(bare._thief, Array)); // n 缺省 → {}
		Assert.equals(null, bare._action); // p 缺省 → null
	}

	// FarmLand.as:212-216：bitmap > 2 截到 2（合成值，行为出处即这两行）
	public function test_importObject_clamps_bitmap_above_two() {
		Assert.equals(2, new FarmLand({a: 1, bitmap: 3})._bitmap);
		Assert.equals(2, new FarmLand({a: 1, bitmap: 5})._bitmap);
		Assert.equals(1, new FarmLand({a: 1, bitmap: 1})._bitmap);
	}

	// FarmLand.as:189-191：null 直接返回，字段保持默认（int→0）
	public function test_importObject_null_is_noop() {
		var land = new FarmLand(null);
		Assert.equals(0, land._cId);
		Assert.equals(0, land._output);
		Assert.equals(null, land._thief);
	}

	// snapshot land1 f:1（杂草）、land3 g:2（害虫）、land2 h:0（缺水）
	public function test_importObject_maps_weed_pest_humidity_per_land() {
		Assert.equals(1, new FarmLand(landJson(1))._weed);
		Assert.equals(2, new FarmLand(landJson(3))._pest);
		Assert.equals(0, new FarmLand(landJson(2))._humidity);
	}

	// farmlandstatus_harvest.php:95 的 status 形态（全键名）→ copyFrom :92-163；
	// :130 leavings→_left、:148-151 updateTime-3600、值取 snapshot land0
	public function test_copyFrom_maps_harvest_status_full_keys() {
		var land = new FarmLand(landJson(0));
		var status = {
			action: [],
			bitmap: 0,
			cId: 2,
			cropStatus: 6,
			fertilize: 0,
			harvestTimes: 0,
			health: 100,
			humidity: 1,
			leavings: 16,
			min: 9,
			oldhumidity: 1,
			oldpest: 0,
			oldweed: 0,
			output: 16,
			pId: 0,
			pest: 0,
			plantTime: 1794879866,
			thief: {},
			updateTime: 1251351720,
			weed: 0
		};
		land.copyFrom(status);
		Assert.equals(2, land._cId);
		Assert.equals(6, land._cropStatus);
		Assert.equals(100, land._health);
		Assert.equals(16, land._left); // leavings
		Assert.equals(9, land._min);
		Assert.equals(16, land._output);
		Assert.equals(1251351720 - 3600, land._updateTime);
		Assert.equals(1, land._oldhumidity); // :177-180 原样拷贝
		Assert.isTrue(!Std.is(land._thief, Array)); // thief:{}（对象）
	}

	// copyFrom :92-131：键缺省的字段不动（条件赋值）；:136-139 thief 缺省补 {}
	public function test_copyFrom_partial_update_only_touched_fields() {
		var land = new FarmLand(landJson(0));
		land.copyFrom({humidity: 0});
		Assert.equals(0, land._humidity);
		Assert.equals(16, land._output); // 未给 output → 保持
		Assert.equals(16, land._left); // 未给 leavings → 保持
		Assert.isTrue(Std.is(land._action, Array)); // action 未给 → 保持原数组
		Assert.equals(0, Reflect.fields(land._thief).length); // thief 缺省 → {}
	}

	// copyFrom :88-91：null 直接返回
	public function test_copyFrom_null_is_noop() {
		var land = new FarmLand(landJson(0));
		land.copyFrom(null);
		Assert.equals(1, land._humidity);
		Assert.equals(16, land._output);
	}

	// copyFrom :152-159：bitmap 截断同样生效（值合成，出处即这两行）
	public function test_copyFrom_clamps_bitmap_above_two() {
		var land = new FarmLand(landJson(0));
		land.copyFrom({bitmap: 4});
		Assert.equals(2, land._bitmap);
	}
}
