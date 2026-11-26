package mc.view;

import mc.view.CropLoader;
import openfl.display.Loader;
import openfl.events.Event;
import utest.Assert;

/**
 * mc.view.CropLoader 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 批量 Loader 队列的常量、存取与 loadNext 的 FIFO/收尾语义。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/CropLoader.as
 * —— ITEM_COMPLETE="item_complete"（:15）；load :40-58（param1 null 时
 * throw Error("需要设置urlArray或urls参数")）；loadNext :101-116（队列
 * shift 出 url——`if(_loc1_)` 真值门：falsy 串不 load 也不 comp、纯消耗；
 * 队列空 → comp()）；comp :81-99（先 dispatchEvent(Event.COMPLETE) 再摘
 * 4 个 contentLoaderInfo 监听、try-close 吞错、`_loader=null`）。
 *
 * 网络/定时面（Loader.load 真加载、load() 入口的 setTimeout 50ms）不在
 * eval 单测——本测试经 @:access 直调私有 loadNext/直置 _urlArray/_loader
 * 绕过定时器，把 FIFO 消耗与 comp 收尾同步钉住，**不再是注释备录的占位**。
 * Loader.close 在 openfl 9.5.2 只警告不掷（容器内实测——"close is not
 * implemented" 警告），comp() 的 try-close 吞错段在 eval 安全走完。
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

	// loadNext 的 falsy 消耗（:104-108）：`_urlArray=[""]` —— shift 出
	// 空串，`if(_loc1_)` 真值门拒绝 → 不 load、**也不 comp**（队列还非空
	// 判断先走 length>0 分支、走不到 else 的 comp）——纯消耗一格。队列
	// 清零后下一次 loadNext 才进 comp。这条把「shift 是 FIFO 消耗」与
	// 「falsy 不触发收尾」两个语义一并钉住
	public function test_loadNext_falsy_url_consumed_without_comp() {
		var loader = new CropLoader();
		loader._urlArray = [""];
		loader._loader = new Loader(); // comp 需要非 null loader——本路径不进 comp
		var compFired = 0;
		loader.addEventListener(Event.COMPLETE, function(e) compFired++);
		loader.loadNext();
		// 空串被消耗（FIFO shift）
		Assert.equals(0, loader._urlArray.length);
		// 不 load 不 comp——COMPLETE 未派发、loader 未清空
		Assert.equals(0, compFired);
		Assert.notNull(loader._loader);
	}

	// loadNext 空队列进 comp（:111-113 → :81-99）：COMPLETE 同步派发、
	// 4 监听摘除、try-close 吞错、`_loader=null`——装配真 Loader 直调
	public function test_loadNext_empty_queue_comp_finishes() {
		var loader = new CropLoader();
		loader._urlArray = [];
		loader._loader = new Loader();
		var compFired = 0;
		loader.addEventListener(Event.COMPLETE, function(e) compFired++);
		loader.loadNext();
		// comp() 先派发 COMPLETE（:83）
		Assert.equals(1, compFired);
		// `_loader=null`（:98——摘监听+close 后清空）
		Assert.isNull(loader._loader);
	}

	// FIFO 顺序（:105 shift——先入先出 + :107 非空串进 load 分支）：
	// 用 support.RecordingLoader（覆写 load 只记 url——真身 load 在 eval
	// 读 Lib.current.loaderInfo 崩 null，RecordingLoader.hx 类头注释）
	// 驱动真 url，直接钉「load 的 url 顺序 = 队列 FIFO 顺序」，
	// 比推断剩余队列更贴近被测语义
	public function test_loadNext_fifo_order() {
		var loader = new CropLoader();
		loader._urlArray = ["first.swf", "second.swf", "third.swf"];
		var rec = new support.RecordingLoader();
		loader._loader = rec;
		loader.loadNext();
		Assert.equals("first.swf", rec.loadedUrls[0]); // 首元素先出
		loader.loadNext();
		Assert.equals("second.swf", rec.loadedUrls[1]); // FIFO 非 LIFO
		loader.loadNext();
		Assert.equals("third.swf", rec.loadedUrls[2]);
		Assert.equals(3, rec.loadedUrls.length);
		Assert.equals(0, loader._urlArray.length); // 队列耗尽
	}
}
