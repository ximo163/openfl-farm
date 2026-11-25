package module.mainScene.farmLand;

import com.greensock.TweenLite;
import common.Consts;
import common.GetCropID;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.cursor.CursorControl;
import entities.FarmLand;
import events.CommonEvent;
import framework.base.BaseLayer;
import module.mainScene.farmLand.widgets.LandItemRender;
import module.mainScene.farmLand.widgets.LandPickIcon;
import module.mainScene.farmLand.widgets.LandTalkTip;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;
import openfl.utils.Timer;
import shim.As3;

/**
 * module.mainScene.farmLand.FarmLandsView —— V3b 翻译（issue #8）。
 * 农田场景视图（地块菱形排布、悬浮高亮/提示、飞机动画、摘取图标、升级红土地
 * 动画挂接）。FarmLandsView.as 960 loc 逐句对应；原版 int 收 Number 表达式处
 * 用 Std.int 保持 AS3 隐式截断。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/FarmLandsView.as
 * PORT-NOTE(动态取键)：AS3 `obj["k"] != undefined` → Reflect.hasField(...) &&
 * Reflect.field(...) != null（JSON 只能产生缺键或 null，两边语义重合）；
 * `as int`（JSON 数值）→ As3.intOf；`as Boolean` → Std.isOfType(…, Bool)。
 */
@:keep
class FarmLandsView extends Sprite {
	// FarmLandsView.as:31
	public static var SCALE:Float = 0.75;

	// FarmLandsView.as:33（Haxe static 按源序初始化，SCALE 先声明）
	public static final ITEM_WIDTH:Float = 204 * SCALE;

	// FarmLandsView.as:35
	public static final ITEM_HEIGHT:Float = 102 * SCALE;

	// FarmLandsView.as:37
	private static final ITEM_TIP_OFFSET:Float = 20 * SCALE;

	// FarmLandsView.as:39
	private var m_pickIcon:LandPickIcon;

	// FarmLandsView.as:41
	private var m_currentItem:LandItemRender;

	// FarmLandsView.as:43
	private var _planeAnimation:MovieClip;

	// FarmLandsView.as:45
	private var m_tipDelayTimer:Timer;

	// FarmLandsView.as:47
	private var m_items:Array<Dynamic>;

	// FarmLandsView.as:49
	private var m_overFilters:Array<Dynamic>;

	// FarmLandsView.as:51
	private var m_controller:FarmLandController;

	// FarmLandsView.as:53
	private var m_talk:LandTalkTip;

	// FarmLandsView.as:55-67
	public function new(param1:FarmLandController) {
		super();
		name = Consts.SCENE_ZINDEX_LAND;
		this.m_controller = param1;
		this.m_tipDelayTimer = null;
		this.m_currentItem = null;
		this.m_overFilters = [new ColorMatrixFilter([1.6, 0, 0, 0, -21.59, 0, 1.6, 0, 0, -21.59, 0, 0, 1.6, 0, -21.59, 0, 0, 0, 1, 0])];
		this.m_items = null;
		this.m_talk = null;
		this.m_pickIcon = null;
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
	}

	// FarmLandsView.as:69-97
	private function onOperateFailed(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "money"));
		if (_loc2_ == 0) {
			return;
		}
		var _loc3_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		if (_loc3_ < 0 || _loc3_ >= this.m_items.length) {
			return;
		}
		var _loc4_:Float = this.m_items[_loc3_].x;
		var _loc5_:Float = this.m_items[_loc3_].y + ITEM_TIP_OFFSET;
		var _loc6_:Point = localToGlobal(new Point(_loc4_, _loc5_));
		var _loc7_:String = "- " + Math.abs(_loc2_);
		var _loc8_:Dynamic = {"text": _loc7_, "type": "4", "cId": 1, "x": _loc6_.x, "y": _loc6_.y};
		this.m_controller.openFloat(Consts.FLOAT_TYPE_HA, _loc8_);
	}

	// FarmLandsView.as:99-107
	private function onReclaimClicked(param1:LandItemRender):Void {
		if (Session.getInstance().harvestAnimationPlaying == true) {
			return;
		}
		this.m_currentItem = null;
		this.m_controller.model.nextReclaimCondition();
	}

	// FarmLandsView.as:109-152（_loc6_ 在内层循环后的残留值 3 被副行命名复用，
	// 原版如此，照抄）
	private function createLandTiles(param1:Int, param2:Int):Void {
		var _loc6_:Int = 0;
		var _loc7_:LandItemRender = null;
		var _loc8_:LandItemRender = null;
		if (param1 == 0 || param2 == 0) {
			return;
		}
		var _loc3_:Float = 46 + param2 * (ITEM_WIDTH / 2);
		var _loc4_:Float = 320 - ITEM_HEIGHT / 2;
		this.m_items = new Array<Dynamic>();
		var _loc5_:Int = 0;
		while (_loc5_ < param1) {
			_loc6_ = 0;
			while (_loc6_ < param2) {
				_loc7_ = new LandItemRender();
				_loc7_.name = "__FarmlandItem__" + _loc5_ + "." + _loc6_;
				_loc7_.x = _loc3_ + _loc5_ * ITEM_WIDTH / 2 - _loc6_ * ITEM_WIDTH / 2;
				_loc7_.y = _loc4_ + _loc5_ * ITEM_HEIGHT / 2 + _loc6_ * ITEM_HEIGHT / 2;
				addChild(_loc7_);
				this.m_items.push(_loc7_);
				_loc7_.addEventListener(MouseEvent.CLICK, this.onMouseEvent, true, 0, true);
				_loc6_++;
			}
			_loc5_++;
		}
		_loc3_ = 46;
		_loc4_ = 320 + ITEM_HEIGHT;
		_loc5_ = 0;
		while (_loc5_ < param1) {
			_loc8_ = new LandItemRender();
			_loc8_.name = "__FarmlandItem__" + _loc5_ + "." + _loc6_;
			_loc8_.x = _loc3_ + _loc5_ * ITEM_WIDTH / 2;
			_loc8_.y = _loc4_ + _loc5_ * ITEM_HEIGHT / 2;
			addChild(_loc8_);
			this.m_items.push(_loc8_);
			_loc8_.addEventListener(MouseEvent.CLICK, this.onMouseEvent, true, 0, true);
			_loc5_++;
		}
	}

	// FarmLandsView.as:154-202（AS3 `_fertilize > 0` 是 Boolean 强转数字，
	// ≡ 直接传布尔）
	private function updateLandItem(param1:LandItemRender, param2:FarmLand):Void {
		var _loc5_:Int = 0;
		var _loc6_:Int = 0;
		if (param1 == null || param2 == null) {
			return;
		}
		var _loc3_:UInt = param2._cId;
		var _loc4_:String = "";
		if (_loc3_ > 0) {
			_loc4_ = Settings.getInstance().getCropName(_loc3_);
		}
		if (_loc4_ != "") {
			_loc5_ = param2._step;
			if (param2._cropStatus >= 7) {
				_loc5_ = 7 - 1;
			}
			param1.setGrowStep(_loc5_, _loc3_);
			if (_loc5_ == 5 || _loc5_ == 6) {
				param1.createByproduct(0, 0);
				param1.updateLandStatus(param2._bitmap, true, false, param2._goldLand);
			} else {
				_loc6_ = 0;
				if (_loc5_ != 3 && _loc5_ != 4) {
					_loc6_ = 0;
				} else {
					_loc6_ = param2._pest;
				}
				param1.createByproduct(_loc6_, param2._weed);
				param1.updateLandStatus(param2._bitmap, param2._humidity > 0, param2._fertilize, param2._goldLand);
			}
			param1.createCrop(_loc3_, _loc4_, GetCropID.getCropUrl(_loc3_, _loc5_));
		} else {
			param1.clearAll();
			param1.updateLandStatus(param2._bitmap, param2._humidity > 0, param2._fertilize, param2._goldLand);
		}
	}

	// FarmLandsView.as:204-232
	private function onPlayPlaneAnimation(param1:Event):Void {
		var _loc2d:Dynamic = Utils.getMaterial("PlaneAnimation");
		var _loc2_:MovieClip = Std.isOfType(_loc2d, MovieClip) ? cast _loc2d : null;
		if (_loc2_ == null) {
			this.m_controller.model.reloadAllLands(false);
			return;
		}
		this.stage.addChild(_loc2_);
		var _loc3_:Int = stage.stageWidth * stage.stageWidth + stage.stageHeight * stage.stageHeight;
		_loc3_ = Std.int(Math.sqrt(_loc3_)); // AS3 int 收 Number 隐式截断
		_loc3_ = Std.int(_loc3_ * 0.5); // 同上
		var _loc4_:Float = 26.6 * Math.PI / 180;
		var _loc5_:Int = Std.int(stage.stageWidth * 0.5 + _loc3_ * Math.cos(_loc4_));
		var _loc6_:Int = Std.int(stage.stageHeight * 0.5 + _loc3_ * Math.sin(_loc4_) - 50);
		_loc2_.x = stage.stageWidth * 0.5;
		_loc2_.y = stage.stageHeight * 0.5 - 20;
		TweenLite.from(_loc2_, 0.5, {"x": _loc5_, "y": _loc6_, "scaleX": 3, "scaleY": 3, "delay": 1.5, "onComplete": this.onPlaneMoveIn});
		this._planeAnimation = _loc2_;
		this._planeAnimation.mouseChildren = false;
		this._planeAnimation.mouseEnabled = false;
	}

	// FarmLandsView.as:234-252
	private function registerListeners():Void {
		var _loc1_:FarmLandModel = this.m_controller.model;
		if (_loc1_ == null) {
			return;
		}
		_loc1_.addEventListener(FarmLandModel.EVENT_INITIALZED, this.onDataInitialized, false, 0, true);
		_loc1_.addEventListener(FarmLandModel.EVENT_HARVEST_DATA, this.onHarvestData, false, 0, true);
		_loc1_.addEventListener(FarmLandModel.EVENT_OPERATE_INVALID, this.onOperateInvalid, false, 0, true);
		_loc1_.addEventListener(FarmLandModel.EVENT_OPERATE_FAILED, this.onOperateFailed, false, 0, true);
		_loc1_.addEventListener(FarmLandModel.EVENT_ADD_HEALTH, this.onAddHealth, false, 0, true);
		_loc1_.addEventListener(FarmLandModel.EVENT_LAND_CHANGED, this.onFarmLandChanged, false, 0, true);
		_loc1_.addEventListener(FarmLandModel.EVENT_SHOW_PICK_ICON, this.onShowPickIcon, false, 0, true);
		_loc1_.addEventListener(FarmLandModel.EVENT_CHECK_STATUS, this.onCheckStatus, false, 0, true);
		_loc1_.addEventListener(FarmLandModel.EVENT_PLAY_PLANE, this.onPlayPlaneAnimation, false, 0, true);
		addEventListener(MouseEvent.ROLL_OVER, this.onMouseEvent, true, 0, true);
		addEventListener(MouseEvent.ROLL_OUT, this.onMouseEvent, true, 0, true);
	}

	// FarmLandsView.as:254-294
	private function onCheckStatus(param1:Event):Void {
		var _loc2_:Session = Session.getInstance();
		var _loc3_:Bool = false;
		var _loc4_:Bool = false;
		var _loc5_:Bool = false;
		var _loc6_:LandItemRender = null;
		var _loc7_:FarmLand = null;
		var _loc8_:Int = 0;
		while (_loc8_ < this.m_items.length) {
			var _loc6d:Dynamic = this.m_items[_loc8_];
			_loc6_ = Std.isOfType(_loc6d, LandItemRender) ? cast _loc6d : null;
			_loc7_ = this.m_controller.model.getLandData(_loc6_.index);
			if (_loc7_ != null) {
				if (_loc3_ == false) {
					_loc3_ = _loc7_.hasWeed;
				}
				if (_loc4_ == false) {
					_loc4_ = _loc7_.hasPest;
				}
				if (_loc5_ == false) {
					_loc5_ = _loc7_.needWater;
				}
			}
			_loc8_++;
		}
		this.m_controller.setNextAction(_loc3_, _loc4_, _loc5_);
		var _loc9_:UInt = _loc2_.currentUserIdByUinMode;
		var _loc10_:UInt = _loc2_.currentUser._uId;
		this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_FRIEND_STATUS, {
			"uId": _loc9_,
			"ownerId": _loc10_,
			"havest": false,
			"weed": _loc3_,
			"bug": _loc4_
		}));
	}

	// FarmLandsView.as:296-322
	private function onPlaneMoveIn():Void {
		var _loc1_:Int = 0;
		var _loc2_:Float = Math.NaN;
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		this.m_controller.model.reloadAllLands(false);
		if (this._planeAnimation != null) {
			_loc1_ = stage.stageWidth * stage.stageWidth + stage.stageHeight * stage.stageHeight;
			_loc1_ = Std.int(Math.sqrt(_loc1_)); // AS3 int 收 Number 隐式截断
			_loc1_ = Std.int(_loc1_ * 0.5); // 同上
			_loc2_ = 26.6 * Math.PI / 180;
			_loc3_ = Std.int(stage.stageWidth * 0.5 - _loc1_ * Math.cos(_loc2_));
			_loc4_ = Std.int(stage.stageHeight * 0.5 - _loc1_ * Math.sin(_loc2_) - 50);
			TweenLite.to(this._planeAnimation, 0.6, {
				"x": _loc3_,
				"y": _loc4_,
				"scaleX": 0.3,
				"scaleY": 0.3,
				"alpha": 0.2,
				"delay": 2.5,
				"onStart": this.onPlaneLeaving,
				"onComplete": this.onPlaneLeft
			});
		}
	}

	// FarmLandsView.as:324-343
	private function onAddHealth(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		if (_loc2_ < 0) {
			return;
		}
		var _loc3_:Float = this.m_items[_loc2_].x;
		var _loc4_:Float = this.m_items[_loc2_].y + ITEM_TIP_OFFSET;
		var _loc5_:Point = localToGlobal(new Point(_loc3_, _loc4_));
		var _loc6_:Dynamic = {"x": _loc5_.x, "y": _loc5_.y};
		this.m_controller.openFloat(Consts.FLOAT_TYPE_HEALTH, _loc6_);
	}

	// FarmLandsView.as:345-402
	public function talkRandom():Void {
		if (this.m_talk != null && this.m_talk.visible == true) {
			return;
		}
		var _loc1_:Float = Math.random();
		if (_loc1_ < 0.5) {
			return;
		}
		if (this.m_items != null && this.m_items.length > 0) {
			var _loc2_:Int = Std.int(Math.random() * this.m_items.length);
			var _loc3d:Dynamic = this.m_items[_loc2_];
			var _loc3_:LandItemRender = Std.isOfType(_loc3d, LandItemRender) ? cast _loc3d : null;
			if (_loc3_ == null) {
				return;
			}
			var _loc4_:FarmLand = this.m_controller.model.getLandData(_loc3_.index);
			if (_loc4_ == null || _loc4_._step >= 7) {
				return;
			}
			var _loc5_:Int = _loc4_._cId;
			var _loc6_:Dynamic = Settings.getInstance().getCropByID(Std.string(_loc5_));
			if (_loc6_ == null) {
				return;
			}
			var _loc7_:Bool = As3.truthy(Reflect.field(_loc6_, "isRed"));
			if (_loc7_ == true && Reflect.hasField(_loc6_, "gossip") && Reflect.field(_loc6_, "gossip") != null) {
				var _loc8_:String = Reflect.field(_loc6_, "gossip");
				if (_loc8_ != "") {
					if (this.m_talk == null) {
						this.m_talk = new LandTalkTip(_loc3_);
					} else {
						this.m_talk.parent = _loc3_;
					}
					var _loc9_:Point = new Point(60 * SCALE, 10 * SCALE);
					this.m_talk.startTalk(_loc8_, _loc9_, _loc3_.scaleX);
				}
			}
		}
	}

	// FarmLandsView.as:404-413
	public function loseMouse():Void {
		if (this.m_currentItem != null) {
			this.m_currentItem.filters = [];
		}
		this.m_currentItem = null;
		this.m_tipDelayTimer.stop();
		this.m_controller.hideTip();
	}

	// FarmLandsView.as:415-424
	private function onPlaneLeft():Void {
		if (this._planeAnimation != null) {
			this.stage.removeChild(this._planeAnimation);
			this._planeAnimation.stop();
			this._planeAnimation = null;
		}
		this.askSharePlane();
	}

	// FarmLandsView.as:426-436
	private function onOperateInvalid(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2d:Dynamic = Reflect.field(param1.data, "text");
		var _loc2_:String = Std.isOfType(_loc2d, String) ? cast _loc2d : null;
		var _loc3_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		var _loc4_:Int = As3.intOf(Reflect.field(param1.data, "yAdjust"));
		this.openLandFloatTip(_loc2_, _loc3_, _loc4_);
	}

	// FarmLandsView.as:438-456
	public function openLandFloatTip(param1:String, param2:Int, param3:Int = 0):Void {
		if (param1 == "" || param2 < 0 || param2 >= this.m_items.length) {
			return;
		}
		var _loc4_:Float = this.m_items[param2].x + this.m_items[param2].width * 0.5;
		var _loc5_:Float = this.m_items[param2].y + ITEM_TIP_OFFSET;
		var _loc6_:Point = localToGlobal(new Point(_loc4_, _loc5_));
		var _loc7_:Bool = Session.getInstance().me;
		var _loc8_:Dynamic = {"text": param1, "me": _loc7_, "x": _loc6_.x, "y": _loc6_.y, "yAdjust": param3};
		this.m_controller.openFloat(Consts.FLOAT_TYPE_OPERATE, _loc8_);
	}

	// FarmLandsView.as:458-542
	public function showPickIcon(param1:Bool, param2:Bool = false):Void {
		var _loc15_:Dynamic = null;
		var _loc3_:Session = Session.getInstance();
		if (param1 == true) {
			if (_loc3_.healthModeValid == true || _loc3_.currentFarmHealthModeValid == true) {
				if (this.m_pickIcon != null) {
					this.m_pickIcon.remove();
				}
			}
		}
		var _loc4_:Bool = false;
		var _loc5_:Bool = false;
		var _loc6_:Bool = false;
		var _loc7_:Bool = false;
		var _loc8_:UInt = _loc3_.currentUserIdByUinMode;
		var _loc9_:UInt = _loc3_.currentUser._uId;
		var _loc10_:String = _loc3_.hostId;
		var _loc11_:LandItemRender = null;
		var _loc12_:FarmLand = null;
		var _loc13_:Array<Dynamic> = [0, 3, 6, 9, 12, 15, 1, 4, 7, 10, 13, 16, 2, 5, 8, 11, 14, 17, 18, 19, 20, 21, 22, 23];
		var _loc14_:Int = 0;
		while (_loc14_ < _loc13_.length) {
			var _loc11d:Dynamic = this.m_items[_loc13_[_loc14_]];
			_loc11_ = Std.isOfType(_loc11d, LandItemRender) ? cast _loc11d : null;
			// 原版对 _loc11_ 不判空直接 .index，cast 失败即 AS3 TypeError 同款
			_loc12_ = this.m_controller.model.getLandData(_loc11_.index);
			if (_loc12_ != null) {
				if (_loc12_._step == 5 && !(_loc3_.healthModeValid == true || _loc3_.currentFarmHealthModeValid == true)) {
					_loc15_ = _loc12_._thief;
					// AS3 Object.hasOwnProperty(uin) ≡ Reflect.hasField（thief 是 JSON 匿名对象）
					if (_loc15_ != null && Reflect.hasField(_loc15_, _loc10_) == false) {
						if (_loc12_._left > 0 && (_loc12_._left > _loc12_._min || _loc3_.me == true)) {
							this.m_pickIcon.moveTo(_loc11_);
							this.m_pickIcon.play();
							_loc7_ = true;
							if (_loc3_.m_welcomeMode == false) {
								this.m_controller.setHandCursor();
							}
							this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_LAND_CAN_PICK, {
								"uId": _loc8_,
								"ownerId": _loc9_
							}));
							return;
						}
					}
				}
				if (_loc4_ == false) {
					_loc4_ = _loc12_.hasWeed;
				}
				if (_loc5_ == false) {
					_loc5_ = _loc12_.hasPest;
				}
				if (_loc6_ == false) {
					_loc6_ = _loc12_.needWater;
				}
			}
			_loc14_++;
		}
		if (this.m_pickIcon != null && _loc7_ == false) {
			this.m_pickIcon.stop();
		}
		this.m_controller.setNextAction(_loc4_, _loc5_, _loc6_);
		if (param2 == false) {
			this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_FRIEND_STATUS, {
				"uId": _loc8_,
				"ownerId": _loc9_,
				"havest": _loc7_,
				"weed": _loc4_,
				"bug": _loc5_,
				"check": true
			}));
		}
	}

	// FarmLandsView.as:544-589
	private function onHarvestData(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Dynamic = param1.data;
		var _loc3_:Int = As3.intOf(Reflect.field(_loc2_, "index"));
		if (_loc3_ < 0 || _loc3_ >= this.m_items.length) {
			return;
		}
		var _loc4_:FarmLand = this.m_controller.model.getLandData(_loc3_);
		if (_loc4_ == null) {
			return;
		}
		var _loc5_:Int = _loc4_._cId;
		var _loc6_:Bool = _loc4_._bitmap > 0 ? true : false;
		var _loc7_:String = "";
		var _loc8_:Dynamic = Settings.getInstance().getCropByID(Std.string(_loc5_));
		// AS3 `== "1"` 松等：nc_data.php 里 isAnimation 有数值形态
		//（id 28/158/168/334 的 "isAnimation": 1）→ As3.eqString
		if (_loc8_ != null && As3.eqString(Reflect.field(_loc8_, "isAnimation"), "1")) {
			_loc7_ = Consts.FLOAT_TYPE_HAC;
		} else if (Reflect.hasField(_loc2_, "plus") && Reflect.field(_loc2_, "plus") != null && _loc5_ > 0 && _loc6_ == true) {
			_loc7_ = Consts.FLOAT_TYPE_HAP;
		} else {
			_loc7_ = Consts.FLOAT_TYPE_HA;
		}
		var _loc9_:Float = this.m_items[_loc3_].x;
		var _loc10_:Float = this.m_items[_loc3_].y + ITEM_TIP_OFFSET;
		var _loc11_:Point = localToGlobal(new Point(_loc9_, _loc10_));
		var _loc12_:Dynamic = {
			"text": Reflect.field(_loc2_, "text"),
			"type": "1",
			"cId": Reflect.field(_loc2_, "cId"),
			"x": _loc11_.x,
			"y": _loc11_.y
		};
		this.m_controller.openFloat(_loc7_, _loc12_);
		this.showPickIcon(true);
	}

	// FarmLandsView.as:591-610
	public function checkCropLoaded():Bool {
		if (this.m_items == null || this.m_items.length == 0) {
			return true;
		}
		var _loc1_:LandItemRender = null;
		var _loc2_:UInt = this.m_items.length;
		var _loc3_:Int = 0;
		while (_loc3_ < _loc2_) {
			var _loc1d:Dynamic = this.m_items[_loc3_];
			_loc1_ = Std.isOfType(_loc1d, LandItemRender) ? cast _loc1d : null;
			if (_loc1_ != null && _loc1_.cropLoaded == false) {
				return false;
			}
			_loc3_++;
		}
		return true;
	}

	// FarmLandsView.as:612-619
	public var landNum(get, never):Int;

	private function get_landNum():Int {
		if (this.m_items == null) {
			return 0;
		}
		return this.m_items.length;
	}

	// FarmLandsView.as:621-630
	private function onAddedToStage(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this.registerListeners();
		this.createLandTiles(6, 3);
		var _loc2_:LandItemRender = this.m_items[0];
		// AS3 Number → int 形参隐式截断
		this.m_pickIcon = new LandPickIcon(this, Std.int(_loc2_.x + 100), Std.int(_loc2_.y - 70));
		this.m_tipDelayTimer = new Timer(100, 1);
		this.m_tipDelayTimer.addEventListener(TimerEvent.TIMER, this.onMouseOverTimer, false, 0, true);
	}

	// FarmLandsView.as:632-639
	private function onLandClicked():Void {
		if (this.m_currentItem == null || this.m_currentItem.waste == true) {
			return;
		}
		this.m_controller.clickOnLand(this.m_currentItem);
	}

	// FarmLandsView.as:641-649
	private function onShowPickIcon(param1:CommonEvent):Void {
		var _loc2_:Bool = true;
		if (param1 != null && param1.data != null && Reflect.hasField(param1.data, "healthMode") && Reflect.field(param1.data, "healthMode") != null) {
			// AS3 `as Boolean`：值非 Boolean 得 null → Boolean 变量 false
			var _loc2d:Dynamic = Reflect.field(param1.data, "healthMode");
			_loc2_ = Std.isOfType(_loc2d, Bool) ? _loc2d : false;
		}
		this.showPickIcon(_loc2_);
	}

	// FarmLandsView.as:651-726（"end" 事件由升级动画（RedUp.swf）主时间轴末帧
	// 帧脚本派发——本地化管线丢帧脚本，openfl 侧复原走 shim/
	// FrameScriptCompensation（#58）；data["red"]/["black"]/["gold"] 由
	// FarmLandController 升级装载完成回调构造，均为真 Boolean，== true 照翻）
	public function playUpgradeRed(param1:Int, param2:Sprite, param3:Dynamic):Void {
		var fi:LandItemRender = null;
		var parent:DisplayObjectContainer = null;
		var index:Int = param1;
		var animation:Sprite = param2;
		var data:Dynamic = param3;
		if (animation == null || data == null) {
			return;
		}
		if (index < 0 || index >= this.m_items.length) {
			return;
		}
		var fid:Dynamic = this.m_items[index];
		fi = Std.isOfType(fid, LandItemRender) ? cast fid : null;
		if (fi == null) {
			return;
		}
		animation.x = 100;
		animation.y = -70;
		animation.mouseChildren = false;
		animation.mouseEnabled = false;
		fi.addChild(animation);
		parent = this.stage;
		animation.addEventListener("end", function(param1:Event):Void {
			var _loc5_:FarmLand = null;
			var _loc6_:Int = 0;
			var _loc7_:Dynamic = null;
			var cur:Dynamic = param1.currentTarget;
			var _loc2d:Dynamic = cur.parent;
			var _loc2_:LandItemRender = Std.isOfType(_loc2d, LandItemRender) ? cast _loc2d : null;
			cur.stop();
			_loc2_.removeChild(cur);
			var _loc3_:Int = Reflect.field(data, "red") == true ? 1 : 0;
			_loc3_ = Reflect.field(data, "black") == true ? 2 : _loc3_;
			var _loc4_:String = _loc3_ == 1 ? "红土地升级成功!" : "";
			_loc4_ = _loc3_ == 2 ? "黑土地升级成功!" : _loc4_;
			if (Reflect.field(data, "gold") == true) {
				_loc4_ = "金牌土地升级成功!";
			}
			m_controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP, {"text": _loc4_, "parent": parent});
			if (Reflect.field(data, "gold") != true) {
				_loc5_ = m_controller.model.getLandData(index);
				if (_loc5_ != null) {
					_loc6_ = _loc5_._cId;
					_loc7_ = Settings.getInstance().getCropByID(Std.string(_loc6_));
					if (_loc7_ != null) {
						// AS3 `== "1"/"2"` 松等：isRed 有数值形态（nc_data.php
						// id 116/242/243/244/246 的 "isRed": 1）→ As3.eqString
						if (As3.eqString(Reflect.field(_loc7_, "isRed"), "1")) {
							openLandFloatTip("红土地,普通作物将增产10%!", index);
						} else if (As3.eqString(Reflect.field(_loc7_, "isRed"), "2")) {
							openLandFloatTip("黑土地,普通和高级作物将提速20%!", index);
						}
					}
				}
			}
			// AS3 `gold == undefined`：缺键或 null（null == undefined）都走这支
			if (Reflect.hasField(data, "gold") == false || Reflect.field(data, "gold") == null) {
				m_controller.model.updateLandData(As3.intOf(Reflect.field(data, "place")), As3.intOf(Reflect.field(data, "output")), As3.intOf(Reflect.field(data, "leavings")), As3.intOf(Reflect.field(data, "min")), _loc3_, -1);
			} else {
				m_controller.model.updateLandData(As3.intOf(Reflect.field(data, "place")), As3.intOf(Reflect.field(data, "output")), As3.intOf(Reflect.field(data, "leavings")), As3.intOf(Reflect.field(data, "min")), _loc3_, Reflect.field(data, "gold") == true ? 1 : 0);
			}
		});
	}

	// FarmLandsView.as:728-750
	private function onFarmLandChanged(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (this.m_items == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "index"));
		if (_loc2_ < 0 || _loc2_ >= this.m_items.length) {
			return;
		}
		var _loc3d:Dynamic = this.m_items[_loc2_];
		var _loc3_:LandItemRender = Std.isOfType(_loc3d, LandItemRender) ? cast _loc3d : null;
		var _loc4_:FarmLand = this.m_controller.model.getLandData(_loc2_);
		this.updateLandItem(_loc3_, _loc4_);
		if (Reflect.field(param1.data, "animation") == true) {
			this.playLandEffect(_loc3_);
		}
	}

	// FarmLandsView.as:752-759
	public function hideTalkTip():Void {
		if (this.m_talk == null) {
			return;
		}
		this.m_talk.stopTalk();
	}

	// FarmLandsView.as:761-776
	private function playLandEffect(param1:LandItemRender):Void {
		if (param1 == null) {
			return;
		}
		var _loc2d:Dynamic = Utils.getMaterial("LandCropEffect");
		var _loc2_:MovieClip = Std.isOfType(_loc2d, MovieClip) ? cast _loc2d : null;
		if (_loc2_ == null) {
			return;
		}
		_loc2_.x = 20 * scaleX;
		_loc2_.y = -17 * scaleY;
		param1.addChild(_loc2_);
		_loc2_.play();
	}

	// FarmLandsView.as:778-835
	private function onDataInitialized(param1:CommonEvent):Void {
		var _loc9_:Bool = false;
		var _loc10_:String = null;
		if (param1 == null || param1.data == null) {
			return;
		}
		if (this.m_items == null || this.m_items.length == 0) {
			return;
		}
		var _loc2_:Bool = Session.getInstance().me;
		var _loc3d:Dynamic = param1.data;
		var _loc3_:Array<Dynamic> = Std.isOfType(_loc3d, Array) ? cast _loc3d : null;
		var _loc4_:LandItemRender = null;
		var _loc5_:FarmLand = null;
		var _loc6_:Int = 0;
		while (_loc6_ < this.m_items.length) {
			var _loc4d:Dynamic = this.m_items[_loc6_];
			_loc4_ = Std.isOfType(_loc4d, LandItemRender) ? cast _loc4d : null;
			var _loc5d:Dynamic = _loc3_[_loc6_];
			_loc5_ = Std.isOfType(_loc5d, FarmLand) ? cast _loc5d : null;
			_loc4_.index = _loc6_;
			if (_loc6_ < _loc3_.length) {
				_loc4_.waste = false;
				this.updateLandItem(_loc4_, _loc5_);
			} else {
				_loc4_.waste = true;
				_loc9_ = false;
				if (_loc3_.length == _loc6_) {
					if (_loc2_ == true) {
						_loc9_ = true;
					}
				}
				_loc4_.reclaim = _loc9_;
			}
			_loc6_++;
		}
		var _loc7_:Bool = true;
		var _loc8_:BaseLayer = this.m_controller.module.app.farmView.getLayerByName(Consts.LAYER_TOOLS);
		if (_loc8_ != null && _loc8_.hitTestPoint(mouseX, mouseY) == true) {
			_loc7_ = false;
		}
		if (_loc7_ == true && Session.getInstance().isInWildStage == false) {
			this.showPickIcon(true);
			_loc10_ = this.m_controller.module.app.farmView.cursorCtrl.name;
			if (_loc10_ == null || _loc10_ == "") {
				this.m_controller.module.app.farmView.cursorCtrl.setCursor(Consts.CURSOR_STYLE_ARROW);
			}
		}
	}

	// FarmLandsView.as:837-839
	private function onPlaneLeaving():Void {}

	// FarmLandsView.as:841-863
	private function askSharePlane():Void {
		var onPlaneShareConfirmed:Void->Void = null;
		onPlaneShareConfirmed = function():Void {
			// AS3 encodeURIComponent ≡ StringTools.urlEncode
			var _loc1_:String = "mod=cgi_qzshare_onekey";
			_loc1_ += "url=" + StringTools.urlEncode("");
			_loc1_ += "&desc=" + StringTools.urlEncode("");
			_loc1_ += "&summary=" + StringTools.urlEncode("我已经使用了飞机施肥，真的一下子全熟了！感觉爽翻~你也快来体验呐！");
			_loc1_ += "&title=" + StringTools.urlEncode("飞机施肥，一键全熟！");
			_loc1_ += "&site=" + StringTools.urlEncode("QQ农场");
			_loc1_ += "&pics=" + StringTools.urlEncode("module/ui/icons/planeshare.jpg");
			QzoneJSAPI.openWindow(_loc1_);
		};
		this.m_controller.openWindow(Consts.WINDOW_NAME_CONFIRM, {
			"title": "分享喜悦？",
			"width": 320,
			"height": 310,
			"customIcon": "PlaneConfirmIcon",
			"text": "我已经使用了飞机施肥，一键全熟！<BR/>一下子成熟的感觉好极了！",
			"confirmFn": onPlaneShareConfirmed
		});
	}

	// FarmLandsView.as:865-882
	private function onMouseOverTimer(param1:TimerEvent):Void {
		if (param1 == null || this.m_currentItem == null) {
			return;
		}
		if (this.m_currentItem.waste == true) {
			return;
		}
		this.m_currentItem.filters = cast this.m_overFilters; // AS3 Array → openfl Array<BitmapFilter>
		var _loc2_:Int = this.m_currentItem.index;
		var _loc3_:FarmLand = this.m_controller.model.getLandData(_loc2_);
		if (_loc3_ != null) {
			this.m_controller.showTip(Consts.TIP_NAME_LAND_INFOR, _loc3_);
		}
	}

	// FarmLandsView.as:884-957
	private function onMouseEvent(param1:MouseEvent):Void {
		var _loc4_:LandItemRender = null;
		if (param1 == null || param1.target == null) {
			return;
		}
		var _loc2_:CursorControl = null;
		if (this.m_controller.module != null && this.m_controller.module.app != null) {
			_loc2_ = this.m_controller.module.app.farmView.cursorCtrl;
		}
		if (_loc2_ == null || _loc2_.name == Consts.CURSOR_STYLE_FISHNET) {
			return;
		}
		if (_loc2_.name == Consts.CURSOR_STYLE_TOOL) {
			if (_loc2_.cursorArgument.indexOf(Consts.ITEM_TYPE_FISHFEED + ",") != -1) {
				return;
			}
		} else if (_loc2_.name == Consts.CURSOR_STYLE_CROPSEED) {
			if (_loc2_.cursorArgument.indexOf(Consts.ITEM_TYPE_FISH + ",") != -1) {
				return;
			}
		}
		// PORT-NOTE: e.target/currentTarget 静态是 openfl Object（=Dynamic），
		// `.name` 裸读在 js/eval 上恒 undefined（openfl 的 name 是 get/set、
		// 无物理字段，机制见 handbook/lessons）——强类型读恢复 AS3 的 getter
		// 语义，本处理器按原版只从显示对象收事件
		var _loc3_:String = (param1.target : DisplayObject).name;
		if (param1.type == MouseEvent.ROLL_OVER) {
			if (_loc3_ == "__reclaim__") {
				this.m_controller.useSystemCursor(true);
			} else if (_loc3_.indexOf("__FarmlandItem__") != -1) {
				var _loc2d:Dynamic = param1.target;
				this.m_currentItem = Std.isOfType(_loc2d, LandItemRender) ? cast _loc2d : null;
				this.m_tipDelayTimer.reset();
				this.m_tipDelayTimer.start();
			}
		} else if (param1.type == MouseEvent.ROLL_OUT) {
			if (_loc3_ == "__reclaim__") {
				this.m_controller.useSystemCursor(false);
			} else if (_loc3_.indexOf("__FarmlandItem__") != -1) {
				this.loseMouse();
			}
		} else if (param1.type == MouseEvent.CLICK) {
			_loc3_ = (param1.target : DisplayObject).name;
			if (_loc3_ == "__reclaim__") {
				var _loc4d:Dynamic = param1.target.parent;
				_loc4_ = Std.isOfType(_loc4d, LandItemRender) ? cast _loc4d : null;
				this.onReclaimClicked(_loc4_);
			} else {
				_loc3_ = (param1.currentTarget : DisplayObject).name;
				if (_loc3_.indexOf("__FarmlandItem__") != -1) {
					var _loc5d:Dynamic = param1.currentTarget;
					this.m_currentItem = Std.isOfType(_loc5d, LandItemRender) ? cast _loc5d : null;
					this.onLandClicked();
				}
			}
		}
	}
}
