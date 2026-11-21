package framework.base;

import common.misc.Utils;
import common.view.MaterialProxy;
import events.ViewEvent;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

/**
 * framework.base.BaseTileItem —— BaseTileItem.as 逐句对应（issue #18 qui
 * 收尾：框架片）。瓦片子项基类：MaterialProxy 物料图（可选 BIG 规格）、
 * 可选背景/遮罩素材，点击/悬停转 CHILD_CLICK/CHILD_OVER/CHILD_OUT 冒泡
 * ViewEvent（data = _item）。
 */
@:keep
class BaseTileItem extends Sprite {
	// BaseTileItem.as:12-16
	public static final CHILD_CLICK:String = "childClick";

	public static final CHILD_OUT:String = "childOut";

	public static final CHILD_OVER:String = "childOver";

	// :18-24
	private var _material:MaterialProxy;

	private var _bg:Sprite;

	private var _item:Dynamic;

	private var _mask:Sprite;

	// :26-45
	public function new(param1:Bool = false) {
		super();
		buttonMode = true;
		useHandCursor = true;
		mouseChildren = false;
		if (param1 == true) {
			this._material = new MaterialProxy(MaterialProxy.BIG);
		} else {
			this._material = new MaterialProxy();
		}
		this._material.showLoading();
		addChild(this._material);
		this._bg = null;
		this._mask = null;
		this._item = null;
	}

	// :47-52
	private function onOver(param1:MouseEvent):Void {
		var _loc2_:ViewEvent = new ViewEvent(CHILD_OVER, true);
		_loc2_.data = this._item;
		dispatchEvent(_loc2_);
	}

	// :54-59
	private function onClick(param1:MouseEvent):Void {
		var _loc2_:ViewEvent = new ViewEvent(CHILD_CLICK, true);
		_loc2_.data = this._item;
		dispatchEvent(_loc2_);
	}

	// :61-86（`Utils.getMaterial(param1) as Sprite`）
	private function createBackground(param1:String, param2:Int = 0, param3:Int = 0):Void {
		if (this._bg != null) {
			return;
		}
		if (param1 == "") {
			return;
		}
		this._bg = Std.isOfType(Utils.getMaterial(param1), Sprite) ? cast(Utils.getMaterial(param1), Sprite) : null;
		if (this._bg != null) {
			this._bg.x = 0;
			this._bg.y = 0;
			if (param2 > 0) {
				this._bg.width = param2;
			}
			if (param3 > 0) {
				this._bg.height = param3;
			}
			addChildAt(this._bg, 0);
		}
	}

	// :88-112
	private function createMask(param1:String, param2:Int = 0, param3:Int = 0):Void {
		if (this._mask != null) {
			return;
		}
		if (param1 == "") {
			return;
		}
		this._mask = Std.isOfType(Utils.getMaterial(param1), Sprite) ? cast(Utils.getMaterial(param1), Sprite) : null;
		if (this._mask != null) {
			if (param2 > 0) {
				this._mask.width = param2;
			}
			if (param3 > 0) {
				this._mask.height = param3;
			}
			addChild(this._mask);
		}
		this._material.mask = this._mask;
	}

	// :114-117 + :119-126（AS3 public get/set data 对）
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this._item;
	}

	// :119-126
	private function set_data(param1:Dynamic):Dynamic {
		if (this._item == param1) {
			return param1;
		}
		this._item = param1;
		return param1;
	}

	// :128-133
	private function registerListeners():Void {
		addEventListener(MouseEvent.CLICK, this.onClick, false, 0, true);
		addEventListener(MouseEvent.ROLL_OVER, this.onOver, false, 0, true);
		addEventListener(MouseEvent.ROLL_OUT, this.onOut, false, 0, true);
	}

	// :135-140
	private function onOut(param1:MouseEvent):Void {
		var _loc2_:ViewEvent = new ViewEvent(CHILD_OUT, true);
		_loc2_.data = this._item;
		dispatchEvent(_loc2_);
	}
}
