package common.view.floating;

import com.qzone.qui.controls.Text;
import com.qzone.qui.effects.Move;
import com.qzone.qui.managers.EffectManager;
import com.qzone.utils.AlignUtil;
import common.Consts;
import common.misc.Utils;
import interfaces.IMsgCenter;
import openfl.display.DisplayObjectContainer;
import openfl.display.GradientType;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.TimerEvent;
import openfl.filters.DropShadowFilter;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.utils.Timer;
import shim.As3;

/**
 * common.view.floating.TextTipFloating —— TextTipFloating.as 逐句对应
 * （issue #9）。文本提示飘字：Success/Error/Tip 图标 + Text 控件 + 渐变
 * 圆角背景，EffectManager.In 入场（默认 Move），Timer stoptime（缺省
 * 2000ms）自关。`as Stage` 的 null 语义经 Std.isOfType 复刻。
 */
@:keep
class TextTipFloating extends FloatingBase {
	// TextTipFloating.as:24
	private var _text:Text;

	// TextTipFloating.as:26
	private var _timer:Timer;

	// TextTipFloating.as:28（AS3 `public var effect:*`）
	public var effect:Dynamic;

	// TextTipFloating.as:30
	private var _icon:Sprite;

	// TextTipFloating.as:32-56
	public function new(param1:IMsgCenter) {
		super(param1);
		this.mouseChildren = false;
		this.mouseEnabled = false;
		this.floatName = Consts.FLOAT_TYPE_TEXTTIP;
		this._icon = cast Utils.getMaterial("SuccessIcon");
		if (this._icon != null) {
			this._icon.scaleX = this._icon.scaleY = 0.33;
			this._icon.x = this._icon.y = 20;
			addChild(this._icon);
		}
		this._text = new Text(240);
		this._text.textDefaultFormat.color = 3355443;
		this._text.textDefaultFormat.size = 14;
		this._text.textDefaultFormat.leading = 5;
		if (this._icon != null) {
			this._text.x = this._icon.width + this._icon.x + 5;
			this._text.y = this._icon.y;
		}
		addChild(this._text);
		this._timer = null;
	}

	// TextTipFloating.as:58-74（入场效果结束：按 data.parent 居中回算全局
	// 坐标落位）
	private function onAddedEffectEnd():Void {
		var _loc1_:DisplayObjectContainer = null;
		var _loc2_:Point = null;
		var _loc3_:Point = null;
		if (this._data != null) {
			var parentObj:Dynamic = Reflect.field(this._data, "parent");
			_loc1_ = Std.isOfType(parentObj, DisplayObjectContainer) ? cast parentObj : null;
			if (_loc1_ != null) {
				// 原版 `_loc1_ as Stage == null ? _loc1_.width : stageWidth`
				var stage1:Stage = Std.isOfType(_loc1_, Stage) ? cast _loc1_ : null;
				_loc2_ = new Point(AlignUtil.middle(stage1 == null ? _loc1_.width : stage1.stageWidth, this.width),
					AlignUtil.middle(stage1 == null ? _loc1_.height : stage1.stageHeight, this.height));
				_loc3_ = _loc1_.localToGlobal(_loc2_);
				this.x = _loc3_.x;
				this.y = _loc3_.y;
			}
		}
	}

	// TextTipFloating.as:76-84
	private function stopTimer():Void {
		if (this._timer != null) {
			this._timer.removeEventListener(TimerEvent.TIMER, this.onTimeout);
			this._timer.stop();
			this._timer = null;
		}
	}

	// TextTipFloating.as:86-154（icon/text/effect 逐键可选覆盖；背景后按
	// parent 尺寸居中 + EffectManager.In 入场；timer 按 stoptime 或 2000）
	override public function start(param1:Dynamic):Void {
		var _loc3_:String = null;
		super.start(param1);
		if (Reflect.hasField(param1, "icon") && Reflect.field(param1, "icon") != "") {
			if (this._icon != null) {
				removeChild(this._icon);
			}
			_loc3_ = Reflect.field(param1, "icon");
			if (_loc3_ == "success") {
				this._icon = cast Utils.getMaterial("SuccessIcon");
			} else if (_loc3_ == "error") {
				this._icon = cast Utils.getMaterial("ErrorIcon");
			} else if (_loc3_ == "tip") {
				this._icon = cast Utils.getMaterial("TipIcon");
			}
			if (this._icon != null) {
				this._icon.scaleX = this._icon.scaleY = 0.33;
				this._icon.x = this._icon.y = 20;
				addChild(this._icon);
			}
		}
		if (Reflect.hasField(param1, "text") && Reflect.field(param1, "text") != "") {
			this._text.text = Std.string(Reflect.field(param1, "text"));
			if (this._icon != null) {
				this._text.x = this._icon.width + this._icon.x + 5;
				this._text.y = this._icon.y;
			}
		}
		if (Reflect.hasField(param1, "effect")) {
			this.effect = Reflect.field(param1, "effect");
		} else {
			this.effect = Move;
		}
		this.drawBackground();
		var parentObj:Dynamic = Reflect.field(param1, "parent");
		var _loc2_:DisplayObjectContainer = Std.isOfType(parentObj, DisplayObjectContainer) ? cast parentObj : null;
		if (_loc2_ != null) {
			var stage1:Stage = Std.isOfType(_loc2_, Stage) ? cast _loc2_ : null;
			this.x = AlignUtil.middle(stage1 == null ? _loc2_.width : stage1.stageWidth, this.width);
			this.y = AlignUtil.middle(stage1 == null ? _loc2_.height : stage1.stageHeight, this.height);
			EffectManager.In(_loc2_, this, this.onAddedEffectEnd);
		}
		if (this._timer == null) {
			if (Reflect.hasField(param1, "stoptime")) {
				this._timer = new Timer(As3.floatOf(Reflect.field(param1, "stoptime")), 1);
			} else {
				this._timer = new Timer(2000, 1);
			}
			this._timer.addEventListener(TimerEvent.TIMER, this.onTimeout);
			this._timer.start();
		}
	}

	// TextTipFloating.as:156-168（竖直渐变白→黑圆角框 + 阴影；尺寸随
	// 内容 +20 边距）
	private function drawBackground():Void {
		var _loc1_:Matrix = new Matrix();
		_loc1_.rotate(90);
		_loc1_.createGradientBox(200, 200, Math.PI / 2, 50, 50);
		var _loc2_:Graphics = this.graphics;
		_loc2_.clear();
		_loc2_.beginGradientFill(GradientType.LINEAR, [16777215, 0], [0.8, 0.7], [0, 255], _loc1_);
		_loc2_.lineStyle(1, 13421772);
		_loc2_.drawRoundRect(0, 0, this.width + 20 * 2, this.height + 20 * 2, 20, 20);
		_loc2_.endFill();
		this.filters = [new DropShadowFilter(5, 45, 0, 0.6, 5, 5)];
	}

	// TextTipFloating.as:170-173
	private function onTimeout(param1:TimerEvent):Void {
		super.close();
	}

	// TextTipFloating.as:175-181
	override public function end():Void {
		super.end();
		this.stopTimer();
		this._icon = null;
		this._text = null;
	}
}
