package com.minutes.ui.collections;

import com.minutes.ui.core.LipiContainer;
import openfl.display.DisplayObject;

/**
 * com.minutes.ui.collections.LipiTile2 —— LipiTile2.as 的签名面 stub
 * （原类 174 loc，minutes UI 片真身待译——#pasture；issue #19 只保
 * ProfileHistory 用到的 ctor、CHILD_OVER/CHILD_OUT 常量、dataList/bgAlpha/
 * 宽高；真身按 colAmount×item 宽高平铺 childItem 实例）。成员清单见
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/collections/LipiTile2.as。
 */
@:keep
class LipiTile2 extends LipiContainer {
	// LipiTile2.as:10-14
	public static var CHILD_CLICK:String = "childClick";
	public static var CHILD_OVER:String = "childOver";
	public static var CHILD_OUT:String = "childOut";

	private var _childItem:Class<Dynamic>;
	private var _colAmount:Int;
	private var _itemWidth:Float;
	private var _itemHeight:Float;
	private var _topSpace:Float = 0;
	private var _leftSpace:Float = 0;
	private var _dataList:Array<Dynamic>;

	public function new(param1:Class<Dynamic>, param2:Int, param3:Float, param4:Float, param5:Float = 0, param6:Float = 0) {
		super();
		this._childItem = param1;
		this._colAmount = param2;
		this._itemWidth = param3;
		this._itemHeight = param4;
		this._topSpace = param5;
		this._leftSpace = param6;
	}

	// LipiTile2.as:44/133
	public var dataList(get, set):Array<Dynamic>;

	private function get_dataList():Array<Dynamic> {
		return this._dataList;
	}

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		this._dataList = param1;
		return param1;
	}

	// LipiTile2.as:53/63
	public var childItem(get, set):Class<Dynamic>;

	private function get_childItem():Class<Dynamic> {
		return this._childItem;
	}

	private function set_childItem(param1:Class<Dynamic>):Class<Dynamic> {
		this._childItem = param1;
		return param1;
	}

	// LipiTile2.as:138/153
	public var colAmount(get, set):Int;

	private function get_colAmount():Int {
		return this._colAmount;
	}

	private function set_colAmount(param1:Int):Int {
		this._colAmount = param1;
		return param1;
	}

	// LipiTile2.as:128/148
	public var itemWidth(get, set):Float;

	private function get_itemWidth():Float {
		return this._itemWidth;
	}

	private function set_itemWidth(param1:Float):Float {
		this._itemWidth = param1;
		return param1;
	}

	// LipiTile2.as:58/158
	public var itemHeight(get, set):Float;

	private function get_itemHeight():Float {
		return this._itemHeight;
	}

	private function set_itemHeight(param1:Float):Float {
		this._itemHeight = param1;
		return param1;
	}

	// LipiTile2.as:107/143
	public var topSpace(get, set):Float;

	private function get_topSpace():Float {
		return this._topSpace;
	}

	private function set_topSpace(param1:Float):Float {
		this._topSpace = param1;
		return param1;
	}

	// LipiTile2.as:163/168
	public var leftSpace(get, set):Float;

	private function get_leftSpace():Float {
		return this._leftSpace;
	}

	private function set_leftSpace(param1:Float):Float {
		this._leftSpace = param1;
		return param1;
	}

	// LipiTile2.as:68（真身按序号算 [x,y]；stub 未用，返回空数组）
	public function getPosition(param1:Int):Array<Dynamic> {
		return [];
	}
}
