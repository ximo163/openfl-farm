package common.view.floating;

import common.CommonData;
import common.Consts;
import common.GetCropID;
import interfaces.IMsgCenter;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
import openfl.system.SecurityDomain;
import shim.As3;

/**
 * common.view.floating.HarvestAnimationCustom —— HarvestAnimationCustom.as
 * 逐句对应（issue #9）。自定义收获动画：Loader 按作物收获素材 URL
 * （GetCropID.getHarvrstUrl）装载，content 派发 "end" 后卸载自关。
 * PORT-NOTE: Loader.load(URLRequest) 保持原调用形态（CLAUDE.md：远程 swf
 * → Assets.getLibrary 的映射只落在 mcloader 加载器类）；html5 运行期的
 * swf 装载能力差异不在本类处理。
 */
@:keep
class HarvestAnimationCustom extends FloatingBase {
	// HarvestAnimationCustom.as:18
	private var _loader:Loader;

	// HarvestAnimationCustom.as:20
	private var _text:String;

	// HarvestAnimationCustom.as:22-29
	public function new(param1:IMsgCenter) {
		super(param1);
		this.floatName = Consts.FLOAT_TYPE_HAC;
		this._loader = new Loader();
		addChild(this._loader);
		this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemoveFromStage, false, 0, true);
	}

	// HarvestAnimationCustom.as:31-35
	private function onRemoveFromStage(param1:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemoveFromStage);
		this.end();
	}

	// HarvestAnimationCustom.as:37-45
	override public function start(param1:Dynamic):Void {
		super.start(param1);
		if (param1 != null && Reflect.hasField(param1, "type") && Reflect.hasField(param1, "cId")) {
			this.text = Std.string(Reflect.field(param1, "text"));
			this.setContent(Std.string(Reflect.field(param1, "type")), As3.intOf(Reflect.field(param1, "cId")));
		}
	}

	// HarvestAnimationCustom.as:47-71（cId==28 特判归零偏移；装载监听挂
	// COMPLETE/IO_ERROR/SECURITY_ERROR）
	public function setContent(param1:String, param2:Int):Void {
		if (this._loader == null) {
			return;
		}
		this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onComplete);
		this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onComplete);
		this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onComplete);
		var _loc3_:String = GetCropID.getHarvrstUrl(param2);
		if (_loc3_ == "") {
			return;
		}
		this._loader.x = 40 * 0.75;
		this._loader.y = -135 * 0.75;
		if (param2 == 28) {
			this._loader.x = 0;
			this._loader.y = 0;
		}
		var _loc4_:URLRequest = new URLRequest(_loc3_);
		var _loc5_:LoaderContext = new LoaderContext(false, CommonData.applicationDomain, SecurityDomain.currentDomain);
		this._loader.load(_loc4_, _loc5_);
	}

	// HarvestAnimationCustom.as:73-75
	public var text(never, set):String;

	private function set_text(param1:String):String {
		this._text = param1;
		return param1;
	}

	// HarvestAnimationCustom.as:78-88（end：摘三个装载监听后置空 loader）
	override public function end():Void {
		super.end();
		if (this._loader != null) {
			this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onComplete);
			this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onComplete);
			this._loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onComplete);
			this._loader = null;
		}
	}

	// HarvestAnimationCustom.as:90-97（content 自报 "end"：卸载、摘子、置空
	// 后 close）
	private function onEnd(param1:Event):Void {
		this._loader.content.removeEventListener("end", this.onEnd);
		this._loader.unload();
		removeChild(this._loader);
		this._loader = null;
		super.close();
	}

	// HarvestAnimationCustom.as:99-116（装载完成挂 content 的 "end"；失败
	// 直接 close）
	private function onComplete(param1:Event):Void {
		if (this._loader == null) {
			return;
		}
		this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onComplete);
		this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onComplete);
		this._loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onComplete);
		if (param1.type == Event.COMPLETE) {
			this._loader.content.addEventListener("end", this.onEnd);
		} else {
			super.close();
		}
	}
}
