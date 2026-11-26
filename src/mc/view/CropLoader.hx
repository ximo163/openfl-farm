package mc.view;

import openfl.display.Loader;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLRequest;
import shim.As3;

/**
 * mc.view.CropLoader —— CropLoader.as 逐句对应（issue #87「通用视图」片）。
 * 队列加载器：load 收 url 数组逐个走 Loader，每件完成派 ITEM_COMPLETE 再
 * loadNext，排空 comp() 派 Event.COMPLETE 并拆监听 close 置空；_material
 * 模式 contents 记 applicationDomain、否则记 content。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/CropLoader.as。
 */
@:keep
class CropLoader extends EventDispatcher {
	// CropLoader.as:15
	public static final ITEM_COMPLETE:String = "item_complete";

	// CropLoader.as:17-23
	private var _contents:Dynamic;
	private var _loader:Loader;
	private var _material:Bool;
	private var _urlArray:Array<Dynamic>;

	// CropLoader.as:25-28
	public function new() {
		super();
	}

	// CropLoader.as:30-34（url 字符串键写入走 Reflect——Dynamic 下标在 cpp
	// 编不过，lessons #19）
	private function onIOError(param1:IOErrorEvent):Void {
		Reflect.setField(this._contents, this._loader.contentLoaderInfo.url, "error");
		this.loadNext();
	}

	// CropLoader.as:36-38（原文即空体）
	private function onHttpStatus(param1:HTTPStatusEvent):Void {}

	// CropLoader.as:40-58（param1==null 抛 "需要设置urlArray或urls参数"；
	// 首用建 Loader 挂四监听，setTimeout 50ms 起 loadNext）
	public function load(param1:Array<Dynamic> = null, param2:Bool = false):Void {
		if (param1 == null) {
			throw new Error("需要设置urlArray或urls参数");
		}
		this._contents = {};
		this._urlArray = param1;
		this._material = param2;
		if (this._loader == null) {
			this._loader = new Loader();
			this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onComp);
			this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
			this._loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.onHttpStatus);
			this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.onProgress);
		}
		As3.setTimeout(this.loadNext, 50);
	}

	// CropLoader.as:60-72。PORT-NOTE(原版缺陷照抄)：非 material 分支的键是
	// contentLoaderInfo **对象**而非 url 字符串（CropLoader.as:68）——AS3 对
	// 对象键按 toString 强制（"[object LoaderInfo]"），每次写入互相覆盖且
	// 无人能按 url 读回，是死写。Haxe 侧 Std.string 复刻 toString 强制通道，
	// 具体串值随运行时异（死写无消费方，偏差无行为影响）
	private function onComp(param1:Event):Void {
		if (this._material) {
			// currentTarget 是 Object/Dynamic——applicationDomain 是 LoaderInfo
			// 真属性，强类型化读（lessons #8 裸读陷阱）
			Reflect.setField(this._contents, this._loader.contentLoaderInfo.url,
				cast(param1.currentTarget, openfl.display.LoaderInfo).applicationDomain);
		} else {
			Reflect.setField(this._contents, Std.string(this._loader.contentLoaderInfo), this._loader.contentLoaderInfo.content);
		}
		dispatchEvent(new Event(CropLoader.ITEM_COMPLETE));
		this.loadNext();
	}

	// CropLoader.as:74-89
	private function comp():Void {
		dispatchEvent(new Event(Event.COMPLETE));
		this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onComp);
		this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
		this._loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.onHttpStatus);
		this._loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, this.onProgress);
		try {
			this._loader.close();
		} catch (e:Dynamic) {}
		this._loader = null;
	}

	// CropLoader.as:91-99
	public var urlArray(get, set):Array<Dynamic>;

	private function get_urlArray():Array<Dynamic> {
		return this._urlArray;
	}

	private function set_urlArray(param1:Array<Dynamic>):Array<Dynamic> {
		this._urlArray = param1;
		return param1;
	}

	// CropLoader.as:101-116（`if(_loc1_)` 真值门：falsy 串不 load 也不 comp、
	// 纯消耗一格——eval/cpp 上 String 直接判 truthy 走 As3.truthy 等价）
	private function loadNext():Void {
		var _loc1_:String = null;
		if (this._urlArray.length > 0) {
			_loc1_ = this._urlArray.shift();
			if (As3.truthy(_loc1_)) {
				this._loader.load(new URLRequest(_loc1_));
			}
		} else {
			this.comp();
		}
	}

	// CropLoader.as:118-121
	public var contents(get, never):Dynamic;

	private function get_contents():Dynamic {
		return this._contents;
	}

	// CropLoader.as:123-125（原文即空体）
	private function onProgress(param1:ProgressEvent):Void {}
}
