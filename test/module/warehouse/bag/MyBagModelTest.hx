package module.warehouse.bag;

import com.qzone.qfa.events.CommandEvent;
import common.Settings;
import common.misc.Utils;
import entities.BagItem;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.vo.ServiceResultVO;
import openfl.events.Event;
import utest.Assert;

/**
 * MyBagModel 纯逻辑（issue #36）：背包（道具/种子两栏）数据层——装载门位与
 * LOADING/INITIALZED/LOAD_FAILED 派发、应答单表分栏（type==1 种子桶
 * sortOn _cId 数值降序前置，其余按 crops_sort 配 _sort 升序、未列 -1 最前、
 * _cId 0 → 99 垫尾）、鱼苗条目从 Settings fish_info 补名称/成熟期
 * （lifecycle 是合并独占观测量——背包应答行无此键）、fillterType 三栏过滤
 * （normal 种子 / fish 成鱼 / tool 其余，鱼食桶插到首个武器条目前，无武器
 * 垫尾）、deleteItem 首命中移除。MyBagController/MyBagView/PackItem 是
 * 接线与显示层，归 CI web-smoke。
 *
 * 环境口径（同 #35 ShopModelTest/#36 WarehouseModelTest）：
 * - NetHelper.sendRequest 在 theApp == null 时 no-op（#7 已译），测试进程
 *   不跑 Main、theApp 恒 null——reload 的请求侧不可观测，应答回调直接喂
 *   构造好的 CommandEvent（body 用 Utils.buildRequest 造出与真实链路同构的
 *   {cmdID,__body,…}，result 装 ServiceResultVO，走 NetHelper.getVOData 的
 *   m_extra 分支）。
 * - 应答载荷形状按真实链路镜像：背包应答 m_extra 已被 BagDataParser
 *   （_class = BagItem，BaseArrayParser 子类）转成 Array<BagItem>，fixture
 *   直接构造实体。
 * - EventRecorder 按 deviations（no-qq-telemetry）DISABLED，
 *   recordErrorEvent/recordSueecssEvent 调用点无观测，只保不抛；
 *   QzoneJSAPI.reportError 在 eval 上安全（QQOutlets.available 恒 false）。
 * - Settings 注入：loadLocalSettings(null) 复位 m_params（crops_sort 缺省
 *   ""→不排序）；「有 crops_sort」用例钉的是 :125-142 指令语义本身（部署
 *   快照恒未配此键）。
 * - Consts.ITEM_TYPE_SEED "1"/FISH "23"/FISHFEED "24"/WEAPON "10" 已译
 *   （Consts.hx:255/:263/:264/:272）；`_type == Consts.ITEM_TYPE_*` 的
 *   AS3 松等（Int 1 == "1"）由实现侧 As3.eqString 承接，fixture 用 Int。
 * - 排序方向（勿按直觉改）：cropSort :80-84 的 `int(a) < int(b) ? -1 : 1`
 *   在 AS3 Array.sort 约定下升序，无 0 返回（平级次序无稳定保证）——
 *   crops_sort 用例全取互异 _sort 键。种子的 sortOn("_cId",
 *   NUMERIC|DESCENDING) 是数值降序（#4 草莓排 #1 前）。
 * - EVENT_INITIALZED 拼写原版如此（:19）；EVENT_UPDATED 声明未派发（本类
 *   无调用点），只钉常量值。
 *
 * 出处：
 * - legacy/decompiled/warehouse_v_23/scripts/module/warehouse/bag/
 *   MyBagModel.as（常量 :19-25、ctor :31-36、getItem :38-49、set dirty
 *   :51-54、onGetMyBagDataFailed :56-67、get empty :69-76、cropSort
 *   :78-85、onGetMyBagData :87-163、get dirty :165-168、fishFoodSort
 *   :170-177、fillterType :179-239、reload :241-249、deleteItem :251-264）
 * - legacy/deploy/QFarmFlash/source/core/source/nc/mod/
 *   repertory_getuserseed.php:12（种子行 {type:1,cId,cName,amount,
 *   lifecycle,level}）、:20（农场工具 {type:3,tId,tName,amount,depict}）、
 *   :27-29（鱼食 {amount,fId,tName,depict,type:24}——id 键是 fId）、:35
 *   （牧场武器 {type:10,tId,tName,amount,depict}）、:43（成鱼 {amount,fId,
 *   tName,type:23}——注意无 lifecycle 键，成熟期只能来自 fish_info 合并）
 * - legacy/deploy/QFarmFlash/source/core/source/xml/mod/nc_data.php:7565
 *   （fish_info 小丑鱼 id2 crop_name mature 23 sale 90）
 * - legacy/deploy/QFarmFlash/source/core/config/nc/cropstype.php:4-7
 *   （cId1 草莓 cLevel10、cId4 玉米 cLevel3）
 * - src/framework/net/parsers/BagDataParser.hx（_class = BagItem →
 *   m_extra = Array<BagItem>）
 */
@:access(module.warehouse.bag.MyBagModel)
class MyBagModelTest {
	public function new() {}

	var model:MyBagModel;

	public function setup() {
		model = new MyBagModel(); // stub ctor 无零位，各用例自垫
		model.m_items = null; // AS3 ctor :34
		model.m_bDirty = true; // :35
		Settings.getInstance().loadLocalSettings(null); // crops_sort 复位缺省
		Settings.getInstance().setConfigDataModel(null);
	}

	public function teardown() {
		Settings.getInstance().loadLocalSettings(null);
		Settings.getInstance().setConfigDataModel(null);
	}

	// :19-25 事件名常量（INITIALZED 原版拼写）+ :31-36 ctor 零位
	// （m_items null / m_bDirty true）
	public function test_event_constants_and_ctor_defaults() {
		Assert.equals("DataInitialized", MyBagModel.EVENT_INITIALZED); // :19
		Assert.equals("LoadFailed", MyBagModel.EVENT_LOAD_FAILED); // :21
		Assert.equals("LoadingProcess", MyBagModel.EVENT_LOADING); // :23
		Assert.equals("DataUpdated", MyBagModel.EVENT_UPDATED); // :25
		var raw = new MyBagModel();
		Assert.isNull(raw.m_items); // :34
		Assert.isTrue(raw.m_bDirty); // :35
	}

	// :38-49 getItem：首个 (cId,type) 松等命中，未命中/表空 null
	public function test_getItem() {
		var a = new BagItem({tId: 1, tName: "普通化肥", type: 3, amount: 10}); // repertory_getuserseed.php:20 行形
		var b = new BagItem({cId: 1, cName: "草莓", type: 1, amount: 5}); // :12 行形
		model.m_items = [a, b];
		Assert.isTrue(model.getItem(1, 1) == b);
		Assert.isTrue(model.getItem(1, 3) == a);
		Assert.isNull(model.getItem(1, 23)); // type 不符
		Assert.isNull(model.getItem(99, 3)); // id 不符
		model.m_items = null;
		Assert.isNull(model.getItem(1, 1)); // AS3 for-each 空表 no-op
	}

	// :69-76 empty / :165-168 dirty getter / :51-54 setter
	public function test_empty_and_dirty() {
		Assert.isTrue(model.empty); // m_items null
		Assert.isTrue(model.dirty); // ctor 零位 true
		model.m_items = [];
		Assert.isTrue(model.empty);
		model.m_items = [new BagItem({cId: 1, type: 1, amount: 1})];
		Assert.isFalse(model.empty);
		model.dirty = false; // setter :51-54
		Assert.isFalse(model.dirty);
		model.dirty = true;
		Assert.isTrue(model.dirty);
	}

	// :87-163 onGetMyBagData 主链（无 crops_sort）：type==1 分种子桶
	// （:113-122），其余原序进主表（:124），种子 sortOn _cId 数值降序前置
	// （:143-144，玉米 4 在草莓 1 前）、鱼苗合并 fish_info（:150-158——
	// lifecycle 只能来自这里，应答行无此键）、dirty=false（:160）、
	// INITIALZED 载荷 = m_items（:161）
	public function test_onGetMyBagData_partition_order_and_fish_merge() {
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({fish_info: [
			{id: 2, crop_name: "小丑鱼", mature: 23, sale: 90}]})); // nc_data.php:7565
		// repertory_getuserseed.php 五段拼接序的取样（:12/:20/:43 行形）
		var tool = new BagItem({tId: 1, tName: "普通化肥", type: 3, amount: 10}); // :20
		var fish = new BagItem({fId: 2, tName: "小丑鱼", amount: 3, type: 23}); // :43
		var corn = new BagItem({cId: 4, cName: "玉米", amount: 2, type: 1, lifecycle: 3, level: 3}); // :12（cropstype.php:7）
		var berry = new BagItem({cId: 1, cName: "草莓", amount: 5, type: 1, lifecycle: 10, level: 10}); // :12（cropstype.php:4）
		var weapon = new BagItem({tId: 2, tName: "打狗棒", type: 10, amount: 1}); // :35 行形
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onGetMyBagData(voEvent(CommandDefs.CMD_GET_BAG_DATA, null, [tool, fish, corn, berry, weapon]));

		Assert.isFalse(model.dirty); // :160
		Assert.equals(1, log.length);
		var entry = log[0];
		Assert.equals(MyBagModel.EVENT_INITIALZED, Reflect.field(entry, "type"));
		Assert.isTrue(Reflect.field(entry, "data") == model.m_items);
		// 种子降序前置（玉米 4 → 草莓 1），其余应答原序
		Assert.equals(5, model.m_items.length);
		Assert.isTrue(model.m_items[0] == corn);
		Assert.isTrue(model.m_items[1] == berry);
		Assert.isTrue(model.m_items[2] == tool);
		Assert.isTrue(model.m_items[3] == fish);
		Assert.isTrue(model.m_items[4] == weapon);
		// 鱼苗合并：_lifeCycle 是 fish_info 独占来源；_name 覆写自 crop_name
		Assert.equals("小丑鱼", fish._name); // :155
		Assert.equals(23, fish._lifeCycle); // :156
		Assert.equals(3, fish._amount);
		// 非鱼条目不进合并（:150 的 type 门）
		Assert.equals("草莓", berry._name);
		Assert.equals(10, berry._lifeCycle);

		// 二次应答整体替换（:97-104 splice(0) + concat）
		model.onGetMyBagData(voEvent(CommandDefs.CMD_GET_BAG_DATA, null, [berry]));
		Assert.equals(1, model.m_items.length);
		Assert.isTrue(model.m_items[0] == berry);
		Assert.equals(2, log.length);
	}

	// :125-142 crops_sort：_sort 只配给分栏后的「其余」表（种子桶尚未进
	// m_items），表内下标即 _sort（未列 -1 最前，_cId 0 → 99 垫尾），升序排
	public function test_onGetMyBagData_crops_sort_assigns_and_orders() {
		Settings.getInstance().loadLocalSettings({crops_sort: "3,1"}); // 合成场景（部署快照恒未配）
		var toolA = new BagItem({tId: 3, tName: "速效化肥", type: 3, amount: 2}); // "3" 表内 0 位
		var toolB = new BagItem({tId: 1, tName: "普通化肥", type: 3, amount: 10}); // "1" 表内 1 位
		var toolC = new BagItem({tId: 7, tName: "化肥", type: 3, amount: 1}); // 未列 → -1
		var zero = new BagItem({type: 3, amount: 1}); // 无 id 键 → _cId 0 → 99
		var berry = new BagItem({cId: 1, cName: "草莓", amount: 5, type: 1, lifecycle: 10, level: 10});

		model.onGetMyBagData(voEvent(CommandDefs.CMD_GET_BAG_DATA, null, [toolA, toolB, toolC, zero, berry]));

		Assert.equals(0, toolA._sort); // :134 indexOf
		Assert.equals(1, toolB._sort);
		Assert.equals(-1, toolC._sort); // 表外 -1
		Assert.equals(99, zero._sort); // :138 _cId 0
		Assert.equals(0, berry._sort); // 种子桶未过 :130-141 循环，保持 BagItem 初值
		// 种子前置 + 其余按 _sort 升序（-1 → 0 → 1 → 99）
		Assert.equals(5, model.m_items.length);
		Assert.isTrue(model.m_items[0] == berry);
		Assert.isTrue(model.m_items[1] == toolC);
		Assert.isTrue(model.m_items[2] == toolA);
		Assert.isTrue(model.m_items[3] == toolB);
		Assert.isTrue(model.m_items[4] == zero);
	}

	// :92-96 VO null：早退在一切动作之前——零事件、列表保持 null、dirty 不复位
	public function test_onGetMyBagData_null_vo() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model.onGetMyBagData(voEvent(CommandDefs.CMD_GET_BAG_DATA, null, null));
		Assert.equals(0, log.length);
		Assert.isNull(model.m_items);
		Assert.isTrue(model.dirty);
	}

	// :56-67 onGetMyBagDataFailed：LOADING{false} 在前、LOAD_FAILED{null}
	// 在后（各恰好一次）
	public function test_onGetMyBagDataFailed_event_pair() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model.onGetMyBagDataFailed(voEvent(CommandDefs.CMD_GET_BAG_DATA, null, null));
		Assert.equals(2, log.length);
		Assert.equals(MyBagModel.EVENT_LOADING, Reflect.field(log[0], "type"));
		Assert.isTrue(Reflect.field(log[0], "data") == false);
		Assert.equals(MyBagModel.EVENT_LOAD_FAILED, Reflect.field(log[1], "type"));
		Assert.isNull(Reflect.field(log[1], "data"));
	}

	// :241-249 reload 门：m_items != null 且 !dirty 才短路（两条件缺一仍派发
	// LOADING{true}）；请求侧 no-op 无观测
	public function test_reload_gate() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.reload(); // m_items null + dirty true
		Assert.equals(1, log.length);
		Assert.isTrue(Reflect.field(log[0], "data") == true);

		model.m_items = [];
		model.m_bDirty = false;
		model.reload(); // 门齐 → 短路
		Assert.equals(1, log.length);

		model.m_bDirty = true;
		model.reload(); // dirty 翻真仍派发
		Assert.equals(2, log.length);

		model.m_items = null;
		model.m_bDirty = false;
		model.reload(); // 表空仍派发（:243 两条件）
		Assert.equals(3, log.length);
	}

	// :251-264 deleteItem：首个 (cId,type) 命中移除即返回（同键重复只删第
	// 一个）、未命中/空表 no-op、零派发
	public function test_deleteItem() {
		var a = new BagItem({tId: 1, tName: "普通化肥", type: 3, amount: 10});
		var b = new BagItem({tId: 1, tName: "普通化肥", type: 3, amount: 4});
		var seed = new BagItem({cId: 1, cName: "草莓", type: 1, amount: 5});
		model.m_items = [a, b, seed];
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.deleteItem(1, 3); // 首命中
		Assert.equals(2, model.m_items.length);
		Assert.isTrue(model.m_items[0] == b); // a 被删，b 保留

		model.deleteItem(99, 3); // 未命中
		Assert.equals(2, model.m_items.length);
		model.deleteItem(1, 23); // type 不符
		Assert.equals(2, model.m_items.length);
		model.m_items = null;
		model.deleteItem(1, 1); // 空表 no-op
		Assert.equals(0, log.length); // 本方法零派发
	}

	// :179-239 fillterType：normal→种子（type "1"）、fish→成鱼（"23"）、
	// tool→其余且鱼食（"24"）攒桶；桶里元素 pop+splice 插到首个武器（"10"）
	// 条目前（原序保持），无武器 concat 垫尾；空表恒 []
	public function test_fillterType() {
		Assert.equals(0, model.fillterType("normal").length); // :186-189 空-guard
		Assert.equals(0, model.fillterType("tool").length);

		var berry = new BagItem({cId: 1, cName: "草莓", type: 1, amount: 5});
		var tool = new BagItem({tId: 1, tName: "普通化肥", type: 3, amount: 10});
		var fish = new BagItem({fId: 2, tName: "小丑鱼", type: 23, amount: 3});
		var ffA = new BagItem({fId: 1, tName: "鱼食", type: 24, amount: 5}); // repertory_getuserseed.php:27-29 行形
		var ffB = new BagItem({fId: 9, tName: "高级鱼食", type: 24, amount: 2});
		var weapon = new BagItem({tId: 2, tName: "打狗棒", type: 10, amount: 1});
		model.m_items = [berry, tool, fish, ffA, ffB, weapon];

		var normal = model.fillterType("normal");
		Assert.equals(1, normal.length);
		Assert.isTrue(normal[0] == berry);

		var fishOnly = model.fillterType("fish");
		Assert.equals(1, fishOnly.length);
		Assert.isTrue(fishOnly[0] == fish);

		// tool：主表 [tool, weapon]，鱼食桶 [ffA, ffB] 插到首个武器所在
		// 下标（=武器前、非武器后）
		var tools = model.fillterType("tool");
		Assert.equals(4, tools.length);
		Assert.isTrue(tools[0] == tool);
		Assert.isTrue(tools[1] == ffA); // pop+splice 保序（:224-227）
		Assert.isTrue(tools[2] == ffB);
		Assert.isTrue(tools[3] == weapon);

		// 无武器：鱼食 concat 垫尾（:233-236）
		var noWeapon = new MyBagModel();
		noWeapon.m_items = [tool, ffA, ffB];
		var out = noWeapon.fillterType("tool");
		Assert.equals(3, out.length);
		Assert.isTrue(out[0] == tool);
		Assert.isTrue(out[1] == ffA);
		Assert.isTrue(out[2] == ffB);

		// 缺省参 = "normal"（:179）
		Assert.equals(1, model.fillterType().length);
	}

	// :78-85 cropSort：int(_sort) 升序、无 0 返回；:170-177 fishFoodSort：
	// 首参是鱼食（type "24"）才比 _cId（小者 -1），否则恒 1
	public function test_cropSort_and_fishFoodSort_comparators() {
		var s0 = new BagItem({tId: 1, type: 3, amount: 1});
		var s1 = new BagItem({tId: 2, type: 3, amount: 1});
		s0._sort = 0;
		s1._sort = 1;
		Assert.equals(-1, model.cropSort(s0, s1)); // 0 < 1
		Assert.equals(1, model.cropSort(s1, s0)); // 1 不小于 0
		Assert.equals(1, model.cropSort(s0, s0)); // 平级无 0，走 1（原版字面）

		var ff5 = new BagItem({fId: 5, type: 24, amount: 1});
		var ff9 = new BagItem({fId: 9, type: 24, amount: 1});
		var ff2 = new BagItem({fId: 2, type: 24, amount: 1});
		var tool = new BagItem({tId: 1, type: 3, amount: 1});
		Assert.equals(-1, model.fishFoodSort(ff5, ff9)); // 5 < 9
		Assert.equals(1, model.fishFoodSort(ff9, ff5)); // 9 不小于 5
		Assert.equals(1, model.fishFoodSort(tool, ff5)); // 首参非鱼食恒 1（:176）
		Assert.equals(1, model.fishFoodSort(ff5, tool)); // 首参鱼食 → 5 < 1 不成立 → 1
		// 对称用例：首参 _cId 小 → -1。第二参 _cId 须大于 2（tId 3 → _cId 3）
		var tool3 = new BagItem({tId: 3, type: 3, amount: 1});
		Assert.equals(-1, model.fishFoodSort(ff2, tool3)); // 首参鱼食 → 2 < 3 成立 → -1
	}

	static function listenModel(m:MyBagModel, log:Array<Dynamic>):Void {
		var names:Array<String> = [
			MyBagModel.EVENT_INITIALZED, MyBagModel.EVENT_LOAD_FAILED,
			MyBagModel.EVENT_LOADING, MyBagModel.EVENT_UPDATED
		];
		for (n in names) {
			m.addEventListener(n, function(e:Event) {
				log.push({
					type: e.type,
					data: Std.isOfType(e, CommonEvent) ? cast(e, CommonEvent).data : null
				});
			});
		}
	}

	// 应答事件：body 用 Utils.buildRequest 造出与 NetHelper.sendRequest →
	// theApp.run 真实链路同构的 {cmdID, __body, __format}；result 装入
	// ServiceResultVO（getVOData 的 m_extra 分支）。同 ShopModelTest。
	static function voEvent(cmd:Int, reqParams:Dynamic, payload:Dynamic):CommandEvent {
		var vo = new ServiceResultVO();
		vo.m_extra = payload;
		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.body = Utils.buildRequest(cmd, reqParams);
		ev.result = vo;
		return ev;
	}
}

// Settings.getFishByID 的配置表注入（getData 按表名直取；ShopModelTest
// 同款，IModel 含 INotifier 三方法）
private class FakeConfigModel implements com.qzone.qfa.interfaces.IModel {
	var tables:Dynamic;

	public function new(tables:Dynamic) {
		this.tables = tables;
	}

	public function getData(param1:String):Dynamic {
		return Reflect.field(this.tables, param1);
	}

	public function flush():Void {}

	public function setData(param1:String, param2:Dynamic):Bool {
		return true;
	}

	public function notify(param1:String):Void {}

	public function removeNotifier(param1:String, param2:Dynamic):Void {}

	public function addNotifier(param1:String, param2:Dynamic):Void {}
}
