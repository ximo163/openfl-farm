package mc.view.common;

import common.CommonData;
import common.MaterialLib;
import mc.view.CropLoader;
import mc.view.farm.GetCropID;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;

/**
 * mc.view.common.MaterialLoaderProxy —— MaterialLoaderProxy.as 逐句对应
 * （issue #87 牧场「通用视图」片；#19 签名面 stub 充真身）。加载型素材
 * 格：setContent 按 type 分派（动物图标/仓库/动物 swf/卡片/野生掉落/
 * 猎狗/背景），加载中挂 MaterialLoading 底图、完成换装、失败换
 * MaterialLoadError 并派 "error"。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/MaterialLoaderProxy.as。
 *
 * PORT-NOTE（`getMaterial(...) as Sprite/DisplayObject` 各处）：as 失配
 * -null 语义走 isOfType 门 + 直取（lessons #7）。原文无 null 守卫的
 * 直取（setMaterial 的 addChild、onLoaderError 的 _bg 读取）逐字保留。
 * PORT-NOTE（`"Card_" + this._id.toString()`/param2.toString()）：AS3
 * int.toString() → Std.string（lessons——js 偶然可用、cpp typer 红）。
 * PORT-NOTE（compFn 的 for-each，:232-240）：`_loc2_` 是 contents 动态
 * 对象——CropLoader 的 contents 在 _material 模式是按 url 键挂
 * applicationDomain 的 Object。AS3 for-each 遍历值——Haxe 用
 * Reflect.fields + Reflect.field 等价（Object 无数组形态时的通用
 * 枚举通道）。
 */
@:keep
class MaterialLoaderProxy extends Sprite {
	// MaterialLoaderProxy.as:15-31
	private var _cardID:String;
	private var childObject:DisplayObject;
	private var cropsLoader:CropLoader;
	private var _type:String;
	private var _addOn:Dynamic;
	private var _bg:Sprite;
	private var _h:Int = 61;
	public var smallBg:Bool;
	private var _loader:Loader;
	private var _w:Int = 61;
	private var _id:Int;

	// MaterialLoaderProxy.as:33-41
	public function new() {
		super();
		this._w = this._h = 61;
		this._loader = new Loader();
		var _matBg:Dynamic = MaterialLib.getInstance().getMaterial("MaterialLoading");
		this._bg = Std.isOfType(_matBg, Sprite) ? cast(_matBg, Sprite) : null;
		this.smallBg = false;
	}

	// MaterialLoaderProxy.as:43-52
	private function setMaterial():Void {
		if (this.childObject != null) {
			removeChild(this.childObject);
			this.childObject = null;
		}
		var _matObj:Dynamic = MaterialLib.getInstance().getMaterial(this._cardID);
		this.childObject = Std.isOfType(_matObj, DisplayObject) ? cast(_matObj, DisplayObject) : null;
		addChild(this.childObject);
		this.childObject.width = this._w;
		this.childObject.height = this._h;
	}

	// MaterialLoaderProxy.as:54-58
	public function loadWare():Void {
		var _loc1_:String = GetCropID.getWareHouseIconUrl(this._id);
		this.load(_loc1_);
	}

	// MaterialLoaderProxy.as:60-67
	private function onLoadComplete(param1:Event):Void {
		if (this.smallBg == true) {
			this._loader.width = this._w;
			this._loader.height = this._h;
		}
		addChild(this._loader);
		this.hideBg();
		dispatchEvent(new Event(Event.COMPLETE));
	}

	// MaterialLoaderProxy.as:69-74
	private function loadHunter(param1:String):Void {
		var _loc2_:String = GetCropID.getSwfUrl();
		_loc2_ += "farm/hunter/h_" + param1 + ".jpg";
		this.load(_loc2_);
	}

	// MaterialLoaderProxy.as:76-90（`!getMaterial(...)` 的 Dynamic 真值——
	// 对象非 null 即真，走 shim.As3.truthy 等价通道）
	public function loadAnimal():Void {
		var _loc1_:Array<Dynamic> = null;
		var _loc2_:String = null;
		if (!shim.As3.truthy(MaterialLib.getInstance().getMaterial("Animal_" + this._id + "_1"))) {
			_loc1_ = [];
			_loc2_ = GetCropID.getAnimalURL(Std.string(this._id), 1);
			_loc1_.push(_loc2_);
			this.cropsLoader = new CropLoader();
			this.cropsLoader.addEventListener(Event.COMPLETE, this.compFn);
			this.cropsLoader.load(_loc1_, true);
		} else {
			this.loadPack();
		}
	}

	// MaterialLoaderProxy.as:92-96
	public function loadBg(param1:String):Void {
		var _loc2_:String = GetCropID.getShopDiyUrl(param1);
		this.load(_loc2_);
	}

	// MaterialLoaderProxy.as:98-103
	public function getWildIcon(param1:String, param2:Int, param3:String):String {
		var _loc4_:String = "";
		_loc4_ = GetCropID.getSwfUrl();
		return _loc4_ + ("farm/wild/pic/" + param1 + "_" + param3 + "_" + param2 + ".jpg");
	}

	// MaterialLoaderProxy.as:105-109
	public function loadAnimalIcon(param1:Bool = false, param2:Bool = false):Void {
		var _loc3_:String = GetCropID.getShopIconUrl(this._id, false, param1, param2);
		this.load(_loc3_);
	}

	// MaterialLoaderProxy.as:111-116
	private function onLoaderError(param1:IOErrorEvent = null):Void {
		var _matErr:Dynamic = MaterialLib.getInstance().getMaterial("MaterialLoadError");
		var _loc2_:Sprite = Std.isOfType(_matErr, Sprite) ? cast(_matErr, Sprite) : null;
		addChild(_loc2_);
		dispatchEvent(new Event("error"));
	}

	// MaterialLoaderProxy.as:118-122
	private function loadPack():Void {
		var _loc1_:String = GetCropID.getShopIconUrl(this._id);
		this.load(_loc1_);
	}

	// MaterialLoaderProxy.as:124-129
	private function showBg():Void {
		if (this._bg != null) {
			addChild(this._bg);
		}
		this._bg.visible = true;
	}

	// MaterialLoaderProxy.as:131-138
	private function load(param1:String):Void {
		this._loader.unload();
		this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoadComplete);
		this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onLoaderError);
		this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoaderSecError);
		this._loader.load(new URLRequest(param1));
	}

	// MaterialLoaderProxy.as:140-146（`Boolean(this._bg)` 对象真值——非 null
	// 即真）
	public function hideBg():Void {
		if (this._bg != null && contains(this._bg)) {
			removeChild(this._bg);
		}
		this._bg.visible = false;
	}

	// MaterialLoaderProxy.as:148-153
	public function loadMaterial():Void {
		this._cardID = "Card_" + Std.string(this._id);
		trace(GetCropID.idToCardSrc(Std.string(this._id)));
		CommonData.rslManager.requestClass(this._cardID, this.setMaterial, GetCropID.idToCardSrc(Std.string(this._id)));
	}

	// MaterialLoaderProxy.as:155-160
	private function onLoaderSecError(param1:SecurityErrorEvent = null):Void {
		var _matErr2:Dynamic = MaterialLib.getInstance().getMaterial("MaterialLoadError");
		var _loc2_:Sprite = Std.isOfType(_matErr2, Sprite) ? cast(_matErr2, Sprite) : null;
		addChild(_loc2_);
		dispatchEvent(new Event("error"));
	}

	// MaterialLoaderProxy.as:162-165
	private function loadOk(param1:Event):Void {
		addChild(this._loader);
	}

	// MaterialLoaderProxy.as:167-171
	private function laodWild():Void {
		var _loc1_:String = this.getWildIcon(this._type, this._id, Reflect.field(this._addOn, "type"));
		this.load(_loc1_);
	}

	// MaterialLoaderProxy.as:173-209
	public function setContent(param1:String, param2:Int, param3:Dynamic = null, param4:Bool = false, param5:Bool = false, param6:Bool = false,
			param7:Bool = false):Void {
		this._type = param1;
		this._id = param2;
		this._addOn = param3;
		if (param1 == "1") {
			this.loadAnimalIcon(param4, param7);
		}
		if (param1 == "2") {
			this.loadWare();
		}
		if (param1 == "9") {
			this.loadAnimal();
		}
		if (param1 == "11") {
			this.loadMaterial();
		}
		if (param1 == "wild_drop") {
			this.laodWild();
		}
		if (param1 == "hunter") {
			this.loadHunter(Std.string(param2));
		}
		if (param1 == "3") {
			this.loadBg(Std.string(param2));
		}
		this.showBg();
	}

	// MaterialLoaderProxy.as:211-243
	private function compFn(param1:Event):Void {
		var _loc3_:Dynamic = null;
		var _loc2_:Dynamic = this.cropsLoader.contents;
		for (_key in Reflect.fields(_loc2_)) {
			_loc3_ = Reflect.field(_loc2_, _key);
			if (!Std.isOfType(_loc3_, ApplicationDomain)) {
				dispatchEvent(new Event("animal_error"));
				this.onLoaderError();
				return;
			}
			MaterialLib.getInstance().push(cast(_loc3_, ApplicationDomain));
		}
		this.loadPack();
	}
}
