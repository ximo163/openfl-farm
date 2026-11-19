package entities;

import haxe.Json;
import utest.Assert;

/**
 * Player 实体的解析/等级/克隆纯逻辑（issue #8）。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/entities/Player.as
 * （ctor 默认值 :54-64、fid/exportObject 已随 V3a 翻译、level :75-78、
 * expToGrade :96-99、importObject :101-141、clone :143-165）。
 * 期望数值取自 test/fixtures/uid1_user_run.json 的 user 块（CI 旧后端快照
 * uid=1 的 user&act=run 真实下发，issue 点名）。
 */
class PlayerTest {
	public function new() {}

	// fixture user 块：canbad=50/exp=0/missionTime=1794915896/money=0/FB=0/
	// moralexp=0/pf=1/uId=1/uinLogin=1/userName="admin"/yellowlevel=0/
	// yellowstatus=0/healthMode 在；无 userId、无 lvup 键
	static function fixtureUser():Dynamic {
		return Json.parse(sys.io.File.getContent("test/fixtures/uid1_user_run.json")).user;
	}

	// Player.as:54-64：先落默认值（me=true/sort=0/uin=0/pf2=true/:55 附近
	// _userId=0）再 importObject(param1)（null 早退）+ _rawData 存参（:63）
	public function test_constructor_defaults_match_as3() {
		var p = new Player(null);
		Assert.isTrue(p.me);
		Assert.equals(0, p.sort);
		Assert.equals(0, p.uin);
		Assert.isTrue(p.pf2);
		Assert.equals(0, p._userId);
		Assert.isNull(p._rawData); // null 入参原样存
		Assert.isNull(p._levelup); // lvup 缺省 → null（:132-139）
	}

	// importObject :101-141：uid=1 真实下发的逐键映射（:107 canbad、:108 exp、
	// :109 missionTime、:111 FB、:112 pf、:113 uId、:114 uinLogin、:115-117
	// yellowlevel/yellowstatus/moralexp、:118-121 userId 仅键在才写、
	// :124-127 healthMode、:132-139 lvup）；:140 uin 跟 _uinLogin。
	// exportObject（V3a 已实现）的跨壳键集顺带钉住
	public function test_importObject_maps_uid1_fixture_user_block() {
		var p = new Player(fixtureUser());
		Assert.equals(1, p._uId); // :113
		Assert.equals("admin", p._userName); // :123
		Assert.equals(0, p._exp); // :108
		Assert.equals(1, p._pf); // :112
		Assert.equals(50, p._canbad); // :107
		Assert.equals(1794915896, p._missionTime); // :109
		Assert.equals(0, p._fb); // :111
		Assert.equals(0, p._yellowlevel); // :115
		Assert.equals(0, p._yellowstatus); // :116
		Assert.equals(0, p._moralExp); // :117
		Assert.equals(1, p._uinLogin); // :114
		Assert.equals(1, p.uin); // :140 uin = _uinLogin
		Assert.equals(0, p._money); // :110 parseFloat
		Assert.equals(0, p._userId); // 键不在 → 保持默认
		Assert.isTrue(p._healthMode != null); // :124-127 实体化
		Assert.isNull(p._levelup); // :132-139 lvup 缺省
		Assert.equals(0, p.level); // exp=0 → expToGrade(0)=0

		var exported = p.exportObject();
		Assert.equals(1, Reflect.field(exported, "uId"));
		Assert.equals("admin", Reflect.field(exported, "userName"));
		Assert.equals(1, Reflect.field(exported, "pf"));
		Assert.isTrue(Reflect.hasField(exported, "money"));
		Assert.isTrue(Reflect.hasField(exported, "yellowlevel"));
	}

	// level :75-78 → expToGrade :96-99：Math.sqrt((exp+25)/100)-0.5 截断回
	// int。75 → 0.5→0（截断非四舍五入）；375 → 1.5→1；875 → 2.5→2；
	// 1525 → ≈3.437→3
	public function test_level_formula_truncates_sqrt_grade() {
		var p = new Player(null);
		p._exp = 75;
		Assert.equals(0, p.level);
		p._exp = 375;
		Assert.equals(1, p.level);
		p._exp = 875;
		Assert.equals(2, p.level);
		p._exp = 1525;
		Assert.equals(3, p.level);
		Assert.equals(0, new Player(null).level); // exp 默认 0 → sqrt(0.25)-0.5 = 0
	}

	// clone :143-165：拷贝清单 = canbad/exp/missionTime/money/pf/uId/uinLogin/
	// yellowlevel/yellowstatus/headPic/userName/healthMode（:157 深克隆）/
	// userId/moralExp/me/sort/uin/pf2；清单外（_levelup/_fb/_rawData）不带走
	public function test_clone_copies_identity_fields_only() {
		var p = new Player(fixtureUser());
		p.me = false;
		p.sort = 4;
		p._levelup = ["lv"];
		p._fb = 5;
		var c = p.clone();
		Assert.equals("admin", c._userName);
		Assert.equals(1, c._uId);
		Assert.equals(50, c._canbad);
		Assert.equals(1794915896, c._missionTime);
		Assert.isFalse(c.me);
		Assert.equals(4, c.sort);
		Assert.equals(1, c.uin);
		Assert.isTrue(c.pf2);
		Assert.equals(0, c._userId);
		Assert.isTrue(c._healthMode != null);
		Assert.isNull(c._levelup); // 不在 :146-163 拷贝清单
		Assert.equals(0, c._fb); // 同上
		Assert.isNull(c._rawData); // 同上
	}
}
