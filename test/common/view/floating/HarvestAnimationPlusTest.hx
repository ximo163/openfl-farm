package common.view.floating;

import common.Session;
import entities.Player;
import utest.Assert;

/**
 * HarvestAnimationPlus 收获加成飘字的好友侧对半拆分纯逻辑（issue #9）。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/floating/
 * HarvestAnimationPlus.as（ctor :34-74 的 Session.me 分支、set text :76-112）。
 * 好友侧偷菜收获总数按偶/奇拆两列：偶数 parseInt 后 /2，两列都写 "+"+半值
 * 并置 _isEven；奇数原样、_isEven=false。
 *
 * 自己农场（me==true）分支取 HarvestPlusB 素材（Utils.getMaterial），eval
 * 无资源走不到——只测好友侧。Session.me 在 ctor 读一次，钉 Session 须在
 * new 之前。
 */
@:access(common.view.floating.HarvestAnimationPlus)
class HarvestAnimationPlusTest {
	public function new() {}

	// FarmLandModelTest 同口径：currentUser._uId == host._uId 即 me
	function pinGuestOnHostFarm():Void {
		var host = new Player({});
		host._uId = 1;
		host._userName = "admin";
		var guest = new Player({});
		guest._uId = 2;
		guest._userName = "guest";
		var s = Session.getInstance();
		s.host = host;
		s.currentUser = guest;
	}

	// :96-105：偶数 8 → :93 parseInt、:96 %2==0 → :101 /2=4，两列
	// "+4"/"+4"（:103-104），_isEven（:105）
	public function test_text_even_total_splits_into_two_halves_on_friend_side() {
		pinGuestOnHostFarm();
		Assert.isFalse(Session.getInstance().me);
		var hap = new HarvestAnimationPlus(null); // 好友分支：两个 TextField，无素材

		hap.text = "8";

		Assert.equals("+4", hap._numText1.text); // :103
		Assert.equals("+4", hap._numText2.text); // :104
		Assert.isTrue(hap._isEven); // :105
	}

	// :106-109：奇数 7 → :94 的原样写入保留、第二列不写、_isEven=false
	public function test_text_odd_total_keeps_raw_text() {
		pinGuestOnHostFarm();
		var hap = new HarvestAnimationPlus(null);

		hap.text = "7";

		Assert.equals("7", hap._numText1.text); // :94 原样写入
		Assert.equals("", hap._numText2.text); // 偶数分支未执行
		Assert.isFalse(hap._isEven); // :109
	}
}
