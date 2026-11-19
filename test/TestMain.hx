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
		// issue #7：V3a 启动与数据层（FarmLand/Seed 实体映射、ServerServices
		// cmdMap/decodeResult；write-tests 阶段对 stub 失败）
		runner.addCase(new entities.FarmLandTest());
		runner.addCase(new entities.SeedTest());
		runner.addCase(new framework.net.ServerServicesTest());
		// issue #7 补齐（round 2）：FarmLandModel 数值/状态公式、qfa HttpOperation
		// 状态机、StartupDataParser 对 uid=1 真实下发的解析、Protocol 请求侧拼装
		runner.addCase(new module.mainScene.farmLand.FarmLandModelTest());
		runner.addCase(new com.qzone.qfa.managers.operation.HttpOperationTest());
		runner.addCase(new framework.net.core.HttpOperationExTest());
		runner.addCase(new framework.net.parsers.StartupDataParserTest());
		runner.addCase(new framework.net.protocol.ProtocolTest());
		// issue #7（回到 write-tests）：启动窗口 module swf ↔ libraries.xml
		// 一致性（WildShellNc_v_5 未入库 → web-smoke 404，见该测试类头注释）
		runner.addCase(new StartupModuleLibrariesTest());
		// issue #8：V3b 农场场景渲染（write-tests 阶段，对 stub 失败）——
		// OperationQueue 合批/派发、FarmLandsView 布局与地块→控件形态分派、
		// LandItemRender 状态映射、BackgroundModel 装饰槽位、NPCModel 狗数据、
		// Player 实体解析/等级/克隆
		runner.addCase(new module.mainScene.farmLand.OperationQueueTest());
		runner.addCase(new module.mainScene.farmLand.FarmLandsViewTest());
		runner.addCase(new module.mainScene.farmLand.widgets.LandItemRenderTest());
		runner.addCase(new module.mainScene.background.BackgroundModelTest());
		runner.addCase(new module.mainScene.npc.NPCModelTest());
		runner.addCase(new entities.PlayerTest());
		// issue #8（review 要求补的注册行，lessons append-only 条目：implement
		// 阶段新增测试文件只能由本阶段注册）——GetCropID.idState/timeToMature
		// 生长档推导、Crop 生命周期/看板 swf ↔ libraries.xml 一致性门、启动
		// 窗口装饰 swf ↔ libraries.xml 一致性门
		runner.addCase(new common.GetCropIDTest());
		runner.addCase(new CropLifecycleLibrariesTest());
		runner.addCase(new SceneDecorLibrariesTest());
		// 新测试文件在这里注册：runner.addCase(new XxxTest());
		Report.create(runner);
		runner.run();
	}
}
