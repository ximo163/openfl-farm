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
		// issue #20：friends 模块（write-tests 阶段，对 stub 失败）——
		// FriendsModel 纯逻辑：排序/过滤/分页/搜索（filterOut 保留极性已按
		// 字节码核对，tools/DumpAbcMethod.hx）、cgi_farm_getstatus_filter
		// 状态表（"1"-"7"）装载与本地推进、门位（serverDown/forbidden/
		// useflag）、应答分派（列表补自己/过滤增删/状态装载）
		runner.addCase(new module.friend.FriendsModelTest());
		// issue #20：implement 阶段 NEEDS-TESTS 回流的修正钉板（FriendsModel
		// :379/:845/:1149 三处期望与部署 swf 字节码相悖，本轮回 write-tests
		// 已把原断言改对，本文件按裁决链记录钉死）：回卷后页 1 无参回退
		// no-op、同步只写 me 行别人保持创建值、复用路径 processFriendList
		// 就地 exp 降序
		runner.addCase(new module.friend.FriendsModelFollowupTest());
		// issue #21：tasks 模块（write-tests 阶段，对 stub 失败）——
		// WelcomeModel 纯逻辑：11 项任务表与新旧 id 映射（newIDToOldID
		// 反查/防御性拷贝）、currentTask 装载派发（TaskChanged +
		// isNewGuideTask 极性）、taskComp 完成判定三门（flag==1/名字+me
		// 对表/code==1 → updateTask 门位）、task_accept/task_update 应答
		// 推进（flag 固定 1/update 回显旧 id/末任务归零 0,0/奖励载荷
		// 原样转发）、onNetError 门位复位
		runner.addCase(new module.task.welcome.WelcomeModelTest());
		// issue #29：农场模块桩清尾（write-tests 阶段，对 stub 失败）——
		// PoolFish 鱼塘格位实体（导入/等级/喂食标记/产量/剩余时间/刷新，
		// serverTime=0 纯分支 + 负 plantTime 合成鱼龄）、四模块壳语义
		// （reportID/空 load 覆写/unload 不调 super/反射失败分支 ctrl 保持
		// null，openfl 不执行外部 swf AS3）、ModuleWater.onZoom 三空防护、
		// DogFoodWindow addFood 9002 礼包载荷 + saleOut 真值极性 +
		// setData 天/小时 html 拼装（dog_feedmoney 载荷形状）
		runner.addCase(new entities.PoolFishTest());
		runner.addCase(new module.shop.ModuleShopTest());
		runner.addCase(new module.warehouse.ModuleWarehouseTest());
		runner.addCase(new module.water.ModuleWaterTest());
		runner.addCase(new module.decorate.ModuleDecorateTest());
		runner.addCase(new module.mainScene.npc.widgets.DogFoodWindowTest());
		// issue #35：shop 功能 swf 翻译（write-tests 阶段，对 stub 失败）——
		// ShopModel 纯逻辑：六页签装载门位与 LOADING/LOADED/FAILED 派发、
		// 买入交易位（beginTransaction/endTransaction 与各买入守卫）、应答
		// 回调（种子/鱼苗 Settings 配置合并与升序排序、装饰倒序+四元块换位、
		// 广告双网关三分支、合作专区 targetid 过滤、onTransactionError 派发
		// 表）；StepperMaker 夹取数学（高夹先行、floor 收尾）；AdItem 双导入
		// 通道（服务端键 "" 缺省 / 缓存下划线键 null 缺省）
		runner.addCase(new module.shop.ShopModelTest());
		runner.addCase(new com.qzone.qui.makers.StepperMakerTest());
		runner.addCase(new entities.AdItemTest());
		// issue #36：warehouse 功能 swf 翻译（write-tests 阶段，对 stub 失败）——
		// WarehouseModel 纯逻辑：六页签装载门位与 LOADING/DATA_CHANGED 派发
		// （index 表 0 蔬果/1 种子/2 花束/3 材料/5 成鱼）、作物应答单表拆三仓
		// （isFlower==1 → flowers、type==11 → cards、其余 → crops，crystals 后拼
		// 进 cards）、(lvl,id) 排序与 crops_sort _sort 表、配置补丁（isFlower/
		// isLock/isFood/isVIP 守卫 + isLock 2→0 归一）、allFlower 缺料计算
		// （lack/canMake/pic/swf/cName）、collectNotLockedIDs 四路过滤、isEmpty
		// 槽表、removeSeed 递减/移除、上锁应答三仓/鱼仓回写（未命中派发残留
		// 尾元素）、出售应答分支（sale/saleAll/saleSeed/sellAllSeeds/saleFish/
		// saleAllFish 的 code/errorType/direction 派发与 num 回填）、送花扣料与
		// m_sendFlowerID、onTransactionFailed 文案、onLoadDataError 恒不派发
		// FAILED（:318 恒真门）；MyBagModel 纯逻辑：分栏（种子 sortOn _cId 数值
		// 降序前置，其余 crops_sort 升序、未列 -1 最前、_cId 0 → 99 垫尾）、
		// 鱼苗 fish_info 合并（lifecycle 独占来源）、fillterType 三栏（鱼食插
		// 首个武器下标，无武器垫尾）、reload 门位、deleteItem 首命中
		runner.addCase(new module.warehouse.house.WarehouseModelTest());
		runner.addCase(new module.warehouse.bag.MyBagModelTest());
		// issue #37：pool 功能 swf 翻译（write-tests 阶段，对 stub 失败）——
		// WaterModel 纯逻辑：装载门位（loadFishes pending 闸 + reset/
		// checkWhiteList）、cgi_fish_index 应答（null 关塘/数组装载 + 逐鱼
		// calcNextStepTime）、canSteal 判定表（checkAll 短路/thief 名单/
		// left>min）、harvestAll 返回码（-3/-2/-1/0，主人侧不看 min 与
		// thief）、单捞/放/喂副作用位、cgi_fish_harvest 应答（单对象 exp
		// 升级 + 出队 + FISH_HARVESTED、数组起批 BATCH_FISH(2)）、
		// cgi_fish_steal 应答（thief 补记 + status 回写 + remove 判定）、
		// processBatchFish 队列推进、growLoop 成熟结算单飞与两连发封顶、
		// onGetOutput 匹配回写、onNetError 七 cmdID 派发表（open 关塘/
		// output 记账/「服务器错误.」缺省文案/steal 双路）；FishMover 纯面：
		// formatFishName 符号命名（FS/FJ + 补零 + level 钳 2）、
		// equalZeroSpeed 0.05 阈值、stop 冻结语义、ctor 初始态；ObjectPool
		// 对象池：借尽抛错/grow 翻档/restore 同实例复用/purge 两分支/
		// initialze 反射调用/SimpleFactory null 类
		runner.addCase(new module.water.WaterModelTest());
		runner.addCase(new module.water.FishMoverTest());
		runner.addCase(new common.cache.ObjectPoolTest());
		// issue #38：decorate 功能 swf 翻译（write-tests 阶段，对 stub 失败）——
		// DecorateModel 纯逻辑：装载门位（loadItems dirty/loading 双闸 +
		// resetLoadingFlags 复位）、getUserItems 应答（current→组 0/items→组 1
		// 装载、空应答清表置 null、空子表落 null 组、在用狗回填 myDogID——
		// 二次装载旧组 splice 清空 + 狗 setter 先于 LOADED 沿旧字典键逐组派
		// DataChanged）、槽位 setter（myBoardID 全表重标/-1 只清旧行 break/
		// 未装载不派发、myDogID 逐组重标/逐组派发）、boards 配置倒序装载与
		// status 标记、selectBoard/selectDecorate 门位与请求锁存、
		// active/deactive 应答（board 回填与清除/失配仍通知、装饰组 1 同型
		// 重标 + 组 0 换槽/原位/push 三路、背景停用补默认件、失败文案字面量）、
		// onNetError 文案与 dirty 保留
		runner.addCase(new module.decorate.DecorateModelTest());
		// issue #39：TweenLite 本体翻译（write-tests 阶段，对 stub 失败）——
		// 默认 easeOut 插值采样（t/d 各档 + 非零起点）、自定义 ease、from 的
		// runBackwards/immediateRender 即时倒放起点、overwrite 语义（缺省
		// mode=1 杀同目标旧补间/显式 0 并行/异目标身份键分桶）、delayedCall
		// 越延迟单次派发、killTweensOf 两分支（禁用/补渲染收尾）、killVars
		// 摘链冻结、propTweenLookup 起止登记、构造链 initClass 四静态
		runner.addCase(new com.greensock.TweenLiteTest());
		// issue #42：提示片（write-tests 阶段，对 stub 失败）——TipControl
		// 注册表与 show/update/hide 的 TipEvent 派发、TipLayer getTip 门位/
		// onTipShow 待显暂存/onTipUpdate 同型刷新路由、四 tip 真身纯面
		// （MouseTip/CropInfoTip 的 data null→"" 归一与文本落位、无舞台
		// mX/mY -5/+20 跟随、DiyMouseTip 到期文案含原文 "11" 尾、
		// LandInfoTip countHealth 健康衰减/动作档位表（含 :107 整式截断与
		// Array 日志丢弃）/jsonToArray 时序排序/data 路由/-60/-120 锚点）
		runner.addCase(new common.view.tip.TipControlTest());
		runner.addCase(new framework.layers.TipLayerTest());
		runner.addCase(new common.view.tip.MouseTipTest());
		runner.addCase(new common.view.tip.CropInfoTipTest());
		runner.addCase(new common.view.tip.DiyMouseTipTest());
		runner.addCase(new common.view.tip.LandInfoTipTest());
		// issue #43：引导与启动杂尾（write-tests 阶段，对 stub 失败）——
		// adobe StringUtil 整类（beginsWith/endsWith 前后缀比对、ltrim/rtrim
		// 的 >32 裁剪集与 U+00A0 边界、replace 手工扫描的跳针/空针语义、
		// remove、stringsAreEqual 大小写两档与 null 相等、stringHasValue）；
		// DisplayUtil 整类（setEnabled 的 hasOwnProperty 门与 filters 无条件
		// 写、copyProperties 选择性拷贝与双真值门、copyXYWH 四键、removeChild
		// 三卫塔回归钉、removeChildByName/At、disableMouse 双分支）；
		// GameGuide 步进纯面（九步坐标表、toggle_water/_stop/前进向/表长
		// 四道门、大小视图偏移与 icon 特加、(-1,-1) 动态锚、dir 朝向变换、
		// 容器缺失抛错、hide/autoHide(0)、tip 懒建只在 WATER_FISH_ITEM 步
		// 挂载）；CursorLayer setPosition 两分支与 remove；UserChangingBar
		// 切换结果分支与 __reload__ 重派发
		runner.addCase(new com.adobe.utils.StringUtilTest());
		runner.addCase(new com.qzone.utils.DisplayUtilTest());
		runner.addCase(new module.GameGuideTest());
		runner.addCase(new framework.layers.CursorLayerTest());
		runner.addCase(new module.load.UserChangingBarTest());
		// issue #44：qui 组件库管理器/工具（write-tests 阶段，对 stub 失败）——
		// FrameTimer 帧驱动语义（ms→帧换算表、frameCount%delay 触发门、
		// setTimeout 单发自清/setInterval 周发/clear 摘表/init 只装一次门、
		// 实例 start/stop/delay/currentCount/repeatCount/reset，FakeStage 钉
		// 30fps 无窗舞台手动派 ENTER_FRAME）；ButtonMaker 状态表（setEnabled
		// 的 mouseEnabled!=门、enable/disable 分支监听与滤镜、ROLL_OVER/
		// ROLL_OUT/MOUSE_DOWN/MOUSE_UP 滤镜轮换、addTarget/removeTarget
		// 标志位）；DragManager 注册表与拖拽事件流（hitArea 名键、父容器
		// MOUSE_MOVE/UP 装拆、LOCATION_CHANGE 的 _draging 门）；
		// EffectManager 无 effect 分支（完成回调透传、登记实例 complete 前置）
		runner.addCase(new com.qzone.qui.utils.FrameTimerTest());
		runner.addCase(new com.qzone.qui.makers.ButtonMakerTest());
		runner.addCase(new com.qzone.qui.managers.DragManagerTest());
		runner.addCase(new com.qzone.qui.managers.EffectManagerTest());
		// 新测试文件在这里注册：runner.addCase(new XxxTest());
		Report.create(runner);
		runner.run();
	}
}
