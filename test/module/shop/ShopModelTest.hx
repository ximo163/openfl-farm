package module.shop;

import com.qzone.qfa.events.CommandEvent;
import common.Session;
import common.Settings;
import common.misc.Utils;
import entities.DIYDecor;
import entities.DecorateItem;
import entities.Item;
import entities.Seed;
import entities.ShopFish;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.vo.ServiceResultVO;
import openfl.events.Event;
import utest.Assert;

/**
 * ShopModel 纯逻辑（issue #35）：商店六页签数据层——装载门位与
 * LOADING/LOADED/FAILED 派发（index 表 0 种子/1 鱼苗/2 道具/3 装饰/4 广告位/
 * 5 合作专区）、买入交易位（beginTransaction/endTransaction 与各买入守卫）、
 * 应答回调（种子/鱼苗的 Settings 配置合并与排序、装饰倒序+四元块换位、
 * 广告双网关三分支、合作专区种子 targetid 过滤、onTransactionError 派发表）。
 * ShopController/ShopView/各买入窗口是接线与显示层，归 CI web-smoke。
 *
 * 环境口径（同 #19/#20/#21 模块先例）：
 * - NetHelper.sendRequest/getRequest 在 theApp == null 时 no-op（#7 已译），
 *   测试进程不跑 Main、theApp 恒 null——请求侧参数拼装（buySeeds 的
 *   {cId,number}、buyFishs 的 {fid,num}、广告双网关的 posid 参数串）不可
 *   观测，不设测试；应答侧直接喂构造好的 CommandEvent（body 用
 *   Utils.buildRequest 造出与真实链路同构的 {cmdID,__body,…}，result 装
 *   ServiceResultVO，走 NetHelper.getVOData 的 m_extra 分支）。
 * - EventRecorder 按 deviations（no-qq-telemetry）DISABLED，recordResp 及
 *   recordSueecssEvent/recordErrorEvent 调用点无观测，只保不抛。
 * - QzoneJSAPI 出口在 eval 上安全：QQOutlets.available 恒 false（qqoutlets
 *   shim）→ reportError 只拼串、getInGamePay/addGToken 直接返回
 *   （QzoneJSAPI.hx:176/:195/:224）；flash.net.sendToURL 无 openfl 等价
 *   顶层函数，实现按 shim.QQOutlets.sendToURL 不发送（QQOutlets.hx:37）；
 *   postUrl 的 URLLoader.load("") 在 eval 上静默返回（探针实测）——
 *   onGetAdvertisementSeedsInfo 成功分支与 onBuySeedSuccess 的 isAdSeed
 *   分支可全程驱动。
 * - onSetCookie（CMD_SET_ADSEED_COOKIE 应答）的观测面只剩
 *   ExternalInterface.call("eval",…)（html5-only，src/shim 目标编译）与一条
 *   发出的买入请求（no-op），不可观测，不设测试；同理 onInGamePreCheckSuccess
 *   的 VO-null 是 AS3 原生 TypeError 路径，不钉。
 * - Settings 注入：loadLocalSettings(null) 复位 m_params（crops_sort 缺省
 *   ""→不排序、mode ""）；配置行走 setConfigDataModel(FakeConfigModel)，
 *   getCropByID/getFishByID 的 `row["id"]==param1` 松等由 As3.eqString 实现
 *   （Settings.hx:372/:112），数字形状的 id 键可直配。
 * - 本部署快照 crops_sort 恒未配（部署 XML/flashvar 全无此键，全文只在
 *   ShopModel/WarehouseModel/MyBagModel 读）→ 「无 crops_sort」用例钉的
 *   是部署现实，「有 crops_sort」用例钉的是 :510-513/:568-571 指令语义
 *   本身。
 * - 排序方向（勿按直觉改）：fishSort :165/:168 与 seedSort :480/:483 的
 *   `param1.x > param2.x ? 1 : -1` 在 AS3 Array.sort 约定下「正数 → param1
 *   排后」→ 升序（产出最小在前、平级 id 最小在前）。字面如此。
 * - onGetDecorsInfo :980-989 的 while 对非 4 倍数长度的表末块越界：读
 *   _loc4_+3 得 undefined、写 _loc4_+3 把 length 垫到下一个 4 的倍数，
 *   垫完 _loc4_ 恰好追平 → 循环照常退出（原版缺陷是尾部留 undefined 槽，
 *   不是死循环；无需单测复现）；装饰 fixture 一律取 4 的倍数。
 * - Consts.ITEM_TYPE_DIY 尚未入 src（实现阶段补），字面 "808080" 按
 *   Consts.as:478 引用；ITEM_TYPE_SEED "1"/ITEM_TYPE_FISH "23" 已译
 *   （Consts.hx:247/:255）。
 *
 * 出处：
 * - legacy/decompiled/shop_v_7/scripts/module/shop/ShopModel.as
 *   （常量 :27-55、ctor :83-92、loadDecorsInfo :94-105、endTransaction
 *   :107-111、loadAdvertisementInfo :113-122、onUnlockFishSuccess :124-136、
 *   onDecorsItemLoadedInfo :138-152、fishSort :159-171、onLoadDataError
 *   :173-224、onGetAdvertisementInfo :231-279、onBuyToolSuccess :286-303、
 *   resetLoadingFlags :305-311、loadSeedsInfo :313-325、onBuySeedSuccess
 *   :327-348、loadFishInfo :350-365、buyDiy :367-375、
 *   onGetAdvertisementSeedsList :387-455、buyFishs :457-472、seedSort
 *   :474-486、onGetSeedsInfo :488-577、buySeeds :579-605、onGetFishInfo
 *   :607-657、buyTool :659-671、isEmpty :693-712、loadItemsInfo :738-749、
 *   unlockFish :751-759、clear :761-795、onInGamePreCheckSuccess :797-831、
 *   buyWeapon :833-841、onBuyDIYSuccess :843-861、onGetItemsInfo :863-888、
 *   onTransactionError :890-929、buyInGame :931-945、loadAdvertisementSeedsList
 *   :947-955、onGetDecorsInfo :957-995、onGetAdvertisementSeedsInfo
 *   :997-1080、onBuyFishSuccess :1082-1094、loadAdvertisementSeedsInfo
 *   :1096-1101、beginTransaction :1112-1121、buyToolVIP :1128-1139）
 * - legacy/deploy/QFarmFlash/source/core/source/xml/mod/nc_data.php：crops
 *   配置行（:6020 草莓 id1、:6021 白萝卜 id2、:6022 胡萝卜 id3
 *   isFood:"1" 字符串形、:6045 菠萝 id27 isRestaurant:1 数值形、:6119 薰衣草
 *   id101 isMill:"0" 字符串形、:6144 曼珠沙华 id126 isRed:"1" 字符串形、
 *   :6182 红色景观树 id169 isVIP:1+vipDesc"神奇的红色景观树"、:6279 星星
 *   圣诞树 id311 isActivity:1 数值形、:6416 园艺熊猫 id460 isRed:2 数值形、
 *   :6699 有机白萝卜 id933 isRestaurant:2+isYouji:1 数值形）；fish_info 行
 *   全在 :7565（小丑鱼 id2、蝶鱼 id4、蝠鲼 id13、海豚 id14，字段值逐字）
 * - legacy/deploy/QFarmFlash/source/core/config/nc/cropstype.php:4-6
 *   （cId1 草莓 cLevel10、cId2 白萝卜 cLevel0、cId3 胡萝卜 cLevel0）
 * - legacy/deploy/QFarmFlash/source/core/source/nc/mod/view_fcg.php:6-10
 *   （count==6 → '{}'；count==15 → ret0 + data["144396668170523855"].ret==1，
 *   广告双网关的部署桩字面量）
 * - legacy/decompiled/main3_v_221/scripts/entities/ShopFish.as:28
 *   （_lock_gold:int——"10000" 字符串赋值经 AS3 int 强转 10000）
 * - spec/protocol.json entries.nc.mods：usertool_getseedinfo/gettools、
 *   item_getuseritems/shop、cgi_fish_list/buy/unlock、cgi_farm_buyweapon/
 *   buyitem/shop_pay、repertory_buyseed、view_fcg
 * - Consts.as:478（ITEM_TYPE_DIY "808080"）；AS3 internal static const →
 *   Haxe private，ShopController 同包消费方按 FriendsController 先例用
 *   @:access 取（本测试同）
 */
@:access(module.shop.ShopModel)
class ShopModelTest {
	public function new() {}

	var model:ShopModel;

	var savedWaterPoolOpen:Bool;

	public function setup() {
		model = freshModel();
		var s = Session.getInstance();
		savedWaterPoolOpen = s.m_waterPoolOpen;
		s.m_waterPoolOpen = false; // loadFishInfo :352 的门位，各用例自开
		Settings.getInstance().loadLocalSettings(null); // crops_sort/mode 复位缺省
		Settings.getInstance().setConfigDataModel(null);
	}

	public function teardown() {
		Session.getInstance().m_waterPoolOpen = savedWaterPoolOpen;
		Settings.getInstance().loadLocalSettings(null);
		Settings.getInstance().setConfigDataModel(null);
	}

	// stub 的 ctor 无零位（那是实现内容 :86-92），各用例统一从这里起手
	static function freshModel():ShopModel {
		var m = new ShopModel(null);
		m.m_preBuyToolType = -1; // AS3 ctor :90
		m.m_requestPending = false; // :91
		return m;
	}

	// :27-55 事件名常量 + :83-92 ctor 零位（四列表 null、m_preBuyToolType=-1、
	// m_requestPending=false）
	public function test_event_constants_and_ctor_defaults() {
		Assert.equals("ShopDataLoaded", ShopModel.EVENT_SHOP_DATA_LOADED); // :27
		Assert.equals("ShopDataLoading", ShopModel.EVENT_SHOP_DATA_LOADING); // :29
		Assert.equals("ShopDataFailed", ShopModel.EVENT_SHOP_DATA_FAILED); // :31
		Assert.equals("BuySeedSuccess", ShopModel.EVENT_BUY_SEED_SUCCESS); // :33
		Assert.equals("BuySeedFail", ShopModel.EVENT_BUY_SEED_FAIL); // :35
		Assert.equals("BuyFishSuccess", ShopModel.EVENT_BUY_FISH_SUCCESS); // :37
		Assert.equals("BuyFishFail", ShopModel.EVENT_BUY_FISH_FAIL); // :39
		Assert.equals("BuyToolSuccess", ShopModel.EVENT_BUY_TOOL_SUCCESS); // :41
		Assert.equals("BuyToolFail", ShopModel.EVENT_BUY_TOOL_FAIL); // :43
		Assert.equals("BuyDiySuccess", ShopModel.EVENT_BUY_DIY_SUCCESS); // :45
		Assert.equals("BuyDiyFail", ShopModel.EVENT_BUY_DIY_FAIL); // :47
		Assert.equals("ShopDiyOwnDataLoaded", ShopModel.EVENT_SHOP_DIY_OWN_LOADED); // :49
		Assert.equals("NormalErrorAlert", ShopModel.EVENT_NORMAL_ERROR); // :51
		Assert.equals("UnlockFishSuccess", ShopModel.EVENT_UNLOCK_FISH_SUCCESS); // :53
		Assert.equals("UnlockFishFail", ShopModel.EVENT_UNLOCK_FISH_FAIL); // :55
		var raw = new ShopModel(null);
		Assert.isNull(raw.m_seeds); // :86
		Assert.isNull(raw.m_items); // :87
		Assert.isNull(raw.m_decors); // :88
		Assert.isNull(raw.m_adSeeds); // :89
		Assert.equals(-1, raw.m_preBuyToolType); // :90
		Assert.isFalse(raw.m_requestPending); // :91 AS3 Boolean 默认 false
	}

	// :693-712 isEmpty：0=种子 1=道具 2=装饰 4=鱼苗（null 或 0 长都算空）；
	// 3（广告位）与其余未列值走末行 return true
	public function test_isEmpty_slot_table() {
		for (idx in [0, 1, 2, 3, 4, 99]) {
			Assert.isTrue(model.isEmpty(idx));
		}
		// 装入道具（usertool_gettools 应答 → onGetItemsInfo）→ 仅 1 号槽翻假
		var it = new Item({tId: 13, type: 3});
		model.onGetItemsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ITEMS, null, [it]));
		Assert.isFalse(model.isEmpty(1)); // :700-701
		Assert.isTrue(model.isEmpty(0)); // 其余槽不受影响
		Assert.isTrue(model.isEmpty(2));
		Assert.isTrue(model.isEmpty(4));
		// 装入种子 → 0 号槽翻假
		var berry = new Seed({cId: 1, cLevel: 10, cName: "草莓"}); // cropstype.php:4
		model.onGetSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, [berry]));
		Assert.isFalse(model.isEmpty(0));
		Assert.isTrue(model.isEmpty(4)); // 鱼苗槽仍空
		// 装入鱼苗（Settings 无 fish_info → 不合并、fishSort 0*0 恒 0）→ 4 号槽翻假
		var fish = new ShopFish({fid: 2, lock: "1", type: 23});
		model.onGetFishInfo(voEvent(CommandDefs.CMD_GET_SHOP_FISH, null, [fish]));
		Assert.isFalse(model.isEmpty(4)); // :708-709
		// 装入装饰 → 2 号槽翻假；广告位装载与否 isEmpty(3) 恒 true（不在表内）
		model.onGetDecorsInfo(voEvent(CommandDefs.CMD_GET_SHOP_DIY, null,
			[new DIYDecor({itemId: 1}), new DIYDecor({itemId: 2}),
				new DIYDecor({itemId: 3}), new DIYDecor({itemId: 4})]));
		Assert.isFalse(model.isEmpty(2)); // :705-706
		var adRow:Dynamic = {};
		model.onGetAdvertisementInfo(voEvent(CommandDefs.CMD_GET_SNS_AD, null,
			{ret: 0, data: obj([["72339074132595919",
				{ret: 0, list: [adRow], cfg: {}}]])}));
		Assert.isTrue(model.isEmpty(3)); // :711 无 3 分支
	}

	// :761-795 clear：0/1/2/3 各清各槽（splice 后置 null）；4（鱼苗）无分支
	// 不清——与 isEmpty 的不对称是原版字面行为
	public function test_clear_clears_only_named_slot() {
		model.onGetItemsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ITEMS, null, [new Item({tId: 13})]));
		model.onGetSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null,
			[new Seed({cId: 1, cLevel: 10, cName: "草莓"})]));
		model.onGetDecorsInfo(voEvent(CommandDefs.CMD_GET_SHOP_DIY, null,
			[new DIYDecor({itemId: 1}), new DIYDecor({itemId: 2}),
				new DIYDecor({itemId: 3}), new DIYDecor({itemId: 4})]));
		model.onGetFishInfo(voEvent(CommandDefs.CMD_GET_SHOP_FISH, null,
			[new ShopFish({fid: 2, lock: "1", type: 23})]));
		var adRow:Dynamic = {};
		model.onGetAdvertisementInfo(voEvent(CommandDefs.CMD_GET_SNS_AD, null,
			{ret: 0, data: obj([["72339074132595919", {ret: 0, list: [adRow], cfg: {}}]])}));

		model.clear(1); // :771-778 只清道具
		Assert.isNull(model.m_items);
		Assert.isFalse(model.isEmpty(0)); // 种子还在
		Assert.isFalse(model.isEmpty(2)); // 装饰还在
		Assert.isFalse(model.isEmpty(4)); // 鱼苗还在

		model.clear(4); // :762-794 无 4 分支 → 鱼苗不动
		Assert.isFalse(model.isEmpty(4));
		Assert.isTrue(model.advertisements == model.m_advertisement); // 广告也还在

		model.clear(0); // :763-770
		Assert.isTrue(model.isEmpty(0));
		model.clear(2); // :779-786
		Assert.isTrue(model.isEmpty(2));
		model.clear(3); // :787-794 广告位（getter 观测）
		Assert.isNull(model.advertisements);
		Assert.isFalse(model.isEmpty(4)); // 全程不清鱼苗
	}

	// :154-156/:226-228/:281-283/:714-716/:1123-1125 五个 getter 是私有
	// 列表的裸透传（不拷贝）
	public function test_getters_expose_slot_arrays() {
		var seeds = [new Seed({cId: 1})];
		model.onGetSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, seeds));
		var items = [new Item({tId: 13})];
		model.onGetItemsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ITEMS, null, items));
		var decors = [new DIYDecor({itemId: 1}), new DIYDecor({itemId: 2}),
			new DIYDecor({itemId: 3}), new DIYDecor({itemId: 4})];
		model.onGetDecorsInfo(voEvent(CommandDefs.CMD_GET_SHOP_DIY, null, decors));
		var fishs = [new ShopFish({fid: 2})];
		model.onGetFishInfo(voEvent(CommandDefs.CMD_GET_SHOP_FISH, null, fishs));
		var adRow:Dynamic = {};
		model.onGetAdvertisementInfo(voEvent(CommandDefs.CMD_GET_SNS_AD, null,
			{ret: 0, data: obj([["72339074132595919", {ret: 0, list: [adRow], cfg: {}}]])}));
		Assert.isTrue(model.seeds == model.m_seeds);
		Assert.isTrue(model.items == model.m_items);
		Assert.isTrue(model.decors == model.m_decors);
		Assert.isTrue(model.fishs == model.m_fishs);
		Assert.isTrue(model.advertisements == model.m_advertisement);
	}

	// 六装载器的 LOADING 载荷表与缓存门位：种子 {index:0,show:true,isact:0}
	// :319-323、道具 {index:2,show:true} :744-747、装饰 {index:3,show:true}
	// :100-103、广告位 {index:4,show:true} :117-120、合作专区 {index:5,show:true}
	// :949-952、鱼苗 {index:1,show:true} :360-363（Session.m_waterPoolOpen 门
	// :352 + m_fishs 缓存门 :356、refresh 形参强穿缓存）
	public function test_loading_dispatches_and_cached_guards() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.loadSeedsInfo();
		var d = firstData(log, ShopModel.EVENT_SHOP_DATA_LOADING);
		Assert.equals(0, Reflect.field(d, "index"));
		Assert.isTrue(Reflect.field(d, "show") == true);
		Assert.equals(0, Reflect.field(d, "isact"));
		model.onGetSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, [new Seed({cId: 1})]));
		log = [];
		listenModel(model, log);
		model.loadSeedsInfo(); // :315-318 m_seeds 已装 → 早退
		Assert.equals(0, log.length);

		model.loadItemsInfo();
		d = firstData(log, ShopModel.EVENT_SHOP_DATA_LOADING);
		Assert.equals(2, Reflect.field(d, "index"));
		Assert.isTrue(Reflect.field(d, "show") == true);
		model.onGetItemsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ITEMS, null, [new Item({tId: 13})]));
		log = [];
		listenModel(model, log);
		model.loadItemsInfo(); // :740-743 m_items 已装 → 早退
		Assert.equals(0, log.length);

		model.loadDecorsInfo();
		d = firstData(log, ShopModel.EVENT_SHOP_DATA_LOADING);
		Assert.equals(3, Reflect.field(d, "index"));
		model.onGetDecorsInfo(voEvent(CommandDefs.CMD_GET_SHOP_DIY, null, [new DIYDecor({itemId: 1})]));
		log = [];
		listenModel(model, log);
		model.loadDecorsInfo(); // :96-99 m_decors 已装 → 早退
		Assert.equals(0, log.length);

		// 广告位/合作专区无缓存门：重复调用每次都发（:113-122/:947-955）
		model.loadAdvertisementInfo();
		d = firstData(log, ShopModel.EVENT_SHOP_DATA_LOADING);
		Assert.equals(4, Reflect.field(d, "index"));
		Assert.isTrue(Reflect.field(d, "show") == true);
		model.loadAdvertisementInfo();
		Assert.equals(2, countType(log, ShopModel.EVENT_SHOP_DATA_LOADING));
		model.loadAdvertisementSeedsList();
		d = lastData(log, ShopModel.EVENT_SHOP_DATA_LOADING);
		Assert.equals(5, Reflect.field(d, "index"));
		Assert.isTrue(Reflect.field(d, "show") == true);

		// 鱼苗：waterPoolOpen 关 → 开着也直接 return（:352-355 先于缓存门）
		Session.getInstance().m_waterPoolOpen = false;
		model.loadFishInfo();
		model.loadFishInfo(true);
		Assert.equals(3, countType(log, ShopModel.EVENT_SHOP_DATA_LOADING)); // 广告位×2+合作专区，门关不新增
		// 开 → LOADING {index:1,show:true}
		Session.getInstance().m_waterPoolOpen = true;
		model.loadFishInfo();
		d = lastData(log, ShopModel.EVENT_SHOP_DATA_LOADING);
		Assert.equals(1, Reflect.field(d, "index"));
		Assert.isTrue(Reflect.field(d, "show") == true);
		// 装载后默认调用走缓存门（:356-359），refresh=true 强穿（:356 的 !param1）
		model.onGetFishInfo(voEvent(CommandDefs.CMD_GET_SHOP_FISH, null, [new ShopFish({fid: 2})]));
		var before = log.length;
		model.loadFishInfo();
		Assert.equals(before, log.length);
		model.loadFishInfo(true);
		Assert.equals(before + 1, log.length);
		Assert.equals(1, Reflect.field(lastData(log, ShopModel.EVENT_SHOP_DATA_LOADING), "index"));
	}

	// 买入守卫与交易位（beginTransaction :1112-1121 / endTransaction
	// :107-111 / resetLoadingFlags :305-311）：
	// - 不经交易位的买入：buyWeapon :833-841、buyToolVIP :1128-1139（守卫
	//   param1==0||param2<=0 :1130）、unlockFish :751-759（守卫 param1<=0 :753）
	// - buySeeds :579-605：守卫 param1==0||param2<=0 :583（注意 ==0，负 id 放行），
	//   交易位 parseInt(ITEM_TYPE_SEED)=1（Consts.hx:247）
	// - buyTool :659-671：无守卫、交易位=param3 原值
	// - buyFishs :457-472：守卫 param1<=0||param2<=0 :459，交易位
	//   parseInt(ITEM_TYPE_FISH)=23（Consts.hx:255）
	// - buyDiy :367-375：交易位 parseInt(ITEM_TYPE_DIY)=808080（Consts.as:478）
	public function test_buy_guards_and_transaction_slots() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		// 先钉三个「不占交易位」的买入：fresh 模型上交易位保持 -1/false
		model.buyWeapon(1, 2, 3); // :833-841
		Assert.isFalse(model.m_requestPending);
		Assert.equals(-1, model.m_preBuyToolType);
		model.buyToolVIP(0, 5); // :1130 守卫
		model.buyToolVIP(5, 0);
		model.buyToolVIP(5, 2); // 合法参数也无 beginTransaction
		Assert.isFalse(model.m_requestPending);
		Assert.equals(-1, model.m_preBuyToolType);
		model.unlockFish(0); // :753 守卫
		model.unlockFish(-3);
		model.unlockFish(3); // 合法参数也无 beginTransaction
		Assert.isFalse(model.m_requestPending);
		Assert.equals(0, log.length);

		// buySeeds 守卫：cId==0 或数量<=0 直接返回
		model.buySeeds(0, 1); // :583
		model.buySeeds(3, 0);
		Assert.isFalse(model.m_requestPending);
		Assert.equals(-1, model.m_preBuyToolType);
		// 合法 → 交易位 1（ITEM_TYPE_SEED "1"）
		model.buySeeds(3, 2);
		Assert.isTrue(model.m_requestPending);
		Assert.equals(1, model.m_preBuyToolType);
		// 守卫是 ==0 不是 <=0：负 id 放行进交易（:583 字面）
		model.resetLoadingFlags();
		model.buySeeds(-1, 2);
		Assert.isTrue(model.m_requestPending);
		Assert.equals(1, model.m_preBuyToolType);

		// 交易中（pending）再买入被 :1114-1116 拒：交易位保持首次值
		model.buyTool(5, 1, 4);
		Assert.equals(1, model.m_preBuyToolType);
		Assert.isTrue(model.m_requestPending);

		// resetLoadingFlags 只翻 pending（:307-310），不动交易位
		model.resetLoadingFlags();
		Assert.isFalse(model.m_requestPending);
		Assert.equals(1, model.m_preBuyToolType);

		// buyTool 无参守卫、交易位=param3 原值
		model.buyTool(5, 2, 3);
		Assert.isTrue(model.m_requestPending);
		Assert.equals(3, model.m_preBuyToolType);

		// buyFishs 守卫 + 交易位 23
		model.resetLoadingFlags();
		model.buyFishs(0, 1); // :459
		model.buyFishs(7, 0);
		Assert.isFalse(model.m_requestPending);
		model.buyFishs(7, 2);
		Assert.equals(23, model.m_preBuyToolType);
		Assert.isTrue(model.m_requestPending);

		// buyDiy 交易位 808080（ITEM_TYPE_DIY "808080"，Consts.as:478）
		model.resetLoadingFlags();
		model.buyDiy(9);
		Assert.equals(808080, model.m_preBuyToolType);
		Assert.isTrue(model.m_requestPending);
		Assert.equals(0, log.length); // 买入族不派发事件
	}

	// :595-602 buySeeds 的 isAdSeed 预置分支：seedID/seedNum 记槽（onSetCookie
	// 用它们拼回购请求——请求侧 no-op 不可观测，槽位值可钉）；分支前
	// beginTransaction 已跑（:587），之后 CMD_SET_ADSEED_COOKIE 请求 no-op
	public function test_buySeeds_adseed_path_pins_ids() {
		model.buySeeds(6, 3, true);
		Assert.equals(6, model.seedID); // :597
		Assert.equals(3, model.seedNum); // :598
		Assert.isTrue(model.m_requestPending); // :587 先于分支
		Assert.equals(1, model.m_preBuyToolType);
	}

	// :931-945 buyInGame：payType 写进载荷对象；_diyExp（param4>0 照存、
	// 否则 0）/_buyType/_itemType 落侧写；不经交易位（无 beginTransaction）
	public function test_buyInGame_patches_payload_and_side_fields() {
		var o:Dynamic = {};
		model.buyInGame(o, 2, "DIY", 5, "2");
		Assert.equals(2, Reflect.field(o, "payType")); // :943
		Assert.equals(5, model._diyExp); // :935
		Assert.equals("DIY", model._buyType); // :941
		Assert.equals("2", model._itemType); // :942
		Assert.isFalse(model.m_requestPending); // 无 beginTransaction

		var o2:Dynamic = {};
		model.buyInGame(o2, 1, "Item", 0, "3"); // param4=0 → :939 _diyExp=0
		Assert.equals(1, Reflect.field(o2, "payType"));
		Assert.equals(0, model._diyExp);
		Assert.equals("Item", model._buyType);
		Assert.equals("3", model._itemType);
		Assert.isFalse(model.m_requestPending);
		Assert.equals(-1, model.m_preBuyToolType);
	}

	// :488-577 onGetSeedsInfo（无 crops_sort 的部署现实路径）：LOADING
	// {index:0,show:false} 先于 null 判（:491-494）；装载整体替换（:500-508）；
	// 配置合并守卫 `_x == -1 && 键在`（:525 等）；_isGreen 无守卫恒写（:565）；
	// 不排序保持应答序（:568-571 的门在 crops_sort 缺省下不进）
	public function test_onGetSeedsInfo_merge_and_order() {
		// crops 配置：胡萝卜 id3 isFood:"1"（nc_data.php:6022）；草莓 :6020、
		// 白萝卜 :6021 两行无 isFood/isYouji/isRed 键
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({crops: [
			{id: 3, isFood: "1"}]}));
		var radish = new Seed({cId: 2, cLevel: 0, cName: "白萝卜"}); // cropstype.php:5
		var carrot = new Seed({cId: 3, cLevel: 0, cName: "胡萝卜"}); // cropstype.php:6
		var berry = new Seed({cId: 1, cLevel: 10, cName: "草莓"}); // cropstype.php:4
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onGetSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, [radish, carrot, berry]));

		// 事件序：LOADING{index:0,show:false} → LOADED{index:0,data:m_seeds}
		Assert.equals(2, log.length);
		Assert.equals(ShopModel.EVENT_SHOP_DATA_LOADING, Reflect.field(log[0], "type"));
		var load = Reflect.field(log[0], "data");
		Assert.equals(0, Reflect.field(load, "index"));
		Assert.isTrue(Reflect.field(load, "show") == false);
		Assert.equals(ShopModel.EVENT_SHOP_DATA_LOADED, Reflect.field(log[1], "type"));
		var loaded = Reflect.field(log[1], "data");
		Assert.equals(0, Reflect.field(loaded, "index"));
		Assert.isTrue(Reflect.field(loaded, "data") == model.m_seeds);

		// crops_sort 未配 → 不解析不排序，保持应答顺序
		Assert.equals(3, model.m_seeds.length);
		Assert.isTrue(model.m_seeds[0] == radish);
		Assert.isTrue(model.m_seeds[1] == carrot);
		Assert.isTrue(model.m_seeds[2] == berry);

		// 胡萝卜：-1 → 配置补 1（isFood=="1" 松等命中，:525-527）；配置行无
		// isFood 的白萝卜/草莓保持 -1
		Assert.equals(1, carrot._isFood);
		Assert.equals(-1, radish._isFood);
		Assert.equals(-1, berry._isFood);
		// :565 _isGreen 无守卫恒写：配置行无 isYouji（undefined==1 false）→ false
		Assert.isFalse(carrot._isGreen);
		Assert.isFalse(berry._isGreen);
		// 配置行无 isRed → :560 的键门不进，_isRed/_isBlack 保持初值 false
		Assert.isFalse(carrot._isRed);
		Assert.isFalse(carrot._isBlack);
		Assert.isFalse(model.isEmpty(0));

		// 二次应答整体替换（:504-508 splice + concat）
		var sole = new Seed({cId: 4, cLevel: 3, cName: "玉米"}); // cropstype.php:7
		model.onGetSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, [sole]));
		Assert.equals(1, model.m_seeds.length);
		Assert.isTrue(model.m_seeds[0] == sole);
	}

	// :510-513 + :568-571 + :474-486：crops_sort 配置时逐个 _sort=表内下标
	// （:520）、装载后 seedSort 排序——比较器 `param1._lvl > param2._lvl
	// ? 1 : -1` 按约定正数排后 → _lvl 升序、平级 _id 升序（勿改降序直觉）
	public function test_onGetSeedsInfo_crops_sort_assigns_and_sorts() {
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({crops: []})); // 无配置行
		Settings.getInstance().loadLocalSettings({crops_sort: "1,3,2"}); // 合成场景
		var berry = new Seed({cId: 1, cLevel: 10, cName: "草莓"});
		var carrot = new Seed({cId: 3, cLevel: 0, cName: "胡萝卜"});
		var radish = new Seed({cId: 2, cLevel: 0, cName: "白萝卜"});

		model.onGetSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, [berry, carrot, radish]));

		// _sort 按表内位置（:520，"1,3,2" → id1=0、id3=1、id2=2）
		Assert.equals(0, berry._sort);
		Assert.equals(1, carrot._sort);
		Assert.equals(2, radish._sort);
		// seedSort 升序：lvl0 组（id2 < id3）在前、lvl10 殿后
		Assert.equals(3, model.m_seeds.length);
		Assert.isTrue(model.m_seeds[0] == radish);
		Assert.isTrue(model.m_seeds[1] == carrot);
		Assert.isTrue(model.m_seeds[2] == berry);
	}

	// :525-565 配置补丁逐键表（crops 行逐字裁剪自 nc_data.php，字符串/数值
	// 形状保持原样——松等断言钉的就是形状）：
	// - isFood "1" → 1；isRestaurant 数值 1/2 → 三值分支 1/2/其余 0（:529-543）
	// - isMill "0" → 键在值非 "1" → 0（:544-547）；isActivity 数值 1 → 1（:548-551）
	// - isVIP 1 → 1 + vipDesc 透传（:552-559）
	// - isRed 一键双写：=="1" → _isRed 且 _isBlack=false；=="2"（数值 2 松等
	//   命中）→ _isBlack（:560-564）
	// - isYouji 1 → _isGreen 无守卫恒写（:565）；行无 isFood → 保持 -1
	public function test_onGetSeedsInfo_flag_patch_table() {
		var rows:Array<Dynamic> = [
			{id: 27, isRestaurant: 1}, // nc_data.php:6045 菠萝（数值形）
			{id: 933, isRestaurant: 2, isYouji: 1}, // :6699 有机白萝卜（数值形）
			{id: 101, isMill: "0"}, // :6119 薰衣草（"0" 字符串形）
			{id: 311, isActivity: 1}, // :6279 星星圣诞树（数值形）
			{id: 169, isVIP: 1, vipDesc: "神奇的红色景观树"}, // :6182 红色景观树
			{id: 126, isRed: "1"}, // :6144 曼珠沙华（"1" 字符串形）
			{id: 460, isRed: 2}, // :6416 园艺熊猫（isRed=2 → 黑土）
			{id: 3, isFood: "1"} // :6022 胡萝卜（"1" 字符串形）
		];
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({crops: rows}));
		var pineapple = new Seed({cId: 27});
		var organic = new Seed({cId: 933});
		var lavender = new Seed({cId: 101});
		var xmas = new Seed({cId: 311});
		var vipTree = new Seed({cId: 169});
		var redSpider = new Seed({cId: 126});
		var panda = new Seed({cId: 460});
		var carrot = new Seed({cId: 3});

		model.onGetSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null,
			[pineapple, organic, lavender, xmas, vipTree, redSpider, panda, carrot]));

		Assert.equals(1, pineapple._isRestaurant); // :531-534
		Assert.equals(2, organic._isRestaurant); // :535-538
		Assert.equals(0, lavender._isMill); // :546 "0" 键在非 "1"
		Assert.equals(1, xmas._isActivity); // :550
		Assert.equals(1, vipTree._isVip); // :554
		Assert.equals("神奇的红色景观树", vipTree._vipDesc); // :557
		Assert.isTrue(redSpider._isRed); // :562 isRed=="1"
		Assert.isFalse(redSpider._isBlack); // :563 "2" 不等 → false
		Assert.isFalse(panda._isRed); // :562 数值 2 松等不命中 "1"
		Assert.isTrue(panda._isBlack); // :563 isRed=="2" 松等命中
		Assert.isTrue(organic._isGreen); // :565 isYouji==1
		Assert.isFalse(pineapple._isGreen); // 行无 isYouji → 恒写 false
		Assert.equals(1, carrot._isFood); // :527
		Assert.equals(-1, organic._isFood); // 行无 isFood → 守卫不进
	}

	// :495-499 VO null 早退发生在 LOADING 之后 → 只见 LOADING 不见 LOADED、
	// m_seeds 保持 null
	public function test_onGetSeedsInfo_null_vo_keeps_loading_only() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		model.onGetSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, null));
		Assert.equals(1, countType(log, ShopModel.EVENT_SHOP_DATA_LOADING));
		Assert.isTrue(Reflect.field(firstData(log, ShopModel.EVENT_SHOP_DATA_LOADING), "show") == false);
		Assert.equals(0, countType(log, ShopModel.EVENT_SHOP_DATA_LOADED));
		Assert.isNull(model.m_seeds);
	}

	// :863-888 onGetItemsInfo：LOADING {index:2,show:false} 先发（:865-868）、
	// 整体替换（:874-882）、LOADED {index:2,data:m_items}；VO null → 只见
	// LOADING 且列表不动
	public function test_onGetItemsInfo_replaces_and_null_keeps_state() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var a = new Item({tId: 13});
		var b = new Item({tId: 14});
		model.onGetItemsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ITEMS, null, [a, b]));
		Assert.equals(2, model.m_items.length);
		Assert.isTrue(model.m_items[0] == a);
		Assert.isTrue(model.m_items[1] == b);
		var loaded = lastData(log, ShopModel.EVENT_SHOP_DATA_LOADED);
		Assert.equals(2, Reflect.field(loaded, "index"));
		Assert.isTrue(Reflect.field(loaded, "data") == model.m_items);
		Assert.isTrue(Reflect.field(firstData(log, ShopModel.EVENT_SHOP_DATA_LOADING), "show") == false);

		var c = new Item({tId: 15});
		model.onGetItemsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ITEMS, null, [c]));
		Assert.equals(1, model.m_items.length); // 旧条目不保留
		Assert.isTrue(model.m_items[0] == c);

		var before = model.m_items;
		model.onGetItemsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ITEMS, null, null));
		Assert.equals(3, countType(log, ShopModel.EVENT_SHOP_DATA_LOADING)); // null 也先发 LOADING（:865-868 先于 :869-872）
		Assert.equals(2, countType(log, ShopModel.EVENT_SHOP_DATA_LOADED));
		Assert.isTrue(model.m_items == before); // :870-871 早退不动列表
	}

	// :607-657 onGetFishInfo：fish_info 配置合并（:634-648 逐字段照搬、
	// _lock_gold==0 才补 lock_money（AS3 int 强转 "10000"→10000，ShopFish.as:28）、
	// _lock_crystal=="" 才补）+ fishSort 升序（output*sale 最小在前，:651）；
	// 无配置行的鱼保持 ShopFish 初值
	public function test_onGetFishInfo_config_merge_and_fishSort_order() {
		// fish_info 行逐字裁剪（全部在 nc_data.php:7565；只保留模型读的键，
		// 值形状照抄：lock_money/lock_crystal 是字符串、产量是数值）
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({fish_info: [
			{id: 2, crop_name: "小丑鱼", exp: 42, output: 15, sale: 90, price: 650,
				mature: 23, pool_size: 1, lock_money: "10000", lock_crystal: ""},
			{id: 4, crop_name: "蝶鱼", exp: 50, output: 24, sale: 85, price: 940,
				mature: 30, pool_size: 1, lock_money: "50000", lock_crystal: "1,10"},
			{id: 13, crop_name: "蝠鲼", exp: 180, output: 29, sale: 350, price: 4800,
				mature: 60, pool_size: 2, lock_money: "500000", lock_crystal: "7,20"},
			{id: 14, crop_name: "海豚", exp: 285, output: 25, sale: 700, price: 8200,
				mature: 68, pool_size: 3, lock_money: "500000", lock_crystal: ""}]}));
		var dolphin = new ShopFish({fid: 14, lock: "0", type: 23}); // 应答乱序进
		var manta = new ShopFish({fid: 13, lock: "2", type: 23});
		var clown = new ShopFish({fid: 2, lock: "1", type: 23});
		var butterfly = new ShopFish({fid: 4, lock: "1", type: 23});
		var unknown = new ShopFish({fid: 999, lock: "0", type: 23});
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onGetFishInfo(voEvent(CommandDefs.CMD_GET_SHOP_FISH, null,
			[dolphin, manta, clown, butterfly, unknown]));

		// 小丑鱼全字段照搬（:634-640）；lock_money "10000" 写进 int 字段
		Assert.equals(1, clown._pool_size);
		Assert.equals(42, clown._exp);
		Assert.equals("小丑鱼", clown._name);
		Assert.equals(15, clown._output);
		Assert.equals(90, clown._sale);
		Assert.equals(650, clown._price);
		Assert.equals(23, clown._mature);
		Assert.equals(10000, clown._lock_gold); // :641-644 AS3 int 强转
		Assert.equals("", clown._lock_crystal); // :645-648 配置值就是 ""
		Assert.equals("1,10", butterfly._lock_crystal); // 初值 "" → 补 "1,10"
		// 无配置行（fid 999）：ShopFish.hx:10-27 初值原样
		Assert.equals(0, unknown._pool_size);
		Assert.equals(0, unknown._output);
		Assert.equals(0, unknown._lock_gold);
		Assert.equals("", unknown._name);
		Assert.equals("", unknown._lock_crystal);

		// fishSort :159-171 升序（正数排后）：unknown 0*0=0 最前，小丑鱼
		// 15*90=1350、蝶鱼 24*85=2040、蝠鲼 29*350=10150、海豚 25*700=17500
		Assert.equals(5, model.m_fishs.length);
		Assert.isTrue(model.m_fishs[0] == unknown);
		Assert.isTrue(model.m_fishs[1] == clown);
		Assert.isTrue(model.m_fishs[2] == butterfly);
		Assert.isTrue(model.m_fishs[3] == manta);
		Assert.isTrue(model.m_fishs[4] == dolphin);
		// 事件序同种子档：LOADING{index:1,show:false} → LOADED{index:1,data}
		Assert.equals(2, log.length);
		Assert.isTrue(Reflect.field(firstData(log, ShopModel.EVENT_SHOP_DATA_LOADING), "show") == false);
		Assert.equals(1, Reflect.field(Reflect.field(log[1], "data"), "index"));
		Assert.isTrue(Reflect.field(Reflect.field(log[1], "data"), "data") == model.m_fishs);
	}

	// :159-171 fishSort / :474-486 seedSort 比较器直调：null 任一侧恒 0；
	// 平级（乘积相等 / lvl 相等）走 _id 比较；非平级永不回 0（原版字面，
	// AS3 sort 对无 0 返回的表不做稳定保证，这里只钉返回值）
	public function test_sort_comparators_fishSort_seedSort() {
		Assert.equals(0, model.fishSort(null, null)); // :161-164
		Assert.equals(0, model.fishSort(null, new ShopFish({fid: 1})));
		Assert.equals(0, model.seedSort(null, null)); // :476-479

		var a = new ShopFish({fid: 1});
		var b = new ShopFish({fid: 2});
		a._output = 2;
		a._sale = 3; // 6
		b._output = 1;
		b._sale = 1; // 1
		Assert.equals(1, model.fishSort(a, b)); // a 乘积大 → 排后（:165）
		Assert.equals(-1, model.fishSort(b, a));
		b._output = 3;
		b._sale = 2; // 6 == 6 → 平级走 _id（:166-168）
		Assert.equals(-1, model.fishSort(a, b)); // a._id 1 < 2 → 排前
		Assert.equals(1, model.fishSort(b, a));

		var s1 = new Seed({cId: 1, cLevel: 5});
		var s2 = new Seed({cId: 2, cLevel: 5});
		Assert.equals(0, model.seedSort(s1, null));
		Assert.equals(1, model.seedSort(s2, s1)); // :480 lvl 相等 → :483 _id 大者排后
		Assert.equals(-1, model.seedSort(s1, s2));
		s2._lvl = 6; // 6 > 5
		Assert.equals(1, model.seedSort(s2, s1)); // lvl 大者排后（升序）
		Assert.equals(-1, model.seedSort(s1, s2));
	}

	// :957-995 onGetDecorsInfo：整表 reverse（:977）后按 4 元块换位
	// （:980-989：块内 0↔3、1↔2）——8 元净效果是后 4 元整体前置；元素本体
	// 不被读取（比较的是位置）。非 4 倍数长度该 while 末块越界写会把
	// length 垫到下一个 4 的倍数、尾部留 undefined 槽（原版缺陷；垫完
	// _loc4_ 追平即退出，非死循环），fixture 取 4 的倍数
	public function test_onGetDecorsInfo_reverse_and_block_swap() {
		var d1 = new DIYDecor({itemId: 1});
		var d2 = new DIYDecor({itemId: 2});
		var d3 = new DIYDecor({itemId: 3});
		var d4 = new DIYDecor({itemId: 4});
		var d5 = new DIYDecor({itemId: 5});
		var d6 = new DIYDecor({itemId: 6});
		var d7 = new DIYDecor({itemId: 7});
		var d8 = new DIYDecor({itemId: 8});
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onGetDecorsInfo(voEvent(CommandDefs.CMD_GET_SHOP_DIY, null,
			[d1, d2, d3, d4, d5, d6, d7, d8]));

		Assert.equals(8, model.m_decors.length);
		Assert.isTrue(model.m_decors[0] == d5); // reverse → [d8..d1]，块换位
		Assert.isTrue(model.m_decors[1] == d6); // → [d5,d6,d7,d8, d1,d2,d3,d4]
		Assert.isTrue(model.m_decors[2] == d7);
		Assert.isTrue(model.m_decors[3] == d8);
		Assert.isTrue(model.m_decors[4] == d1);
		Assert.isTrue(model.m_decors[5] == d2);
		Assert.isTrue(model.m_decors[6] == d3);
		Assert.isTrue(model.m_decors[7] == d4);
		// LOADING{index:3,show:false} → LOADED{index:3,data:m_decors}
		Assert.equals(2, log.length);
		Assert.isTrue(Reflect.field(firstData(log, ShopModel.EVENT_SHOP_DATA_LOADING), "show") == false);
		Assert.equals(3, Reflect.field(Reflect.field(log[1], "data"), "index"));
		Assert.isTrue(Reflect.field(Reflect.field(log[1], "data"), "data") == model.m_decors);
		Assert.isFalse(model.isEmpty(2));

		// 二次应答整体替换
		model.onGetDecorsInfo(voEvent(CommandDefs.CMD_GET_SHOP_DIY, null,
			[new DIYDecor({itemId: 9}), new DIYDecor({itemId: 10}),
				new DIYDecor({itemId: 11}), new DIYDecor({itemId: 12})]));
		Assert.equals(4, model.m_decors.length);
		Assert.equals(9, model.m_decors[0]._id); // 4 元块：reverse+换位=恒等
		Assert.equals(10, model.m_decors[1]._id);
		Assert.equals(11, model.m_decors[2]._id);
		Assert.equals(12, model.m_decors[3]._id);
	}

	// :231-279 onGetAdvertisementInfo 三分支：
	// - ret!=0（部署桩 '{}'，view_fcg.php:7）→ FAILED{index:4,error:msg缺省}
	// - data[posid].ret==0 → LOADING{index:4,show:false} + concat 整体替换 +
	//   LOADED{index:4,data} + apurl 非空走 sendToURL（shim 不发送）
	// - data[posid].ret!=0 → 只发 LOADED、载荷是现有列表（未装载时 null）
	// - VO null → 无派发
	public function test_onGetAdvertisementInfo_branches() {
		// 分支一/VO-null：独立模型
		var m1 = freshModel();
		var log1:Array<Dynamic> = [];
		listenModel(m1, log1);
		m1.onGetAdvertisementInfo(voEvent(CommandDefs.CMD_GET_SNS_AD, null, {}));
		Assert.equals(1, log1.length);
		var failed = Reflect.field(log1[0], "data");
		Assert.equals(ShopModel.EVENT_SHOP_DATA_FAILED, Reflect.field(log1[0], "type"));
		Assert.equals(4, Reflect.field(failed, "index")); // :241-244
		Assert.isTrue(Reflect.field(failed, "error") == null); // {} 无 msg 键
		m1.onGetAdvertisementInfo(voEvent(CommandDefs.CMD_GET_SNS_AD, null, null));
		Assert.equals(1, log1.length); // :235-238 VO null 早退

		// 成功 + 替换 + ret!=0 带现有
		var m2 = freshModel();
		var log2:Array<Dynamic> = [];
		listenModel(m2, log2);
		var rowA:Dynamic = {img: "http://i/a.png", rl: "http://r/a"};
		var rowB:Dynamic = {img: "http://i/b.png", rl: "http://r/b"};
		m2.onGetAdvertisementInfo(voEvent(CommandDefs.CMD_GET_SNS_AD, null,
			{ret: 0, data: obj([["72339074132595919",
				{ret: 0, list: [rowA, rowB], cfg: {apurl: "http://pgdt.qq.com/l?fcg?a=1"}}]])}));
		Assert.equals(2, log2.length); // LOADING show:false → LOADED
		Assert.isTrue(Reflect.field(firstData(log2, ShopModel.EVENT_SHOP_DATA_LOADING), "show") == false);
		Assert.equals(4, Reflect.field(Reflect.field(log2[1], "data"), "index"));
		Assert.equals(2, (Reflect.field(Reflect.field(log2[1], "data"), "data"):Array<Dynamic>).length);
		Assert.isTrue(m2.m_advertisement[0] == rowA); // :260 原行引用直拼
		Assert.isTrue(m2.m_advertisement[1] == rowB);

		// 二次成功应答：splice(0) + concat → 整体替换（:252-260）
		var rowC:Dynamic = {img: "http://i/c.png", rl: "http://r/c"};
		m2.onGetAdvertisementInfo(voEvent(CommandDefs.CMD_GET_SNS_AD, null,
			{ret: 0, data: obj([["72339074132595919", {ret: 0, list: [rowC], cfg: {}}]])}));
		Assert.equals(1, m2.m_advertisement.length); // cfg 无 apurl → 不发 sendToURL
		Assert.isTrue(m2.m_advertisement[0] == rowC);

		// data[posid].ret!=0 → 只发 LOADED、带现有列表引用（:273-277）
		var before = m2.m_advertisement;
		m2.onGetAdvertisementInfo(voEvent(CommandDefs.CMD_GET_SNS_AD, null,
			{ret: 0, data: obj([["72339074132595919", {ret: 1}]])}));
		Assert.equals(3, countType(log2, ShopModel.EVENT_SHOP_DATA_LOADED));
		Assert.equals(2, countType(log2, ShopModel.EVENT_SHOP_DATA_LOADING)); // 两次成功各一发，本分支不发（:271-277）
		Assert.isTrue(Reflect.field(lastData(log2, ShopModel.EVENT_SHOP_DATA_LOADED), "data") == before);

		// 未装载时走同分支：LOADED{index:4,data:null}
		var m3 = freshModel();
		var log3:Array<Dynamic> = [];
		listenModel(m3, log3);
		m3.onGetAdvertisementInfo(voEvent(CommandDefs.CMD_GET_SNS_AD, null,
			{ret: 0, data: obj([["72339074132595919", {ret: 1}]])}));
		Assert.equals(1, log3.length);
		Assert.equals(ShopModel.EVENT_SHOP_DATA_LOADED, Reflect.field(log3[0], "type"));
		Assert.isTrue(Reflect.field(Reflect.field(log3[0], "data"), "data") == null);
	}

	// :387-455 onGetAdvertisementSeedsList（合作专区种子列表，自身零派发、
	// 末尾 loadAdvertisementSeedsInfo 只发请求 no-op → log 恒空）：
	// - concat 整体替换（:395-403）
	// - isRestaurant 是二元判定 `=="1"?1:0`（:424-427）——数值 2 也归 0，
	//   与种子页 :529-543 的三值分支不对称（照抄）
	// - isRed 单写 _isRed（:444-447），无 :563 的 _isBlack 孪生；无 :565 的
	//   _isGreen/isYouji 补丁——三条都与种子页形成对照钉
	public function test_onGetAdvertisementSeedsList_config_gates_contrast() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var rows:Array<Dynamic> = [
			{id: 3, isFood: "1"}, // nc_data.php:6022 胡萝卜
			{id: 126, isRed: "1"}, // :6144 曼珠沙华
			{id: 933, isRestaurant: 2, isYouji: 1} // :6699 有机白萝卜
		];
		Settings.getInstance().setConfigDataModel(new FakeConfigModel({crops: rows}));
		var carrot = new Seed({cId: 3});
		var redSpider = new Seed({cId: 126});
		var organic = new Seed({cId: 933});

		model.onGetAdvertisementSeedsList(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null,
			[carrot, redSpider, organic]));

		Assert.equals(3, model.m_adSeeds.length);
		Assert.isTrue(model.m_adSeeds[0] == carrot);
		Assert.isTrue(model.m_adSeeds[2] == organic);
		Assert.equals(1, carrot._isFood); // :420-423 同种子页二元判定
		Assert.equals(0, organic._isRestaurant); // :426 数值 2 → 0（对照
		// 种子页的 _isRestaurant==2）
		Assert.isTrue(redSpider._isRed); // :446 单写
		Assert.isFalse(redSpider._isBlack); // 无孪生写 → 初值 false（对照种子页）
		Assert.isFalse(organic._isGreen); // 无 :565 恒写 → 初值 false（对照
		// 种子页的 isYouji==1 → true）
		Assert.equals(0, log.length); // 全程零派发

		// 二次应答整体替换（:400-403 splice + concat）
		var sole = new Seed({cId: 101});
		model.onGetAdvertisementSeedsList(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, [sole]));
		Assert.equals(1, model.m_adSeeds.length);
		Assert.isTrue(model.m_adSeeds[0] == sole);

		// VO null 早退（:391-394）
		model.onGetAdvertisementSeedsList(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, null));
		Assert.equals(1, model.m_adSeeds.length);
		Assert.equals(0, log.length);
	}

	// :997-1080 onGetAdvertisementSeedsInfo（合作专区第二网关应答）：
	// - ret!=0 → FAILED{index:5,error:msg}（:1015-1021）
	// - data[posid].ret!=0 → LOADED{index:5,data:null}（:1073-1078）——部署桩
	//   形态（view_fcg.php:9：ret0 外壳 + 内层 ret1）
	// - data[posid].ret==0 → LOADING{index:5,show:false} + targetid 过滤
	//   （:1039-1056 倒数循环 splice 掉表外种子，保序）+ 留守种子补
	//   _isAdSeed=1/_rl/apurl 截取 viewid + LOADED{index:5,data:m_adSeeds}
	// - VO null → 无派发
	public function test_onGetAdvertisementSeedsInfo_branches() {
		// 分支一：ret!=0
		var m1 = freshModel();
		var log1:Array<Dynamic> = [];
		listenModel(m1, log1);
		m1.onGetAdvertisementSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ADVERTISEMENT_SEED, null,
			{ret: 5, msg: "网关异常"}));
		Assert.equals(1, log1.length);
		Assert.equals(ShopModel.EVENT_SHOP_DATA_FAILED, Reflect.field(log1[0], "type"));
		Assert.equals(5, Reflect.field(Reflect.field(log1[0], "data"), "index"));
		Assert.equals("网关异常", Reflect.field(Reflect.field(log1[0], "data"), "error"));

		// 分支二：部署桩字面（count==15，view_fcg.php:9）→ 内层 ret==1
		var m2 = freshModel();
		var log2:Array<Dynamic> = [];
		listenModel(m2, log2);
		m2.onGetAdvertisementSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ADVERTISEMENT_SEED, null,
			{ret: 0, msg: "", data: obj([["144396668170523855", {ret: 1, msg: ""}]])}));
		Assert.equals(1, log2.length); // 无 LOADING
		Assert.equals(ShopModel.EVENT_SHOP_DATA_LOADED, Reflect.field(log2[0], "type"));
		Assert.equals(5, Reflect.field(Reflect.field(log2[0], "data"), "index"));
		Assert.isTrue(Reflect.field(Reflect.field(log2[0], "data"), "data") == null);

		// 分支三：先经 onGetAdvertisementSeedsList 装三粒种子，成功应答过滤
		var m3 = freshModel();
		var log3:Array<Dynamic> = [];
		listenModel(m3, log3);
		var s3 = new Seed({cId: 3});
		var s126 = new Seed({cId: 126});
		var s169 = new Seed({cId: 169});
		m3.onGetAdvertisementSeedsList(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, [s3, s126, s169]));
		m3.onGetAdvertisementSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ADVERTISEMENT_SEED, null,
			{ret: 0, data: obj([["144396668170523855", {ret: 0, list: [
				{targetid: "169", rl: "http://l/169", apurl: "http://pgdt.qq.com/s?fcg?viewid=777&x=4"},
				{targetid: "3", rl: "http://l/3", apurl: "http://pgdt.qq.com/s?fcg?viewid=888&x=9"}]}]])}));
		Assert.equals(2, log3.length); // LOADING → LOADED（首段零派发）
		Assert.isTrue(Reflect.field(firstData(log3, ShopModel.EVENT_SHOP_DATA_LOADING), "show") == false);
		Assert.equals(5, Reflect.field(lastData(log3, ShopModel.EVENT_SHOP_DATA_LOADED), "index"));
		// 126 不在 targetid 表 → 被倒数 splice（:1042-1045），保序留守
		Assert.equals(2, m3.m_adSeeds.length);
		Assert.isTrue(m3.m_adSeeds[0] == s3);
		Assert.isTrue(m3.m_adSeeds[1] == s169);
		Assert.equals(1, s3._isAdSeed); // :1048
		Assert.equals("http://l/3", s3._rl); // :1049 同位 list 行的 rl
		Assert.equals(1, s169._isAdSeed);
		Assert.equals("http://l/169", s169._rl);
		Assert.equals(-1, s126._isAdSeed); // 被移除，未补丁（Seed.hx:51 初值）
		// apurl 截取（:1050-1053）经 URLVariables 解析后只进 postUrl 载荷，
		// 不可观测——分支全程跑通不抛即钉（URLLoader 空址 eval 静默）

		// VO null（:1011-1014 早退）→ 无派发，log 停在 2 条
		m3.onGetAdvertisementSeedsInfo(voEvent(CommandDefs.CMD_GET_SHOP_ADVERTISEMENT_SEED, null, null));
		Assert.equals(2, log3.length);
	}

	// :173-224 onLoadDataError：cmdID → 页签 index 表（33→0、34→2、35→3、
	// 61→1、65→5）+ 重试文案；52（广告位）无 index 改写 → 不派发；body 无
	// cmdID 键 → 不派发；VO null → 早退不派发
	public function test_onLoadDataError_cmd_table_and_retry_text() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var retry = "请求超时，<a href='event:reload'><u><font color='#ff6600'>点击重试</font></u></a>"; // :219（Language.L cn 表恒等映射）

		var table:Array<Array<Int>> = [
			[33, 0], // :183-188 种子
			[34, 2], // :189-194 道具
			[35, 3], // :195-200 装饰
			[61, 1], // :205-209 鱼苗
			[65, 5] // :210-213 合作专区
		];
		var seen = 0;
		for (row in table) {
			model.onLoadDataError(voEvent(row[0], null, {}));
			seen++;
			Assert.equals(seen, countType(log, ShopModel.EVENT_SHOP_DATA_FAILED));
			var d = lastData(log, ShopModel.EVENT_SHOP_DATA_FAILED);
			Assert.equals(row[1], Reflect.field(d, "index"));
			Assert.equals(retry, Reflect.field(d, "error"));
		}
		Assert.equals(5, seen);

		// 52：只 recordResp 不改 _loc3_（:201-204）→ -1 → 不派发
		model.onLoadDataError(voEvent(CommandDefs.CMD_GET_SNS_AD, null, {}));
		Assert.equals(5, countType(log, ShopModel.EVENT_SHOP_DATA_FAILED));

		// body 无 cmdID 键（:181-182 判键）→ 不派发
		var bare = new CommandEvent(CommandEvent.COMPLETE);
		var vo = new ServiceResultVO();
		vo.m_extra = {};
		bare.body = {};
		bare.result = vo;
		model.onLoadDataError(bare);
		Assert.equals(5, countType(log, ShopModel.EVENT_SHOP_DATA_FAILED));

		// VO null（:176-179）→ 不派发
		model.onLoadDataError(voEvent(33, null, null));
		Assert.equals(5, countType(log, ShopModel.EVENT_SHOP_DATA_FAILED));
	}

	// :286-303 onBuyToolSuccess：cmdID ∈ {95,151,106} 且 code==1 →
	// BUY_TOOL_SUCCESS（载荷原引用 + __buyType="0" 写在载荷上）；cmdID 或
	// code 不匹配 → 不派发但 endTransaction 照跑；VO null → 连
	// endTransaction 都不跑（:289-292 早退）
	public function test_onBuyToolSuccess_cmd_gate_and_transaction_reset() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		// cmdID 表逐个：94（种子买入）不在表 → 不派发但复位
		model.m_requestPending = true;
		model.m_preBuyToolType = 7;
		model.onBuyToolSuccess(voEvent(CommandDefs.CMD_BUY_SEEDS, null, {code: 1}));
		Assert.equals(0, log.length);
		Assert.isFalse(model.m_requestPending); // :302 endTransaction 无条件
		Assert.equals(-1, model.m_preBuyToolType);

		var seen = 0;
		for (cmd in [CommandDefs.CMD_BUY_TOOLS, CommandDefs.CMD_BUY_WEAPONS,
			CommandDefs.CMD_BUY_TOOLS_VIP]) { // :294
			model.m_requestPending = true;
			model.m_preBuyToolType = 7;
			model.onBuyToolSuccess(voEvent(cmd, null, {code: 1}));
			seen++;
			Assert.equals(seen, countType(log, ShopModel.EVENT_BUY_TOOL_SUCCESS));
			var d = lastData(log, ShopModel.EVENT_BUY_TOOL_SUCCESS);
			Assert.equals("0", Reflect.field(d, "__buyType")); // :298 写在载荷上
			Assert.isFalse(model.m_requestPending);
			Assert.equals(-1, model.m_preBuyToolType);
		}

		// cmdID 命中但 code!=1 → 不派发、复位照跑（:296 判 code）
		model.m_requestPending = true;
		model.m_preBuyToolType = 7;
		model.onBuyToolSuccess(voEvent(CommandDefs.CMD_BUY_TOOLS, null, {code: 2}));
		Assert.equals(3, countType(log, ShopModel.EVENT_BUY_TOOL_SUCCESS));
		Assert.isFalse(model.m_requestPending);

		// VO null → 不复位（:289-292）
		model.m_requestPending = true;
		model.onBuyToolSuccess(voEvent(CommandDefs.CMD_BUY_TOOLS, null, null));
		Assert.isTrue(model.m_requestPending);
	}

	// :843-861 onBuyDIYSuccess（cmdID==98 门）与 :1082-1094 onBuyFishSuccess
	//（无 cmdID 门——body 都不读）的成功/复位表
	public function test_onBuyDIY_and_onBuyFish_success_gates() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		// DIY：98 + code1 → BUY_DIY_SUCCESS + __buyType="0" + 复位
		model.m_requestPending = true;
		model.m_preBuyToolType = 808080;
		model.onBuyDIYSuccess(voEvent(CommandDefs.CMD_BUY_DIY, null, {code: 1}));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_DIY_SUCCESS)); // :851-858
		Assert.equals("0", Reflect.field(lastData(log, ShopModel.EVENT_BUY_DIY_SUCCESS), "__buyType"));
		Assert.isFalse(model.m_requestPending); // :860
		Assert.equals(-1, model.m_preBuyToolType);

		// cmdID 非 98（如 99）→ 不派发、复位照跑
		model.m_requestPending = true;
		model.onBuyDIYSuccess(voEvent(99, null, {code: 1}));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_DIY_SUCCESS));
		Assert.isFalse(model.m_requestPending);

		// 98 + code!=1 → 不派发、复位照跑
		model.m_requestPending = true;
		model.onBuyDIYSuccess(voEvent(CommandDefs.CMD_BUY_DIY, null, {code: 0}));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_DIY_SUCCESS));
		Assert.isFalse(model.m_requestPending);

		// DIY VO null → 不复位
		model.m_requestPending = true;
		model.onBuyDIYSuccess(voEvent(CommandDefs.CMD_BUY_DIY, null, null));
		Assert.isTrue(model.m_requestPending);

		// 鱼：无 cmdID 门——body 为 null 也照发（:1089 只判 code）
		model.m_requestPending = true;
		var bare = new CommandEvent(CommandEvent.COMPLETE);
		var vo = new ServiceResultVO();
		vo.m_extra = {code: 1};
		bare.result = vo;
		model.onBuyFishSuccess(bare);
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_FISH_SUCCESS));
		Assert.isFalse(model.m_requestPending); // :1093

		// code!=1 → 不派发、复位照跑
		model.m_requestPending = true;
		model.onBuyFishSuccess(voEvent(CommandDefs.CMD_BUY_FISHS, null, {code: 0}));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_FISH_SUCCESS));
		Assert.isFalse(model.m_requestPending);

		// VO null → 不复位
		model.m_requestPending = true;
		model.onBuyFishSuccess(voEvent(CommandDefs.CMD_BUY_FISHS, null, null));
		Assert.isTrue(model.m_requestPending);
	}

	// :327-348 onBuySeedSuccess（code==1 → 事件 + 复位；isAdSeed 分支走
	// postUrl 空址不发送不抛）与 :124-136 onUnlockFishSuccess（code==1 → 事件；
	// loadFishInfo(true) 无条件跑 → 门开时多发一发 LOADING）
	public function test_onBuySeedSuccess_and_onUnlockFishSuccess() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		// code==1 → BUY_SEED_SUCCESS（载荷原引用），无 __buyType 写
		model.m_requestPending = true;
		var payload:Dynamic = {code: 1, cId: 3, num: 2};
		model.onBuySeedSuccess(voEvent(CommandDefs.CMD_BUY_SEEDS, null, payload));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_SEED_SUCCESS));
		Assert.isTrue(lastData(log, ShopModel.EVENT_BUY_SEED_SUCCESS) == payload);
		Assert.isFalse(model.m_requestPending); // :340

		// code!=1 → 不派发、复位照跑
		model.m_requestPending = true;
		model.onBuySeedSuccess(voEvent(CommandDefs.CMD_BUY_SEEDS, null, {code: 0}));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_SEED_SUCCESS));
		Assert.isFalse(model.m_requestPending);

		// isAdSeed 分支（:341-346，__body.isAdSeed truthy）：postUrl 空址
		// eval 静默 → 全程跑通不抛
		model.m_requestPending = true;
		model.onBuySeedSuccess(voEvent(CommandDefs.CMD_BUY_SEEDS, {isAdSeed: true},
			{code: 1, cId: 6, num: 3}));
		Assert.equals(2, countType(log, ShopModel.EVENT_BUY_SEED_SUCCESS));
		Assert.isFalse(model.m_requestPending);

		// VO null → 不复位
		model.m_requestPending = true;
		model.onBuySeedSuccess(voEvent(CommandDefs.CMD_BUY_SEEDS, null, null));
		Assert.isTrue(model.m_requestPending);

		// unlockFish 应答：门关（waterPoolOpen=false）→ 只发成功事件
		var m2 = freshModel();
		var log2:Array<Dynamic> = [];
		listenModel(m2, log2);
		var okPayload:Dynamic = {code: 1};
		m2.onUnlockFishSuccess(voEvent(CommandDefs.CMD_UNLOCK_SHOP_FISH, null, okPayload));
		Assert.equals(1, log2.length);
		Assert.equals(ShopModel.EVENT_UNLOCK_FISH_SUCCESS, Reflect.field(log2[0], "type"));
		Assert.isTrue(Reflect.field(log2[0], "data") == okPayload); // :133 载荷原引用
		// 门开 → loadFishInfo(true)（:135）多发一发 LOADING{index:1,show:true}
		Session.getInstance().m_waterPoolOpen = true;
		m2.onUnlockFishSuccess(voEvent(CommandDefs.CMD_UNLOCK_SHOP_FISH, null, {code: 2}));
		Assert.equals(1, countType(log2, ShopModel.EVENT_UNLOCK_FISH_SUCCESS)); // code!=1 不发
		Assert.equals(1, countType(log2, ShopModel.EVENT_SHOP_DATA_LOADING)); // 但刷新照跑
		Assert.equals(1, Reflect.field(firstData(log2, ShopModel.EVENT_SHOP_DATA_LOADING), "index"));
		Assert.isTrue(Reflect.field(firstData(log2, ShopModel.EVENT_SHOP_DATA_LOADING), "show") == true);

		// code==1 且门开 → 事件 + 刷新各一
		m2.onUnlockFishSuccess(voEvent(CommandDefs.CMD_UNLOCK_SHOP_FISH, null, {code: 1}));
		Assert.equals(2, countType(log2, ShopModel.EVENT_UNLOCK_FISH_SUCCESS));
		Assert.equals(2, countType(log2, ShopModel.EVENT_SHOP_DATA_LOADING));

		// VO null → 无事件无刷新
		m2.onUnlockFishSuccess(voEvent(CommandDefs.CMD_UNLOCK_SHOP_FISH, null, null));
		Assert.equals(2, countType(log2, ShopModel.EVENT_UNLOCK_FISH_SUCCESS));
		Assert.equals(2, countType(log2, ShopModel.EVENT_SHOP_DATA_LOADING));
	}

	// :890-929 onTransactionError：cmdID 派发表（94→BUY_SEED_FAIL、107/63→
	// BUY_FISH_FAIL、95/106→BUY_TOOL_FAIL、98→BUY_DIY_FAIL、105→
	// NORMAL_ERROR（无 __buyType 写））；未知 cmdID 不派发；全表 endTransaction
	// 无条件复位；VO null 早退不复位
	public function test_onTransactionError_dispatch_table() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		var seedPayload:Dynamic = {};
		model.m_requestPending = true;
		model.m_preBuyToolType = 7;
		model.onTransactionError(voEvent(CommandDefs.CMD_BUY_SEEDS, null, seedPayload));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_SEED_FAIL)); // :899-904
		Assert.equals("0", Reflect.field(seedPayload, "__buyType")); // :901
		Assert.isFalse(model.m_requestPending); // :928
		Assert.equals(-1, model.m_preBuyToolType);

		var seen = 0;
		for (cmd in [CommandDefs.CMD_BUY_FISHS, CommandDefs.CMD_UNLOCK_SHOP_FISH]) { // :905
			var p:Dynamic = {};
			model.m_requestPending = true;
			model.onTransactionError(voEvent(cmd, null, p));
			seen++;
			Assert.equals(seen, countType(log, ShopModel.EVENT_BUY_FISH_FAIL));
			Assert.equals("0", Reflect.field(p, "__buyType")); // :907
			Assert.isFalse(model.m_requestPending);
		}
		seen = 0;
		for (cmd in [CommandDefs.CMD_BUY_TOOLS, CommandDefs.CMD_BUY_TOOLS_VIP]) { // :910
			var p:Dynamic = {};
			model.m_requestPending = true;
			model.onTransactionError(voEvent(cmd, null, p));
			seen++;
			Assert.equals(seen, countType(log, ShopModel.EVENT_BUY_TOOL_FAIL));
			Assert.equals("0", Reflect.field(p, "__buyType")); // :912
			Assert.isFalse(model.m_requestPending);
		}
		// 98 → BUY_DIY_FAIL（:915-923；ecode==-30017 只影响 recordResp 的
		// 调用与否，EventRecorder DISABLED 下不可观测）
		var diyPayload:Dynamic = {};
		model.m_requestPending = true;
		model.onTransactionError(voEvent(CommandDefs.CMD_BUY_DIY, null, diyPayload));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_DIY_FAIL));
		Assert.equals("0", Reflect.field(diyPayload, "__buyType")); // :917
		Assert.isFalse(model.m_requestPending);

		// 105 → NORMAL_ERROR，无 __buyType 写（:924-927）
		var ingamePayload:Dynamic = {};
		model.m_requestPending = true;
		model.onTransactionError(voEvent(CommandDefs.CMD_BUY_INGAME_BUY, null, ingamePayload));
		Assert.equals(1, countType(log, ShopModel.EVENT_NORMAL_ERROR));
		Assert.isFalse(Reflect.hasField(ingamePayload, "__buyType"));
		Assert.isFalse(model.m_requestPending);

		// 未知 cmdID（如 33）→ 不派发、复位照跑
		model.m_requestPending = true;
		model.onTransactionError(voEvent(CommandDefs.CMD_GET_SHOP_SEED, null, {}));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_SEED_FAIL));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_FISH_FAIL));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_TOOL_FAIL));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_DIY_FAIL));
		Assert.equals(1, countType(log, ShopModel.EVENT_NORMAL_ERROR));
		Assert.isFalse(model.m_requestPending);

		// VO null → 不复位（:892-895）
		model.m_requestPending = true;
		model.onTransactionError(voEvent(CommandDefs.CMD_BUY_SEEDS, null, null));
		Assert.isTrue(model.m_requestPending);
	}

	// :138-152 onDecorsItemLoadedInfo：载荷 [当前装饰, 已购装饰表]（Parser
	// 的 m_extra 双元素形态），取 [1] 的 _id 逐个收进事件载荷 {data:[...]}
	public function test_onDecorsItemLoadedInfo_ids_event() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);
		var ownedA = new DecorateItem({id: 33}); // DecorateItem.hx:28 _id ← "id" 键
		var ownedB = new DecorateItem({id: 34});

		model.onDecorsItemLoadedInfo(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null,
			[[], [ownedA, ownedB]]));

		Assert.equals(1, countType(log, ShopModel.EVENT_SHOP_DIY_OWN_LOADED));
		var d = firstData(log, ShopModel.EVENT_SHOP_DIY_OWN_LOADED);
		var ids:Array<Dynamic> = Reflect.field(d, "data");
		Assert.equals(2, ids.length); // :146-151
		Assert.equals(33, ids[0]);
		Assert.equals(34, ids[1]);

		// VO null → 无派发（:142-145）
		model.onDecorsItemLoadedInfo(voEvent(CommandDefs.CMD_GET_DIY_ITEMS, null, null));
		Assert.equals(1, countType(log, ShopModel.EVENT_SHOP_DIY_OWN_LOADED));
	}

	// :797-831 onInGamePreCheckSuccess：code!=1 → BUY_DIY_FAIL 带
	// {direction}（:826-830）；code==1 → 只走 getInGamePay（QQOutlets
	// available 恒 false → no-op，无派发无回调）
	public function test_onInGamePreCheckSuccess_direction_branch() {
		var log:Array<Dynamic> = [];
		listenModel(model, log);

		model.onInGamePreCheckSuccess(voEvent(CommandDefs.CMD_BUY_INGAME_BUY, null,
			{code: 0, direction: "元宝不足"}));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_DIY_FAIL));
		var d = firstData(log, ShopModel.EVENT_BUY_DIY_FAIL);
		Assert.equals("元宝不足", Reflect.field(d, "direction")); // :828

		model.onInGamePreCheckSuccess(voEvent(CommandDefs.CMD_BUY_INGAME_BUY, null,
			{code: 1, url_params: "p=1"}));
		Assert.equals(1, countType(log, ShopModel.EVENT_BUY_DIY_FAIL)); // no-op 路径
	}

	// —— 工具 ——

	// 数字字符串键的 AS3 Object 形态（广告网关 data 下的 posid 键是长数字
	// 字符串；AS3 obj["72339074132595919"] 按同名属性命中，按同形态喂）
	static function obj(pairs:Array<Array<Dynamic>>):Dynamic {
		var o:Dynamic = {};
		for (p in pairs) {
			Reflect.setField(o, p[0], p[1]);
		}
		return o;
	}

	// 14 个会被 ShopModel 派发的事件（EVENT_UNLOCK_FISH_FAIL 声明后全类无
	// 派发点，不在监听面）：{type, data} 落 log；对同一 model 多次 listen
	// 各收一份，按段用新 log 分阶段断言（FriendsModelTest 同款）
	static function listenModel(m:ShopModel, log:Array<Dynamic>):Void {
		var names:Array<String> = [
			ShopModel.EVENT_SHOP_DATA_LOADED, ShopModel.EVENT_SHOP_DATA_LOADING,
			ShopModel.EVENT_SHOP_DATA_FAILED, ShopModel.EVENT_BUY_SEED_SUCCESS,
			ShopModel.EVENT_BUY_SEED_FAIL, ShopModel.EVENT_BUY_FISH_SUCCESS,
			ShopModel.EVENT_BUY_FISH_FAIL, ShopModel.EVENT_BUY_TOOL_SUCCESS,
			ShopModel.EVENT_BUY_TOOL_FAIL, ShopModel.EVENT_BUY_DIY_SUCCESS,
			ShopModel.EVENT_BUY_DIY_FAIL, ShopModel.EVENT_SHOP_DIY_OWN_LOADED,
			ShopModel.EVENT_NORMAL_ERROR, ShopModel.EVENT_UNLOCK_FISH_SUCCESS
		];
		for (n in names) {
			m.addEventListener(n, function(e:Event) {
				log.push({type: e.type, data: cast(e, CommonEvent).data});
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

	static function firstData(log:Array<Dynamic>, type:String):Dynamic {
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				return Reflect.field(entry, "data");
			}
		}
		return null;
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
	// ServiceResultVO（getVOData 的 m_extra 分支）。同 FriendsModelTest。
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
// PoolFishTest 同款，IModel 含 INotifier 三方法）
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
