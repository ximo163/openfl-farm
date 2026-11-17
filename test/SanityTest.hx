package;

import utest.Assert;

/** 占位用例：utest 的 Runner 一个用例都不注册时按「No tests executed」失败，
 * 会让 main 上的 haxe test.hxml 红、preflight 拦下全部任务。它只证明测试
 * 工具链本身能跑，不测任何 legacy 行为。 */
class SanityTest {
	public function new() {}

	public function test_toolchain_runs() {
		Assert.isTrue(true);
	}
}
