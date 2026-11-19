package;

import shim.LocalSwfLoader;
import sys.io.File;
import utest.Assert;

/**
 * 农场场景启动窗口的装饰 swf ↔ 资产声明一致性门（issue #8 implement attempt 3）。
 *
 * 与 StartupModuleLibrariesTest 同一条不变式的场景窗口片：启动数据里 uid=1
 * 的 items 会经 BackgroundModel.setDecors/buildDecor 变成 module/ui/farm/diy/
 * <itemId>.swf 的组加载（BackgroundScreen.setDIYUrl → RSLLoader →
 * LocalSwfLoader），URL 未入库时 html5 运行期对未声明库发 404——CI web-smoke
 * 以三条 console.error「Failed to load resource: 404」FAIL，implement 前两轮
 * 即卡在这里（diy/2,3,4 未声明，本地 node 冒烟对失败库只走 onError 分支，
 * 就绪标记照样置位，所以两轮都报「无 TypeError」而漏掉）。
 *
 * 数据链（期望值全部可指认）：
 * - legacy/snapshot/initialized.sql:5718 uchome_qqfarm_nc uid=1 行 decorative 列
 *   `{"1":{"1":{"status":1,...}},"2":{"2":...},"3":{"3":...},"4":{"4":...}}`；
 * - user_run.php:141-156 逐槽取 $decorative_echo[$item_type]['itemId'] →
 *   下发 items {"1":{"itemId":1},…,"4":{"itemId":4}}（DECOR 类型见
 *   Consts.as:213-216：1 背景、2 房子、3 栅栏、4 狗屋，billboard=9 不在
 *   uid=1 数据里）；
 * - StartupDataParser（StartupDataParser.as:25-54）_decors = items；
 * - BackgroundModel.buildDecor（BackgroundModel.as:174-218）非 billboard 槽
 *   idToDiyUrl2(itemId)；
 * - idToDiyUrl2（GetCropID.as:81-108）查 item_info（nc_data.php:6780-6784
 *   id 1..4 茅草系列）的 asset_id.m = 945/948/951/954；
 * - getAssetUrl（GetCropID.as:299-329）查 assets 表（nc_data.php:51/82/392/640
 *   `<asset id="945" src="$url/module/ui/farm/diy/1.swf"/>`，948/951/954 →
 *   diy/2/3/4.swf），/diy/ 前缀拼 module/ui/farm。
 *
 * 三条不变式：URL 可被 LocalSwfLoader.libraryIdForUrl 映射成数字库名；
 * 库名在 libraries.xml 声明；swf 路径在 assets/legacy-assets.txt 里（构建期
 * 同步进 assets/legacy/，两文件按 CLAUDE.md 必须同 commit 增删）。
 */
@:access(shim.LocalSwfLoader)
class SceneDecorLibrariesTest {
	// 绝对 URL 前缀：assets 表的 src 带 $url（common.php:15-17 拼站点自身），
	// Utils.addPrefix 后是部署绝对形态。host 取占位值（映射只看 module/ 尾段）。
	static final CORE_URL:String = "http://page.host/home/qqfarm/core";

	// uid=1 场景启动窗口逐槽请求的装饰 swf（背景=1 已随 V2/#3 入库，这里
	// 连同一起钉住，避免后续把四槽拆散）。
	static final DECOR_WINDOW:Array<{url:String, id:String}> = [
		{url: CORE_URL + "/module/ui/farm/diy/1.swf", id: "1"}, // 背景 田园风光
		{url: CORE_URL + "/module/ui/farm/diy/2.swf", id: "2"}, // 房子 茅草屋
		{url: CORE_URL + "/module/ui/farm/diy/3.swf", id: "3"}, // 栅栏 木桩栅栏
		{url: CORE_URL + "/module/ui/farm/diy/4.swf", id: "4"} // 狗屋 茅草狗屋
	];

	// 库声明指向的 assets/legacy 相对路径（libraries.xml path 去前缀）；
	// assets/legacy-assets.txt 里登记的部署相对路径。两形对照。
	static final ASSET_PATHS:Array<String> = [
		"source/core/module/ui/farm/diy/1.swf",
		"source/core/module/ui/farm/diy/2.swf",
		"source/core/module/ui/farm/diy/3.swf",
		"source/core/module/ui/farm/diy/4.swf"
	];

	public function new() {}

	// 不变式 1：装饰 URL 全部落在 LocalSwfLoader 的 module swf 映射域内，
	// 且库名 = 文件名去 .swf（diy 库名是纯数字，映射规则不特判）。
	public function test_library_id_mapping_covers_scene_decor_urls() {
		for (r in DECOR_WINDOW) {
			Assert.equals(r.id, LocalSwfLoader.libraryIdForUrl(r.url), 'url=${r.url}');
		}
	}

	// 不变式 2：每个装饰库名在 libraries.xml 声明，且 path 指向 ASSET_PATHS
	// 里的 swf（防「声明了但指向别的文件」的错位）。
	public function test_scene_decor_libraries_are_declared() {
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
		for (r in DECOR_WINDOW) {
			Assert.isTrue(declared.exists(r.id),
				'libraries.xml 缺 <library id="${r.id}">：场景启动会请求 ${r.url}，'
				+ '未入库的 module swf 在 html5 下对未声明库发 404 请求'
				+ '（console.error → web-smoke FAIL）');
			Assert.equals("assets/legacy/" + ASSET_PATHS[DECOR_WINDOW.indexOf(r)],
				declared.get(r.id), 'id=${r.id} 的 path 指错文件');
		}
	}

	// 不变式 3：对应 swf 在 assets/legacy-assets.txt 登记（scripts/
	// sync-legacy-assets.sh 才会把它拷进 assets/legacy/——只改 libraries.xml
	// 不登记时构建期打 Warning「Could not find library file」，运行期库空）。
	public function test_scene_decor_swfs_are_in_sync_manifest() {
		var manifest:String;
		try {
			manifest = File.getContent("assets/legacy-assets.txt");
		} catch (e:Dynamic) {
			Assert.fail('读不到 assets/legacy-assets.txt（测试须从仓库根目录跑）：${e}');
			return;
		}
		for (p in ASSET_PATHS) {
			Assert.isTrue(manifest.indexOf(p) != -1,
				'assets/legacy-assets.txt 缺 ${p}：构建期不同步该 swf，'
				+ 'libraries.xml 指向的文件不存在（CLAUDE.md：两文件同 commit 改）');
		}
	}
}
