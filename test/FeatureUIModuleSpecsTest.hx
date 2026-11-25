package;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import utest.Assert;

/**
 * 功能 UI swf 规格提取的契约门（issue #66，pipeline:spec；镜像 #30 的
 * farm-shop-ui 四件套验收，三个新清单到 2026-11-25 为止都不存在，本门
 * write-tests 阶段对缺失文件失败，extract 阶段交付后转绿）。
 *
 * 三个用户可到达、实现全在独立 swf、此前从未反编译的功能：openfl 的 swf
 * 库只画时间轴不执行其 ABC——功能当前是死的（#30 shop/warehouse/pool/
 * decorate、#65 help.swf 同族）。反编译产物已随前置 commit 落地
 * （scripts/decompile-legacy.sh main_swfs +cards_v_1/quickshoot_v_0/
 * WildShellNc_v_5 三件，产物 legacy/decompiled/{cards_v_1,quickshoot_v_0,
 * WildShellNc_v_5}/，baseline tracked → #66）。本门钉 issue #66 的交付物：
 *
 *   1. spec/modules/cards-game-ui.json / quickshoot-ui.json /
 *      wild-shell-ui.json（issue #66 建议命名，无成文规范时以此为准）：
 *      顶层形状镜像 #30 四清单（version:1、module、swf、description、
 *      sources、notes、counts:{classes}、classes，见 farm-shop-ui.json）；
 *      条目格式同 S4（#5）：{path, class, swf, subsystem, loc, mods,
 *      assets, interactions, cross_module_imports}，无内容的字段可省
 *      （farm-shop-ui 的 entities.AdItem 即省 cross_module_imports）。
 *      验收「三个清单条目全部能指出处」按双向对账钉死：条目 path ↔
 *      legacy/decompiled/<swf>/scripts/ 的 .as 全集双射（每类恰一册，
 *      不多报不漏报），class 字段与 path 互推。
 *
 *   2. spec/swf-inventory.json 三件增补 code 块。形态出处是 commit
 *      84c203bb（#30 的交付形态），不是当前文件——#30 给 shop_v_7 /
 *      warehouse_v_23 / pool_v_13 / decorate_v_0 四件写的 code 块已被
 *      399a5faa（2026-11-24 13:29，github-actions「反编译主代码 swf +
 *      资产清单」）的 CI 再生成整体抹掉，当前文件没有任何条目带 code
 *      块，排障别去现文件找 shop_v_7。84c203bb 形态五键：{decompiled:
 *      "legacy/decompiled/<swf>/", symbol_class:<文档类>, classes:<类数>,
 *      module_spec:<清单路径>, note:<说明>}，note 文案「scripts 类数与
 *      module_spec 全类覆盖对账；SymbolClass 仅 frame0 文档类」；本门
 *      断言钉前四个结构键，note 是说明文字不钉内容。
 *      ⚠ 已知不稳定形态，风险链如实记下（未来红了照此定位，别再考古）：
 *      scripts/swf-inventory.py:115 用 json.dump 从零全量重写该文件，
 *      无任何合并/保留逻辑（scripts/ 人只读）；legacy-decompile.yml 由
 *      legacy/deploy/recompile-trigger 的 push 触发
 *      （.github/workflows/legacy-decompile.yml:11-12）。extract 按本门
 *      为三件手工恢复 84c203bb 形态、本门转绿之后，任何后续前置触发的
 *      重生成都会把它们再抹一次（issue #66「边界」已预告牧场批次前置），
 *      届时本门在 main 上无责变红——先查最近一次「反编译主代码 swf +
 *      资产清单」CI commit 是否又抹了 code 块，#30 四件正是这样死的
 *      （399a5faa 之后因无测试而无人察觉）。「生成器不保留手写 code
 *      块」的缺口须随本 issue 报给 spec/脚本所有者（scripts/ 人管），
 *      由人决定改生成器合并逻辑还是换存放位置；人裁决前按 84c203bb
 *      形态验收。
 *
 *   3. spec/modules/_index.json external 分组沿用 #30 的设计：805 校验
 *      不动（counts_check.total==805、sum_equals_805，功能 swf 另计），
 *      external.swfs 增三键（module_spec/classes/document_class/pull，
 *      pull 回指 main3 侧反射入口），external.total_classes = 77（#30 四件
 *      25+29+14+9）+ 5 + 15 + 16 = 113 = Σ 各 swfs.classes；
 *      moduleList_reconciliation 的 Cards/Quick Shoot 两行从「不入类清单
 *      （activities 砍除）」改道新清单（nc_main.php:20/:21 仍是 source）。
 *
 *   4. mods 交叉引用（「逐一登记到清单 mods」）：三个 swf 控制器发起的
 *      服务端调用逐一登记（本类 EXPECTED 表逐 mod 给全推导链）；每条
 *      mod 在 spec/protocol.json entries.nc.mods 可解——键规则：无 act
 *      用 mod 本名，带 act 用 mod+'_'+act.toLowerCase()（如
 *      item_healthmode ← mod=item&act=healthMode，ScenarioRunnerContract
 *      Test:432 同款）；解不到 protocol 的必须带 note 说明不可达
 *      （farm-shop-ui 的 cgi_farm_tool_vip 先例：mync.php $mod_list 白名单
 *      外、无输出）。
 *      口径镜像 #30 四清单：mods 只收命令路由型调用（CommandDefs/
 *      CmdBeastDefs → ServerServices/BeastAPI 的 mod 通道）；swf 内直连
 *      网关的非命令调用不入 mods、按 deviations 流程另行登记——
 *      quickshoot 的照片上传 POST（QuickShootController.as:223-232，
 *      URLLoader 直连 _saveQuickShootUrl）即此形态，EXPECTED 表不收
 *      它不算漏报（#30 对直连 URLLoader/信标/window.open 零登记同款）。
 *
 *   5. cross_module_imports 值解析为既有模块名（spec/modules/<名>.json 的
 *      module 字段；farm-shop-ui 全部值如此，无悬空名）。
 *
 * 期望值出处（断言消息处再标一次）：
 *   - 类清单/类数：legacy/decompiled/<swf>/scripts/（issue #66 前置产物，
 *     FFDec 24.0.1 -export script：cards 5 类 / quickshoot 15 类 /
 *     WildShellNc 16 类；行数不属验收）。
 *   - 文档类：legacy/decompiled/<swf>/symbolclass/symbols.csv，三件均仅
 *     frame0 一个导出（CardsGameWrapper / QuickShootWrapper / WildShell）。
 *   - 拉起链：nc_main.php:20 Quick Shoot Module / :21 Cards Module；
 *     nc_addon.php:81 beastLoaderUrl=module/mc/farm/wild/WildShellNc_v_5.swf；
 *     main3 ModuleCardsGame.as:23、ModuleQuickShoot.as:29/:36、
 *     FarmApplication.as:270（getClass wild.com.Shell.WildShell）/:586
 *     （loadWildShell）/:766（_beast 到位触发）。
 *   - mod 推导链：EXPECTED_MODS 各 src 字段（swf 内调用点 → CommandDefs/
 *     CmdBeastDefs → ServerServices m_cmdMap / BeastAPI.postRequest →
 *     mync.php $mod_list）。
 *   - 协议权威：spec/protocol.json（S1，人审过；CLAUDE.md 依据优先级
 *     spec 高于反编译）。
 */
class FeatureUIModuleSpecsTest {
	// 三件套期望（issue #66 背景表 + 前置产物核对）
	static final SPECS:Array<SpecExpect> = [
		{
			file: "spec/modules/cards-game-ui.json",
			module: "cards-game-ui", // issue #66 建议命名
			swf: "cards_v_1",
			decompiledDir: "legacy/decompiled/cards_v_1",
			inventoryPath: "module/ui/cards_v_1.swf", // spec/swf-inventory.json path 值（web_root 相对）
			symbolClass: "module.cardsgame.CardsGameWrapper", // symbolclass/symbols.csv frame0
			// _index external.swfs.pull 须含的 main3 侧入口证据
			pullMustContain: ["ModuleCardsGame", "module.cardsgame.CardsGameController"],
			// 断言消息引用的完整拉起链
			entryChain: "nc_main.php:21 Cards Module → main3 ModuleCardsGame.as:23 Utils.getClass(module.cardsgame.CardsGameController)",
			mods: [
				{
					key: "cgi_farm_login_home",
					src: "CardsGameModel.as:44-47 cardsGameQuery() → CMD_GET_CARDSGAME_DATA(58)（main3 framework/net/CommandDefs.as:92）→ ServerServices.as:138 m_cmdMap mod=cgi_farm_login_home；mync.php:33 白名单整名"
				},
				{
					key: "cgi_farm_login_click",
					src: "CardsGameModel.as:49-52 refreshCardsGameData() → CMD_REFRESH_CARDSGAME_DATA(60)（CommandDefs.as:96）→ ServerServices.as:139；mync.php:34"
				},
				{
					key: "cgi_pasture_signin",
					src: "CardsGameModel.as:54-61 getReward() 与 :160-166 getBonusGift()（同 CMD 两形态）→ CMD_GET_CARDSGAME_REWARD(59)（CommandDefs.as:94）→ ServerServices.as:140；mync.php:35"
				},
				{
					key: "cgi_farm_login_draw",
					src: "CardsGameModel.as:77-82 ActivityClickGet(t) → CMD_GET_CARDSGAME_ACTIVITY(652)（CommandDefs.as:222）→ ServerServices.as:175；mync.php $mod_list 无 cgi_farm_login_draw 整名（白名单未收录，dispatch 不命中无输出）→ 本部署不可达，登记须带 note（farm-shop-ui 的 cgi_farm_tool_vip 同款）"
				}
			]
		},
		{
			file: "spec/modules/quickshoot-ui.json",
			module: "quickshoot-ui", // issue #66 建议命名
			swf: "quickshoot_v_0",
			decompiledDir: "legacy/decompiled/quickshoot_v_0",
			inventoryPath: "module/ui/quickshoot_v_0.swf",
			symbolClass: "module.quickshoot.QuickShootWrapper",
			// ModuleQuickShoot 反射拉两个控制器（:29 QuickShootController、
			// :36 HealthController——健康模式也住在这个 swf 里）
			pullMustContain: ["ModuleQuickShoot", "module.quickshoot.QuickShootController", "module.health.HealthController"],
			entryChain: "nc_main.php:20 Quick Shoot Module → main3 ModuleQuickShoot.as:29/:36 Utils.getClass(module.quickshoot.QuickShootController / module.health.HealthController)",
			mods: [
				{
					key: "item_healthmode",
					src: "HealthModel.as:60-67 openHealthMode()（{time}）与 :203-210 closeHealthMode()（{close:1}）→ CMD_OPEN_HEALTH(110)（CommandDefs.as:154）→ ServerServices.as:121 m_cmdMap mod=item&act=healthMode；mync.php:60 白名单整名 item_healthmode（键规则 mod+'_'+act 小写）"
				}
			]
		},
		{
			file: "spec/modules/wild-shell-ui.json",
			module: "wild-shell-ui", // issue #66 建议命名
			swf: "WildShellNc_v_5",
			decompiledDir: "legacy/decompiled/WildShellNc_v_5",
			inventoryPath: "module/mc/farm/wild/WildShellNc_v_5.swf",
			symbolClass: "wild.com.Shell.WildShell",
			// 农场侧壳不走 nc_main moduleList：FarmApplication.loadWildShell
			// 按 beastLoaderUrl（nc_addon.php:81）加载，onWildComplete 反射
			pullMustContain: ["FarmApplication", "wild.com.Shell.WildShell"],
			entryChain: "nc_addon.php:81 beastLoaderUrl → main3 FarmApplication.as:586 loadWildShell（:766 _beast 到位触发）→ :270 Utils.getClass(wild.com.Shell.WildShell)",
			mods: [
				{
					key: "cgi_farm_hpage_beast",
					src: "CmdSetup.as:82-88 updateServer() _API.postRequest(cgi_farm_hpage_beast,{isfarm,ownerId}) → main3 framework/api/beast/BeastAPI.as:503 postRequest → CmdBeastDefs.as:49 cgi[CMD_WILD_HPAGE_BEAST(10011)]；mync.php:124 白名单整名"
				},
				{
					key: "cgi_farm_beast_getnick",
					src: "CmdSetup.as:144-157 getNick() _API.postRequest(cgi_farm_beast_getnick,{ownerId,isfarm}) → BeastAPI.as:503 → CmdBeastDefs.as:50 cgi[CMD_WILD_GET_NICK(10012)]；mync.php:113/:125 白名单整名"
				}
			]
		}
	];

	// #30 四件已入 external 分组的类数（25+29+14+9=77，_index external
	// .total_classes 现值）；本 issue 三件 5+15+16=36，合计 113
	static final EXISTING_EXTERNAL_TOTAL:Int = 77;
	static final EXPECTED_EXTERNAL_TOTAL:Int = 113;

	// 805 对账口径不动（issue #66 要什么 3：805 校验不动，功能 swf 另计）
	static final MAIN_TOTAL:Int = 805;

	static final MODULES_DIR:String = "spec/modules";
	static final INDEX_PATH:String = "spec/modules/_index.json";
	static final INVENTORY_PATH:String = "spec/swf-inventory.json";
	static final PROTOCOL_PATH:String = "spec/protocol.json";

	public function new() {}

	// ------------------------------------------------------------------
	// 交付物 1：三清单本体

	// 三清单存在且顶层形状镜像 #30（version/module/swf/description/
	// sources/notes/counts/classes），module/swf 与 issue #66 背景表一字不差
	public function test_module_lists_header_matches_issue66_naming_and_s4_shape() {
		for (e in SPECS) {
			var spec = loadJson(e.file, e.module + " 清单");
			if (spec == null) {
				continue;
			}
			Assert.equals(1, asInt(Reflect.field(spec, "version")), '${e.file} version==1（S4/#30 清单同款，checks/spec-valid.sh 只查 version 存在，取值由镜像形状钉死）');
			Assert.equals(e.module, Std.string(Reflect.field(spec, "module")), '${e.file} module==${e.module}（issue #66 建议命名）');
			Assert.equals(e.swf, Std.string(Reflect.field(spec, "swf")), '${e.file} swf==${e.swf}（swf 文件名去 .swf，条目 swf 字段同值）');
			Assert.isTrue(isNonEmptyString(Reflect.field(spec, "description")), '${e.file} description 非空（S4 顶层形状）');
			var sources:Array<Dynamic> = cast Reflect.field(spec, "sources");
			Assert.isTrue(sources != null && sources.length > 0, '${e.file} sources 非空数组（S4 顶层形状）');
			Assert.notNull(Reflect.field(spec, "notes"), '${e.file} notes 字段在（S4 顶层形状）');
			var classes:Array<Dynamic> = cast Reflect.field(spec, "classes");
			Assert.notNull(classes, '${e.file} classes 是数组');
			if (classes == null) {
				continue;
			}
			var counts:Dynamic = Reflect.field(spec, "counts");
			Assert.notNull(counts, '${e.file} counts 对象在（S4 顶层形状）');
			if (counts != null) {
				Assert.equals(classes.length, asInt(Reflect.field(counts, "classes")), '${e.file} counts.classes==${classes.length}（counts 与 classes 数组对账，#30 同款）');
			}
		}
	}

	// 验收「三个清单条目全部能指出处」的双向对账：每条 path 指向
	// legacy/decompiled/<swf>/scripts/ 下真实存在的 .as 且 class 字段与
	// path 互推；反编译产物逐类入册（不多报、不漏报、不重复）
	public function test_class_entries_cover_decompiled_scripts_exactly() {
		for (e in SPECS) {
			var spec = loadJson(e.file, e.module + " 清单");
			if (spec == null) {
				continue;
			}
			var classes:Array<Dynamic> = cast Reflect.field(spec, "classes");
			Assert.notNull(classes, '${e.file} classes 是数组');
			if (classes == null) {
				continue;
			}
			// 期望侧 = 前置反编译产物的 .as 全集（运行时读树，不靠手抄）
			var expected:Array<String> = [];
			collectAsFiles(e.decompiledDir + "/scripts", expected);
			Assert.isTrue(expected.length > 0, '${e.decompiledDir}/scripts/ 反编译产物在仓（issue #66 前置已落地；缺产物属 BLOCKED 项，不是本门的失败形态）');
			if (expected.length == 0) {
				continue;
			}
			var seen:Map<String, Bool> = new Map();
			for (c in classes) {
				var path:String = Std.string(Reflect.field(c, "path"));
				var cls:String = Std.string(Reflect.field(c, "class"));
				Assert.isTrue(isNonEmptyString(path), '${e.file} 条目 path 非空');
				Assert.isTrue(isNonEmptyString(cls), '${e.file} 条目 class 非空');
				Assert.isTrue(path.indexOf(e.decompiledDir + "/scripts/") == 0, '${e.file} ${cls} path 指向 ${e.decompiledDir}/scripts/（issue #66 验收：出处是 legacy/decompiled/<swf>/scripts/ 路径）, got ${path}');
				Assert.isTrue(FileSystem.exists(path), '${e.file} ${cls} path 存在于仓：${path}');
				Assert.equals(e.decompiledDir + "/scripts/" + cls.split(".").join("/") + ".as", path, '${e.file} ${cls} class 字段与 path 互推（包路径 ↔ 目录，S4 条目同款）');
				Assert.equals(e.swf, Std.string(Reflect.field(c, "swf")), '${e.file} ${cls} swf==${e.swf}');
				Assert.isFalse(seen.exists(path), '${e.file} ${path} 重复登记（一类一册）');
				seen.set(path, true);
			}
			for (p in expected) {
				Assert.isTrue(seen.exists(p), '${e.file} 漏报：${p} 未登记（issue #66 前置产物逐类入册，FFDec -export script 一类一文件）');
			}
		}
	}

	// 清单 sources 明写反编译产物出处（issue #66 要什么 1：出处指
	// legacy/decompiled/<swf>/scripts/）
	public function test_sources_cite_the_decompiled_tree() {
		for (e in SPECS) {
			var spec = loadJson(e.file, e.module + " 清单");
			if (spec == null) {
				continue;
			}
			var sources:Array<Dynamic> = cast Reflect.field(spec, "sources");
			Assert.notNull(sources, '${e.file} sources 是数组');
			if (sources == null) {
				continue;
			}
			var cites = false;
			for (s in sources) {
				if (Std.string(s).indexOf(e.decompiledDir) >= 0) {
					cites = true;
				}
			}
			Assert.isTrue(cites, '${e.file} sources 至少一条指 ${e.decompiledDir}/（#30 同款：farm-shop-ui sources 第 2 条指 legacy/decompiled/shop_v_7/scripts/）');
		}
	}

	// ------------------------------------------------------------------
	// 交付物 4：mods 交叉引用

	// 三个 swf 控制器发起的服务端调用逐一登记（EXPECTED 表 = 反编译源码
	// 里全部 sendRequest/postRequest 形态的推导终点；登记进清单任意类的
	// mods 即算——#30 把 ShopModel 的 mod 记在发调类条目上）
	public function test_controller_server_calls_are_registered_in_list_mods() {
		for (e in SPECS) {
			var spec = loadJson(e.file, e.module + " 清单");
			if (spec == null) {
				continue;
			}
			var classes:Array<Dynamic> = cast Reflect.field(spec, "classes");
			Assert.notNull(classes, '${e.file} classes 是数组');
			if (classes == null) {
				continue;
			}
			var registered:Array<String> = [];
			for (c in classes) {
				var mods:Array<Dynamic> = cast Reflect.field(c, "mods");
				if (mods == null) {
					continue;
				}
				for (m in mods) {
					var mod:String = asOptString(Reflect.field(m, "mod"));
					if (mod != null) {
						registered.push(modKey(mod, asOptString(Reflect.field(m, "act"))));
					}
				}
			}
			for (x in e.mods) {
				Assert.isTrue(registered.indexOf(x.key) >= 0, '${e.file} 登记了 ${x.key}（issue #66「逐一登记」；${x.src}）');
			}
		}
	}

	// 每条 mods 登记可判定：via 恒填（调用点推导链）；mod 在
	// spec/protocol.json entries.nc.mods 可解（S1 对照），解不到协议的
	// 必须带 note 说明（farm-shop-ui 的 cgi_farm_tool_vip 先例：白名单外
	// mod 无输出不可达）；无 mod 的登记（外部网关 raw）同样必须带 note
	public function test_registered_mods_resolve_to_protocol_or_carry_note() {
		var protocol = loadJson(PROTOCOL_PATH, "S1 协议清单");
		Assert.notNull(protocol, "spec/protocol.json 可加载（S1 既有交付物）");
		if (protocol == null) {
			return;
		}
		var protocolMods:Dynamic = Reflect.field(Reflect.field(Reflect.field(protocol, "entries"), "nc"), "mods");
		Assert.notNull(protocolMods, "spec/protocol.json entries.nc.mods 在");
		if (protocolMods == null) {
			return;
		}
		for (e in SPECS) {
			var spec = loadJson(e.file, e.module + " 清单");
			if (spec == null) {
				continue;
			}
			var classes:Array<Dynamic> = cast Reflect.field(spec, "classes");
			if (classes == null) {
				continue;
			}
			for (c in classes) {
				var cls = Std.string(Reflect.field(c, "class"));
				var mods:Array<Dynamic> = cast Reflect.field(c, "mods");
				if (mods == null) {
					continue;
				}
				for (m in mods) {
					Assert.isTrue(isNonEmptyString(Reflect.field(m, "via")), '${e.file} ${cls} mods 登记带非空 via（调用点推导链，#30 ShopModel.mods 条目同款）');
					var mod:String = asOptString(Reflect.field(m, "mod"));
					var note:String = asOptString(Reflect.field(m, "note"));
					if (mod == null) {
						Assert.isTrue(isNonEmptyString(note), '${e.file} ${cls} 无 mod 的登记必须带 note 说明（外部网关 raw 形态，#30 ShopModel 的 gdt_cookie.fcg 条目同款 {note,raw,via}）');
						continue;
					}
					var key = modKey(mod, asOptString(Reflect.field(m, "act")));
					var inProtocol = Reflect.hasField(protocolMods, key);
					if (!inProtocol) {
						Assert.isTrue(isNonEmptyString(note), '${e.file} ${cls} mod=${key} 不在 spec/protocol.json entries.nc.mods（mync.php $$mod_list 白名单外的 S1 缺条目）——登记必须带 note 说明不可达性（farm-shop-ui 的 cgi_farm_tool_vip 先例）');
					}
				}
			}
		}
	}

	// ------------------------------------------------------------------
	// 交付物 2：swf-inventory code 块

	// 三件在 spec/swf-inventory.json 的条目带 code 块，形态出处 commit
	// 84c203bb（#30 的交付；399a5faa CI 再生成后当前文件已无 code 块先例
	// 可查，抹除链见类头注释交付物 2），类数与清单对账、module_spec 指回
	// 真实存在的清单文件
	public function test_swf_inventory_code_blocks_reconcile_three_swfs() {
		var inventory = loadJson(INVENTORY_PATH, "swf-inventory");
		Assert.notNull(inventory, "spec/swf-inventory.json 可加载（既有交付物）");
		if (inventory == null) {
			return;
		}
		var entries:Array<Dynamic> = cast Reflect.field(inventory, "swfs");
		Assert.notNull(entries, "spec/swf-inventory.json swfs 是数组");
		if (entries == null) {
			return;
		}
		for (e in SPECS) {
			var spec = loadJson(e.file, e.module + " 清单");
			if (spec == null) {
				continue;
			}
			var row:Dynamic = null;
			for (s in entries) {
				if (Std.string(Reflect.field(s, "path")) == e.inventoryPath) {
					row = s;
					break;
				}
			}
			Assert.notNull(row, 'spec/swf-inventory.json 有 path==${e.inventoryPath} 的条目（web_root 相对，legacy/deploy/QFarmFlash/source/core/module/ 下）');
			if (row == null) {
				continue;
			}
			var code:Dynamic = Reflect.field(row, "code");
			Assert.notNull(code, '${e.inventoryPath} 带 code 块（形态出处 commit 84c203bb——#30 的交付形态；当前文件经 399a5faa CI 再生成已无 code 块先例，抹除链见类头注释交付物 2）');
			if (code == null) {
				continue;
			}
			Assert.equals("legacy/decompiled/" + e.swf + "/", Std.string(Reflect.field(code, "decompiled")), '${e.inventoryPath} code.decompiled 指反编译产物目录（84c203bb 四件同值形态）');
			Assert.equals(e.symbolClass, Std.string(Reflect.field(code, "symbol_class")), '${e.inventoryPath} code.symbol_class==${e.symbolClass}（${e.decompiledDir}/symbolclass/symbols.csv 仅 frame0 一个导出）');
			var counts:Dynamic = Reflect.field(spec, "counts");
			Assert.notNull(counts, '${e.file} counts 在（前置对账用）');
			if (counts != null) {
				Assert.equals(asInt(Reflect.field(counts, "classes")), asInt(Reflect.field(code, "classes")), '${e.inventoryPath} code.classes 与 ${e.file} counts.classes 对账（84c203bb 的 note 文案：「scripts 类数与 module_spec 全类覆盖对账」）');
			}
			var moduleSpec = Std.string(Reflect.field(code, "module_spec"));
			Assert.equals(e.file, moduleSpec, '${e.inventoryPath} code.module_spec==${e.file}');
			Assert.isTrue(FileSystem.exists(moduleSpec), 'code.module_spec 指回真实存在的清单文件：${moduleSpec}');
		}
	}

	// ------------------------------------------------------------------
	// 交付物 3：_index external 分组

	// external.swfs 增三键（module_spec/classes/document_class/pull——pull
	// 回指 main3 侧反射入口链），total_classes 三处对账：
	// Σ 各 swfs.classes == external.total_classes == 113（77+36）；
	// 805 校验口径不动
	public function test_index_external_group_covers_three_swfs_and_keeps_805_intact() {
		var index = loadJson(INDEX_PATH, "S4 模块清单索引");
		Assert.notNull(index, "spec/modules/_index.json 可加载（既有交付物）");
		if (index == null) {
			return;
		}
		var external:Dynamic = Reflect.field(index, "external");
		Assert.notNull(external, "_index.json external 分组在（#30 设计）");
		if (external == null) {
			return;
		}
		var swfs:Dynamic = Reflect.field(external, "swfs");
		Assert.notNull(swfs, "external.swfs 在（#30 设计：功能 swf 按名分组）");
		if (swfs == null) {
			return;
		}
		// 三件的新键 + 四件既有键一并对账 total
		var sum = 0;
		for (name in Reflect.fields(swfs)) {
			var row:Dynamic = Reflect.field(swfs, name);
			var n = asInt(Reflect.field(row, "classes"));
			Assert.isTrue(n > 0, 'external.swfs.${name}.classes 为正整数（类数对账口径）');
			if (n > 0) {
				sum += n;
			}
		}
		var total = asInt(Reflect.field(external, "total_classes"));
		Assert.equals(sum, total, 'external.total_classes==Σ 各 swfs.classes=${sum}（#30 对账口径：total=Σ 各清单 counts.classes）');
		Assert.equals(EXPECTED_EXTERNAL_TOTAL, total, 'external.total_classes==${EXPECTED_EXTERNAL_TOTAL}（#30 四件 ${EXISTING_EXTERNAL_TOTAL} + cards 5 + quickshoot 15 + WildShellNc 16；issue #66 三件并入）');
		for (e in SPECS) {
			var spec = loadJson(e.file, e.module + " 清单");
			if (spec == null) {
				continue;
			}
			var counts:Dynamic = Reflect.field(spec, "counts");
			Assert.notNull(counts, '${e.file} counts 在');
			if (counts == null) {
				continue;
			}
			var row:Dynamic = Reflect.field(swfs, e.swf);
			Assert.notNull(row, 'external.swfs.${e.swf} 在（issue #66 三件并入功能 swf 分组）');
			if (row == null) {
				continue;
			}
			Assert.equals(e.file, Std.string(Reflect.field(row, "module_spec")), 'external.swfs.${e.swf}.module_spec==${e.file}');
			Assert.equals(asInt(Reflect.field(counts, "classes")), asInt(Reflect.field(row, "classes")), 'external.swfs.${e.swf}.classes 与 ${e.file} counts.classes 对账');
			Assert.equals(e.symbolClass, Std.string(Reflect.field(row, "document_class")), 'external.swfs.${e.swf}.document_class==${e.symbolClass}（symbolclass frame0 文档类，#30 四件同字段）');
			var pull = Std.string(Reflect.field(row, "pull"));
			Assert.isTrue(isNonEmptyString(pull), 'external.swfs.${e.swf}.pull 非空（#30 设计：拉起链记在 pull）');
			for (needle in e.pullMustContain) {
				Assert.isTrue(pull.indexOf(needle) >= 0, 'external.swfs.${e.swf}.pull 含「${needle}」（cross_module_imports 回指 main3 侧入口类，issue #66 要什么 4；${e.entryChain}）');
			}
		}
		// 805 校验不动（issue #66 要什么 3：功能 swf 另计）
		var countsCheck:Dynamic = Reflect.field(index, "counts_check");
		Assert.notNull(countsCheck, "_index.json counts_check 在（805 对账）");
		if (countsCheck != null) {
			Assert.equals(MAIN_TOTAL, asInt(Reflect.field(countsCheck, "total")), 'counts_check.total==${MAIN_TOTAL}（issue #66：805 校验不动——只覆盖 main3+Master2，功能 swf 另计）');
			Assert.isTrue(Reflect.field(countsCheck, "sum_equals_805") == true, "counts_check.sum_equals_805==true（同上，main3+Master2 的对账口径不受本 issue 影响）");
		}
	}

	// moduleList_reconciliation 的 Cards/Quick Shoot 两行改道新清单：现状
	// 是「不入类清单：activities 砍除模块的 UI（UI swf 未反编译、不移植）」
	// ——本 issue 反编译并提取后该说法失效，两行 disposition 指向新清单
	// （nc_main.php:20/:21 的 source 不变）
	public function test_modulelist_reconciliation_routes_cards_and_quickshoot_to_new_lists() {
		var index = loadJson(INDEX_PATH, "S4 模块清单索引");
		Assert.notNull(index, "spec/modules/_index.json 可加载（既有交付物）");
		if (index == null) {
			return;
		}
		var external:Dynamic = Reflect.field(index, "external");
		Assert.notNull(external, "_index.json external 分组在（#30 设计）");
		if (external == null) {
			return;
		}
		var recon:Array<Dynamic> = cast Reflect.field(external, "moduleList_reconciliation");
		Assert.notNull(recon, "external.moduleList_reconciliation 在（nc_main.php moduleList 逐行对账）");
		if (recon == null) {
			return;
		}
		var cases:Array<{url:String, name:String, src:String, sourceRef:String}> = [
			{url: "module/ui/quickshoot_v_0.swf", name: "quickshoot-ui", src: "nc_main.php:20 Quick Shoot Module", sourceRef: "nc_main.php:20"},
			{url: "module/ui/cards_v_1.swf", name: "cards-game-ui", src: "nc_main.php:21 Cards Module", sourceRef: "nc_main.php:21"}
		];
		for (c in cases) {
			var row:Dynamic = null;
			for (r in recon) {
				if (Std.string(Reflect.field(r, "url")) == c.url) {
					row = r;
					break;
				}
			}
			Assert.notNull(row, 'moduleList_reconciliation 有 url==${c.url} 的行（${c.src}）');
			if (row == null) {
				continue;
			}
			var disposition = Std.string(Reflect.field(row, "disposition"));
			Assert.isTrue(disposition.indexOf(c.name) >= 0, '${c.url} 的 disposition 指向 ${c.name} 清单（现状「不入类清单：activities 砍除模块的 UI（UI swf 未反编译、不移植）」随本 issue 反编译+提取失效，#30 的 Shop/Pool 行形态是「farm-shop-ui（25 类）」）');
			Assert.isTrue(Std.string(Reflect.field(row, "source")).indexOf(c.sourceRef) >= 0, '${c.url} 的 source 仍含 ${c.sourceRef}（issue #66 要什么 3：「nc_main.php:20/:21 仍是 source」，改道只改 disposition 的去向）');
		}
	}

	// ------------------------------------------------------------------
	// 交付物 1（cross_module_imports 字段）：引用既有模块名

	// cross_module_imports 值解析为既有模块名（spec/modules/<名>.json 的
	// module 字段）——#30 farm-shop-ui 全部值如此（farm-basic/activities/
	// water…），不允许悬空名；字段缺省（无跨模块引用）不判红
	public function test_cross_module_imports_resolve_to_module_names() {
		var names = moduleNames();
		Assert.isTrue(names.length > 0, "spec/modules/ 下能枚举出模块名（既有交付物）");
		for (e in SPECS) {
			var spec = loadJson(e.file, e.module + " 清单");
			if (spec == null) {
				continue;
			}
			var classes:Array<Dynamic> = cast Reflect.field(spec, "classes");
			if (classes == null) {
				continue;
			}
			for (c in classes) {
				var cls = Std.string(Reflect.field(c, "class"));
				var xs:Array<Dynamic> = cast Reflect.field(c, "cross_module_imports");
				if (xs == null) {
					continue;
				}
				for (v in xs) {
					Assert.isTrue(names.indexOf(Std.string(v)) >= 0, '${e.file} ${cls} cross_module_imports 值「${v}」是既有模块名（spec/modules/<名>.json 的 module 字段；#30 先例：swf 加载进 main3 子 ApplicationDomain，跨 swf 依赖按模块记录）');
				}
			}
		}
	}

	// ------------------------------------------------------------------
	// helpers

	/** utest 的 Assert 记录后不中断方法（#17 同款）：缺文件 fail 后返回
	 * null，调用方空值守卫收尾——write-tests 阶段三清单缺失即此失败形态 */
	static function loadJson(path:String, what:String):Dynamic {
		if (!FileSystem.exists(path)) {
			Assert.fail('${what}缺失：${path}（issue #66 交付物，由 extract 阶段生成，格式契约见本类头注释）');
			return null;
		}
		return Json.parse(File.getContent(path));
	}

	/** 递归收集 dir 下的 *.as（FFDec -export script 一类一文件） */
	static function collectAsFiles(dir:String, acc:Array<String>):Void {
		if (!FileSystem.exists(dir)) {
			return;
		}
		for (name in FileSystem.readDirectory(dir)) {
			var p = dir + "/" + name;
			if (FileSystem.isDirectory(p)) {
				collectAsFiles(p, acc);
			} else if (StringTools.endsWith(p, ".as")) {
				acc.push(p);
			}
		}
	}

	/** spec/modules/<名>.json 的 module 字段全集（含本 issue 三件自身） */
	static function moduleNames():Array<String> {
		var names:Array<String> = [];
		if (!FileSystem.exists(MODULES_DIR)) {
			return names;
		}
		for (f in FileSystem.readDirectory(MODULES_DIR)) {
			if (!StringTools.endsWith(f, ".json") || f == "_index.json") {
				continue;
			}
			var path = MODULES_DIR + "/" + f;
			var d:Dynamic = Json.parse(File.getContent(path));
			var m = asOptString(Reflect.field(d, "module"));
			if (m != null && names.indexOf(m) < 0) {
				names.push(m);
			}
		}
		return names;
	}

	/** protocol.json entries.nc.mods 的键规则：无 act 用 mod 本名；带 act
	 * 用 mod+'_'+act 小写（mync.php:60 整名 item_healthmode ←
	 * mod=item&act=healthMode；ScenarioRunnerContractTest:432 同款） */
	static function modKey(mod:String, act:String):String {
		if (act == null || act == "") {
			return mod;
		}
		return mod + "_" + act.toLowerCase();
	}

	static function isNonEmptyString(v:Dynamic):Bool {
		return v != null && Std.isOfType(v, String) && Std.string(v).length > 0;
	}

	/** JSON 数值在 eval/解析侧可能是 Int 或 Float，读经 Dynamic 再判 */
	static function asInt(v:Dynamic):Int {
		if (v == null) {
			return -1;
		}
		if (Std.isOfType(v, Int)) {
			return v;
		}
		if (Std.isOfType(v, Float)) {
			return Std.int(v);
		}
		if (Std.isOfType(v, String)) {
			return Std.parseInt(v);
		}
		return -1;
	}

	static function asOptString(v:Dynamic):String {
		if (v == null || !Std.isOfType(v, String)) {
			return null;
		}
		var s = Std.string(v);
		return s.length > 0 ? s : null;
	}
}

typedef SpecExpect = {
	file:String,
	module:String,
	swf:String,
	decompiledDir:String,
	inventoryPath:String,
	symbolClass:String,
	/** _index external.swfs[swf].pull 须含的 main3 侧入口证据 */
	pullMustContain:Array<String>,
	/** 反编译源码核实过的服务端调用（解析键 + 推导链） */
	mods:Array<ModExpect>,
	/** 断言消息里引用的 main3 侧拉起链（msg 用，非断言本体） */
	entryChain:String,
};

typedef ModExpect = {
	/** protocol.json entries.nc.mods 解析键 */
	key:String,
	/** 调用点 → CommandDefs/CmdBeastDefs → ServerServices/BeastAPI → mync.php */
	src:String,
};
