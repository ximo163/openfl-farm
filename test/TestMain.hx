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
		// issue #9：V3c 种收交互（write-tests 阶段，对 stub 失败）——
		// UIToolsModel 账户/离线/升级礼物 diff 派发、ToolBar 工具选择开关
		// 与快捷键映射、飘字段基类/收获飘字数值文本/数值滚动补间、
		// FloatControl/CursorControl 派发、MaterialProxy 尺寸档与 loaded 语义
		runner.addCase(new module.uitools.UIToolsModelTest());
		runner.addCase(new module.uitools.widgets.ToolBarTest());
		runner.addCase(new common.view.floating.FloatingBaseTest());
		runner.addCase(new common.view.floating.NumAnimationTest());
		runner.addCase(new common.view.floating.HarvestAnimationTest());
		runner.addCase(new common.view.floating.HarvestAnimationPlusTest());
		runner.addCase(new common.view.floating.FloatControlTest());
		runner.addCase(new common.view.cursor.CursorControlTest());
		runner.addCase(new common.view.MaterialProxyTest());
		// issue #10：V4 预览准备——android 真机侧接线（局域网后端基址的
		// flashvar 默认/覆盖解析、相对 *.php 改写契约）
		runner.addCase(new shim.AndroidBackendTest());
		// issue #17：T1 场景运行器（tools/scenario.mjs 种植场景对拍）——
		// 交付物的数据契约门（场景声明四步进农场→种→浇→收、mod/参数对
		// mync.php 白名单 + spec/protocol.json + snapshot uid=1、自录基线的
		// 请求序列/全绿判定/检查点状态）。执行器与 diff 算法演示按 issue
		// 走 PR 说明 + CI 人工配套，utest 只钉纯数据契约（见测试类头）
		runner.addCase(new ScenarioRunnerContractTest());
		// issue #10：素材剪辑动态属性侧表（cpp 上裸写抛 Invalid field，真机闪退修复）
		runner.addCase(new shim.ClipPropsTest());
		// issue #18：farm-basic 收尾（write-tests 阶段，对 stub 失败）——
		// DateTimeUtils 时间格式化/同日/闰年、HtmlUtil 转义与双字节长度、
		// ImageSizeUtil 适配矩形数学（含 param4→height 原版笔误）、Payment
		// 序号/对账参数/回调、PropTween 链表节点、LevelUpModel 土地档位表
		// 与种子过滤/加载门位/URL 拼装
		runner.addCase(new com.qzone.utils.DateTimeUtilsTest());
		runner.addCase(new com.qzone.utils.HtmlUtilTest());
		runner.addCase(new com.qzone.utils.ImageSizeUtilTest());
		runner.addCase(new com.qzone.sns.entities.PaymentTest());
		runner.addCase(new com.greensock.core.PropTweenTest());
		runner.addCase(new module.levelup.LevelUpModelTest());
		// issue #18（review-impl 要求补的注册行，lessons 条目同 #8 先例：
		// implement 阶段新增测试文件只能由本阶段注册）——As3.arrayIndex
		// 字符串键取 AS3 Array 语义：TileList 拼接键绑定、正则下标边界表、
		// ViewStack Dictionary 混键种死门
		runner.addCase(new shim.As3ArrayIndexTest());
		// issue #19：messages 模块（write-tests 阶段，对 stub 失败）——
		// MessageModel 纯逻辑：getAllInfo 旗标表与已读门（loadData 各页签
		// 缓存早退/双源位复位）、应答解析分派（user/chat/log/repertory/
		// cost 双源合并降序/systemMsg ret 门/fish 映射）、留言列表收发
		// 清空、feeds ecode 门、网络失败文案、reset 重开已读门
		runner.addCase(new module.messages.MessageModelTest());
		// 新测试文件在这里注册：runner.addCase(new XxxTest());
		Report.create(runner);
		runner.run();
	}
}
