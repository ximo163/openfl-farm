package mc.view.proxy;

import mc.view.proxy.GameProxy;
import utest.Assert;

/**
 * mc.view.proxy.GameProxy 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * host/currentUser 存取、me 真值表、CURRENT_USER_CHANGE 派发。
 *
 * 结构注记：utest 在 eval 目标上 setup/teardown 抛异常会让 handler 永不完成
 * （executeFinally 不跑——整个测试进程死等，曾致 haxe test.hxml 5 分钟超时
 * 被判 verification 失败），而测试方法体内抛只会记为 ERROR。所以清理
 * currentUser（stub setter 掷 not implemented）不放 setup/teardown，而是
 * 包进本类的 reset() 在每个用例方法体内调用——implement 充真身后路径照旧。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/proxy/GameProxy.as
 * —— me :49-60（currentUser/host 双非空且 uId 不同才 false，其余全 true）；
 * set currentUser :72-76（赋值 + 派 Event(CURRENT_USER_CHANGE)）；
 * CURRENT_USER_CHANGE="proxy_UserChange"（:19）；host setter 是 plain
 * 赋值（:44-47——不派发）。
 */
class GameProxyTest {
	var proxy:GameProxy;

	public function new() {}

	function setup() {
		proxy = GameProxy.getInstance();
		proxy.host = null;
	}

	// 状态复位（currentUser 换主）——在方法体内调用而非 teardown，原因见类头
	function reset() {
		proxy.host = null;
		proxy.currentUser = null;
	}

	// 常量值（GameProxy.as:19）
	public function test_event_constant() {
		Assert.equals("proxy_UserChange", GameProxy.CURRENT_USER_CHANGE);
	}

	// me 真值表（:49-60）：双 null → true；仅 host → true；uId 相同 →
	// true；uId 不同 → false
	public function test_me_truth_table() {
		reset();
		Assert.isTrue(proxy.me);
		proxy.host = {uId: "a"};
		Assert.isTrue(proxy.me);
		proxy.currentUser = {uId: "a"};
		Assert.isTrue(proxy.me);
		proxy.currentUser = {uId: "b"};
		Assert.isFalse(proxy.me);
	}

	// set currentUser 派 CURRENT_USER_CHANGE（:72-76）
	public function test_currentUser_dispatches_change() {
		reset();
		var count = 0;
		proxy.addEventListener(GameProxy.CURRENT_USER_CHANGE, function(e) count++);
		proxy.currentUser = {uId: "x"};
		Assert.equals(1, count);
	}

	// host setter 不派发（:44-47 plain 赋值）+ 存取往返
	public function test_host_plain_setter() {
		reset();
		var count = 0;
		proxy.addEventListener(GameProxy.CURRENT_USER_CHANGE, function(e) count++);
		proxy.host = {uId: "h"};
		Assert.equals(0, count);
		Assert.equals("h", proxy.host.uId);
	}
}
