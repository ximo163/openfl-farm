package framework.layers;

import common.Consts;
import common.view.tip.TipControl;
import events.TipEvent;
import framework.base.BaseLayer;
import interfaces.ITip;
import openfl.errors.ArgumentError;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.utils.Timer;

/**
 * framework.layers.TipLayer —— TipLayer.as 逐句对应（issue #42，替换 #7 的
 * 闭包 stub）。提示宿主层：TIP_SHOW 暂存待显四元组并复位 300ms 一次的
 * Timer，到点经 TipControl 注册表反射建 tip（实例按名缓存）、装载 data 与
 * 定位，MOUSE_MOVE 持续跟随，TIP_UPDATE 只刷同屏同型，TIP_HIDE 摘除停表。
 */
@:keep
class TipLayer extends BaseLayer {
	// TipLayer.as:15
	private var m_libs:Dynamic;

	// TipLayer.as:17
	private var m_tip:ITip;

	// TipLayer.as:19-21
	private var m_waitTX:Int;

	private var m_waitTY:Int;

	// TipLayer.as:23
	private var m_waitArg:Dynamic;

	// TipLayer.as:25
	private var m_timer:Timer;

	// TipLayer.as:27
	private var m_waitTip:String;

	// TipLayer.as:29
	private var m_ctrl:TipControl;

	// TipLayer.as:31-49（null 参抛 ArgumentError "Null parameter"）
	public function new(param1:TipControl) {
		if (param1 != null) {
			super(param1.getMsgCenter());
			this.m_ctrl = param1;
			this.m_libs = {};
			this.m_waitArg = null;
			this.m_waitTX = this.m_waitTY = 0;
			this.m_waitTip = "";
			this.m_timer = null;
			this.m_tip = null;
			mouseEnabled = false;
			mouseChildren = false;
			name = Consts.LAYER_TIP;
			return;
		}
		throw new ArgumentError("Null parameter");
	}

	// TipLayer.as:51-58
	private function remove():Void {
		if (this.m_tip != null && this.contains(this.m_tip.displayObject) == true) {
			removeChild(this.m_tip.displayObject);
			this.m_tip = null;
		}
	}

	// TipLayer.as:60-95（getTip：注册表类反射构造 + 按名实例缓存；
	// `new _loc3_() as ITip` → Type.createInstance）
	private function getTip(param1:String):ITip {
		var _loc3_:Class<Dynamic> = null;
		if (param1 == "") {
			return null;
		}
		if (this.m_ctrl == null) {
			return null;
		}
		var _loc2_:ITip = null;
		if (this.m_libs == null || Reflect.hasField(this.m_libs, param1) == false) {
			_loc3_ = this.m_ctrl.getClass(param1);
			if (_loc3_ == null) {
				return null;
			}
			_loc2_ = cast(Type.createInstance(_loc3_, []), ITip);
			if (_loc2_.displayObject != null) {
				Reflect.setField(this.m_libs, param1, _loc2_);
				addChild(_loc2_.displayObject);
			} else {
				_loc2_ = null;
			}
		} else {
			_loc2_ = Reflect.field(this.m_libs, param1);
		}
		return _loc2_;
	}

	// TipLayer.as:97-104
	private function onTipHide(param1:TipEvent):Void {
		this.remove();
		if (this.m_timer != null) {
			this.m_timer.stop();
		}
	}

	// TipLayer.as:106-115（init：BaseLayer.onAddedToStage 后走一次）
	override private function init():Void {
		super.init();
		m_msgCenter.addEventListener(TipEvent.TIP_SHOW, this.onTipShow, false, 0, true);
		m_msgCenter.addEventListener(TipEvent.TIP_HIDE, this.onTipHide, false, 0, true);
		m_msgCenter.addEventListener(TipEvent.TIP_UPDATE, this.onTipUpdate, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, this.stageMove, false, 0, true);
		this.m_timer = new Timer(300, 1);
		this.m_timer.addEventListener(TimerEvent.TIMER, this.onTimer, false, 0, true);
	}

	// TipLayer.as:117-124
	private function stageMove(param1:MouseEvent):Void {
		if (this.m_tip != null) {
			this.m_tip.mX = param1.stageX;
			this.m_tip.mY = param1.stageY;
		}
	}

	// TipLayer.as:126-146（onTimer：300ms 到点建 tip 并装载）
	private function onTimer(param1:TimerEvent):Void {
		if (this.m_waitTip == "") {
			return;
		}
		if (this.m_tip == null || this.m_tip.tipName != this.m_waitTip) {
			this.m_tip = this.getTip(this.m_waitTip);
			this.m_waitTip = "";
			if (this.m_tip != null) {
				this.addChild(this.m_tip.displayObject);
				this.m_tip.data = this.m_waitArg;
				this.m_tip.tX = this.m_waitTX;
				this.m_tip.tY = this.m_waitTY;
				this.m_tip.mX = mouseX;
				this.m_tip.mY = mouseY;
			}
		}
	}

	// TipLayer.as:148-160（tX/tY 是 Number，m_waitTX:int 落位即 AS3 隐式截断）
	private function onTipShow(param1:TipEvent):Void {
		this.remove();
		this.m_waitTip = param1.tipType;
		this.m_waitArg = param1.tipArgument;
		this.m_waitTX = Std.int(param1.tX);
		this.m_waitTY = Std.int(param1.tY);
		if (this.m_timer != null) {
			this.m_timer.reset();
			this.m_timer.start();
		}
	}

	// TipLayer.as:162-173
	private function onTipUpdate(param1:TipEvent):Void {
		if (this.m_tip == null) {
			return;
		}
		if (this.m_tip.tipName != param1.tipType) {
			return;
		}
		this.m_tip.data = param1.tipArgument;
	}
}
