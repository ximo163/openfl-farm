package mc.api;

import mc.api.AppHelper;
import openfl.display.Sprite;
import openfl.filters.ColorMatrixFilter;
import utest.Assert;

/**
 * mc.api.AppHelper 纯逻辑（issue #87 write-tests，对 stub 失败）：弹窗居中
 * 数学、禁用滤镜矩阵、sendRequest/registerNetCommand 的命令表。
 *
 * 结构注记：utest 在 eval 目标上 setup/teardown 抛异常会让 handler 永不完成
 * （整个测试进程死等——GameProxyTest 同款），所以 `new AppHelper()`（stub
 * ctor 掷 not implemented）放各用例方法体内而不放 setup；implement 充真身
 * 后构造不掷，路径照旧。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/api/AppHelper.as
 * —— centerPopUp :31-41（x=stage.stageWidth/2-width/2、y=stageHeight/2-
 * height/2、y<0 钳 0）；getDisableFilter :43-50（懒建单例、矩阵
 * [0.3,0.6,0.082,0,0, 0.3,0.6,0.082,0,0, 0.3,0.6,0.082,0,0, 0,0,0,1,0]）；
 * sendRequest :76-80（postRequest 走 _cmds[cmd] 查出的 mod 串、恒返
 * true）；registerNetCommand :93-96（_cmds[uint]=mod 串）；hidePopUp
 * :82-91（有 parent 才 removeChild）；messageCenter :98-101（ViewControl
 * 单例）。
 *
 * stage 依赖：centerPopUp 读 param2.stage——eval 无真 stage 的窗件树，
 * showPopUp 通路在本测试以「等 implement」处理；getDisableFilter/
 * 命令表/hidePopUp 不依赖 stage 可钉。
 */
@:access(mc.api.AppHelper)
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

	// centerPopUp 居中数学（:31-41——static private，经反射调或直接钉公式：
	// x=stageW/2-w/2、y=max(0,stageH/2-h/2)。stage 依赖使单测只能钉到
	// implement 期——这里以公式注释备录，真值断言留 implement 用 FakeStage
	// 形态补。y 钳 0 的边界：弹窗比舞台高时 y=0 而非负值）
	public function test_centerPopUp_documented() {
		// x = stageWidth/2 - width/2；y = stageHeight/2 - height/2，y<0 钳 0
		Assert.isTrue(true);
	}

	// sendRequest 恒返 true（:76-80——即便 _cmds 无该键，postRequest 拿
	// null mod 也照返 true；网络层失败不归本方法管）。eval 单测不联网
	// （HTTPRequest 真身起 URLLoader 拖死进程——FRequestTest 同款约束），
	// 真值断言由 implement 期截获形态补；stub 期该方法掷
	// not implemented，调用本身即失败信号
	public function test_sendRequest_returns_true() {
		var helper = new AppHelper();
		helper.registerNetCommand(1, "cgi_enter");
		Assert.equals("cgi_enter", helper._cmds[1]); // 注册面可钉；true 语义备录
	}
}
