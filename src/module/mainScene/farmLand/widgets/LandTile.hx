package module.mainScene.farmLand.widgets;

import common.misc.Utils;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.errors.Error;
import shim.As3;

/**
 * module.mainScene.farmLand.widgets.LandTile —— V3b 翻译（issue #8）。
 * 地格底图：按 red/black 位与湿度/施肥状态换 com.qzone.ui.Farmland* 符号，
 * 金牌地套 JPLand* 双层。逐句对应 legacy/decompiled/main3_v_221/scripts/
 * module/mainScene/farmLand/widgets/LandTile.as。
 */
class LandTile {
	// LandTile.as:11-17（状态串）
	public static final DRY:String = "arid";
	public static final DRY_FERTILE:String = "aridFertile";
	public static final FERTILE:String = "fertile";
	public static final SUITABLE:String = "suitable";

	// LandTile.as:19-29
	private var _parent:DisplayObjectContainer;
	private var _aFarmlandC:Sprite;
	private var _aFarmlandS:DisplayObject;
	private var _status:String;
	private var _jinPaiBitMap:DisplayObject;
	private var _bitsFlag:UInt;

	// LandTile.as:31-38
	public function new(param1:DisplayObjectContainer) {
		this._bitsFlag = 0;
		this._status = "";
		this._aFarmlandS = null;
		this._parent = param1;
	}

	// LandTile.as:40-58（clearOldLand：摘旧底图/金牌层）
	private function clearOldLand():Void {
		if (this._parent != null) {
			if (As3.truthy(this._aFarmlandC) && this._aFarmlandC.parent == this._parent) {
				this._parent.removeChild(this._aFarmlandC);
				this._aFarmlandC.removeChild(this._jinPaiBitMap);
				this._aFarmlandC.removeChild(this._aFarmlandS);
				this._aFarmlandS = null;
				this._aFarmlandC = null;
			} else if (As3.truthy(this._aFarmlandS) && this._aFarmlandS.parent == this._parent) {
				this._parent.removeChild(this._aFarmlandS);
				this._aFarmlandS = null;
			}
		}
	}

	// LandTile.as:60-115（updateLandStatus：同态短路；状态先落定再取素材，
	// 素材缺失抛 "Can not get land res!"（:108-111——无资源环境里状态已可读）
	public function updateLandStatus(param1:UInt, param2:String, param3:Int):Void {
		var _loc4_:Bool = this._aFarmlandC != null ? true : false;
		// 原版 `param3 == _loc4_`（int 对 Boolean 宽松等值：false≡0/true≡1）
		if (this._bitsFlag == param1 && this._status == param2 && param3 == (_loc4_ ? 1 : 0)) {
			return;
		}
		this._bitsFlag = param1;
		this._status = param2;
		if (this._status == "" || this._status == null) {
			this._status = SUITABLE;
		}
		var _loc5_:Int = 0;
		if (this._aFarmlandS != null && this._aFarmlandS.parent == this._parent) {
			_loc5_ = this._parent.getChildIndex(this._aFarmlandS);
		} else if (As3.truthy(this._aFarmlandC) && this._aFarmlandC.parent == this._parent) {
			_loc5_ = this._parent.getChildIndex(this._aFarmlandC);
		}
		this.clearOldLand();
		var _loc6_:String = "";
		if (this._bitsFlag == 1) {
			_loc6_ = ".red";
		} else if (this._bitsFlag == 2) {
			_loc6_ = ".black";
		}
		if (this._status == SUITABLE) {
			this._aFarmlandS = asDisplayObject(Utils.getMaterial("com.qzone.ui" + _loc6_ + ".FarmlandS"));
		} else if (this._status == DRY) {
			this._aFarmlandS = asDisplayObject(Utils.getMaterial("com.qzone.ui" + _loc6_ + ".FarmlandG"));
		} else if (this._status == FERTILE) {
			this._aFarmlandS = asDisplayObject(Utils.getMaterial("com.qzone.ui" + _loc6_ + ".FarmlandS2"));
		} else if (this._status == DRY_FERTILE) {
			this._aFarmlandS = asDisplayObject(Utils.getMaterial("com.qzone.ui" + _loc6_ + ".FarmlandG2"));
		}
		if (this._aFarmlandS == null) {
			throw new Error("Can not get land res!");
		}
		this._aFarmlandS.cacheAsBitmap = true;
		this._aFarmlandS.name = "__land__";
		this.showGoldLand(param3, _loc5_);
	}

	// 原版 `Utils.getMaterial(...) as DisplayObject`：单次取材后判型收窄
	private static function asDisplayObject(param1:Dynamic):DisplayObject {
		if (Std.isOfType(param1, DisplayObject)) {
			return cast(param1, DisplayObject);
		}
		return null;
	}

	// LandTile.as:117-150（showGoldLand：金牌套 JPLand* 垫在底图上）
	private function showGoldLand(param1:Int, param2:Int):Void {
		if (param1 == 1) {
			if (!As3.truthy(this._aFarmlandC)) {
				this._aFarmlandC = new Sprite();
			}
			if (this._status == SUITABLE) {
				this._jinPaiBitMap = asDisplayObject(Utils.getMaterial("com.qzone.ui.JPLandS"));
			} else if (this._status == DRY) {
				this._jinPaiBitMap = asDisplayObject(Utils.getMaterial("com.qzone.ui.JPLandG"));
			} else if (this._status == FERTILE) {
				this._jinPaiBitMap = asDisplayObject(Utils.getMaterial("com.qzone.ui.JPLandS2"));
			} else if (this._status == DRY_FERTILE) {
				this._jinPaiBitMap = asDisplayObject(Utils.getMaterial("com.qzone.ui.JPLandG2"));
			}
			this._jinPaiBitMap.cacheAsBitmap = true;
			this._aFarmlandC.addChild(this._aFarmlandS);
			this._aFarmlandC.addChild(this._jinPaiBitMap);
			this._parent.addChildAt(this._aFarmlandC, param2);
		} else {
			this._parent.addChildAt(this._aFarmlandS, param2);
		}
	}

	// LandTile.as:152-157
	public function clear():Void {
		this.clearOldLand();
		this._bitsFlag = 0;
		this._status = "";
	}

	// LandTile.as:159-162
	public function reset():Void {
		this.updateLandStatus(0, SUITABLE, 0);
	}

	// LandTile.as:164-167（get status）
	public var status(get, never):String;

	private function get_status():String {
		return this._status;
	}
}
