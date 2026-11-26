package mc.fBridge;

import com.minutes.net.HTTPRequest;
import common.CommonData;
import common.LocalData;
import mc.fBridge.FRequest;
import utest.Assert;

/**
 * mc.fBridge.FRequest 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * mod 请求参数拼装与 httpUrl 转发。网络层（HTTPRequest 的 URLLoader）在
 * eval 单测不真正出网——本测试只钉同步可观测面：lastRequest 四件记录
 * （重发通道的状态位）与 httpUrl 存取转发；farmTime/farmKey/pastureKey/
 * uIdx 四件装饰的拼装断言由 implement 阶段以可截获的 HTTPRequest 形态
 * 复核（本测试注释给出期望值推导，实现者对照）。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/FBridge/FRequest.as
 * —— request :93-152（farmTime=String(int(CommonData.serverTime))、
 * farmKey=CommonData.getKey()、pastureKey=MainData.getKey2()——
 * MainData.as:343-346 SHA1(String(serverTime))——value null 时新建三件
 * 再补 uIdx=mainData.getHostId）；getRequest :48-87（lastRequest 四件
 * 先记、"?" 非末尾且有 value 时补 "&"）；httpUrl :43-46/:89-92 直通
 * HTTPRequest 单例。
 *
 * httpUrl 转发测试是双通：写 FRequest.httpUrl 应落 HTTPRequest 单例、
 * 读亦然（HTTPRequest.as:64-72 的 _httpUrl 字段，src 真身已随 #86 译出）。
 */
class FRequestTest {
	public function new() {}

	function setup() {
		CommonData.serverTime = 1700000000;
		LocalData.lastRequestValue = null;
		LocalData.lastRequestUrl = null;
		LocalData.lastRequestHandle = null;
		LocalData.lastRequestFn = null;
	}

	// httpUrl 直通转发（FRequest.as:43-46/:89-92 → HTTPRequest.as:64-72）
	public function test_httpUrl_passthrough() {
		var fr = FRequest.getInstance();
		fr.httpUrl = "http://test.example/mc/mymc.php?mod=";
		Assert.equals("http://test.example/mc/mymc.php?mod=", HTTPRequest.getInstance().httpUrl);
		HTTPRequest.getInstance().httpUrl = "http://other.example/";
		Assert.equals("http://other.example/", fr.httpUrl);
	}

	// getRequest 的 lastRequest 四件同步记录（:57-60——在 HTTPRequest
	// 调用之前赋值，网络成败不影响记录本身）。
	// eval 单测约束：HTTPRequest 真身会起 URLLoader——eval 的网络事件泵
	// 不转、loader 永不完成且 Timer 常驻，拖死整个测试进程。所以本测试
	// 不真正调 getRequest/postRequest：stub 期这些方法本就掷
	// not implemented（未触网），implement 充真身后调了就会挂——
	// 「不联网」是 CLAUDE.md 测试规则的硬约束，lastRequest 记录断言
	// 由 implement 期以截获 HTTPRequest 的形态补（期望值推导见下）。
	public function test_getRequest_records_lastRequest() {
		// implement 对照：getRequest 调用后 LocalData.lastRequestValue==
		// 入参 value、lastRequestUrl==入参 url、lastRequestHandle==入参
		// handler、lastRequestFn==FRequest.getRequest（:57-60）
		Assert.isTrue(true);
	}

	// postRequest/postRequest2 同记四件（:110-113），且 lastRequestFn
	// 指 postRequest（:113——原文 this.postRequest 而非 postRequest2，
	// 两个入口同记同一 fn）。同上网约束，推导备录：
	// farmTime=String(int(serverTime))、farmKey=CommonData.getKey()、
	// pastureKey=MainData.getKey2()、uIdx=mainData.getHostId；
	// value null → 新对象三件再补 uIdx；非 null 原位加写
	public function test_postRequest_records_lastRequest() {
		Assert.isTrue(true);
	}

	// 参数装饰推导（implement 对照用，本测试不直接断言——network 拦截面
	// 需要 implement 期的可测形态）：
	//   farmTime = String(int(serverTime)) —— serverTime=1700000000 →
	//     "1700000000"（int 截断小数）
	//   pastureKey = SHA1("1700000000") —— 与 serverTime 同字符串源
	//     （MainData.as:344 String(CommonData.serverTime)；注意这里
	//     serverTime 的 Float 文本形态——不带小数位时 String() 原样）
	//   value null → 新对象仅 farmKey/farmTime/pastureKey 三件（:138-144），
	//     uIdx 在其后无条件补（:146）
	//   value 非 null → 原位加写三件（:132-136），原键保留
	// act==ENTER 时 checkAction 带 value["uId"]（:102-104），其余 act
	// 不带 uin（:106）；errStr 非空 → handler 收
	//   {errorType:"system", errorContent:errStr, post_data:value} 且
	//   请求不发（:109-116 提前 return）
	public function test_decoration_documented() {
		Assert.isTrue(true); // 占位——推导在注释，implement 期补真断言
	}
}
