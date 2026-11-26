package comm;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;

// comm.S9bmp —— S9bmp.as 逐句对应（issue #86 牧场库底座，comm 片）。九宫格
// 位图缩放容器：把位图按 param2 矩形切成 3x3 九块，width/height setter 只
// 拉伸中块/边块、四角不变。
// `new param1()`（Class 实例化）→ Type.createInstance。
// bg/bmpClass 原文类型 `*`（Dynamic）：bg 是嵌位图符号实例（Bitmap 子类），
// 读 width/height 经 Dynamic——html5/js 动态读取无碍；cpp 上位图类实例的
// width 是真实属性，Reflect/动态读取同通道（S9bmp.as:59-60 等处）。
@:keep
class S9bmp extends Sprite {
	// S9bmp.as:12-40
	private var bg:Dynamic;

	private var bm1:Bitmap;

	private var bm2:Bitmap;

	private var bm3:Bitmap;

	private var bm4:Bitmap;

	private var bm6:Bitmap;

	private var bm8:Bitmap;

	private var bm5:Bitmap;

	private var bm7:Bitmap;

	private var bm9:Bitmap;

	private var _x1:Float;

	private var _x2:Float;

	private var bmpClass:Dynamic;

	private var _y1:Float;

	private var _y2:Float;

	// S9bmp.as:42-114
	public function new(param1:Class<Dynamic>, param2:Rectangle) {
		super();
		if (param2 == null) {
			addChild(Type.createInstance(param1, []));
			return;
		}
		this.bmpClass = param1;
		var _loc3_:Float = param2.x;
		var _loc4_:Float = param2.width;
		var _loc5_:Float = param2.y;
		var _loc6_:Float = param2.height;
		this._x1 = _loc3_;
		this._x2 = _loc4_;
		this._y1 = _loc5_;
		this._y2 = _loc6_;
		this.bg = Type.createInstance(this.bmpClass, []);
		var _loc7_:BitmapData = new BitmapData(Std.int(this.bg.width), Std.int(this.bg.height), true, 0);
		_loc7_.draw(this.bg, null, null, null, null, true);
		var _loc8_:BitmapData = new BitmapData(Std.int(_loc3_), Std.int(_loc5_));
		_loc8_.copyPixels(_loc7_, new Rectangle(0, 0, _loc3_, _loc5_), new Point(0, 0));
		var _loc9_:BitmapData = new BitmapData(Std.int(_loc4_), Std.int(_loc5_));
		_loc9_.copyPixels(_loc7_, new Rectangle(_loc3_, 0, _loc4_, _loc5_), new Point(0, 0));
		var _loc10_:BitmapData = new BitmapData(Std.int(this.bg.width - _loc3_ - _loc4_), Std.int(_loc5_));
		_loc10_.copyPixels(_loc7_, new Rectangle(_loc3_ + _loc4_, 0, this.bg.width - _loc3_ - _loc4_, _loc5_), new Point(0, 0));
		var _loc11_:BitmapData = new BitmapData(Std.int(_loc3_), Std.int(_loc6_));
		_loc11_.copyPixels(_loc7_, new Rectangle(0, _loc5_, _loc3_, _loc6_), new Point(0, 0));
		var _loc12_:BitmapData = new BitmapData(Std.int(_loc4_), Std.int(_loc6_));
		_loc12_.copyPixels(_loc7_, new Rectangle(_loc3_, _loc5_, _loc4_, _loc6_), new Point(0, 0));
		var _loc13_:BitmapData = new BitmapData(Std.int(this.bg.width - _loc3_ - _loc4_), Std.int(_loc6_));
		_loc13_.copyPixels(_loc7_, new Rectangle(_loc3_ + _loc4_, _loc5_, this.bg.width - _loc3_ - _loc4_, _loc6_), new Point(0, 0));
		var _loc14_:BitmapData = new BitmapData(Std.int(_loc3_), Std.int(this.bg.height - _loc5_ - _loc6_));
		_loc14_.copyPixels(_loc7_, new Rectangle(0, _loc5_ + _loc6_, _loc3_, this.bg.height - _loc5_ - _loc6_), new Point(0, 0));
		var _loc15_:BitmapData = new BitmapData(Std.int(_loc4_), Std.int(this.bg.height - _loc5_ - _loc6_));
		_loc15_.copyPixels(_loc7_, new Rectangle(_loc3_, _loc5_ + _loc6_, _loc4_, this.bg.height - _loc5_ - _loc6_), new Point(0, 0));
		var _loc16_:BitmapData = new BitmapData(Std.int(this.bg.width - _loc3_ - _loc4_), Std.int(this.bg.height - _loc5_ - _loc6_));
		_loc16_.copyPixels(_loc7_,
			new Rectangle(_loc3_ + _loc4_, _loc5_ + _loc6_, this.bg.width - _loc3_ - _loc4_, this.bg.height - _loc5_ - _loc6_), new Point(0, 0));
		this.bm1 = new Bitmap(_loc8_);
		this.bm2 = new Bitmap(_loc9_);
		this.bm3 = new Bitmap(_loc10_);
		this.bm4 = new Bitmap(_loc11_);
		this.bm5 = new Bitmap(_loc12_);
		this.bm6 = new Bitmap(_loc13_);
		this.bm7 = new Bitmap(_loc14_);
		this.bm8 = new Bitmap(_loc15_);
		this.bm9 = new Bitmap(_loc16_);
		addChild(this.bm1);
		addChild(this.bm2);
		this.bm2.x = _loc3_;
		this.bm2.y = 0;
		addChild(this.bm3);
		this.bm3.x = _loc3_ + _loc4_;
		this.bm3.y = 0;
		addChild(this.bm4);
		this.bm4.x = 0;
		this.bm4.y = _loc5_;
		addChild(this.bm5);
		this.bm5.x = _loc3_;
		this.bm5.y = _loc5_;
		addChild(this.bm6);
		this.bm6.x = _loc3_ + _loc4_;
		this.bm6.y = _loc5_;
		addChild(this.bm7);
		this.bm7.x = 0;
		this.bm7.y = _loc5_ + _loc6_;
		addChild(this.bm8);
		this.bm8.x = _loc3_;
		this.bm8.y = _loc5_ + _loc6_;
		addChild(this.bm9);
		this.bm9.x = _loc3_ + _loc4_;
		this.bm9.y = _loc5_ + _loc6_;
	}

	// S9bmp.as:116-124
	private override function set_width(param1:Float):Float {
		this.bm2.width = param1 - this._x1 - (this.bg.width - this._x1 - this._x2);
		this.bm5.width = param1 - this._x1 - (this.bg.width - this._x1 - this._x2);
		this.bm8.width = param1 - this._x1 - (this.bg.width - this._x1 - this._x2);
		this.bm3.x = this._x1 + this.bm2.width;
		this.bm6.x = this._x1 + this.bm2.width;
		this.bm9.x = this._x1 + this.bm2.width;
		return param1;
	}

	// S9bmp.as:126-134
	private override function set_height(param1:Float):Float {
		this.bm4.height = param1 - this._y1 - (this.bg.height - this._y1 - this._y2);
		this.bm5.height = param1 - this._y1 - (this.bg.height - this._y1 - this._y2);
		this.bm6.height = param1 - this._y1 - (this.bg.height - this._y1 - this._y2);
		this.bm7.y = this._y1 + this.bm4.height;
		this.bm8.y = this._y1 + this.bm4.height;
		this.bm9.y = this._y1 + this.bm4.height;
		return param1;
	}
}
