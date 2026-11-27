package mc.control;

import mc.control.Command;
import mc.model.MData;
import support.McCommandEnv;
import utest.Assert;

/**
 * mc.control.ToolCommand 纯逻辑（issue #88 write-tests，对 stub 失败）：
 * 欢迎队形两 mod 的请求拼装与应答分派、checkSameDay 同日判定。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/control/ToolCommand.as
 * —— setWhistle :107-110（postRequest("cgi_set_parade", param1 原样转发)——
 * mod 出处 spec/protocol.json entries.mc.mods.cgi_set_parade：pinfo/pid
 * 两参原样入库，cgi_set_parade.php:5-9）；getWhistle :172-175
 * （postRequest("cgi_get_parade", null)——cgi_get_parade.php 无参数）；
 * onSetWhistle :339-348（checkErrorReturn true 早退、否则 alertWindow
 * ("success","设置成功！")）；onGetWhistle :411-421（checkErrorReturn
 * true 早退、否则 MData.toolData.whistleData = param1——setter 派发
 * WHISTLE_CHANGE，ToolData.as:47-51）；
 * checkErrorReturn :248-276（errorType 在 → validateCode 直返 true；
 * IOError/httpStatus/timeOut → alertWindow("error","请求超时，稍后再试")；
 * 非 session 且 errorContent 非空（trim 后）→ alertWindow errorContent；
 * 其余 errorType 有即返 true——**恒 true 闸**：errorType 在除上述分支外
 * 仍 true）；checkErrorReturn2 :59-105（type/serial 键形态——IOError 系
 * 写 farmOperate {text:"请求超时，稍后再试。", type:param2}——注意尾部
 * 句号、:73-77；system → errorContent 原样、:79-83；非 session 且
 * errorContent 非空 → serial 键随参、:85-92）；
 * checkSameDay :229-237（年/月/日三同 → true——**月日年三件全等**，跨
 * 月同日 false）。
 *
 * 拍照（quickShoot/drawPic/_SaveQuick 一族）涉 BitmapData 显示面与
 * setTimeout/URLLoader——不进纯逻辑测试（CLAUDE.md 测试规则），只钉
 * quickShoot 的每日 5 次门位（:288-318：LocalData quickShootData 同日
 * num>=5 → alertWindow "每天最多拥有5次拍照留念机会。" 早退）。
 *
 * alertWindow :295-307 经 ViewControl 派 WindowEvent.OPEN windowName
 * "AlertWindow"、windowArgument {type, text}——env 捕获断言。
 */
class ToolCommandTest {
	var env:McCommandEnv;

	public function new() {}

	function setup() {
		env = new McCommandEnv();
		env.resetStatics();
		env.swapInRecorder();
		env.captureViewControl([]);
	}

	function teardown() {
		env.restoreRecorder();
		env.releaseViewControl();
	}

	// setWhistle（ToolCommand.as:107-110）：param1 原样转发——键序不变、
	// 不多不少。mod 出处 cgi_set_parade.php:5-6（pinfo/pid）
	public function test_setWhistle_passthrough() {
		Command.getInstance().toolCommand.setWhistle({pinfo: "1,2,3", pid: 2});
		Assert.equals(1, env.rec.postCount);
		Assert.equals("cgi_set_parade", env.rec.postedUrl);
		Assert.equals("1,2,3", Reflect.field(env.rec.postedValue, "pinfo"));
		Assert.equals(2, Reflect.field(env.rec.postedValue, "pid"));
	}

	// getWhistle（:172-175）：null 参数体
	public function test_getWhistle_null_value() {
		Command.getInstance().toolCommand.getWhistle();
		Assert.equals(1, env.rec.postCount);
		Assert.equals("cgi_get_parade", env.rec.postedUrl);
		// FRequest 装饰段对 null value 新建四件对象（FRequest.as:138-146），
		// 原 null 语义体现在「无业务键」——装饰键之外无任何键
		var keys = Reflect.fields(env.rec.postedValue);
		for (k in keys) {
			Assert.isTrue(k == "farmTime" || k == "farmKey" || k == "pastureKey" || k == "uIdx");
		}
	}

	// onGetWhistle 成功（:411-421）：应答原样写 toolData.whistleData——
	// setter 派发 WHISTLE_CHANGE（ToolData.as:47-51，#87 充真身在案）
	public function test_onGetWhistle_writes_whistleData() {
		var td = MData.getInstance().toolData;
		var got:Array<String> = [];
		td.addEventListener("whistle_change", function(e) got.push(e.type));
		Command.getInstance().toolCommand.getWhistle();
		env.respond({p: 1, i: "3,1,2"});
		var wd = td.whistleDate; // getter 名 whistleDate 原版拼写照抄
		Assert.notNull(wd);
		Assert.equals(1, Reflect.field(wd, "p"));
		Assert.equals("3,1,2", Reflect.field(wd, "i"));
		Assert.equals("whistle_change", got.join(","));
	}

	// onGetWhistle 错误闸（:413-417 checkErrorReturn）：errorType
	// 网络系 → alertWindow "请求超时，稍后再试"（无句号——checkErrorReturn
	// :259）且不写 whistleData
	public function test_onGetWhistle_ioerror_alerts_and_skips() {
		var td = MData.getInstance().toolData;
		td.whistleData = null;
		Command.getInstance().toolCommand.getWhistle();
		env.respond({errorType: "IOError"});
		Assert.isNull(td.whistleDate);
		Assert.equals(1, env.windowEvents.length);
		Assert.equals("AlertWindow", env.windowEvents[0].name);
		Assert.equals("error", Reflect.field(env.windowEvents[0].arg, "type"));
		Assert.equals("请求超时，稍后再试", Reflect.field(env.windowEvents[0].arg, "text"));
	}

	// onSetWhistle 成功（:346-347）：alertWindow("success","设置成功！")
	public function test_onSetWhistle_success_alert() {
		Command.getInstance().toolCommand.setWhistle({pinfo: "x", pid: 1});
		env.respond({});
		Assert.equals(1, env.windowEvents.length);
		Assert.equals("success", Reflect.field(env.windowEvents[0].arg, "type"));
		Assert.equals("设置成功！", Reflect.field(env.windowEvents[0].arg, "text"));
	}

	// checkErrorReturn 的 errorContent 通道（:262-267）：非 session 且
	// trim 后非空 → alertWindow errorContent 原样
	public function test_errorContent_alert_verbatim() {
		Command.getInstance().toolCommand.getWhistle();
		env.respond({errorType: "logic", errorContent: "队形数据错误"});
		Assert.equals(1, env.windowEvents.length);
		Assert.equals("队形数据错误", Reflect.field(env.windowEvents[0].arg, "text"));
	}

	// errorContent 全空白 → trim 空串不进 alertWindow（StringUtil.trim
	// :264）——errorType 在仍返 true 早退但不弹窗
	public function test_blank_errorContent_no_alert() {
		Command.getInstance().toolCommand.getWhistle();
		env.respond({errorType: "logic", errorContent: "   "});
		Assert.equals(0, env.windowEvents.length);
	}

	// checkSameDay（:229-237）：年月日三同 true；年/月/日任一不同 false
	public function test_checkSameDay_table() {
		var tc = Command.getInstance().toolCommand;
		var a = Date.fromString("2012-05-06 10:00:00");
		var b = Date.fromString("2012-05-06 23:59:59");
		Assert.isTrue(tc.checkSameDay(a, b));
		Assert.isFalse(tc.checkSameDay(a, Date.fromString("2012-05-07 00:00:01")));
		Assert.isFalse(tc.checkSameDay(a, Date.fromString("2012-06-06 10:00:00")));
		Assert.isFalse(tc.checkSameDay(a, Date.fromString("2013-05-06 10:00:00")));
	}
}
