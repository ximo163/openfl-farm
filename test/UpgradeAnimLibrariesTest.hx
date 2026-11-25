package;

import shim.LocalSwfLoader;
import sys.io.File;
import utest.Assert;

/**
 * 升级红地动画（RedUp.swf）的 swf ↔ 资产声明一致性门（issue #58
 * write-tests 阶段，对未注册红——本文件是 implement 阶段把 RedUp 入库的
 * 验收门）。与 SceneDecorLibrariesTest / CropLifecycleLibrariesTest 同式
 * 三不变式：URL 可被 LocalSwfLoader.libraryIdForUrl 映射成库名；库名在
 * libraries.xml 声明且 path 指对文件；swf 路径在 assets/legacy-assets.txt
 * 登记。
 *
 * 为什么 #58 需要这条门：RedUp 是帧脚本补偿的落地场景之一（主时间轴
 * frame134 派发 "end"），补偿接线走 LocalSwfLoader content 的根时间轴
 * （symbolKey 空串），前提是 swf 已按库入库——未入库的 module swf 在
 * html5 下对未声明库发 404（console.error → web-smoke FAIL），
 * FarmLandController 的 IO_ERROR 兜底会吞掉升级动画。
 *
 * 数据链（期望值全部可指认）：
 * - nc_data.php:37 secondList：{"id":"redup",
 *   "src":"$url/module/ui/main/RedUp.swf", "className":"Red"}——$url 由
 *   服务端替换成部署前缀（Settings.replaceAppImg 同款绝对形态），客户端
 *   侧 FarmLandController 拿到的是绝对 URL（legacy/decompiled/main3_v_221/
 *   scripts/module/mainScene/farmLand/FarmLandController.as:595
 *   getSecondUrl("redup") → LocalSwfLoader）；
 * - 映射域只看 URL 的 module/ 尾段（LocalSwfLoader.libraryIdForUrl），
 *   → 库名 "RedUp" = 文件名去 .swf；
 * - 帧脚本与收尾监听：RedUp.swf 主轴 addFrameScript(133, frame134)（MainTimeline.as:13）、frame134 = dispatchEvent(new Event("end"))
 *   （MainTimeline.as:16-19）；收听方 FarmLandsView.as:677
 *   animation.addEventListener("end", …)（升级红地动画的清场收尾）；
 * - RedUp.swf 在 scripts/decompile-legacy.sh:68 的 main_swfs 清单内
 *   （swf-code-audit 无 LEAK，按素材库入库不违反「带 AS3 的 swf 须先立项」
 *   门禁——它的 ABC 已进 legacy/decompiled/RedUp/）。
 */
@:access(shim.LocalSwfLoader)
class UpgradeAnimLibrariesTest {
	// 绝对 URL 前缀：secondList src 带 $url，服务端替换后是部署绝对形态。
	// host 取占位值（映射只看 module/ 尾段）。
	static final CORE_URL:String = "http://page.host/home/qqfarm/core";

	static final REDUP_URL:String = CORE_URL + "/module/ui/main/RedUp.swf";
	static final REDUP_ID:String = "RedUp";
	static final REDUP_ASSET_PATH:String = "source/core/module/ui/main/RedUp.swf";

	public function new() {}

	// 不变式 1：redup 的 URL 落在 LocalSwfLoader 的 module swf 映射域内，
	// 库名 = 文件名去 .swf（diy/board 消歧规则不触及该路径）。
	public function test_redup_url_maps_to_library_id() {
		Assert.equals(REDUP_ID, LocalSwfLoader.libraryIdForUrl(REDUP_URL), 'url=${REDUP_URL}');
	}

	// 不变式 2：RedUp 在 libraries.xml 声明，且 path 指向对应 swf。
	public function test_redup_library_is_declared() {
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
		Assert.isTrue(declared.exists(REDUP_ID),
			'libraries.xml 缺 <library id="${REDUP_ID}">：升级红地动画会请求 '
			+ REDUP_URL + '，未入库的 module swf 在 html5 下对未声明库发 404 '
			+ '（console.error → web-smoke FAIL），帧脚本补偿也无从接线');
		Assert.equals("assets/legacy/" + REDUP_ASSET_PATH, declared.get(REDUP_ID),
			'id=${REDUP_ID} 的 path 指错文件');
	}

	// 不变式 3：RedUp.swf 在 assets/legacy-assets.txt 登记（构建期才会同步
	// 进 assets/legacy/，CLAUDE.md：两文件同 commit 改）。
	public function test_redup_swf_is_in_sync_manifest() {
		var manifest:String;
		try {
			manifest = File.getContent("assets/legacy-assets.txt");
		} catch (e:Dynamic) {
			Assert.fail('读不到 assets/legacy-assets.txt（测试须从仓库根目录跑）：${e}');
			return;
		}
		Assert.isTrue(manifest.indexOf(REDUP_ASSET_PATH) != -1,
			'assets/legacy-assets.txt 缺 ${REDUP_ASSET_PATH}：构建期不同步该 '
			+ 'swf，libraries.xml 指向的文件不存在（库文件缺失 → 构建红）');
	}
}
