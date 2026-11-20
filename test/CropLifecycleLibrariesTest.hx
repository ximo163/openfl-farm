package;

import shim.LocalSwfLoader;
import sys.io.File;
import utest.Assert;

/**
 * 农场作物生命周期 + 看板的 swf ↔ 资产声明一致性门（issue #8 implement
 * visit 4 attempt 2）。**注册待 write-tests 阶段**（test/ 既有文件
 * append-only，TestMain 的 runner.addCase 行只能由该阶段补，见
 * handbook/lessons 的 append-only 条目；注册前由 CI web-smoke 的 404
 * 计数兜底，本文件用 /tmp 侧 harness 单跑过全绿）。
 *
 * attempt 1 的 CI 单条 404 根因：farmlandstatus 字母协议读反——a 才是
 * 作物号（farmlandstatus_getoutput.php:62 `"cId":' . $a`，b 是 cropStatus），
 * 快照 uid=1 四块在种地全是白萝卜 cId=2（initialized.sql:5718 status
 * `[{\"a\":2,\"b\":6,…},{\"a\":2,\"b\":1,…}×3,{\"a\":0,…}×2]`），不是
 * cId=1/6（前几轮把 b 当作物号，libraries.xml 错收了 Crop_1_1..4/
 * Crop_6_0..4 十档，本轮已按白萝卜生命周期改齐）。
 *
 * 数据链（期望值全部可指认）：
 * - cId=2 白萝卜（source/core/source/xml/mod/nc_data.php:6021）asset_id 只
 *   列 m1/m2/m3 = "5481"/"5482"/"5483"，无 m0/m4 → GetCropID.specialGrow 回
 *   SG_PUBLIC_SEED_PUBLIC_DEAD；
 * - assets 表（nc_data.php:3065-3067）`<asset id="5481" src="$url/module/
 *   ui/allcrops/Crop_2_1.swf"/>`（5482/5483 → Crop_2_2/2_3.swf）；
 * - GetCropID.getCropUrl/GetCropIDTest 同款折叠：3/4/5 档 → m3；0 档无 m0
 *   → 回退 cropUrl+publicCropPrefix+0 = Crop_1_0.swf；6 档无 m4 → 回退
 *   publicCropPrefix+4 = Crop_1_4.swf（Crop.as:93-99 的 _classStep 同折叠，
 *   4 档类名不可达；公共分支类名带未折叠档位 → Crop_1_4.swf 内导出符号是
 *   Crop_1_6，Crop.as:104/199）；
 * - 生长墙钟：cropGrow "7200,14400,25200,36000,36000,…"（nc_data.php:6021）
 *   按 plantTime=2026-11-17（快照 q 值）推进，CI ≥11-18 时四块地全在第 5 档
 *   → 冒烟窗口实际只拉 Crop_2_3（land0 b=6 成熟、lands1-3 b=1 生长，
 *   FarmLandModel.getOutputs 只对 step==5 && output==0 的 1..3 号地发
 *   farmlandstatus getOutput，与 attempt 1 CI 的三条 POST 吻合）；
 * - 看板：user_run.php:206 `if($list['activeItem'] > 0)` 补发 items 槽 9
 *   （快照 activeItem=90001）→ boards 90001（nc_data.php:5977）→ asset
 *   1719（nc_data.php:2260）`$url/module/ui/farm/diy/board/1.swf`。**本测试
 *   同时纠正 SceneDecorLibrariesTest 类头注释的「billboard=9 不在 uid=1
 *   数据里」——decorative 列确实没有 9，但 user_run 是按 activeItem 补发
 *   槽 9 的，看板在 uid=1 冒烟窗口内**（该文件 append-only 改不了，纠正
 *   落在这里和 handbook）。
 *
 * 三条不变式与 SceneDecorLibrariesTest 同式：URL 可被
 * LocalSwfLoader.libraryIdForUrl 映射成库名（看板因与 diy/1.swf 同名经
 * shim 特判消歧为 board_1）；库名在 libraries.xml 声明且 path 指对文件；
 * swf 路径在 assets/legacy-assets.txt 登记。
 */
@:access(shim.LocalSwfLoader)
class CropLifecycleLibrariesTest {
	// 绝对 URL 前缀：assets 表 src 带 $url，Utils.addPrefix 后是部署绝对
	// 形态。host 取占位值（映射只看 module/ 尾段）。
	static final CORE_URL:String = "http://page.host/home/qqfarm/core";

	// uid=1 白萝卜（cId=2）全生命周期会请求的作物 swf：档 0 公共种子、
	// 1/2/3 自家（3/4/5 折叠 3）、6 公共枯死（URL 折叠到 Crop_1_4.swf）。
	static final CROP_WINDOW:Array<{url:String, id:String}> = [
		{url: CORE_URL + "/module/ui/allcrops/Crop_1_0.swf", id: "Crop_1_0"}, // 档 0 公共种子
		{url: CORE_URL + "/module/ui/allcrops/Crop_2_1.swf", id: "Crop_2_1"}, // 档 1 发芽
		{url: CORE_URL + "/module/ui/allcrops/Crop_2_2.swf", id: "Crop_2_2"}, // 档 2 小叶子
		{url: CORE_URL + "/module/ui/allcrops/Crop_2_3.swf", id: "Crop_2_3"}, // 档 3/4/5 大叶子起（冒烟窗口实际拉起的唯一作物库）
		{url: CORE_URL + "/module/ui/allcrops/Crop_1_4.swf", id: "Crop_1_4"} // 档 6 公共枯死（导出符号 Crop_1_6）
	];

	static final CROP_ASSET_PATHS:Array<String> = [
		"source/core/module/ui/allcrops/Crop_1_0.swf",
		"source/core/module/ui/allcrops/Crop_2_1.swf",
		"source/core/module/ui/allcrops/Crop_2_2.swf",
		"source/core/module/ui/allcrops/Crop_2_3.swf",
		"source/core/module/ui/allcrops/Crop_1_4.swf"
	];

	// 看板 URL 与 diy/1.swf 同名文件（board/1.swf vs diy/1.swf）——库名必须
	// 消歧，否则看板槽装进 diy/1 背景图（画面保真错位，不 404、CI 冒烟不拦）。
	static final BOARD_URL:String = CORE_URL + "/module/ui/farm/diy/board/1.swf";
	static final BOARD_ID:String = "board_1";
	static final BOARD_ASSET_PATH:String = "source/core/module/ui/farm/diy/board/1.swf";

	public function new() {}

	// 不变式 1：生命周期各档 URL 全部落在 LocalSwfLoader 的 module swf 映射
	// 域内，库名 = 文件名去 .swf（attempt 1 的 404 即 Crop_2_3 这一环缺失）。
	public function test_library_id_mapping_covers_crop_lifecycle_urls() {
		for (r in CROP_WINDOW) {
			Assert.equals(r.id, LocalSwfLoader.libraryIdForUrl(r.url), 'url=${r.url}');
		}
	}

	// 不变式 2：每个作物库名在 libraries.xml 声明，且 path 指向对应 swf。
	public function test_crop_lifecycle_libraries_are_declared() {
		var declared:Map<String, String> = new Map<String, String>();
		try {
			var project = Xml.parse(File.getContent("libraries.xml")).firstElement();
			for (library in project.elementsNamed("library")) {
				declared.set(library.get("id"), library.get("path"));
			}
		} catch (e:Dynamic) {
			Assert.fail('读不到 libraries.xml（测试须从仓库根目录跑）：${e}');
			return;
		}
		for (r in CROP_WINDOW) {
			Assert.isTrue(declared.exists(r.id),
				'libraries.xml 缺 <library id="${r.id}">：白萝卜生命周期会请求 '
				+ r.url + '，未入库的 module swf 在 html5 下对未声明库发 404 '
				+ '（console.error → web-smoke FAIL）');
			Assert.equals("assets/legacy/" + CROP_ASSET_PATHS[CROP_WINDOW.indexOf(r)],
				declared.get(r.id), 'id=${r.id} 的 path 指错文件');
		}
	}

	// 不变式 3：作物 swf 在 assets/legacy-assets.txt 登记（构建期才会同步进
	// assets/legacy/，CLAUDE.md：两文件同 commit 改）。
	public function test_crop_lifecycle_swfs_are_in_sync_manifest() {
		var manifest:String;
		try {
			manifest = File.getContent("assets/legacy-assets.txt");
		} catch (e:Dynamic) {
			Assert.fail('读不到 assets/legacy-assets.txt（测试须从仓库根目录跑）：${e}');
			return;
		}
		for (p in CROP_ASSET_PATHS) {
			Assert.isTrue(manifest.indexOf(p) != -1,
				'assets/legacy-assets.txt 缺 ${p}：构建期不同步该 swf，'
				+ 'libraries.xml 指向的文件不存在');
		}
	}

	// 不变式 4：看板 URL 消歧为 board_1，且不与装饰背景库名（diy/1.swf → "1"）
	// 相撞——撞库不 404、装错图，只能靠这条不变式钉住。
	public function test_board_url_maps_to_disambiguated_library() {
		Assert.equals(BOARD_ID, LocalSwfLoader.libraryIdForUrl(BOARD_URL), 'url=${BOARD_URL}');
		Assert.notEquals(LocalSwfLoader.libraryIdForUrl(BOARD_URL),
			LocalSwfLoader.libraryIdForUrl(CORE_URL + "/module/ui/farm/diy/1.swf"),
			"看板与背景同名文件必须映射到不同库名");

		var declared:Map<String, String> = new Map<String, String>();
		try {
			var project = Xml.parse(File.getContent("libraries.xml")).firstElement();
			for (library in project.elementsNamed("library")) {
				declared.set(library.get("id"), library.get("path"));
			}
			Assert.isTrue(declared.exists(BOARD_ID),
				'libraries.xml 缺 <library id="${BOARD_ID}">：看板槽 9（activeItem '
				+ '补发）会请求 ${BOARD_URL}');
			Assert.equals("assets/legacy/" + BOARD_ASSET_PATH, declared.get(BOARD_ID),
				'id=${BOARD_ID} 的 path 指错文件');
		} catch (e:Dynamic) {
			Assert.fail('读不到 libraries.xml（测试须从仓库根目录跑）：${e}');
			return;
		}

		var manifest:String;
		try {
			manifest = File.getContent("assets/legacy-assets.txt");
		} catch (e:Dynamic) {
			Assert.fail('读不到 assets/legacy-assets.txt（测试须从仓库根目录跑）：${e}');
			return;
		}
		Assert.isTrue(manifest.indexOf(BOARD_ASSET_PATH) != -1,
			'assets/legacy-assets.txt 缺 ${BOARD_ASSET_PATH}：构建期不同步看板 swf');
	}
}
