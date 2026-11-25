package module.water;

import common.CommonData;
import common.Consts;
import common.Language;
import common.Session;
import common.misc.Cookies;
import common.misc.Utils;
import common.misc.time.CountDown;
import common.view.cursor.CursorControl;
import entities.PoolFish;
import events.CommonEvent;
import framework.base.Controller;
import interfaces.IMsgCenter;
import module.GameGuide;
import openfl.events.Event;
import openfl.geom.Point;
import shim.As3;

/**
 * module.water.WaterController —— WaterController.as 逐句对应（issue #37
 * 功能 swf 翻译：鱼塘 pool_v_13 控制器，ModuleWater 反射入口的落点）。
 * 组 WaterModel（数据/7 个 mod）+ WaterPool（交互视图）+ PoolInfoWindow（鱼
 * 商店/详情窗）+ WaterGrayOpen（未开通引导板）；MSG_* 应用级消息、
 * FishAnimationMgr GC 的 onGameLoop 驱动都在这。
 *
 * PORT-NOTE: AS3 internal static const（WaterModel.EVENT_*）译 private 后，
 * 同包消费方按 FriendsController 先例以 @:access 取（Haxe private 非包可见）。
 * `setTimeout` → As3.setTimeout（eval/html5/android 同通道）。
 */
@:access(module.water.WaterModel)
class WaterController extends Controller {
	// WaterController.as:23
	private var m_updateFreq:CountDown;

	// WaterController.as:25（AS3 实例 const → static final，CLAUDE.md 映射）
	static final ITEM_HEIGHT:Float = 76.5;

	// WaterController.as:27
	private var _infoWindow:PoolInfoWindow;

	// WaterController.as:29
	// AS3 Number 默认 NaN（eval/js 未赋值是 null/undefined，显式落）
	private var _batchProcessTime:Float = Math.NaN;

	// WaterController.as:31
	private var _disableInfoWin:Bool = false;

	// WaterController.as:33
	private var _grayOpen:WaterGrayOpen;

	// WaterController.as:35
	static final ITEM_WIDTH:Float = 153;

	// WaterController.as:37-44
	public function new() {
		super(null);
		this.m_updateFreq = new CountDown(Consts.FARM_LAND_COUNTDOWN);
		this._grayOpen = null;
		this._batchProcessTime = -1;
		this._disableInfoWin = false;
	}

	// WaterController.as:46-124
	private function onFishLoaded(param1:CommonEvent):Void {
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:UInt = 0;
		var _loc6_:UInt = 0;
		var _loc7_:Bool = false;
		var _loc8_:Dynamic = null;
		var _loc9_:CursorControl = null;
		var _loc2_:Session = Session.getInstance();
		var _loc3_:Bool = _loc2_.me;
		if (this.model.opened == true) {
			_loc4_ = cast param1.data;
			if (_loc4_ == null || _loc4_.length == 0) {
				this.view.reset();
			} else {
				this.view.fillFishes(_loc4_);
			}
			if (_loc3_ == true) {
				_loc7_ = _loc2_.m_waterPoolOpen;
				if (_loc7_ == false) {
					_loc2_.m_waterPoolOpen = true;
					m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_POOL_OPEN, true));
				}
			}
			this.updatePoolInfoBtn();
			_loc5_ = _loc2_.currentUser._uId;
			_loc6_ = _loc2_.currentUserIdByUinMode;
			if (this.model.canSteal(_loc3_) == false) {
				if (_loc3_ == false) {
					Cookies.setObject("f_" + _loc6_, CommonData.serverTime);
				} else {
					this.adjustCursorFirstTime();
				}
				m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_FISH_FRIENDLIST, {
					"uId": _loc2_.currentUserIdByUinMode,
					"ownerId": _loc5_,
					"hasFish": false,
					"check": true
				}));
			} else {
				_loc8_ = {"harvest": false};
				m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_LAND_CURSOR, null, _loc8_));
				if (Reflect.field(_loc8_, "harvest") == false) {
					_loc9_ = m_module.app.farmView.cursorCtrl;
					if (_loc9_ != null) {
						_loc9_.setCursor(Consts.CURSOR_STYLE_FISHNET_ALL);
					}
				}
				m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_FISH_FRIENDLIST, {
					"uId": _loc2_.currentUserIdByUinMode,
					"ownerId": _loc5_,
					"hasFish": true,
					"check": true
				}));
			}
		} else if (_loc3_ == true) {
			if (this._grayOpen == null) {
				this._grayOpen = new WaterGrayOpen(this, this.view);
			}
			this._grayOpen.flag = this.model.whited;
		}
	}

	// WaterController.as:126-133
	private function onShowErrorMsg(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.view.showErrorMsg(Reflect.field(param1.data, "msg"), As3.intOf(Reflect.field(param1.data, "id")));
	}

	// WaterController.as:135-147
	private function onShowPoolInfo(param1:Event):Void {
		if (this._disableInfoWin == true) {
			return;
		}
		if (this._infoWindow == null) {
			this._infoWindow = new PoolInfoWindow(m_module.app);
		}
		this._infoWindow.data = {"fishes": this.model.poolFishes};
		m_module.app.farmView.winCtrl.open(this._infoWindow);
	}

	// WaterController.as:149-155
	private function onShowGuideArrow(param1:CommonEvent):Void {
		if (As3.intOf(Reflect.field(param1.data, "step")) == GameGuide.WATER_POOL_CENTER) {
			this.view.showGuideArrow(As3.intOf(Reflect.field(param1.data, "step")));
		}
	}

	// WaterController.as:157-173。data 是 0/1/2 档位（WaterModel 批捞派发）
	private function onBatchProcessFish(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.view.disableMouse = As3.floatOf(param1.data) >= 1;
		this._disableInfoWin = true;
		if (As3.floatOf(param1.data) == 0) {
			m_module.app.useSystemCursor(false);
		} else if (As3.floatOf(param1.data) == 2) {
			this._batchProcessTime = 1200;
		}
	}

	// WaterController.as:175-198
	private function onGrowUp(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:PoolFish = cast(Reflect.field(param1.data, "fish"), PoolFish);
		var _loc3_:Int = As3.intOf(Reflect.field(param1.data, "food"));
		if (_loc2_ == null) {
			return;
		}
		var _loc4_:FishMover = this.view.findFishByID(_loc2_._id);
		if (_loc4_ != null) {
			_loc4_.grow();
			this.view.refreshInfoTip(_loc2_);
			this.view.refreshMatureFlag(false);
		}
		m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_DATA_REMOVE, {
			"type": As3.parseInt(Consts.ITEM_TYPE_FISHFEED),
			"id": _loc3_
		}));
	}

	// WaterController.as:200-203
	public function restoreLandCursor():Void {
		m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_LAND_CURSOR, null));
	}

	// WaterController.as:205-209
	private function updatePoolInfoBtn():Void {
		var _loc1_:Bool = Session.getInstance().me;
		m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_POOLINFO, {"size": (_loc1_ ? this.model.poolSize : -1)}));
	}

	// WaterController.as:211-242
	private function onFishHarvest(param1:CommonEvent):Void {
		var _loc7_:UInt = 0;
		if (param1.data == null) {
			return;
		}
		if (param1 != null && param1.data != null && As3.floatOf(Reflect.field(param1.data, "count")) > 0) {
			m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_FISH_RELOAD_FLAG, null));
		}
		this.updatePoolInfoBtn();
		var _loc2_:Int = As3.intOf(Reflect.field(param1.data, "count"));
		var _loc3_:Int = As3.intOf(Reflect.field(param1.data, "id"));
		var _loc4_:Bool = As3.truthy(Reflect.field(param1.data, "remove"));
		this.view.harvestFish(_loc3_, _loc2_, _loc4_);
		var _loc5_:Session = Session.getInstance();
		var _loc6_:Bool = _loc5_.me;
		if (this.model.canSteal(_loc6_) == false) {
			if (_loc6_ == false) {
				Cookies.setObject("f_" + _loc5_.currentUserIdByUinMode, CommonData.serverTime);
			}
			_loc7_ = _loc5_.currentUser._uId;
			m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_FISH_FRIENDLIST, {
				"uId": _loc5_.currentUserIdByUinMode,
				"ownerId": _loc7_,
				"remove": true
			}));
		}
	}

	// WaterController.as:244-253
	private function onGameDataReloaded(param1:CommonEvent):Void {
		this.view.reset();
		var _loc2_:Bool = Session.getInstance().me;
		if (this._grayOpen != null) {
			this._grayOpen.myHome = _loc2_;
		}
		this.onInitialized(param1);
	}

	// WaterController.as:255-263
	private function onUpdateMatureFlag(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		var _loc2_:Int = As3.intOf(param1.data);
		this.view.updateMatureFlag(_loc2_);
	}

	// WaterController.as:265-297
	private function onFishPlanted(param1:CommonEvent):Void {
		var _loc2_:PoolFish = cast param1.data;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Point = this.view.findNearPos();
		if (_loc3_ != null) {
			this.view.addFish(_loc2_, _loc3_.x, _loc3_.y);
		}
		m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_DATA_REMOVE, {
			"id": _loc2_._type,
			"type": As3.parseInt(Consts.ITEM_TYPE_FISH)
		}));
		this.updatePoolInfoBtn();
		var _loc4_:Int = Std.int(Math.max(0, Consts.FISH_MAX_SIZE - this.model.poolSize));
		var _loc5_:Int = _loc2_.poolSize;
		var _loc6_:String = Language.replaceText("plantFishTip", {
			"size": _loc5_,
			"num": _loc4_
		});
		openFloat(Consts.FLOAT_TYPE_TEXTTIP, {
			"text": _loc6_,
			"parent": this.view.stage
		});
		if (_loc4_ <= 0) {
			m_module.app.dispatchEvent(new Event(Consts.CLOSE_MY_BAG));
		}
		GameGuide.instance().hide();
	}

	// WaterController.as:299-318
	private function registerListeners():Void {
		var _loc1_:IMsgCenter = cast(m_module.app, IMsgCenter);
		if (_loc1_ != null) {
			_loc1_.addEventListener(Consts.MSG_RELOAD_GAME_RESULT, this.onGameDataReloaded, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_FISH_GUIDE, this.onShowGuideArrow, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_SHOW_WATER_CURSOR, this.onShowFishCursor, false, 0, true);
			_loc1_.addEventListener(Consts.MSG_SHOW_POOLINFO, this.onShowPoolInfo, false, 0, true);
		}
		this.model.addEventListener(WaterModel.EVENT_DATA_LOADED, this.onFishLoaded, false, 0, true);
		this.model.addEventListener(WaterModel.EVENT_FISH_PLANTED, this.onFishPlanted, false, 0, true);
		this.model.addEventListener(WaterModel.EVENT_FISH_HARVESTED, this.onFishHarvest, false, 0, true);
		this.model.addEventListener(WaterModel.EVENT_FISH_CHANGED, this.onFishChanged, false, 0, true);
		this.model.addEventListener(WaterModel.EVENT_ERROR_MSG, this.onShowErrorMsg, false, 0, true);
		this.model.addEventListener(WaterModel.EVENT_LEVELUP, this.onLevelUp, false, 0, true);
		this.model.addEventListener(WaterModel.EVENT_GROW_UP, this.onGrowUp, false, 0, true);
		this.model.addEventListener(WaterModel.EVENT_BATCH_FISH, this.onBatchProcessFish, false, 0, true);
		this.model.addEventListener(WaterModel.EVENT_UPDATE_MATURE_FLAG, this.onUpdateMatureFlag, false, 0, true);
	}

	// WaterController.as:320-328
	override public function finalize():Void {
		if (m_model != null) {
			m_model = null;
		}
		this._grayOpen = null;
		this._infoWindow = null;
	}

	// WaterController.as:330-336
	private function adjustCursorFirstTime():Void {
		As3.setTimeout(function():Void {
			restoreLandCursor();
		}, 3000);
	}

	// WaterController.as:338-344
	private function onLevelUp(param1:CommonEvent):Void {
		if (param1 != null && param1.data != null) {
			m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_LEVELUP, param1.data));
		}
	}

	// WaterController.as:346-354
	private function onFishChanged(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		this.view.refreshInfoTip(cast(param1.data, PoolFish));
		this.view.refreshMatureFlag(true);
	}

	// WaterController.as:356-359
	public var model(get, never):WaterModel;

	private function get_model():WaterModel {
		return cast(m_model, WaterModel);
	}

	// WaterController.as:361-376。`param1.result["fish"] = ...` 匿名记录写 →
	// Reflect.setField
	private function onShowFishCursor(param1:CommonEvent):Void {
		var _loc4_:CursorControl = null;
		if (param1.result == null) {
			return;
		}
		var _loc2_:Bool = Session.getInstance().me;
		var _loc3_:Bool = this.model.canSteal(_loc2_);
		Reflect.setField(param1.result, "fish", _loc3_);
		if (_loc3_ == true) {
			_loc4_ = m_module.app.farmView.cursorCtrl;
			_loc4_.setCursor(Consts.CURSOR_STYLE_FISHNET_ALL);
		}
	}

	// WaterController.as:378-398
	override public function initialze():Void {
		var _loc1_:WaterPool = null;
		if (m_model == null) {
			m_model = new WaterModel();
		}
		this.registerListeners();
		if (m_view == null) {
			_loc1_ = new WaterPool(this);
			m_view = _loc1_;
			if (m_module != null && m_module.container != null) {
				// 基类 m_view 是 Dynamic 字段，cpp 上 openfl 的 x/y get/set
				// 属性不能 Dynamic 裸写（真机 Invalid field:x，#10 同族，2026-11-24
				// debug 栈实锤本行）——经类型化局部（同一对象）写，值不变。
				_loc1_.x = 46 + 6 * ITEM_WIDTH / 2;
				_loc1_.y = 320 + 4 * ITEM_HEIGHT / 2;
				m_module.container.addChild(m_view);
			}
			this.onInitialized(null);
		}
	}

	// WaterController.as:400-423
	private function onInitialized(param1:CommonEvent):Void {
		var _loc2_:Bool = Session.getInstance().me;
		if (_loc2_ == true) {
			this.model.checkWhiteList();
		} else {
			this.model.loadFishes();
		}
		this._batchProcessTime = -1;
		this.view.disableMouse = false;
		var _loc3_:CursorControl = null;
		if (m_module != null && m_module.app != null) {
			_loc3_ = m_module.app.farmView.cursorCtrl;
		}
		if (_loc3_ != null) {
			_loc3_.register(Consts.CURSOR_STYLE_FISHNET, Utils.getClass("CursorFishNet"));
			_loc3_.register(Consts.CURSOR_STYLE_FISHNET_ALL, Utils.getClass("CursorFishNetAll"));
		}
	}

	// WaterController.as:425-440
	public function switchMode(param1:Bool):Void {
		this.view.hideInfoTip();
		if (param1 == true) {
			this.view.scaleX = this.view.scaleY = 1.3;
			this.view.x = 46 * 1.3 + 6 * ITEM_WIDTH * 1.3 / 2;
			this.view.y = 320 * 1.3 + 4 * ITEM_HEIGHT * 1.3 / 2;
		} else {
			this.view.scaleX = this.view.scaleY = 1;
			this.view.x = 46 + 6 * ITEM_WIDTH / 2;
			this.view.y = 320 + 4 * ITEM_HEIGHT / 2;
		}
	}

	// WaterController.as:442-471
	public function onGameLoop(param1:Float):Void {
		if (this._batchProcessTime >= 0) {
			this._batchProcessTime += param1;
			if (this._batchProcessTime >= 700) {
				if (this.model.processBatchFish() == false) {
					this._batchProcessTime = -1;
				} else {
					this._batchProcessTime = 0;
				}
			}
		}
		if (this.m_updateFreq.isReady() == false) {
			return;
		}
		this.m_updateFreq.reset(Consts.WATER_POOL_COUNTDOWN);
		this.model.growLoop();
		if (this._batchProcessTime == -1) {
			this.view.refreshMatureFlag(false);
			this._disableInfoWin = false;
		}
		FishAnimationMgr.getInstance().onGameLoop(param1);
	}

	// WaterController.as:473-476
	public var view(get, never):WaterPool;

	private function get_view():WaterPool {
		return cast(m_view, WaterPool);
	}
}
