package common.view.window;

import common.Consts;
import common.view.window.RedUpWindow;
import common.CommonData;
import common.Session;
import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.RadioButton;
import com.qzone.qui.controls.TabBar;
import com.qzone.qui.makers.RadioGroup;
import com.qzone.qfa.events.CommandEvent;
import entities.Player;
import framework.net.CommandDefs;
import framework.net.vo.ServiceResultVO;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import utest.Assert;

/**
 * RedUpWindow 纯逻辑（issue #41）：红/黑土地升级窗的数据提取、确认回调
 * 参数拼装、黑土地升级回报的文案装配与错误回落。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/window/
 * RedUpWindow.as（ctor :100-116 常量；setData :663-721：text :665-668、
 * _redEnable 按 ecode :669-673（-30120/-30121/-30123 关）、confirmFn
 * :674-681、-30120 无金牌页签时 selectedIndex=1 :683-695、否则复位 0 并
 * 上树 :696-707；updateNote :839-857：ecode ∈ {0,-30122,-30123} 时按
 * VIP 态写 _adText（openYellowVIP :861 “VIP特权…” / renewalsYellowVIP
 * :923 “您是VIP…”）且 _showAdFlag=true，否则 _showAdFlag=false；
 * confirmButtonClick :396-430：元宝单选→1 :407、黑页签冷却中→第 4 参
 * true :410-413、按页签 0/1/2 三路回调 :414-425、用后清 _confirmFn +
 * super.close() :427-428；onBlackUp :312-394：报文模板 :328-334、金币
 * 不足或 ecode=-30342 追加翻倍句 :329-332、_targetBlack/_cd :327/:335、
 * 冷却外 showBlackTip("连续升级黑土地时…") :354、金币不足落 :360、等级
 * 不够落 :386、-30342 落 Language.L["BlackUpNoLand"] :375、ecode==0
 * 才点亮按钮 :367-370；onNetError :926-950：CMD_UPGRADE_BLACK+op==0 →
 * "获取服务器数据失败！"+_cd=0；onClosed :827-837 复位四态）。
 *
 * eval 适配（DogFoodWindowTest 先例）：init() 装配的 _tabNav/_newIcon/
 * _alertText/_confirmButton 钉等价物；_tabNav 用 FakeTabBar（真身
 * set_selectedIndex 触 viewStack :88-90，无装配必炸；空实例 + 只写
 * _currentIndex，探针实测可 addChild/读写）。onBlackUp 只测 cd ≤
 * serverTime 的路——cd > serverTime 会 new Timer(1000).start()（:338-344），
 * eval 解释器挂死（probe 实测）。serverTime 用“先 0 后目标”两步复位
 * （set 对 |Δ|≤1 早退不清 _clientTime，CommonData.as:126-134）。
 * confirmButtonClick 经 ConfirmWindow.keyEnter 触发（:214-217 直落），
 * 事件数据直钉 BaseWindow._data，绕开 setData 全链。
 */
@:access(common.view.window.RedUpWindow)
@:access(common.view.window.ConfirmWindow)
@:access(common.view.window.BaseWindow)
class RedUpWindowTest {
	public function new() {}

	private function buildWindow():RedUpWindow {
		var win = new RedUpWindow(null);
		win._tabNav = Type.createEmptyInstance(FakeTabBar);
		win._newIcon = new MovieClip();
		win._alertText = new TextField();
		win._confirmButton = new Button();
		win._adText = new TextField();
		win._isFirst = true;
		Session.getInstance().host = new Player({});
		win.ss = Session.getInstance();
		return win;
	}

	private function pinServerTime(v:Float) {
		CommonData.serverTime = 0;
		CommonData.serverTime = v;
	}

	private function commandEvent(extra:Dynamic):CommandEvent {
		var vo = new ServiceResultVO();
		vo.m_extra = extra;
		var ev = new CommandEvent("net");
		ev.result = vo;
		return ev;
	}

	// :100-116：构造器常量
	public function test_ctor_constants() {
		var win = new RedUpWindow(null);
		Assert.equals(465, win.width);
		Assert.equals(445, win.height); // HEIGHT :54
		Assert.equals("升级土地", win.title);
		Assert.equals(Consts.WINDOW_NAME_UPGRADE_RED, win.windowName);
		Assert.equals("", win._redText);
		Assert.isFalse(win._redEnable);
		Assert.isTrue(win._checkBlack);
		Assert.equals(-1, win._targetBlack);
		Assert.equals(0, win._cd);
	}

	// :663-721：setData 按 ecode 定红土地可用态与页签落点
	public function test_setData_red_enable_and_tab_by_ecode() {
		var cases:Array<{ecode:Int, enable:Bool, tab:Int, why:String}> = [
			{ecode: -30120, enable: false, tab: 1, why: "-30120 直落黑页签 :686"},
			{ecode: -30121, enable: false, tab: 0, why: "-30121 复位红页签 :700"},
			{ecode: -30123, enable: false, tab: 0, why: "-30123 只关可用态 :672"},
			{ecode: 0, enable: true, tab: 0, why: "0 可用 :669"},
			{ecode: -30122, enable: true, tab: 0, why: "-30122 不在关闭名单"}
		];
		for (c in cases) {
			var win = buildWindow();
			var fn = function() {};
			win.data = {ecode: c.ecode, text: "红土地升级说明", confirmFn: fn};
			Assert.equals(c.enable, win._redEnable, c.why);
			Assert.equals(c.tab, win._tabNav.selectedIndex, c.why);
			Assert.equals("红土地升级说明", win._redText, c.why); // :667
			Assert.isTrue(Reflect.compareMethods(win._confirmFn, fn), c.why); // :676
		}
		// 缺键：confirmFn 清空、text 保留旧值（:665-681 都是有键才写）
		var win2 = buildWindow();
		win2._redText = "旧文案";
		win2.data = {ecode: -30120};
		Assert.isNull(win2._confirmFn);
		Assert.equals("旧文案", win2._redText);
	}

	// :839-857：updateNote 的 VIP 文案两态与非名单关闭
	public function test_setData_updateNote_vip_copy() {
		// ecode 0 + 非VIP（yellowstatus 0）→ 开通文案 :861
		var win = buildWindow();
		Session.getInstance().host._yellowstatus = 0;
		win._adText.htmlText = "sentinel";
		win.data = {ecode: 0};
		Assert.isTrue(win._showAdFlag);
		Assert.equals("VIP特权升级红土地无需等级限制。", win._adText.text);
		// ecode 0 + VIP（yellowstatus>0 且 yellowlevel>0）→ 续费文案 :923
		var win2 = buildWindow();
		Session.getInstance().host._yellowstatus = 1;
		Session.getInstance().host._yellowlevel = 3;
		win2._adText.htmlText = "sentinel";
		win2.data = {ecode: 0};
		Assert.isTrue(win2._showAdFlag);
		Assert.equals("您是VIP，升级红土地无等级限制。", win2._adText.text);
		// ecode 不在 {0,-30122,-30123} → 不写文案、_showAdFlag=false
		var win3 = buildWindow();
		win3._adText.htmlText = "sentinel";
		win3.data = {ecode: -30121};
		Assert.isFalse(win3._showAdFlag);
		Assert.equals("sentinel", win3._adText.text);
	}

	// :396-430：confirmButtonClick 的回调参数表（经 keyEnter :214-217 触发）
	public function test_confirmButtonClick_argument_assembly() {
		// 页签 0：红土地路，第 3 参取 data["place"] :414-417
		var win = buildWindow();
		win._data = {place: 7};
		var got = captureConfirm(win);
		Assert.same([0, 0, 7, false], got);

		// 页签 1 无单选组：第 2 参 0、第 3 参 _targetBlack :420
		var win2 = buildWindow();
		win2._tabNav.selectedIndex = 1;
		win2._targetBlack = 5;
		win2._cd = 0;
		Assert.same([1, 0, 5, false], captureConfirm(win2));

		// 页签 1 选中元宝单选：第 2 参 1（:405-408）
		var win3 = buildWindow();
		win3._tabNav.selectedIndex = 1;
		win3._targetBlack = 5;
		win3._cd = 0;
		var jb = new RadioButton("100000 金币");
		var qb = new RadioButton("12 元宝");
		var rg = new RadioGroup();
		rg.addTarget(jb);
		rg.addTarget(qb);
		rg.selectedTarget = qb;
		win3._radioGroup = rg;
		win3._rbtnQB = qb;
		Assert.same([1, 1, 5, false], captureConfirm(win3));

		// 页签 1 且 _cd 在冷却中（> serverTime）：第 4 参 true :410-413
		var win4 = buildWindow();
		win4._tabNav.selectedIndex = 1;
		win4._targetBlack = 5;
		win4._cd = 1000;
		pinServerTime(120);
		Assert.same([1, 0, 5, true], captureConfirm(win4));

		// 页签 2（金牌）：第 2 参恒 0，冷却判定只看页签 1 → false :424
		var win5 = buildWindow();
		win5._tabNav.selectedIndex = 2;
		win5._targetBlack = 5;
		win5._cd = 1000;
		pinServerTime(120);
		Assert.same([2, 0, 5, false], captureConfirm(win5));
	}

	// :427-428 + :400：回调后清 _confirmFn、关窗恰一次；按钮禁用全拦
	public function test_confirmButtonClick_clears_fn_closes_once_and_gates_on_disabled() {
		var win = buildWindow();
		win._data = {place: 1};
		var closeCount = 0;
		win.addEventListener(Event.CLOSE, function(e) closeCount++);
		var called = 0;
		win._confirmFn = function(a, b, c, d) called++;
		win.keyEnter(new KeyboardEvent(KeyboardEvent.KEY_UP));
		Assert.equals(1, called);
		Assert.equals(1, closeCount); // super.close() :428
		Assert.isNull(win._confirmFn); // :427 用后即清

		// _confirmFn 已清：只关窗不再回调
		win.keyEnter(new KeyboardEvent(KeyboardEvent.KEY_UP));
		Assert.equals(1, called);
		Assert.equals(2, closeCount);

		// 按钮禁用：:400 门全拦
		var win2 = buildWindow();
		win2._data = {place: 1};
		win2._confirmButton.enabled = false;
		var closeCount2 = 0;
		win2.addEventListener(Event.CLOSE, function(e) closeCount2++);
		var called2 = 0;
		win2._confirmFn = function(a, b, c, d) called2++;
		win2.keyEnter(new KeyboardEvent(KeyboardEvent.KEY_UP));
		Assert.equals(0, called2);
		Assert.equals(0, closeCount2);
	}

	// :312-394：onBlackUp 报文与提示装配（只测 cd ≤ serverTime，见类头）
	public function test_onBlackUp_assembles_message_and_tips() {
		var templateHead = "升级第<font color=\"#FF6600\">4</font>块黑土地需要<font color=\"#FF6600\">20</font>级，"
			+ "您可以使用农场<font color=\"#FF6600\">金币</font>或者<font color=\"#FF6600\">元宝</font>升级黑土地。";
		var doubling = "连续升级黑土地时升级价格将会翻倍增长。";

		// A：钱够级够 ecode 0：模板原文、冷却外提示落翻倍句、按钮点亮
		var win = buildWindow();
		Session.getInstance().host._money = 200000;
		Session.getInstance().host._exp = 50000; // level 21 ≥ 20
		pinServerTime(120);
		win._checking = true;
		win.onBlackUp(commandEvent({place: 3, level: 20, money: 100000, cd: 0, qd: 12, yqd: 15, ecode: 0}));
		Assert.isFalse(win._checking); // :314
		Assert.equals(3, win._targetBlack); // :327
		Assert.equals(0, win._cd); // :335
		Assert.equals("<font size='14'>" + templateHead + "请您选择：</font>", win._alertText.htmlText); // :328-334
		Assert.equals(doubling, win._tipText.htmlText); // :354
		Assert.isTrue(win._confirmButton.enabled); // :367-370
		Assert.notNull(win._rbtnJB); // showRadioGroup 建组 :498-551
		Assert.notNull(win._rbtnQB);
		Assert.notNull(win._radioGroup);
		Assert.equals(win._rbtnJB, win._radioGroup.selectedTarget); // 钱够选金币 :551

		// B：金币不足：模板追加翻倍句、提示落金币不足（覆盖 :354 的翻倍句）
		var winB = buildWindow();
		Session.getInstance().host._money = 50000;
		Session.getInstance().host._exp = 50000;
		pinServerTime(120);
		winB.onBlackUp(commandEvent({place: 3, level: 20, money: 100000, cd: 0, qd: 12, yqd: 15, ecode: 0}));
		Assert.equals("<font size='14'>" + templateHead + doubling + "请您选择：</font>", winB._alertText.htmlText); // :329-332
		Assert.equals("您的金币不足，试试用元宝升级黑土地吧！", winB._tipText.htmlText); // :360
		Assert.equals(winB._rbtnQB, winB._radioGroup.selectedTarget); // 钱不够选元宝 :551

		// C：等级不够（exp 0 → level 0 < 20）：提示落等级句
		var winC = buildWindow();
		Session.getInstance().host._money = 200000;
		Session.getInstance().host._exp = 0;
		pinServerTime(120);
		winC.onBlackUp(commandEvent({place: 3, level: 20, money: 100000, cd: 0, qd: 12, yqd: 15, ecode: 0}));
		Assert.equals("您的等级不够。", winC._tipText.htmlText); // :386

		// D：ecode -30342：模板追加翻倍句、提示落 BlackUpNoLand、按钮不点亮
		var winD = buildWindow();
		Session.getInstance().host._money = 200000;
		Session.getInstance().host._exp = 50000;
		pinServerTime(120);
		winD._confirmButton.enabled = false;
		winD.onBlackUp(commandEvent({place: 3, level: 20, money: 100000, cd: 0, qd: 12, yqd: 15, ecode: -30342}));
		Assert.equals("<font size='14'>" + templateHead + doubling + "请您选择：</font>", winD._alertText.htmlText);
		Assert.equals("亲爱的农友，您需要先升级红土地，再把红土地升级为黑土地哦。", winD._tipText.htmlText); // :375 = Language.as:226
		Assert.isFalse(winD._confirmButton.enabled); // ecode != 0 不点亮 :367

		// E：result null 早退——_checking 已清、其余不动 :316-319
		var winE = buildWindow();
		winE._checking = true;
		winE._targetBlack = 99;
		var ev = commandEvent({});
		ev.result = null;
		winE.onBlackUp(ev);
		Assert.isFalse(winE._checking);
		Assert.equals(99, winE._targetBlack);
	}

	// :926-950：onNetError 只认 CMD_UPGRADE_BLACK + op 0
	public function test_onNetError_resets_cd_on_upgrade_black_query() {
		var win = buildWindow();
		win._checking = true;
		win._cd = 77;
		win.onNetError(commandEventWithBody({}, {cmdID: CommandDefs.CMD_UPGRADE_BLACK, __body: {op: 0}}));
		Assert.isFalse(win._checking); // :929
		Assert.equals("获取服务器数据失败！", win._alertText.htmlText); // :946
		Assert.equals(0, win._cd); // :947

		// cmdID 不匹配：全不动
		var win2 = buildWindow();
		win2._cd = 77;
		win2._alertText.htmlText = "sentinel";
		win2.onNetError(commandEventWithBody({}, {cmdID: 999, __body: {op: 0}}));
		Assert.equals(77, win2._cd);
		Assert.equals("sentinel", win2._alertText.htmlText);

		// op != 0：全不动
		var win3 = buildWindow();
		win3._cd = 77;
		win3.onNetError(commandEventWithBody({}, {cmdID: CommandDefs.CMD_UPGRADE_BLACK, __body: {op: 1}}));
		Assert.equals(77, win3._cd);
	}

	// :827-837：关窗复位四态（_timer null 不触 stop）
	public function test_onClosed_resets_state() {
		var win = buildWindow();
		win._checkBlack = false;
		win._checking = true;
		win._redText = "残留";
		win._redEnable = true;
		win.onClosed(null);
		Assert.isTrue(win._checkBlack);
		Assert.isFalse(win._checking);
		Assert.equals("", win._redText);
		Assert.isFalse(win._redEnable);
	}

	// 触发一次确认并抓回调四参（keyEnter → confirmButtonClick）
	private function captureConfirm(win:RedUpWindow):Array<Dynamic> {
		var got:Array<Dynamic> = null;
		var calls = 0;
		win._confirmFn = function(a, b, c, d) {
			calls++;
			got = [a, b, c, d];
		};
		win.keyEnter(new KeyboardEvent(KeyboardEvent.KEY_UP));
		Assert.equals(1, calls, "confirmFn 恰调一次");
		Assert.isNull(win._confirmFn, "用后清空 :427");
		return got;
	}

	private function commandEventWithBody(extra:Dynamic, body:Dynamic):CommandEvent {
		var ev = commandEvent(extra);
		ev.body = body;
		return ev;
	}
}

// TabBar 替身：真身 set_selectedIndex 触 viewStack（TabBar.as:88-90），eval
// 无装配必炸；空实例 + 只写 _currentIndex（探针实测可 addChild、读写可行）。
private class FakeTabBar extends TabBar {
	override private function set_selectedIndex(param1:Int):Int {
		return this._currentIndex = param1;
	}
}
