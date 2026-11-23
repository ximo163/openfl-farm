package module.decorate;

import com.qzone.qfa.events.CommandEvent;
import common.Consts;
import common.Session;
import common.Settings;
import common.misc.Utils;
import entities.DecorateItem;
import framework.net.CommandDefs;
import framework.net.vo.ServiceResultVO;
import module.FarmApplication;
import openfl.utils.Dictionary;
import utest.Assert;

/**
 * DecorateModel 纯逻辑（issue #38）：DIY 装饰数据层——装载门位、
 * item.getUserItems 应答拆组装载、myBoardID/myDogID 槽位 setter 的
 * boardArray/decorGroup 重标、boards 配置倒序装载、selectBoard/
 * selectDecorate 请求锁存、active/deactive 应答回写与派发、失败文案。
 * DecorateController/DecorateView/widgets 各页签是接线与显示层，归 CI
 * web-smoke。
 *
 * 环境口径（同 #35/#36/#37 功能 swf 模块先例）：
 * - NetHelper.sendRequest 在 theApp == null 时 no-op（#7 已译），测试进程
 *   不跑 Main、theApp 恒 null——请求侧参数拼装（selectBoard 的 {id,type:1}、
 *   selectDecorate 的 {id,type}、loadItems 的 null）不可观测，不设测试；
 *   应答侧直接喂构造好的 CommandEvent（body 用 Utils.buildRequest 造出与
 *   真实链路同构的 {cmdID,__body,…}，result 装 ServiceResultVO，走
 *   NetHelper.getVOData 的 m_extra 分支）。
 * - EventRecorder 已按 deviations（no-qq-telemetry）DISABLED，
 *   recordSueecssEvent/recordErrorEvent 调用点无观测，只保不抛。
 * - Session 单例跨用例共享：按 NPCModelTest 先例给 Session 装真
 *   FarmApplication 并预置空装饰表 {}（实现 ctor :58 经 sceneDecorates 读
 *   UserDecorate 键，不预置在 eval 上 null 访问；空表无 "9"/"8" 键 →
 *   setMyDecorate 早退，ctor 零位不受扰）。
 * - Settings 注入：loadLocalSettings(null) 复位、boards 配置走
 *   setConfigDataModel(FakeConfigModel)；经 ConfigMerger.mergeJsonArrayNode
 *   （ConfigMerger.hx:122）存进模型的是内层 boards 数组，getBillBoardData
 *   （Settings.hx:276-283）直返该数组——loadBoards 的 reverse 原地翻转
 *   连配置里的同一数组一起翻，原版如此。
 * - `_loc2_["code"] == "1"` 是 AS3 松等：协议返回 code 为 int（见下），
 *   fixture 一律给 int 1（int 0 给失败分支），实现须按 WelcomeModel 先例
 *   走 As3.eqString 语义，直比 `Reflect.field(...) == "1"` 在 Haxe 下对
 *   int 是 false——本测试即钉这一点。
 * - loadBoards 在无 boards 配置时 `null.reverse()` 是 AS3 原生 TypeError
 *   路径（同 ShopModel.onInGamePreCheckSuccess 的 VO-null 先例），不钉。
 *
 * 出处：
 * - legacy/decompiled/decorate_v_0/scripts/module/decorate/DecorateModel.as
 *   （常量 :20-32、ctor :48-59、onDeSelectDecorateSuccess :61-103、
 *   set myBoardID :105-141、setDefaultBackground :148-169、loadBoards
 *   :176-204、set myDogID :206-253、selectBoard :255-281、
 *   resetLoadingFlags :283-293、onDataLoadSuccess :295-376、
 *   onSelectBoardSuccess :378-396、setMyDecorate :398-414、
 *   onDeSelectFailed :421-430、onSelectFailed :432-441、selectDecorate
 *   :443-466、onNetError :468-479、onDeSelectBoardSuccess :499-520、
 *   loadItems :522-535、onSelectDecorateSuccess :537-630）
 * - spec/protocol.json entries.nc.mods：item_getuseritems（cmd 38，返回
 *   {code:int 恒 1, current[], items[], …}，元素 {id,itemType,status,…}）、
 *   item_activeitem（cmd 86，返回 {code:int 恒 1, id:int 回显}）、
 *   item_deactiveitem（cmd 87，返回 {code:int 恒 1, id:int 回显}）
 * - legacy/decompiled/main3_v_221/scripts/framework/net/ServerServices.as:77-79
 *   （CMD_GET_DIY_ITEMS 38 / CMD_ACTIVE_DECORATE 86 / CMD_DEACTIVE_DECORATE
 *   87，src/framework/net/CommandDefs.hx:33/:65/:66 同值）
 * - DecorateItemsParser（main3 侧已译，src/framework/net/parsers/
 *   DecorateItemsParser.hx:37-59）：current → 组 0（当前装备）、items →
 *   组 1（拥有物），onDataLoadSuccess 的 m_decorGroup[0]/[1] 由此定序
 * - legacy/deploy/QFarmFlash/source/core/source/xml/mod/nc_data.php:5974-6014
 *   （boards 配置行形状：{asset_id 字串, id 数值, name}，90001/90003/90005 →
 *   asset_id "1719"/"1723"/"1727"）
 * - Consts.hx:323/:325/:328/:332（DECOR_DOG 8 / DECOR_DOG_BASE_ID 80000 /
 *   DECOR_BACKGROUND 1 / DECOR_BILLBOARD 9）；键形状同 NPCModel.changeDog
 *   写 sceneDecorates 的 {"8":{itemId:n}}（NPCModel.as:104-108）
 * - Language.hx cn 表（"请求超时，"/"点击重试" 原文，onNetError :476 拼串）
 */
@:access(module.decorate.DecorateModel)
class DecorateModelTest {
	public function new() {}

	var model:DecorateModel;

	var savedApp:FarmApplication;

	// 事件捕获：(type, data) 序列，listen 按需挂类型
	var events:Array<Dynamic>;

	public function setup() {
		savedApp = Session.getInstance().app;
		var app = new FarmApplication();
		Session.getInstance().app = app;
		app.model.setData(Consts.USER_DECORATE_OBJECT, {});
		Settings.getInstance().loadLocalSettings(null);
		Settings.getInstance().setConfigDataModel(null);
		model = freshModel();
	}

	public function teardown() {
		Session.getInstance().app = savedApp;
		Settings.getInstance().loadLocalSettings(null);
		Settings.getInstance().setConfigDataModel(null);
	}

	// stub 的 ctor 无零位（那是实现内容 :51-57），各用例统一从这里起手
	static function freshModel():DecorateModel {
		var m = new DecorateModel(null);
		m.m_decorGroup = null; // AS3 ctor :51
		m.m_dirty = true; // :52
		m.m_boardArray = null; // :53
		m.m_myBoardID = -1; // :54
		m.m_myDogID = -1; // :55
		m.m_loading = false; // :56
		m.m_requesting = false; // :57
		return m;
	}

	// 应答事件构造（ShopModelTest 同款）：body 走 Utils.buildRequest 造出与
	// 真实链路同构的 {cmdID,__body,…}，result 装 ServiceResultVO，
	// NetHelper.getVOData 走 m_extra 分支
	static function voEvent(cmd:Int, reqParams:Dynamic, payload:Dynamic):CommandEvent {
		var vo = new ServiceResultVO();
		vo.m_extra = payload;
		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.body = Utils.buildRequest(cmd, reqParams);
		ev.result = vo;
		return ev;
	}

	// Haxe 对象字面量写不了数字串键（"9"/"8"/"asset_id"），统一经 Reflect 落键
	static function obj(pairs:Array<Array<Dynamic>>):Dynamic {
		var o:Dynamic = {};
		for (p in pairs) {
			Reflect.setField(o, p[0], p[1]);
		}
		return o;
	}

	function listen(types:Array<String>) {
		events = [];
		for (t in types) {
			model.addEventListener(t, function(e:Dynamic) events.push({type: e.type, data: e.data}));
		}
	}

	function countType(type:String):Int {
		var n = 0;
		for (e in events) {
			if (e.type == type) {
				n++;
			}
		}
		return n;
	}

	static function groupsOf(g0:Array<Dynamic>, g1:Array<Dynamic>):Dictionary<Int, Array<Dynamic>> {
		var g:Dictionary<Int, Array<Dynamic>> = new Dictionary<Int, Array<Dynamic>>();
		g.set(0, g0);
		g.set(1, g1);
		return g;
	}

	// :20-32 事件名常量（"Warehouse*" 三连是原版从仓库模型拷贝的原文，照抄）
	public function test_event_constants() {
		Assert.equals("WarehouseDataLoading", DecorateModel.EVENT_DATA_LOADING); // :20
		Assert.equals("WarehouseDataLoaded", DecorateModel.EVENT_DATA_LOADED); // :22
		Assert.equals("WarehouseDataFailed", DecorateModel.EVENT_DATA_FAILED); // :24
		Assert.equals("DataChanged", DecorateModel.EVENT_DATA_CHANGED); // :26
		Assert.equals("DataStatusChanged", DecorateModel.EVENT_DATA_STATUS_CHANGED); // :28
		Assert.equals("OperateFailed", DecorateModel.EVENT_OPERATE_FAILED); // :30
		Assert.equals("RefreshMainScene", DecorateModel.NOTIFY_REFRESH_MAINSCENE); // :32
	}

	// :48-59 ctor 零位（sceneDecorates 预置空表，setMyDecorate 无键早退）
	public function test_ctor_defaults() {
		var raw = new DecorateModel(null);
		Assert.isNull(raw.m_decorGroup); // :51
		Assert.isTrue(raw.m_dirty); // :52
		Assert.isNull(raw.m_boardArray); // :53
		Assert.equals(-1, raw.m_myBoardID); // :54
		Assert.equals(-1, raw.m_myDogID); // :55
		Assert.isFalse(raw.m_loading); // :56
		Assert.isFalse(raw.m_requesting); // :57
	}

	// :171-174/:416-419 dirty 存取对（DecorateController.onNeedReload 经此
	// 重开装载门，DecorateController.as:84-90）
	public function test_dirty_property_roundtrip() {
		Assert.isTrue(model.dirty);
		model.dirty = false;
		Assert.isFalse(model.dirty);
		model.dirty = true;
		Assert.isTrue(model.dirty);
	}

	// :398-414 setMyDecorate：键 "9"（DECOR_BILLBOARD.toString()）带 itemId →
	// myBoardID；键 "8"（DECOR_DOG）→ myDogID = 80000 + itemId；null / 空表 /
	// 有键无 itemId 均不动
	public function test_setMyDecorate_maps_billboard_and_dog_keys() {
		model.setMyDecorate(null); // :400-402
		Assert.equals(-1, model.m_myBoardID);
		Assert.equals(-1, model.m_myDogID);

		model.setMyDecorate(obj([])); // 无 "9"/"8" 键
		Assert.equals(-1, model.m_myBoardID);
		Assert.equals(-1, model.m_myDogID);

		model.setMyDecorate(obj([["9", obj([["itemId", 90003]])], ["8", obj([["itemId", 5]])]]));
		Assert.equals(90003, model.m_myBoardID); // :404-408
		Assert.equals(80005, model.m_myDogID); // :409-413（80000+5）
		Assert.equals(80005, model.myDogID); // :143-146 getter

		// 有键无 itemId → 不动（:405/:410 的 itemId 双判）
		var m2 = freshModel();
		m2.setMyDecorate(obj([["9", obj([])], ["8", obj([])]]));
		Assert.equals(-1, m2.m_myBoardID);
		Assert.equals(-1, m2.m_myDogID);
	}

	// :522-535 loadItems 门位：dirty=false 直退；loading 中直退不重复派发；
	// 开工置 m_loading、派 LOADING{show:true}，dirty 只在应答里清
	// （onDataLoadSuccess :310）；:283-293 resetLoadingFlags 复位后可再发
	public function test_loadItems_gates_and_loading_dispatch() {
		listen([DecorateModel.EVENT_DATA_LOADING]);
		model.loadItems();
		Assert.equals(1, countType("WarehouseDataLoading"));
		Assert.isTrue(Reflect.field(events[0].data, "show")); // :534
		Assert.isTrue(model.m_loading); // :532
		Assert.isTrue(model.m_dirty); // :531 只在应答里清

		model.loadItems(); // :528-531 loading 中直退
		Assert.equals(1, countType("WarehouseDataLoading"));

		model.resetLoadingFlags(); // :283-293
		Assert.isFalse(model.m_loading);
		Assert.isFalse(model.m_requesting);
		model.loadItems();
		Assert.equals(2, countType("WarehouseDataLoading"));

		// dirty=false → 直退、不派发（:524-527）
		model = freshModel();
		model.m_dirty = false;
		listen([DecorateModel.EVENT_DATA_LOADING]);
		model.loadItems();
		Assert.equals(0, countType("WarehouseDataLoading"));
		Assert.isFalse(model.m_loading);
	}

	// :295-376 onDataLoadSuccess：[current, items]（DecorateItemsParser 定
	// 序）→ 组 0/组 1 装载；loading/dirty 复位；组内在用狗（type 8 且
	// status 1）回填 myDogID；先 LOADING{show:false} 再 LOADED{index:0,data:组}；
	// 空子表落 null 组（:333-335/:346-350 的 null 初值保底）
	public function test_onDataLoadSuccess_populates_groups_and_records_dog() {
		var dog = new DecorateItem({id: 80003, itemId: 3, itemType: 8, status: 1});
		var fence0 = new DecorateItem({id: 300, itemType: 3, status: 1});
		var fence1 = new DecorateItem({id: 301, itemType: 3, status: 0});
		var bg = new DecorateItem({id: 100, itemType: 1, status: 0});
		listen([DecorateModel.EVENT_DATA_LOADING, DecorateModel.EVENT_DATA_LOADED,
			DecorateModel.EVENT_DATA_CHANGED]);
		model.onDataLoadSuccess(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null, [[dog, fence0], [fence1, bg]]));

		Assert.isFalse(model.m_loading); // :309
		Assert.isFalse(model.m_dirty); // :310
		Assert.equals(80003, model.m_myDogID); // :351-354 组 0 在用狗
		var groups:Dictionary<Int, Array<Dynamic>> = model.m_decorGroup;
		Assert.isFalse(groups == null);
		Assert.equals(2, groups.get(0).length); // :368
		Assert.equals(dog, groups.get(0)[0]); // 存引用
		Assert.equals(2, groups.get(1).length); // :369
		// 首装期间组表刚建为空（:329-331），狗 setter 零圈 → 只有收尾两连发
		Assert.equals(2, events.length);
		Assert.equals("WarehouseDataLoading", events[0].type); // :370
		Assert.isFalse(Reflect.field(events[0].data, "show"));
		var loaded = events[1];
		Assert.equals("WarehouseDataLoaded", loaded.type); // :371-374
		Assert.equals(0, Reflect.field(loaded.data, "index"));
		Assert.equals(groups, Reflect.field(loaded.data, "data"));

		// 空子表：组 0 落 null、组 1 照装、无狗不动（-1）
		var m2 = freshModel();
		m2.onDataLoadSuccess(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null, [[], [bg]]));
		Assert.isNull(m2.m_decorGroup.get(0)); // :333-335/_loc6_ 保持 null
		Assert.equals(1, m2.m_decorGroup.get(1).length);
		Assert.equals(-1, m2.m_myDogID);
	}

	// :311-328 空应答（[]）：m_decorGroup 清键置 null，派 LOADING{show:false}
	// +LOADED{index:0,data:null}；:304-308 VO 缺数据直退：loading/dirty 保持
	public function test_onDataLoadSuccess_empty_clears_and_null_vo_early_return() {
		var bg = new DecorateItem({id: 100, itemType: 1, status: 1});
		model.onDataLoadSuccess(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null, [[bg], [bg]]));
		Assert.isFalse(model.m_decorGroup == null);

		listen([DecorateModel.EVENT_DATA_LOADING, DecorateModel.EVENT_DATA_LOADED]);
		model.onDataLoadSuccess(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null, []));
		Assert.isNull(model.m_decorGroup); // :314-321 清空置 null
		Assert.isFalse(model.m_loading); // :309
		Assert.isFalse(model.m_dirty); // :310
		Assert.equals(1, countType("WarehouseDataLoading"));
		Assert.isFalse(Reflect.field(events[0].data, "show")); // :322
		var loaded = events[1];
		Assert.equals("WarehouseDataLoaded", loaded.type); // :323-326
		Assert.equals(0, Reflect.field(loaded.data, "index"));
		Assert.isNull(Reflect.field(loaded.data, "data"));

		// VO 缺数据 → 直退（loading 是调用方自置的，保持）
		var m2 = freshModel();
		m2.m_loading = true;
		m2.onDataLoadSuccess(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null, null));
		Assert.isTrue(m2.m_loading); // :304-308 未触碰
		Assert.isTrue(m2.m_dirty);
	}

	// :336-343+:351-354 二次装载：旧组先 splice 清空（键保留），新数据里
	// 首次出现在用狗 → myDogID setter（:206-253）在组 0/1 赋值（:368-369）
	// 之前触发，沿旧字典的两个键各派一记 DataChanged{index:0}（:248-251 在
	// for-in 体内），随后才是 LOADING{show:false}/LOADED——事件序钉死
	public function test_onDataLoadSuccess_reload_splices_old_groups_and_dog_setter_fires_early() {
		var fence0 = new DecorateItem({id: 300, itemType: 3, status: 1});
		var fence1 = new DecorateItem({id: 301, itemType: 3, status: 0});
		model.onDataLoadSuccess(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null, [[fence0], [fence1]]));
		var oldGroups:Dictionary<Int, Array<Dynamic>> = model.m_decorGroup;
		var oldGroup0:Array<Dynamic> = oldGroups.get(0);
		Assert.equals(1, oldGroup0.length);

		model.m_dirty = true; // 重开装载门
		var dog = new DecorateItem({id: 80003, itemId: 3, itemType: 8, status: 1});
		listen([DecorateModel.EVENT_DATA_LOADING, DecorateModel.EVENT_DATA_LOADED,
			DecorateModel.EVENT_DATA_CHANGED]);
		model.onDataLoadSuccess(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null, [[dog], [dog]]));
		Assert.equals(80003, model.m_myDogID); // 两组各扫一遍（:351-354/:363-366）
		Assert.equals(0, oldGroup0.length); // :336-343 旧数组被 splice 清空
		// 事件序：DataChanged×2（旧字典键 0/1 各一记）→ Loading{show:false} → Loaded
		Assert.equals(4, events.length);
		Assert.equals("DataChanged", events[0].type);
		Assert.equals("DataChanged", events[1].type);
		Assert.equals(0, Reflect.field(events[0].data, "index")); // :249
		Assert.equals("WarehouseDataLoading", events[2].type);
		Assert.isFalse(Reflect.field(events[2].data, "show"));
		Assert.equals("WarehouseDataLoaded", events[3].type);
		// 组 0 换新数组（旧引用已弃）
		Assert.isTrue(model.m_decorGroup.get(0) != oldGroup0);
	}

	// :105-141 set myBoardID：同值直退；换值时 boardArray 全表按新 id 重标
	// （非 -1：命中 1 其余 0；-1：只清旧 id 一行并 break），派
	// DataChanged{index:1,newItemId,oldItemId}；boardArray 未装载不派发
	public function test_myBoardID_setter_board_array_statuses() {
		var boards:Array<Dynamic> = [obj([["id", 90001]]), obj([["id", 90003]]), obj([["id", 90005]])];
		model.m_boardArray = boards;
		model.m_myBoardID = 90003;
		listen([DecorateModel.EVENT_DATA_CHANGED]);
		model.myBoardID = 90005;
		Assert.equals(90005, model.m_myBoardID);
		Assert.equals(0, Reflect.field(boards[0], "status")); // :120-127 全表重标
		Assert.equals(0, Reflect.field(boards[1], "status"));
		Assert.equals(1, Reflect.field(boards[2], "status"));
		Assert.equals(1, countType("DataChanged"));
		Assert.equals(1, Reflect.field(events[0].data, "index")); // :136
		Assert.equals(90005, Reflect.field(events[0].data, "newItemId")); // :137
		Assert.equals(90003, Reflect.field(events[0].data, "oldItemId")); // :138

		model.myBoardID = 90005; // :108-111 同值直退
		Assert.equals(1, countType("DataChanged"));

		// -1 路径：只清旧 id 的行并 break（:129-133）——哨兵钉「其余行不动」
		Reflect.setField(boards[0], "status", 7);
		Reflect.setField(boards[1], "status", 7);
		model.myBoardID = -1;
		Assert.equals(7, Reflect.field(boards[0], "status"));
		Assert.equals(7, Reflect.field(boards[1], "status"));
		Assert.equals(0, Reflect.field(boards[2], "status")); // 旧 id 90005
		Assert.equals(2, countType("DataChanged")); // -1 也派（:135-139）

		// boardArray null → 只换值不派发（:114 门）
		model = freshModel();
		listen([DecorateModel.EVENT_DATA_CHANGED]);
		model.myBoardID = 90003;
		Assert.equals(0, countType("DataChanged"));
		Assert.equals(90003, model.m_myBoardID);
		Assert.equals(90003, model.myBoardID); // :494-497 getter
	}

	// :206-253 set myDogID：同值直退；非 -1 → 各组 DECOR_DOG 全表重标（命中
	// 1 其余 0，非狗不动）；-1 → 各组只清旧 id 一行 break；每组各派一记
	// DataChanged{index:0,data:组表}（:248-251 在 for-in 体内，两组=两记）；
	// 组表 null 零派发
	public function test_myDogID_setter_group_statuses_and_per_group_dispatch() {
		var dogA0 = new DecorateItem({id: 80003, itemType: 8, status: 1});
		var fence0 = new DecorateItem({id: 300, itemType: 3, status: 1});
		var dogB0 = new DecorateItem({id: 80005, itemType: 8, status: 0});
		var dogA1 = new DecorateItem({id: 80003, itemType: 8, status: 1});
		var dogB1 = new DecorateItem({id: 80005, itemType: 8, status: 0});
		var groups:Dictionary<Int, Array<Dynamic>> = groupsOf([dogA0, fence0, dogB0], [dogA1, dogB1]);
		model.m_decorGroup = groups;
		model.m_myDogID = 80003;

		listen([DecorateModel.EVENT_DATA_CHANGED]);
		model.myDogID = 80005;
		Assert.equals(80005, model.m_myDogID);
		Assert.equals(0, dogA0._status); // :226-233 组内同型全表重标
		Assert.equals(1, dogB0._status);
		Assert.equals(1, fence0._status); // :224 非狗不动
		Assert.equals(0, dogA1._status);
		Assert.equals(1, dogB1._status);
		Assert.equals(2, countType("DataChanged")); // :248-251 两组各一记
		Assert.equals(0, Reflect.field(events[0].data, "index")); // :249
		Assert.equals(groups, Reflect.field(events[0].data, "data")); // :250

		model.myDogID = 80005; // :211-214 同值直退
		Assert.equals(2, countType("DataChanged"));

		// -1：各组首个旧 id 命中行清 0 后 break（:239-246）——哨兵钉
		dogA0._status = 7;
		dogA1._status = 7;
		model.myDogID = -1;
		Assert.equals(7, dogA0._status); // 组 0 在命中行（dogB0）之前，不动
		Assert.equals(0, dogB0._status); // 旧 id 80005 命中
		Assert.equals(7, dogA1._status); // 组 1 命中行之前，不动
		Assert.equals(0, dogB1._status);
		Assert.equals(4, countType("DataChanged")); // -1 也逐组派

		// 组表 null → for-in 零圈、零派发，值照换
		model = freshModel();
		listen([DecorateModel.EVENT_DATA_CHANGED]);
		model.myDogID = 80003;
		Assert.equals(0, countType("DataChanged"));
		Assert.equals(80003, model.m_myDogID);
	}

	// :176-204 loadBoards：boards 配置倒序装载（reverse 原地翻转）、按
	// myBoardID 标 status（命中 1 其余 0）、派 LOADED{index:1,data:表}；
	// 二调直退。行形状照 nc_data.php:5978-5982
	public function test_loadBoards_reverses_marks_and_dispatches_once() {
		Settings.getInstance().setConfigDataModel(new FakeConfigModel(obj([["boards", [
			obj([["asset_id", "1719"], ["id", 90001], ["name", "牌子"]]),
			obj([["asset_id", "1723"], ["id", 90003], ["name", "牌子"]]),
			obj([["asset_id", "1727"], ["id", 90005], ["name", "牌子"]])]]])));
		model.m_myBoardID = 90003;
		listen([DecorateModel.EVENT_DATA_LOADED]);
		model.loadBoards();
		var boards:Array<Dynamic> = model.m_boardArray;
		Assert.isFalse(boards == null);
		Assert.equals(3, boards.length);
		Assert.equals(90005, Reflect.field(boards[0], "id")); // :184 倒序
		Assert.equals(90003, Reflect.field(boards[1], "id"));
		Assert.equals(90001, Reflect.field(boards[2], "id"));
		Assert.equals(0, Reflect.field(boards[0], "status")); // :188-198
		Assert.equals(1, Reflect.field(boards[1], "status"));
		Assert.equals(0, Reflect.field(boards[2], "status"));
		Assert.equals(1, countType("WarehouseDataLoaded"));
		Assert.equals(1, Reflect.field(events[0].data, "index")); // :201
		Assert.equals(boards, Reflect.field(events[0].data, "data")); // :202

		model.loadBoards(); // :179-182 二调直退
		Assert.equals(1, countType("WarehouseDataLoaded"));
	}

	// :255-281 selectBoard 门位：负 id 直退不占请求位；其余两条分支（同 id
	// 走 deactive、异 id 走 active——请求参数 {id,type:1} 拼装不可观测，见
	// 类头环境口径）都置 m_requesting 请求位；复位走 resetLoadingFlags
	// （:283-293）或应答
	public function test_selectBoard_guards_and_latch() {
		model.selectBoard(-1); // :261-263
		Assert.isFalse(model.m_requesting);
		model.selectBoard(90003); // ≠ myBoardID(-1) → active 分支（:275-280）
		Assert.isTrue(model.m_requesting);
		model.resetLoadingFlags();
		Assert.isFalse(model.m_requesting);
		model.m_myBoardID = 90003;
		model.selectBoard(90003); // == myBoardID → deactive 分支（:266-272）
		Assert.isTrue(model.m_requesting);
	}

	// :443-466 selectDecorate：status==1 走 deactive、status==0 走 active，
	// 两分支都置请求位（请求参数拼装不可观测）
	public function test_selectDecorate_latch_both_branches() {
		var active = new DecorateItem({id: 300, itemType: 3, status: 0});
		model.selectDecorate(active); // :459-465 active 分支
		Assert.isTrue(model.m_requesting);
		model.resetLoadingFlags();
		Assert.isFalse(model.m_requesting);
		var equipped = new DecorateItem({id: 300, itemType: 3, status: 1});
		model.selectDecorate(equipped); // :451-457 deactive 分支
		Assert.isTrue(model.m_requesting);
	}

	// :378-396 onSelectBoardSuccess：code==1（协议 int，AS3 与 "1" 松等）→
	// 回填 myBoardID（走 setter 重标 boardArray）+REFRESH{type:9,id}；code!=1
	// 只复位请求位；VO 缺数据直退（请求位保持）
	public function test_onSelectBoardSuccess_updates_board_and_notifies() {
		var boards:Array<Dynamic> = [obj([["id", 90001]]), obj([["id", 90003]]), obj([["id", 90005]])];
		model.m_boardArray = boards;
		model.m_myBoardID = 90003;
		model.m_requesting = true;
		listen([DecorateModel.EVENT_DATA_CHANGED, DecorateModel.NOTIFY_REFRESH_MAINSCENE]);
		model.onSelectBoardSuccess(voEvent(CommandDefs.CMD_ACTIVE_DECORATE,
			{id: 90005, type: 1}, obj([["code", 1], ["id", 90005]])));
		Assert.equals(90005, model.m_myBoardID); // :388-389
		Assert.equals(1, Reflect.field(boards[2], "status")); // setter 全表重标
		Assert.equals(0, Reflect.field(boards[1], "status"));
		Assert.equals("DataChanged", events[0].type); // setter 先派（:389）
		var refresh = events[1];
		Assert.equals("RefreshMainScene", refresh.type); // :390-393
		Assert.equals(9, Reflect.field(refresh.data, "type")); // Consts.DECOR_BILLBOARD
		Assert.equals(90005, Reflect.field(refresh.data, "id"));
		Assert.isFalse(model.m_requesting); // :395

		// code!=1：无派发、只复位
		model.m_requesting = true;
		listen([DecorateModel.EVENT_DATA_CHANGED, DecorateModel.NOTIFY_REFRESH_MAINSCENE]);
		model.onSelectBoardSuccess(voEvent(CommandDefs.CMD_ACTIVE_DECORATE,
			{id: 90005, type: 1}, obj([["code", 0], ["id", 90005]])));
		Assert.equals(0, events.length); // :386 门未过
		Assert.isFalse(model.m_requesting);

		// VO 缺数据 → 直退，请求位保持（:381-385）
		model.m_requesting = true;
		model.onSelectBoardSuccess(voEvent(CommandDefs.CMD_ACTIVE_DECORATE, {id: 90005, type: 1}, null));
		Assert.isTrue(model.m_requesting);
		Assert.equals(90005, model.m_myBoardID); // 未动
	}

	// :499-520 onDeSelectBoardSuccess：code==1 且 id==当前 → myBoardID=-1
	// （setter 清 boardArray 旧行）+REFRESH{type:9,id:-1}；id 失配 → 值不动
	// （:510 门）但 REFRESH 照发（:514-517 无条件）
	public function test_onDeSelectBoardSuccess_clears_or_mismatch_still_notifies() {
		var boards:Array<Dynamic> = [obj([["id", 90005]]), obj([["id", 90003]])];
		model.m_boardArray = boards;
		model.m_myBoardID = 90005;
		model.m_requesting = true;
		listen([DecorateModel.EVENT_DATA_CHANGED, DecorateModel.NOTIFY_REFRESH_MAINSCENE]);
		model.onDeSelectBoardSuccess(voEvent(CommandDefs.CMD_DEACTIVE_DECORATE,
			{id: 90005, type: 1}, obj([["code", 1], ["id", 90005]])));
		Assert.equals(-1, model.m_myBoardID); // :510-513
		Assert.equals(0, Reflect.field(boards[0], "status")); // setter 清旧行
		var refresh = events[1];
		Assert.equals("RefreshMainScene", refresh.type); // :514-517
		Assert.equals(9, Reflect.field(refresh.data, "type"));
		Assert.equals(-1, Reflect.field(refresh.data, "id"));
		Assert.isFalse(model.m_requesting); // :519

		// id 失配：值保持、REFRESH 照发
		model.m_myBoardID = 90003;
		Reflect.setField(boards[1], "status", 7); // 哨兵：setter 没跑就不动
		model.m_requesting = true;
		listen([DecorateModel.EVENT_DATA_CHANGED, DecorateModel.NOTIFY_REFRESH_MAINSCENE]);
		model.onDeSelectBoardSuccess(voEvent(CommandDefs.CMD_DEACTIVE_DECORATE,
			{id: 90009, type: 1}, obj([["code", 1], ["id", 90009]])));
		Assert.equals(90003, model.m_myBoardID); // 未动
		Assert.equals(7, Reflect.field(boards[1], "status"));
		Assert.equals(0, countType("DataChanged"));
		Assert.equals(1, countType("RefreshMainScene"));
		Assert.equals(-1, Reflect.field(events[0].data, "id"));
		Assert.isFalse(model.m_requesting);
	}

	// :537-630 onSelectDecorateSuccess 启用路径 A：组 1（items）同型全表重标
	// （命中 1 其余 0，:563-577）；组 0（current）首个同型槽位是别 id → 整槽
	// 换成组 1 的实例引用（:600），派 DataChanged{index:0}（:613-616）+
	// REFRESH{type,id}（:625-628）
	public function test_onSelectDecorateSuccess_replaces_current_slot_and_mass_updates() {
		var bg100 = new DecorateItem({id: 100, itemType: 1, status: 1});
		var curFence = new DecorateItem({id: 300, itemType: 3, status: 1});
		var ownFence300 = new DecorateItem({id: 300, itemType: 3, status: 1});
		var ownFence301 = new DecorateItem({id: 301, itemType: 3, status: 0});
		var groups:Dictionary<Int, Array<Dynamic>> = groupsOf([bg100, curFence], [ownFence300, ownFence301]);
		model.m_decorGroup = groups;
		model.m_requesting = true;
		listen([DecorateModel.EVENT_DATA_CHANGED, DecorateModel.EVENT_DATA_STATUS_CHANGED,
			DecorateModel.NOTIFY_REFRESH_MAINSCENE]);
		model.onSelectDecorateSuccess(voEvent(CommandDefs.CMD_ACTIVE_DECORATE,
			{id: 301, type: 3}, obj([["code", 1], ["id", 301]])));
		Assert.isFalse(model.m_requesting); // :555（code 判之前复位）
		Assert.equals(0, ownFence300._status); // :573-574 同型其余 0
		Assert.equals(1, ownFence301._status); // :569-570 命中 1
		var cur:Array<Dynamic> = groups.get(0);
		Assert.equals(2, cur.length); // 组 0 已有同型槽，不增位
		Assert.equals(bg100, cur[0]); // 异型槽不动
		Assert.equals(ownFence301, cur[1]); // :600 换成组 1 实例
		Assert.isTrue(cur[1] != curFence);
		Assert.equals(1, countType("DataChanged")); // :613-616（_loc12_==0）
		Assert.equals(0, countType("DataStatusChanged"));
		var refresh = events[events.length - 1];
		Assert.equals("RefreshMainScene", refresh.type);
		Assert.equals(3, Reflect.field(refresh.data, "type"));
		Assert.equals(301, Reflect.field(refresh.data, "id"));
	}

	// :537-630 启用路径 B：组 0 首个同型槽位已是同 id → 原位抄组 1 实例的
	// status（:595-596）、_loc12_=1 → 派 DataStatusChanged{type,id} 而非
	// DataChanged（:620-623）；组 0 后续同型行不扫（:603 break）——哨兵钉住
	public function test_onSelectDecorateSuccess_same_id_updates_in_place_status_changed() {
		var cur301 = new DecorateItem({id: 301, itemType: 3, status: 0});
		var cur305 = new DecorateItem({id: 305, itemType: 3, status: 1});
		var own301 = new DecorateItem({id: 301, itemType: 3, status: 0});
		var groups:Dictionary<Int, Array<Dynamic>> = groupsOf([cur301, cur305], [own301]);
		model.m_decorGroup = groups;
		listen([DecorateModel.EVENT_DATA_CHANGED, DecorateModel.EVENT_DATA_STATUS_CHANGED,
			DecorateModel.NOTIFY_REFRESH_MAINSCENE]);
		model.onSelectDecorateSuccess(voEvent(CommandDefs.CMD_ACTIVE_DECORATE,
			{id: 301, type: 3}, obj([["code", 1], ["id", 301]])));
		Assert.equals(1, own301._status); // 组 1 命中
		Assert.equals(1, cur301._status); // :595-596 原位抄
		Assert.equals(cur301, groups.get(0)[0]); // 槽位不换实例
		Assert.equals(1, cur305._status); // :603 break——同型后续行不动
		Assert.equals(0, countType("DataChanged"));
		Assert.equals(1, countType("DataStatusChanged")); // :620-623
		Assert.equals(3, Reflect.field(events[0].data, "type"));
		Assert.equals(301, Reflect.field(events[0].data, "id"));
		Assert.equals(1, countType("RefreshMainScene"));
	}

	// :537-630 启用路径 C + 早退：组 0 无该类型槽 → 组 1 实例 push 进组 0
	// （:607-610）派 DataChanged；id/type 不在组 1 → _loc7_ null 早退
	// （:578-581，无派发）；VO 缺数据直退（:550-554，请求位保持）
	public function test_onSelectDecorateSuccess_push_when_type_absent_and_early_returns() {
		var bg100 = new DecorateItem({id: 100, itemType: 1, status: 1});
		var own301 = new DecorateItem({id: 301, itemType: 3, status: 0});
		var groups:Dictionary<Int, Array<Dynamic>> = groupsOf([bg100], [own301]);
		model.m_decorGroup = groups;
		listen([DecorateModel.EVENT_DATA_CHANGED, DecorateModel.EVENT_DATA_STATUS_CHANGED,
			DecorateModel.NOTIFY_REFRESH_MAINSCENE]);
		model.onSelectDecorateSuccess(voEvent(CommandDefs.CMD_ACTIVE_DECORATE,
			{id: 301, type: 3}, obj([["code", 1], ["id", 301]])));
		Assert.equals(2, groups.get(0).length); // :607-610 push
		Assert.equals(own301, groups.get(0)[1]);
		Assert.equals(1, countType("DataChanged"));
		Assert.equals(1, countType("RefreshMainScene"));

		// 组 1 无此 (id,type) → 早退，无任何派发（请求位已在 :555 复位）
		model.m_requesting = true;
		listen([DecorateModel.EVENT_DATA_CHANGED, DecorateModel.EVENT_DATA_STATUS_CHANGED,
			DecorateModel.NOTIFY_REFRESH_MAINSCENE]);
		model.onSelectDecorateSuccess(voEvent(CommandDefs.CMD_ACTIVE_DECORATE,
			{id: 999, type: 3}, obj([["code", 1], ["id", 999]])));
		Assert.equals(0, events.length); // :578-581
		Assert.isFalse(model.m_requesting);
		Assert.equals(2, groups.get(0).length); // 组 0 不动

		// VO 缺数据 → 直退（请求位保持）
		model.m_requesting = true;
		model.onSelectDecorateSuccess(voEvent(CommandDefs.CMD_ACTIVE_DECORATE, {id: 301, type: 3}, null));
		Assert.isTrue(model.m_requesting); // :550-554
	}

	// :61-103 onDeSelectDecorateSuccess：各组首个 (id,type) 命中行清 0 后
	// break（:78-89——组 1 的后续同型行不动，哨兵钉）；派
	// DataStatusChanged{type,id}+REFRESH{type,id:-1}
	public function test_onDeSelectDecorateSuccess_clears_per_group_first_match() {
		var cur300 = new DecorateItem({id: 300, itemType: 3, status: 1});
		var own300 = new DecorateItem({id: 300, itemType: 3, status: 1});
		var own301 = new DecorateItem({id: 301, itemType: 3, status: 1});
		var groups:Dictionary<Int, Array<Dynamic>> = groupsOf([cur300], [own300, own301]);
		model.m_decorGroup = groups;
		model.m_requesting = true;
		listen([DecorateModel.EVENT_DATA_CHANGED, DecorateModel.EVENT_DATA_STATUS_CHANGED,
			DecorateModel.NOTIFY_REFRESH_MAINSCENE]);
		model.onDeSelectDecorateSuccess(voEvent(CommandDefs.CMD_DEACTIVE_DECORATE,
			{id: 300, type: 3}, obj([["code", 1], ["id", 300]])));
		Assert.isFalse(model.m_requesting); // :73
		Assert.equals(0, cur300._status); // 组 0 命中
		Assert.equals(0, own300._status); // 组 1 首个命中
		Assert.equals(1, own301._status); // :84-88 break——后续不动
		Assert.equals(0, countType("DataChanged"));
		Assert.equals(1, countType("DataStatusChanged")); // :94-97
		Assert.equals(3, Reflect.field(events[0].data, "type"));
		Assert.equals(300, Reflect.field(events[0].data, "id"));
		Assert.equals(1, countType("RefreshMainScene")); // :98-101
		Assert.equals(3, Reflect.field(events[1].data, "type"));
		Assert.equals(-1, Reflect.field(events[1].data, "id"));
	}

	// :90-93+:148-169 背景类型（type 1）停用后补默认背景：各组里
	// DECOR_BACKGROUND 的 id==-1 槽标 1、其余背景 0、非背景不动
	public function test_onDeSelectDecorateSuccess_background_resets_default() {
		var curBg = new DecorateItem({id: 100, itemType: 1, status: 1});
		var defaultBg = new DecorateItem({id: -1, itemType: 1, status: 0});
		var fence = new DecorateItem({id: 300, itemType: 3, status: 1});
		var groups:Dictionary<Int, Array<Dynamic>> = groupsOf([curBg], [defaultBg, fence]);
		model.m_decorGroup = groups;
		listen([DecorateModel.EVENT_DATA_STATUS_CHANGED, DecorateModel.NOTIFY_REFRESH_MAINSCENE]);
		model.onDeSelectDecorateSuccess(voEvent(CommandDefs.CMD_DEACTIVE_DECORATE,
			{id: 100, type: 1}, obj([["code", 1], ["id", 100]])));
		Assert.equals(0, curBg._status); // :83-88 命中清 0
		Assert.equals(1, defaultBg._status); // :158-160 默认件顶上
		Assert.equals(1, fence._status); // :156 非背景不动
		Assert.equals(1, Reflect.field(events[0].data, "type")); // :94-97
		Assert.equals(100, Reflect.field(events[0].data, "id"));
		Assert.equals(1, Reflect.field(events[1].data, "type")); // :98-101
		Assert.equals(-1, Reflect.field(events[1].data, "id"));

		// VO 缺数据 → 直退（请求位保持，:68-72）
		var m2 = freshModel();
		m2.m_requesting = true;
		m2.onDeSelectDecorateSuccess(voEvent(CommandDefs.CMD_DEACTIVE_DECORATE, {id: 100, type: 1}, null));
		Assert.isTrue(m2.m_requesting);
	}

	// :421-441 失败回调：字面文案（AS3 硬编码串，非 Language 表）派
	// OperateFailed{error}+复位请求位；VO 缺数据直退（请求位保持）
	public function test_failed_callbacks_dispatch_error_and_reset() {
		model.m_requesting = true;
		listen([DecorateModel.EVENT_OPERATE_FAILED]);
		model.onSelectFailed(voEvent(CommandDefs.CMD_ACTIVE_DECORATE, {id: 301, type: 3}, obj([["code", 0]])));
		Assert.equals(1, countType("OperateFailed"));
		Assert.equals("设置装饰失败", Reflect.field(events[0].data, "error")); // :439
		Assert.isFalse(model.m_requesting); // :440

		model.m_requesting = true;
		listen([DecorateModel.EVENT_OPERATE_FAILED]);
		model.onDeSelectFailed(voEvent(CommandDefs.CMD_DEACTIVE_DECORATE, {id: 300, type: 3}, obj([["code", 0]])));
		Assert.equals(1, countType("OperateFailed"));
		Assert.equals("取消设置装饰失败", Reflect.field(events[0].data, "error")); // :428
		Assert.isFalse(model.m_requesting);

		// VO 缺数据 → 直退
		model.m_requesting = true;
		model.onSelectFailed(voEvent(CommandDefs.CMD_ACTIVE_DECORATE, {id: 301, type: 3}, null));
		Assert.isTrue(model.m_requesting); // :433-436
	}

	// :468-479 onNetError：复位 loading、派 DataFailed{error}（Language cn
	// 表原文拼串）；dirty 不动（失败后可重拉）；VO 缺数据直退
	public function test_onNetError_message_and_flags() {
		model.m_loading = true;
		listen([DecorateModel.EVENT_DATA_FAILED]);
		model.onNetError(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null, obj([["code", 0]])));
		Assert.isFalse(model.m_loading); // :475
		Assert.isTrue(model.m_dirty); // 不在清理范围
		Assert.equals(1, countType("WarehouseDataFailed"));
		Assert.equals("请求超时，<a href='event:reload'><u><font color='#ff6600'>点击重试</font></u></a>",
			Reflect.field(events[0].data, "error")); // :476

		// VO 缺数据 → 直退（loading 保持）
		model.m_loading = true;
		listen([DecorateModel.EVENT_DATA_FAILED]);
		model.onNetError(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null, null));
		Assert.isTrue(model.m_loading); // :470-473
		Assert.equals(0, countType("WarehouseDataFailed"));
	}
}

// ShopModelTest 同款（IModel 含 INotifier 三方法），boards 表注入用
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
