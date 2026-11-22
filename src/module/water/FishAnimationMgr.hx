package module.water;

import com.qzone.qfa.managers.LoadManager;
import common.Consts;
import common.misc.time.CountDown;
import entities.PoolFish;
import openfl.display.MovieClip;
import openfl.system.ApplicationDomain;

/**
 * module.water.FishAnimationMgr —— FishAnimationMgr.as 逐句对应（issue #37
 * 功能 swf 翻译：鱼塘 pool_v_13 鱼动画管理）。单例：FishMCPoolObjectMgr 按
 * 鱼符号（FS_xx_x_x/FJ_…）回收 MovieClip，LoadManager（3 线程）预载鱼动画
 * swf（PoolFish.animationUrl），CountDown(300s) 到点 gc 各池。
 */
class FishAnimationMgr {
	// FishAnimationMgr.as:13
	private static var _instance:FishAnimationMgr;

	// FishAnimationMgr.as:15
	private var _loadMgr:LoadManager;

	// FishAnimationMgr.as:17
	private var m_recycleFreq:CountDown;

	// FishAnimationMgr.as:19
	private var _poolMgr:FishMCPoolObjectMgr;

	// FishAnimationMgr.as:21-28
	public function new() {
		this._poolMgr = new FishMCPoolObjectMgr();
		this._loadMgr = new LoadManager(ApplicationDomain.currentDomain);
		this._loadMgr.maxThreadCount = 3;
		this.m_recycleFreq = new CountDown(Consts.FISH_POOL_GC_COUNTDOWN);
	}

	// FishAnimationMgr.as:30-38
	public static function getInstance():FishAnimationMgr {
		if (_instance != null) {
			return _instance;
		}
		_instance = new FishAnimationMgr();
		return _instance;
	}

	// FishAnimationMgr.as:40-54
	public function destroyMC(param1:MovieClip):Void {
		if (param1 == null) {
			return;
		}
		param1.stop();
		param1.x = param1.y = 0;
		param1.scaleX = param1.scaleY = 1;
		if (param1.parent != null) {
			param1.parent.removeChild(param1);
		}
		this._poolMgr.returnObject(param1);
	}

	// FishAnimationMgr.as:56-67
	public function createFishMC(param1:String):MovieClip {
		if (param1 == null || param1 == "") {
			return null;
		}
		if (this._poolMgr.contains(param1) == false) {
			this._poolMgr.register(param1);
		}
		return cast(this._poolMgr.getObject(param1), MovieClip);
	}

	// FishAnimationMgr.as:69-77
	public function onGameLoop(param1:Float):Void {
		if (this.m_recycleFreq.isReady() == false) {
			return;
		}
		this.m_recycleFreq.reset(Consts.FISH_POOL_GC_COUNTDOWN);
		this._poolMgr.gc();
	}

	// FishAnimationMgr.as:79-104。for each → 值遍历
	public function loadFishes(param1:Array<Dynamic>):Bool {
		var _loc3_:PoolFish = null;
		var _loc4_:String = null;
		var _loc2_:Bool = false;
		if (param1 == null || param1.length == 0) {
			return _loc2_;
		}
		// for-each：AS3 声明 `_loc3_:PoolFish`，经 typed 收窄——animationUrl
		// 是 getter，动态接收者上取不到
		var typed:Array<PoolFish> = cast param1;
		for (_loc3_ in typed) {
			if (_loc3_ != null) {
				_loc4_ = _loc3_.animationUrl;
				if (!(_loc4_ == null || _loc4_ == "")) {
					if (this._loadMgr.add(_loc4_) != null) {
						_loc2_ = true;
					}
				}
			}
		}
		this._loadMgr.start();
		return _loc2_;
	}
}
