package com.minutes.ui.core;

import comm.S9bmp;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
 * com.minutes.ui.core.LipiSkin —— LipiSkin.as 逐句对应（issue #86 牧场库
 * 底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/core/LipiSkin.as。
 *
 * PORT-NOTE（AS3 `as` 转换）：eval 裸 cast 不做运行时检查（lessons #7），
 * `x as MovieClip` 的失配-null 语义走 Std.isOfType 门 + 直取。本类所有
 * `as MovieClip` 上游都有 `is MovieClip`/`totalFrames` 守卫语境，逐处按
 * 原文位置保留门判。
 * PORT-NOTE（`new param1()`，LipiSkin.as:146）：AS3 的 Class 实例化——
 * Type.createInstance 等价（CLAUDE.md 语言差异清单）。
 * PORT-NOTE（`if(this._rect)` :140）：AS3 对象真值——非 null 即真，
 * As3.truthy 等价。
 */
@:keep
class LipiSkin extends Sprite {
	// LipiSkin.as:14-20
	private var _enableMouse:Bool = true;
	private var _rect:Rectangle;
	private var _backgroundImage:Class<Dynamic>;
	private var _bgImage:DisplayObject;

	// :22-31
	public function new(param1:Class<Dynamic>, param2:Rectangle = null) {
		super();
		this._rect = param2;
		if (param1 != null) {
			this.backgroundImage = param1;
		}
		addEventListener(Event.REMOVED_FROM_STAGE, this.removeFormStage);
	}

	// :33-36
	public var backgroundDisplayObject(get, set):DisplayObject;

	private function get_backgroundDisplayObject():DisplayObject {
		return this._bgImage;
	}

	// :38-41
	public var enableMouse(get, set):Bool;

	private function get_enableMouse():Bool {
		return this._enableMouse;
	}

	// :43-46
	private function set_enableMouse(param1:Bool):Bool {
		this._enableMouse = param1;
		return param1;
	}

	// :48-55（`is`/`as` 成对：isOfType 门内直取）
	private function removeFormStage(param1:Event):Void {
		if (Std.isOfType(this._bgImage, MovieClip)) {
			cast(this._bgImage, MovieClip).gotoAndStop(1);
		}
		stage.removeEventListener(MouseEvent.MOUSE_UP, this.stageUpHandler);
	}

	// :57-68（currentTarget 是 IEventDispatcher——运行时实为本类挂监听
	// 的 _bgImage（MovieClip）；`as MovieClip` 的失配-null 在随后
	// .totalFrames 上会抛，isOfType 门后直取与原行为等价）
	private function downHandler(param1:MouseEvent):Void {
		if (!this.enableMouse) {
			return;
		}
		var _loc2_:MovieClip = Std.isOfType(param1.currentTarget, MovieClip) ? cast(param1.currentTarget, MovieClip) : null;
		if (_loc2_ != null && _loc2_.totalFrames >= 3) {
			_loc2_.gotoAndStop(3);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.stageUpHandler);
		}
	}

	// :70-84
	private function outHandler(param1:MouseEvent):Void {
		if (!this.enableMouse) {
			return;
		}
		if (param1.buttonDown == true) {
			return;
		}
		var _loc2_:MovieClip = Std.isOfType(param1.currentTarget, MovieClip) ? cast(param1.currentTarget, MovieClip) : null;
		if (_loc2_ != null && _loc2_.totalFrames >= 3) {
			_loc2_.gotoAndStop(1);
		}
	}

	// :86-93（override 访问器——不写 super，原版语义是把尺寸写透给
	// _bgImage、自身 Sprite 测量不变）
	private override function set_width(param1:Float):Float {
		if (this._bgImage == null) {
			return param1;
		}
		this._bgImage.width = param1;
		return param1;
	}

	// :95-102
	private override function set_height(param1:Float):Float {
		if (this._bgImage == null) {
			return param1;
		}
		this._bgImage.height = param1;
		return param1;
	}

	// :104-125
	private function stageUpHandler(param1:MouseEvent):Void {
		if (!this.enableMouse) {
			return;
		}
		if (Std.isOfType(this._bgImage, MovieClip)) {
			var _loc2_:MovieClip = cast(this._bgImage, MovieClip);
			if (_loc2_.totalFrames >= 3) {
				if (param1.target == this._bgImage) {
					_loc2_.gotoAndStop(2);
				} else {
					_loc2_.gotoAndStop(1);
				}
			}
		}
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.stageUpHandler);
	}

	// :127-130
	public var backgroundImage(get, set):Class<Dynamic>;

	private function get_backgroundImage():Class<Dynamic> {
		return this._backgroundImage;
	}

	// :132-135
	public var bgImage(get, never):DisplayObject;

	private function get_bgImage():DisplayObject {
		return this._bgImage;
	}

	// :137-158（`if(this._rect)` 真值判与 Class 实例化见类头 PORT-NOTE；
	// `new param1() as DisplayObject`——实例总是显示对象符号类，isOfType
	// 门 + 直取，失配 null 在随后 .x 上抛与原行为等价）
	private function set_backgroundImage(param1:Class<Dynamic>):Class<Dynamic> {
		this._backgroundImage = param1;
		if (shim.As3.truthy(this._rect)) {
			this._bgImage = new S9bmp(param1, this._rect);
		} else {
			var _loc2_:Dynamic = Type.createInstance(param1, []);
			this._bgImage = Std.isOfType(_loc2_, DisplayObject) ? cast(_loc2_, DisplayObject) : null;
		}
		this._bgImage.x = 0;
		this._bgImage.y = 0;
		addChild(this._bgImage);
		if (Std.isOfType(this._bgImage, MovieClip)) {
			var _loc3_:MovieClip = cast(this._bgImage, MovieClip);
			_loc3_.gotoAndStop(1);
			_loc3_.addEventListener(MouseEvent.MOUSE_OVER, this.overHandler);
			_loc3_.addEventListener(MouseEvent.MOUSE_DOWN, this.downHandler);
			_loc3_.addEventListener(MouseEvent.MOUSE_OUT, this.outHandler);
		}
		return param1;
	}

	// :160-173
	private function overHandler(param1:MouseEvent):Void {
		if (!this.enableMouse) {
			return;
		}
		if (param1.buttonDown == false) {
			var _loc2_:MovieClip = Std.isOfType(param1.currentTarget, MovieClip) ? cast(param1.currentTarget, MovieClip) : null;
			if (_loc2_ != null && _loc2_.totalFrames >= 3) {
				_loc2_.gotoAndStop(2);
			}
		}
	}

	// :175-178
	private function set_backgroundDisplayObject(param1:DisplayObject):DisplayObject {
		this._bgImage = param1;
		return param1;
	}
}
