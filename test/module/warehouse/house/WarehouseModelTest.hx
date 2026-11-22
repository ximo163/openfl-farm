package module.warehouse.house;

import com.qzone.qfa.events.CommandEvent;
import common.Settings;
import common.misc.Utils;
import entities.WarehouseCrop;
import entities.WarehouseFish;
import entities.WarehouseSeed;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.vo.ServiceResultVO;
import openfl.events.Event;
import utest.Assert;

/**
 * WarehouseModel 纯逻辑（issue #36）：仓库六页签数据层——装载门位与
 * LOADING/DATA_CHANGED 派发（index 表 0 蔬果/1 种子/2 花束/3 材料/5 成鱼）、
 * 作物应答单表拆三仓（isFlower==1 → flowers、type==11 → cards、其余 →
 * crops， crystals 后拼进 cards）、(lvl,id) 排序与 crops_sort _sort 表、
 * 配置补丁（isFlower/isLock/isFood/isVIP 守卫 + isLock 2→0 归一）、
 * allFlower 缺料计算（lack/canMake/pic/swf）、collectNotLockedIDs 四路
 * 过滤、isEmpty 槽表、removeSeed 递减/移除、上锁应答三仓/鱼仓回写、
 * 出售应答分支（sale/saleAll/saleSeed/sellAllSeeds/saleFish/saleAllFish
 * 的 code/errorType/direction 派发与 num 回填）、送花扣料与 m_sendFlowerID、
 * onTransactionFailed 文案、onLoadDataError 恒不派发 FAILED。
 * WarehouseController/WarehouseView/各页签是接线与显示层，归 CI web-smoke。
 *
 * 环境口径（同 #35 ShopModelTest）：
 * - NetHelper.sendRequest 在 theApp == null 时 no-op（#7 已译），测试进程
 *   不跑 Main、theApp 恒 null——请求侧（sellPlant/sellAll/sellAllSeeds/
 *   sellFish/sellAllFish/sellCrystal/sendFlower/storeUserCropLockInfo/
 *   storeUserFishLockInfo 的参数拼装）不可观测，不设测试；应答侧直接喂
 *   构造好的 CommandEvent（body 用 Utils.buildRequest 造出与真实链路同构
 *   的 {cmdID,__body,…}，result 装 ServiceResultVO，走 NetHelper.getVOData
 *   的 m_extra 分支）。
 * - 应答载荷形状按真实链路镜像：crops 应答的 m_extra 已被
 *   WarehouseCropsParser 转成 {flowerPath, crops: Array<WarehouseCrop>,
 *   allFlower: 原始对象}（fish/seeds/bag 同理由 BaseArrayParser 子类转成
 *   实体数组），故 fixture 直接构造实体。
 * - EventRecorder 按 deviations（no-qq-telemetry）DISABLED，recordResp
 *   及 recordSueecssEvent/recordErrorEvent 调用点无观测，只保不抛。
 * - QzoneJSAPI.reportError/getOnlineTime 在 eval 上安全
 *   （QQOutlets.available 恒 false，qqoutlets shim）。
 * - Settings 注入：loadLocalSettings(null) 复位 m_params（crops_sort 缺省
 *   ""→不排序、mode ""）；配置行走 setConfigDataModel(FakeConfigModel)，
 *   getCropByID/getFishByID 的 `row["id"]==param1` 松等由 As3.eqString 实现
 *   （Settings.hx:372/:112），数字形状的 id 键可直配。
 * - Consts.WAREHOUSE_CROP/FLOWER/CARD/FISH（1/2/3/4）尚未入 src（实现阶段
 *   补），字面量按 Consts.as:532-538 引用。
 * - processAllFlowers 的 need.cName 走 GetCropID.getNameByIDType（main3 侧
 *   方法，实现阶段随本模块补译）；其 getCropByID 读 theApp.model，测试进程
 *   theApp 恒 null → 查无 → 落「未知物品」（GetCropID.hx:205 缺 app 判空
 *   先例）。
 * - onCrystalsLoaded 的 WildData.reloadCrystal=false（framework.api.beast，
 *   本模块清单外）在 eval 上无观测面，不设测试。
 * - 排序方向（勿按直觉改）：sort :517-521 的 `param1._lvl >= param2._lvl
 *   ? 1 : -1` 在 AS3 Array.sort 约定下「正数 → param1 排后」→ (lvl,id)
 *   升序；比较器无 0 返回，等值元素次序无稳定保证——fixture 全取互异键。
 *
 * 出处：
 * - legacy/decompiled/warehouse_v_23/scripts/module/warehouse/house/
 *   WarehouseModel.as（常量 :27-51、字段 :53-83、ctor :85-103、
 *   onLockSuccess :105-167、onFishLockSuccess :169-196、sendFlower
 *   :203-220、onSellPlantSuccess :240-251、removeSeed :253-279、
 *   onLoadDataError :281-331、loadCrops :348-358、onCrystalsLoaded
 *   :360-382、collectNotLockedIDs :384-430、onFishsLoaded :432-468、
 *   onTransactionFailed :470-508、sort :515-522、onSellAllSeedsSuccess
 *   :534-549、isEmpty :613-624、removeMyFlower :631-652、sellFish
 *   :659-668、onSellAllSuccess :670-696、loadFishs :698-708、
 *   onFlowerSentSuccess :710-762、onSellAllFishSuccess :789-801、
 *   loadSeeds :803-813、sellSeed :833-845、loadMyFlowers :847-857、
 *   sellAllFish :859-869、onSeedsLoaded :871-911、onCropsLoaded
 *   :913-983、processAllFlowers :990-1022、sellAll :1024-1039、
 *   loadCrystal :1059-1069、onMyFlowersLoaded :1071-1106、
 *   onSellFishSuccess :1108-1120、seperateFlowers :1127-1165）
 * - legacy/deploy/QFarmFlash/source/core/source/nc/mod/cgi_farm_getusercrop.php
 *   （:15-36 crop 行字段、:38 allFlower/flowerPath 恒 "module/ui/flower"）
 * - legacy/deploy/QFarmFlash/source/core/config/nc/allflower.php
 *   （:24 fId12 完美恋人 need 3×cId41、:14 fId2 星语心愿 need 10×cId103
 *   +50×cId105）
 * - legacy/deploy/QFarmFlash/source/core/config/nc/cropstype.php:4-7
 *   （cId1 草莓 cLevel10、cId2 白萝卜 cLevel0、cId3 胡萝卜 cLevel0、
 *   cId4 玉米 cLevel3）、:43（cId41 红玫瑰 cLevel7）、:103-104
 *   （cId101 薰衣草 cLevel17、cId102 马蹄莲 cLevel18）
 * - legacy/deploy/QFarmFlash/source/core/source/xml/mod/nc_data.php
 *   （:6022 胡萝卜 isFood "1"+isLock "1" 字符串形、:6059 红玫瑰
 *   isFlower "1" 字符串形、:6119 薰衣草 isFlower 1 数值形、:6182
 *   红色景观树 isVIP 1、:6715 圣诞老人卡 id2001 type 11、:7565
 *   fish_info 小丑鱼 id2 mature23 sale90 / 蝶鱼 id4 mature30 sale85）
 * - legacy/deploy/QFarmFlash/source/core/config/mc/crystalinf.php:4-6
 *   （蓝/绿/紫水晶 sale10 type9）
 * - legacy/deploy/QFarmFlash/source/core/source/nc/mod/
 *   cgi_farm_get_usercrystal.php:15（type=9 的 info 行形状）、
 *   cgi_fish_user_rep.php:10-16（fid/lock/num/type）、
 *   cgi_farm_flower_received.php:19（myFlower/flowerPath）、
 *   repertory_sale.php:16,39（cId/code/direction/money）、
 *   repertory_saleall.php:30（code 恒 1）、cgi_farm_seed_sell.php:34
 *   （批量 code 恒 1 + money）、cgi_fish_sale.php:23,36（code 恒 1）、
 *   cgi_farm_set_lock.php:32（crop [{cId,isLock:回显 type}]）、
 *   cgi_fish_rep_lock.php:35（fid/lock 1|0）、
 *   cgi_farm_flower_send.php:31（code/direction）
 * - src/common/Language.hx:53（saleAllFnText2 模板）、:63（请求超时，稍后再试）
 * - spec/protocol.json entries.nc.mods（repertory_sale/repertory_saleall/
 *   repertory_getuserseed/cgi_farm_getusercrop/cgi_farm_get_usercrystal/
 *   cgi_fish_user_rep/cgi_farm_flower_received/cgi_farm_seed_list/
 *   cgi_farm_seed_sell/cgi_fish_sale/cgi_farm_flower_send/
 *   cgi_fish_rep_lock/cgi_farm_set_lock 及 dispatch.special）
 */
@:access(module.warehouse.house.WarehouseModel)
class WarehouseModelTest {
	public function new() {}

	var model:WarehouseModel;

	public function setup() {
		model = freshModel();
		Settings.getInstance().loadLocalSettings(null); // crops_sort/mode 复位缺省
		Settings.getInstance().setConfigDataModel(null);
	}

	public function teardown() {
		Settings.getInstance().loadLocalSettings(null);
		Settings.getInstance().setConfigDataModel(null);
	}

	// stub 的 ctor 无零位（那是实现内容 :88-102），各用例统一从这里起手
	static function freshModel():WarehouseModel {
		var m = new WarehouseModel(null);
		m.m_cropDirty = true; // AS3 ctor :88-92
		m.m_crystalDirty = true;
		m.m_seedDirty = true;
		m.m_flowerDirty = true;
		m.m_fishDirty = true;
		m.m_flowerPath = ""; // :101
		m.m_sendFlowerID = -1; // :102
		return m;
	}

	// :27-51 事件名常量 + :85-103 ctor 零位（五 dirty=true、八列表 null、
	// flowerPath ""、sendFlowerID -1）。EVENT_SENDFLOWER_SUCCESS 值是
	// "SellFlowerSuccess"（:47 原版名值不齐）
	public function test_event_constants_and_ctor_defaults() {
		Assert.equals("DataChanged", WarehouseModel.EVENT_DATA_CHANGED); // :27
		Assert.equals("WarehouseDataLoading", WarehouseModel.EVENT_DATA_LOADING); // :29
		Assert.equals("WarehouseDataFailed", WarehouseModel.EVENT_DATA_FAILED); // :31
		Assert.equals("NetTransactionError", WarehouseModel.EVENT_NET_TRANSACTION_ERROR); // :33
		Assert.equals("SellAllSuccess", WarehouseModel.EVENT_SELLALL_SUCCESS); // :35
		Assert.equals("SellPlantSuccess", WarehouseModel.EVENT_SELLPLANT_SUCCESS); // :37
		Assert.equals("SellAllFishsSuccess", WarehouseModel.EVENT_SELLALLFISHS_SUCCESS); // :39
		Assert.equals("SellFishSuccess", WarehouseModel.EVENT_SELLFISH_SUCCESS); // :41
		Assert.equals("SellSeedSuccess", WarehouseModel.EVENT_SELLSEED_SUCCESS); // :43
		Assert.equals("SellAllSeedsSuccess", WarehouseModel.EVENT_SELLALLSEEDS_SUCCESS); // :45
		Assert.equals("SellFlowerSuccess", WarehouseModel.EVENT_SENDFLOWER_SUCCESS); // :47
		Assert.equals("UpdateLockSuccess", WarehouseModel.EVENT_UPDATELOCK_SUCCESS); // :49
		Assert.equals("UpdateFishLockSuccess", WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS); // :51
		var raw = new WarehouseModel(null);
		Assert.isTrue(raw.m_cropDirty); // :88
		Assert.isTrue(raw.m_crystalDirty); // :89
		Assert.isTrue(raw.m_seedDirty); // :90
		Assert.isTrue(raw.m_flowerDirty); // :91
		Assert.isTrue(raw.m_fishDirty); // :92
		Assert.isNull(raw.m_crops); // :93
		Assert.isNull(raw.m_flowers); // :94
		Assert.isNull(raw.m_seeds); // :95
		Assert.isNull(raw.m_cards); // :96
		Assert.isNull(raw.m_crystal); // :97
		Assert.isNull(raw.m_allFlower); // :98
		Assert.isNull(raw.m_myFlower); // :99
		Assert.isNull(raw.m_fishs); // :100
		Assert.equals("", raw.m_flowerPath); // :101
		Assert.equals(-1, raw.m_sendFlowerID); // :102
	}

	// 五装载器的 LOADING 载荷表与 dirty 门位：crops {index:0,show:true}
	// :352-355、seeds {index:1,show:true} :807-810、myFlowers {index:2,
	// show:true} :851-854、crystal {index:3,show:true} :1063-1066、fish
	// {index:5,show:true} :702-705；门位翻假后不再派发（crystal/flower 无
	// 公开 setter，直写私有字段）
	public function test_loading_dispatches_and_dirty_gates() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.loadCrops();
		model.loadSeeds();
		model.loadMyFlowers();
		model.loadCrystal();
		model.loadFishs();
		Assert.equals(5, log.length);
		var table:Array<Array<Int>> = [[0, 0], [1, 1], [2, 2], [3, 3], [5, 4]]; // [index, log 行]
		for (row in table) {
			var entry = log[row[1]];
			Assert.equals(WarehouseModel.EVENT_DATA_LOADING, Reflect.field(entry, "type"));
			Assert.equals(row[0], Reflect.field(Reflect.field(entry, "data"), "index"));
			Assert.isTrue(Reflect.field(Reflect.field(entry, "data"), "show") == true);
		}

		// 门位翻假：crop/seed/fish 走公开 setter，crystal/flower 直写私有字段
		// （AS3 只有这三个的 setter :551/:608/:626）
		model.cropDirty = false;
		model.seedDirty = false;
		model.fishDirty = false;
		model.m_crystalDirty = false;
		model.m_flowerDirty = false;
		model.loadCrops();
		model.loadSeeds();
		model.loadMyFlowers();
		model.loadCrystal();
		model.loadFishs();
		Assert.equals(5, log.length); // 无新增

		// :576/:784/:828 三个 getter 是字段透传
		Assert.isFalse(model.cropDirty);
		Assert.isFalse(model.seedDirty);
		Assert.isFalse(model.fishDirty);
	}

	// :913-983 onCropsLoaded：VO null 早退在一切动作之前（:916-919）→ 零事件
	public function test_onCropsLoaded_null_vo_no_events() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model.onCropsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_CROPS, null, null));
		Assert.equals(0, log.length);
		Assert.isTrue(model.cropDirty); // :921 未执行
	}

	// :913-983 主链：flowerPath 捕获（:926-929）、配置补丁
	// （:949-972：isFlower/-1、isLock<=0、isLock==2→0、isFood/-1、isVIP/-1）、
	// (lvl,id) 排序（:978 经 :515-522 sort）、seperateFlowers 拆三仓
	// （:1127-1165：isFlower==1→flowers、isFlower<=0&&type!=11→crops、
	// type==11→cards）、DATA_CHANGED {index:0} 无 data 键（:981）
	public function test_onCropsLoaded_partition_sort_and_config_merge() {
		// 配置行逐字裁剪（键值形状保持部署原样——松等断言钉的就是形状）
		var rows:Array<Dynamic> = [
			{id: 3, isFood: "1", isLock: "1"}, // nc_data.php:6022（"1" 字符串形）
			{id: 41, isFlower: "1"}, // :6059（"1" 字符串形）
			{id: 101, isFlower: 1}, // :6119（数值形）
			{id: 169, isVIP: 1}]; // :6182
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({crops: rows}));
		// 应答侧 crop 行（cgi_farm_getusercrop.php:15-36；cLevel/cName 取自
		// cropstype.php:4-7/:43/:103），乱序进
		var berry = new WarehouseCrop({cId: 1, cName: "草莓", level: 10, price: 27, amount: 5, type: 1, isLock: 0});
		var lavender = new WarehouseCrop({cId: 101, cName: "薰衣草", level: 17, price: 63, amount: 4, type: 1, isLock: 0});
		var radish = new WarehouseCrop({cId: 2, cName: "白萝卜", level: 0, price: 17, amount: 10, type: 1, isLock: 0});
		var card = new WarehouseCrop({cId: 2001, cName: "圣诞老人卡", level: 0, price: 0, amount: 3, type: 11}); // nc_data.php:6715（type 11）
		var rose = new WarehouseCrop({cId: 41, cName: "红玫瑰", level: 7, price: 46, amount: 2, type: 1, isLock: 2}); // isLock 2 → :960-963 归 0
		var carrot = new WarehouseCrop({cId: 3, cName: "胡萝卜", level: 0, price: 21, amount: 7, type: 1, isLock: 0});
		var tree = new WarehouseCrop({cId: 169, cName: "红色景观树", level: 0, price: 1, amount: 1, type: 1}); // 应答无 isLock 键 → 实体 -1
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onCropsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_CROPS, null, {
			flowerPath: "module/ui/flower", // cgi_farm_getusercrop.php:38 恒值
			crops: [berry, lavender, radish, card, rose, carrot, tree],
			allFlower: []}));

		// 事件序：LOADING{index:0,show:false}（:922-925）→ DATA_CHANGED
		// {index:0}（:981，无 data 键）
		Assert.equals(2, log.length);
		Assert.equals(WarehouseModel.EVENT_DATA_LOADING, Reflect.field(log[0], "type"));
		Assert.isTrue(Reflect.field(Reflect.field(log[0], "data"), "show") == false);
		Assert.equals(WarehouseModel.EVENT_DATA_CHANGED, Reflect.field(log[1], "type"));
		Assert.equals(0, Reflect.field(Reflect.field(log[1], "data"), "index"));
		Assert.isNull(Reflect.field(Reflect.field(log[1], "data"), "data"));

		Assert.isFalse(model.cropDirty); // :921
		Assert.equals("module/ui/flower", model.flowerPath); // :926-929/:529-532

		// 配置补丁：isFlower 两种形状都命中（"1" 与 1）；isLock 守卫 <=0
		// 且配置 "1" 松等 1（:956-959）；isLock 2 不进守卫但 :960-963 归 0；
		// 应答缺 isLock 键的实体保持 -1（tree，配置行无 isLock 不补）
		Assert.equals(1, rose._isFlower); // :952-955
		Assert.equals(1, lavender._isFlower);
		Assert.equals(-1, radish._isFlower); // 配置行无键 → 保持 -1
		Assert.equals(0, rose._isLock); // 2 → 0（:960-963）
		Assert.equals(1, carrot._isLock); // 0 <= 0 且配置 "1"（:956-959）
		Assert.equals(0, radish._isLock); // 应答 0、配置行无键 → 保持 0
		Assert.equals(1, carrot._isFood); // :964-967
		Assert.equals(-1, radish._isFood);
		Assert.equals(1, tree._isVip); // :968-971
		Assert.equals(-1, radish._isVip);

		// (lvl,id) 升序（:978 + :515-522：lvl 平级 id 小者前）：lvl0 组
		// id 2<3<169、rose lvl7、berry lvl10、lavender lvl17（card type 11
		// 已拆去 cards）
		Assert.equals(4, model.crops.length); // :1127-1165 拆仓
		Assert.isTrue(model.crops[0] == radish);
		Assert.isTrue(model.crops[1] == carrot);
		Assert.isTrue(model.crops[2] == tree);
		Assert.isTrue(model.crops[3] == berry);
		Assert.equals(2, model.flowers.length);
		Assert.isTrue(model.flowers[0] == rose);
		Assert.isTrue(model.flowers[1] == lavender);
		Assert.equals(1, model.cards.length); // cards = type11 + crystals（:1160-1164）
		Assert.isTrue(model.cards[0] == card);
		Assert.equals(0, model.m_crystal.length); // :1160-1163 falsy → []
	}

	// :936-940 + :947：crops_sort 配置时逐仓 _sort=表内下标（ flowers/
	// cards 条目同样赋值——循环遍历的是拆仓前的整表），排序仍按 (lvl,id)
	// （:978 不看 _sort）
	public function test_onCropsLoaded_crops_sort_assigns_sort_index() {
		Settings.getInstance().loadLocalSettings({crops_sort: "2,3"}); // 合成场景（部署快照恒未配）
		// 应答行不含 isFlower（cgi_farm_getusercrop.php:15-36）——花仓归属只能
		// 来自配置合并（:952-955），与主链用例同源
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({crops: [
			{id: 41, isFlower: "1"}]})); // nc_data.php:6059（"1" 字符串形）
		var radish = new WarehouseCrop({cId: 2, level: 0, type: 1, isLock: 0});
		var carrot = new WarehouseCrop({cId: 3, level: 0, type: 1, isLock: 0});
		var berry = new WarehouseCrop({cId: 1, level: 10, type: 1, isLock: 0});
		var rose = new WarehouseCrop({cId: 41, level: 7, type: 1, isLock: 0});

		model.onCropsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_CROPS, null,
			{flowerPath: "module/ui/flower", crops: [berry, rose, radish, carrot]}));

		// _sort 按表内位置（:947，"2,3" → id2=0、id3=1），表外 -1
		Assert.equals(0, radish._sort);
		Assert.equals(1, carrot._sort);
		Assert.equals(-1, berry._sort);
		Assert.equals(-1, rose._sort);
		// 顺序仍 (lvl,id)（:978）
		Assert.isTrue(model.crops[0] == radish);
		Assert.isTrue(model.crops[1] == carrot);
		Assert.isTrue(model.flowers[0] == rose);
	}

	// :990-1022 processAllFlowers：need 逐项算 lack（:1009-1016：库存取自
	// flowers 仓 getFlowerCount :581-592，差额 int(amount-count)，倒挂为 0）、
	// 汇总 canMake（:1019）、pic/swf 路径（:1017-1018）、m_allFlower 落表
	// （:1021）；need.cName 走 GetCropID.getNameByIDType，theApp 恒 null →
	// 查无落「未知物品」。守卫：allFlower/flowerPath 任一缺键或 flowerPath
	// 空串 → 整段跳过（:997-1005）
	public function test_onCropsLoaded_processAllFlowers_lack_and_paths() {
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({crops: [
			{id: 41, isFlower: "1"}]})); // :6059 红玫瑰 → flowers 仓
		var rose = new WarehouseCrop({cId: 41, level: 7, amount: 5, type: 1, isLock: 0});
		// allflower.php:14（fId2 星语心愿：10×cId103 + 50×cId105，均无库存）
		// 与 :24（fId12 完美恋人：3×cId41，库存 5 够）
		var wish:Dynamic = {fId: 2, fName: "星语心愿", need: [{cId: 103, amount: 10}, {cId: 105, amount: 50}]};
		var lover:Dynamic = {fId: 12, fName: "完美恋人", need: [{cId: 41, amount: 3}]};

		model.onCropsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_CROPS, null,
			{flowerPath: "module/ui/flower", crops: [rose], allFlower: [wish, lover]}));

		Assert.equals(2, model.allFlower.length); // :1021/:1054-1057
		// fId2：两项 lack 相加 60 → canMake false
		Assert.equals(10, Reflect.field(Reflect.field(wish, "need")[0], "lack"));
		Assert.equals(50, Reflect.field(Reflect.field(wish, "need")[1], "lack"));
		Assert.isFalse(Reflect.field(wish, "canMake"));
		// fId12：库存 5 ≥ 3 → lack 0 → canMake true
		Assert.equals(0, Reflect.field(Reflect.field(lover, "need")[0], "lack"));
		Assert.isTrue(Reflect.field(lover, "canMake"));
		// 路径拼装（:1017-1018，flowerPath 取应答字段）
		Assert.equals("module/ui/flower/2.gif", Reflect.field(wish, "pic"));
		Assert.equals("module/ui/flower/2.swf", Reflect.field(wish, "swf"));
		Assert.equals("module/ui/flower/12.gif", Reflect.field(lover, "pic"));
		Assert.equals("module/ui/flower/12.swf", Reflect.field(lover, "swf"));
		// cName：theApp 恒 null → getNameByIDType 落「未知物品」
		Assert.equals("未知物品", Reflect.field(Reflect.field(wish, "need")[0], "cName"));

		// 守卫：应答缺 allFlower 键 → m_allFlower 保持 null、flowerPath 不写
		var fresh2 = freshModel();
		fresh2.onCropsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_CROPS, null, {crops: []}));
		Assert.isNull(fresh2.m_allFlower);
		Assert.equals("", fresh2.flowerPath); // :926 键判不进
	}

	// :360-382 onCrystalsLoaded：info 逐项建 WarehouseCrop 入 m_crystal、
	// cards = _tempCards.concat(crystal)（:372-376 _tempCards 缺省 []）、
	// DATA_CHANGED {index:3,show:true}（:377-380，注意 show 是 true）
	public function test_onCrystalsLoaded_concat_cards() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		// cgi_farm_get_usercrystal.php:15 type=9 行 + crystalinf.php:4-5
		var blue = {amount: 5, cId: 1, cName: "蓝水晶", price: 10, type: 9};
		var green = {amount: 2, cId: 2, cName: "绿水晶", price: 10, type: 9};

		model.onCrystalsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_CRYSTAL, {type: 9}, {info: [blue, green]}));

		Assert.equals(2, model.m_crystal.length);
		Assert.equals(1, model.m_crystal[0]._id);
		Assert.equals(5, model.m_crystal[0]._amount);
		Assert.equals(9, model.m_crystal[0]._type);
		Assert.equals(2, model.m_crystal[1]._id);
		Assert.equals(2, model.cards.length); // _tempCards=[] 前置（:372-376）
		Assert.equals(1, countType(log, WarehouseModel.EVENT_DATA_CHANGED));
		var d = lastData(log, WarehouseModel.EVENT_DATA_CHANGED);
		Assert.equals(3, Reflect.field(d, "index"));
		Assert.isTrue(Reflect.field(d, "show") == true);

		// 先水晶后作物：作物应答把 cards 重拼为 _tempCards + m_crystal
		// （:1159-1164），type 11 卡在前水晶在后
		var card = new WarehouseCrop({cId: 2001, level: 0, amount: 3, type: 11});
		model.onCropsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_CROPS, null,
			{flowerPath: "module/ui/flower", crops: [card]}));
		Assert.equals(3, model.cards.length);
		Assert.isTrue(model.cards[0] == card);
		Assert.equals(1, model.cards[1]._id);
		Assert.equals(2, model.cards[2]._id);
	}

	// :871-911 onSeedsLoaded：VO null 零事件（:874-877）、门位复位 +
	// LOADING{index:1,show:false}、整表替换、(lvl,id) 排序（:893）、
	// isVIP 配置补丁（:897-905 守卫 -1）、DATA_CHANGED {index:1,data}
	public function test_onSeedsLoaded_sort_and_vip_merge() {
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({crops: [
			{id: 169, isVIP: 1}]})); // nc_data.php:6182
		var radish = new WarehouseSeed({cId: 2, level: 0, amount: 10}); // cropstype.php:5
		var berry = new WarehouseSeed({cId: 1, level: 10, amount: 5}); // :4
		var corn = new WarehouseSeed({cId: 4, level: 3, amount: 2}); // :7
		var vipTree = new WarehouseSeed({cId: 169, level: 0, amount: 1});
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onSeedsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_SEEDS, null, [berry, radish, vipTree, corn]));

		Assert.isFalse(model.seedDirty); // :879
		Assert.equals(2, log.length);
		Assert.equals(WarehouseModel.EVENT_DATA_LOADING, Reflect.field(log[0], "type"));
		Assert.isTrue(Reflect.field(Reflect.field(log[0], "data"), "show") == false);
		Assert.equals(1, Reflect.field(Reflect.field(log[0], "data"), "index"));
		Assert.equals(WarehouseModel.EVENT_DATA_CHANGED, Reflect.field(log[1], "type"));
		Assert.isTrue(Reflect.field(Reflect.field(log[1], "data"), "data") == model.seeds);

		// (lvl,id) 升序：lvl0 组 id 2 < 169、corn lvl3、berry lvl10
		Assert.equals(4, model.seeds.length);
		Assert.isTrue(model.seeds[0] == radish);
		Assert.isTrue(model.seeds[1] == vipTree);
		Assert.isTrue(model.seeds[2] == corn);
		Assert.isTrue(model.seeds[3] == berry);
		Assert.equals(1, vipTree._isVip); // :900-904（-1 守卫 + 松等）
		Assert.equals(-1, radish._isVip); // 配置行无键 → 保持 -1

		// 二次应答整体替换（:884-892 splice + concat）
		model.onSeedsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_SEEDS, null, [corn]));
		Assert.equals(1, model.seeds.length);
		Assert.isTrue(model.seeds[0] == corn);

		// VO null：零事件、门位不复位（:874-877）
		var log2:Array<Dynamic> = [];
		listenModel(model, log2);
		model.seedDirty = true;
		model.onSeedsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_SEEDS, null, null));
		Assert.equals(0, log2.length);
		Assert.isTrue(model.seedDirty);
	}

	// :432-468 onFishsLoaded：VO null 零事件、LOADING{index:5,show:false}、
	// 整表替换（不排序）、名称/售价从 fish_info 补（:457-463）、
	// DATA_CHANGED {index:5,data}
	public function test_onFishsLoaded_name_sale_merge() {
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({fish_info: [
			{id: 2, crop_name: "小丑鱼", mature: 23, sale: 90}, // nc_data.php:7565
			{id: 4, crop_name: "蝶鱼", mature: 30, sale: 85}]}));
		// cgi_fish_user_rep.php:10-16 行形状（lock 是字符串数字）
		var clown = new WarehouseFish({fid: 2, num: 5, lock: "0", type: 23});
		var unknown = new WarehouseFish({fid: 999, num: 1, lock: "1", type: 23});
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onFishsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_FISH, null, [clown, unknown]));

		Assert.isFalse(model.fishDirty); // :440
		Assert.equals(2, log.length);
		Assert.equals(WarehouseModel.EVENT_DATA_LOADING, Reflect.field(log[0], "type"));
		Assert.equals(5, Reflect.field(Reflect.field(log[0], "data"), "index"));
		Assert.isTrue(Reflect.field(Reflect.field(log[0], "data"), "show") == false);
		Assert.equals(WarehouseModel.EVENT_DATA_CHANGED, Reflect.field(log[1], "type"));
		Assert.isTrue(Reflect.field(Reflect.field(log[1], "data"), "data") == model.fishs);
		// 配置合并只改 _name/_sale（:460-462），无配置行保持实体初值
		Assert.equals(2, model.fishs.length); // 不排序，应答序
		Assert.isTrue(model.fishs[0] == clown);
		Assert.equals("小丑鱼", clown._name);
		Assert.equals(90, clown._sale);
		Assert.equals("", unknown._name); // WarehouseFish.hx ctor 初值
		Assert.equals(0, unknown._sale);

		// VO null：零事件、门位不复位（:435-439）
		var log2:Array<Dynamic> = [];
		listenModel(model, log2);
		model.fishDirty = true;
		model.onFishsLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_FISH, null, null));
		Assert.equals(0, log2.length);
		Assert.isTrue(model.fishDirty);
	}

	// :1071-1106 onMyFlowersLoaded：VO null 零事件、LOADING{index:2,
	// show:false}、myFlower/flowerPath 任一缺键 → 早退（:1084-1087，门位已
	// 复位、无 DATA_CHANGED）、pic = flowerPath/fId.gif（:1099）、
	// DATA_CHANGED {index:2,data}；装载后 loadMyFlowers 不再派发（:849 门）
	public function test_onMyFlowersLoaded_pic_and_gate() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		// cgi_farm_flower_received.php:19 行形状
		var received:Dynamic = {fId: 12, time: 1320000000, fromId: 10001, friendName: "好友", word: "加油"};

		model.onMyFlowersLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_MYFLOWERS, null,
			{myFlower: [received], flowerPath: "module/ui/flower"}));

		Assert.isFalse(model.m_flowerDirty); // :1079
		Assert.equals(2, log.length);
		Assert.equals(WarehouseModel.EVENT_DATA_LOADING, Reflect.field(log[0], "type"));
		Assert.equals(2, Reflect.field(Reflect.field(log[0], "data"), "index"));
		Assert.equals(WarehouseModel.EVENT_DATA_CHANGED, Reflect.field(log[1], "type"));
		Assert.isTrue(Reflect.field(Reflect.field(log[1], "data"), "data") == model.myFlowers);
		Assert.equals("module/ui/flower/12.gif", Reflect.field(received, "pic")); // :1099

		// 门位已复位 → loadMyFlowers 不再派发
		model.loadMyFlowers();
		Assert.equals(2, log.length);

		// 缺 myFlower 键：LOADING 照发、无 DATA_CHANGED、列表保持 null
		var fresh2 = freshModel();
		var log2:Array<Dynamic> = [];
		listenModel(fresh2, log2);
		fresh2.onMyFlowersLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_MYFLOWERS, null,
			{flowerPath: "module/ui/flower"}));
		Assert.equals(1, log2.length);
		Assert.isNull(fresh2.myFlowers);
		Assert.isFalse(fresh2.m_flowerDirty); // :1079 在键判之前

		// VO null：零事件、门位不复位（:1074-1078）
		var fresh3 = freshModel();
		var log3:Array<Dynamic> = [];
		listenModel(fresh3, log3);
		fresh3.onMyFlowersLoaded(voEvent(CommandDefs.CMD_GET_WAREHOUSE_MYFLOWERS, null, null));
		Assert.equals(0, log3.length);
		Assert.isTrue(fresh3.m_flowerDirty);
	}

	// :384-430 collectNotLockedIDs：1(crop)/2(flower)/4(fish)/其余(card) 四路，
	// 过滤 _id > 0 && _isLock <= 0（Consts.as:532-538 的 1/2/3/4）
	public function test_collectNotLockedIDs_slot_filter() {
		model.m_crops = [crop(1, 0), crop(2, 1), crop(3, -1), crop(0, 0)];
		model.m_flowers = [crop(41, 0), crop(42, 1)];
		model.m_fishs = [fish(2, 0), fish(4, 1), fish(0, 0)];
		model.m_cards = [crop(2001, 0)];

		Assert.same([1, 3], model.collectNotLockedIDs(1)); // WAREHOUSE_CROP
		Assert.same([41], model.collectNotLockedIDs(2)); // WAREHOUSE_FLOWER
		Assert.same([2], model.collectNotLockedIDs(4)); // WAREHOUSE_FISH
		Assert.same([2001], model.collectNotLockedIDs(3)); // WAREHOUSE_CARD → else
		Assert.same([2001], model.collectNotLockedIDs(99)); // 未列值同 else
	}

	// :613-624 isEmpty 槽表：0/1 → crops、2 → seeds、其余 → cards
	// （null 与空表都算空；与装载 index 表不同编号——原版字面）
	public function test_isEmpty_slot_table() {
		Assert.isTrue(model.isEmpty(0));
		Assert.isTrue(model.isEmpty(1));
		Assert.isTrue(model.isEmpty(2));
		Assert.isTrue(model.isEmpty(3));
		model.m_crops = [];
		Assert.isTrue(model.isEmpty(0));
		Assert.isTrue(model.isEmpty(1));
		model.m_seeds = [new WarehouseSeed({cId: 1})];
		Assert.isFalse(model.isEmpty(2));
		Assert.isTrue(model.isEmpty(0)); // 其它槽不受影响
		model.m_crops = [crop(1, 0)];
		Assert.isFalse(model.isEmpty(0));
		Assert.isFalse(model.isEmpty(1)); // 1 号也看 crops（:615-618）
		Assert.isTrue(model.isEmpty(3)); // cards 仍 null
		model.m_cards = [crop(2001, 0)];
		Assert.isFalse(model.isEmpty(3));
		Assert.isFalse(model.isEmpty(99)); // 未列值走 cards（:623）
	}

	// :253-279 removeSeed：命中递减，amount<=0 才 splice+return true（每命中
	// 都派发 DATA_CHANGED {index:1,data}）；递减后继续扫（同 id 无重复则落到
	// 末行 return false）；无命中零派发回 false
	public function test_removeSeed_decrement_and_removal() {
		var a = new WarehouseSeed({cId: 1, amount: 5});
		var b = new WarehouseSeed({cId: 2, amount: 3});
		model.m_seeds = [a, b];
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		Assert.isFalse(model.removeSeed(1, 2)); // 5-2=3 > 0 → 派发但非 true
		Assert.equals(3, a._amount);
		Assert.equals(1, countType(log, WarehouseModel.EVENT_DATA_CHANGED));
		Assert.isTrue(Reflect.field(lastData(log, WarehouseModel.EVENT_DATA_CHANGED), "data") == model.m_seeds);

		Assert.isTrue(model.removeSeed(2, 3)); // 3-3=0 → splice + true
		Assert.equals(1, model.m_seeds.length);
		Assert.isTrue(model.m_seeds[0] == a);
		Assert.equals(2, countType(log, WarehouseModel.EVENT_DATA_CHANGED));

		Assert.isFalse(model.removeSeed(999, 1)); // 无命中
		Assert.equals(2, countType(log, WarehouseModel.EVENT_DATA_CHANGED));
	}

	// :631-652 removeMyFlower：null/缺 fId 守卫早退；未命中也派发（:648 在
	// 循环外无守卫，列表原样）；命中 splice 后派发
	public function test_removeMyFlower_guard_and_splice() {
		var f1:Dynamic = {fId: 1};
		var f2:Dynamic = {fId: 2};
		model.m_myFlower = [f1, f2];
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.removeMyFlower(null); // :634-637 守卫
		model.removeMyFlower({});
		Assert.equals(0, log.length);

		model.removeMyFlower({fId: 99}); // 未命中：:648 派发照发
		Assert.equals(1, countType(log, WarehouseModel.EVENT_DATA_CHANGED));
		Assert.equals(2, model.m_myFlower.length);
		Assert.isTrue(Reflect.field(lastData(log, WarehouseModel.EVENT_DATA_CHANGED), "data") == model.m_myFlower);

		model.removeMyFlower({fId: 2}); // 命中删除
		Assert.equals(1, model.m_myFlower.length);
		Assert.isTrue(model.m_myFlower[0] == f1);
		Assert.equals(2, countType(log, WarehouseModel.EVENT_DATA_CHANGED));
	}

	// :105-167 onLockSuccess：code=="1" 松等门（cgi_farm_set_lock.php:32 的
	// code 是 int 1）；crop 条目按 cId 在 crops→flowers→cards 三仓顺序回写
	// isLock（回显 type 1|2，==1 ? 1 : 0 → 2 落 0），每命中派发
	// UpdateLockSuccess（载荷=命中实体）；全不命中不派发；code!=1 不派发
	public function test_onLockSuccess_three_slot_writeback() {
		var carrot = new WarehouseCrop({cId: 3});
		var rose = new WarehouseCrop({cId: 41});
		var card = new WarehouseCrop({cId: 2001});
		model.m_crops = [carrot];
		model.m_flowers = [rose];
		model.m_cards = [card];
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onLockSuccess(voEvent(CommandDefs.CMD_UPDATE_LOCK, {crop: "3:1"},
			{code: 1, crop: [{cId: 3, isLock: 1}]}));
		Assert.equals(1, carrot._isLock);
		Assert.equals(1, countType(log, WarehouseModel.EVENT_UPDATELOCK_SUCCESS));
		Assert.isTrue(lastData(log, WarehouseModel.EVENT_UPDATELOCK_SUCCESS) == carrot);

		// flowers 仓命中（crops 仓无此 id）；isLock 回显 2 → 落 0
		model.onLockSuccess(voEvent(CommandDefs.CMD_UPDATE_LOCK, {crop: "41:2"},
			{code: 1, crop: [{cId: 41, isLock: 2}]}));
		Assert.equals(0, rose._isLock);
		Assert.equals(2, countType(log, WarehouseModel.EVENT_UPDATELOCK_SUCCESS));
		Assert.isTrue(lastData(log, WarehouseModel.EVENT_UPDATELOCK_SUCCESS) == rose);

		// cards 仓命中 + 一应答双条目各派发一次
		model.onLockSuccess(voEvent(CommandDefs.CMD_UPDATE_LOCK, null,
			{code: 1, crop: [{cId: 2001, isLock: 1}, {cId: 3, isLock: 1}]}));
		Assert.equals(1, card._isLock);
		Assert.equals(4, countType(log, WarehouseModel.EVENT_UPDATELOCK_SUCCESS));

		// 全不命中：零派发（三仓都空也走 AS3 for-each no-op，不崩）
		model.onLockSuccess(voEvent(CommandDefs.CMD_UPDATE_LOCK, null,
			{code: 1, crop: [{cId: 999, isLock: 1}]}));
		Assert.equals(4, countType(log, WarehouseModel.EVENT_UPDATELOCK_SUCCESS));
		var empty = freshModel();
		var log2:Array<Dynamic> = [];
		listenModel(empty, log2);
		empty.onLockSuccess(voEvent(CommandDefs.CMD_UPDATE_LOCK, null,
			{code: 1, crop: [{cId: 3, isLock: 1}]}));
		Assert.equals(0, log2.length);

		// code!=1（int 0 松等 "1" 不中）：零派发
		model.onLockSuccess(voEvent(CommandDefs.CMD_UPDATE_LOCK, null,
			{code: 0, crop: [{cId: 3, isLock: 1}]}));
		Assert.equals(4, countType(log, WarehouseModel.EVENT_UPDATELOCK_SUCCESS));
	}

	// :169-196 onFishLockSuccess：code=="1" 门、按 fid 命中回写 lock
	// （1|0）、派发在循环外——未命中也派发，载荷是 for-each 残留的尾元素
	// （空表才 null，:184 初值）
	public function test_onFishLockSuccess_hit_and_miss_payload() {
		var clown = new WarehouseFish({fid: 2, lock: "0"});
		model.m_fishs = [clown];
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onFishLockSuccess(voEvent(CommandDefs.CMD_UPDATE_FISH_LOCK, {fId: 2, flag: "lock"},
			{code: 1, fid: 2, lock: 1})); // cgi_fish_rep_lock.php:35 行形状
		Assert.equals(1, clown._isLock);
		Assert.equals(1, countType(log, WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS));
		Assert.isTrue(lastData(log, WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS) == clown);

		model.onFishLockSuccess(voEvent(CommandDefs.CMD_UPDATE_FISH_LOCK, {fId: 2, flag: "unlock"},
			{code: 1, fid: 2, lock: 0}));
		Assert.equals(0, clown._isLock);

		// 未命中也派发（:193 无守卫）：载荷是 for-each 落定的循环变量——
		// m_fishs 非空未命中 → 尾元素（AS3 for-each 残留，原版字面）；
		// 空表 → 初值 null（:184）
		model.onFishLockSuccess(voEvent(CommandDefs.CMD_UPDATE_FISH_LOCK, null,
			{code: 1, fid: 999, lock: 1}));
		Assert.equals(3, countType(log, WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS));
		Assert.isTrue(lastData(log, WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS) == clown);

		// m_fishs 空（ctor 零位）：派发载荷 null
		var fresh = freshModel();
		var log2:Array<Dynamic> = [];
		listenModel(fresh, log2);
		fresh.onFishLockSuccess(voEvent(CommandDefs.CMD_UPDATE_FISH_LOCK, null, {code: 1, fid: 2, lock: 1}));
		Assert.equals(1, countType(log2, WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS));
		Assert.isNull(lastData(log2, WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS));

		// code!=1：零派发
		model.onFishLockSuccess(voEvent(CommandDefs.CMD_UPDATE_FISH_LOCK, null,
			{code: 0, fid: 2, lock: 1}));
		Assert.equals(3, countType(log, WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS));
	}

	// :240-251 onSellPlantSuccess：num 从请求 body __body.number 回填进载荷
	// （repertory_sale.php:7 的 number 参数回看）、SELLPLANT_SUCCESS 派发后
	// 追加 EvtAPI.REFRESH_CRYSTAL（"refreshCrystal"，EvtAPI.hx:18）；
	// VO null 零事件
	public function test_onSellPlantSuccess_num_backfill_and_crystal_refresh() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var payload:Dynamic = {cId: 3, code: 1, money: 63, direction: "成功卖出3个胡萝卜"}; // repertory_sale.php:16 形状

		model.onSellPlantSuccess(voEvent(CommandDefs.CMD_SELL_PLANT,
			{cId: 3, number: 3, hw: 1, onlineTime: 0}, payload)); // :567-573 请求侧形状
		Assert.equals(3, Reflect.field(payload, "num")); // :247
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLPLANT_SUCCESS));
		Assert.isTrue(lastData(log, WarehouseModel.EVENT_SELLPLANT_SUCCESS) == payload);
		Assert.equals(1, countType(log, EvtAPI.REFRESH_CRYSTAL));

		model.onSellPlantSuccess(voEvent(CommandDefs.CMD_SELL_PLANT, null, null));
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLPLANT_SUCCESS));
		Assert.equals(1, countType(log, EvtAPI.REFRESH_CRYSTAL));
	}

	// :670-696 onSellAllSuccess 三分支（else-if 链）：errorType 有键且在
	// {IOError,httpStatus,timeOut,PHPError} → NET_TRANSACTION_ERROR 请求
	// 超时文案；errorType 有键但不在表内 → 后两分支全不可达（零派发，原版
	// 字面）；errorType 无键 + code==1 → SELLALL_SUCCESS；errorType 无键 +
	// code!=1 + direction 非空 → NET_TRANSACTION_ERROR(direction)；direction
	// 空串 → 零派发
	public function test_onSellAllSuccess_branch_table() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var retry = "请求超时，稍后再试"; // Language.L cn 表恒等映射（Language.hx:44）

		for (et in ["IOError", "httpStatus", "timeOut", "PHPError"]) { // :681
			model.onSellAllSuccess(voEvent(CommandDefs.CMD_SELL_ALL_PLANTS, null, {errorType: et}));
			Assert.equals(retry, Reflect.field(lastData(log, WarehouseModel.EVENT_NET_TRANSACTION_ERROR), "error"));
		}
		Assert.equals(4, countType(log, WarehouseModel.EVENT_NET_TRANSACTION_ERROR));
		Assert.equals(0, countType(log, WarehouseModel.EVENT_SELLALL_SUCCESS));

		// errorType 有键不在表内：链被首分支吃掉 → 零派发（:678-686 无 fallthrough）
		var before = log.length;
		model.onSellAllSuccess(voEvent(CommandDefs.CMD_SELL_ALL_PLANTS, null,
			{errorType: "securityError", code: 1}));
		Assert.equals(before, log.length);

		// code==1（repertory_saleall.php:30 恒 1）
		var ok:Dynamic = {code: 1, money: 750, direction: ""};
		model.onSellAllSuccess(voEvent(CommandDefs.CMD_SELL_ALL_PLANTS, null, ok));
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLALL_SUCCESS));
		Assert.isTrue(lastData(log, WarehouseModel.EVENT_SELLALL_SUCCESS) == ok);

		// direction 非空报错文案
		model.onSellAllSuccess(voEvent(CommandDefs.CMD_SELL_ALL_PLANTS, null,
			{code: 0, direction: "请确认数值！"})); // repertory_sale.php:39 失败文案示例
		Assert.equals(5, countType(log, WarehouseModel.EVENT_NET_TRANSACTION_ERROR));
		Assert.equals("请确认数值！", Reflect.field(lastData(log, WarehouseModel.EVENT_NET_TRANSACTION_ERROR), "error"));

		// direction 空串：零派发
		var before2 = log.length;
		model.onSellAllSuccess(voEvent(CommandDefs.CMD_SELL_ALL_PLANTS, null, {code: 0, direction: ""}));
		Assert.equals(before2, log.length);

		// VO null：零事件（:673-676）
		model.onSellAllSuccess(voEvent(CommandDefs.CMD_SELL_ALL_PLANTS, null, null));
		Assert.equals(before2, log.length);
	}

	// :534-549 onSellAllSeedsSuccess：code==1 时 direction 由
	// Language.replaceText("saleAllFnText2", {money}) 生成写回载荷
	// （Language.hx:53 模板）并派发；code!=1 / VO null 零派发
	public function test_onSellAllSeedsSuccess_direction_template() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var payload:Dynamic = {code: 1, money: 750}; // cgi_farm_seed_sell.php:34 形状

		model.onSellAllSeedsSuccess(voEvent(CommandDefs.CMD_SELL_ALL_SEEDS, null, payload));
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLALLSEEDS_SUCCESS));
		Assert.isTrue(lastData(log, WarehouseModel.EVENT_SELLALLSEEDS_SUCCESS) == payload);
		Assert.equals("成功卖出所有种子，得到金币 <font color=\"#FF6600\">&nbsp;<b>750</b>&nbsp;</font>。",
			Reflect.field(payload, "direction")); // :544 + Language.hx:53

		model.onSellAllSeedsSuccess(voEvent(CommandDefs.CMD_SELL_ALL_SEEDS, null, {code: 0}));
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLALLSEEDS_SUCCESS));
		model.onSellAllSeedsSuccess(voEvent(CommandDefs.CMD_SELL_ALL_SEEDS, null, null));
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLALLSEEDS_SUCCESS));
	}

	// :594-606 onSellSeedSuccess / :1108-1120 onSellFishSuccess / :789-801
	// onSellAllFishSuccess：code==1 门 → 各自成功事件（载荷原引用）；
	// code!=1 / VO null 零派发（cgi_farm_seed_sell.php:23 与
	// cgi_fish_sale.php:23,36 的 code 恒 1）
	public function test_sell_success_code_gates() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		var seedPayload:Dynamic = {code: 1, cId: 3, money: 63};
		model.onSellSeedSuccess(voEvent(CommandDefs.CMD_SELL_SEED, null, seedPayload));
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLSEED_SUCCESS));
		Assert.isTrue(lastData(log, WarehouseModel.EVENT_SELLSEED_SUCCESS) == seedPayload);

		var fishPayload:Dynamic = {code: 1, cId: 2, money: 450};
		model.onSellFishSuccess(voEvent(CommandDefs.CMD_SELL_WAREHOUSE_FISH, null, fishPayload));
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLFISH_SUCCESS));
		Assert.isTrue(lastData(log, WarehouseModel.EVENT_SELLFISH_SUCCESS) == fishPayload);

		var allFishPayload:Dynamic = {code: 1, money: 1200};
		model.onSellAllFishSuccess(voEvent(CommandDefs.CMD_SELL_WAREHOUSE_FISH, null, allFishPayload));
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLALLFISHS_SUCCESS));
		Assert.isTrue(lastData(log, WarehouseModel.EVENT_SELLALLFISHS_SUCCESS) == allFishPayload);

		for (cmd in [CommandDefs.CMD_SELL_SEED, CommandDefs.CMD_SELL_WAREHOUSE_FISH]) {
			model.onSellSeedSuccess(voEvent(cmd, null, {code: 0}));
			model.onSellFishSuccess(voEvent(cmd, null, {code: 0}));
			model.onSellAllFishSuccess(voEvent(cmd, null, {code: 0}));
			model.onSellSeedSuccess(voEvent(cmd, null, null));
			model.onSellFishSuccess(voEvent(cmd, null, null));
			model.onSellAllFishSuccess(voEvent(cmd, null, null));
		}
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLSEED_SUCCESS));
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLFISH_SUCCESS));
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SELLALLFISHS_SUCCESS));
	}

	// :710-762 onFlowerSentSuccess：code==1 门；按 m_sendFlowerID 在
	// m_allFlower 找定义（:726-733），need 逐项从 flowers 仓扣料
	// （parseInt(amount)，<=0 移除，:737-754）、派发 SellFlowerSuccess
	// {msg: direction, data: flowers}；定义不存在 → 不派发
	public function test_onFlowerSentSuccess_decrement_and_removal() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		// allflower.php:24（fId12 完美恋人 need 3×cId41）
		model.m_allFlower = [{fId: 12, fName: "完美恋人", need: [{cId: 41, amount: 3}]}];

		var rose = new WarehouseCrop({cId: 41, amount: 5});
		model.m_flowers = [rose];
		model.m_sendFlowerID = 12;

		model.onFlowerSentSuccess(voEvent(CommandDefs.CMD_SEND_FLOWER,
			{to: 10001, fId: 12, w: "加油"}, {code: 1, direction: "送花成功"})); // cgi_farm_flower_send.php:31 形状
		Assert.equals(2, rose._amount); // 5-3
		Assert.equals(1, countType(log, WarehouseModel.EVENT_SENDFLOWER_SUCCESS));
		var d = lastData(log, WarehouseModel.EVENT_SENDFLOWER_SUCCESS);
		Assert.equals("送花成功", Reflect.field(d, "msg"));
		Assert.isTrue(Reflect.field(d, "data") == model.m_flowers);

		// 恰好扣空：3-3=0 → 从 flowers 仓移除
		var rose2 = new WarehouseCrop({cId: 41, amount: 3});
		model.m_flowers = [rose2];
		model.onFlowerSentSuccess(voEvent(CommandDefs.CMD_SEND_FLOWER, null, {code: 1, direction: ""}));
		Assert.equals(0, model.m_flowers.length);
		Assert.equals(2, countType(log, WarehouseModel.EVENT_SENDFLOWER_SUCCESS));

		// fId 不在 m_allFlower：不派发
		model.m_sendFlowerID = 999;
		model.onFlowerSentSuccess(voEvent(CommandDefs.CMD_SEND_FLOWER, null, {code: 1, direction: ""}));
		Assert.equals(2, countType(log, WarehouseModel.EVENT_SENDFLOWER_SUCCESS));

		// code!=1 / VO null：不派发
		model.m_sendFlowerID = 12;
		model.onFlowerSentSuccess(voEvent(CommandDefs.CMD_SEND_FLOWER, null, {code: 0}));
		model.onFlowerSentSuccess(voEvent(CommandDefs.CMD_SEND_FLOWER, null, null));
		Assert.equals(2, countType(log, WarehouseModel.EVENT_SENDFLOWER_SUCCESS));
	}

	// :203-220 sendFlower 的可观测面只有 m_sendFlowerID（请求侧 no-op）：
	// to 空串 / 花定义 null / 缺 fId 三守卫早退不写，过守卫写 parseInt(fId)
	public function test_sendFlower_guards_set_pending_id() {
		model.sendFlower("", "加油", {fId: "12"}); // :205-207
		Assert.equals(-1, model.m_sendFlowerID);
		model.sendFlower("10001", "加油", null); // :209-212
		Assert.equals(-1, model.m_sendFlowerID);
		model.sendFlower("10001", "加油", {});
		Assert.equals(-1, model.m_sendFlowerID);
		model.sendFlower("10001", "加油", {fId: "12"}); // :218
		Assert.equals(12, model.m_sendFlowerID);
	}

	// :470-508 onTransactionFailed：VO null 或 message 空串 → 请求超时文案；
	// 有 message → 原文派发；cmdID 各分支只走 recordResp（DISABLED 无观测）
	public function test_onTransactionFailed_error_text() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var retry = "请求超时，稍后再试";

		// result null（VO 装不进 → :472-474 null 分支）
		var bare = new CommandEvent(CommandEvent.COMPLETE);
		bare.body = Utils.buildRequest(CommandDefs.CMD_SELL_ALL_PLANTS, null);
		model.onTransactionFailed(bare);
		Assert.equals(1, countType(log, WarehouseModel.EVENT_NET_TRANSACTION_ERROR));
		Assert.equals(retry, Reflect.field(lastData(log, WarehouseModel.EVENT_NET_TRANSACTION_ERROR), "error"));

		// message 空串同文案；非空走原文（:479）
		model.onTransactionFailed(voEvent(CommandDefs.CMD_SELL_PLANT, null, null));
		Assert.equals(retry, Reflect.field(lastData(log, WarehouseModel.EVENT_NET_TRANSACTION_ERROR), "error"));
		var vo = new ServiceResultVO();
		vo.m_extra = {};
		vo.m_message = "请确认数值！";
		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.body = Utils.buildRequest(CommandDefs.CMD_SELL_PLANT, {cId: 3, number: 3});
		ev.result = vo;
		model.onTransactionFailed(ev);
		Assert.equals("请确认数值！", Reflect.field(lastData(log, WarehouseModel.EVENT_NET_TRANSACTION_ERROR), "error"));
		Assert.equals(3, countType(log, WarehouseModel.EVENT_NET_TRANSACTION_ERROR));
	}

	// :281-331 onLoadDataError：:318 的 `if(_loc3_ != 0 || _loc3_ != 1)
	// return` 恒真（一值不可能同时为 0 和 1）→ EVENT_DATA_FAILED 永不派发
	// （:322-330 重试文案是死分支）；:313 的 body 键 "cmdId"（小写 d）也与
	// buildRequest 的 "cmdID" 不符；VO null 零事件（:284-290）
	public function test_onLoadDataError_never_dispatches_failed() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onLoadDataError(voEvent(CommandDefs.CMD_GET_WAREHOUSE_CROPS, null, {errorType: "timeOut"}));
		model.onLoadDataError(voEvent(CommandDefs.CMD_GET_WAREHOUSE_SEEDS, null, {errorType: "IOError"}));
		model.onLoadDataError(voEvent(CommandDefs.CMD_GET_WAREHOUSE_CRYSTAL, {type: 9}, {errorType: "httpStatus"}));
		model.onLoadDataError(voEvent(CommandDefs.CMD_GET_WAREHOUSE_MYFLOWERS, null, {errorType: "PHPError"}));
		Assert.equals(0, countType(log, WarehouseModel.EVENT_DATA_FAILED)); // :318 恒真门
		Assert.equals(0, log.length); // 其余零派发

		// result 无 VO：:288-292 return，零事件
		var bare = new CommandEvent(CommandEvent.COMPLETE);
		bare.body = Utils.buildRequest(CommandDefs.CMD_GET_WAREHOUSE_CROPS, null);
		model.onLoadDataError(bare);
		Assert.equals(0, log.length);
	}

	// :515-522 sort 比较器直调：lvl 平级走 _id（>= → 1）、非平级 lvl >= → 1、
	// 永不回 0（原版字面；AS3 sort 对无 0 返回的表不做稳定保证，只钉返回值）
	public function test_sort_comparator() {
		var a = new WarehouseCrop({cId: 2, level: 5});
		var b = new WarehouseCrop({cId: 1, level: 5});
		Assert.equals(1, model.sort(a, b)); // lvl 平 → id 2>=1
		Assert.equals(-1, model.sort(b, a)); // id 1<2
		Assert.equals(1, model.sort(a, a)); // 全平 → >= 成立
		var c = new WarehouseCrop({cId: 9, level: 6});
		Assert.equals(1, model.sort(c, a)); // lvl 6>=5
		Assert.equals(-1, model.sort(a, c)); // lvl 5<6
	}

	// :581-592 getFlowerCount：flowers 仓按 _id 查 _amount，未命中 0
	public function test_getFlowerCount() {
		model.m_flowers = [new WarehouseCrop({cId: 41, amount: 5})];
		Assert.equals(5, model.getFlowerCount(41));
		Assert.equals(0, model.getFlowerCount(42));
	}

	// :235-238/:333-336/:654-657/:985-988/:1054-1057/:1122-1125 各 getter 是
	// 私有列表的裸透传（不拷贝）；:556-559 flowers setter 直写
	public function test_getters_expose_slot_arrays() {
		var crops:Array<Dynamic> = [crop(1, 0)];
		var flowers:Array<Dynamic> = [crop(41, 0)];
		var fishs:Array<Dynamic> = [fish(2, 0)];
		var seeds:Array<Dynamic> = [new WarehouseSeed({cId: 1})];
		var cards:Array<Dynamic> = [crop(2001, 0)];
		var myFlowers:Array<Dynamic> = [{fId: 1}];
		var allFlower:Array<Dynamic> = [{fId: 12}];
		model.m_crops = crops;
		model.flowers = flowers; // :556-559 setter
		model.m_fishs = fishs;
		model.m_seeds = seeds;
		model.m_cards = cards;
		model.m_myFlower = myFlowers;
		model.m_allFlower = allFlower;
		Assert.isTrue(model.crops == crops);
		Assert.isTrue(model.flowers == flowers);
		Assert.isTrue(model.fishs == fishs);
		Assert.isTrue(model.seeds == seeds);
		Assert.isTrue(model.cards == cards);
		Assert.isTrue(model.myFlowers == myFlowers);
		Assert.isTrue(model.allFlower == allFlower);
	}

	static function crop(cId:Int, isLock:Int):WarehouseCrop {
		return new WarehouseCrop({cId: cId, isLock: isLock, type: 1});
	}

	static function fish(fid:Int, isLock:Int):WarehouseFish {
		return new WarehouseFish({fid: fid, lock: Std.string(isLock), type: 23, num: 1});
	}

	static function listenModel(m:WarehouseModel, log:Array<Dynamic>):Void {
		var names:Array<String> = [
			WarehouseModel.EVENT_DATA_CHANGED, WarehouseModel.EVENT_DATA_LOADING,
			WarehouseModel.EVENT_DATA_FAILED, WarehouseModel.EVENT_NET_TRANSACTION_ERROR,
			WarehouseModel.EVENT_SELLALL_SUCCESS, WarehouseModel.EVENT_SELLPLANT_SUCCESS,
			WarehouseModel.EVENT_SELLALLFISHS_SUCCESS, WarehouseModel.EVENT_SELLFISH_SUCCESS,
			WarehouseModel.EVENT_SELLSEED_SUCCESS, WarehouseModel.EVENT_SELLALLSEEDS_SUCCESS,
			WarehouseModel.EVENT_SENDFLOWER_SUCCESS, WarehouseModel.EVENT_UPDATELOCK_SUCCESS,
			WarehouseModel.EVENT_UPDATEFISHLOCK_SUCCESS, EvtAPI.REFRESH_CRYSTAL
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

	static function countType(log:Array<Dynamic>, type:String):Int {
		var n = 0;
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				n++;
			}
		}
		return n;
	}

	static function lastData(log:Array<Dynamic>, type:String):Dynamic {
		var out = null;
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				out = Reflect.field(entry, "data");
			}
		}
		return out;
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

// Settings.getCropByID/getFishByID 的配置表注入（getData 按表名直取；
// ShopModelTest 同款，IModel 含 INotifier 三方法）
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
