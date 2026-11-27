package mc.control;

import common.INI;
import common.LocalData;
import mc.control.Command;
import mc.model.MainData;
import mc.model.MData;
import support.McCommandEnv;
import utest.Assert;

/**
 * mc.control.DiyItemCommand 纯逻辑（issue #88 write-tests，对 stub 失败）：
 * 牧场装饰 QB/FB 买的验价请求拼装、DNA 重发、buyDiyFn 文案模板拼装。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/control/DiyItemCommand.as
 * —— verifyQBRequest :40-66（_postValue 八键 {itemID,type,userFB,diyName,
 * FBPrice,win,exp,number}；发往 INI postUrl.@verifyRequest——fixture
 * mc-ini.xml verifyRequest="shop_verify"（mc_main.php:8 抄录）；请求体
 * 仅 payitem 一键 = param2*10000+param1 + "-" + param8 + "-" + param4——
 * payitem 三段拼接公式 :60）；
 * buyDiy :129-148（发往 postUrl.@fbRequest="gb_buy"；请求体 12 键逐字：
 * app_key "QQMCZZ"、payitem 同式、payvalue 10*param5*param8、paytype 0、
 * accttype 4、dnatime 0、payinfo=param4、dnakey 0、format "JSON"、
 * itemId=param1、exp=param7——:135-146 逐字）；
 * returnFn :150-178（open=="1" 分支：payitem=int(type)*10000+int(itemID)
 * +"-"+number+"-"+diyName、payType 1 → cgi_pasture_shop_pay 发往
 * mainCommand.onInGamePreCheckSuccess；MainData.inGameBuyType="DIY"、
 * inGameBuyObject 写 itemID/exp 两键——:168-172）；
 * forDNA :180-196（lastRequestValue 非空原位加写 dnakey/dnatime 两键，
 * null 新建仅两键对象；随后 lastRequestFn(lastRequestUrl,lastRequestValue,
 * lastRequestHandle) 三参重发——FRequest.as:139-142 记录位）；
 * buyDiyFn :276-344（code==1：money 取负后 addMoney——**param1.money =
 * -param1.money** :282；direction 缺省 "购买成功" :292；tinBuySuccessText
 * 参数在时拼 "<br>" + 可选 <a href='event:success'><u> 包裹 + 文案——
 * 模板 :297-307 逐字；code==100 → JSProxy.showDNA 早返不再弹窗 :314-318；
 * code==50 → "余额不足" + tinBuyQDText 同款模板、event:addMoney 链 :321-336）。
 *
 * INI 注入：INI.getInstance().data 可写属性，fixture mc-ini.xml 的
 * postUrl 行抄录 mc_main.php:8（verifyRequest="shop_verify"
 * fbRequest="gb_buy"）。JSProxy.showDNA 属 no-qzone-jsapi 决策族——
 * showDNA 调用面不进断言（只钉 code 100 不再进后续弹窗分支）。
 */
class DiyItemCommandTest {
	static var FIXTURE:String = sys.io.File.getContent("test/fixtures/mc-ini.xml");

	var env:McCommandEnv;

	public function new() {}

	function setup() {
		env = new McCommandEnv();
		env.resetStatics();
		env.swapInRecorder();
		env.captureViewControl([]);
		INI.getInstance().data = Xml.parse(FIXTURE);
		LocalData.parameters = {};
		MainData.inGameBuyType = "";
		MainData.inGameBuyObject = {};
	}

	function teardown() {
		env.restoreRecorder();
		env.releaseViewControl();
	}

	// verifyQBRequest（DiyItemCommand.as:40-66）：url 取 INI verifyRequest
	// 属性（fixture "shop_verify"）；请求体仅 payitem 一键——
	// param2*10000+param1+"-"+param8+"-"+param4。例 type=6/itemID=101/
	// number=2/diyName="背景A" → 6*10000+101=60101 + "-"+"2"+"-"+"背景A"
	public function test_verifyQBRequest_payitem_formula() {
		Command.getInstance().diyCommand.verifyQBRequest(101, 6, true, "背景A", 5, null, 0, 2);
		Assert.equals(1, env.rec.postCount);
		Assert.equals("shop_verify", env.rec.postedUrl);
		Assert.equals("60101-2-背景A", Reflect.field(env.rec.postedValue, "payitem"));
		// 请求体业务键仅 payitem 一键（:59-61——_loc10_ 新建只写 payitem）；
		// FRequest 装饰段对 value 原位加写 farmTime/farmKey/pastureKey/uIdx
		// 四键（FRequest.as:150-162）——剔四件装饰键后不得有第二件业务键
		var keys = Reflect.fields(env.rec.postedValue);
		for (k in keys) {
			Assert.isTrue(k == "payitem" || k == "farmTime" || k == "farmKey" || k == "pastureKey" || k == "uIdx",
				"unexpected key " + k);
		}
	}

	// returnFn 的 open=="1" 分支（:151-173）：验价应答带 open "1" → 直发
	// cgi_pasture_shop_pay（payType 1、payitem 同式重拼）；inGameBuyType
	// 落 "DIY"、inGameBuyObject 记 itemID/exp
	public function test_verify_open1_branch_posts_pasture_shop_pay() {
		var dc = Command.getInstance().diyCommand;
		dc.verifyQBRequest(101, 6, true, "背景A", 5, null, 30, 2);
		env.respond({code: 0, open: "1"});
		// 应答后新一发：cgi_pasture_shop_pay
		Assert.equals(2, env.rec.postCount);
		Assert.equals("cgi_pasture_shop_pay", env.rec.postedUrl);
		Assert.equals("60101-2-背景A", Reflect.field(env.rec.postedValue, "payitem"));
		Assert.equals(1, Reflect.field(env.rec.postedValue, "payType"));
		Assert.equals("DIY", MainData.inGameBuyType);
		Assert.equals(101, Reflect.field(MainData.inGameBuyObject, "itemID"));
		Assert.equals(30, Reflect.field(MainData.inGameBuyObject, "exp"));
	}

	// returnFn 的 code==1 分支（:174-176）→ buyDiy 发到 fbRequest（fixture
	// "gb_buy"），12 键逐字（:135-146）——验价成功后真正下单的请求形状
	public function test_verify_code1_branch_posts_buyDiy_12keys() {
		var dc = Command.getInstance().diyCommand;
		dc.verifyQBRequest(101, 6, true, "背景A", 5, null, 30, 2);
		env.respond({code: 0}); // 无 open 键 → code 1 → buyDiy
		Assert.equals(2, env.rec.postCount);
		Assert.equals("gb_buy", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals("QQMCZZ", Reflect.field(v, "app_key"));
		Assert.equals("60101-2-背景A", Reflect.field(v, "payitem"));
		// payvalue = 10*param5*param8 = 10*5*2 = 100（:138）
		Assert.equals(100, Reflect.field(v, "payvalue"));
		Assert.equals(0, Reflect.field(v, "paytype"));
		Assert.equals(4, Reflect.field(v, "accttype"));
		Assert.equals(0, Reflect.field(v, "dnatime"));
		Assert.equals("背景A", Reflect.field(v, "payinfo"));
		Assert.equals(0, Reflect.field(v, "dnakey"));
		Assert.equals("JSON", Reflect.field(v, "format"));
		Assert.equals(101, Reflect.field(v, "itemId"));
		Assert.equals(30, Reflect.field(v, "exp"));
	}

	// returnFn 的 logic/system 分支（:177-178）→ alertWindow error
	// direction——验价失败的直接弹窗面
	public function test_verify_logic_error_alerts() {
		var dc = Command.getInstance().diyCommand;
		dc.verifyQBRequest(101, 6, true, "背景A", 5, null, 30, 2);
		env.respond({errorType: "logic", errorContent: "余额不足，请充值"});
		Assert.equals(1, env.rec.postCount); // 不再发新请求
		Assert.equals(1, env.windowEvents.length);
		Assert.equals("AlertWindow", env.windowEvents[0].name);
		Assert.equals("error", Reflect.field(env.windowEvents[0].arg, "type"));
		Assert.equals("余额不足，请充值", Reflect.field(env.windowEvents[0].arg, "text"));
	}

	// forDNA（:180-196）：lastRequestValue 非空 → 原位加写 dnakey/dnatime
	// 两键（原键保留），随后三参重发——重发入参逐字钉
	public function test_forDNA_inplace_write_and_replay() {
		LocalData.lastRequestValue = {payitem: "60101-2-x", app_key: "QQMCZZ"};
		LocalData.lastRequestUrl = "gb_buy";
		var got:Array<Dynamic> = [];
		LocalData.lastRequestHandle = function(o:Dynamic) {};
		LocalData.lastRequestFn = function(url:String, value:Dynamic, handle:Dynamic) {
			got.push({url: url, value: value});
		};
		Command.getInstance().diyCommand.forDNA("KEY123", "999888");
		Assert.equals("KEY123", Reflect.field(LocalData.lastRequestValue, "dnakey"));
		Assert.equals("999888", Reflect.field(LocalData.lastRequestValue, "dnatime"));
		Assert.equals("60101-2-x", Reflect.field(LocalData.lastRequestValue, "payitem")); // 原键保留
		Assert.equals(1, got.length);
		Assert.equals("gb_buy", got[0].url);
		Assert.equals(LocalData.lastRequestValue, got[0].value);
	}

	// forDNA 的 null 分支（:188-193）：lastRequestValue null → 新建仅
	// dnakey/dnatime 两键对象
	public function test_forDNA_null_value_new_object() {
		LocalData.lastRequestValue = null;
		LocalData.lastRequestFn = function(url:String, value:Dynamic, handle:Dynamic) {};
		Command.getInstance().diyCommand.forDNA("K", "T");
		var keys = Reflect.fields(LocalData.lastRequestValue);
		Assert.equals(2, keys.length);
		Assert.equals("K", Reflect.field(LocalData.lastRequestValue, "dnakey"));
		Assert.equals("T", Reflect.field(LocalData.lastRequestValue, "dnatime"));
	}

	// buyDiyFn 成功文案模板（:289-307）：direction 缺省回 "购买成功"；
	// tinBuySuccessText 在 + tinBuySuccessUrl 在 → 全包链：
	// "购买成功" + "<br>" + "<a href='event:success'><u>" + 文案 +
	// "</u></a>"——模板逐字；弹窗第三参 url 随 tinBuySuccessUrl
	public function test_buyDiyFn_success_template_with_link() {
		var dc = Command.getInstance().diyCommand;
		var md = MData.getInstance().mainData;
		md.host = {"uId": "100", "money": 500, "exp": 0, "userName": "me"};
		LocalData.parameters = {tinBuySuccessText: "继续购买", tinBuySuccessUrl: "http://x/shop"};
		// buyDiyFn 是 public（:274）——直接驱动，等价 qqBuyDiyFn 收口后的
		// 归并点；money 取负（:282）：money -300 → +300 入账
		dc.buyDiyFn({code: 1, money: -300, direction: ""});
		Assert.equals(1, env.windowEvents.length);
		Assert.equals("success", Reflect.field(env.windowEvents[0].arg, "type"));
		Assert.equals("购买成功<br><a href='event:success'><u>继续购买</u></a>", Reflect.field(env.windowEvents[0].arg, "text"));
		Assert.equals("http://x/shop", Reflect.field(env.windowEvents[0].arg, "url"));
		// money 取负后 addMoney：-(-300)=+300 → host.money 500+300=800
		Assert.equals(800, Reflect.field(md.host, "money"));
	}

	// 无 tinBuySuccessUrl 时文案裸拼（无 <a> 链）："<br>"+文案（:299-305
	// 的 _loc3_ false 分支）
	public function test_buyDiyFn_success_template_without_url() {
		var dc = Command.getInstance().diyCommand;
		MData.getInstance().mainData.host = {"uId": "100", "money": 500, "exp": 0, "userName": "me"};
		LocalData.parameters = {tinBuySuccessText: "继续购买"};
		dc.buyDiyFn({code: 1, money: -100, direction: ""});
		Assert.equals("购买成功<br>继续购买", Reflect.field(env.windowEvents[0].arg, "text"));
	}

	// direction 非空时不落缺省（:289-292）
	public function test_buyDiyFn_direction_verbatim() {
		var dc = Command.getInstance().diyCommand;
		MData.getInstance().mainData.host = {"uId": "100", "money": 0, "exp": 0, "userName": "me"};
		LocalData.parameters = {};
		dc.buyDiyFn({code: 1, money: -100, direction: "买到了稀有装饰"});
		Assert.equals("买到了稀有装饰", Reflect.field(env.windowEvents[0].arg, "text"));
	}

	// code==50 余额不足模板（:321-336）："余额不足" + event:addMoney 链 +
	// alertWindow error + **提前 return**——不进 errorType 尾段
	public function test_buyDiyFn_code50_template() {
		var dc = Command.getInstance().diyCommand;
		LocalData.parameters = {tinBuyQDText: "立即充值", tinBuyQDUrl: "http://x/pay"};
		dc.buyDiyFn({code: 50, dnaurl: "", direction: "", errorType: "IOError"});
		Assert.equals(1, env.windowEvents.length);
		Assert.equals("error", Reflect.field(env.windowEvents[0].arg, "type"));
		Assert.equals("余额不足<br><a href='event:addMoney'><u>立即充值</u></a>", Reflect.field(env.windowEvents[0].arg, "text"));
		Assert.equals("http://x/pay", Reflect.field(env.windowEvents[0].arg, "url"));
	}

	// code==100 → showDNA 早返（:314-318）：不弹任何窗
	public function test_buyDiyFn_code100_no_alert() {
		var dc = Command.getInstance().diyCommand;
		dc.buyDiyFn({code: 100, dnaurl: "http://x/dna"});
		Assert.equals(0, env.windowEvents.length);
	}

	// direction 通道（:338-342）：非 1/100/50 且 direction 非空 → error 弹窗
	public function test_buyDiyFn_direction_error_branch() {
		var dc = Command.getInstance().diyCommand;
		dc.buyDiyFn({code: 7, direction: "系统错误"});
		Assert.equals(1, env.windowEvents.length);
		Assert.equals("error", Reflect.field(env.windowEvents[0].arg, "type"));
		Assert.equals("系统错误", Reflect.field(env.windowEvents[0].arg, "text"));
	}

	// errorType 尾段（:344-351）：IOError 系且无 direction → "请求超时，
	// 稍后再试"（无句号）
	public function test_buyDiyFn_errorType_timeout_text() {
		var dc = Command.getInstance().diyCommand;
		dc.buyDiyFn({code: 7, errorType: "timeOut"});
		Assert.equals(1, env.windowEvents.length);
		Assert.equals("请求超时，稍后再试", Reflect.field(env.windowEvents[0].arg, "text"));
	}
}
