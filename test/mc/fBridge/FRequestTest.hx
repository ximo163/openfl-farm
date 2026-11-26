package mc.fBridge;

import com.minutes.net.HTTPRequest;
import common.CommonData;
import common.LocalData;
import mc.fBridge.FRequest;
import mc.fBridge.RequestManager;
import support.RecordingRequest;
import utest.Assert;

/**
 * mc.fBridge.FRequest 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * mod 请求参数拼装、httpUrl 转发、熔断早退与 getRequest 的 lastRequest 四件。
 *
 * 网络层（HTTPRequest 真身起 URLLoader）在 eval 单测不联网（CLAUDE.md 测试
 * 规则）——本测试用 support/RecordingRequest（Type.createEmptyInstance 构造，
 * 跳过真身 ctor 的单例守卫与常驻 Timer(1000).start()）经 @:access 置换
 * HTTPRequest.instance 截获 postRequest/getRequest 入参，从而把 FRequest
 * 的装饰段/getRequest 同步面完整钉住，**不再是注释备录的占位**。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/FBridge/FRequest.as
 * —— request :93-152：try 段 RequestManager.checkAction（act==ENTER 带
 * value["uId"]、其余 act 不带——:102-106）；errStr 非空 → handler 收
 * {errorType:"system", errorContent:errStr, post_data:value} 且**提前
 * return、请求不发**（:109-116）；随后才记 lastRequest 四件（:118-121）
 * 再做装饰：farmTime=String(int(serverTime))、farmKey=CommonData.getKey()、
 * pastureKey=MainData.getKey2()（MainData.as:343-346 SHA1(String(serverTime))）
 * ——value null → 新对象三件再补 uIdx=mainData.getHostId（:138-146）；非
 * null 原位加写。getRequest :48-87（lastRequest 四件在 HTTPRequest 调用
 * 之前赋值 :57-60；"?" 非末尾且有 value 时 url 补 "&" :62-65）。
 *
 * serverTime 锚点漂移（CommonData.as:141-148——setter 记锚+clientTime、
 * getter 叠 floor(getTimer()/1000)-_clientTime 整数秒漂移）：测试 setup
 * 重锚 1700000000，锚点 floor 漂移极慢（数十秒内不变），断言
 * farmTime="1700000000" 采用 MainDataTest.test_getKey2 同款的定点钉法
 * （SHA1 期望值同锚点推算）；若同 suite 内漂移跨秒则转 implement 调整，
 * 属已知 eval 时间面耦合，与 #87 逻辑无关。
 */
@:access(com.minutes.net.HTTPRequest)
@:access(mc.fBridge.RequestManager)
class FRequestTest {
	var savedInstance:HTTPRequest;
	var rec:RecordingRequest;

	public function new() {}

	function setup() {
		CommonData.serverTime = 1700000000;
		LocalData.lastRequestValue = null;
		LocalData.lastRequestUrl = null;
		LocalData.lastRequestHandle = null;
		LocalData.lastRequestFn = null;
		savedInstance = null;
		rec = null;
	}

	function teardown() {
		// 归还截获的单例，避免跨用例污染
		if (savedInstance != null) {
			HTTPRequest.instance = savedInstance;
			savedInstance = null;
		}
		if (rec != null) {
			rec = null;
		}
	}

	// 截获换入：用 Type.createEmptyInstance 跳过真身 ctor（单例守卫 +
	// 常驻 Timer(1000).start()——RecordingRequest.hx 类头注释），经 @:access
	// 写入 HTTPRequest.instance 私有静态位
	function swapInRecorder():RecordingRequest {
		savedInstance = HTTPRequest.instance;
		var r:RecordingRequest = cast Type.createEmptyInstance(RecordingRequest);
		HTTPRequest.instance = r;
		return r;
	}

	// httpUrl 直通转发（FRequest.as:43-46/:89-92 → HTTPRequest.as:64-72）
	public function test_httpUrl_passthrough() {
		var fr = FRequest.getInstance();
		fr.httpUrl = "http://test.example/mc/mymc.php?mod=";
		Assert.equals("http://test.example/mc/mymc.php?mod=", HTTPRequest.getInstance().httpUrl);
		HTTPRequest.getInstance().httpUrl = "http://other.example/";
		Assert.equals("http://other.example/", fr.httpUrl);
	}

	// —— 熔断早退（:102-116）：act 触发 checkAction 封禁 → handler 收
	// {errorType:"system", errorContent, post_data:value}，**不发请求、
	// 不记 lastRequest**。RequestManager 的 uinList 直接布置封禁态并预置
	// record:true（绕过 EventRecorder 上报——recordErrorEvent 是 no-qq-
	// telemetry 已禁用通道，预置键让 !…["record"] 为 false 跳过其调用）。
	// 用 ENTER + value.uId 路径同时验证 checkAction(act, value["uId"]) 的
	// 双参调用形态（:104）
	public function test_circuit_breaker_early_exit() {
		// 布置 RequestManager 的 ENTER 封禁态（uinList["999"]，blocking 未来）
		var rm = RequestManager.getInstance();
		rm.uinList = {};
		var t = CommonData.serverTime;
		Reflect.setField(rm.uinList, "999", {errNum: 3, blocking: t + 450, record: true});

		rec = swapInRecorder();
		var received:Dynamic = null;
		var callCount = 0;
		FRequest.getInstance().postRequest("http://x/?mod=cgi_enter", {uId: "999", op: 1}, function(res:Dynamic) {
			received = res;
			callCount++;
		}, RequestManager.ENTER);

		Assert.equals(1, callCount);
		Assert.notNull(received);
		Assert.equals("system", Reflect.field(received, "errorType"));
		// 文案 ceil((blocking-serverTime)/60)=ceil(450/60)=8，ENTER 变体
		// "分钟后再访问该好友。"（RequestManager.as:96）
		Assert.equals("系统太忙，建议8分钟后再访问该好友。", Reflect.field(received, "errorContent"));
		Assert.equals("999", Reflect.field(Reflect.field(received, "post_data"), "uId"));
		// 早退在 HTTPRequest 之前（:115 return）——截获计数 0
		Assert.equals(0, rec.postCount);
		// 早退在 lastRequest 记录之前（:118 不达）——setup 已清 null
		Assert.isNull(LocalData.lastRequestValue);
	}

	// —— 参数装饰四件（:126-146）：act=null（sendRequest 调用形态——
	// AppHelper.sendRequest 不带 act，FRequestTest 直接复现）跳过熔断，
	// 经装饰后发往 HTTPRequest。value 非 null → 原位加写 farmTime/farmKey/
	// pastureKey 三件再补 uIdx（原键保留）；farmTime=String(int(serverTime))
	// 锚点 1700000000 → "1700000000"。CommonData.getKey 是 Dynamic 函数位
	// （src/common/CommonData.hx:42），用测试函数桩住以隔离外部依赖；
	// pastureKey=MainData.getKey2()=SHA1(String(serverTime))——期望值用同库
	// SHA1.hash 对同锚点推算（MainDataTest 同款先例）。uIdx=mainData.getHostId
	// ——host null 时 ""（MainData.hx getHostId）
	public function test_decoration_four_keys_inplace() {
		// getKey 函数桩——CommonData.getKey 是 Dynamic 函数字段可赋值
		var savedGetKey:Dynamic = CommonData.getKey;
		CommonData.getKey = function() return "TESTKEY";
		try {
			rec = swapInRecorder();
			var value:Dynamic = {op: "harvest"};
			FRequest.getInstance().postRequest("http://x/?mod=cgi_harvest", value, function(res:Dynamic) {});

			Assert.equals(1, rec.postCount);
			Assert.equals("http://x/?mod=cgi_harvest", rec.postedUrl);
			// 原位加写：postedValue 与入参同对象、原键 op 保留
			Assert.equals("harvest", Reflect.field(rec.postedValue, "op"));
			Assert.equals("1700000000", Reflect.field(rec.postedValue, "farmTime"));
			Assert.equals("TESTKEY", Reflect.field(rec.postedValue, "farmKey"));
			// pastureKey = SHA1("1700000000")（MainData.as:344 String(serverTime)
			// ——锚点值不带小数位，Std.string(1700000000.0)=="1700000000"）
			Assert.equals(com.adobe.crypto.SHA1.hash("1700000000"), Reflect.field(rec.postedValue, "pastureKey"));
			// uIdx=mainData.getHostId——host 未置 → ""（MainData.hx getHostId）
			Assert.equals("", Reflect.field(rec.postedValue, "uIdx"));
		} catch (e:Dynamic) {
			CommonData.getKey = savedGetKey;
			throw e;
		}
		CommonData.getKey = savedGetKey;
	}

	// —— 装饰的 null-value 分支（:138-144）：value 传 null → 新建仅三件
	// （farmKey/farmTime/pastureKey），随后 uIdx 无条件补（:146）
	public function test_decoration_null_value_new_object() {
		var savedGetKey:Dynamic = CommonData.getKey;
		CommonData.getKey = function() return "K2";
		try {
			rec = swapInRecorder();
			FRequest.getInstance().postRequest("http://x/?mod=gb_buy", null, function(res:Dynamic) {});

			Assert.equals(1, rec.postCount);
			Assert.notNull(rec.postedValue);
			Assert.equals("1700000000", Reflect.field(rec.postedValue, "farmTime"));
			Assert.equals("K2", Reflect.field(rec.postedValue, "farmKey"));
			Assert.isTrue(Reflect.hasField(rec.postedValue, "pastureKey"));
			Assert.isTrue(Reflect.hasField(rec.postedValue, "uIdx"));
		} catch (e:Dynamic) {
			CommonData.getKey = savedGetKey;
			throw e;
		}
		CommonData.getKey = savedGetKey;
	}

	// —— getRequest 的 lastRequest 四件 + "&" 拼装（:57-65）：value 非空
	// 且 url 含 "?" 非末尾 → 补 "&"；"?" 在末尾或无 value 不补。getRequest
	// 无熔断段（直接记四件再发），lastRequestFn 记的是 getRequest 本身
	// （:60——与 postRequest 记的 this.postRequest 各自指回各自入口）
	public function test_getRequest_lastRequest_and_ampersand() {
		rec = swapInRecorder();
		var handler = function(res:Dynamic) {};
		var value:Dynamic = {a: 1};
		FRequest.getInstance().getRequest("http://x/cgi?first=1", value, handler);

		// lastRequest 四件（:57-60）——value/url 两键可断言；handle/fn 是
		// 闭包引用，Reflect.compareMethods 在 eval 对成员函数引用不可靠，
		// 钉前两键（记录发生在 HTTPRequest 调用之前、网络成败无关——这正是
		// write-tests 要钉的「同步可观测」面）
		Assert.equals(value, LocalData.lastRequestValue);
		Assert.equals("http://x/cgi?first=1", LocalData.lastRequestUrl);
		Assert.notNull(LocalData.lastRequestHandle); // handler 非空即被记录
		Assert.notNull(LocalData.lastRequestFn); // getRequest 入口自身（:60）
		// "&" 拼装：url 含 "?" 且非末尾、有 value → +"&"
		Assert.equals("http://x/cgi?first=1&", rec.gettedUrl);
		Assert.equals(1, rec.getCount);

		// "?" 在末尾 → 不补
		FRequest.getInstance().getRequest("http://x/cgi?", {a: 1}, handler);
		Assert.equals("http://x/cgi?", rec.gettedUrl);

		// value null → 不补（Boolean(value) 门）
		FRequest.getInstance().getRequest("http://x/cgi?first=1", null, handler);
		Assert.equals("http://x/cgi?first=1", rec.gettedUrl);
		Assert.equals(3, rec.getCount);
	}
}
