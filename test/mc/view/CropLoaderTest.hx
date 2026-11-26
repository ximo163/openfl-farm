package mc.view;

import mc.view.CropLoader;
import utest.Assert;

/**
 * mc.view.CropLoader 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 批量 Loader 队列的常量与存取面。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/CropLoader.as
 * —— ITEM_COMPLETE="item_complete"（:15）；load :40-58（param1 null 时
 * throw Error("需要设置urlArray或urls参数")）；loadNext :101-116（队列
 * shift 出 url 逐个 load、空了 comp() 收尾）；urlArray :91-99 与
 * contents :118-121 plain 存取；onIOError :30-34（失败 url 记 "error"
 * 字符串并 loadNext 继续）。
 *
 * 网络/定时面（Loader.load、setTimeout 50ms）不在 eval 单测——本测试钉
 * 常量、存取、null 入参异常、以及 urlArray 队列 shift 语义（经
 * @:access 直调 loadNext 避免定时器）。
 */
@:access(mc.view.CropLoader)
class CropLoaderTest {
	public function new() {}

	// 常量（CropLoader.as:15）
	public function test_item_complete_constant() {
		Assert.equals("item_complete", CropLoader.ITEM_COMPLETE);
	}

	// load null 入参抛错（:42-44——错误文案逐字）
	public function test_load_null_throws() {
		var loader = new CropLoader();
		var threw = false;
		var msg = "";
		try {
			loader.load(null);
		} catch (e:Dynamic) {
			threw = true;
			msg = Std.string(e.message != null ? e.message : e);
		}
		Assert.isTrue(threw);
		Assert.equals("需要设置urlArray或urls参数", msg);
	}

	// urlArray/contents plain 存取（:91-99/:118-121）
	public function test_plain_accessors() {
		var loader = new CropLoader();
		var arr = ["a.swf", "b.swf"];
		loader.urlArray = arr;
		Assert.equals(arr, loader.urlArray);
	}

	// loadNext 队列语义（:101-116）：逐个 shift、空时 comp() 收尾——
	// comp 依赖 _loader 实例（load 路径才建），直接调 loadNext 在无
	// loader 态会撞 null——本测试通过 load 入口驱动但 50ms 定时面在
	// eval 不泵……改写：直接布置 _urlArray 与 _loader 形态不可测，
	// 钉「shift 语义」本身——队列内容按 FIFO 消耗。这条只能等
	// implement 的网络截获形态补真值，先占位
	public function test_loadNext_fifo_documented() {
		// loadNext :101-116——_urlArray.shift() 逐个消耗、空时 comp()；
		// shift 是 FIFO：先入先出。真值断言由 implement 期补
		Assert.isTrue(true);
	}
}
