package com.qzone.qfa.managers;

import com.qzone.qfa.data.ResourceType;
import com.qzone.qfa.events.LoaderEvent;
import openfl.events.EventDispatcher;
import openfl.events.ProgressEvent;
import utest.Assert;

/**
 * 预加载队列管理器的纯逻辑（issue #3）：loading/stopped 状态机、addAt 入队边界、
 * 队列进度公式。
 *
 * 出处：legacy/decompiled/happyfarm3_v_149/scripts/com/qzone/qfa/managers/LoadManager.as
 * （常量 :16/:18；stop :53-60；count :107-110；add :236-239；addAt :260-285；
 * removeItem :322-356；reset :377-390；removeAt :413-416；start :417-427；
 * progressHandler :429-457）
 *
 * 不联网：start() 的放行分支（队列非空→loadItem 真发 URLLoader/Loader）不进
 * 单测，loading 态用 setStatus 摆位；进度公式经 @:access 直接驱动
 * progressHandler，用一个 EventDispatcher 冒充在传的 loader——原版里
 * _map 的键就是 loader 对象（as:188），progressHandler 以 param1.target 查表
 * （as:435），ProgressEvent 经它派发时 target 即它自身。
 */
@:access(com.qzone.qfa.managers.LoadManager)
class LoadManagerTest {
	public function new() {}

	// LoadManager.as:16/:18 常量值；:42-51 构造 → reset（:377-390）→ 初始 stopped
	//（:384 _queue = []）
	public function test_initial_status_is_stopped_with_empty_queue() {
		Assert.equals("loading", LoadManager.STATUS_LOADING);
		Assert.equals("stopped", LoadManager.STATUS_STOPPED);
		var lm = new LoadManager();
		Assert.equals(LoadManager.STATUS_STOPPED, lm.status);
		Assert.equals(0, lm.count);
	}

	// LoadManager.as:417-427：start 只在 stopped 且队列非空时放行；空队列时
	// 不动状态、不发 QUEUE_START
	public function test_start_with_empty_queue_is_noop() {
		var lm = new LoadManager();
		var queueStarts = 0;
		lm.addEventListener(LoaderEvent.QUEUE_START, function(e) queueStarts++);
		lm.start();
		Assert.equals(LoadManager.STATUS_STOPPED, lm.status);
		Assert.equals(0, queueStarts);
	}

	// LoadManager.as:53-60：stop 只在 loading 时清队列（clear→reset，_itemFailed
	// 为 0 走 reset，:404-411）并补发 QUEUE_CHANGED（:58）；stopped 下 stop 无操作
	public function test_stop_is_noop_when_stopped_and_resets_when_loading() {
		var lm = new LoadManager();
		var changed = 0;
		lm.addEventListener(LoaderEvent.QUEUE_CHANGED, function(e) changed++);

		lm.stop(); // stopped → 什么都不做
		Assert.equals(0, changed);
		Assert.equals(LoadManager.STATUS_STOPPED, lm.status);

		lm.setStatus(LoadManager.STATUS_LOADING); // 摆位，绕开真实加载路径
		lm.stop(); // → stopped + 1 次 QUEUE_CHANGED
		Assert.equals(1, changed);
		Assert.equals(LoadManager.STATUS_STOPPED, lm.status);
	}

	// LoadManager.as:236-239 add 追加；:260-285 addAt 建 Resource（url :267、type
	// 按 ResourceType :268）；重复 URL（:263-264 → :284）、下标越界（<0 或 > length，
	// :273-276）返回 null 且不入队；:281 splice 插到指定下标
	public function test_add_and_addAt_enqueue_with_type_and_boundaries() {
		var lm = new LoadManager();
		var r = lm.add("module/main3_v_221.swf");
		Assert.notNull(r);
		Assert.equals("module/main3_v_221.swf", r.url);
		Assert.equals(ResourceType.TYPE_SWF, r.type);
		Assert.equals(1, lm.count);

		var r2 = lm.add("xml.php?mod=data_zh_CN_v_20120905.xml");
		Assert.notNull(r2);
		Assert.equals(ResourceType.TYPE_TEXT, r2.type);
		Assert.equals(2, lm.count);

		Assert.isNull(lm.add("module/main3_v_221.swf")); // 重复 URL
		Assert.equals(2, lm.count);

		Assert.isNull(lm.addAt("module/no_extension", -1)); // 下标 < 0
		Assert.isNull(lm.addAt("module/no_extension", lm.count + 1)); // 下标 > length
		Assert.equals(2, lm.count);

		Assert.notNull(lm.addAt("module/a.png", 1)); // 插到 1 号位
		Assert.equals(3, lm.count);
		Assert.equals("module/main3_v_221.swf", queueUrl(lm, 0));
		Assert.equals("module/a.png", queueUrl(lm, 1));
		Assert.equals("xml.php?mod=data_zh_CN_v_20120905.xml", queueUrl(lm, 2));
	}

	// LoadManager.as:277-280：loading 中插到 0 号位被拒（队头正是在传的项），
	// 其余下标（含队尾 == length）不拦
	public function test_addAt_index_zero_is_rejected_while_loading() {
		var lm = new LoadManager();
		Assert.notNull(lm.add("module/a.txt"));
		lm.setStatus(LoadManager.STATUS_LOADING);
		Assert.isNull(lm.addAt("module/b.txt", 0));
		Assert.equals(1, lm.count);
		Assert.notNull(lm.addAt("module/b.txt", 1));
		Assert.equals(2, lm.count);
	}

	// LoadManager.as:62-65/322-356/413-416：remove 按 URL 出队（:341-346 命中
	// splice 返回 true）；找不到且无下标 → false（:355）；removeAt 按下标盲删
	//（removeItem(null, idx)，:350-353）
	public function test_remove_by_url_and_index() {
		var lm = new LoadManager();
		lm.add("module/a.png");
		lm.add("module/b.png");
		Assert.isTrue(lm.remove("module/a.png"));
		Assert.equals(1, lm.count);
		Assert.equals("module/b.png", queueUrl(lm, 0));
		Assert.isFalse(lm.remove("module/no/such.png"));
		Assert.isTrue(lm.removeAt(0));
		Assert.equals(0, lm.count);
	}

	// LoadManager.as:437-440：bytesTotal==0（总长不可知）时当前项按 80 记；
	// :452 队列进度 =（100*itemLoaded + Σ在传项 percent）/（itemLoaded+itemFailed+队列长）
	public function test_queue_progress_counts_unknown_total_as_80_percent() {
		var lm = new LoadManager();
		lm.add("data/a.xml"); // 队列长度 1 进分母（:434）
		var item = newItem(10);
		var carrier = hookInProgress(lm, item);
		carrier.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 0, 0));
		Assert.floatEquals(80, item.percent); // :439
		Assert.floatEquals(80, lm._percentQueue); // (100*0+80)/(0+0+1)
	}

	// LoadManager.as:442-444：总长已知按 bytesLoaded/bytesTotal*100 记
	public function test_queue_progress_uses_byte_ratio_when_total_known() {
		var lm = new LoadManager();
		lm.add("data/a.xml");
		var item = newItem(0);
		var carrier = hookInProgress(lm, item);
		carrier.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 25, 200));
		Assert.floatEquals(12.5, item.percent); // 25/200*100
		Assert.floatEquals(12.5, lm._percentQueue); // (0+12.5)/(0+0+1)
	}

	// LoadManager.as:445-452：分子 = 100*已完成数 + 各在传项 percent 之和
	//（:447 percent 为 0 的跳过）；分母 = 已完成 + 失败 + 队列长。
	// 两个在传项（80、25）、已完成 2、失败 1、队列 2 → (200+105)/5 = 61
	public function test_queue_progress_formula_weights_loaded_and_failed_counts() {
		var lm = new LoadManager();
		lm.add("data/a.xml");
		lm.add("data/b.xml");
		lm._itemLoaded = 2;
		lm._itemFailed = 1;
		var itemA = newItem(50);
		var itemB = newItem(25);
		var carrierA = hookInProgress(lm, itemA);
		hookInProgress(lm, itemB);
		carrierA.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 0, 0)); // bytesTotal=0 → itemA 变 80
		Assert.floatEquals(80, itemA.percent);
		Assert.floatEquals(61, lm._percentQueue); // (100*2 + 80 + 25) / (2+1+2)
	}

	// 读私有队列第 index 项的 url（addAt 的插入位置验证）
	static function queueUrl(lm:LoadManager, index:Int):String {
		var item:LoadManager.LoadItem = lm._queue[index];
		return item.resource.url;
	}

	// 构造一个在传中的 LoadItem（percent 预置；progressHandler 只读它的 percent，
	// resource 仅透传进事件，可为 null）
	static function newItem(percent:Float):LoadManager.LoadItem {
		var item = new LoadManager.LoadItem();
		item.percent = percent;
		return item;
	}

	// 模拟 loadItem（as:188）的登记形态：_map[loader] = item，并把 progressHandler
	// 挂到这个假 loader 上，让 ProgressEvent.target 查得到它
	static function hookInProgress(lm:LoadManager, item:LoadManager.LoadItem):EventDispatcher {
		var carrier = new EventDispatcher();
		lm._map.set(carrier, item);
		carrier.addEventListener(ProgressEvent.PROGRESS, lm.progressHandler);
		return carrier;
	}
}
