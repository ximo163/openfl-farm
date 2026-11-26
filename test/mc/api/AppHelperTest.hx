package mc.api;

import com.minutes.net.HTTPRequest;
import mc.api.AppHelper;
import openfl.display.Sprite;
import openfl.filters.ColorMatrixFilter;
import support.RecordingRequest;
import utest.Assert;

/**
 * mc.api.AppHelper 纯逻辑（issue #87 write-tests，对 stub 失败）：弹窗
 * 命令表、禁用滤镜矩阵、sendRequest 的 mod 派发与恒 true 返回。
 *
 * 结构注记：utest 在 eval 目标上 setup/teardown 抛异常会让 handler 永不完成
 * （整个测试进程死等——GameProxyTest 同款），所以 `new AppHelper()`（stub
 * ctor 掷 not implemented）放各用例方法体内而不放 setup；implement 充真身
 * 后构造不掷，路径照旧。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/api/AppHelper.as
 * —— getDisableFilter :43-50（懒建单例、矩阵
 * [0.3,0.6,0.082,0,0, 0.3,0.6,0.082,0,0, 0.3,0.6,0.082,0,0, 0,0,0,1,0]）；
 * sendRequest :76-80（`_fr.postRequest(this._cmds[param1],param2,param3)`
 * ——**不带 act 第四参**，熔断通道（RequestManager.checkAction）因此不可
 * 经 sendRequest 触发，恒返 true——网络层失败不归本方法管）；
 * registerNetCommand :93-96（_cmds[uint]=mod 串）；hidePopUp
 * :82-91（有 parent 才 removeChild）；centerPopUp :31-41（static private，
 * 读 param2.stage——eval 无真 stage，见下）。
 *
 * **删除项备录**（round 1 review 驳回处置）：round 1 的
 * test_centerPopUp_documented 是 isTrue(true) 占位，本组已删——centerPopUp
 * 居中数学依赖真 stage（param2.stage.stageWidth/Height），eval 无真
 * stage、注入假 stage 需贯穿 ViewControl.windowsLayer 链路，超出纯逻辑
 * 单测边界；该面属画面层居中布局，由 CI web-build/web-smoke 的场景连拍
 * 比对覆盖，注释备录公式：x=stageWidth/2-width/2、y=stageHeight/2-height/2、
 * y<0 钳 0（:33-40）。
 *
 * sendRequest 走 RecordingRequest 截获（support/RecordingRequest.hx——
 * Type.createEmptyInstance 跳过 HTTPRequest 真身 ctor 的常驻 Timer，
 * 覆写 postRequest 只记不出网）——mod 串拼装与恒 true 因此真钉，
 * 不再是注释备录。
 */
@:access(mc.api.AppHelper)
@:access(com.minutes.net.HTTPRequest)
class AppHelperTest {
	public function new() {}

	// 禁用滤镜矩阵（AppHelper.as:43-50）：懒建 + 矩阵逐字
	public function test_disable_filter_matrix() {
		var helper = new AppHelper();
		var filters = helper.getDisableFilter();
		Assert.equals(1, filters.length);
		var cmf:ColorMatrixFilter = cast filters[0];
		Assert.notNull(cmf);
		// 矩阵逐字（:46 的 20 元）
		var expect = [0.3, 0.6, 0.082, 0, 0, 0.3, 0.6, 0.082, 0, 0, 0.3, 0.6, 0.082, 0, 0, 0, 0, 0, 1, 0];
		var actual:Array<Float> = cast cmf.matrix;
		for (i in 0...20) {
			Assert.floatEquals(expect[i], actual[i], 'matrix[$i]');
		}
		// 懒建缓存：二次调用同一实例
		Assert.equals(filters, helper.getDisableFilter());
	}

	// 命令表注册与查询（:76-80/:93-96）：registerNetCommand 后 _cmds 可查
	public function test_register_net_command() {
		var helper = new AppHelper();
		helper.registerNetCommand(1, "cgi_enter");
		helper.registerNetCommand(2, "cgi_steal");
		Assert.equals("cgi_enter", helper._cmds[1]);
		Assert.equals("cgi_steal", helper._cmds[2]);
	}

	// hidePopUp（:82-91）：有 parent 移除、无 parent 不炸、null 不炸
	public function test_hidePopUp_parent_gate() {
		var helper = new AppHelper();
		var parent = new Sprite();
		var child = new Sprite();
		helper.hidePopUp(null); // null 不炸
		helper.hidePopUp(child); // 无 parent 不炸
		parent.addChild(child);
		helper.hidePopUp(child);
		Assert.isFalse(parent.contains(child));
	}

	// sendRequest 恒返 true + mod 派发（:76-80）：registerNetCommand 注册的
	// mod 串即 postRequest 的第一参 url；param2 value 原样转发；返回值恒
	// true（即便 _cmds 无该键——postRequest(null,…) 也照返 true，网络层
	// 失败不归本方法管）。经 RecordingRequest 截获，真断言不再是备录
	public function test_sendRequest_returns_true_and_posts_mod() {
		var savedInstance = HTTPRequest.instance;
		var rec:RecordingRequest = cast Type.createEmptyInstance(RecordingRequest);
		HTTPRequest.instance = rec;
		try {
			var helper = new AppHelper();
			helper.registerNetCommand(1, "cgi_enter");
			var value:Dynamic = {uId: "999"};
			var handler = function(res:Dynamic) {};
			var ret = helper.sendRequest(1, value, handler);
			// 恒 true（:79——无论命令表命中与否）
			Assert.isTrue(ret);
			// mod 串即 postRequest 第一参（:77 _cmds[param1]）
			Assert.equals("cgi_enter", rec.postedUrl);
			// value 原样转发（注意：FRequest 装饰段会在其上**原位加写**
			// farmTime/farmKey/pastureKey/uIdx 四件——postedValue 与入参同
			// 对象、原键 uId 保留；四件的断言由 FRequestTest 承担，此处只钉
			// mod 派发与同对象转发）
			Assert.equals(value, rec.postedValue);
			Assert.equals(1, rec.postCount);
		} catch (e:Dynamic) {
			HTTPRequest.instance = savedInstance;
			throw e;
		}
		HTTPRequest.instance = savedInstance;
	}
}
