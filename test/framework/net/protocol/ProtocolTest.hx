package framework.net.protocol;

import common.CommonData;
import common.Settings;
import common.misc.QzoneJSAPI;
import entities.Player;
import openfl.net.URLVariables;
import utest.Assert;

/**
 * Protocol 请求侧参数拼装 encodeForHttp + 回包解码 decodeForHttp（issue #7）。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/framework/net/protocol/Protocol.as
 *   （encodeForHttp :92-131：POST 基础三元组 farmKey/farmTime/uIdx :104-109、
 *   qzone 的 uinX/uinY :110-118、WB platform :119-122、m_request 合并 :123-129；
 *   decodeForHttp :32-57：非 JSON 回包包成 ReponseError :45-48）
 * - Consts.as:54 NET_HTTP_METHOD_POST = URLRequestMethod.POST（"POST"，
 *   入参 toUpperCase 后比较）
 * - Settings.as:126-131（mode "1" → "qzone"）；Session.as:441-448（hostId）、
 *   :130-137（hostUin）；CommonData.as:32（getKey 函数位）、:141-148
 *   （serverTime 读取 = 设定值 + 距设定的整秒漂移）
 *
 * farmTime 不断言精确值：get_serverTime 会加上「距 set 的整秒数」（0 或 1 秒，
 * 相邻语句在毫秒级完成），断言落在 [T, T+1] 内。Settings/QzoneJSAPI/Session
 * 均为已译类/闭包 stub，每个用例自行钉状态。
 */
class ProtocolTest {
	static final T:Float = 1794915896; // fixture serverTime（uid1_user_run.json）

	public function new() {}

	function pinHost(uId:UInt, uinLogin:UInt):Void {
		var host = new Player({});
		host._uId = uId;
		host._uinLogin = uinLogin;
		Settings.getInstance().loadLocalSettings({});
		QzoneJSAPI.WB = false;
		var s = common.Session.getInstance();
		s.currentUser = host;
		s.host = host;
	}

	// :104-109 POST：farmKey=getKey() 返回值、farmTime=serverTime、uIdx=hostId；
	// :123-129 m_request 的键随后合并进来
	public function test_encodeForHttp_post_merges_auth_triple_and_request() {
		pinHost(1, 8888);
		CommonData.getKey = function():String return "farmKeyK";
		CommonData.serverTime = T;

		var p = new Protocol(1);
		p.importRequestObject({place: "3"});
		var vars:Dynamic = p.encodeForHttp("post");

		Assert.equals("farmKeyK", Reflect.field(vars, "farmKey")); // :106
		var farmTime = Std.parseFloat(Reflect.field(vars, "farmTime")); // :107
		Assert.isTrue(farmTime == T || farmTime == T + 1, 'farmTime=$farmTime');
		Assert.equals("1", Reflect.field(vars, "uIdx")); // :108 host._uId.toString()
		Assert.equals("3", Reflect.field(vars, "place")); // :127 合并
	}

	// :98-101 getKey 为 null → farmKey 空串；:123 m_request 为 null → 只有三元组
	public function test_encodeForHttp_post_defaults_without_key_and_request() {
		pinHost(1, 8888);
		CommonData.getKey = null;
		CommonData.serverTime = T;

		var p = new Protocol(1);
		var vars:Dynamic = p.encodeForHttp("post");
		Assert.equals("", Reflect.field(vars, "farmKey"));
		Assert.isFalse(Reflect.hasField(vars, "place")); // 没有请求对象就没有业务键
	}

	// :123-129 合并发生在三元组之后：请求对象里的 farmKey 覆盖鉴权值
	public function test_encodeForHttp_request_fields_override_auth_triple() {
		pinHost(1, 8888);
		CommonData.getKey = function():String return "farmKeyK";
		CommonData.serverTime = T;

		var p = new Protocol(1);
		p.importRequestObject({farmKey: "override", ownerId: 7});
		var vars:Dynamic = p.encodeForHttp("post");
		Assert.equals("override", Reflect.field(vars, "farmKey"));
		Assert.equals(7, Reflect.field(vars, "ownerId"));
	}

	// :104 GET（toUpperCase != "POST"）：不带 farmKey/farmTime/uIdx，只合并业务键
	public function test_encodeForHttp_get_has_no_auth_triple() {
		pinHost(1, 8888);
		CommonData.getKey = function():String return "farmKeyK";
		CommonData.serverTime = T;

		var p = new Protocol(1);
		p.importRequestObject({place: "3"});
		var vars:Dynamic = p.encodeForHttp("get");
		Assert.isFalse(Reflect.hasField(vars, "farmKey"));
		Assert.isFalse(Reflect.hasField(vars, "farmTime"));
		Assert.isFalse(Reflect.hasField(vars, "uIdx"));
		Assert.equals("3", Reflect.field(vars, "place"));
	}

	// :110-118 qzone 模式 + POST：uinX=_userUin（非空才写）、uinY=hostUin；
	// GET 时不写（:110 同一 POST 条件）
	public function test_encodeForHttp_qzone_uin_fields() {
		pinHost(1, 8888);
		Settings.getInstance().loadLocalSettings({mode: "1"}); // Settings.as:127-128
		CommonData.getKey = null;
		CommonData.serverTime = T;

		Protocol._userUin = "12345";
		var p = new Protocol(1);
		var post:Dynamic = p.encodeForHttp("post");
		Assert.equals("12345", Reflect.field(post, "uinX")); // :115
		Assert.equals("8888", Reflect.field(post, "uinY")); // :117 hostUin

		Protocol._userUin = ""; // :113-116 空串不写 uinX
		var p2 = new Protocol(1);
		var post2:Dynamic = p2.encodeForHttp("post");
		Assert.isFalse(Reflect.hasField(post2, "uinX"));
		Assert.equals("8888", Reflect.field(post2, "uinY"));

		Protocol._userUin = "12345";
		var p3 = new Protocol(1);
		var get:Dynamic = p3.encodeForHttp("get");
		Assert.isFalse(Reflect.hasField(get, "uinX")); // :110 GET 不进
		Assert.isFalse(Reflect.hasField(get, "uinY"));
	}

	// :119-122 QzoneJSAPI.WB → platform=3（任意 method）
	public function test_encodeForHttp_wb_adds_platform() {
		pinHost(1, 8888);
		CommonData.getKey = null;
		CommonData.serverTime = T;
		QzoneJSAPI.WB = true;

		var p = new Protocol(1);
		var get:Dynamic = p.encodeForHttp("get");
		Assert.equals(3, Reflect.field(get, "platform"));
	}

	// decodeForHttp :45-48：回包不是 {/[ 开头 → 包成
	// {errorType:"ReponseError", errorContent:原文} 再解码
	public function test_decodeForHttp_wraps_non_json_payload() {
		var p = new Protocol(1);
		p.importResponseObject("plain not json");
		var decoded:Dynamic = p.decodeForHttp();
		Assert.equals("ReponseError", Reflect.field(decoded, "errorType"));
		Assert.equals("plain not json", Reflect.field(decoded, "errorContent"));
	}
}
