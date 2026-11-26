package com.minutes.ui.collections;

import com.minutes.ui.core.LipiContainer;
import com.minutes.ui.core.Reservoir;
import openfl.display.DisplayObject;

/**
 * com.minutes.ui.collections.LipiTile2 —— LipiTile2.as 逐句对应（issue #86
 * 牧场库底座，LipiUI 组件库片）。
 * legacy/decompiled/Master2_v_142/scripts/com/minutes/ui/collections/LipiTile2.as。
 *
 * PORT-NOTE（构造器参数落位，LipiTile2.as:32-42）：`leftSpace = param5`、
 * `topSpace = param6`——形参顺序 (childItem, colAmount, itemWidth,
 * itemHeight, param5=0, param6=0) 里 param5 进 leftSpace、param6 进
 * topSpace（与成员声明顺序相反），原版如此逐字。
 * PORT-NOTE（`as LipiListChild`，:85/:90）：eval 裸 cast 不做运行时检查
 * ——元素恒为 Reservoir 按 childItem 类造的实例（LipiListChild 子类），
 * isOfType 门 + 直取。
 * PORT-NOTE（setChild 的 `var _loc2_:* = int(numChildren - 1)`，:96）：
 * AS3 int() 强转——numChildren 本就是 int，shim.As3.intOf 等价通道；
 * Dynamic 局部（AS3 `*`）照翻。
 * PORT-NOTE（`vScrollPosition = 0`，:104）：写 LipiContainer 的属性通道
 * ——verticalScrollBar 尚未创建时 setter 空转（LipiContainer.as:408-414
 * 的 null 守卫），原版语义。
 */
@:keep
class LipiTile2 extends LipiContainer {
	// LipiTile2.as:10-14
	public static var CHILD_CLICK:String = "childClick";
	public static var CHILD_OVER:String = "childOver";
	public static var CHILD_OUT:String = "childOut";

	// :16-30
	private var _dataList:Array<Dynamic>;
	private var _itemHeight:Float = 0;
	private var aReservoir:Reservoir;
	private var _leftSpace:Float = 0;
	private var _topSpace:Float = 0;
	private var _itemWidth:Float = 0;
	private var _colAmount:Int = 0;
	private var _childItem:Class<Dynamic>;

	// :32-42（参数落位见类头 PORT-NOTE）
	public function new(param1:Class<Dynamic>, param2:Int, param3:Float, param4:Float, param5:Float = 0, param6:Float = 0) {
		super();
		this.childItem = param1;
		this.colAmount = param2;
		this.leftSpace = param5;
		this.topSpace = param6;
		this.itemWidth = param3;
		this.itemHeight = param4;
		this.aReservoir = new Reservoir(param1);
	}

	// :44-51
	public var dataList(get, set):Array<Dynamic>;

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		this._dataList = param1;
		if (this._dataList != null) {
			this.setChild();
		}
		return param1;
	}

	// :53-56
	public var childItem(get, set):Class<Dynamic>;

	private function get_childItem():Class<Dynamic> {
		return this._childItem;
	}

	// :58-61
	public var itemHeight(get, set):Float;

	private function get_itemHeight():Float {
		return this._itemHeight;
	}

	// :63-66
	private function set_childItem(param1:Class<Dynamic>):Class<Dynamic> {
		this._childItem = param1;
		return param1;
	}

	// :68-75（`new Array(x,y)`——Haxe 数组字面量等价）
	public function getPosition(param1:Int):Array<Dynamic> {
		var _loc2_:Float = Math.floor(param1 / this.colAmount);
		var _loc3_:Float = param1 % this.colAmount;
		var _loc4_:Float = this.leftSpace + _loc3_ * this.itemWidth;
		var _loc5_:Float = this.topSpace + _loc2_ * this.itemHeight;
		return [_loc4_, _loc5_];
	}

	// :77-105（`getChildAt(_loc1_) as LipiListChild` 见类头 PORT-NOTE；
	// numChildren/getChildAt/removeChildAt 走 LipiContainer 的 contentPane
	// 重定向——子件进内容区，遮罩/滚动生效，原版语义）
	private function setChild():Void {
		var _loc3_:LipiListChild = null;
		var _loc1_:Int = 0;
		while (_loc1_ < this.dataList.length) {
			if (numChildren > _loc1_) {
				var _loc4_:Dynamic = getChildAt(_loc1_);
				_loc3_ = Std.isOfType(_loc4_, LipiListChild) ? cast(_loc4_, LipiListChild) : null;
				_loc3_.data = this.dataList[_loc1_];
			} else {
				var _loc5_:Dynamic = this.aReservoir.getInstance();
				_loc3_ = Std.isOfType(_loc5_, LipiListChild) ? cast(_loc5_, LipiListChild) : null;
				_loc3_.data = this.dataList[_loc1_];
				addChild(_loc3_);
			}
			_loc1_++;
		}
		// PORT-NOTE: `var _loc2_:* = int(…)`（:96）——AS3 `*` 但 int() 强转
		// 后始终是 int（下标递减循环纯 int 运算），Int 定型比 Dynamic 更贴近
		// 运行时；也避开 scan_dyn_writes 与 setChildPosition 的 DisplayObject
		// _loc2_ 跨函数同名撞车
		var _loc2_:Int = shim.As3.intOf(numChildren - 1);
		while (_loc2_ >= this.dataList.length) {
			this.aReservoir.delInstance(getChildAt(_loc2_));
			removeChildAt(_loc2_);
			_loc2_--;
		}
		this.setChildPosition();
		vScrollPosition = 0;
	}

	// :107-110
	public var topSpace(get, set):Float;

	private function set_topSpace(param1:Float):Float {
		this._topSpace = param1;
		return param1;
	}

	// :112-126（`_loc2_ = null` 空赋值原样保留——重声明后立刻清 null
	// 再进循环，原版冗余逐字；`_loc1_[0]` 数组下标读是 getPosition 返的
	// 普通 Array，直读）
	private function setChildPosition():Void {
		var _loc2_:DisplayObject = null;
		var _loc1_:Array<Dynamic> = null;
		_loc2_ = null;
		var _loc3_:Int = 0;
		while (_loc3_ < numChildren) {
			_loc1_ = this.getPosition(_loc3_);
			_loc2_ = getChildAt(_loc3_);
			_loc2_.x = _loc1_[0];
			_loc2_.y = _loc1_[1];
			_loc3_++;
		}
	}

	// :128-131
	public var itemWidth(get, set):Float;

	private function set_itemWidth(param1:Float):Float {
		this._itemWidth = param1;
		return param1;
	}

	// :133-136
	private function get_dataList():Array<Dynamic> {
		return this._dataList;
	}

	// :138-141
	public var colAmount(get, set):Int;

	private function set_colAmount(param1:Int):Int {
		this._colAmount = param1;
		return param1;
	}

	// :143-146
	private function get_topSpace():Float {
		return this._topSpace;
	}

	// :148-151
	private function get_itemWidth():Float {
		return this._itemWidth;
	}

	// :153-156
	private function get_colAmount():Int {
		return this._colAmount;
	}

	// :158-161
	private function set_itemHeight(param1:Float):Float {
		this._itemHeight = param1;
		return param1;
	}

	// :163-166
	public var leftSpace(get, set):Float;

	private function set_leftSpace(param1:Float):Float {
		this._leftSpace = param1;
		return param1;
	}

	// :168-171
	private function get_leftSpace():Float {
		return this._leftSpace;
	}
}
