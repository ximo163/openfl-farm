package mc.model;

import com.adobe.crypto.SHA1;
import common.CommonData;
import mc.model.MainData;
import utest.Assert;

/**
 * mc.model.MainData 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 等级/经验公式互逆、窝棚容量档位、分页 ceil、好友过滤与去重、hostFid/
 * currentFid 的 qzone 分支、getKey2 的 SHA1 时间戳。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/model/MainData.as
 * —— gradeToExp :401-404（100*n*(n+1)）；expToGrade :893-896
 * （sqrt((exp+25)/100)-0.5）；getAnimalNum :859-885（>=8→10；窝：1→2、
 * 2→3、>=3→n+2；棚&&!=0→n+2；else 0）；showFriendSum :491-506（空搜索
 * 用 friendList、否则 filterFriendList，ceil(len/friendPageNum)，0→1）；
 * friendPageNum :1354-1357（恒 10）；friendFilter :1211-1215（userName
 * 正则 `.*?value.*` i）、friendFilterByUin :549-552（uin 同型正则）；
 * filterFriendList :1333-1341（userName 过滤 + qzone 追加 uin 过滤、
 * uniq 去重）；uniq :1051-1066（按 uId 去重、保序）；hostFid :898-905
 * （Version.value=="qzone" → host.uin 否则 host.uId）；getKey2 :343-346
 * （SHA1(String(serverTime))）；me :1140-1149（currentUser/host 双非空
 * 且 uId 不同才 false）。
 *
 * Version.value 在测试环境恒 ""（src/mc/control/Version.hx:26-30 的
 * PORT-NOTE——INI version value 生产即空串）——hostFid/currentFid 的
 * qzone 分支因此在本测试环境不可达，只钉 uId 分支；分支真值表在注释
 * 备录，implement 若改 Version 注入形态需回补。
 */
class MainDataTest {
	var md:MainData;

	public function new() {}

	function setup() {
		md = new MainData();
		md.friendList = null;
		md.searchFriendValue = "";
		md.host = null;
		md.currentUser = null;
		CommonData.serverTime = 1700000000;
	}

	// gradeToExp（MainData.as:401-404——#19 已译真身，钉回归）：
	// 100*n*(n+1)
	public function test_gradeToExp() {
		Assert.equals(0, md.gradeToExp(0));
		Assert.equals(200, md.gradeToExp(1));
		Assert.equals(600, md.gradeToExp(2));
		Assert.equals(1200, md.gradeToExp(3));
		Assert.equals(4200, md.gradeToExp(6));
	}

	// expToGrade（:893-896）：sqrt((exp+25)/100)-0.5——与 gradeToExp 在
	// 整数等级点互逆：grade n 的门槛经验 100n(n+1) 反解恰得 n
	public function test_expToGrade_inverse_at_thresholds() {
		// exp=200（grade1 门槛）：sqrt(225/100)-0.5 = 1.5-0.5 = 1
		Assert.equals(1, md.expToGrade(200));
		// exp=600：sqrt(625/100)-0.5 = 2.5-0.5 = 2
		Assert.equals(2, md.expToGrade(600));
		// exp=1200：sqrt(1225/100)-0.5 = 3.5-0.5 = 3
		Assert.equals(3, md.expToGrade(1200));
		// 门槛间取整：exp=199 → sqrt(224/100)-0.5 ≈ 1.4966-0.5 = 0.9966 → int 0
		Assert.equals(0, md.expToGrade(199));
		// exp=0 → sqrt(0.25)-0.5 = 0
		Assert.equals(0, md.expToGrade(0));
	}

	// getAnimalNum（:859-885）档位表
	public function test_getAnimalNum_table() {
		// >=8 恒 10（不分窝棚）
		Assert.equals(10, md.getAnimalNum(8, "窝"));
		Assert.equals(10, md.getAnimalNum(9, "棚"));
		Assert.equals(10, md.getAnimalNum(100, "窝"));
		// 窝：1→2、2→3、>=3→n+2
		Assert.equals(2, md.getAnimalNum(1, "窝"));
		Assert.equals(3, md.getAnimalNum(2, "窝"));
		Assert.equals(5, md.getAnimalNum(3, "窝"));
		Assert.equals(9, md.getAnimalNum(7, "窝"));
		// 棚 && !=0 → n+2
		Assert.equals(3, md.getAnimalNum(1, "棚"));
		Assert.equals(9, md.getAnimalNum(7, "棚"));
		// 棚 0 级 → 0（!=0 门）
		Assert.equals(0, md.getAnimalNum(0, "棚"));
		// 窝 0 级 → 0（窝分支 1/2/>=3 全不落，落穿 return 0）
		Assert.equals(0, md.getAnimalNum(0, "窝"));
	}

	// getKey2（:343-346）= SHA1(String(serverTime))；期望值用同库
	// SHA1.hash 对同一锚点求值（SHA1 本身有独立测试钉 RFC 向量，
	// test/com/adobe/crypto/SHA1Test.hx）
	public function test_getKey2_sha1_of_server_time() {
		CommonData.serverTime = 1700000000;
		var expect = SHA1.hash("1700000000");
		Assert.equals(expect, MainData.getKey2());
	}

	// friendPageNum 恒 10（:1376-1379）
	public function test_friendPageNum_is_10() {
		Assert.equals(10, md.friendPageNum);
	}

	// showFriendSum（:491-506）：null 列表 → 1；空搜索按 friendList 长度
	// ceil 分页；0 页钳回 1
	public function test_showFriendSum_pages() {
		Assert.equals(1, md.showFriendSum); // friendList null → 1
		md.friendList = [];
		Assert.equals(1, md.showFriendSum); // 0/10 ceil=0 → 钳 1
		md.friendList = [for (i in 0...10) {uId: "u" + i, userName: "n" + i, uin: "1" + i}];
		Assert.equals(1, md.showFriendSum); // 10/10=1
		md.friendList = [for (i in 0...11) {uId: "u" + i, userName: "n" + i, uin: "1" + i}];
		Assert.equals(2, md.showFriendSum); // ceil(11/10)=2
		md.friendList = [for (i in 0...25) {uId: "u" + i, userName: "n" + i, uin: "1" + i}];
		Assert.equals(3, md.showFriendSum); // ceil(25/10)=3
	}

	// 搜索态下分页按 filterFriendList 长度（:497-500）
	public function test_showFriendSum_search_uses_filtered() {
		md.friendList = [for (i in 0...25) {uId: "u" + i, userName: (i < 12 ? "张" : "李") + i, uin: "1" + i}];
		md.searchFriendValue = "张";
		Assert.equals(2, md.showFriendSum); // 12 张 → ceil(12/10)=2
	}

	// friendFilter（:1211-1215）：userName 正则 `.*?value.*` 不区分大小写
	// ——子串命中即真（前后任意字符），大小写不敏感
	public function test_filterFriendList_by_username() {
		md.friendList = [
			{uId: "u1", userName: "张三", uin: "101"},
			{uId: "u2", userName: "张四", uin: "102"},
			{uId: "u3", userName: "李五", uin: "103"},
			{uId: "u4", userName: "abc", uin: "104"},
			{uId: "u5", userName: "ABC", uin: "105"}
		];
		md.searchFriendValue = "张";
		var out = md.filterFriendList;
		Assert.equals(2, out.length);
		Assert.equals("u1", out[0].uId);
		Assert.equals("u2", out[1].uId);
		// 大小写不敏感（"i" 标志）
		md.searchFriendValue = "abc";
		out = md.filterFriendList;
		Assert.isTrue(out.length >= 2);
	}

	// uniq（:1051-1066）：按 uId 去重保序——同名 userName 与 uin 双通道
	// 命中同一好友时不出两份（qzone 追加 uin 过滤的去重收益）
	public function test_filterFriendList_uniq_dedup() {
		md.friendList = [
			{uId: "u1", userName: "张三", uin: "101"},
			{uId: "u2", userName: "李四", uin: "102"}
		];
		md.searchFriendValue = "张";
		// userName 命中 u1；若 uin 通道也命中 u1（正则同串），uniq 后仍一份。
		// Version.value 在测试环境恒 ""（非 qzone）——uin 通道不进 concat，
		// 本测试钉的是 uniq 本身的幂等：结果恰一份 u1。
		var out = md.filterFriendList;
		Assert.equals(1, out.length);
		Assert.equals("u1", out[0].uId);
	}

	// hostFid（:898-905）：Version.value!=="qzone"（测试环境恒 ""）→ uId
	public function test_hostFid_uId_branch() {
		md.host = {uId: "uid_host", uin: "123456"};
		Assert.equals("uid_host", md.hostFid);
	}

	// currentFid 同构（currentUser 侧）
	public function test_currentFid_uId_branch() {
		md.currentUser = {uId: "uid_cur", uin: "654321"};
		Assert.equals("uid_cur", md.currentFid);
	}

	// me（:1140-1149）：双 null → true；双非空 uId 相同 → true；不同 → false；
	// 仅其一 null → true（短路不进比较）
	public function test_me_truth_table() {
		Assert.isTrue(md.me); // 双 null
		md.host = {uId: "a"};
		Assert.isTrue(md.me); // currentUser null
		md.currentUser = {uId: "a"};
		Assert.isTrue(md.me); // uId 相同
		md.currentUser = {uId: "b"};
		Assert.isFalse(md.me); // uId 不同
	}

	// searchFriendValue 是 plain 存取（MainData.as:206/232 无派发）
	public function test_searchFriendValue_plain_access() {
		md.searchFriendValue = "abc";
		Assert.equals("abc", md.searchFriendValue);
	}
}
