package mc.fBridge;

import common.LocalData;
import mc.fBridge.FeartureManager;
import mc.model.MData;
import utest.Assert;

/**
 * mc.fBridge.FeartureManager 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 按 uin 取模分桶的功能灰度。enter/steal/friendList 三通道同构：
 * uin % mod 落逗号分隔的 a-b 区间表 → 命中返回 tips 文案，否则 null。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/FBridge/FeartureManager.as
 * —— enterMod :15-25、stealMod :27-37、friendListMod :62-72（parameters
 * 键名 pasture_enter/pasture_enter_mod/pasture_enter_tips 等）；checkRange
 * :41-58（param2 非空 && uin 非零 && mod 非零三门、uin%mod、逗号切段、
 * 段内 "a-b" split、StringUtil.trim 后 parseInt 闭区间比较）。
 *
 * uin 注入：MData.getInstance().mainData.host 是可写属性（MainData.as:1174
 * 存取对，src/mc/model/MainData.hx:122-131）——测试直接赋 {uin: N}。
 * 分桶推导：mod=10 时 uin=12345 → 12345%10=5；uin=100 → 0；uin=7 → 7。
 */
class FeartureManagerTest {
	public function new() {}

	function setup() {
		LocalData.parameters = {};
		MData.getInstance().mainData.host = {uin: 12345};
	}

	function teardown() {
		MData.getInstance().mainData.host = null;
		LocalData.parameters = {};
	}

	// enterMod 命中：12345%10=5 落 "3-7" 区间 → 返回 tips 文案
	//（FeartureManager.as:20-24）
	public function test_enterMod_hit_returns_tips() {
		LocalData.parameters = {
			pasture_enter: "0-2,3-7",
			pasture_enter_mod: "10",
			pasture_enter_tips: "牧场维护中，稍后再进"
		};
		Assert.equals("牧场维护中，稍后再进", FeartureManager.enterMod());
	}

	// 未命中：5 不落 "0-2" → null
	public function test_enterMod_miss_returns_null() {
		LocalData.parameters = {
			pasture_enter: "0-2",
			pasture_enter_mod: "10",
			pasture_enter_tips: "牧场维护中，稍后再进"
		};
		Assert.isNull(FeartureManager.enterMod());
	}

	// 边界闭区间（:54 `>=`/`<=`）：mod=10、桶 "5-5" 单点、uin%10=5 命中；
	// "0-4"/"6-9" 的端点邻位 5 不命中
	public function test_checkRange_inclusive_bounds() {
		LocalData.parameters = {
			pasture_enter: "5-5",
			pasture_enter_mod: "10",
			pasture_enter_tips: "hit"
		};
		Assert.equals("hit", FeartureManager.enterMod());
		LocalData.parameters.pasture_enter = "0-4,6-9";
		Assert.isNull(FeartureManager.enterMod());
	}

	// 区间表段内空白经 trim 吸收（:53 StringUtil.trim——"3 - 7" 与 "3-7"
	// 等价）
	public function test_checkRange_trims_whitespace() {
		LocalData.parameters = {
			pasture_enter: " 3 - 7 ",
			pasture_enter_mod: "10",
			pasture_enter_tips: "hit"
		};
		Assert.equals("hit", FeartureManager.enterMod());
	}

	// 三门缺一即 false（:47）：range 空串 / mod 0 / 缺键 → null
	public function test_missing_params_return_null() {
		// 全无
		Assert.isNull(FeartureManager.enterMod());
		// 有 range 无 mod（int(null)=0 → Boolean(0)=false）
		LocalData.parameters = {pasture_enter: "0-9"};
		Assert.isNull(FeartureManager.enterMod());
		// mod=0
		LocalData.parameters = {pasture_enter: "0-9", pasture_enter_mod: "0"};
		Assert.isNull(FeartureManager.enterMod());
	}

	// uin 取模落桶：uin=100 mod=10 → 0 号桶；uin=7 mod=10 → 7 号桶
	public function test_mod_buckets() {
		LocalData.parameters = {
			pasture_enter: "0-0",
			pasture_enter_mod: "10",
			pasture_enter_tips: "hit"
		};
		MData.getInstance().mainData.host = {uin: 100};
		Assert.equals("hit", FeartureManager.enterMod());
		MData.getInstance().mainData.host = {uin: 7};
		Assert.isNull(FeartureManager.enterMod());
	}

	// stealMod/friendListMod 同构通道、键名各异（:30-36/:64-70）
	public function test_steal_and_friendList_channels() {
		LocalData.parameters = {
			pasture_steal: "3-7",
			pasture_steal_mod: "10",
			pasture_steal_tips: "偷菜维护中",
			pasture_friend_list: "3-7",
			pasture_friend_list_mod: "10",
			pasture_friend_list_tips: "好友列表维护中"
		};
		Assert.equals("偷菜维护中", FeartureManager.stealMod());
		Assert.equals("好友列表维护中", FeartureManager.friendListMod());
		// 键名隔离：只配 steal 时 enter/friendList 不受影响
		LocalData.parameters = {
			pasture_steal: "3-7",
			pasture_steal_mod: "10",
			pasture_steal_tips: "偷菜维护中"
		};
		Assert.isNull(FeartureManager.enterMod());
		Assert.isNull(FeartureManager.friendListMod());
	}
}
