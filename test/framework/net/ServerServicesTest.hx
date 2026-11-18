package framework.net;

import common.Settings;
import common.misc.QzoneJSAPI;
import entities.StartupData;
import framework.net.protocol.Protocol;
import openfl.errors.ArgumentError;
import utest.Assert;

/**
 * ServerServices 网络命令层纯逻辑（issue #7）。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/framework/net/ServerServices.as
 *   （cmdMap 构造表 :22-197、registerCmdMap :209-224、decodeResult :226-258、
 *   getRequestUrl :260-307、registerCmd :309-328、encodeRequest :330-344、
 *   checkResponseError :346-369）
 * - legacy/deploy/QFarmFlash/source/core/mync.php:36-46（mod_list 白名单：act 名）、
 *   :171-177（mod+act→模块名规则、phpye=phpye→cgi_farm_get_usercrystal）
 * - legacy/deploy/QFarmFlash/source/core/source/nc/mod/farmlandstatus_scarify.php:69
 *   （code:0 + direction 文案的真实错误回包形态）
 *
 * 单例注意：ServerServices 是单例，cmdMap 在构造时按 Settings.mode 固定（:28-42）。
 * 每个用例先 loadLocalSettings({}) + WB=false，把模式钉在 ""（qzone 分支与
 * xymode 分支都得到空前缀），命令串即 mync.php 的原始形态。
 * getUrlConfigByName 无 config model 时返回 ""（Settings.as:387-405），
 * getRequestUrl :292-295 直接返回 cmd 串；QzoneJSAPI.addGToken 在无 QQOutlets 的
 * 环境（eval）原样返回入参（QzoneJSAPI.as），不改变 URL。
 */
@:access(framework.net.ServerServices)
class ServerServicesTest {
	public function new() {}

	static function svc():ServerServices {
		Settings.getInstance().loadLocalSettings({});
		QzoneJSAPI.WB = false;
		return ServerServices.getInstance();
	}

	// ServerServices.as:43-65 构造表 + mync.php:36-46 act 白名单（表驱动）
	public function test_getRequestUrl_cmd_map() {
		var s = svc();
		var cases:Array<{cmd:UInt, expected:String, where:String}> = [
			{cmd: CommandDefs.CMD_GET_BOOT_DATA, expected: "mod=user&act=run", where: "ServerServices.as:43（user_run.php）"},
			{cmd: CommandDefs.CMD_OPERATE_WATER, expected: "mod=farmlandstatus&act=water", where: "ServerServices.as:45（mync.php:46 farmlandstatus_water）"},
			{cmd: CommandDefs.CMD_OPERATE_CLEARWEED, expected: "mod=farmlandstatus&act=clearWeed", where: "ServerServices.as:46（mync.php:36）"},
			{cmd: CommandDefs.CMD_OPERATE_ADDWEED, expected: "mod=farmlandstatus&act=scatterSeed", where: "ServerServices.as:47（mync.php:43 farmlandstatus_scatterseed）"},
			{cmd: CommandDefs.CMD_OPERATE_ADDBUG, expected: "mod=farmlandstatus&act=pest", where: "ServerServices.as:48（mync.php:40）"},
			{cmd: CommandDefs.CMD_OPERATE_CLEARBUG, expected: "mod=farmlandstatus&act=spraying", where: "ServerServices.as:49（mync.php:45）"},
			{cmd: CommandDefs.CMD_OPERATE_HARVEST, expected: "mod=farmlandstatus&act=harvest", where: "ServerServices.as:58（mync.php:39）"},
			{cmd: CommandDefs.CMD_OPERATE_SCARIFY, expected: "mod=farmlandstatus&act=scarify", where: "ServerServices.as:59（mync.php:42）"},
			{cmd: CommandDefs.CMD_OPERATE_PLANT, expected: "mod=farmlandstatus&act=planting", where: "ServerServices.as:60（mync.php:41）"},
			{cmd: CommandDefs.CMD_OPERATE_CHECKSTATUS, expected: "mod=user&act=checkStatus", where: "ServerServices.as:62"},
			{cmd: CommandDefs.CMD_GET_OUTPUT, expected: "mod=farmlandstatus&act=getOutput", where: "ServerServices.as:63（mync.php:38）"},
			{cmd: CommandDefs.CMD_GET_BAG_DATA, expected: "mod=repertory&act=getUserSeed", where: "ServerServices.as:64"},
			{cmd: CommandDefs.CMD_GET_SHOP_SEED, expected: "mod=usertool&act=getSeedInfo", where: "ServerServices.as:65（usertool_getseedinfo.php）"},
			{cmd: CommandDefs.CMD_GET_WAREHOUSE_CRYSTAL, expected: "cgi_farm_get_usercrystal&phpye=phpye", where: "ServerServices.as:71（mync.php:171-172 phpye 特例）"},
			{cmd: CommandDefs.CMD_SET_ADSEED_COOKIE, expected: "http://c.gdt.qq.com/gdt_cookie.fcg", where: "ServerServices.as:156"},
			{cmd: CommandDefs.CMD_GET_SNS_AD, expected: "mod=view_fcg&", where: "ServerServices.as:154"},
			{cmd: CommandDefs.CMD_GET_FISHES, expected: "mod=cgi_fish_index", where: "ServerServices.as:157"},
			{cmd: CommandDefs.WHITE_LIST, expected: "mod=cgi_farm_whitelist", where: "ServerServices.as:164"},
			{cmd: CommandDefs.CMD_CLEAR_ALL_FEEDS, expected: "mod=hydra_feeds_delete", where: "ServerServices.as:149"},
			{cmd: CommandDefs.CMD_WB_PROFILE, expected: "mod=cgi_farm_get_userprofile", where: "ServerServices.as:106"},
			{cmd: CommandDefs.CMD_ACTIVITY_GRAY, expected: "mod=cgi_farm_get_bit?bit=6", where: "ServerServices.as:176"}
		];
		for (c in cases) {
			Assert.equals(c.expected, s.getRequestUrl(c.cmd));
		}
		// 未注册的 cmd：m_cmdMap[9999] == null（:263 读出 null）
		Assert.equals(null, s.getRequestUrl(9999));
	}

	// checkResponseError :346-369：null→true；errorType 定义→false；
	// code=="1"/"888"→true；其它 code→false；无 code→true
	public function test_checkResponseError_table() {
		var s = svc();
		Assert.isTrue(s.checkResponseError(null)); // :348-351
		Assert.isTrue(s.checkResponseError({})); // :368 落到默认 true
		Assert.isFalse(s.checkResponseError({errorType: "NoLoginError"})); // :352-355
		Assert.isTrue(s.checkResponseError({code: "1"})); // :358-361
		Assert.isTrue(s.checkResponseError({code: "888"})); // :362-365
		Assert.isFalse(s.checkResponseError({code: "999"})); // :366
		Assert.isFalse(s.checkResponseError({code: "0"})); // :366
		// :358 AS3 松散相等：1 == "1" 为真（Haxe 侧需等价处理）
		Assert.isTrue(s.checkResponseError({code: 1}));
	}

	// encodeRequest :330-344：cmd 0 → ArgumentError；未注册 → ArgumentError
	public function test_encodeRequest_throws_on_invalid_cmd_or_url() {
		var s = svc();
		Assert.raises(function() s.encodeRequest(0), ArgumentError); // :332-335
		Assert.raises(function() s.encodeRequest(9999), ArgumentError); // :337-340
	}

	// encodeRequest :341-343：注册过的 cmd 返回带 cmdID 的 Protocol，
	// 请求对象经 importRequestObject 存入
	public function test_encodeRequest_returns_protocol_with_cmd() {
		var s = svc();
		var p = s.encodeRequest(CommandDefs.CMD_OPERATE_WATER, {place: "3"});
		Assert.equals(CommandDefs.CMD_OPERATE_WATER, p.cmdID);
		var boot = s.encodeRequest(CommandDefs.CMD_GET_BOOT_DATA, null);
		Assert.equals(CommandDefs.CMD_GET_BOOT_DATA, boot.cmdID);
	}

	// decodeResult :230-243：null 协议 / cmdID 0 / 解码失败 一律 null
	public function test_decodeResult_null_paths() {
		var s = svc();
		Assert.equals(null, s.decodeResult(null)); // :230-233
		Assert.equals(null, s.decodeResult(new Protocol(0))); // :234-238
		var noResp = new Protocol(CommandDefs.CMD_OPERATE_WATER);
		Assert.equals(null, s.decodeResult(noResp)); // :239-243（decodeForHttp null）
		var badJson = new Protocol(CommandDefs.CMD_OPERATE_WATER);
		badJson.importResponseObject('{"a":');
		Assert.equals(null, s.decodeResult(badJson)); // Protocol.as:49 解码异常→null
	}

	// decodeResult :253-257 错误 VO：m_result = errorType||code、
	// m_message = errorContent||direction||msg（AS3 || 短路）
	public function test_decodeResult_error_vo() {
		var s = svc();

		var noLogin = new Protocol(CommandDefs.CMD_OPERATE_WATER);
		noLogin.importResponseObject('{"errorType":"NoLoginError","errorContent":"请重新登录"}');
		var vo = s.decodeResult(noLogin);
		Assert.equals("NoLoginError", vo.m_result);
		Assert.equals("请重新登录", vo.m_message);
		Assert.equals("NoLoginError", Reflect.field(vo.m_extra, "errorType")); // :256 m_extra 原对象

		var codeOnly = new Protocol(CommandDefs.CMD_OPERATE_WATER);
		codeOnly.importResponseObject('{"code":"999","direction":"次数过多"}');
		vo = s.decodeResult(codeOnly);
		Assert.equals("999", vo.m_result); // errorType 缺省 → code
		Assert.equals("次数过多", vo.m_message); // errorContent 缺省 → direction

		// errorType 为空串（AS3 || 视为假）→ 落到 code
		var emptyType = new Protocol(CommandDefs.CMD_OPERATE_WATER);
		emptyType.importResponseObject('{"errorType":"","code":"42","direction":"d"}');
		vo = s.decodeResult(emptyType);
		Assert.equals("42", Std.string(vo.m_result));

		// 真实 PHP 错误回包：farmlandstatus_scarify.php:69 重复锄地
		//（code 是数字 0，AS3 里赋给 String 字段会转成 "0"，这里两侧都用 Std.string）
		var scarify = new Protocol(CommandDefs.CMD_OPERATE_SCARIFY);
		scarify.importResponseObject('{"farmlandIndex":1,"code":0,"poptype":1,"direction":"已经锄过这块地了哟！"}');
		vo = s.decodeResult(scarify);
		Assert.equals("0", Std.string(vo.m_result));
		Assert.equals("已经锄过这块地了哟！", vo.m_message);
		Assert.equals(1, Reflect.field(vo.m_extra, "farmlandIndex"));
	}

	// decodeResult :244-251 成功路径：按 m_parsers 分派，
	// CMD_GET_BOOT_DATA→StartupDataParser（:181）、
	// CMD_OPERATE_CHECKSTATUS→NullParser（:182，恒 null）、
	// 其余走 m_defaultParser=CommonParser（:25，m_extra 原样）
	public function test_decodeResult_dispatches_registered_parsers() {
		var s = svc();

		var boot = new Protocol(CommandDefs.CMD_GET_BOOT_DATA);
		boot.importResponseObject('{"serverTime":{"time":123},"farmlandStatus":[],"a":0,"b":0,"c":0,"d":0,"e":0,"exp":7,"user":{},"dog":{},"task":{},"weather":{},"items":{},"beast":{}}');
		var vo = s.decodeResult(boot);
		Assert.isTrue(Std.is(vo.m_extra, StartupData));
		Assert.equals(123, cast(vo.m_extra, StartupData)._serverTime); // StartupDataParser.as:36

		var check = new Protocol(CommandDefs.CMD_OPERATE_CHECKSTATUS);
		check.importResponseObject('{"code":"1"}');
		Assert.equals(null, s.decodeResult(check)); // NullParser.as:14-17

		var water = new Protocol(CommandDefs.CMD_OPERATE_WATER);
		water.importResponseObject('{"code":"1","humidity":1}');
		vo = s.decodeResult(water);
		Assert.equals("", vo.m_result); // CommonParser 不动 m_result（构造默认 ""）
		Assert.equals(1, Reflect.field(vo.m_extra, "humidity"));
	}

	// registerCmd :309-328：id 0 / url 空静默返回；新 id 注册成功可查；
	// 重复注册抛 ArgumentError "Command already exists."
	//（放在类末尾：它改共享单例的 m_cmdMap，后续只读用例不再依赖 cmd 10 的原值）
	public function test_registerCmd_rules() {
		var s = svc();
		s.registerCmd(0, "mod=zero"); // :311-314 静默
		s.registerCmd(9998, ""); // :315-318 静默
		s.registerCmd(9998, "mod=newcmd"); // :323
		Assert.equals("mod=newcmd", s.getRequestUrl(9998));
		Assert.raises(function() s.registerCmd(9998, "mod=dup"), ArgumentError); // :319-322
		Assert.raises(function() s.registerCmd(CommandDefs.CMD_OPERATE_WATER, "mod=dup"), ArgumentError); // 覆盖构造表里的 cmd 同样算重复
	}

	// registerCmdMap :209-224：整表覆写、不做重复检查（:220 直接赋值）、null 项跳过
	public function test_registerCmdMap_overwrites_without_duplicate_check() {
		var s = svc();
		s.registerCmdMap([{id: 9996, url: "mod=mapA"}, null, {id: 9997, url: "mod=mapB"}]);
		Assert.equals("mod=mapA", s.getRequestUrl(9996));
		Assert.equals("mod=mapB", s.getRequestUrl(9997));
		// 同 id 再次注册不抛，直接换值
		s.registerCmdMap([{id: 9996, url: "mod=mapA2"}]);
		Assert.equals("mod=mapA2", s.getRequestUrl(9996));
	}
}
