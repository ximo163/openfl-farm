package com.qzone.corelib.net;

import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.TimerEvent;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.system.SecurityDomain;
import openfl.utils.Timer;
import shim.As3;
import shim.LocalSwfLoader;

// RSLLoader.as 逐句对应。
// PORT-NOTE(load-swf)：`new Loader()` → shim.LocalSwfLoader（远程 swf 本地化，
// 见该类头注释；load 调用形态不变）。本类在本 swf 内只被主程序经
// CommonData.rslLoader 使用。
class RSLLoader {
	// RSLLoader.as:18
	public var rsls:Array<Dynamic> = [];

	// RSLLoader.as:20
	private var _lc:LoaderContext;

	// RSLLoader.as:22。Function → Dynamic
	public var listCompleteFn:Dynamic;

	// RSLLoader.as:24
	public var securityDomain:SecurityDomain;

	// RSLLoader.as:26
	private var _retryUrls:Dynamic = {};

	// RSLLoader.as:28
	private var _url:String;

	// RSLLoader.as:30
	private var _loader:LocalSwfLoader;

	// RSLLoader.as:32
	private var _urls:Dynamic = {};

	// RSLLoader.as:34
	private var _checkTimer:Timer;

	// RSLLoader.as:36
	public var contentCheckDelay:Int = 3000;

	// RSLLoader.as:38
	private var _index:Int;

	// RSLLoader.as:40
	public var ignoreError:Bool;

	// RSLLoader.as:42
	private var _req:URLRequest;

	// RSLLoader.as:44。Function → Dynamic
	public var completeFn:Dynamic;

	// RSLLoader.as:46
	public var applicationDomain:ApplicationDomain;

	// RSLLoader.as:48
	public var faultList:Array<Dynamic> = [];

	// RSLLoader.as:50。Function → Dynamic
	public var errorFn:Dynamic;

	// RSLLoader.as:52
	private var _loading:Bool;

	// RSLLoader.as:54
	public var retryTimes:UInt = 1;

	// RSLLoader.as:56-73
	public function new() {
		this.ignoreError = false;
		this.applicationDomain = ApplicationDomain.currentDomain;
		this._lc = new LoaderContext();
		this._req = new URLRequest();
		this._loader = new LocalSwfLoader();
		this._index = 0;
		this._loading = false;
		this._checkTimer = new Timer(this.contentCheckDelay, 1);
		this._checkTimer.addEventListener(TimerEvent.TIMER, this.onTimeOut);
		this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoadComplete);
		this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
		this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoadError);
		this._loader.contentLoaderInfo.addEventListener(Event.OPEN, this.onLoadOpen);
		this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
	}

	// RSLLoader.as:75-98
	private function loadRSL():Void {
		this._url = Reflect.field(this.rsls[this._index], "url");
		if (this._url == "") {
			this._loading = false;
			++this._index;
			this.onLoadComplete(null);
		} else {
			this._req.url = this._url;
			this._loading = true;
			++this._index;
			if (Reflect.field(this._urls, this._url) == true) {
				this.onLoadComplete(null);
			} else {
				this._loader.load(this._req, this._lc);
			}
		}
	}

	// RSLLoader.as:100-103
	public var loader(get, never):Loader;

	private function get_loader():Loader {
		return this._loader;
	}

	// RSLLoader.as:105-115。`errorFn && errorFn(param1)` 短路调用
	private function onLoadError(param1:Event):Void {
		this._checkTimer.stop();
		if (As3.truthy(this.errorFn)) {
			this.errorFn(param1);
		}
		var _loc2_:String = this._req.url;
		this.faultList.push(_loc2_);
		if (this.ignoreError) {
			this.loadNext(param1);
		}
	}

	// RSLLoader.as:117-119
	private function onLoadProgress(param1:ProgressEvent):Void {
	}

	// RSLLoader.as:121-125
	private function loadAllComplete(param1:Event):Void {
		this._loading = false;
		if (As3.truthy(this.listCompleteFn)) {
			this.listCompleteFn(param1);
		}
	}

	// RSLLoader.as:127-130
	public var loading(get, never):Bool;

	private function get_loading():Bool {
		return this._loading;
	}

	// RSLLoader.as:132-138
	private function onLoadComplete(param1:Event):Void {
		this._checkTimer.stop();
		Reflect.setField(this._urls, this._url, true);
		if (As3.truthy(this.completeFn)) {
			this.completeFn(param1);
		}
		this.loadNext(param1);
	}

	// RSLLoader.as:140-148
	public function reset():Void {
		this._urls = {};
		this.rsls = [];
		this.faultList = [];
		this._retryUrls = {};
		this._index = 0;
		this._loading = false;
	}

	// RSLLoader.as:150-154
	private function onLoadOpen(param1:Event):Void {
		this._checkTimer.reset();
		this._checkTimer.start();
	}

	// RSLLoader.as:156-178
	private function loadRetry():Void {
		var _loc1_:String = this._req.url;
		if (this.retryTimes == 0 || Reflect.field(this._retryUrls, _loc1_) >= this.retryTimes) {
			trace("RSLLoader timeout, force to load next one!");
			this.faultList.push(_loc1_);
			this.loadNext(null);
		} else {
			trace("RSLLoader Retry Load Again!");
			this._loader.load(this._req, this._lc);
			if (Reflect.field(this._retryUrls, _loc1_) == null) {
				Reflect.setField(this._retryUrls, _loc1_, 1);
			} else {
				Reflect.setField(this._retryUrls, _loc1_, Reflect.field(this._retryUrls, _loc1_) + 1);
			}
		}
	}

	// RSLLoader.as:180-208
	public function load(param1:Array<Dynamic>):Void {
		var _loc2_:Dynamic = null;
		var _loc3_:String = null;
		for (_loc2_ in param1) {
			if (!(_loc2_ == null || !Reflect.hasField(_loc2_, "url"))) {
				_loc3_ = Reflect.field(_loc2_, "url");
				if (!(_loc3_ == "" || _loc3_ == null)) {
					// 原版 `=== undefined`：只判缺失，不判 null（这里存的值只有布尔）
					if (Reflect.field(this._urls, _loc3_) == null) {
						this.rsls.push(_loc2_);
						Reflect.setField(this._urls, _loc3_, false);
					}
				}
			}
		}
		if (this._loading == false) {
			if (this._index < this.rsls.length) {
				this._lc.applicationDomain = this.applicationDomain;
				this._lc.securityDomain = this.securityDomain;
				this.loadRSL();
			}
		}
	}

	// RSLLoader.as:210-214
	private function onTimeOut(param1:Event):Void {
		this._checkTimer.stop();
		this.loadRetry();
	}

	// RSLLoader.as:216-226
	private function loadNext(param1:Event):Void {
		if (this._index < this.rsls.length) {
			this.loadRSL();
		} else {
			this.loadAllComplete(param1);
		}
	}
}
