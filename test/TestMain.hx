package;

import utest.Runner;
import utest.ui.Report;

class TestMain {
	/** Report.create 在 eval 目标上跑完会以退出码收尾：全绿 0、有失败 1。
	 * orchestrator 的 expect:fail / verify 都按退出码判定（无 junit）。 */
	static function main() {
		var runner = new Runner();
		runner.addCase(new SanityTest()); // 保底用例：utest 把零用例运行当失败，main 必须绿
		// issue #3：V2 预加载器（flashvar 解析、config URL、资源类型、
		// useflag 开关/双条件门/加载队列状态机与进度公式）
		runner.addCase(new common.SettingsTest());
		runner.addCase(new com.qzone.qfa.data.ResourceTypeTest());
		runner.addCase(new FarmLiteTest());
		runner.addCase(new com.qzone.qfa.managers.LoadManagerTest());
		// 新测试文件在这里注册：runner.addCase(new XxxTest());
		Report.create(runner);
		runner.run();
	}
}
