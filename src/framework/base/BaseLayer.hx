package framework.base;

import interfaces.IMsgCenter;
import openfl.display.Sprite;
import openfl.events.Event;

// framework.base.BaseLayer —— BaseLayer.as 逐句对应。
class BaseLayer extends Sprite {
	// BaseLayer.as:10
	private var m_msgCenter:IMsgCenter; // AS3 protected → Haxe private（子类可见）

	// BaseLayer.as:12-17
	public function new(param1:IMsgCenter) {
		super();
		this.m_msgCenter = param1;
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
	}

	// BaseLayer.as:19-23
	private function onAddedToStage(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this.init();
	}

	// BaseLayer.as:25-27
	private function init():Void {}
}
