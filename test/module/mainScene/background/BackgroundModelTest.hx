package module.mainScene.background;

import common.Consts;
import common.GetCropID;
import module.FarmApplication;
import utest.Assert;

/**
 * BackgroundModel 装饰槽位纯逻辑（issue #8）。issue 文案把 BackgroundModel
 * 猜成「天气/时间」，原版实际是装饰数据模型（背景/房子/栅栏/狗屋/木牌五槽
 * + 变更事件）——以 legacy 为准。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/module/mainScene/background/
 * BackgroundModel.as（槽位常量 :13-25、INDEX_TO_TYPE_MAP :35-58、
 * TYPE_TO_INDEX_MAP :60-83、removeDecor :85-108、changeDecor :110-151、
 * setDecors :153-162、buildDecor :174-218、decors 存取 :164-172）。
 *
 * url 相关断言依赖 GetCropID 的配置缺失分支：给 GetCropID.theApp 装一个空
 * model 的 app（真游戏 Main 启动时设置），idToDiyUrl2/idToBoardUrl 里
 * `theApp.model.getData("item_info"/"boards") == null → ""`（GetCropID.as
 * 各自开头的守卫段）——无配置环境下 url 恒 ""。装饰配置命中后返回真实 url、
 * changeDecor 落槽写 Session.sceneDecorates 的成功路径属资源链，不在纯逻辑
 * 单测里证明（记 issue #8 PR 说明）。
 */
class BackgroundModelTest {
	public function new() {}

	// GetCropID.theApp 只在 module/Main 启动时设置（Main.hx:246 对应
	// Main.as）；单测里装一个 model 为空 AppData 的 app，让 url 守卫走
	// 「配置缺失 → ""」分支（AS3 里 theApp 未设置时 theApp.model 会直接
	// ReferenceError，不是返回 ""）
	static function pinGetCropID():Void {
		GetCropID.theApp = new FarmApplication();
	}

	// 收集 EVENT_DECORS_CHANGED 派发的 data（:107/:149/:161 的 {type}）
	static function listen(model:BackgroundModel):Array<Dynamic> {
		var events:Array<Dynamic> = [];
		model.addEventListener(BackgroundModel.EVENT_DECORS_CHANGED, function(e) events.push(e.data));
		return events;
	}

	// :35-58/:60-83：五槽 ↔ Consts.DECOR_*（Consts.as:428-438）一一对应，
	// 表外下标/类型 -1；DECOR_DOG(8) 是 NPC 不是装饰槽，不在表里
	public function test_slot_type_maps() {
		Assert.equals(Consts.DECOR_BACKGROUND, BackgroundModel.INDEX_TO_TYPE_MAP(0));
		Assert.equals(Consts.DECOR_HOUSE, BackgroundModel.INDEX_TO_TYPE_MAP(1));
		Assert.equals(Consts.DECOR_FENCE, BackgroundModel.INDEX_TO_TYPE_MAP(2));
		Assert.equals(Consts.DECOR_DOGHOUSE, BackgroundModel.INDEX_TO_TYPE_MAP(3));
		Assert.equals(Consts.DECOR_BILLBOARD, BackgroundModel.INDEX_TO_TYPE_MAP(4));
		Assert.equals(-1, BackgroundModel.INDEX_TO_TYPE_MAP(5)); // DECOR_INDEX_MAX 起表外
		Assert.equals(0, BackgroundModel.TYPE_TO_INDEX_MAP(Consts.DECOR_BACKGROUND));
		Assert.equals(1, BackgroundModel.TYPE_TO_INDEX_MAP(Consts.DECOR_HOUSE));
		Assert.equals(2, BackgroundModel.TYPE_TO_INDEX_MAP(Consts.DECOR_FENCE));
		Assert.equals(3, BackgroundModel.TYPE_TO_INDEX_MAP(Consts.DECOR_DOGHOUSE));
		Assert.equals(4, BackgroundModel.TYPE_TO_INDEX_MAP(Consts.DECOR_BILLBOARD));
		Assert.equals(-1, BackgroundModel.TYPE_TO_INDEX_MAP(Consts.DECOR_DOG)); // :60-83 无此分支
		Assert.equals(-1, BackgroundModel.TYPE_TO_INDEX_MAP(0)); // 表外类型
	}

	// setDecors :153-162 + buildDecor :174-218：items 下发建五槽定序数组
	//（BG/HOUSE/FENCE/DOGHOUSE/BOARD，:156-160）；present 键 → {id:itemId,
	// type:键字符串, url}（:183-200）；缺 BG → {id:-1, url:idToDiyUrl2("1")}
	//（:202-209，theApp null → ""）；缺其余 → {id:-1, url:""}（:210-217）；
	// 完成派发 {type:-1}（:161）
	public function test_setDecors_builds_five_slots_in_fixed_order() {
		pinGetCropID();
		var model = new BackgroundModel();
		var events = listen(model);
		model.setDecors({"3": {itemId: 7}, "9": {itemId: 12}});
		var decors:Array<Dynamic> = model.decors;
		Assert.equals(5, decors.length);
		// 槽 0 BG 缺省（:202-209）
		Assert.equals(-1, Reflect.field(decors[0], "id"));
		Assert.equals("1", Reflect.field(decors[0], "type"));
		Assert.equals("", Reflect.field(decors[0], "url")); // idToDiyUrl2("1") 无配置 → ""
		// 槽 1 HOUSE 缺省（:210-217）
		Assert.equals(-1, Reflect.field(decors[1], "id"));
		Assert.equals("2", Reflect.field(decors[1], "type"));
		Assert.equals("", Reflect.field(decors[1], "url"));
		// 槽 2 FENCE present（:183-200）
		Assert.equals(7, Reflect.field(decors[2], "id"));
		Assert.equals("3", Reflect.field(decors[2], "type"));
		Assert.equals("", Reflect.field(decors[2], "url")); // idToDiyUrl2(7) 无配置 → ""
		// 槽 3 DOGHOUSE 缺省
		Assert.equals(-1, Reflect.field(decors[3], "id"));
		Assert.equals("4", Reflect.field(decors[3], "type"));
		Assert.equals("", Reflect.field(decors[3], "url"));
		// 槽 4 BILLBOARD present（:187-190 走 idToBoardUrl）
		Assert.equals(12, Reflect.field(decors[4], "id"));
		Assert.equals("9", Reflect.field(decors[4], "type"));
		Assert.equals("", Reflect.field(decors[4], "url")); // idToBoardUrl(12) 无配置 → ""
		Assert.equals(1, events.length);
		Assert.equals(-1, Reflect.field(events[0], "type"));
	}

	// setDecors :153-162：入参 null 时 buildDecor 逐槽早退（:179-181），
	// decors 为空数组，事件照发（:161）
	public function test_setDecors_null_yields_empty_array_with_event() {
		var model = new BackgroundModel();
		var events = listen(model);
		model.setDecors(null);
		Assert.notNull(model.decors);
		Assert.equals(0, model.decors.length);
		Assert.equals(1, events.length);
		Assert.equals(-1, Reflect.field(events[0], "type"));
	}

	// removeDecor :85-108：非 BG 槽无条件写 {id:param1, url:""} 并派发
	// {type}（:105-107）；BG 槽要 idToDiyUrl2 非 ""（:100-103），无配置环境
	// url 恒 "" → 早退——槽不动也不派发
	public function test_removeDecor_writes_empty_url_for_non_bg_and_skips_bg_without_asset() {
		pinGetCropID();
		var model = new BackgroundModel();
		var events = listen(model);
		model.decors = [
			{id: 3, type: "1", url: "/bg.swf"},
			{id: 4, type: "2", url: "/house.swf"},
			{id: 5, type: "3", url: "/fence.swf"},
			{id: 6, type: "4", url: "/doghouse.swf"},
			{id: 7, type: "9", url: "/board.swf"}
		];
		// BG：theApp null → url "" → :100-103 早退
		model.removeDecor(9, Consts.DECOR_BACKGROUND);
		Assert.equals(0, events.length);
		Assert.equals("/bg.swf", Reflect.field(model.decors[0], "url")); // 槽未动
		// FENCE：直写 url ""/id 并派发 {type:3}
		model.removeDecor(5, Consts.DECOR_FENCE);
		Assert.equals(1, events.length);
		Assert.equals(Consts.DECOR_FENCE, Reflect.field(events[0], "type"));
		Assert.equals(5, Reflect.field(model.decors[2], "id"));
		Assert.equals("", Reflect.field(model.decors[2], "url"));
	}

	// changeDecor(-1) :119-124：先克隆存量槽再 removeDecor，返回移除前快照；
	// FENCE 的槽被清成 {id:-1, url:""}，BG 因 removeDecor 早退保持原值
	public function test_changeDecor_minus_one_returns_previous_slot_snapshot() {
		pinGetCropID();
		var model = new BackgroundModel();
		model.decors = [
			{id: 3, type: "1", url: "/bg.swf"},
			{id: -1, type: "2", url: ""},
			{id: 5, type: "3", url: "/fence.swf"},
			{id: -1, type: "4", url: ""},
			{id: -1, type: "9", url: ""}
		];
		var prev = model.changeDecor(-1, Consts.DECOR_FENCE);
		Assert.notNull(prev);
		Assert.equals(5, Reflect.field(prev, "id"));
		Assert.equals("/fence.swf", Reflect.field(prev, "url")); // 快照是移除前的
		Assert.equals(-1, Reflect.field(model.decors[2], "id")); // 槽被清
		Assert.equals("", Reflect.field(model.decors[2], "url"));
		var bgPrev = model.changeDecor(-1, Consts.DECOR_BACKGROUND);
		Assert.equals(3, Reflect.field(bgPrev, "id"));
		Assert.equals("/bg.swf", Reflect.field(bgPrev, "url")); // 快照仍有值
		Assert.equals("/bg.swf", Reflect.field(model.decors[0], "url")); // 槽未被动
	}

	// changeDecor :114-118/:134-137：TYPE_TO_INDEX_MAP 不认识的 type（含
	// DECOR_DOG）直接 null；url 解析为 ""（无配置）或与存量相同 →
	// 返回 null 且槽不动（真 id 换装的成功路径需配置资源，见类头注释）
	public function test_changeDecor_rejects_unknown_type_and_empty_url() {
		pinGetCropID();
		var model = new BackgroundModel();
		model.decors = [
			{id: -1, type: "1", url: ""},
			{id: -1, type: "2", url: ""},
			{id: 5, type: "3", url: "/fence.swf"},
			{id: -1, type: "4", url: ""},
			{id: -1, type: "9", url: ""}
		];
		Assert.isNull(model.changeDecor(7, 55)); // :115-118 表外
		Assert.isNull(model.changeDecor(7, Consts.DECOR_DOG)); // 不在槽表
		Assert.isNull(model.changeDecor(7, Consts.DECOR_FENCE)); // :132-137 url ""
		Assert.equals(5, Reflect.field(model.decors[2], "id")); // 槽未动
		Assert.equals("/fence.swf", Reflect.field(model.decors[2], "url"));
	}
}
