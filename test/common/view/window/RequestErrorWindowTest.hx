package common.view.window;

import common.view.window.RequestErrorWindow;
import com.qzone.corelib.net.RSLManager;
import common.CommonData;
import framework.net.core.RequestChecker;
import utest.Assert;

/**
 * RequestErrorWindow 纯逻辑（issue #41）：errorUrl 按 url 关键词 +
 * RequestChecker 限流记录拼五路文案（showed=false 路），及限流放行/登记
 * 副作用。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/window/
 * RequestErrorWindow.as（errorUrl :137-236：null/空早退 :141-144、
 * checkRequest==false → getInofByUrl 取记录 :146-148、title="温馨提示"
 * :151、harvest :152-164 / scrounge :165-177 / planting :178-190 /
 * scarify :191-203 / cgi_farm_index :204-216 的 showed=false 文案与
 * m_imgName、else 路 :217-222、m_imgName 非空恒以 "RequestErrorBG" 走
 * rslManager.requestClass :223-228、记录回写 showed=true :229）。
 * checkRequest 的门：RequestChecker.as:30-71（url 命中 harvest/scrounge/
 * planting/scarify 且记录 limitMinute>0、`serverTime/60 - time/60 <
 * limitMinute` → false）。
 *
 * eval 适配：rslManager 换 FakeRsl（真身 requestClass 走 applicationDomain
 * 必炸，探针实测替身可行）；RequestChecker._data 直钉匿名记录；serverTime
 * 用“先 0 后目标”两步复位（set_serverTime 对 |Δ|≤1 早退不清 _clientTime，
 * CommonData.as:126-134）。showed=true 各路与 else 路都要走 defaultError
 * （:76-100），其 getMaterial/panelTitle 在 eval 无素材必炸，属显示装配，
 * 留给 CI web-smoke。
 */
@:access(common.view.window.RequestErrorWindow)
@:access(framework.net.core.RequestChecker)
class RequestErrorWindowTest {
	public function new() {}

	private function pinRecord(url:String):Dynamic {
		// serverTime=120、time=0 → 2 < limitMinute 5，checkRequest 恒 false
		CommonData.serverTime = 0;
		CommonData.serverTime = 120;
		var record = {errorCount: 2, time: 0, limitMinute: 5, showed: false};
		RequestChecker._data = {};
		Reflect.setField(RequestChecker._data, url, record);
		return record;
	}

	private function restore() {
		RequestChecker._data = null;
		CommonData.rslManager = null;
		CommonData.serverTime = 0;
	}

	// :152-216：五路关键词文案表（showed=false；`\'` 转义后是单引号）
	public function test_errorUrl_keyword_copy_table() {
		var cases:Array<{url:String, info:String, img:String, why:String}> = [
			{
				url: "cgi_mync_harvest_farmland",
				info: "好友家临时举办了一场隆重的宴会，您受邀前往参<br/>加，<font color='#ff9900'>5</font>分钟后才会返回，暂时无法收获果实。",
				img: "RequestErrorBG",
				why: "harvest :156-157"
			},
			{
				url: "cgi_mync_scrounge_steal",
				info: "抱歉，您的准摘证已过期。村委会需要花<font color='#ff9900'>5</font>分钟为您重<br/>新办理，办理完毕之前您没有权限摘取好友的果实。",
				img: "RequestErrorZZ",
				why: "scrounge :169-170"
			},
			{
				url: "cgi_mync_planting_sow",
				info: "好友家临时举办了一场隆重的宴会，您受邀前往参<br/>加，<font color='#ff9900'>5</font>分钟后才会返回，暂时无法耕种田地。",
				img: "RequestErrorBG",
				why: "planting :182-183"
			},
			{
				url: "cgi_mync_scarify_dig",
				info: "和平天使降临，农场一片祥和宁静。大使感召您花<font color='#ff9900'>5</font>分<br/>钟和她一起祈祷世界和平，此期间需要您停止翻地。",
				img: "RequestErrorHP",
				why: "scarify :195-196"
			},
			{
				url: "cgi_farm_index?uin=123",
				info: "2012即将到来，黎明前的黑暗总是恐怖的，您被限制访问<br/>该好友的农场<font color='#ff9900'>5</font>分钟。诺亚方舟即将建成，等待希望的出现吧！",
				img: "RequestErrorFZ",
				why: "cgi_farm_index :208-209"
			}
		];
		for (c in cases) {
			var win = new RequestErrorWindow(null);
			var record = pinRecord(c.url);
			var fake = newFakeRsl();
			CommonData.rslManager = fake;
			win.errorUrl = c.url;
			Assert.equals(c.info, win.m_info, c.why);
			Assert.equals(c.img, win.m_imgName, c.why);
			Assert.equals("温馨提示", win.title, c.why); // :151
			// :223-228：素材类名恒为 "RequestErrorBG"（与 m_imgName 无关）
			Assert.equals(1, fake.calls.length, c.why);
			Assert.equals("RequestErrorBG", fake.calls[0], c.why);
			// :229：记录回写 showed=true
			Assert.isTrue(record.showed, c.why);
		}
		restore();
	}

	// :152-216：indexOf 链按声明序取第一命中（harvest 先于 scrounge）
	public function test_errorUrl_keyword_precedence() {
		var win = new RequestErrorWindow(null);
		var url = "cgi_mync_scrounge_harvest_mix";
		pinRecord(url);
		var fake = newFakeRsl();
		CommonData.rslManager = fake;
		win.errorUrl = url;
		Assert.equals("RequestErrorBG", win.m_imgName); // harvest 路的图
		Assert.isTrue(StringTools.startsWith(win.m_info, "好友家临时举办了一场隆重的宴会"));
		restore();
	}

	// :141-144：null/空串早退——文案不动、不碰 rsl
	public function test_errorUrl_null_or_empty_is_noop() {
		var win = new RequestErrorWindow(null);
		win.m_info = "sentinel";
		win.m_imgName = "sentinel";
		var fake = newFakeRsl();
		CommonData.rslManager = fake;
		win.errorUrl = null;
		win.errorUrl = "";
		Assert.equals("sentinel", win.m_info);
		Assert.equals("sentinel", win.m_imgName);
		Assert.equals(0, fake.calls.length);
		restore();
	}

	// 真身构造器带单例门（别的模块测试已把 instance 建起，见类头），空实例
	// 绕开；calls 显式初始化（空实例不跑字段默认值）
	private function newFakeRsl():FakeRsl {
		var fake = Type.createEmptyInstance(FakeRsl);
		fake.calls = [];
		return fake;
	}
}

// 替身：只记录 requestClass 的类名（真身走 applicationDomain，eval 必炸，
// 见类头）；模块级私有类，与本文件测试同包。
private class FakeRsl extends RSLManager {
	public var calls:Array<String> = [];

	override public function requestClass(param1:String, param2:Dynamic, param3:String = null, param4:Dynamic = null):Void {
		this.calls.push(param1);
	}
}
