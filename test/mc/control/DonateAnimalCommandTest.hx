package mc.control;

import common.INI;
import mc.control.DonateAnimalCommand;
import mc.model.FarmData;
import mc.model.MData;
import support.McCommandEnv;
import utest.Assert;

/**
 * mc.control.DonateAnimalCommand 纯逻辑（issue #88 write-tests，对 stub
 * 失败）：爱心捐赠的前置守卫（状态拦截/确认窗文案）与 cgi_donate_animal
 * 请求拼装/应答分派。
 *
 * 期望值出处：
 * legacy/decompiled/Master2_v_142/scripts/mc/control/DonateAnimalCommand.as
 * —— donateAnimal :66-120（param1 null/data null → 早退；status==
 * ANIMAL_SHENGCHAN(4) → farmOperate "生产中动物不能操作！"；status==
 * ANIMAL_SHOUHUO(6) → "成熟动物请收获！"——两文案 type "animal"、serial
 * 取 param1.data.serial；其余状态开 ConfirmWindow：文案模板 :84 逐字
 * "动物还没有成熟，爱心捐赠将获得感谢金<b><font color=\"#4DA337\">" +
 * price/2 + "</font></b>金币。<BR/>您确定要这么做吗？<BR/>温馨提示：
 * 爱心捐赠不获得经验。"——price 出处 mc_data animals 配置（fixture
 * mc-ini.xml animal 1001 price="700" 抄录 mc_data.php:5575——price/2=350）；
 * 窗 width 440、confirmEnable true、data={text:文案}）；
 * donateRequest :51-60（_isDonating 闸——true 早退；postRequest(
 * "cgi_donate_animal", {serial:param1}, donateResponse)，serial 出处
 * spec/protocol.json entries.mc.mods.cgi_donate_animal（1 基序号，
 * cgi_donate_animal.php:5 (int)$_REQUEST['serial']）；
 * donateResponse :122-152（errorCode+errorContent 双键在 →
 * floatWindow(errorContent) 早退；cId/direction/money 三键齐 →
 * addMoney+floatWindow(direction)+onDonateSuccess——成功应答形状出处
 * cgi_donate_animal.php:59 echo '{"cId":…,"direction":"爱心捐赠成功！",
 * "money":…,"serial":…}'）；onDonateSuccess :154-175（cId==0 或
 * serial==0 早退；与 _targetAnimal.data 的 cId/serial 不符早退；
 * plands.removeAnimal + ViewControl 派 Event("animal_change")）。
 *
 * Animal/Pasturelands 是场景片签名 stub（issue #88 描述：沿用既有 stub
 * 或补落签名面 stub，本片不翻）——donateAnimal 入参 Animal 在测试里以
 * 签名面空壳驱动（只需 .data 字段面）。ConfirmWindow 素材（DonateTitle）
 * 属显示层不进纯逻辑断言。
 */
class DonateAnimalCommandTest {
	static var FIXTURE:String = sys.io.File.getContent("test/fixtures/mc-ini.xml");

	var env:McCommandEnv;

	public function new() {}

	function setup() {
		env = new McCommandEnv();
		env.resetStatics();
		env.swapInRecorder();
		env.captureViewControl(["animal_change"]);
		// price 查询走 GetCropID.getAnimalInfo(cId).@price——INI fixture
		// 注入 + 静态缓存复位（GetCropIDTest 同款手法）
		INI.getInstance().data = Xml.parse(FIXTURE);
		resetCropXml();
	}

	function teardown() {
		env.restoreRecorder();
		env.releaseViewControl();
	}

	// 状态守卫（DonateAnimalCommand.as:70-81）：SHENGCHAN(4) 与
	// SHOUHUO(6) 两态不开窗不发请求，只写 farmOperate——文案逐字、
	// type "animal"、serial 原动物序号。FarmData 状态常量
	// ANIMAL_SHENGCHAN/ANIMAL_SHOUHUO 出处 FarmData.as:59/63
	public function test_donateAnimal_shengchan_blocked() {
		var fd = MData.getInstance().farmData;
		fd.farmOperate = null;
		var animal = makeAnimal(1502, 3, FarmData.ANIMAL_SHENGCHAN);
		DonateAnimalCommand.getInstance().donateAnimal(animal);
		var op = fd.farmOperate;
		Assert.notNull(op);
		Assert.equals("生产中动物不能操作！", Reflect.field(op, "text"));
		Assert.equals("animal", Reflect.field(op, "type"));
		Assert.equals(3, Reflect.field(op, "serial"));
		Assert.equals(0, env.rec.postCount);
		Assert.equals(0, env.windowEvents.length);
	}

	public function test_donateAnimal_shouhuo_blocked() {
		var fd = MData.getInstance().farmData;
		fd.farmOperate = null;
		var animal = makeAnimal(1502, 7, FarmData.ANIMAL_SHOUHUO);
		DonateAnimalCommand.getInstance().donateAnimal(animal);
		Assert.equals("成熟动物请收获！", Reflect.field(fd.farmOperate, "text"));
		Assert.equals(0, env.rec.postCount);
		Assert.equals(0, env.windowEvents.length);
	}

	// 生长期动物 → 开确认窗（:82-119）：经 WControl.open 派 WindowEvent.
	// OPEN；文案 price/2 拼进模板——fixture 1001 price="700" → 350。
	// 文案期望出处 mc-ini.xml（mc_data.php:5575）+ 模板 :84
	public function test_donateAnimal_normal_opens_confirm_with_price_half() {
		var animal = makeAnimal(1001, 2, FarmData.ANIMAL_SHENGZHANG);
		DonateAnimalCommand.getInstance().donateAnimal(animal);
		Assert.equals(1, env.windowEvents.length);
		Assert.equals(WindowEvent_OPEN(), env.windowEvents[0].kind);
		var win:Dynamic = env.windowEvents[0].win;
		Assert.notNull(win);
		var data:Dynamic = win.data;
		Assert.notNull(data);
		Assert.equals("动物还没有成熟，爱心捐赠将获得感谢金<b><font color=\"#4DA337\">350</font></b>金币。<BR/>您确定要这么做吗？<BR/>温馨提示：爱心捐赠不获得经验。",
			Reflect.field(data, "text"));
		Assert.equals(0, env.rec.postCount);
	}

	// 确认后发请求（onConfirmDonate :143-152 → donateRequest :51-60）：
	// mod 串逐字 "cgi_donate_animal"，参数体仅 serial 一键、取目标动物
	// data.serial。confirmFn 触发：窗的 confirmFn 是公开 setter
	// （ConfirmWindow.as 成员面），测试直接调窗上的 confirmFn——等价
	// 用户点确定（窗按钮显示层不进单测）
	public function test_confirm_posts_serial() {
		var animal = makeAnimal(1001, 5, FarmData.ANIMAL_SHENGZHANG);
		DonateAnimalCommand.getInstance().donateAnimal(animal);
		var win:Dynamic = env.windowEvents[0].win;
		win.confirmFn();
		Assert.equals(1, env.rec.postCount);
		Assert.equals("cgi_donate_animal", env.rec.postedUrl);
		Assert.equals(5, Reflect.field(env.rec.postedValue, "serial"));
	}

	// _isDonating 闸（:52-55）：请求未应答时第二次 donateRequest 不出网
	public function test_donateRequest_pending_gate() {
		var animal = makeAnimal(1001, 5, FarmData.ANIMAL_SHENGZHANG);
		DonateAnimalCommand.getInstance().donateAnimal(animal);
		var win:Dynamic = env.windowEvents[0].win;
		win.confirmFn();
		win.confirmFn(); // 闸内：第二发不出网
		Assert.equals(1, env.rec.postCount);
	}

	// 应答成功（:122-152 + cgi_donate_animal.php:59）：cId/direction/
	// money 三键齐 → addMoney（host.money 累加）、animal_change 派发、
	// _isDonating 复位。cId/serial 与目标动物一致才移除（onDonateSuccess
	// :160-165）——Host money 累加面：addMoney 的 money 是 price/2=350
	public function test_donateResponse_success_adds_money_and_dispatches() {
		var md = MData.getInstance().mainData;
		md.host = {"uId": "100", "money": 1000, "userName": "me"};
		var animal = makeAnimal(1001, 5, FarmData.ANIMAL_SHENGZHANG);
		DonateAnimalCommand.getInstance().donateAnimal(animal);
		var win:Dynamic = env.windowEvents[0].win;
		win.confirmFn();
		env.plainEvents = [];
		// cgi_donate_animal.php:59 echo 形状（money=price/2）
		env.respond({cId: 1001, direction: "爱心捐赠成功！", money: 350, serial: 5});
		Assert.equals(1350, Reflect.field(md.host, "money"));
		Assert.isTrue(env.plainEvents.indexOf("animal_change") != -1);
		// 闸复位：应答后可再发
		env.rec.postCount = 0;
		win.confirmFn();
		Assert.equals(1, env.rec.postCount);
	}

	// 应答 cId/serial 与目标不符 → 不移除不派 animal_change
	// （onDonateSuccess :168-171 早退）——但 addMoney/floatWindow 在前
	// 已执行（:145-150），money 仍累加：原文顺序如此照抄
	public function test_donateResponse_mismatched_serial_no_animal_change() {
		var md = MData.getInstance().mainData;
		md.host = {"uId": "100", "money": 1000, "userName": "me"};
		var animal = makeAnimal(1001, 5, FarmData.ANIMAL_SHENGZHANG);
		DonateAnimalCommand.getInstance().donateAnimal(animal);
		var win:Dynamic = env.windowEvents[0].win;
		win.confirmFn();
		env.plainEvents = [];
		env.respond({cId: 1001, direction: "爱心捐赠成功！", money: 350, serial: 9});
		Assert.equals(1350, Reflect.field(md.host, "money"));
		Assert.equals(-1, env.plainEvents.indexOf("animal_change"));
	}

	// errorCode+errorContent 双键 → 早退（:135-139）：不加钱、不派
	// animal_change
	public function test_donateResponse_error_pair_early_exit() {
		var md = MData.getInstance().mainData;
		md.host = {"uId": "100", "money": 1000, "userName": "me"};
		var animal = makeAnimal(1001, 5, FarmData.ANIMAL_SHENGZHANG);
		DonateAnimalCommand.getInstance().donateAnimal(animal);
		var win:Dynamic = env.windowEvents[0].win;
		win.confirmFn();
		env.plainEvents = [];
		env.respond({errorCode: 1, errorContent: "动物状态已变化"});
		Assert.equals(1000, Reflect.field(md.host, "money"));
		Assert.equals(-1, env.plainEvents.indexOf("animal_change"));
	}

	// param1 null/data null 早退（:67-70）——Animal 签名面 stub 的 data
	// 为 null 时不开窗不发请求
	public function test_donateAnimal_null_data_early_exit() {
		var animal = makeAnimal(1001, 1, FarmData.ANIMAL_SHENGZHANG);
		Reflect.setField(animal, "data", null);
		DonateAnimalCommand.getInstance().donateAnimal(animal);
		Assert.equals(0, env.rec.postCount);
		Assert.equals(0, env.windowEvents.length);
	}

	// Animal 签名面替身：测试只需 .data {cId, serial, status} 字段面
	// （data 是真身 Animal 的 public getter，场景片充真身前的最小壳）。
	// 类型上 donateAnimal(param1:Animal)——Haxe 静态类型要求真 Animal
	// 或子类实例；stub 期签名面以 Dynamic 构造经 cast 传入，implement
	// 落地后以真 Animal 空构造 + data 注入替换（测试语义不变）
	static function makeAnimal(cId:Int, serial:Int, status:Int):Dynamic {
		return {
			data: {
				cId: cId,
				serial: serial,
				status: status
			}
		};
	}

	static function WindowEvent_OPEN():String {
		return mc.events.WindowEvent.OPEN;
	}

	@:access(mc.view.farm.GetCropID)
	static function resetCropXml() {
		mc.view.farm.GetCropID._xml = null;
	}
}
