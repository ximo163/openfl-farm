package com.qzone.qfa.managers;

import com.qzone.qfa.data.Resource;
import com.qzone.qfa.data.ResourceType;
import com.qzone.qfa.events.LoaderEvent;
import openfl.display.Bitmap;
import openfl.display.LoaderInfo;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.HTTPStatusEvent;
import openfl.events.IEventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.system.SecurityDomain;
import openfl.utils.Dictionary;
import openfl.Lib.getTimer;
import shim.As3;
import shim.LocalSwfLoader;

// LoadManager.as 逐句对应。
class LoadManager extends EventDispatcher {
	// LoadManager.as:16
	public static final STATUS_LOADING:String = "loading";

	// LoadManager.as:18
	public static final STATUS_STOPPED:String = "stopped";

	// LoadManager.as:20
	private var _status:String;

	// LoadManager.as:22
	private var _queue:Array<Dynamic>;

	// LoadManager.as:24
	private var _itemLoaded:Int;

	// LoadManager.as:26。键是 loader 对象（URLLoader/LoaderInfo），K 用对象类型
	// 才落 ObjectMap；事件目标是 EventDispatcher
	private var _map:Dictionary<EventDispatcher, Dynamic>;

	// LoadManager.as:28
	private var _percentQueue:Float;

	// LoadManager.as:30
	private var _maxThreadCount:UInt;

	// LoadManager.as:32
	private var _startTime:Int;

	// LoadManager.as:34
	private var _itemFailed:Int;

	// LoadManager.as:36
	private var _eventList:Array<String> = [LoaderEvent.COMPLETE, LoaderEvent.ERROR, LoaderEvent.PROGRESS,
		LoaderEvent.QUEUE_CHANGED, LoaderEvent.QUEUE_COMPLETE, LoaderEvent.QUEUE_PROGRESS, LoaderEvent.QUEUE_START,
		LoaderEvent.START, LoaderEvent.STATUS_CHANGED];

	// LoadManager.as:38
	private var _defaultAppDomain:ApplicationDomain;

	// LoadManager.as:40
	private var _loadingThreadCount:Int;

	// LoadManager.as:42-51
	public function new(param1:ApplicationDomain = null) {
		super();
		this.reset();
		this._maxThreadCount = 1;
		if (As3.truthy(param1)) {
			this._defaultAppDomain = param1;
		}
	}

	// LoadManager.as:53-60
	public function stop():Void {
		if (this._status == STATUS_LOADING) {
			this.clear();
			dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_CHANGED));
		}
	}

	// LoadManager.as:62-65
	public function remove(param1:String):Bool {
		return this.removeItem(param1);
	}

	// LoadManager.as:67-96
	private function processFile(param1:Event = null):Void {
		var _loc2_:LoadItem = null;
		var _loc3_:Resource = null;
		var _loc4_:Bitmap = null;
		if (As3.truthy(param1)) {
			_loc2_ = this._map.get(param1.target);
			if (!As3.truthy(_loc2_)) {
				return;
			}
			_loc3_ = _loc2_.resource;
			_loc3_.loaded = true;
			if (_loc3_.type == ResourceType.TYPE_BITMAP) {
				_loc4_ = Std.isOfType(cast(param1.target, LoaderInfo).content,
					MovieClip) ? cast(cast(cast(param1.target, LoaderInfo).content, MovieClip).getChildAt(0),
					Bitmap) : cast(cast(param1.target, LoaderInfo).content, Bitmap);
				_loc3_.data = _loc4_;
			} else if (_loc3_.type == ResourceType.TYPE_SWF) {
				_loc3_.applicationDomain = As3.truthy(_loc2_.appDomain) ? _loc2_.appDomain : (As3.truthy(
					this._defaultAppDomain) ? this._defaultAppDomain : cast(param1.target, LoaderInfo).applicationDomain);
				_loc3_.data = cast(param1.target, LoaderInfo).content;
			} else {
				_loc3_.data = cast(param1.target, URLLoader).data;
			}
		}
	}

	// LoadManager.as:98-105
	private function unknownErrorHandler(param1:LoaderEvent):Void {
		var _loc2_:LoadItem = cast(param1.target, LoadItem);
		// 原版把 percent(Number) 传给 int 形参，AS3 隐式截断——Std.int 等价；
		// getTimer()-loadTime 在 loadTime 未设值时 AS3 得 NaN→0（As3.intSub）
		dispatchEvent(this.packageEvent(LoaderEvent.ERROR, this, Std.int(_loc2_.percent),
			As3.intSub(getTimer(), _loc2_.loadTime), this._percentQueue, _loc2_.resource,
			"[LoaderManager] unkown error"));
		++this._itemFailed;
		this.clearCurrentItem(param1);
		this.afterComplete(_loc2_);
	}

	// LoadManager.as:107-110
	public var count(get, never):Int;

	private function get_count():Int {
		return this._queue.length;
	}

	// LoadManager.as:112-117
	public function removeAll():Void {
		this.clear();
		this.reset();
		dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_CHANGED));
	}

	// LoadManager.as:119-193
	private function loadItem():Void {
		var _loc1_:LoadItem = null;
		var _loc2_:Resource = null;
		var _loc3_:URLRequest = null;
		var _loc4_:LoaderContext = null;
		var _loc5_:Dynamic = null;
		var _loc6_:Int = 0;
		var _loc7_:Int = 0;
		var _loc8_:Dynamic = null;
		if (this._status == STATUS_LOADING && As3.truthy(this._queue.length)) {
			_loc6_ = 0;
			_loc7_ = this._queue.length;
			while (_loc6_ < _loc7_ && this._loadingThreadCount < this._maxThreadCount) {
				_loc1_ = cast this._queue[this._loadingThreadCount];
				if (_loc1_ == null) {
					return;
				}
				for (_loc8_ in this._map) {
					if (this._map.get(_loc8_) == _loc1_) {
						return;
					}
				}
				_loc2_ = _loc1_.resource;
				_loc3_ = new URLRequest(_loc2_.url);
				_loc1_.loadTime = getTimer();
				if (_loc2_.type == ResourceType.TYPE_BITMAP || _loc2_.type == ResourceType.TYPE_SWF) {
					if (As3.truthy(_loc1_.appDomain)) {
						_loc4_ = new LoaderContext(_loc2_.type == ResourceType.TYPE_SWF, _loc1_.appDomain);
					} else if (As3.truthy(this._defaultAppDomain)) {
						_loc4_ = new LoaderContext(_loc2_.type == ResourceType.TYPE_SWF, this._defaultAppDomain);
					} else {
						_loc4_ = new LoaderContext(_loc2_.type == ResourceType.TYPE_SWF, new ApplicationDomain());
					}
					// 原版 `!_loc2_.url.indexOf("file://")`：indexOf 命中 0 位才为真
					if (As3.truthy(_loc4_) && (_loc2_.type == ResourceType.TYPE_SWF)
						&& _loc2_.url.indexOf("file://") == 0) {
						_loc4_.securityDomain = SecurityDomain.currentDomain;
					}
					// PORT-NOTE(load-swf)：远程 swf 本地化——openfl 不能按 URL 加载
					// 远程 swf 模块，这里按 CLAUDE.md 的映射换成 shim.LocalSwfLoader
					//（内部走 Assets.getLibrary），LoadManager 其余调用形态不变
					var _loc9_:LocalSwfLoader = new LocalSwfLoader();
					_loc2_.loaderInfo = _loc9_.contentLoaderInfo;
					this.setListeners(_loc9_.contentLoaderInfo);
					// PORT-NOTE(open-sync)：openfl 的 URLLoader/Loader 在 load() 返回前
					// 就同步派发 Event.OPEN（Flash 全部异步、最早也在 load() 返回后），
					// openHandler 查 _map 必须已登记。原版把 _map 赋值放在两分支之后，
					// Flash 语义下「load() 后」与「load() 前」观察等价（之间不会有任何
					// 事件处理器运行），这里按 openfl 的事件时序把登记提到 load() 之前
					this._map.set(_loc9_.contentLoaderInfo, _loc1_);
					_loc9_.load(_loc3_, _loc4_);
					_loc5_ = _loc9_.contentLoaderInfo;
				} else {
					_loc5_ = new URLLoader();
					if (_loc2_.type == ResourceType.TYPE_BINARY) {
						_loc5_.dataFormat = URLLoaderDataFormat.BINARY;
					} else {
						_loc5_.dataFormat = URLLoaderDataFormat.TEXT;
					}
					this.setListeners(_loc5_);
					// PORT-NOTE(open-sync)：同上——登记提前到 load() 之前
					this._map.set(_loc5_, _loc1_);
					cast(_loc5_, URLLoader).load(_loc3_);
				}
				_loc6_++;
				++this._loadingThreadCount;
			}
		}
	}

	// LoadManager.as:195-203
	private function removeListeners(param1:IEventDispatcher):Void {
		param1.removeEventListener(Event.OPEN, this.openHandler);
		param1.removeEventListener(ProgressEvent.PROGRESS, this.progressHandler);
		param1.removeEventListener(Event.COMPLETE, this.completeHandler);
		param1.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.errorHandler);
		param1.removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.httpstatusHandler);
		param1.removeEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);
	}

	// LoadManager.as:205-234
	private function clearCurrentItem(param1:Event = null):Void {
		var target:Dynamic = null;
		var e:Event = param1;
		if (e != null) {
			this.removeListeners(cast(e.target, IEventDispatcher));
		} else {
			for (target in this._map) {
				try {
					if (Reflect.hasField(target, "close")) {
						Reflect.callMethod(target, Reflect.field(target, "close"), []);
					}
					if (Reflect.hasField(target, "unloadAndStop")) {
						Reflect.callMethod(target, Reflect.field(target, "unloadAndStop"), []);
					}
				} catch (e2:Dynamic) {
				}
				this.removeListeners(target);
			}
		}
	}

	// LoadManager.as:236-239
	public function add(param1:String, param2:ApplicationDomain = null):Resource {
		return this.addAt(param1, this._queue.length, param2);
	}

	// LoadManager.as:241-248
	private function errorHandler(param1:Dynamic):Void {
		var _loc2_:LoadItem = this._map.get(param1.target);
		// 同 unknownErrorHandler：percent(Number) → int 形参的隐式截断；
		// getTimer()-loadTime 在 loadTime 未设值时 AS3 得 NaN→0（As3.intSub）
		dispatchEvent(this.packageEvent(LoaderEvent.ERROR, this, Std.int(_loc2_.percent),
			As3.intSub(getTimer(), _loc2_.loadTime), this._percentQueue, _loc2_.resource, param1.text));
		++this._itemFailed;
		this.clearCurrentItem(param1);
		this.afterComplete(_loc2_);
	}

	// LoadManager.as:250-253
	private function openHandler(param1:Event = null):Void {
		dispatchEvent(this.packageEvent(LoaderEvent.START, this, 0, 0, this._percentQueue,
			this._map.get(param1.target).resource));
	}

	// LoadManager.as:255-258
	public var maxThreadCount(get, set):UInt;

	private function get_maxThreadCount():UInt {
		return this._maxThreadCount;
	}

	// LoadManager.as:260-285
	public function addAt(param1:String, param2:Int, param3:ApplicationDomain = null):Resource {
		var _loc5_:LoadItem = null;
		var _loc4_:Resource = this.findItem(param1);
		if (_loc4_ == null) {
			_loc4_ = new Resource();
			_loc4_.url = param1;
			_loc4_.type = ResourceType.getType(param1);
			_loc5_ = new LoadItem();
			_loc5_.percent = 0;
			_loc5_.resource = _loc4_;
			_loc5_.appDomain = param3;
			if (param2 < 0 || param2 > this._queue.length) {
				return null;
			}
			if (this._status == STATUS_LOADING && param2 == 0) {
				return null;
			}
			// AS3 splice(index, 0, item) 是插入；Haxe Array.splice 不带插入参数，
			// 等价 insert
			this._queue.insert(param2, _loc5_);
			return _loc4_;
		}
		return null;
	}

	// LoadManager.as:287-320
	private function afterComplete(param1:LoadItem):Void {
		var _loc2_:UInt = 0;
		var _loc3_:UInt = this._queue.length;
		while (_loc2_ < _loc3_) {
			if (this._queue[_loc2_] == param1) {
				this._queue.splice(_loc2_, 1);
			}
			_loc2_++;
		}
		if (this._queue.length == 0) {
			this.setStatus(STATUS_STOPPED);
		}
		if (this._loadingThreadCount > 0) {
			--this._loadingThreadCount;
		}
		if (param1.percent == 100) {
			dispatchEvent(this.packageEvent(LoaderEvent.COMPLETE, this, param1.loadTime, 100, this._percentQueue,
				param1.resource));
		}
		if (As3.truthy(this._queue.length)) {
			this.loadItem();
		} else {
			dispatchEvent(this.packageEvent(LoaderEvent.QUEUE_COMPLETE, this, getTimer() - this._startTime, 100, 100,
				param1.resource));
			this.clear();
		}
	}

	// LoadManager.as:322-356
	private function removeItem(param1:String, param2:Int = -1):Bool {
		var _loc3_:Dynamic = null;
		var _loc4_:Int = 0;
		var _loc5_:Resource = null;
		var _loc6_:Int = 0;
		for (_loc3_ in this._map) {
			if (this._status == STATUS_LOADING && this._map.get(_loc3_).url == param1) {
				return false;
			}
		}
		if (param1 != null && param1.length > 4) {
			_loc4_ = this._queue.length;
			_loc6_ = 0;
			while (_loc6_ < _loc4_) {
				_loc5_ = cast(this._queue[_loc6_], LoadItem).resource;
				if (_loc5_.url == param1) {
					this._queue.splice(_loc6_, 1);
					return true;
				}
				_loc6_++;
			}
		}
		if (param2 > -1) {
			this._queue.splice(param2, 1);
			return true;
		}
		return false;
	}

	// LoadManager.as:358-361
	private function set_maxThreadCount(param1:UInt):UInt {
		this._maxThreadCount = Std.int(Math.max(param1, 0));
		return param1;
	}

	// LoadManager.as:363-366
	public var loadingThreadCount(get, never):UInt;

	private function get_loadingThreadCount():UInt {
		return this._loadingThreadCount;
	}

	// LoadManager.as:368-375
	public function addEventListeners(param1:Dynamic):Void {
		var _loc2_:String = null;
		for (_loc2_ in this._eventList) {
			addEventListener(_loc2_, param1, false, 0, false);
		}
	}

	// LoadManager.as:377-390
	private function reset():Void {
		this._itemLoaded = 0;
		this._itemFailed = 0;
		this._loadingThreadCount = 0;
		this._percentQueue = 0;
		this._map = new Dictionary();
		this._queue = [];
		this._loadingThreadCount = 0;
		if (this._status != STATUS_STOPPED) {
			this.setStatus(STATUS_STOPPED);
		}
	}

	// LoadManager.as:392-402
	private function completeHandler(param1:Event = null):Void {
		var _loc2_:LoadItem = this._map.get(param1.target);
		_loc2_.loadTime = As3.intSub(getTimer(), _loc2_.loadTime);
		this.processFile(param1);
		this._map.remove(param1.target);
		_loc2_.percent = 100;
		++this._itemLoaded;
		this.clearCurrentItem(param1);
		this.afterComplete(_loc2_);
	}

	// LoadManager.as:404-411
	private function clear(param1:Event = null):Void {
		this.clearCurrentItem(param1);
		if (this._itemFailed == 0) {
			this.reset();
		}
	}

	// LoadManager.as:413-416
	public function removeAt(param1:Int):Bool {
		return this.removeItem(null, param1);
	}

	// LoadManager.as:417-427
	public function start():Void {
		if (this._status == STATUS_STOPPED && this._queue.length > 0) {
			this._startTime = getTimer();
			this.setStatus(STATUS_LOADING);
			dispatchEvent(new LoaderEvent(LoaderEvent.QUEUE_START));
			this.loadItem();
		}
	}

	// LoadManager.as:429-457
	private function progressHandler(param1:ProgressEvent):Void {
		var _loc4_:Dynamic = null;
		var _loc5_:Float = 0;
		var _loc6_:Int = 0;
		var _loc2_:Int = this._queue.length;
		var _loc3_:LoadItem = this._map.get(param1.target);
		this._percentQueue = 0;
		if (param1.bytesTotal == 0) {
			_loc3_.percent = 80;
		} else {
			_loc3_.percent = param1.bytesLoaded / param1.bytesTotal * 100;
		}
		for (_loc4_ in this._map) {
			if (As3.truthy(cast(this._map.get(_loc4_), LoadItem).percent)) {
				this._percentQueue += cast(this._map.get(_loc4_), LoadItem).percent;
			}
		}
		this._percentQueue = (100 * this._itemLoaded + this._percentQueue) / (this._itemLoaded + this._itemFailed + _loc2_);
		_loc5_ = _loc3_.percent;
		// loadTime/_startTime 未设值时 AS3 得 NaN→int 0（As3.intSub）
		_loc6_ = As3.intSub(getTimer(), _loc3_.loadTime);
		dispatchEvent(this.packageEvent(LoaderEvent.PROGRESS, this, _loc6_, _loc5_, this._percentQueue,
			_loc3_.resource));
		dispatchEvent(this.packageEvent(LoaderEvent.QUEUE_PROGRESS, this, As3.intSub(getTimer(), this._startTime),
			_loc5_, this._percentQueue, _loc3_.resource));
	}

	// LoadManager.as:459-466
	public function removeEventListeners(param1:Dynamic):Void {
		var _loc2_:String = null;
		for (_loc2_ in this._eventList) {
			removeEventListener(_loc2_, param1);
		}
	}

	// LoadManager.as:468-483
	private function findItem(param1:String):Resource {
		var _loc3_:Resource = null;
		var _loc2_:Int = this._queue.length;
		var _loc4_:Int = 0;
		while (_loc4_ < _loc2_) {
			_loc3_ = cast(this._queue[_loc4_], LoadItem).resource;
			if (_loc3_.url == param1) {
				return _loc3_;
			}
			_loc4_++;
		}
		return null;
	}

	// LoadManager.as:485-487
	private function httpstatusHandler(param1:HTTPStatusEvent):Void {
	}

	// LoadManager.as:489-492
	public var status(get, never):String;

	private function get_status():String {
		return this._status;
	}

	// LoadManager.as:494-497（单测用它把状态机摆到 loading，绕开真实加载）
	private function setStatus(param1:String):Void {
		this._status = param1;
	}

	// LoadManager.as:499-515
	private function packageEvent(param1:String, param2:Dynamic, param3:Int, param4:Float, param5:Float,
			param6:Resource, param7:String = ""):LoaderEvent {
		var _loc8_:LoaderEvent = new LoaderEvent(param1);
		_loc8_.loader = param2;
		_loc8_.percentItem = param4;
		_loc8_.percentQueue = param5;
		_loc8_.loadTime = param3;
		_loc8_.item = param6;
		_loc8_.queueCount = this._itemLoaded;
		_loc8_.failCount = this._itemFailed;
		_loc8_.queueLength = this._queue.length;
		if (!As3.truthy(param7)) {
			_loc8_.msg = param7;
		}
		return _loc8_;
	}

	// LoadManager.as:517-525
	private function setListeners(param1:IEventDispatcher):Void {
		param1.addEventListener(Event.OPEN, this.openHandler, false, 0, false);
		param1.addEventListener(ProgressEvent.PROGRESS, this.progressHandler, false, 0, false);
		param1.addEventListener(Event.COMPLETE, this.completeHandler, false, 0, false);
		param1.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.httpstatusHandler, false, 0, false);
		param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.errorHandler, false, 0, false);
		param1.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler, false, 0, false);
	}
}

// LoadManager.as:532-547：AS3 与 LoadManager 同文件的无修饰类（文件级
// internal）。Haxe 里保持同文件；不加 private——private 会把可见性锁死在本模块
// 内，单测无法构造（AS3 的文件 internal 在 Haxe 没有逐字等价，取最接近的映射）。
class LoadItem {
	// LoadManager.as:535
	public var loadTime:Int;

	// LoadManager.as:537
	public var appDomain:ApplicationDomain;

	// LoadManager.as:539
	public var percent:Float;

	// LoadManager.as:541
	public var resource:Resource;

	// LoadManager.as:543-546
	public function new() {
	}
}
