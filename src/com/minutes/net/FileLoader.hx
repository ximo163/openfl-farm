package com.minutes.net;

import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.errors.Error;
import openfl.events.TimerEvent;
import openfl.net.URLRequest;
import openfl.utils.Timer;

/**
 * com.minutes.net.FileLoader —— FileLoader.as 逐句对应（issue #86 牧场库
 * 底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/net/FileLoader.as。
 *
 * PORT-NOTE（`this.contents[key] = v` 动态键写，FileLoader.as:50/:94/
 * :122/:167）：contents 是 Object（键是 URL 串）——动态键写落
 * Reflect.setField（URLVariables 同款先例 EventRecorder.hx:184）。
 * PORT-NOTE（`if(_loc2_)`（:108）是 AS3 真值——空串/null 为假，
 * shim.As3.truthy 等价）。
 * PORT-NOTE（`this.preTime = getTimer()`，:111/:161）：preTime 是 Number
 * 字段存 int 毫秒——shim.As3.getTimer 返 Int，赋进 Float 通道直翻。
 * PORT-NOTE（comp 的 try/catch 吞 loader.close() 错，:144-150）：原版
 * close 未加载时抛错被吞——Haxe 同构 try/catch。
 */
@:keep
class FileLoader extends EventDispatcher {
	// FileLoader.as:17-27
	private var timer:Timer;
	private var _contents:Dynamic;
	private var _urlArray:Array<Dynamic>;
	private var preTime:Float = 0;
	private var _loader:Loader;
	private var _index:Int = 0;

	// :29-32
	public function new() {
		super();
	}

	// :34-37
	public var contents(get, never):Dynamic;

	private function get_contents():Dynamic {
		return this._contents;
	}

	// :39-42
	public var urlArray(get, set):Array<Dynamic>;

	private function get_urlArray():Array<Dynamic> {
		return this._urlArray;
	}

	// :44-60（`new Object()` → 匿名结构 {}）
	private function onIOError(param1:IOErrorEvent):Void {
		if (this.contents == null) {
			this._contents = {};
		}
		Reflect.setField(this.contents, this.urlArray[this._index], "error");
		if (this._index + 1 >= this.urlArray.length) {
			this.comp();
		} else {
			this._index += 1;
			this.load();
		}
	}

	// :62-64
	private function onProgress(param1:ProgressEvent):Void {
	}

	// :66-114（`throw new Error` 直翻；`if(_loc2_)` 真值判见类头 PORT-NOTE）
	public function load(param1:Array<Dynamic> = null):Void {
		var _loc2_:String = null;
		if (param1 != null) {
			this.urlArray = param1;
		}
		if (this.urlArray == null) {
			throw new Error("需要设置urlArray或urls参数");
		}
		if (this._loader == null) {
			this._loader = new Loader();
			this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onComp);
			this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
			this._loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.onHttpStatus);
			this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
			this.timer = new Timer(1000);
			this.timer.addEventListener(TimerEvent.TIMER, this.timerEventHandler);
			this.timer.start();
		}
		if (this.urlArray.length == 0 || this.urlArray[this._index] == "") {
			if (this.contents == null) {
				this._contents = {};
			}
			Reflect.setField(this.contents, this.urlArray[this._index], "");
			if (this._index + 1 >= this.urlArray.length) {
				this.comp();
			} else {
				this._index += 1;
				this.load();
			}
		} else {
			_loc2_ = this.urlArray[this._index];
			if (shim.As3.truthy(_loc2_)) {
				this._loader.load(new URLRequest(_loc2_));
				this.preTime = shim.As3.getTimer();
			}
		}
	}

	// :116-132（`this.contents[...] = content`——加载产物 DisplayObject
	// 进 Object 动态键，Reflect.setField 同通道）
	private function onComp(param1:Event):Void {
		if (this.contents == null) {
			this._contents = {};
		}
		Reflect.setField(this.contents, this.urlArray[this._index], this._loader.contentLoaderInfo.content);
		if (this._index + 1 >= this.urlArray.length) {
			this.comp();
		} else {
			this._index += 1;
			this.load();
		}
	}

	// :134-152
	private function comp():Void {
		dispatchEvent(new Event(Event.COMPLETE));
		this.timer.stop();
		this.timer = null;
		this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onComp);
		this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
		this._loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.onHttpStatus);
		this._loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
		this._index = 0;
		try {
			this._loader.close();
		} catch (e:Dynamic) {}
		this._loader = null;
	}

	// :154-156
	private function onHttpStatus(param1:HTTPStatusEvent):Void {
	}

	// :158-185（`var e:TimerEvent = param1` 死变量原样保留）
	private function timerEventHandler(param1:TimerEvent):Void {
		var e:TimerEvent = param1;
		if (shim.As3.getTimer() - this.preTime > 1000 * 10) {
			if (this.contents == null) {
				this._contents = {};
			}
			Reflect.setField(this.contents, this.urlArray[this._index], "error");
			if (this._index + 1 >= this.urlArray.length) {
				this.comp();
			} else {
				this._index += 1;
				try {
					this._loader.close();
				} catch (e:Dynamic) {}
				this.load();
			}
		}
	}

	// :187-190
	private function set_urlArray(param1:Array<Dynamic>):Array<Dynamic> {
		this._urlArray = param1;
		return param1;
	}
}
