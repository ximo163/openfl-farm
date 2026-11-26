package mc.view.common;

import com.minutes.ui.collections.LipiListChild;
import com.minutes.ui.collections.SimpleCollection;
import shim.As3;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

/**
 * mc.view.common.HList —— HList.as 逐句对应（issue #87 牧场「通用视图」
 * 片；#19 签名面 stub 充真身）。横向滚动列表：子件装入 _childSprite
 * 后用 scrollRect 左右平移，setChildPosition 按 align（left/center/
 * right）定首件 x；rightEnabled/leftEnabled 给方向钮使能判据。注意与
 * com.qzone.qui.controls.HList（qui 组件库列表）是两个类。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/HList.as。
 *
 * PORT-NOTE（_width/_height 存储）：AS3 在 HList 重声明同名 private
 * 字段（:16/:24，初值 100——与 SimpleCollection.as:11-13 的父类槽位
 * 不相交）。Haxe 禁止子类重定义父类字段，而 HList 覆写了 width/
 * height 全部四个访问器、父类存储通道（set_bg 的写透）读的都是
 * 覆写后的访问器——由父类唯一存储承担无观察差（值域一致，初值同
 * 为 100）。
 * PORT-NOTE（setChildPosition 的 `- 1`，:154/:163）：center/right 的
 * 首件公式是 `numChildren * (child0.width + gap) - 1`——减的是常量
 * 1 而非 gap（排版直觉应减 gap），原版如此逐字保留。
 * PORT-NOTE（`(child as LipiListChild).data`，:115）：as 失配-null 语义
 * ——itemClass 实例实践上是 LipiListChild 子类（构造约束），isOfType
 * 门 + 直取；失配时 AS3 得到 null 再写 .data NPE，等价形是直取 null
 * 后写字段——Haxe 下 Reflect 写 null 字段同样抛，门后直写保持同形态。
 */
@:keep
class HList extends SimpleCollection {
	// HList.as:11-29（_width/_height 见类头 PORT-NOTE）
	private var _childSprite:Sprite;
	private var _align:String = "left";
	private var _dataList:Array<Dynamic> = [];
	private var _gap:Int;
	private var itemPosition:Int = 0;
	private var offsetX:Float = 0;
	private var _itemClass:Class<Dynamic>;
	private var offsetY:Float = 0;

	// HList.as:32-39
	public function new(param1:Class<Dynamic>, param2:Int = 0) {
		super();
		this._itemClass = param1;
		this._gap = param2;
		this._childSprite = new Sprite();
		addChild(this._childSprite);
	}

	// HList.as:41-52
	public function leftMove2(param1:Int = 1):Void {
		var _loc3_:Float = Math.NaN;
		var _loc2_:Float = this._childSprite.getChildAt(this.itemPosition).x;
		if (this.itemPosition - param1 >= 0) {
			this.itemPosition -= param1;
			_loc3_ = this._childSprite.getChildAt(this.itemPosition).x;
			this.offsetX += _loc3_ - _loc2_;
			scrollRect = new Rectangle(_loc3_, 0, this.width, this.height);
		}
	}

	// HList.as:54-62（align 存取——setter 调 setChildPosition）
	public var align(get, set):String;

	private function get_align():String {
		return this._align;
	}

	private function set_align(param1:String):String {
		this._align = param1;
		this.setChildPosition();
		return param1;
	}

	// HList.as:64-83
	public function rightMove(param1:Int):Bool {
		if (this._childSprite.width < this.width) {
			return false;
		}
		var _loc2_:Bool = true;
		if (this.offsetX + this.width + param1 > this._childSprite.width) {
			this.offsetX = this._childSprite.width - this.width;
			_loc2_ = false;
		} else {
			this.offsetX += param1;
		}
		scrollRect = new Rectangle(this.offsetX, this.offsetY, this.width, this.height);
		return _loc2_;
	}

	// HList.as:85-89/（dataList 存取——setter 调 setChild）
	public var dataList(get, set):Array<Dynamic>;

	private function set_dataList(param1:Array<Dynamic>):Array<Dynamic> {
		this._dataList = param1;
		this.setChild();
		return param1;
	}

	// HList.as:91-98（rightEnabled：offsetX < childSprite.width - width - 5）
	public var rightEnabled(get, never):Bool;

	private function get_rightEnabled():Bool {
		if (this.offsetX >= this._childSprite.width - this.width - 5) {
			return false;
		}
		return true;
	}

	// HList.as:100-103/:174-180（width 覆写——setter 清 offset 刷 scrollRect）
	override private function get_width():Float {
		return this._width;
	}

	override private function set_width(param1:Float):Float {
		this._width = param1;
		this.offsetX = 0;
		this.offsetY = 0;
		scrollRect = new Rectangle(this.offsetX, this.offsetY, this.width, this.height);
		return param1;
	}

	// HList.as:105-127
	private function setChild():Void {
		var _loc2_:DisplayObject = null;
		var _loc1_:Int = 0;
		while (_loc1_ < this._dataList.length) {
			if (_loc1_ >= this._childSprite.numChildren) {
				_loc2_ = cast Type.createInstance(this._itemClass, []);
				this._childSprite.addChild(_loc2_);
			}
			castLipiListChild(this._childSprite.getChildAt(_loc1_)).data = this._dataList[_loc1_];
			_loc1_++;
		}
		while (this._childSprite.numChildren > this._dataList.length) {
			this._childSprite.removeChildAt(this._childSprite.numChildren - 1);
		}
		this.setChildPosition();
		scrollRect = new Rectangle(0, 0, this.width, this.height);
		this.offsetX = 0;
		this.itemPosition = 0;
	}

	// HList.as:119-130
	public function rightMove2(param1:Int = 1):Void {
		var _loc3_:Float = Math.NaN;
		var _loc2_:Float = this._childSprite.getChildAt(this.itemPosition).x;
		if (this.itemPosition + param1 < this._childSprite.numChildren - 4) {
			this.itemPosition += param1;
			_loc3_ = this._childSprite.getChildAt(this.itemPosition).x;
			this.offsetX += _loc3_ - _loc2_;
			scrollRect = new Rectangle(_loc3_, 0, this.width, this.height);
		}
	}

	// HList.as:132-169（align 三分支定位——`- 1` 常量见类头 PORT-NOTE。
	// PORT-NOTE（_loc1_ 的 int 截断）：FFDec 标注 `_loc1_:int`——ABC
	// 实证（DumpAbcMethod 读 Master2_v_142.swf）：center/right 分支的
	// Number 表达式与循环累进在每次 OSetReg(1) 前都有 OToInt（convert_i
	// = ToInt32 向零截断）。故 center 首件 (100-119)/2=-9.5 落 -9、
	// 逐件 -9/31/71——半像素位在原版被截成整像素。Haxe Float→Int 编译
	// 红，照 lessons 「int 声明照抄 + As3.intOf 族包赋值」：声明 int
	// 照抄、赋值经 As3.int32（ToInt32 截断+回绕等价物）。）
	private function setChildPosition():Void {
		var _loc1_:Int = 0;
		var _loc2_:Int = 0;
		if (this.align == "left") {
			_loc1_ = 0;
		} else if (this.align == "center") {
			if (this._childSprite.numChildren == 0) {
				_loc1_ = 0;
			} else {
				_loc1_ = As3.int32((this.width - (this._childSprite.numChildren * (this._childSprite.getChildAt(_loc2_).width + this._gap) - 1)) / 2);
			}
		} else {
			_loc1_ = As3.int32(this.width - (this._childSprite.numChildren * (this._childSprite.getChildAt(_loc2_).width + this._gap) - 1));
		}
		_loc2_ = 0;
		while (_loc2_ < this._childSprite.numChildren) {
			this._childSprite.getChildAt(_loc2_).x = _loc1_;
			_loc1_ = As3.int32(_loc1_ + this._childSprite.getChildAt(_loc2_).width + this._gap);
			_loc2_++;
		}
	}

	// HList.as:171-174/:182-198（height 覆写）
	override private function get_height():Float {
		return this._height;
	}

	override private function set_height(param1:Float):Float {
		this._height = param1;
		this.offsetX = 0;
		this.offsetY = 0;
		scrollRect = new Rectangle(this.offsetX, this.offsetY, this.width, this.height);
		return param1;
	}

	private function get_dataList():Array<Dynamic> {
		return this._dataList;
	}

	// HList.as:200-207（leftEnabled：offsetX > 0）
	public var leftEnabled(get, never):Bool;

	private function get_leftEnabled():Bool {
		if (this.offsetX <= 0) {
			return false;
		}
		return true;
	}

	// HList.as:209-223
	public function leftMove(param1:Int):Bool {
		var _loc2_:Bool = true;
		if (this.offsetX - param1 < 0) {
			this.offsetX = 0;
			_loc2_ = false;
		} else {
			this.offsetX -= param1;
		}
		scrollRect = new Rectangle(this.offsetX, this.offsetY, this.width, this.height);
		return _loc2_;
	}

	// `x as LipiListChild`（isOfType ? cast : null，setChild 一处用）
	private static function castLipiListChild(param1:Dynamic):LipiListChild {
		return Std.isOfType(param1, LipiListChild) ? cast(param1, LipiListChild) : null;
	}
}
