package common.view.floating;

import common.Consts;
import common.view.MaterialProxy;
import interfaces.IMsgCenter;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.filters.GlowFilter;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import shim.As3;

/**
 * common.view.floating.HarvestAnimation —— HarvestAnimation.as 逐句对应
 * （issue #9）。收获飘字：MaterialProxy 苗图 + 金色数字（白描边），帧驱动
 * 缓升缓止（easingY 0.2，currentValue 自 59 收敛到 0 以下自关）。
 */
@:keep
class HarvestAnimation extends FloatingBase {
	// HarvestAnimation.as:15
	private var _materialProxy:MaterialProxy;

	// HarvestAnimation.as:17（`private const` 实例常量）
	private final easingY:Float = 0.2;

	// HarvestAnimation.as:19
	private var _numText:TextField;

	// HarvestAnimation.as:21
	private var _currentValue:Float;

	// HarvestAnimation.as:23-34
	public function new(param1:IMsgCenter) {
		super(param1);
		this.floatName = Consts.FLOAT_TYPE_HA;
		this._materialProxy = new MaterialProxy();
		addChild(this._materialProxy);
		this._numText = new TextField();
		this._numText.defaultTextFormat = new TextFormat("Verdana", 16, 16737792, true);
		this._numText.filters = [new GlowFilter(16777215, 1, 3, 3, 7)];
		this._numText.autoSize = TextFieldAutoSize.LEFT;
		addChild(this._numText);
	}

	// HarvestAnimation.as:36-53（text 非空才设内容；type 缺省 "1"；帧驱动上浮）
	override public function start(param1:Dynamic):Void {
		super.start(param1);
		if (param1 != null && Reflect.field(param1, "text") != "") {
			this.text = Std.string(Reflect.field(param1, "text"));
			if (Reflect.hasField(param1, "type")) {
				this.setContent(Std.string(Reflect.field(param1, "type")), As3.intOf(Reflect.field(param1, "cId")));
			} else {
				this.setContent("1", As3.intOf(Reflect.field(param1, "cId")));
			}
		}
		this.addEventListener(Event.ENTER_FRAME, this.onTimer);
		this._currentValue = 59;
	}

	// HarvestAnimation.as:55-64（currentValue 向 60 收敛 × easingY；每帧
	// y 降 (60 - currentValue)；< 0 摘帧听 + close）
	private function onTimer(param1:Event):Void {
		this._currentValue -= (60 - this._currentValue) * this.easingY;
		this.y -= 60 - this._currentValue;
		if (this._currentValue < 0) {
			this.removeEventListener(Event.ENTER_FRAME, this.onTimer);
			super.close();
		}
	}

	// HarvestAnimation.as:66-74
	public function setContent(param1:String, param2:Int):Void {
		if (param1 == "") {
			return;
		}
		this._materialProxy.setContent(param1, param2);
		this.cacheAsBitmap = true;
	}

	// HarvestAnimation.as:76-85（纯数字且不带正负号时补 "+ " 前缀；文本
	// (65, (60-高)/2) 落位）
	public var text(never, set):String;

	private function set_text(param1:String):String {
		if (param1.charAt(0) != "-" && param1.charAt(0) != "+" && Math.isNaN(As3.floatOf(param1)) == false) {
			param1 = "+ " + param1;
		}
		this._numText.text = param1;
		this._numText.x = 65;
		this._numText.y = (60 - this._numText.height) / 2;
		return param1;
	}

	// HarvestAnimation.as:87-93
	override public function end():Void {
		super.end();
		this.removeEventListener(Event.ENTER_FRAME, this.onTimer);
		this._materialProxy = null;
		this._numText = null;
	}
}
