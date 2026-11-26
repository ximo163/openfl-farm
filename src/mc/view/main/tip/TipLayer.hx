package mc.view.main.tip;

import mc.control.ViewControl;
import mc.events.TipEvent;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import shim.As3;

/**
 * mc.view.main.tip.TipLayer —— TipLayer.as 逐句对应（issue #87「提示」片）。
 * 提示层：TIP_SHOW 记下 waitTip/waitArg/waitTX/waitTY + getTimer 时刻后重启
 * 300ms 单发 Timer，到点换同名 Tip 实例未见则经 TipClassLib 建并存
 * tipInstance 表复用，喂 data/tX/tY/mX/mY 挂树；TIP_HIDE 摘 tip 停表；
 * stageMove 跟进 mX/mY + updateAfterEvent。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/tip/TipLayer.as。
 */
@:keep
class TipLayer extends Sprite {
	// TipLayer.as:15-31
	private var tipInstance:Dynamic;
	private var timer:Timer;
	private var tip:Tip;
	private var waitArg:Dynamic;
	private var waitTime:Int = 0;
	private var lastTip:String;
	private var waitTip:String = "";
	private var waitTX:Int = 0;
	private var waitTY:Int = 0;

	// TipLayer.as:33-40
	public function new() {
		super();
		this.tipInstance = {};
		addEventListener(Event.ADDED_TO_STAGE, this.addedToStage);
		mouseChildren = false;
		mouseEnabled = false;
	}

	// TipLayer.as:42-61
	private function timerHandler(param1:TimerEvent):Void {
		if (this.waitTip != "") {
			if (this.lastTip != this.waitTip) {
				this.tip = this.getTip(this.waitTip);
				this.lastTip = this.waitTip;
			}
			if (this.tip != null) {
				addChild(this.tip);
				this.tip.data = this.waitArg;
				this.tip.tX = this.waitTX;
				this.tip.tY = this.waitTY;
				this.tip.mX = mouseX;
				this.tip.mY = mouseY;
			}
		}
	}

	// TipLayer.as:63-70
	private function init():Void {
		ViewControl.getInstance().addEventListener(TipEvent.TIP_SHOW, this.tipShow, false, 0, true);
		ViewControl.getInstance().addEventListener(TipEvent.TIP_HIDE, this.tipHide, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, this.stageMove, false, 0, true);
		this.timer = new Timer(300, 1);
		this.timer.addEventListener(TimerEvent.TIMER, this.timerHandler);
	}

	// TipLayer.as:72-76
	private function addedToStage(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.addedToStage);
		this.init();
	}

	// TipLayer.as:78-96（tipInstance 表复用；未见经 TipClassLib.getClass 建
	// 存表挂树；"" 返回 null。PORT-NOTE(as 语义)：`new (cls as Class)() as Tip`
	// ——AS3 `as` 失配得 null，isOfType 门 + 直取等价；hasOwnProperty 对动态
	// Object 键查询等价 Reflect.hasField（tipInstance 是 {} 匿名对象，键为
	// 物理字段，lessons #18 密封类陷阱不适用）
	private function getTip(param1:String):Tip {
		var _loc2_:Tip = null;
		if (param1 == "") {
			return null;
		}
		if (this.tipInstance == null || !Reflect.hasField(this.tipInstance, param1)) {
			// 原文 `new (TipClassLib.getClass(param1) as Class)() as Tip`——
			// 键缺失时 as 链出 null、new null 掷 TypeError；Type.createInstance
			// 对 null 类同掷（崩溃路径等价，不垫守卫）
			var _loc4_:Dynamic = Type.createInstance(TipClassLib.getClass(param1), []);
			_loc2_ = Std.isOfType(_loc4_, Tip) ? cast _loc4_ : null;
			Reflect.setField(this.tipInstance, param1, _loc2_);
			addChild(_loc2_);
		} else {
			_loc2_ = Reflect.field(this.tipInstance, param1);
		}
		return _loc2_;
	}

	// TipLayer.as:98-106
	private function stageMove(param1:MouseEvent):Void {
		if (this.tip != null) {
			this.tip.mX = param1.stageX;
			this.tip.mY = param1.stageY;
			param1.updateAfterEvent();
		}
	}

	// TipLayer.as:108-120（`if(this.tip != null) {}` 空分支原文照留）
	private function tipShow(param1:TipEvent):Void {
		if (this.tip != null) {}
		this.waitTip = param1.tipType;
		this.waitArg = param1.tipArgument;
		this.waitTX = Std.int(param1.tX);
		this.waitTY = Std.int(param1.tY);
		this.waitTime = As3.getTimer();
		this.timer.stop();
		this.timer.start();
	}

	// TipLayer.as:122-129
	private function tipHide(param1:TipEvent):Void {
		if (this.tip != null && contains(this.tip)) {
			removeChild(this.tip);
		}
		this.timer.stop();
	}
}
