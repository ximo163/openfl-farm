package framework.layers;

import common.Consts;
import common.view.floating.FloatControl;
import common.view.floating.FloatingBase;
import events.FloatingEvent;
import framework.base.BaseLayer;
import interfaces.IMsgCenter;
import openfl.errors.ArgumentError;

/**
 * framework.layers.FloatingLayer —— FloatingLayer.as 逐句对应（issue #9）。
 * 飘字层：FLOATING_OPEN/CLOSE 监听 + FloatControl 类注册表实例化，#9 飘字
 * 片（HarvestAnimation/AddMoneyFloating/AddExpFloating 等）的宿主。#7 时是
 * 闭包 stub（只保建层形态），飘字行为按其头注「随飘字片接入」——本条即接入。
 */
@:keep
class FloatingLayer extends BaseLayer {
	// FloatingLayer.as:12
	private var m_ctrl:FloatControl;

	// FloatingLayer.as:16-27（null 参抛 ArgumentError）
	public function new(param1:FloatControl) {
		if (param1 != null) {
			super(param1.getMsgControl());
			mouseEnabled = false;
			mouseChildren = false;
			this.name = Consts.LAYER_FLOATING;
			this.m_ctrl = param1;
			return;
		}
		throw new ArgumentError("Null parameter");
	}

	// FloatingLayer.as:31-36（init：挂 FloatingEvent 监听——ADDED_TO_STAGE 后
	// 走 BaseLayer.onAddedToStage）
	override private function init():Void {
		super.init();
		m_msgCenter.addEventListener(FloatingEvent.FLOATING_OPEN, this.floatingOpen, false, 0, true);
		m_msgCenter.addEventListener(FloatingEvent.FLOATING_CLOSE, this.floatingClose, false, 0, true);
	}

	// FloatingLayer.as:38-50
	private function floatingClose(param1:FloatingEvent):Void {
		var _loc2_:String = param1.floating;
		if (_loc2_.length == 0) {
			return;
		}
		var _loc3_:FloatingBase = this.findFloat(_loc2_, param1.fid);
		if (_loc3_ != null) {
			this.removeChild(_loc3_);
		}
	}

	// FloatingLayer.as:52-73
	private function floatingOpen(param1:FloatingEvent):Void {
		if (param1.floating == null) {
			return;
		}
		var _loc2_:Int = param1.fid;
		var _loc3_:FloatingBase = this.findFloat(param1.floating, _loc2_);
		if (_loc3_ != null) {
			_loc3_.start(param1.data);
			return;
		}
		if (this.m_ctrl == null || m_msgCenter == null) {
			return;
		}
		var _loc4_:Class<Dynamic> = this.m_ctrl.getClass(param1.floating);
		if (_loc4_ == null) {
			return;
		}
		// `new _loc4_(m_msgCenter)`：变量型 Class 反射构造 → Type.createInstance
		//（同 BaseArrayParser 的处理）
		var _loc5_:Dynamic = Type.createInstance(_loc4_, [m_msgCenter]);
		_loc3_ = cast _loc5_;
		_loc3_.start(param1.data);
		addChild(_loc3_);
	}

	// FloatingLayer.as:75-93
	private function findFloat(param1:String, param2:Int):FloatingBase {
		if (param1 == "" || param2 < 0) {
			return null;
		}
		var _loc3_:FloatingBase = null;
		var _loc4_:Int = 0;
		while (_loc4_ < numChildren) {
			var _loc4d:Dynamic = getChildAt(_loc4_);
			if (Std.isOfType(_loc4d, FloatingBase)) {
				_loc3_ = cast _loc4d;
				if (_loc3_.floatName == param1) {
					return _loc3_;
				}
			}
			_loc4_++;
		}
		return null;
	}

	// FloatingLayer.as:95-98
	public function getMsgCenter():IMsgCenter {
		return m_msgCenter;
	}
}
