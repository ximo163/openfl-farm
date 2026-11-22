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
 *
 * 鱼动画资产链（符号命名约定 F{S,J}_<鱼型两位>_<档0-2>_<向0|2>，档取
 * min(level,2)、向只有 0/2——FishMover.formatFishName + spawn 的向翻转）：
 * 17 种鱼各一个库 fish_01..fish_17（nc_data.php:7564 fish_info 的
 * asset_id.m → module/ui/farm/fish/，LocalSwfLoader 按 URL 尾段映射库名），
 * 每库导出 FS 全网格 6 枚 + 跳跃 FJ_2_2 一枚（型 1/2/3 另有 FJ_2_0），同名
 * 根包 shim（src/FS_*.hx / src/FJ_*.hx，@:keep + dceAnchor #37 段）注册进
 * 编译期类表——FishMover.checkResource 的 hasDefinition 与 FishMCPoolObjectMgr
 * .register 的 getDefinition（openfl 两者均 Type.resolveClass，只看编译期
 * 类表、不看已载库符号）靠它们命中，素材库再由 SymbolClass.bind 按需拉起。
 * 原版怪癖两处（dump_swf.php 可证）：fish_10.swf 的跳跃符号误导出为
 * FJ_01_2_2（与 fish_01 撞名，同名 shim 只能绑一库、按符号名归 fish_01，
 * deviations 候选）；鱼型 11 的 m 档 URL 登记 fish_11.swf 而部署包文件名
 * 大写 Fish_11.swf（原版大小写不敏感部署同一文件，入库按磁盘大小写、
 * 库名取 URL 尾段 fish_11）。fish_10_v_3.swf 部署包存在但无配置引用
 * （死资产，不入库；其 FJ_10_2_2 原版同样永不可见）。
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
