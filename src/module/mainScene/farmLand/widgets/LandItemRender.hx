package module.mainScene.farmLand.widgets;

import common.GetCropID;
import module.mainScene.farmLand.FarmLandsView;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.Event;

/**
 * module.mainScene.farmLand.widgets.LandItemRender —— V3b 翻译（issue #8，
 * 17 类清单内地块控件）。单格渲染器：地底图/作物位/虫草/荒地四层。
 * 逐句对应 legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/
 * widgets/LandItemRender.as。
 */
class LandItemRender extends Sprite {
	// LandItemRender.as:13-20
	private var _wasteland:Wasteland;
	private var _land:LandTile;
	private var _cropID:Int;
	private var _index:Int;
	private var _waste:Bool;
	private var _step:Int;
	private var _crop:Crop;
	private var _byproduct:Byproduct;

	// LandItemRender.as:27-38（ctor：建三层子控件并整体缩到场景 SCALE）
	public function new() {
		super();
		// 原版 `scaleX = scaleY = SCALE`（链式赋值）
		scaleX = FarmLandsView.SCALE;
		scaleY = FarmLandsView.SCALE;
		this._index = -1;
		this._cropID = 0;
		this._waste = false;
		this._step = 0;
		this._land = new LandTile(this);
		this._byproduct = new Byproduct(this);
		this._wasteland = new Wasteland(this);
	}

	// LandItemRender.as:40-56（setGrowStep：换 cropID 清旧作物，否则推帧）
	public function setGrowStep(param1:Int, param2:Int):Void {
		this._step = param1;
		if (this._cropID != param2) {
			if (this._crop != null) {
				removeChild(this._crop);
				this._crop = null;
			}
			this._cropID = param2;
		} else if (this._crop != null) {
			this._crop.step = param1;
		}
	}

	// LandItemRender.as:58-61（set reclaim：荒地开垦板显隐；FarmLandsView 跨类
	// 调用，public）
	public var reclaim(never, set):Bool;

	private function set_reclaim(param1:Bool):Bool {
		this._wasteland.showExpandBoard(param1);
		return param1;
	}

	// LandItemRender.as:63-78（clearAll：作物摘除、虫草清空、地块复位）
	public function clearAll():Void {
		if (this._crop != null) {
			removeChild(this._crop);
			this._crop = null;
		}
		if (this._byproduct != null) {
			this._byproduct.clear();
		}
		if (this._land != null) {
			this._land.reset();
		}
	}

	// LandItemRender.as:80-83（get index）
	public var index(get, set):Int;

	private function get_index():Int {
		return this._index;
	}

	// LandItemRender.as:85-88（get waste）
	public var waste(get, set):Bool;

	private function get_waste():Bool {
		return this._waste;
	}

	// LandItemRender.as:90-110（createByproduct：虫草计数带入，step 3/4 间
	// 取作物配置的虫位串）
	public function createByproduct(param1:Int, param2:Int):Void {
		this._byproduct.insect = param1;
		this._byproduct.weed = param2;
		var _loc3_:Int = 0;
		if (this._step == 3) {
			_loc3_ = 1;
		} else if (this._step == 4) {
			_loc3_ = 2;
		}
		if (_loc3_ != 0) {
			this._byproduct.insectPosition = GetCropID.getInsectPosition(Std.string(this._cropID), _loc3_);
		}
		this._byproduct.updateInsect();
		this._byproduct.updateWeed();
		this._byproduct.updateInsectPosition();
	}

	// LandItemRender.as:112-115（set index）
	private function set_index(param1:Int):Int {
		this._index = param1;
		return param1;
	}

	// LandItemRender.as:117-134（createCrop：作物位实例化；守卫读实例字段
	// _cropID——:119 是 `this._cropID` 非 param1）
	public function createCrop(param1:Int, param2:String, param3:String):Void {
		if (this._cropID == 0) {
			throw new Error("Invalid crop id.");
		}
		if (param2 == "" || param3 == "") {
			return;
		}
		if (this._crop == null) {
			this._crop = new Crop(param1, param2, param3);
			this._crop.step = this._step;
			this._crop.addEventListener(Event.COMPLETE, this.onCropLoaded, false, 0, true);
			addChildAt(this._crop, 1);
		}
	}

	// LandItemRender.as:136-160（updateLandStatus：湿度/施肥四象限交底图）
	public function updateLandStatus(param1:UInt, param2:Bool, param3:Bool, param4:Int):Void {
		if (this._land == null) {
			return;
		}
		var _loc5_:String = "";
		if (param2 && !param3) {
			_loc5_ = LandTile.SUITABLE;
		} else if (param2 && param3) {
			_loc5_ = LandTile.FERTILE;
		} else if (!param2 && param3) {
			_loc5_ = LandTile.DRY_FERTILE;
		} else {
			_loc5_ = LandTile.DRY;
		}
		this._land.updateLandStatus(param1, _loc5_, param4);
	}

	// LandItemRender.as:162-167（onCropLoaded：作物到位后重摆虫草）
	private function onCropLoaded(param1:Event):Void {
		this._byproduct.updateInsect();
		this._byproduct.updateWeed();
		this._byproduct.updateInsectPosition();
	}

	// LandItemRender.as:169-176（get cropLoaded：无作物实例恒 true）
	public var cropLoaded(get, never):Bool;

	private function get_cropLoaded():Bool {
		if (this._crop != null) {
			return this._crop.loaded;
		}
		return true;
	}

	// LandItemRender.as:178-181（get cropID）
	public var cropID(get, never):Int;

	private function get_cropID():Int {
		return this._cropID;
	}

	// LandItemRender.as:183-199（set waste：荒地态切换——清底图虫草作物、
	// 挂荒地板；摘收则只收荒地板）
	private function set_waste(param1:Bool):Bool {
		this._waste = param1;
		if (param1 == true) {
			this._land.clear();
			this._byproduct.clear();
			this._wasteland.showWaste();
			if (this._crop != null) {
				removeChild(this._crop);
				this._crop = null;
			}
		} else {
			this._wasteland.clear();
		}
		return param1;
	}
}
