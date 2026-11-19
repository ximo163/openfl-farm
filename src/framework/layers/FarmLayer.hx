package framework.layers;

import common.Consts;
import common.view.cursor.CursorControl;
import interfaces.IMsgCenter;
import module.FarmApplication;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import framework.base.BaseLayer;

// framework.layers.FarmLayer —— FarmLayer.as 逐句对应（场景滚动层：scrollRect
// 视口 + 鼠标拖拽平移 + 滚动边界钳制，数值逐字照抄）。
class FarmLayer extends BaseLayer {
	// FarmLayer.as:15
	private var _height:Float;

	// FarmLayer.as:17
	private var _width:Float;

	// FarmLayer.as:19
	private var _downTop:Float;

	// FarmLayer.as:21
	private var _top:Float;

	// FarmLayer.as:23
	private var _maxWidth:Float;

	// FarmLayer.as:25
	private var _left:Float;

	// FarmLayer.as:27
	private var _downLeft:Float;

	// FarmLayer.as:29
	private var _realitySize:Array<Dynamic>;

	// FarmLayer.as:31
	private var _maxHeight:Float;

	// FarmLayer.as:33
	private var _downX:Float;

	// FarmLayer.as:35
	private var _downY:Float;

	// FarmLayer.as:37-47
	public function new(param1:IMsgCenter) {
		super(param1);
		this.name = Consts.LAYER_SCENE_CONTENT;
		this._left = this._top = 0;
		this._width = this._height = 100;
		this._maxWidth = this._maxHeight = 10000;
		this._downLeft = this._downTop = 0;
		this._downX = this._downY = 0;
		this._realitySize = null;
	}

	// FarmLayer.as:49-54
	private function onMouseUp(param1:MouseEvent):Void {
		removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		this._realitySize = null;
	}

	// FarmLayer.as:56-59
	public var maxWidth(get, set):Float;

	private function set_maxWidth(param1:Float):Float {
		this._maxWidth = param1;
		return param1;
	}

	// FarmLayer.as:61-70
	private function onMouseDown(param1:MouseEvent):Void {
		addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp, false, 0, true);
		this._downX = param1.stageX;
		this._downY = param1.stageY;
		this._downLeft = this.left;
		this._downTop = this.top;
		this._realitySize = this.getRealitySize();
	}

	// FarmLayer.as:72-75
	private function get_maxWidth():Float {
		return this._maxWidth;
	}

	// FarmLayer.as:77-80（盖掉 DisplayObject 的量宽，滚动视口用存储值）
	override private function get_width():Float {
		return this._width;
	}

	// FarmLayer.as:82-88
	override private function init():Void {
		this.reRoll();
		addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
		addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
	}

	// FarmLayer.as:90-93
	public var top(get, set):Float;

	private function get_top():Float {
		return this._top;
	}

	// FarmLayer.as:95-98
	override private function set_width(param1:Float):Float {
		this._width = param1;
		return param1;
	}

	// FarmLayer.as:100-103
	public var left(get, set):Float;

	private function set_left(param1:Float):Float {
		this._left = param1;
		return param1;
	}

	// FarmLayer.as:105-108
	public function reRoll():Void {
		this.scrollRect = new Rectangle(this.left, this.top, this.width, this.height);
	}

	// FarmLayer.as:110-113
	override private function set_height(param1:Float):Float {
		this._height = param1;
		return param1;
	}

	// FarmLayer.as:115-118
	public var maxHeight(get, set):Float;

	private function set_maxHeight(param1:Float):Float {
		this._maxHeight = param1;
		return param1;
	}

	// FarmLayer.as:120-123（盖掉 DisplayObject 的量高）
	override private function get_height():Float {
		return this._height;
	}

	// FarmLayer.as:125-128
	private function get_left():Float {
		return this._left;
	}

	// FarmLayer.as:130-133
	private function set_top(param1:Float):Float {
		this._top = param1;
		return param1;
	}

	// FarmLayer.as:135-138
	private function get_maxHeight():Float {
		return this._maxHeight;
	}

	// FarmLayer.as:140-147
	private function onRollOut(param1:MouseEvent):Void {
		var _loc2_:FarmApplication = cast super.m_msgCenter;
		if (_loc2_ != null) {
			_loc2_.useSystemCursor(true);
		}
	}

	// FarmLayer.as:149-171
	private function getRealitySize():Array<Dynamic> {
		var _loc4_:Float = Math.NaN;
		var _loc5_:Float = Math.NaN;
		var _loc1_:Float = 0;
		var _loc2_:Float = 0;
		var _loc3_:Int = 0;
		while (_loc3_ < numChildren) {
			_loc4_ = getChildAt(_loc3_).width + getChildAt(_loc3_).x;
			if (_loc4_ > _loc1_) {
				_loc1_ = _loc4_;
			}
			_loc5_ = getChildAt(_loc3_).height + getChildAt(_loc3_).y;
			if (_loc5_ > _loc2_) {
				_loc2_ = _loc5_;
			}
			_loc3_++;
		}
		return [_loc1_, _loc2_];
	}

	// FarmLayer.as:173-205
	private function onMouseMove(param1:MouseEvent):Void {
		var _loc2_:Float = Math.NaN;
		var _loc3_:Float = Math.NaN;
		var _loc4_:Float = Math.NaN;
		var _loc5_:Float = Math.NaN;
		if (param1.buttonDown == true) {
			_loc2_ = param1.stageX - this._downX;
			_loc3_ = param1.stageY - this._downY;
			if (this._realitySize == null) {
				this._realitySize = this.getRealitySize();
			}
			_loc4_ = this._realitySize[0] > this._maxWidth ? this._maxWidth : this._realitySize[0];
			_loc5_ = this._realitySize[1] > this._maxHeight ? this._maxHeight : this._realitySize[1];
			if (this._downLeft - _loc2_ >= 0 && this._downLeft - _loc2_ + this.width <= _loc4_) {
				this.left = this._downLeft - _loc2_;
			}
			if (this._downTop - _loc3_ >= 0 && this._downTop - _loc3_ + this.height <= _loc5_) {
				this.top = this._downTop - _loc3_;
			}
			this.reRoll();
		} else {
			removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			this._realitySize = null;
		}
	}

	// FarmLayer.as:207-226
	private function onRollOver(param1:MouseEvent):Void {
		var _loc2_:FarmApplication = cast super.m_msgCenter;
		if (_loc2_ != null) {
			_loc2_.useSystemCursor(false);
		}
		var _loc3_:CursorControl = _loc2_.farmView.cursorCtrl;
		if (this.name == Consts.LAYER_SCENE_CONTENT) {
			if (_loc3_.name == Consts.CURSOR_WILD_HAND) {
				_loc3_.setCursor(Consts.CURSOR_STYLE_ARROW);
			} else if (_loc3_.name == null || _loc3_.name == "") {
				_loc2_.dispatchEvent(new Event(Consts.MSG_SET_LAND_CURSOR));
			}
		}
	}
}
