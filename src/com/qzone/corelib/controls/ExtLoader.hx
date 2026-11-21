package com.qzone.corelib.controls;

import com.qzone.utils.ImageSizeUtil;
import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.system.SecurityDomain;
import openfl.utils.ByteArray;
import shim.As3;

/**
 * com.qzone.corelib.controls.ExtLoader —— ExtLoader.as 逐句对应（issue #18
 * qui 收尾：corelib 控件片）。外链图加载控件：内嵌 Loader + 描边框，
 * ImageSizeUtil 按 _style 摆放，Bitmap smoothing/cacheAsBitmap；可选缓存
 * 上一张（load 时克隆 bitmapData 留底）；IO 失败按 _autoRetry 重试。
 * `addEventListener` 覆写把 COMPLETE/PROGRESS/部分 IO 错误转发到内层
 * contentLoaderInfo（调用方挂的是加载事件而非容器事件）。
 */
@:keep
class ExtLoader extends Sprite {
	// ExtLoader.as:19-49
	public static final ONLOAD_INIT:String = "onLoadInit";

	private var _autoRetry:Int;

	public var defaultWidth:Float;

	public var defaultHeight:Float;

	private var _border:Sprite;

	private var _lc:LoaderContext;

	private var _retryNum:Int = 0;

	private var _req:URLRequest;

	private var _cachePrevImage:Bool;

	private var _prevImage:Bitmap;

	private var _h:Float;

	private var _style:Int;

	private var _smoothing:Bool;

	public var contentUrl:String;

	private var _w:Float;

	private var _loader:Loader;

	// :51-68
	public function new(param1:Float = 150, param2:Float = 80, param3:Int = -1, param4:Bool = false, param5:Int = 0,
			param6:Bool = false, param7:Int = 1) {
		super();
		this._w = param1;
		this._h = param2;
		this._style = param3;
		this._autoRetry = param7;
		this._smoothing = param4;
		this._cachePrevImage = param6;
		this._lc = new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
		this._loader = new Loader();
		addChild(this._loader);
		this._border = new Sprite();
		this._border.graphics.lineStyle(0, 0, param5 >= 1 ? 1 : 0);
		this._border.graphics.drawRect(0, 0, this._w, this._h);
		this._border.graphics.endFill();
		addChild(this._border);
	}

	// :70-73（`this._loader.height || 0`）
	public var contentHeight(get, never):Float;

	private function get_contentHeight():Float {
		return As3.or(this._loader.height, 0);
	}

	// :75-93
	private function __onLoaderCompleteHandler(param1:Event):Void {
		this._retryNum = 0;
		if (this._cachePrevImage) {
			this._loader.alpha = 0;
			setChildIndex(this._loader, numChildren - 1);
		}
		this.defaultWidth = As3.or(this._loader.content.width, 0);
		this.defaultHeight = As3.or(this._loader.content.height, 0);
		ImageSizeUtil.setSize2(this._loader, 0, 0, this._w, this._h, this._style);
		if (Std.isOfType(this._loader.content, Bitmap) && this._smoothing) {
			cast(this._loader.content, Bitmap).smoothing = true;
		}
		this._loader.content.cacheAsBitmap = true;
		this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.__onLoaderCompleteHandler);
		dispatchEvent(new Event(ONLOAD_INIT));
	}

	// :95-98
	public var contentWidth(get, never):Float;

	private function get_contentWidth():Float {
		return As3.or(this._loader.width, 0);
	}

	// :100-103
	public var loader(get, never):Loader;

	private function get_loader():Loader {
		return this._loader;
	}

	// :105-115（原版 Function 形参 → Dynamic；泛型签名靠 Dynamic 统一）
	override public function addEventListener(param1:String, param2:Dynamic, param3:Bool = false, param4:Int = 0,
			param5:Bool = false):Void {
		// PORT-NOTE: IOErrorEvent.DISK_ERROR/NETWORK_ERROR/VERIFY_ERROR 在
		// openfl 里被注释掉不可引用（openfl/events/IOErrorEvent.hx:20,76,77），
		// 用 Flash Player 原值字面量（"diskError"/"networkError"/"verifyError"）。
		if (param1 == Event.COMPLETE || param1 == ProgressEvent.PROGRESS || param1 == "diskError"
			|| param1 == "networkError" || param1 == "verifyError") {
			this._loader.contentLoaderInfo.addEventListener(param1, param2, param3, param4, param5);
		} else {
			super.addEventListener(param1, param2, param3, param4, param5);
		}
	}

	// :117-127
	private function __onLoaderIOErrorHandler(param1:IOErrorEvent):Void {
		if (this._retryNum < this._autoRetry && As3.truthy(this._autoRetry)) {
			this._loader.load(this._req, this._lc);
			++this._retryNum;
			return;
		}
		this._retryNum = 0;
		dispatchEvent(param1);
	}

	// :129-137
	public function unloadPrevImage():Void {
		if (this._prevImage != null) {
			removeChild(this._prevImage);
			this._prevImage.bitmapData.dispose();
			this._prevImage = null;
		}
	}

	// :139-163
	public function load(param1:String):Void {
		if (this._cachePrevImage) {
			if (Std.isOfType(this._loader.content, Bitmap)) {
				this.unloadPrevImage();
				this._prevImage = new Bitmap(cast(this._loader.content, Bitmap).bitmapData.clone(), "auto", true);
				this._prevImage.x = this._loader.x;
				this._prevImage.y = this._loader.y;
				this._prevImage.width = this._loader.width;
				this._prevImage.height = this._loader.height;
				addChild(this._prevImage);
			}
		}
		this.unload();
		this._req = new URLRequest(param1);
		this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.__onLoaderCompleteHandler);
		if (this._autoRetry > 0) {
			this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.__onLoaderIOErrorHandler);
		}
		this.contentUrl = param1;
		this._loader.load(this._req, this._lc);
	}

	// :165-172（AS3 纯 setter style）
	public var style(never, set):Int;

	private function set_style(param1:Int):Int {
		if (this._loader != null) {
			this._style = param1;
			ImageSizeUtil.setSize2(this._loader, 0, 0, this._w, this._h, this._style);
		}
		return param1;
	}

	// :174-178
	public function loadBytes(param1:ByteArray, param2:LoaderContext = null):Void {
		this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.__onLoaderCompleteHandler);
		this._loader.loadBytes(param1, param2);
	}

	// :180-190（AS3 catch(err:Error) 吞异常：内容非位图/已卸载时的强转失败）
	public function unload():Void {
		try {
			cast(this._loader.content, Bitmap).bitmapData.dispose();
			this._loader.unload();
		} catch (err:Dynamic) {}
	}
}
