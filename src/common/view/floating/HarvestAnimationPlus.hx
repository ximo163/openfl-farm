package common.view.floating;

import common.Consts;
import common.Session;
import common.misc.Utils;
import common.view.MaterialProxy;
import interfaces.IMsgCenter;
import openfl.Lib.getTimer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.filters.GlowFilter;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import shim.As3;

/**
 * common.view.floating.HarvestAnimationPlus —— HarvestAnimationPlus.as 逐句
 * 对应（issue #9）。收获加成飘字：me 用 HarvestPlusB 素材整体件；访客侧
 * 手搓两行 Times New Roman 28 号金字，偶数收获在上升途中补挂第二行+苗图。
 * 帧驱动缓升同 HarvestAnimation（easingY 0.2、currentValue 自 59）。
 */
@:keep
class HarvestAnimationPlus extends FloatingBase {
	// HarvestAnimationPlus.as:18
	private var _isEven:Bool;

	// HarvestAnimationPlus.as:20
	private var _materialProxy:MaterialProxy;

	// HarvestAnimationPlus.as:22（偶数行的二段挂载只做一次）
	private var _lock:Bool;

	// HarvestAnimationPlus.as:24
	private final easingY:Float = 0.2;

	// HarvestAnimationPlus.as:26
	private var _currentValue:Float;

	// HarvestAnimationPlus.as:28-36
	private var _numText1:TextField;
	private var _numText2:TextField;
	private var _numText:TextField;

	// HarvestAnimationPlus.as:34
	private var _materialProxy1:MaterialProxy;

	// HarvestAnimationPlus.as:36
	private var _mc:Sprite;

	// HarvestAnimationPlus.as:38-74
	public function new(param1:IMsgCenter) {
		var _loc2_:String = null;
		var _loc3_:Sprite = null;
		var _loc4_:Array<openfl.filters.BitmapFilter> = null;
		super(param1);
		this.floatName = Consts.FLOAT_TYPE_HAP;
		this._lock = true;
		this._isEven = false;
		this._materialProxy = new MaterialProxy();
		addChild(this._materialProxy);
		if (Session.getInstance().me == true) {
			_loc2_ = "HarvestPlusB";
			_loc3_ = cast Utils.getMaterial(_loc2_);
			if (_loc3_ != null) {
				this._mc = _loc3_;
				this._numText = cast Reflect.field(_loc3_, "txt");
				addChild(_loc3_);
			}
		} else {
			this._numText1 = new TextField();
			this._numText2 = new TextField();
			// 原版局部无类型注解（new Array）＋首元素 GlowFilter；filters
			// 属性要 Array<BitmapFilter>，按元素类型收窄
			_loc4_ = [new GlowFilter(16777215, 1, 3, 3, 7)];
			this._numText1.defaultTextFormat = new TextFormat("Times New Roman", 28, 16737792, true);
			this._numText1.filters = _loc4_;
			this._numText1.autoSize = TextFieldAutoSize.LEFT;
			addChild(this._numText1);
			this._numText2.defaultTextFormat = new TextFormat("Times New Roman", 28, 16737792, true);
			this._numText2.filters = _loc4_;
			this._numText2.autoSize = TextFieldAutoSize.LEFT;
			this._materialProxy1 = new MaterialProxy();
		}
	}

	// HarvestAnimationPlus.as:76-112（me：素材文本落位；访客：偶数收获拆
	// 半 "+n" 两行、第二行+苗图随上升途中挂）
	public var text(never, set):String;

	private function set_text(param1:String):String {
		var _loc2_:Int = 0;
		if (Session.getInstance().me == true) {
			if (this._numText != null) {
				this._numText.text = param1;
			}
			if (this._mc != null) {
				this._mc.x = 60;
				this._mc.y = (60 - this._numText.height) / 2;
			}
		} else {
			_loc2_ = As3.intOf(As3.parseInt(param1));
			this._numText1.text = param1;
			this._numText1.x = 60;
			this._numText1.y = (60 - this._numText1.height) / 2;
			if (_loc2_ % 2 == 0) {
				this._materialProxy1.y = this._numText1.y + this._numText1.height;
				this._numText2.x = 60;
				this._numText2.y = this._materialProxy1.y + 10;
				// AS3 int `/=`：按 Number 相除截断回 int
				_loc2_ = As3.intOf(_loc2_ / 2);
				this._numText1.text = "+" + Std.string(_loc2_);
				this._numText2.text = "+" + Std.string(_loc2_);
				this._isEven = true;
			} else {
				this._isEven = false;
			}
		}
		return param1;
	}

	// HarvestAnimationPlus.as:114-122
	override public function end():Void {
		super.end();
		this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		this._mc = null;
		this._numText = null;
		this._numText1 = null;
		this._numText2 = null;
		this._materialProxy = null;
		this._materialProxy1 = null;
	}

	// HarvestAnimationPlus.as:124-134
	override public function start(param1:Dynamic):Void {
		super.start(param1);
		if (param1 != null) {
			this.text = Std.string(Reflect.field(param1, "text"));
			this.setContent(Std.string(Reflect.field(param1, "type")), As3.intOf(Reflect.field(param1, "cId")));
		}
		this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		this._currentValue = 59;
	}

	// HarvestAnimationPlus.as:136-151（缓升同 HarvestAnimation；偶数行在
	// currentValue < 58 时补挂一次后开锁）
	private function onEnterFrame(param1:Event):Void {
		this._currentValue -= (60 - this._currentValue) * this.easingY;
		this.y -= 60 - this._currentValue;
		if (this._lock && this._isEven && this._currentValue < 58) {
			addChild(this._numText2);
			addChild(this._materialProxy1);
			this._lock = false;
		}
		if (this._currentValue < 0) {
			this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			super.close();
		}
	}

	// HarvestAnimationPlus.as:153-168（两个苗图同 type/id；cacheAsBitmap）
	public function setContent(param1:String, param2:Int):Void {
		if (param1 == "") {
			return;
		}
		if (this._materialProxy != null) {
			this._materialProxy.setContent(param1, param2);
		}
		if (this._isEven == true && this._materialProxy1 != null) {
			this._materialProxy1.setContent(param1, param2);
		}
		this.cacheAsBitmap = true;
	}
}
