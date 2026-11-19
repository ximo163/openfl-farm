package module.mainScene.farmLand.widgets;

import FarmLoading;
import com.qzone.corelib.net.RSLManager;
import common.CommonData;
import common.GetCropID;
import common.Settings;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import report.EventRecorder;
import shim.As3;

/**
 * module.mainScene.farmLand.widgets.Crop —— V3b 翻译（issue #8）。
 * 地块作物位：按生长步取 Crop_<id>_<classStep> 阶段 swf 的符号类，step1/2/3
 * 帧位显隐。逐句对应 legacy/decompiled/main3_v_221/scripts/module/mainScene/
 * farmLand/widgets/Crop.as。
 */
class Crop extends Sprite {
	// Crop.as:11-29
	public var _cropUrl:String;
	private var _cropLoading:MovieClip;
	private var _cropLayers:Array<Dynamic>;
	private var _loaded:Bool;
	private var _classStep:Int;
	private var _cropId:Int;
	private var _step:Int;
	private var _specialGrow:Int;
	private var _currentCrop:Dynamic;
	private var _cropName:String;
	private var _cropLoadingTimer:Int;

	// Crop.as:31-46
	public function new(param1:Int, param2:String, param3:String, param4:Int = -1) {
		super();
		this._cropId = param1;
		this._cropUrl = param3;
		this._cropName = param2;
		this._currentCrop = null;
		this._step = param4;
		this._cropLayers = null;
		this._loaded = false;
		this._cropLoading = null;
		this._cropLoadingTimer = 0;
		this._specialGrow = GetCropID.specialGrow(Std.string(this._cropId));
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
	}

	// Crop.as:48-59（加载动画兜底：素材 300ms 没回来放 FarmLoading）
	private function showLoadingAnimation():Void {
		if (this._cropLoading == null) {
			this._cropLoading = new FarmLoading();
			this._cropLoading.y = 30;
			this._cropLoading.x = 100;
			this._cropLoading.mouseEnabled = false;
			this._cropLoading.mouseChildren = false;
			addChild(this._cropLoading);
		}
	}

	// Crop.as:61-72
	private function removeCurrentCrop():Void {
		if (this._currentCrop != null && contains(this._currentCrop)) {
			removeChild(this._currentCrop);
			this._currentCrop = null;
		}
		if (this._cropLayers != null) {
			// AS3 splice(0) 不带删除数 → 从 0 清到尾
			this._cropLayers.splice(0, this._cropLayers.length);
			this._cropLayers = null;
		}
	}

	// Crop.as:74-124（setState：阶段类名解析，公共枯苗档走 publicCropPrefix）
	private function setState():Void {
		var _loc1_:String = null;
		this._cropUrl = GetCropID.getCropUrl(this._cropId, this._step);
		if (this._cropName != "" && this._cropUrl != "") {
			if (this._cropLoadingTimer != 0) {
				As3.clearTimeout(this._cropLoadingTimer);
			}
			this._cropLoadingTimer = As3.setTimeout(function():Void {
				showLoadingAnimation();
			}, 300);
		}
		if (this._step > 2 && this._step < 6) {
			this._classStep = 3;
		} else {
			this._classStep = this._step;
		}
		_loc1_ = Settings.getInstance().getStringAttribute("publicCropPrefix");
		if (this._classStep == 0
			&& (this._specialGrow == GetCropID.SG_PUBLIC_SEED_PUBLIC_DEAD || this._specialGrow == GetCropID.SG_SPECIAL_DEAD)
			|| this._classStep == 6
			&& (this._specialGrow == GetCropID.SG_PUBLIC_SEED_PUBLIC_DEAD || this._specialGrow == GetCropID.SG_SPECIAL_SEED)) {
			CommonData.rslManager.requestClass(_loc1_ + this._classStep, this.onCropLoaded, this._cropUrl, {"404": false});
		} else if (As3.truthy(this._currentCrop) && this._classStep == 3 && cropStepChild(this._currentCrop, "step1") != null) {
			// PORT-NOTE: 原版 `MovieClip(_currentCrop).step1` 是时间轴具名子实例
			// 挂在实例属性上（hasOwnProperty("step1") 为真）；openfl 动画运行时
			// 里子实例不是字段，改 getChildByName 检取，语义同源
			setStepChildVisible(this._currentCrop, "step1", this._step == 3);
			setStepChildVisible(this._currentCrop, "step2", this._step == 4);
			setStepChildVisible(this._currentCrop, "step3", this._step != 3 && this._step != 4);
			this.stopLoadingAnimation();
		} else {
			CommonData.rslManager.requestClass(this._cropName + "_" + this._classStep, this.onCropLoaded, this._cropUrl, {"404": false});
		}
	}

	// PORT-NOTE：时间轴具名子实例的检取（见 setState 处注释）
	private function cropStepChild(param1:Dynamic, param2:String):Dynamic {
		if (Std.isOfType(param1, MovieClip)) {
			return cast(param1, MovieClip).getChildByName(param2);
		}
		return null;
	}

	// PORT-NOTE：同上——step1/2/3 显隐经具名子实例
	private function setStepChildVisible(param1:Dynamic, param2:String, param3:Bool):Void {
		var _loc1_:Dynamic = cropStepChild(param1, param2);
		if (_loc1_ != null) {
			_loc1_.visible = param3;
		}
	}

	// Crop.as:126-133（set step：同值早退，否则重走阶段解析）
	public var step(never, set):Int;

	private function set_step(param1:Int):Int {
		if (param1 == this._step) {
			return param1;
		}
		this._step = param1;
		this.setState();
		return param1;
	}

	// Crop.as:135-146
	private function stopLoadingAnimation():Void {
		if (this._cropLoadingTimer != 0) {
			As3.clearTimeout(this._cropLoadingTimer);
			this._cropLoadingTimer = 0;
		}
		if (this._cropLoading != null && this.contains(this._cropLoading) == true) {
			this._cropLoading.stop();
			removeChild(this._cropLoading);
			this._cropLoading = null;
		}
	}

	// Crop.as:148-151（get loaded：素材到位与否，LandItemRender.cropLoaded 读）
	public var loaded(get, never):Bool;

	private function get_loaded():Bool {
		return this._loaded;
	}

	// Crop.as:153-158
	private function onAddedToStage(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage, false, 0, true);
	}

	// Crop.as:160-165
	private function onRemovedFromStage(param1:Event):Void {
		removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
		this.stopLoadingAnimation();
		this.removeCurrentCrop();
	}

	// Crop.as:167-214（onCropLoaded：阶段类实例化，step1/2/3 帧位选段）
	private function onCropLoaded(param1:Dynamic):Void {
		var _loc2_:Class<Dynamic> = null;
		var _loc3_:String = null;
		if (param1 != null && Reflect.field(param1, "404") == true) {
			EventRecorder.recordErrorEvent("160453", 0, EventRecorder.FAULT_ERROR);
			return;
		}
		EventRecorder.recordSueecssEvent("160453", 0);
		_loc3_ = Settings.getInstance().getStringAttribute("publicCropPrefix");
		if (this._classStep == 0) {
			if (this._specialGrow == GetCropID.SG_PUBLIC_SEED_PUBLIC_DEAD || this._specialGrow == GetCropID.SG_SPECIAL_DEAD) {
				_loc2_ = RSLManager.getClass(_loc3_ + this._classStep);
			} else {
				_loc2_ = RSLManager.getClass(this._cropName + "_" + this._classStep);
			}
		} else if (this._classStep == 6) {
			if (this._specialGrow == GetCropID.SG_PUBLIC_SEED_PUBLIC_DEAD || this._specialGrow == GetCropID.SG_SPECIAL_SEED) {
				_loc2_ = RSLManager.getClass(_loc3_ + this._classStep);
			} else {
				_loc2_ = RSLManager.getClass(this._cropName + "_" + this._classStep);
			}
		} else {
			_loc2_ = RSLManager.getClass(this._cropName + "_" + this._classStep);
		}
		if (_loc2_ != null) {
			this.stopLoadingAnimation();
			this.removeCurrentCrop();
			this._loaded = true;
			this._currentCrop = Type.createInstance(_loc2_, []);
			this._currentCrop.name = "__crop__";
			if (this._classStep == 3) {
				// PORT-NOTE：step1/2/3 具名子实例，见 setState 处注释
				setStepChildVisible(this._currentCrop, "step1", this._step == 3);
				setStepChildVisible(this._currentCrop, "step2", this._step == 4);
				setStepChildVisible(this._currentCrop, "step3", this._step != 3 && this._step != 4);
			}
			this._currentCrop.cacheAsBitmap = true;
			this._cropLayers = [];
			this._cropLayers.push(this._currentCrop);
			this._cropLayers.reverse();
			addChild(this._currentCrop);
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
