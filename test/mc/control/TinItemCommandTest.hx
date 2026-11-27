package mc.control;

import common.INI;
import common.LocalData;
import mc.control.Command;
import mc.model.MData;
import mc.model.MainData;
import mc.model.TinItemsData;
import support.McCommandEnv;
import utest.Assert;

/**
 * mc.control.TinItemCommand 纯逻辑（issue #88 write-tests，对 stub 失败）：
 * 罐头/道具商店（扩展栏道具）的请求拼装与应答分派。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/control/TinItemCommand.as
 * —— getTinsInfo :46-58（m_pending 闸——true 早退；postRequest2(
 * "cgi_get_toollist", {ystatus:host.yellowstatus, ylv:host.yellowlevel,
 * plv:expToGrade(host.exp)}——三键出处 :50-54；后置 m_pending=true +
 * tinData.loadingData=true——先请求后置闸的顺序 :56-57）；getTinsInfoFn
 * :318-340（m_pending 复位；IOError 系 → shopTinInfoErr = "请求超时，" +
 * "<a href='event:reload'><u><font color='#ff6600'>点击重试</font></u></a>"
 * 模板逐字 :325-326；成功 → tinData.addTinItems(param1 as Array) +
 * loadingData=false）；
 * verifyQBRequest :196-232（appid!=353（缺省 358）→ verifyRequest 通道
 * payitem=type*10000+itemID+"-"+number+"-"+itemName；appid==353 →
 * cgi_farm_shop_verify 通道四键 {shopType:10, itemType, itemId, itemNum}
 * ——:218-229 分支逐字）；returnFn :117-159（open=="1" 分支 appid!=353 →
 * cgi_pasture_shop_pay payitem 重拼 + payType 1；appid==353 →
 * cgi_farm_shop_pay 五键 {shopType:10, itemType, itemId, itemNum, payType:1}
 * ——:126-147；inGameBuyType "Item" + inGameBuyObject.itemType——:151-153）；
 * buyTool :386-427（!userFB 三分支：type==106 → cgi_buy_guard {id,type,
 * number}；type==10 && win.data.appid=="353" → getPostUrl()+
 * "cgi_farm_buyweapon" {tId,type,number}；userFB true → fbRequest 通道
 * 12 键——app_key 按 appid 353 "happyfarm"/否则 "QQMCZZ"（:408-413）、
 * payvalue 10*FBPrice*number、checkUpdateType=type、appid 随窗——:405-425）；
 * buyToolFn2 :69-101（ecode==0 → alertWindow "购买成功！"；type==106 →
 * mainData.hunter={id,name,t:striketime,used:1}——:83-89 逐字；reloadUserSeed/
 * reloadUserMaterial 置位 + getTinsInfo 重拉；非零 → floatWindow(direction,
 * "Exclamation")）；qqBuyToolFn :272-316（code==0 → 成功块：direction
 * 缺省 "购买成功"；post_data.checkUpdateType==5 → mainCommand.getCropStatus
 * ("0",false)；type==10 && appid=="353" → direction 换驱赶武器长文案
 * :294-295 逐字；errorType 网络系 → "请求超时，稍后再试"）。
 *
 * expToGrade 依赖 host.exp——MainData 公式 100n(n+1) 门槛（MainData.as:
 * 893-896）：exp 200 → plv 1、exp 600 → plv 2。
 */
class TinItemCommandTest {
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
		var md = MData.getInstance().mainData;
		md.host = {"uId": "100", "money": 5000, "exp": 200, "userName": "me", "yellowstatus": 1, "yellowlevel": 3};
	}

	function teardown() {
		env.restoreRecorder();
		env.releaseViewControl();
	}

	// getTinsInfo（TinItemCommand.as:46-58）：三键逐字——yellowstatus 1、
	// yellowlevel 3、plv=expToGrade(200)=1（exp 200 是 grade1 门槛
	// 100*1*2=200，MainData.as:893-896）
	public function test_getTinsInfo_three_keys() {
		Command.getInstance().tinCommand.getTinsInfo();
		Assert.equals(1, env.rec.postCount);
		Assert.equals("cgi_get_toollist", env.rec.postedUrl);
		Assert.equals(1, Reflect.field(env.rec.postedValue, "ystatus"));
		Assert.equals(3, Reflect.field(env.rec.postedValue, "ylv"));
		Assert.equals(1, Reflect.field(env.rec.postedValue, "plv"));
		Assert.isTrue(MData.getInstance().tinData.loadingData);
	}

	// m_pending 闸（:47-49）：未应答时第二次调用不出网
	public function test_getTinsInfo_pending_gate() {
		Command.getInstance().tinCommand.getTinsInfo();
		Command.getInstance().tinCommand.getTinsInfo();
		Assert.equals(1, env.rec.postCount);
	}

	// getTinsInfoFn 成功（:328-338）：pending 复位、loadingData false、
	// addTinItems 装载——应答数组原样进罐头表（TinItemsData.addTinItems
	// 是 #87 充真身；装载后以 shopTinInfo 非空/条数佐证——TinItemsData
	// 重映射属模型层语义，这里只钉命令层的调用到位）
	public function test_getTinsInfoFn_success_loads() {
		Command.getInstance().tinCommand.getTinsInfo();
		env.respond([{tId: "4001", type: "7", amount: 2}]);
		Assert.isFalse(MData.getInstance().tinData.loadingData);
		// 闸复位：可再次发请求
		Command.getInstance().tinCommand.getTinsInfo();
		Assert.equals(2, env.rec.postCount);
	}

	// getTinsInfoFn 网络错（:322-327）：shopTinInfoErr 模板逐字
	public function test_getTinsInfoFn_ioerror_template() {
		var td = MData.getInstance().tinData;
		td.shopTinInfoErr = "";
		Command.getInstance().tinCommand.getTinsInfo();
		env.respond({errorType: "timeOut"});
		Assert.equals("请求超时，<a href='event:reload'><u><font color='#ff6600'>点击重试</font></u></a>", td.shopTinInfoErr);
	}

	// verifyQBRequest 缺省 appid（:218-224）：appid 358（缺省）≠353 →
	// verifyRequest 通道 payitem 公式（fixture verifyRequest="shop_verify"）
	public function test_verifyQBRequest_default_channel() {
		Command.getInstance().tinCommand.verifyQBRequest(101, 4, true, "罐头", 5, null, 2);
		Assert.equals("shop_verify", env.rec.postedUrl);
		Assert.equals("40101-2-罐头", Reflect.field(env.rec.postedValue, "payitem"));
	}

	// verifyQBRequest appid==353 通道（:225-229）：cgi_farm_shop_verify
	// 四键——shopType 恒 10、itemType/itemId/itemNum 随参
	public function test_verifyQBRequest_353_channel() {
		Command.getInstance().tinCommand.verifyQBRequest(55, 10, true, "武器", 5, null, 3, 353);
		Assert.equals("cgi_farm_shop_verify", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals(10, Reflect.field(v, "shopType"));
		Assert.equals(10, Reflect.field(v, "itemType"));
		Assert.equals(55, Reflect.field(v, "itemId"));
		Assert.equals(3, Reflect.field(v, "itemNum"));
		Assert.isFalse(Reflect.hasField(v, "payitem"));
	}

	// returnFn open=="1" appid 非 353（:126-134）→ cgi_pasture_shop_pay
	public function test_verify_open1_non353_pasture_pay() {
		var tc = Command.getInstance().tinCommand;
		tc.verifyQBRequest(101, 4, true, "罐头", 5, null, 2);
		env.respond({code: 0, open: "1"});
		Assert.equals(2, env.rec.postCount);
		Assert.equals("cgi_pasture_shop_pay", env.rec.postedUrl);
		Assert.equals("40101-2-罐头", Reflect.field(env.rec.postedValue, "payitem"));
		Assert.equals(1, Reflect.field(env.rec.postedValue, "payType"));
		Assert.equals("Item", MainData.inGameBuyType);
		Assert.equals(4, Reflect.field(MainData.inGameBuyObject, "itemType"));
	}

	// returnFn open=="1" appid==353（:135-147）→ cgi_farm_shop_pay 五键
	public function test_verify_open1_353_farm_pay() {
		var tc = Command.getInstance().tinCommand;
		tc.verifyQBRequest(55, 10, true, "武器", 5, null, 3, 353);
		env.respond({code: 0, open: "1"});
		Assert.equals(2, env.rec.postCount);
		Assert.equals("cgi_farm_shop_pay", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals(10, Reflect.field(v, "shopType"));
		Assert.equals(10, Reflect.field(v, "itemType"));
		Assert.equals(55, Reflect.field(v, "itemId"));
		Assert.equals(3, Reflect.field(v, "itemNum"));
		Assert.equals(1, Reflect.field(v, "payType"));
	}

	// buyTool 非 FB type==106（:392-398）→ cgi_buy_guard {id,type,number}
	public function test_buyTool_guard_106() {
		Command.getInstance().tinCommand.buyTool(7, 1, 106, false, "", 0, null);
		Assert.equals("cgi_buy_guard", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals(7, Reflect.field(v, "id"));
		Assert.equals(106, Reflect.field(v, "type"));
		Assert.equals(1, Reflect.field(v, "number"));
	}

	// buyTool 非 FB type==10 appid 353（:399-405）→ getPostUrl()+
	// "cgi_farm_buyweapon"——url 带 mymc.php 前缀（fixture postUrl url
	// 属性 "http://appimg.qq.com/mc/mymc.php?mod="）
	public function test_buyTool_weapon_353() {
		var win:Dynamic = {data: {appid: "353"}};
		Command.getInstance().tinCommand.buyTool(55, 2, 10, false, "", 0, win);
		Assert.equals("http://appimg.qq.com/mc/mymc.php?mod=cgi_farm_buyweapon", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals(55, Reflect.field(v, "tId"));
		Assert.equals(10, Reflect.field(v, "type"));
		Assert.equals(2, Reflect.field(v, "number"));
	}

	// buyTool FB 通道（:405-425）：app_key 按窗 appid 分叉——353 →
	// "happyfarm"，否则 "QQMCZZ"；checkUpdateType=type、appid 随窗
	public function test_buyTool_fb_appkey_branches() {
		var win353:Dynamic = {data: {appid: "353"}};
		Command.getInstance().tinCommand.buyTool(55, 2, 10, true, "武器", 6, win353);
		Assert.equals("gb_buy", env.rec.postedUrl);
		Assert.equals("happyfarm", Reflect.field(env.rec.postedValue, "app_key"));
		Assert.equals("353", Reflect.field(env.rec.postedValue, "appid"));
		Assert.equals(10, Reflect.field(env.rec.postedValue, "checkUpdateType"));
		// payitem = type*10000+id+"-"+number+"-"+name = 100055-2-武器
		Assert.equals("100055-2-武器", Reflect.field(env.rec.postedValue, "payitem"));
		// payvalue = 10*6*2 = 120
		Assert.equals(120, Reflect.field(env.rec.postedValue, "payvalue"));

		env.rec.postCount = 0;
		var win358:Dynamic = {data: {appid: "358"}};
		Command.getInstance().tinCommand.buyTool(101, 1, 4, true, "罐头", 5, win358);
		Assert.equals("QQMCZZ", Reflect.field(env.rec.postedValue, "app_key"));
	}

	// buyToolFn2 成功（:69-101）：ecode 0 → "购买成功！" 弹窗 + type 106
	// 时 hunter 四键 {id,name,t:striketime,used:1} 逐字（:83-89）
	public function test_buyToolFn2_success_guard_hunter() {
		var tc = Command.getInstance().tinCommand;
		tc.buyTool(7, 1, 106, false, "", 0, null);
		env.respond({
			ecode: 0,
			id: 7,
			name: "猎手",
			striketime: 86400,
			post_data: {type: 106}
		});
		Assert.isTrue(env.windowEvents.length >= 1);
		Assert.equals("购买成功！", Reflect.field(env.windowEvents[0].arg, "text"));
		var h = MData.getInstance().mainData.hunter;
		Assert.equals(7, Reflect.field(h, "id"));
		Assert.equals("猎手", Reflect.field(h, "name"));
		Assert.equals(86400, Reflect.field(h, "t"));
		Assert.equals(1, Reflect.field(h, "used"));
		// 成功后重拉罐头表（:97 getTinsInfo）——第二发出网
		Assert.equals(2, env.rec.postCount);
		Assert.equals("cgi_get_toollist", env.rec.postedUrl);
	}

	// buyToolFn2 非零 ecode（:99-101）→ floatWindow(direction,
	// "Exclamation")——浮字层不进断言，只钉不写 hunter、不重拉
	public function test_buyToolFn2_failure_no_hunter_no_reload() {
		var tc = Command.getInstance().tinCommand;
		tc.buyTool(7, 1, 106, false, "", 0, null);
		env.rec.postCount = 0;
		env.respond({ecode: 1, direction: "已经买过"});
		Assert.equals(0, env.rec.postCount);
	}

	// qqBuyToolFn 成功（:272-316）：code 0 → buyToolFn 归并——direction
	// 缺省 "购买成功"；checkUpdateType==5 触发 getCropStatus("0",false)
	// （：287-289）——cgi_enter 请求佐证（mod 串 "cgi_enter?" 出处
	// MainCommand.as:1695-1700）
	public function test_qqBuyToolFn_checkUpdateType5_triggers_enter() {
		var tc = Command.getInstance().tinCommand;
		var win358:Dynamic = {data: {appid: "358"}};
		tc.buyTool(101, 1, 5, true, "罐头", 5, win358);
		env.rec.postCount = 0;
		env.respond({code: 0, post_data: {checkUpdateType: 5, type: 5, appid: "358", exp: 0}});
		// 触发 cgi_enter 重进（MainCommand.getCropStatus——newitem 2 flag 1）
		Assert.isTrue(env.rec.postCount >= 1);
		Assert.equals("cgi_enter?", env.rec.postedUrl);
	}

	// type==10 && appid=="353" 的 direction 长文案（:294-295 逐字）
	public function test_qqBuyToolFn_weapon353_direction() {
		var tc = Command.getInstance().tinCommand;
		var win353:Dynamic = {data: {appid: "353"}};
		tc.buyTool(55, 1, 10, true, "武器", 5, win353);
		env.respond({code: 0, post_data: {type: 10, appid: "353", exp: 0}});
		Assert.isTrue(env.windowEvents.length >= 1);
		Assert.equals("购买成功+<br>驱赶武器放在扩展场景->武器背包中，<a href='event:gotoWild'><font color='#ff6600'>去查看。</font></a>",
			Reflect.field(env.windowEvents[0].arg, "text"));
	}

	// errorType 网络系（:301-306）→ "请求超时，稍后再试" 不进 buyToolFn
	// 成功块
	public function test_qqBuyToolFn_ioerror_alert() {
		var tc = Command.getInstance().tinCommand;
		var win358:Dynamic = {data: {appid: "358"}};
		tc.buyTool(101, 1, 4, true, "罐头", 5, win358);
		env.respond({code: 1, errorType: "IOError", msg: "x"});
		Assert.isTrue(env.windowEvents.length >= 1);
		Assert.equals("请求超时，稍后再试", Reflect.field(env.windowEvents[0].arg, "text"));
	}
}
