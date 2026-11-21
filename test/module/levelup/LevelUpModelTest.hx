package module.levelup;

import com.qzone.qfa.events.CommandEvent;
import com.qzone.qfa.interfaces.IModel;
import common.Settings;
import common.Session;
import entities.Player;
import entities.Seed;
import openfl.events.Event;
import utest.Assert;

/**
 * LevelUpModel 纯逻辑（issue #18）：升级模块数据层——土地档位常量表、
 * 升级可送种子列表的过滤（配置缺失 / exclude_seeds / isVIP / isMill）、
 * 加载门位、面板 URL 拼装、黄钻身份。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/module/levelup/LevelUpModel.as
 *   （常量表 :17-21、事件名 :23、getPanelURL :36-38、getYellowURL :46-48、
 *   isNotShow :51-67、getLevelUpPicURL :69-71、loadSeedsInfo :74-82、
 *   onGetSeedsInfo :89-116、isYellow :118-120）
 * - 配置：legacy/deploy/QFarmFlash/source/core/source/xml/mod/nc_data.php
 *   <crops>（:6020 id 1 草莓——无 isVIP/isMill；:6119 id 101 薰衣草 isMill
 *   "0"；id 169 红色景观树 isVIP 为数字 1；:6257 id 256 石竹花——无
 *   isVIP/isMill）＋ nc_addon.php:106 exclude_seeds（256 在列）、:58
 *   vipSeedLink、:267 secondList 的 levelUpUI。红土地起点 28（spec/
 *   levels.json upgrade.php:4 首行 level 28）与黑土地起点 40（upblack.php:4
 *   level 40）和 :17-21 常量表对账一致。
 *
 * 网络路径不进测试：loadSeedsInfo 的 NetHelper.sendRequest 在 theApp == null
 * 时 no-op（#7 已译，UIToolsModelTest 同口径）；onGetSeedsInfo 直接喂构造好
 * 的 CommandEvent（result 为 Array，走 NetHelper.getVOData 的 Array 直返
 * 分支）。Settings 是全局单例：setup/teardown 钉入/复位 m_params 与
 * m_configDataModel（FakeConfigModel 只实现 getData）。
 */
@:access(common.Settings)
@:access(module.levelup.LevelUpModel)
class LevelUpModelTest {
	public function new() {}

	var model:LevelUpModel;

	public function setup() {
		model = new LevelUpModel();
		var s = Settings.getInstance();
		s.loadLocalSettings(null); // m_params = null、m_appImgPrefix 复位 ""
		s.m_configDataModel = null;
	}

	public function teardown() {
		var s = Settings.getInstance();
		s.loadLocalSettings(null);
		s.m_configDataModel = null;
	}

	// :17-21 三张土地档位表（升到几级解锁下一块普通/红/黑土地）+ :23 事件名
	public function test_land_update_tables_and_event_name() {
		Assert.same([5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39],
			LevelUpModel.NORMAL_LAND_UPDATE_INFO);
		Assert.same([28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 47, 49, 51, 53, 55, 57],
			LevelUpModel.RED_LAND_UPDATE_INFO);
		Assert.same([40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 59, 61, 63, 65, 67, 69],
			LevelUpModel.BLACK_LAND_UPDATE_INFO_NUM);
		Assert.equals("levelUpSeedsDataLoaded", LevelUpModel.EVENT_SEEDS_DATA_LOADED);
	}

	// :74-82 加载门位：请求一次后 _loading 置位；重复调用是 no-op；
	// 应答后 m_seeds 非 null（空表也算“已加载”）→ 永不再发。
	// theApp == null：sendRequest 不发请求，只落状态。
	public function test_loadSeedsInfo_latches_loading_and_skips_when_loaded() {
		// 初始未在加载：eval 上未赋值的 Bool 字段是 null（AS3 默认 false），
		// 断言语义取“非 true”
		Assert.isFalse(model._loading == true);
		Assert.isNull(model.m_seeds);

		model.loadSeedsInfo();
		Assert.isTrue(model._loading);
		Assert.isNull(model.m_seeds);

		model.loadSeedsInfo(); // :76 _loading 早退，不重复发
		Assert.isTrue(model._loading);

		model.onGetSeedsInfo(fakeSeedEvent([])); // 空应答也算已加载
		Assert.isFalse(model._loading);
		Assert.isFalse(model.m_seeds == null);
		Assert.equals(0, model.m_seeds.length);

		model.loadSeedsInfo(); // :76 m_seeds != null 早退，不再置位
		Assert.isFalse(model._loading);
	}

	// :89-116 过滤链（顺序逐层）：
	//   1. getCropByID 命中配置才继续（:102-103，配置缺失整个丢弃）
	//   2. crop 有 id 且 ∈ exclude_seeds → 丢弃（:105，isNotShow :51-67）
	//   3. isVIP/isMill 为 "1" → 丢弃（:107。AS3 宽松等值：nc_data.php 里
	//      isVIP 是 JSON 数字 1，1 == "1" 为 true，照抄）
	//   4. 其余按应答顺序推入 VO 实体本身（:109）
	public function test_onGetSeedsInfo_filters_and_dispatches() {
		pinCrops([
			{"id": "1"}, // 草莓（nc_data.php:6020）：无 isVIP/isMill
			{"id": "101", "isMill": "0"}, // 薰衣草（:6119）isMill "0" → 不排除
			{"id": "169", "isVIP": 1}, // 红色景观树：isVIP 数字 1 → 排除
			{"id": "256"}, // 石竹花（:6257）：无 VIP/Mill，但 256 ∈ exclude_seeds
			{"id": "30001", "isMill": "1"} // isMill "1" → 排除（真实配置无此档，钉 :107 分支）
		]);
		pinParams({"exclude_seeds": "256,261,395"}); // nc_addon.php:106 前 3 项

		var keep1 = new Seed({"cId": 1});
		var keep101 = new Seed({"cId": 101});
		var dropVip = new Seed({"cId": 169});
		var dropExcluded = new Seed({"cId": 256});
		var dropMill = new Seed({"cId": 30001});
		var dropUnknown = new Seed({"cId": 777}); // 配置缺失

		var fired = 0;
		model.addEventListener(LevelUpModel.EVENT_SEEDS_DATA_LOADED, function(e:Event) fired++);
		model.onGetSeedsInfo(fakeSeedEvent([keep1, dropVip, dropExcluded, keep101, dropMill, dropUnknown]));

		Assert.equals(2, model.m_seeds.length);
		Assert.equals(keep1, model.m_seeds[0]); // :109 推入 VO 实体本身，顺序保持
		Assert.equals(keep101, model.m_seeds[1]);
		Assert.isFalse(model._loading); // :93 应答先复位加载位
		Assert.equals(1, fired); // :114 派发一次 EVENT_SEEDS_DATA_LOADED
	}

	// :96-98 应答 data 为 null（getVOData null）直接 return：不建列表、不派发
	public function test_onGetSeedsInfo_with_null_data_returns_early() {
		model.onGetSeedsInfo(fakeSeedEvent(null));
		Assert.isNull(model.m_seeds);
	}

	// :51-67 exclude_seeds 首次调用拆分并缓存（:54 只在 _notShowIdArr 为
	// null 时读配置）；配置换掉后缓存不重建
	public function test_isNotShow_splits_exclude_list_once_and_caches() {
		pinParams({"exclude_seeds": "256,261"});
		Assert.isTrue(model.isNotShow("256"));
		Assert.isFalse(model.isNotShow("100"));
		Assert.isFalse(model.isNotShow("26")); // 逐项精确匹配，非子串

		pinParams({"exclude_seeds": "100"}); // 缓存已建，改配置不生效
		Assert.isFalse(model.isNotShow("100"));
		Assert.isTrue(model.isNotShow("256"));
	}

	// :36-38 getPanelURL = secondList 里 levelUpUI 的 src（nc_addon.php:267；
	// appImgPrefix 空 → 不改写）；:46-48 getYellowURL = vipSeedLink
	// （nc_addon.php:58）；:69-71 getLevelUpPicURL = 硬编码路径
	public function test_url_assembly_from_config() {
		Settings.getInstance().m_configDataModel = new FakeConfigModel({
			"secondList": [{"id": "levelUpUI", "src": "module/levelup/levelUpUI_v_1.swf"}]
		});
		pinParams({"vipSeedLink": "tools.php?mod=vip"});
		Assert.equals("module/levelup/levelUpUI_v_1.swf", model.getPanelURL());
		Assert.equals("tools.php?mod=vip", model.getYellowURL());
		Assert.equals("module/ui/icons/levelUp.jpg", model.getLevelUpPicURL());
	}

	// :118-120 isYellow = Session.isMeVIP（Session.as:349-358 host._yellowstatus > 0）
	public function test_isYellow_follows_session_host_yellowstatus() {
		var session = Session.getInstance();
		var saved = session.host;
		var host = new Player({});
		host._yellowstatus = 0;
		session.host = host;
		Assert.isFalse(model.isYellow());
		host._yellowstatus = 3;
		Assert.isTrue(model.isYellow());
		session.host = saved; // Session 全局单例，复位
	}

	// —— 工具 ——

	static function pinParams(params:Dynamic):Void {
		Settings.getInstance().loadLocalSettings(params);
	}

	static function pinCrops(crops:Array<Dynamic>):Void {
		Settings.getInstance().m_configDataModel = new FakeConfigModel({"crops": crops});
	}

	// shop seed 应答：result 直接是 VO 数组（NetHelper.getVOData 的 Array 分支）
	static function fakeSeedEvent(seeds:Array<Dynamic>):CommandEvent {
		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.result = seeds;
		return ev;
	}
}

/**
 * 测试用 IModel：getData 按表名取 Reflect 字段，其余 no-op（Settings 只经
 * getData 读配置：getCropByID :376-396、getSecondUrl :149-165）。
 */
private class FakeConfigModel implements IModel {
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
