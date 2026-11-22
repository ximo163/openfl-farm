package module.water;

import common.CommonData;
import common.Consts;
import common.Session;
import common.Settings;
import common.misc.Utils;
import common.view.cursor.CursorControl;
import entities.PoolFish;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.geom.Point;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.utils.Timer;
import module.GameGuide;
import shim.As3;
import shim.ClipProps;
import shim.LocalSwfLoader;

/**
 * module.water.WaterPool —— WaterPool.as 逐句对应（issue #37 功能 swf 翻译：
 * 鱼塘 pool_v_13 交互主视图，继承 PoolMap）。Event.ENTER_FRAME 帧驱动各
 * FishMover.moveFrame（帧驱动动画，CLAUDE.md 画面保真：不许改时间驱动）、
 * 点击捞/偷/喂/放、长按悬停 50ms Timer 出 FishInfoTip、成熟标志 _matureFlag
 * 跟鱼游动。
 *
 * PORT-NOTE(load-swf)：`new Loader()` → shim.LocalSwfLoader（CLAUDE.md 加载
 * 映射：原版资产已本地化，water_v_5.swf 走 Assets 库，调用点保持
 * loader.load(req, context) 原形态）。_matureFlag 的 `["fish"]` 是原版挂
 * 素材剪辑上的动态属性（存 FishMover）→ shim.ClipProps 侧表读写（同通道）。
 */
class WaterPool extends PoolMap {
	// WaterPool.as:29
	private var _loading:MovieClip;

	// WaterPool.as:31
	private var _mouseState:Dynamic;

	// WaterPool.as:33
	private var _disableMouse:Bool = false;

	// WaterPool.as:35
	private var _water:MovieClip;

	// WaterPool.as:37
	private var _loader:Loader;

	// WaterPool.as:39
	private var _matureFlag:MovieClip;

	// WaterPool.as:41
	private var _controller:WaterController;

	// WaterPool.as:43
	private var _timer:Timer;

	// WaterPool.as:45
	private var _toBeDeleted:Int = 0;

	// WaterPool.as:47
	private var _tip:FishInfoTip;

	// WaterPool.as:49
	private var _stone:MovieClip;

	// WaterPool.as:51
	private var _fishMovers:Array<Dynamic>;

	// WaterPool.as:53
	private var _selectedFish:FishMover;

	// WaterPool.as:55-68
	public function new(param1:WaterController) {
		super();
		this._controller = param1;
		name = "__waterpool__";
		this._water = null;
		this._stone = null;
		this._loading = null;
		this._selectedFish = null;
		this._toBeDeleted = -1;
		this._mouseState = null;
		this._disableMouse = false;
		this.loadRes();
	}

	// WaterPool.as:70-112
	private function onClick(param1:MouseEvent):Void {
		if (this._disableMouse == true) {
			return;
		}
		var _loc2_:CursorControl = null;
		if (this._controller.module != null && this._controller.module.app != null) {
			_loc2_ = this._controller.module.app.farmView.cursorCtrl;
		}
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:String = _loc2_.cursorArgument;
		var _loc4_:String = _loc2_.name;
		var _loc5_:Array<Dynamic> = null;
		if (_loc4_ == Consts.CURSOR_STYLE_CROPSEED) {
			_loc5_ = _loc3_.split(",");
			if (_loc5_ != null && _loc5_.length == 2 && _loc5_[0] == Consts.ITEM_TYPE_FISH) {
				this.operatePlant(Std.int(As3.parseInt(_loc5_[1])));
			}
		} else if (_loc4_ == Consts.CURSOR_STYLE_FISHNET) {
			this.operateHarvest();
		} else if (_loc4_ == Consts.CURSOR_STYLE_FISHNET_ALL) {
			this.operateHarvestAll(true);
		} else if (_loc4_ == Consts.CURSOR_STYLE_TOOL) {
			_loc5_ = _loc3_.split(",");
			if (_loc5_ != null && _loc5_.length == 2 && _loc5_[0] == Consts.ITEM_TYPE_FISHFEED) {
				this.operateFeed(Std.int(As3.parseInt(_loc5_[1])));
			}
		}
	}

	// WaterPool.as:114-133
	public function findFishByID(param1:Int):FishMover {
		if (this._fishMovers == null) {
			return null;
		}
		var _loc2_:FishMover = null;
		var _loc3_:Int = this._fishMovers.length;
		var _loc4_:Int = 0;
		while (_loc4_ < _loc3_) {
			_loc2_ = cast(this._fishMovers[_loc4_], FishMover);
			if (_loc2_ != null && _loc2_.fish._id == param1) {
				return _loc2_;
			}
			_loc4_++;
		}
		return null;
	}

	// WaterPool.as:135-182。`split(",",2)` 限长 2：Haxe split 无 limit 参，
	// 此处只读 [0]，行为等价（PORT-NOTE）
	private function onMouseOver(param1:MouseEvent):Void {
		var _loc6_:Array<Dynamic> = null;
		if (this._fishMovers == null || this._fishMovers.length == 0) {
			return;
		}
		if (Session.getInstance().m_lockFishMouse == true) {
			return;
		}
		var _loc2_:CursorControl = null;
		if (this._controller.module != null && this._controller.module.app != null) {
			_loc2_ = this._controller.module.app.farmView.cursorCtrl;
		}
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:String = _loc2_.name;
		if (_loc3_ == Consts.CURSOR_STYLE_ARROW || _loc3_ == Consts.CURSOR_STYLE_FISHNET || _loc3_ == Consts.CURSOR_STYLE_WEED
			|| _loc3_ == Consts.CURSOR_STYLE_INSET || _loc3_ == Consts.CURSOR_STYLE_FISHNET_ALL) {
			return;
		}
		if (_loc2_.name == Consts.CURSOR_STYLE_CROPSEED || _loc2_.name == Consts.CURSOR_STYLE_TOOL) {
			_loc6_ = _loc2_.cursorArgument.split(",");
			if (_loc6_ == null || _loc6_[0] == Consts.ITEM_TYPE_FISH || _loc6_[0] == Consts.ITEM_TYPE_FISHFEED) {
				return;
			}
		}
		this._mouseState = {
			"name": _loc2_.name,
			"argument": _loc2_.cursorArgument
		};
		var _loc4_:Bool = Session.getInstance().me;
		var _loc5_:Bool = this._controller.model.canSteal(_loc4_);
		if (_loc5_ == true) {
			_loc2_.setCursor(Consts.CURSOR_STYLE_FISHNET_ALL);
		} else {
			_loc2_.setCursor(Consts.CURSOR_STYLE_ARROW);
		}
	}

	// WaterPool.as:184-219。:191 先读 _pool.numChildren 再判 _pool 空——照抄
	// （_pool 空时同样先炸再判，原版如此）
	public function findNearPos():Point {
		var _loc1_:DisplayObject = null;
		var _loc2_:DisplayObject = null;
		var _loc3_:Float = 0;
		var _loc4_:Float = 1000000;
		var _loc5_:Float = 0;
		var _loc6_:UInt = _pool.numChildren;
		if (_pool == null) {
			return null;
		}
		var _loc7_:Float = mouseX - _pool.x;
		var _loc8_:Float = mouseY - _pool.y;
		var _loc9_:Int = 0;
		while (_loc9_ < _loc6_) {
			_loc1_ = _pool.getChildAt(_loc9_);
			_loc5_ = _loc1_.width * 0.5;
			if ((_loc1_.name.length == 2 || _loc1_.name.length == 3) && _loc1_.name.charAt(0) == "c") {
				_loc3_ = (_loc7_ - _loc1_.x - _loc5_) * (_loc7_ - _loc1_.x - _loc5_)
					+ (_loc8_ - _loc1_.y - _loc5_) * (_loc8_ - _loc1_.y - _loc5_);
				if (_loc3_ < _loc4_) {
					_loc4_ = _loc3_;
					_loc2_ = _loc1_;
				}
			}
			_loc9_++;
		}
		if (_loc2_ != null) {
			return new Point(_loc2_.x + _loc5_, _loc2_.y + _loc5_);
		}
		return null;
	}

	// WaterPool.as:221-245。`getDefinition("FishWave_"+n)` 在 openfl 是
	// Type.resolveClass：符号类未注册时 null → 原版 hasDefinition 缺失同路径
	public function showWaterFlower(param1:Point, param2:Int):Void {
		var _loc3_:Array<Dynamic> = [0, 1, 2, 3];
		var _loc4_:Array<Dynamic> = [[1.75, 9.25], [1, 1], [10.63, -1.63], [11.63, 8.5]];
		var _loc5_:MovieClip = null;
		var _loc6_:Class<Dynamic> = null;
		var _loc7_:Int = 0;
		while (_loc7_ < _loc3_.length) {
			if (param2 != _loc3_[_loc7_]) {
				_loc6_ = ApplicationDomain.currentDomain.getDefinition("FishWave_" + _loc3_[_loc7_]);
				if (_loc6_ != null) {
					_loc5_ = cast(Type.createInstance(_loc6_, []), MovieClip);
					_loc5_.mouseEnabled = false;
					_loc5_.x = param1.x - _loc4_[_loc3_[_loc7_]][0];
					_loc5_.y = param1.y - _loc4_[_loc3_[_loc7_]][1];
					_loc5_.gotoAndPlay(1);
					_fishContainer.addChild(_loc5_);
				}
			}
			_loc7_++;
		}
	}

	// WaterPool.as:247-267
	public function addFish(param1:PoolFish, param2:Float, param3:Float):Void {
		if (param1 == null) {
			return;
		}
		if (this._fishMovers == null) {
			this._fishMovers = new Array();
			addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);
		} else if (this._fishMovers.length >= Consts.FISH_MAX_SIZE) {
			return;
		}
		var _loc4_:FishMover = new FishMover(this, param1);
		_loc4_.spawnPos = new Point(param2, param3);
		_loc4_.think();
		this._fishMovers.push(_loc4_);
		FishAnimationMgr.getInstance().loadFishes([param1]);
	}

	// WaterPool.as:269-286
	private function openLandFloatTip(param1:String, param2:Int = 0):Void {
		if (param1 == null || param1 == "") {
			return;
		}
		var _loc3_:Point = new Point(mouseX, mouseY);
		_loc3_ = localToGlobal(_loc3_);
		var _loc4_:Bool = Session.getInstance().me;
		var _loc5_:Dynamic = {
			"text": param1,
			"me": _loc4_,
			"x": _loc3_.x,
			"y": _loc3_.y,
			"yAdjust": param2
		};
		this._controller.openFloat(Consts.FLOAT_TYPE_OPERATE, _loc5_);
	}

	// WaterPool.as:288-326
	private function operateHarvestAll(param1:Bool):Void {
		var _loc4_:Point = null;
		var _loc5_:Int = 0;
		if (this._fishMovers == null) {
			return;
		}
		var _loc2_:Int = this._fishMovers.length;
		var _loc3_:FishMover = null;
		if (param1 == true) {
			_loc4_ = new Point(mouseX, mouseY);
			_loc4_ = localToGlobal(_loc4_);
			_loc5_ = 0;
			while (_loc5_ < _loc2_) {
				_loc3_ = cast(this._fishMovers[_loc5_], FishMover);
				if (_loc3_ != null) {
					if (_loc3_.hitTest(_loc4_.x, _loc4_.y) == true) {
						param1 = false;
						break;
					}
				}
				_loc5_++;
			}
		}
		if (param1 == true) {
			return;
		}
		if (this._controller.model.harvestAll() == -1) {
			this.openLandFloatTip("做人不能贪得无厌！");
			return;
		}
	}

	// WaterPool.as:328-336
	private function resetLastFish():Void {
		if (this._selectedFish != null) {
			this._selectedFish.continueMove();
			this._selectedFish = null;
		}
		this.hideInfoTip();
	}

	// WaterPool.as:338-358
	private function askDelete(param1:PoolFish):Void {
		var pf:PoolFish = param1;
		var onConfirmDeleteOK:Void->Void = function():Void {
			_controller.model.harvest(_toBeDeleted, false);
		};
		if (pf == null) {
			return;
		}
		var data:Dynamic = {
			"title": "捞起鱼苗",
			"text": "鱼儿还没有成熟，现在捞起将损失鱼苗！确定要进行捕捞么？",
			"confirmFn": onConfirmDeleteOK
		};
		this._controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM, data);
		this._toBeDeleted = pf._id;
	}

	// WaterPool.as:360-363
	private function onPoolResLoadFailed(param1:IOErrorEvent):Void {
		trace("load water resource failed: " + param1.toString());
	}

	// WaterPool.as:365-391
	private function onHoverTimer(param1:TimerEvent):Void {
		if (this._fishMovers == null) {
			return;
		}
		var _loc2_:Point = new Point(this.mouseX, this.mouseY);
		_loc2_ = localToGlobal(_loc2_);
		var _loc3_:Int = this._fishMovers.length;
		var _loc4_:FishMover = null;
		var _loc5_:Int = 0;
		while (_loc5_ < _loc3_) {
			_loc4_ = cast(this._fishMovers[_loc5_], FishMover);
			if (_loc4_ != null) {
				if (_loc4_.hitTest(_loc2_.x, _loc2_.y) == true) {
					_loc4_.stop();
					this._selectedFish = _loc4_;
					this.showInfoTip(_loc4_.fish);
					break;
				}
			}
			_loc5_++;
		}
	}

	// WaterPool.as:393-403
	public function refreshInfoTip(param1:PoolFish):Void {
		if (param1 == null || this._tip == null) {
			return;
		}
		if (param1._output > 0) {
			this._tip.update();
		}
	}

	// WaterPool.as:405-439。`_matureFlag["fish"]` 动态属性 → ClipProps 侧表
	private function onEnterFrame(param1:Event):Void {
		if (this._fishMovers == null) {
			this.stopLoadingAnimation();
			return;
		}
		var _loc2_:Bool = true;
		var _loc3_:FishMover = null;
		var _loc4_:Int = this._fishMovers.length;
		var _loc5_:Int = 0;
		while (_loc5_ < _loc4_) {
			_loc3_ = cast(this._fishMovers[_loc5_], FishMover);
			if (_loc3_ != null) {
				_loc3_.moveFrame();
				if (this._matureFlag != null && ClipProps.get(this._matureFlag, "fish") == _loc3_) {
					this._matureFlag.x = _pool.x + _loc3_.x + (_loc3_.hFlip ? -1 : 1) * 10;
					this._matureFlag.y = _pool.y + _loc3_.y - 4;
					this._matureFlag.visible = true;
				}
				if (_loc3_.loaded == false) {
					_loc2_ = false;
				}
			}
			_loc5_++;
		}
		if (_loc2_ == true) {
			this.stopLoadingAnimation();
		}
	}

	// WaterPool.as:441-461
	public function updateMatureFlag(param1:Int):Void {
		if (this._matureFlag == null) {
			return;
		}
		var _loc2_:FishMover = this.findFishByID(param1);
		if (_loc2_ == null) {
			return;
		}
		if (ClipProps.get(this._matureFlag, "fish") == null) {
			ClipProps.set(this._matureFlag, "fish", _loc2_);
			this._matureFlag.addEventListener(MouseEvent.CLICK, this.onClickMatureFlag, false, 0, true);
		} else if (ClipProps.get(this._matureFlag, "fish") != _loc2_) {
			ClipProps.set(this._matureFlag, "fish", _loc2_);
		}
	}

	// WaterPool.as:463-502。WaterLand3/StoneFrame1 是 water_v_5 库符号，经
	// CommonData.applicationDomain（=Type.resolveClass）取，根包符号 shim 类
	// 注册（见 src/WaterLand3.hx 等）
	private function createPool():Void {
		this.stopLoadingAnimation();
		var _loc1_:Int = 0;
		var _loc2_:Class<Dynamic> = CommonData.applicationDomain.getDefinition("WaterLand3");
		this._water = cast(Type.createInstance(_loc2_, []), MovieClip);
		this._water.x = 8;
		this._water.y = 39;
		this._water.cacheAsBitmap = true;
		this._water.mouseEnabled = false;
		addChildAt(this._water, _loc1_++);
		if (_pool != null) {
			_pool.x = 229;
			_pool.y = 42;
			_pool.mouseEnabled = false;
			addChildAt(_pool, _loc1_++);
		}
		if (CommonData.applicationDomain.hasDefinition("StoneFrame1") == true) {
			_loc2_ = CommonData.applicationDomain.getDefinition("StoneFrame1");
			this._stone = Type.createInstance(_loc2_, []);
			this._stone.x = -6;
			this._stone.y = 19;
			this._stone.cacheAsBitmap = true;
			this._stone.mouseEnabled = false;
			addChildAt(this._stone, _loc1_++);
		}
		this._matureFlag = cast(Utils.getMaterial("HarvestFishFlag"), MovieClip);
		if (this._matureFlag != null) {
			this._matureFlag.visible = false;
			this._matureFlag.mouseEnabled = false;
			addChildAt(this._matureFlag, _loc1_++);
		}
		addEventListener(MouseEvent.CLICK, this.onClick, false, 0, true);
		addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove, false, 0, true);
		addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut, false, 0, true);
		addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver, false, 0, true);
	}

	// WaterPool.as:504-507
	public var disableMouse(never, set):Bool;

	private function set_disableMouse(param1:Bool):Bool {
		this._disableMouse = param1;
		return param1;
	}

	// WaterPool.as:509-548
	private function operateFeed(param1:Int):Void {
		if (this._fishMovers == null) {
			return;
		}
		var _loc2_:Bool = Session.getInstance().me;
		if (_loc2_ == false) {
			return;
		}
		var _loc3_:Point = new Point(mouseX, mouseY);
		_loc3_ = localToGlobal(_loc3_);
		var _loc4_:Int = this._fishMovers.length;
		var _loc5_:FishMover = null;
		var _loc6_:Int = 0;
		while (_loc6_ < _loc4_) {
			_loc5_ = cast(this._fishMovers[_loc6_], FishMover);
			if (_loc5_ != null) {
				if (_loc5_.hitTest(_loc3_.x, _loc3_.y) == true) {
					if (_loc5_.fish.level == Consts.FISH_MAX_LEVEL) {
						this.openLandFloatTip("可收获了，不需要再喂食");
						break;
					}
					if (_loc5_.fish._fertilize == true) {
						this.openLandFloatTip("对不起，您已经使用过鱼食了");
						break;
					}
					this._controller.model.feed(_loc5_.fish._id, param1);
					break;
				}
			}
			_loc6_++;
		}
	}

	// WaterPool.as:550-561
	private function showLoadingAnimation():Void {
		if (this._loading == null) {
			this._loading = new FarmLoading();
			this._loading.x = 220;
			this._loading.y = 148;
			this._loading.mouseEnabled = false;
			this._loading.mouseChildren = false;
			addChild(this._loading);
		}
	}

	// WaterPool.as:563-570
	public function showGuideArrow(param1:Int):Void {
		var _loc2_:DisplayObjectContainer = cast(this.fishContainer, DisplayObjectContainer);
		var _loc3_:Point = new Point(0, 100);
		_loc3_ = _loc2_.localToGlobal(_loc3_);
		GameGuide.instance().showStep(param1, Std.int(_loc3_.x), Std.int(_loc3_.y));
		GameGuide.instance().autoHide(3);
	}

	// WaterPool.as:572-579
	private function onCheckLoaded(param1:Event):Void {
		if (CommonData.applicationDomain.hasDefinition("WaterLand3") == true) {
			removeEventListener(Event.ENTER_FRAME, this.onCheckLoaded);
			this.createPool();
		}
	}

	// WaterPool.as:581-599。`splice(0)` 清表 → splice(0, length)（Haxe 需删数）
	public function reset():Void {
		var _loc1_:FishMover = null;
		if (this._fishMovers != null) {
			// for-each：AS3 声明 `_loc1_:FishMover`，经 typed 收窄——fish 是
			// getter/setter，动态读写都落空（写还触 CLAUDE.md 动态属性裸写禁令）
			var typed:Array<FishMover> = cast this._fishMovers;
			for (_loc1_ in typed) {
				if (!(_loc1_ == null || _loc1_.fish == null)) {
					_loc1_.fish = null;
				}
			}
			this._fishMovers.splice(0, this._fishMovers.length);
		}
		this._selectedFish = null;
		this.hideInfoTip();
		this.hideHarvestFlag();
		this.stopLoadingAnimation();
	}

	// WaterPool.as:601-612
	public function showInfoTip(param1:PoolFish):Void {
		if (this._tip == null) {
			this._tip = new FishInfoTip(this);
		}
		this._tip.scaleX /= scaleX;
		this._tip.scaleY /= scaleY;
		this._tip.x = this._selectedFish.x + _pool.x - 50 / scaleX;
		this._tip.y = this._selectedFish.y - 25 / scaleY;
		this._tip.show(param1);
	}

	// WaterPool.as:614-622
	private function stopLoadingAnimation():Void {
		if (this._loading != null && this.contains(this._loading) == true) {
			this._loading.stop();
			removeChild(this._loading);
			this._loading = null;
		}
	}

	// WaterPool.as:624-632
	private function hideHarvestFlag():Void {
		if (this._matureFlag != null) {
			this._matureFlag.visible = false;
			ClipProps.set(this._matureFlag, "fish", null);
			this._matureFlag.removeEventListener(MouseEvent.CLICK, this.onClickMatureFlag);
		}
	}

	// WaterPool.as:634-669
	private function operateHarvest():Void {
		if (this._fishMovers == null) {
			return;
		}
		var _loc1_:Point = new Point(mouseX, mouseY);
		_loc1_ = localToGlobal(_loc1_);
		var _loc2_:Bool = Session.getInstance().me;
		var _loc3_:Int = this._fishMovers.length;
		var _loc4_:FishMover = null;
		var _loc5_:Int = 0;
		while (_loc5_ < _loc3_) {
			_loc4_ = cast(this._fishMovers[_loc5_], FishMover);
			if (_loc4_ != null) {
				if (_loc4_.hitTest(_loc1_.x, _loc1_.y) == true) {
					if (_loc2_ == false && this.canSteal(_loc4_) == false) {
						break;
					}
					if (_loc2_ == true && _loc4_.fish.canHarvest == false) {
						this.askDelete(_loc4_.fish);
						break;
					}
					this._toBeDeleted = -1;
					this._controller.model.harvest(_loc4_.fish._id, _loc4_.fish.canHarvest);
					break;
				}
			}
			_loc5_++;
		}
	}

	// WaterPool.as:671-707
	public function refreshMatureFlag(param1:Bool):Void {
		if (this._fishMovers == null || this._matureFlag == null) {
			return;
		}
		if (param1 == false && this._matureFlag.visible == true) {
			return;
		}
		var _loc2_:FishMover = null;
		var _loc3_:Bool = false;
		var _loc4_:Int = this._fishMovers.length;
		var _loc5_:Int = 0;
		while (_loc5_ < _loc4_) {
			_loc2_ = cast(this._fishMovers[_loc5_], FishMover);
			if (!(_loc2_ == null || _loc2_.fish == null)) {
				if (this.canHarvest(_loc2_.fish) == true) {
					if (_loc3_ == false) {
						ClipProps.set(this._matureFlag, "fish", _loc2_);
						this._matureFlag.addEventListener(MouseEvent.CLICK, this.onClickMatureFlag, false, 0, true);
						_loc3_ = true;
						break;
					}
				}
			}
			_loc5_++;
		}
		if (_loc3_ == false) {
			this.hideHarvestFlag();
		}
	}

	// WaterPool.as:709-721。PORT-NOTE(load-swf)：new Loader() → LocalSwfLoader
	private function loadRes():Void {
		var _loc1_:String = Settings.getInstance().getSecondUrl("water");
		if (_loc1_ == null || _loc1_ == "") {
			return;
		}
		this.showLoadingAnimation();
		this._loader = new LocalSwfLoader();
		this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onPoolResLoaded, false, 0, true);
		this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onPoolResLoadFailed, false, 0, true);
		this._loader.load(new URLRequest(_loc1_), new LoaderContext(false, CommonData.applicationDomain));
	}

	// WaterPool.as:723-763
	private function onClickMatureFlag(param1:MouseEvent):Void {
		var _loc4_:Bool = false;
		if (this._disableMouse == true) {
			return;
		}
		param1.target.removeEventListener(MouseEvent.CLICK, this.onClickMatureFlag);
		if (this._matureFlag == null) {
			return;
		}
		var _loc2_:FishMover = cast(ClipProps.get(this._matureFlag, "fish"), FishMover);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:CursorControl = null;
		if (this._controller.module != null && this._controller.module.app != null) {
			_loc3_ = this._controller.module.app.farmView.cursorCtrl;
		}
		if (_loc3_ == null) {
			return;
		}
		if (_loc3_.name == Consts.CURSOR_STYLE_FISHNET) {
			_loc4_ = Session.getInstance().me;
			if (_loc4_ == false && this.canSteal(_loc2_) == false) {
				return;
			}
			this._toBeDeleted = -1;
			this._controller.model.harvest(_loc2_.fish._id, true);
		} else if (_loc3_.name == Consts.CURSOR_STYLE_FISHNET_ALL) {
			this.operateHarvestAll(false);
		}
	}

	// WaterPool.as:765-785。配置对象裸键读 → Reflect.field（Dynamic）
	private function operatePlant(param1:Int):Void {
		if (this._controller.model.checkSize() == false) {
			this.openLandFloatTip("容量已达上限6，不能再养了");
			this._controller.module.app.dispatchEvent(new Event(Consts.CLOSE_MY_BAG));
			return;
		}
		var _loc2_:Dynamic = Settings.getInstance().getFishByID(Std.string(param1));
		if (_loc2_ == null) {
			return;
		}
		if (this._controller.model.poolSize + As3.floatOf(Reflect.field(_loc2_, "pool_size")) > Consts.FISH_MAX_SIZE) {
			this.openLandFloatTip(Reflect.field(_loc2_, "crop_name") + "占用容量" + Reflect.field(_loc2_, "pool_size") + "，池塘剩余容量不足");
			this._controller.module.app.dispatchEvent(new Event(Consts.CLOSE_MY_BAG));
			return;
		}
		this._controller.model.grow(param1);
	}

	// WaterPool.as:787-806
	public function harvestFish(param1:Int, param2:Int, param3:Bool):Void {
		var _loc4_:FishMover = this.findFishByID(param1);
		if (_loc4_ == null) {
			return;
		}
		if (param2 > 0) {
			this.playHarvestAnimation(_loc4_, "+" + param2);
		}
		if (param3 == true) {
			this.removeFish(param1);
		} else {
			this.hideHarvestFlag();
		}
	}

	// WaterPool.as:808-856
	private function onMouseOut(param1:MouseEvent):Void {
		var _loc3_:Bool = false;
		var _loc4_:Bool = false;
		var _loc5_:Bool = false;
		if (this.checkCursor() == false) {
			return;
		}
		if (this._timer != null) {
			this._timer.stop();
		}
		this.resetLastFish();
		var _loc2_:CursorControl = null;
		if (this._controller.module != null && this._controller.module.app != null) {
			_loc2_ = this._controller.module.app.farmView.cursorCtrl;
		}
		if (this._mouseState != null) {
			_loc3_ = Session.getInstance().me;
			if (Reflect.field(this._mouseState, "name") == Consts.CURSOR_STYLE_ARROW) {
				this._controller.restoreLandCursor();
			} else if (Reflect.field(this._mouseState, "name") == Consts.CURSOR_STYLE_FISHNET) {
				if (this._controller.model.canSteal(_loc3_) == false) {
					this._controller.restoreLandCursor();
				}
			} else if (_loc2_ != null) {
				_loc2_.setCursor(Reflect.field(this._mouseState, "name"), Reflect.field(this._mouseState, "argument"));
			}
			this._mouseState = null;
		} else if (this._controller.model.canSteal(_loc3_) == false) {
			_loc4_ = _loc2_.name == Consts.CURSOR_STYLE_TOOL
				&& _loc2_.cursorArgument.indexOf(Consts.ITEM_TYPE_FISHFEED) != -1;
			_loc5_ = _loc2_.name == Consts.CURSOR_STYLE_CROPSEED && _loc2_.cursorArgument.indexOf(Consts.ITEM_TYPE_FISH) != -1;
			if (_loc4_ == false && _loc5_ == false) {
				this._controller.restoreLandCursor();
			}
		}
	}

	// WaterPool.as:858-888
	public function fillFishes(param1:Array<Dynamic>):Void {
		if (param1 == null) {
			return;
		}
		if (this._fishMovers == null) {
			this._fishMovers = new Array();
			addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);
		}
		var _loc2_:FishMover = null;
		var _loc3_:Int = 0;
		while (_loc3_ < param1.length) {
			if (this._fishMovers.length >= Consts.FISH_MAX_SIZE) {
				break;
			}
			_loc2_ = new FishMover(this, param1[_loc3_]);
			_loc2_.spawnPos = null;
			this._fishMovers.push(_loc2_);
			_loc2_.think();
			_loc3_++;
		}
		if (FishAnimationMgr.getInstance().loadFishes(param1) == true) {
			this.showLoadingAnimation();
		}
		this._selectedFish = null;
	}

	// WaterPool.as:890-897
	private function onPoolResLoaded(param1:Event):Void {
		var _loc2_:LoaderInfo = cast(param1.target, LoaderInfo);
		if (_loc2_ != null) {
			addEventListener(Event.ENTER_FRAME, this.onCheckLoaded, false, 0, true);
		}
	}

	// WaterPool.as:899-906
	public function hideInfoTip():Void {
		if (this._tip != null) {
			this._tip.hide();
			this._tip.scaleX = this._tip.scaleY = 1;
		}
	}

	// WaterPool.as:908-931
	private function canSteal(param1:FishMover):Bool {
		if (param1 == null) {
			return false;
		}
		var _loc2_:PoolFish = param1.fish;
		if (_loc2_ == null) {
			return false;
		}
		var _loc3_:Int = Std.int(As3.parseInt(Session.getInstance().hostId));
		if (_loc2_._thief.indexOf(_loc3_) != -1) {
			this.openLandFloatTip("做人不能贪得无厌！");
			return false;
		}
		if (_loc2_._left != 0 && _loc2_._left <= _loc2_.min) {
			this.openLandFloatTip("行行好吧，我所剩无几了！");
			return false;
		}
		return true;
	}

	// WaterPool.as:933-952
	private function playHarvestAnimation(param1:FishMover, param2:String):Void {
		if (param1 == null || param2 == null || param2 == "") {
			return;
		}
		var _loc3_:Point = new Point(mouseX, mouseY);
		_loc3_ = localToGlobal(_loc3_);
		_loc3_.x -= 100 * scaleX;
		_loc3_.y -= 20 * scaleY;
		var _loc4_:Int = param1.fish._type;
		var _loc5_:Dynamic = {
			"text": param2,
			"type": Consts.ITEM_TYPE_FISH,
			"cId": _loc4_,
			"x": _loc3_.x,
			"y": _loc3_.y
		};
		this._controller.openFloat(Consts.FLOAT_TYPE_HA, _loc5_);
	}

	// WaterPool.as:954-976
	public function showErrorMsg(param1:String, param2:Int):Void {
		if (param1 == null || param1.length == 0) {
			return;
		}
		var _loc3_:FishMover = this.findFishByID(param2);
		if (_loc3_ == null) {
			return;
		}
		var _loc4_:Point = new Point(20, -12);
		_loc4_ = _loc3_.localToGlobal(_loc4_);
		var _loc5_:Bool = Session.getInstance().me;
		var _loc6_:Dynamic = {
			"text": param1,
			"me": _loc5_,
			"x": _loc4_.x,
			"y": _loc4_.y,
			"yAdjust": 0
		};
		this._controller.openFloat(Consts.FLOAT_TYPE_OPERATE, _loc6_);
	}

	// WaterPool.as:978-1004
	private function onMouseMove(param1:MouseEvent):Void {
		if (this._disableMouse == true) {
			return;
		}
		if (this.checkCursor() == false) {
			return;
		}
		if (this._selectedFish != null && this._selectedFish.hitTest(param1.stageX, param1.stageY) == true) {
			return;
		}
		this.resetLastFish();
		if (this._timer == null) {
			this._timer = new Timer(50, 1);
			this._timer.addEventListener(TimerEvent.TIMER, this.onHoverTimer, false, 0, true);
			this._timer.start();
		} else {
			this._timer.stop();
			this._timer.start();
		}
	}

	// WaterPool.as:1006-1032
	private function canHarvest(param1:PoolFish):Bool {
		var _loc3_:Int = 0;
		if (param1 == null) {
			return false;
		}
		var _loc2_:Bool = Session.getInstance().me;
		if (_loc2_ == true) {
			return param1.canHarvest == true;
		}
		if (param1.canHarvest == false) {
			return false;
		}
		_loc3_ = Std.int(As3.parseInt(Session.getInstance().hostId));
		if (param1._thief.indexOf(_loc3_) != -1) {
			return false;
		}
		if (param1._left <= param1.min) {
			return false;
		}
		return true;
	}

	// WaterPool.as:1034-1063
	public function removeFish(param1:Int):Void {
		if (this._fishMovers == null) {
			return;
		}
		var _loc2_:FishMover = null;
		var _loc3_:Int = this._fishMovers.length;
		var _loc4_:Int = 0;
		while (_loc4_ < _loc3_) {
			_loc2_ = cast(this._fishMovers[_loc4_], FishMover);
			if (_loc2_ != null && _loc2_.fish._id == param1) {
				_loc2_.fish = null;
				if (this._selectedFish == _loc2_) {
					this.hideInfoTip();
					this._selectedFish = null;
				}
				if (this._matureFlag != null && ClipProps.get(this._matureFlag, "fish") == _loc2_) {
					this.hideHarvestFlag();
				}
				this._fishMovers.splice(_loc4_, 1);
				break;
			}
			_loc4_++;
		}
	}

	// WaterPool.as:1065-1094
	private function checkCursor():Bool {
		var _loc2_:Array<Dynamic> = null;
		var _loc1_:CursorControl = null;
		if (this._controller.module != null && this._controller.module.app != null) {
			_loc1_ = this._controller.module.app.farmView.cursorCtrl;
		}
		if (_loc1_ == null) {
			return false;
		}
		if (_loc1_.name == Consts.CURSOR_STYLE_ARROW || _loc1_.name == Consts.CURSOR_STYLE_FISHNET
			|| _loc1_.name == Consts.CURSOR_STYLE_FISHNET_ALL) {
			return true;
		}
		if (_loc1_.name == Consts.CURSOR_STYLE_TOOL) {
			_loc2_ = _loc1_.cursorArgument.split(",");
			if (_loc2_ == null || _loc2_.length != 2) {
				return false;
			}
			if (_loc2_[0] == Consts.ITEM_TYPE_FISHFEED) {
				return true;
			}
		}
		return false;
	}
}
