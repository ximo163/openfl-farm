package common.view;

import ItemLoading;
import com.qzone.corelib.net.RSLManager;
import com.qzone.farm.api.interfaces.IPluginProxy;
import com.qzone.qui.styles.Style;
import com.qzone.utils.DisplayUtil;
import common.Consts;
import common.GetCropID;
import common.Settings;
import common.misc.Utils;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.net.URLRequest;
import framework.api.PluginManager;
import shim.As3;

/**
 * common.view.MaterialProxy —— MaterialProxy.as 逐句对应（issue #9）。
 * 万物素材位：setContent 按类型串路由（种子/水晶/武器/卡/工具/鱼食/装饰/
 * 狗/金币/经验/鱼/精灵），经 RSLManager.requestClass 确保库后落素材居中。
 * 字段名照抄（childObjcet 是原版拼写 :43）；AS3 protected → Haxe private。
 */
@:keep
class MaterialProxy extends Sprite {
	// MaterialProxy.as:21-25
	public static final BIG:String = "big";
	public static final SMALL:String = "small";
	public static final CARDSGAME:String = "CardsGame";

	// MaterialProxy.as:27-43
	private var currentType:String;
	private var _size:String;
	private var _enable:Bool;
	private var _loaded:Bool;
	private var itemLoading:Sprite;
	private var _h:Int;
	private var currentId:Int = 0;
	private var _w:Int;
	private var childObjcet:DisplayObject;

	// MaterialProxy.as:45-67（small→60、CardsGame→80、其余（big）120）
	public function new(param1:String = "small") {
		super();
		this.mouseChildren = false;
		this.cacheAsBitmap = true;
		this._enable = true;
		this._size = param1;
		if (this._size == SMALL) {
			this._w = this._h = 60;
		} else if (this._size == CARDSGAME) {
			this._w = this._h = 80;
		} else {
			this._w = this._h = 120;
		}
		this.currentType = "";
		this.itemLoading = null;
		this._loaded = false;
	}

	// MaterialProxy.as:69-99（Dog<id> 素材；small 半幅、big 原幅居中）
	private function setDog():Void {
		var _loc1_:Int = this.currentId;
		var _loc2_:String = "Dog" + Std.string(_loc1_);
		this.remove();
		if (_loc2_ == "") {
			return;
		}
		this.hideLoading();
		this.childObjcet = cast Utils.getMaterial(_loc2_);
		if (this.childObjcet == null) {
			return;
		}
		if (this._size == SMALL) {
			this.childObjcet.scaleX = 0.5;
			this.childObjcet.scaleY = 0.5;
		} else if (this._size == BIG) {
			this.childObjcet.scaleX = 1;
			this.childObjcet.scaleY = 1;
		}
		this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
		this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
		this.enableChild(this._enable);
		addChild(this.childObjcet);
		this._loaded = true;
	}

	// MaterialProxy.as:101-104
	public var loaded(get, never):Bool;

	private function get_loaded():Bool {
		return this._loaded;
	}

	// MaterialProxy.as:106-219（同 (type,id,enable) 早退；type 路由各素材；
	// 尾部统一记 currentId）
	public function setContent(param1:String, param2:Int, param3:Bool = true):Void {
		var _loc6_:String = null;
		var _loc7_:String = null;
		var _loc8_:String = null;
		var _loc9_:String = null;
		var _loc10_:String = null;
		var _loc11_:String = null;
		var _loc12_:String = null;
		var _loc13_:String = null;
		var _loc14_:IPluginProxy = null;
		var _loc15_:Class<Dynamic> = null;
		if (this.currentType == param1 && this.currentId == param2 && param3 == this._enable) {
			return;
		}
		this._enable = param3;
		this.currentType = param1;
		var _loc4_:RSLManager = RSLManager.getInstance();
		var _loc5_:Settings = Settings.getInstance();
		if (param1 == Consts.ITEM_TYPE_SEED) {
			this.currentId = param2;
			_loc6_ = GetCropID.getSeedUrl(this.currentId);
			_loc4_.requestClass(_loc5_.getSeedName(this.currentId), this.setCrop, _loc6_);
		} else if (param1 == Consts.ITEM_TYPE_CRYSTAL) {
			this.currentId = param2;
			_loc7_ = _loc5_.getStringAttribute("NcDrop9");
			_loc4_.requestClass(_loc5_.getCrystalName(param1, this.currentId), this.setCrystal, _loc7_);
		} else if (param1 == Consts.ITEM_TYPE_WEAPON) {
			this.currentId = param2;
			_loc8_ = _loc5_.getStringAttribute("wildaweapon") + "weapon" + this.currentId + ".swf";
			_loc4_.requestClass(_loc5_.getWeaponName("Small", this.currentId), this.setWeapon, _loc8_, {"id": param2});
		} else if (param1 == Consts.ITEM_TYPE_CARD) {
			this.currentId = param2;
			_loc9_ = GetCropID.getSeedUrl(this.currentId, Consts.ITEM_TYPE_CARD);
			_loc4_.requestClass(_loc5_.getCardName(this.currentId), this.setCard, _loc9_);
		} else if (param1 == Consts.ITEM_TYPE_TOOL || param1 == Consts.ITEM_TYPE_STICK || param1 == Consts.ITEM_TYPE_PESTICIDE
			|| param1 == Consts.ITEM_TYPE_DOGFOOD) {
			this.currentId = param2;
			_loc10_ = GetCropID.idToToolName(Std.string(param2));
			_loc11_ = "";
			if (_loc10_ == "FertilizerMagic") {
				_loc11_ = _loc5_.getSecondUrl("tvShowIcon");
			} else {
				_loc11_ = _loc5_.getSecondUrl("Fertilizer");
			}
			_loc4_.requestClass(_loc10_, this.setTool, _loc11_);
		} else if (param1 == Consts.ITEM_TYPE_FISHFEED) {
			this.currentId = param2;
			_loc4_.requestClass("FishFood_" + param2, this.setFishFood, _loc5_.getSecondUrl("Fertilizer"));
		} else if (param1 == Consts.ITEM_TYPE_DECORATE) {
			this.setDiy(param2);
		} else if (param1 == Consts.ITEM_TYPE_DOG) {
			this.currentId = param2;
			_loc12_ = "FDog" + Std.string(this.currentId);
			_loc10_ = "Dog" + Std.string(param2);
			_loc11_ = GetCropID.idToDogUrl(_loc12_, true);
			_loc4_.requestClass(_loc10_, this.setDog, _loc11_);
		} else if (param1 != "5") {
			if (param1 == "6") {
				this.setGold(param2);
			} else if (param1 == "7") {
				this.setExp(param2);
			} else if (param1 == Std.string(Consts.DECOR_BILLBOARD)) {
				this.enableChild(this._enable);
			} else if (param1 == Consts.ITEM_TYPE_FISH) {
				this.currentId = param2;
				_loc13_ = GetCropID.getFishUrl(this.currentId);
				_loc4_.requestClass(_loc5_.getFishName(this.currentId), this.setFish, _loc13_);
			} else if (param1 == Consts.ITEM_TYPE_FAIRY) {
				_loc14_ = cast PluginManager.getInstance().getPluginByID(2);
				if (_loc14_ != null) {
					_loc15_ = cast _loc14_.executeCommand(2102, null);
					if (_loc15_ != null) {
						this.setChildObject(Type.createInstance(_loc15_, []));
						this.childObjcet.scaleX = this.childObjcet.scaleY = 1.5;
						// 原版 x 用 width*scaleX、y 不乘 scaleY（:211-212，照抄）
						this.childObjcet.x = (this._w - this.childObjcet.width * this.childObjcet.scaleX) / 2;
						this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
					}
				}
			}
		}
		this.currentId = param2;
	}

	// MaterialProxy.as:221-232（摘子并断 loaded）
	private function remove():Void {
		if (this.childObjcet != null) {
			if (this.childObjcet.parent != null) {
				this.childObjcet.parent.removeChild(this.childObjcet);
			}
			this.childObjcet = null;
		}
		this._loaded = false;
	}

	// MaterialProxy.as:234-238
	private function setGold(param1:Int):Void {
		this.setChildObjectByMaterialName("GoldCardsGame");
		this._loaded = true;
	}

	// MaterialProxy.as:240-243
	public var size(get, never):String;

	private function get_size():String {
		return this._size;
	}

	// MaterialProxy.as:245-255
	private function setCard():Void {
		var _loc1_:String = "";
		var _loc2_:Int = this.currentId;
		if (_loc2_ > 0) {
			_loc1_ = Settings.getInstance().getCardName(this.currentId);
		}
		this.remove();
		this.setMaterialByName(_loc1_);
	}

	// MaterialProxy.as:257-279（Loader 直挂（94×94 居中）；完成回调用
	// arguments[0]/callee 的自摘监听 → Haxe 命名闭包自引）
	public function loadBillBoard(param1:String):Void {
		var url:String = param1;
		this.remove();
		this._w = this._h = 100;
		var ld:Loader = new Loader();
		ld.mouseChildren = false;
		ld.mouseEnabled = false;
		var onComplete:Event->Void = null;
		onComplete = function(e:Event):Void {
			this.childObjcet.width = this.childObjcet.height = 94;
			this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
			this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
			e.target.removeEventListener(Event.COMPLETE, onComplete);
			this._loaded = true;
			this.hideLoading();
		};
		ld.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		ld.load(new URLRequest(url));
		this.childObjcet = ld;
		this.enableChild(this._enable);
		addChild(this.childObjcet);
	}

	// MaterialProxy.as:281-289
	public function hideLoading():Void {
		if (this.itemLoading == null) {
			return;
		}
		DisplayUtil.removeChild(this, this.itemLoading);
		this.itemLoading = null;
	}

	// MaterialProxy.as:291-294
	private function setExp(param1:Int):Void {
		this.setChildObjectByMaterialName("ExpIcon");
		this._loaded = true;
	}

	// MaterialProxy.as:297-307
	private function setWeapon(param1:Dynamic):Void {
		var _loc2_:String = "";
		var _loc3_:Int = As3.intOf(Reflect.field(param1, "id"));
		if (_loc3_ > 0) {
			_loc2_ = Settings.getInstance().getWeaponName("Small", _loc3_);
		}
		this.remove();
		this.setMaterialByName(_loc2_);
	}

	// MaterialProxy.as:309-335
	private function setFishFood():Void {
		var _loc1_:Int = this.currentId;
		this.remove();
		var _loc2_:String = "FishFood_" + _loc1_;
		this.childObjcet = cast Utils.getMaterial(_loc2_);
		if (this.childObjcet == null) {
			this.childObjcet = new Sprite();
		}
		this.hideLoading();
		if (this._size == SMALL) {
			this.childObjcet.scaleX = 1;
			this.childObjcet.scaleY = 1;
		} else if (this._size == BIG) {
			this.childObjcet.scaleX = 2;
			this.childObjcet.scaleY = 2;
		}
		this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
		this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
		this.enableChild(this._enable);
		addChild(this.childObjcet);
		this._loaded = true;
	}

	// MaterialProxy.as:337-368（素材名 → 素材；small 1x / big 2x / 卡 1.3x）
	private function setMaterialByName(param1:String):Void {
		if (param1 == "") {
			return;
		}
		this.childObjcet = cast Utils.getMaterial(param1);
		if (this.childObjcet != null) {
			this.hideLoading();
			this._loaded = true;
			if (this._size == SMALL) {
				this.childObjcet.scaleX = 1;
				this.childObjcet.scaleY = 1;
			} else if (this._size == BIG) {
				this.childObjcet.scaleX = 2;
				this.childObjcet.scaleY = 2;
			} else if (this._size == CARDSGAME) {
				this.childObjcet.scaleX = 1.3;
				this.childObjcet.scaleY = 1.3;
			}
			this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
			this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
			this.enableChild(this._enable);
			addChild(this.childObjcet);
		}
	}

	// MaterialProxy.as:370-380
	private function setCrop():Void {
		var _loc1_:String = "";
		var _loc2_:Int = this.currentId;
		if (_loc2_ > 0) {
			_loc1_ = Settings.getInstance().getSeedName(this.currentId);
		}
		this.remove();
		this.setMaterialByName(_loc1_);
	}

	// MaterialProxy.as:382-394（enable：滤镜清空；disable：置灰滤镜且本件
	// 禁鼠标）
	private function enableChild(param1:Bool):Void {
		if (param1 == true) {
			this.childObjcet.filters = null;
			this.mouseEnabled = true;
		} else {
			this.childObjcet.filters = cast Style.getDisableFilter();
			this.mouseEnabled = false;
		}
	}

	// MaterialProxy.as:396-406
	private function setFish():Void {
		var _loc1_:String = "";
		var _loc2_:Int = this.currentId;
		if (_loc2_ > 0) {
			_loc1_ = Settings.getInstance().getFishName(this.currentId);
		}
		this.remove();
		this.setMaterialByName(_loc1_);
	}

	// MaterialProxy.as:408-439（diy：URL 直挂 Loader；enable 走滤镜）
	private function setDiy(param1:Int):Void {
		var _loc2_:String = GetCropID.idToDiyUrl(Std.string(param1), this._size == SMALL);
		if (_loc2_ == "") {
			_loc2_ = Settings.getInstance().getSecondUrl(Std.string(param1) + (this._size == SMALL ? "" : "b"));
		}
		if (_loc2_ == "") {
			return;
		}
		if (param1 != this.currentId) {
			this.remove();
			this.childObjcet = new Loader();
			(cast this.childObjcet : Loader).load(new URLRequest(_loc2_));
			addChild(this.childObjcet);
		}
		if (this.childObjcet == null) {
			return;
		}
		this._loaded = true;
		if (this._enable) {
			this.childObjcet.filters = [];
		} else {
			this.childObjcet.filters = cast Style.getDisableFilter();
		}
	}

	// MaterialProxy.as:441-468（直挂子件：small 1x / big 1.5x / 卡 1.1x）
	private function setChildObject(param1:DisplayObject):Void {
		this.remove();
		this.childObjcet = param1;
		if (this.childObjcet == null) {
			return;
		}
		if (this._size == SMALL) {
			this.childObjcet.scaleX = 1;
			this.childObjcet.scaleY = 1;
		} else if (this._size == BIG) {
			this.childObjcet.scaleX = 1.5;
			this.childObjcet.scaleY = 1.5;
		} else if (this._size == CARDSGAME) {
			this.childObjcet.scaleX = 1.1;
			this.childObjcet.scaleY = 1.1;
		}
		this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
		this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
		this.enableChild(this._enable);
		addChild(this.childObjcet);
	}

	// MaterialProxy.as:470-474
	private function setChildObjectByMaterialName(param1:String):Void {
		var _loc2_:DisplayObject = cast Utils.getMaterial(param1);
		this.setChildObject(_loc2_);
	}

	// MaterialProxy.as:476-486
	private function setCrystal():Void {
		var _loc1_:String = "";
		var _loc2_:Int = this.currentId;
		if (_loc2_ > 0) {
			_loc1_ = Settings.getInstance().getCrystalName(this.currentType, this.currentId);
		}
		this.remove();
		this.setMaterialByName(_loc1_);
	}

	// MaterialProxy.as:488-518
	private function setTool():Void {
		var _loc1_:Int = this.currentId;
		var _loc2_:String = GetCropID.idToToolName(Std.string(_loc1_));
		this.remove();
		if (_loc2_ == "") {
			return;
		}
		this.childObjcet = cast Utils.getMaterial(_loc2_);
		if (this.childObjcet == null) {
			this.childObjcet = new Sprite();
		}
		this.hideLoading();
		if (this._size == SMALL) {
			this.childObjcet.scaleX = 1;
			this.childObjcet.scaleY = 1;
		} else if (this._size == BIG) {
			this.childObjcet.scaleX = 2;
			this.childObjcet.scaleY = 2;
		}
		this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
		this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
		this.enableChild(this._enable);
		addChild(this.childObjcet);
		this._loaded = true;
	}

	// MaterialProxy.as:520-532（装载动画 >60 尺寸时居中）
	public function showLoading():Void {
		if (this.itemLoading == null) {
			this.itemLoading = new ItemLoading();
			this.addChild(this.itemLoading);
		}
		if (this._w > 60) {
			this.itemLoading.x = (this._w - this.itemLoading.width) * 0.5;
			this.itemLoading.y = (this._h - this.itemLoading.height) * 0.5;
		}
	}
}
