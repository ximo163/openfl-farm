package module.lite;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.DataEvent;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.GlowFilter;
import openfl.geom.Point;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.ui.Mouse;
import openfl.utils.Dictionary;
import shim.As3;
import shim.LocalSwfLoader;

// FarmLiteView.as 逐句对应。
// PORT-NOTE(load-swf)：`new Loader()` → shim.LocalSwfLoader（背景 diy swf
// 本地化，见该类头注释；load 调用形态不变）。
class FarmLiteView extends Sprite {
	// FarmLiteView.as:26
	public static var SCALE:Float = 0.75;

	// FarmLiteView.as:28
	public static var LAND_SUM:Int = 24;

	// FarmLiteView.as:30
	public static final ITEM_WIDTH:Float = 204 * SCALE;

	// FarmLiteView.as:32
	public static final ITEM_HEIGHT:Float = 102 * SCALE;

	// FarmLiteView.as:34
	private var _arrowCursor:CursorArrow_Lite;

	// FarmLiteView.as:36
	private var _items:Array<Dynamic>;

	// FarmLiteView.as:38（声明未使用，照抄）
	private static final ITEM_TIP_OFFSET:Float = 20 * SCALE;

	// FarmLiteView.as:40
	private var _overFilters:Array<Dynamic>;

	// FarmLiteView.as:42
	private var _bgLoader:Loader;

	// FarmLiteView.as:44
	private var _poolLoading:FarmLoading_Lite;

	// FarmLiteView.as:46。键是收获数字 TextField（onHarvestAnimation 里按
	// DisplayObject 键取，K 取基类）
	private var _harvestAnimationStep:Dictionary<DisplayObject, Int>;

	// FarmLiteView.as:48
	private var _pickIcon:canPickIcon_Lite;

	// FarmLiteView.as:50
	private var _model:FarmLiteModel;

	// FarmLiteView.as:52
	private var _currentItem:Int;

	// FarmLiteView.as:54
	private var _currentCursor:DisplayObject;

	// FarmLiteView.as:56
	private var _pickIndex:Int;

	// FarmLiteView.as:58
	private var _pickCursor:CursorHand_Lite;

	// FarmLiteView.as:60-80
	public function new(param1:FarmLiteModel) {
		super();
		this._model = param1;
		this._currentItem = -1;
		this._overFilters = [new ColorMatrixFilter([1.6, 0, 0, 0, -21.59, 0, 1.6, 0, 0, -21.59, 0, 0, 1.6, 0, -21.59, 0, 0, 0, 1, 0])];
		this._items = null;
		this._pickIcon = new canPickIcon_Lite();
		this._pickIcon.scaleX = this._pickIcon.scaleY = 1 / SCALE;
		this._pickIcon.mouseChildren = false;
		this._pickIcon.mouseEnabled = false;
		this._pickIndex = -1;
		addEventListener(Event.ADDED_TO_STAGE, this.onInit, false, 0, true);
		addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove, false, 0, true);
		addEventListener(MouseEvent.ROLL_OVER, this.onMouseOver, false, 0, true);
		addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut, false, 0, true);
		addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown, false, 0, true);
		addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp, false, 0, true);
		addEventListener(MouseEvent.CLICK, this.onClick, false, 0, true);
		this._model.addEventListener(FarmLiteModel.EVENT_HARVEST, this.onHarvest, false, 0, true);
	}

	// FarmLiteView.as:82-139
	private function onHarvest(param1:DataEvent):Void {
		var _loc5_:DisplayObjectContainer = null;
		var _loc6_:Float = Math.NaN;
		var _loc7_:DisplayObject = null;
		var _loc8_:TextField = null;
		var _loc2_:String = param1.data;
		var _loc3_:Array<String> = _loc2_.split(",");
		if (_loc3_ == null || _loc3_.length == 0) {
			return;
		}
		var _loc4_:Float = As3.floatOf(_loc3_[0]);
		if (Math.isNaN(_loc4_) == true) {
			return;
		}
		if (_loc4_ >= 0 && _loc4_ < this._items.length) {
			_loc5_ = Std.isOfType(this._items[Std.int(_loc4_)], DisplayObjectContainer)
				? cast(this._items[Std.int(_loc4_)], DisplayObjectContainer)
				: null;
			if (_loc5_ != null) {
				_loc7_ = _loc5_.getChildByName("_seed_");
				if (_loc7_ != null) {
					_loc5_.removeChild(_loc7_);
				}
				_loc7_ = null;
			}
			_loc6_ = As3.floatOf(_loc3_[1]);
			if (Math.isNaN(_loc6_) == false) {
				_loc8_ = new TextField();
				_loc8_.defaultTextFormat = new TextFormat("Verdana", 18, 16737792, true);
				_loc8_.filters = [new GlowFilter(16777215, 1, 3, 3, 7)];
				_loc8_.autoSize = TextFieldAutoSize.LEFT;
				_loc8_.text = "+" + Std.string(_loc6_);
				_loc8_.addEventListener(Event.ENTER_FRAME, this.onHarvestAnimation, false, 0, true);
				_loc5_.addChild(_loc8_);
				_loc8_.x = (_loc5_.width - _loc8_.textWidth) / 2;
				_loc8_.y = -_loc8_.textHeight;
				if (this._harvestAnimationStep == null) {
					this._harvestAnimationStep = new Dictionary<DisplayObject, Int>();
				}
				this._harvestAnimationStep.set(_loc8_, 0);
			}
		}
		if (this._pickIndex == _loc4_) {
			this._pickIndex = -1;
			if (this._pickIcon.parent != null) {
				this._pickIcon.parent.removeChild(this._pickIcon);
			}
			this.showPickIcon();
		}
	}

	// FarmLiteView.as:141-158
	private function pick(param1:Int):Void {
		var _loc2_:Dynamic = this._model.getLandByIndex(param1);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = 0;
		if (Reflect.field(_loc2_, "a") != 0) {
			_loc3_ = this._model.idState(As3.intOf(Reflect.field(_loc2_, "a")), As3.floatOf(Reflect.field(_loc2_, "q")),
				As3.intOf(Reflect.field(_loc2_, "b")), As3.intOf(Reflect.field(_loc2_, "bitmap")),
				As3.intOf(Reflect.field(_loc2_, "a")));
			if (_loc3_ != 5) {
				return;
			}
			this._model.harvest(param1);
		}
	}

	// FarmLiteView.as:160-238
	private function onInit(param1:Event):Void {
		this._bgLoader = new LocalSwfLoader();
		this._bgLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.onLoadError, false, 0, true);
		this._bgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadError, false, 0, true);
		this._bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoadComplete, false, 0, true);
		this._bgLoader.load(new URLRequest(this._model.background));
		this._bgLoader.mouseChildren = false;
		this._bgLoader.mouseEnabled = false;
		addChildAt(this._bgLoader, 0);
		// 原版 y 也用 stageWidth（按 stageHeight 才对得上 768）——照抄
		this._bgLoader.x = (1024 - stage.stageWidth) / 2;
		this._bgLoader.y = (768 - stage.stageWidth) / 2;
		this._items = new Array();
		var _loc2_:Dynamic = null;
		var _loc3_:Sprite = null;
		var _loc4_:Point = null;
		var _loc5_:FarmLoading_Lite = null;
		var _loc6_:Int = 0;
		while (_loc6_ < LAND_SUM) {
			_loc2_ = this._model.getLandByIndex(_loc6_);
			if (_loc2_ == null) {
				_loc3_ = new Wasteland_Lite();
				_loc4_ = this.calcXY(_loc6_);
				_loc3_.x = _loc4_.x;
				_loc3_.y = _loc4_.y;
				_loc3_.scaleX = _loc3_.scaleY = SCALE;
				_loc3_.mouseEnabled = false;
				this._items.push(_loc3_);
				addChild(_loc3_);
			} else {
				if (Reflect.field(_loc2_, "bitmap") > 2) {
					Reflect.setField(_loc2_, "bitmap", 2);
				}
				if (Reflect.field(_loc2_, "bitmap") == 0) {
					_loc3_ = new Farmland_Lite();
				} else if (Reflect.field(_loc2_, "bitmap") == 1) {
					_loc3_ = new FarmlandRed_Lite();
				} else if (Reflect.field(_loc2_, "bitmap") == 2) {
					_loc3_ = new FarmlandBlack_Lite();
				}
				_loc4_ = this.calcXY(_loc6_);
				_loc3_.x = _loc4_.x;
				_loc3_.y = _loc4_.y;
				_loc3_.scaleX = _loc3_.scaleY = SCALE;
				_loc3_.mouseChildren = false;
				_loc3_.name = "_land_" + _loc6_;
				this._items.push(_loc3_);
				addChild(_loc3_);
				if (Reflect.field(_loc2_, "a") != 0) {
					_loc5_ = new FarmLoading_Lite();
					_loc5_.mouseChildren = false;
					_loc5_.mouseEnabled = false;
					_loc5_.x = _loc3_.width * 0.5 + 20;
					_loc5_.y = (_loc3_.height - _loc5_.height) * 0.5;
					_loc5_.name = "_seed_";
					_loc3_.addChild(_loc5_);
				}
			}
			_loc6_++;
		}
		this.showPickIcon();
		this._poolLoading = new FarmLoading_Lite();
		_loc4_ = this.calcXY(16);
		this._poolLoading.x = _loc4_.x + 150;
		this._poolLoading.y = _loc4_.y + 125;
		this._poolLoading.mouseEnabled = false;
		addChild(this._poolLoading);
	}

	// FarmLiteView.as:240-274
	private function onMouseOver(param1:MouseEvent):Void {
		if (this._currentCursor == null) {
			Mouse.hide();
			if (this._pickIndex == -1) {
				if (this._arrowCursor == null) {
					this._arrowCursor = new CursorArrow_Lite();
					this._arrowCursor.mouseEnabled = false;
					this._arrowCursor.mouseChildren = false;
				}
				this._currentCursor = this._arrowCursor;
			} else {
				if (this._pickCursor == null) {
					this._pickCursor = new CursorHand_Lite();
					this._pickCursor.mouseEnabled = false;
					this._pickCursor.mouseChildren = false;
				}
				this._currentCursor = this._pickCursor;
			}
			this._currentCursor.x = mouseX;
			this._currentCursor.y = mouseY;
			addChild(this._currentCursor);
		}
		var _loc2_:DisplayObject = Std.isOfType(param1.target, DisplayObject) ? cast(param1.target, DisplayObject) : null;
		if (_loc2_.name.indexOf("_land_") != -1) {
			_loc2_.filters = this._overFilters;
		}
	}

	// FarmLiteView.as:276-282
	private function onMouseUp(param1:MouseEvent):Void {
		if (this._currentCursor != null) {
			Reflect.callMethod(this._currentCursor, Reflect.field(this._currentCursor, "gotoAndStop"), [1]);
		}
	}

	// FarmLiteView.as:284-305
	private function calcXY(param1:Int):Point {
		var _loc2_:Float = 225;
		var _loc3_:Float = 92;
		var _loc4_:Point = new Point();
		var _loc5_:Int = Std.int(param1 / 3);
		var _loc6_:Int = param1 % 3;
		if (param1 < 18) {
			_loc4_.x = _loc2_ + _loc5_ * ITEM_WIDTH / 2 - _loc6_ * ITEM_WIDTH / 2;
			_loc4_.y = _loc3_ + _loc5_ * ITEM_HEIGHT / 2 + _loc6_ * ITEM_HEIGHT / 2;
		} else {
			_loc2_ = -3;
			_loc3_ += ITEM_HEIGHT * 1.5;
			_loc5_ = param1 - 18;
			_loc4_.x = _loc2_ + _loc5_ * ITEM_WIDTH / 2;
			_loc4_.y = _loc3_ + _loc5_ * ITEM_HEIGHT / 2;
		}
		return _loc4_;
	}

	// FarmLiteView.as:307-342
	private function showPickIcon():Void {
		if (this._pickIndex != -1) {
			return;
		}
		var _loc1_:Dynamic = null;
		var _loc2_:Sprite = null;
		var _loc3_:Int = 0;
		var _loc4_:Array<Dynamic> = [0, 3, 6, 9, 12, 15, 1, 4, 7, 10, 13, 16, 2, 5, 8, 11, 14, 17, 18, 19, 20, 21, 22, 23];
		var _loc5_:Int = 0;
		while (_loc5_ < _loc4_.length) {
			_loc1_ = this._model.getLandByIndex(_loc4_[_loc5_]);
			if (_loc1_ != null) {
				_loc2_ = Std.isOfType(getChildByName("_land_" + _loc4_[_loc5_]), Sprite)
					? cast(getChildByName("_land_" + _loc4_[_loc5_]), Sprite)
					: null;
				if (_loc2_ != null) {
					if (Reflect.field(_loc1_, "a") != 0 && Reflect.field(_loc1_, "k") > 0 && Reflect.field(_loc1_, "m") > 0) {
						_loc3_ = this._model.idState(As3.intOf(Reflect.field(_loc1_, "a")), As3.floatOf(Reflect.field(_loc1_, "q")),
							As3.intOf(Reflect.field(_loc1_, "b")), As3.intOf(Reflect.field(_loc1_, "bitmap")),
							As3.intOf(Reflect.field(_loc1_, "a")));
						if (_loc3_ >= 5) {
							this._pickIcon.x = _loc2_.width * 0.5;
							this._pickIcon.y = -40;
							_loc2_.addChild(this._pickIcon);
							this._pickIndex = _loc4_[_loc5_];
							break;
						}
					}
				}
			}
			_loc5_++;
		}
	}

	// FarmLiteView.as:344-366
	private function onHarvestAnimation(param1:Event):Void {
		var _loc2_:DisplayObject = Std.isOfType(param1.target, DisplayObject) ? cast(param1.target, DisplayObject) : null;
		if (_loc2_ == null) {
			return;
		}
		if (this._harvestAnimationStep == null || !this._harvestAnimationStep.exists(_loc2_)) {
			return;
		}
		var _loc3_:Int = this._harvestAnimationStep.get(_loc2_);
		_loc2_.y -= Math.abs(Math.cos(_loc3_ * 5) * 20);
		if (++_loc3_ > 10) {
			_loc2_.removeEventListener(Event.ENTER_FRAME, this.onHarvestAnimation);
			_loc2_.parent.removeChild(_loc2_);
			this._harvestAnimationStep.remove(_loc2_);
			_loc2_ = null;
			return;
		}
		this._harvestAnimationStep.set(_loc2_, this._harvestAnimationStep.get(_loc2_) + 1);
	}

	// FarmLiteView.as:368-370
	private function onLoadError(param1:Event):Void {}

	// FarmLiteView.as:372-381
	private function onClick(param1:MouseEvent):Void {
		var _loc2_:DisplayObject = Std.isOfType(param1.target, DisplayObject) ? cast(param1.target, DisplayObject) : null;
		if (_loc2_ == null || _loc2_.name.indexOf("_land_") == -1) {
			return;
		}
		var _loc3_:Int = As3.intOf(_loc2_.name.substring(6));
		this.pick(_loc3_);
	}

	// FarmLiteView.as:383-396
	private function onMouseOut(param1:MouseEvent):Void {
		Mouse.show();
		if (this._currentCursor != null && this._currentCursor.parent != null) {
			removeChild(this._currentCursor);
			this._currentCursor = null;
		}
		var _loc2_:DisplayObject = Std.isOfType(param1.target, DisplayObject) ? cast(param1.target, DisplayObject) : null;
		if (_loc2_.name.indexOf("_land_") != -1) {
			_loc2_.filters = null;
		}
	}

	// FarmLiteView.as:398-407
	private function onMouseDown(param1:MouseEvent):Void {
		if (this._currentCursor != null) {
			if (Reflect.field(this._currentCursor, "totalFrames") > 1) {
				Reflect.callMethod(this._currentCursor, Reflect.field(this._currentCursor, "gotoAndStop"), [2]);
			}
		}
	}

	// FarmLiteView.as:409-416
	private function onMouseMove(param1:MouseEvent):Void {
		if (this._currentCursor != null) {
			this._currentCursor.x = mouseX;
			this._currentCursor.y = mouseY;
		}
	}

	// FarmLiteView.as:418-455
	public function destroy():Void {
		var _loc2_:DisplayObjectContainer = null;
		var _loc1_:MovieClip = null;
		for (_loc2_ in this._items) {
			if (Std.isOfType(_loc2_, MovieClip)) {
				Reflect.callMethod(_loc2_, Reflect.field(_loc2_, "stop"), []);
			}
			_loc1_ = Std.isOfType(_loc2_.getChildByName("_seed_"), MovieClip)
				? cast(_loc2_.getChildByName("_seed_"), MovieClip)
				: null;
			if (_loc1_ != null) {
				_loc1_.stop();
			}
			removeChild(_loc2_);
		}
		if (this._pickIcon != null) {
			this._pickIcon.stop();
			if (this._pickIcon.parent != null) {
				this._pickIcon.parent.removeChild(this._pickIcon);
			}
			this._pickIcon = null;
		}
		if (this._currentCursor != null && this._currentCursor.parent != null) {
			this._currentCursor.parent.removeChild(this._currentCursor);
		}
		if (this._poolLoading != null && this._poolLoading.parent != null) {
			this._poolLoading.parent.removeChild(this._poolLoading);
		}
		this._poolLoading = null;
		this._currentCursor = null;
		this._items = null;
	}

	// FarmLiteView.as:457-461
	private function onLoadComplete(param1:Event):Void {
		this._bgLoader.x = -50;
		this._bgLoader.y = -190;
	}
}
