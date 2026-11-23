package framework.layers;

import common.Consts;
import common.view.cursor.CursorControl;
import framework.base.BaseLayer;
import openfl.errors.ArgumentError;

/**
 * framework.layers.CursorLayer —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 光标层（CursorEvent 驱动、隐藏系统鼠标、光标 MovieClip 跟随，CursorLayer.as
 * 203 loc）属于通用视图的光标片；这里只保构造形态（super(ctrl.getMsgCenter())、
 * mouseEnabled/mouseChildren = false、name = LAYER_CURSOR、null 参抛
 * ArgumentError）让 FarmStage 建层编译，光标行为随光标片接入。
 */
@:keep
class CursorLayer extends BaseLayer {
	// CursorLayer.as:13
	private var m_cursorCtrl:CursorControl;

	// CursorLayer.as:17
	private var m_currentCursor:Dynamic;

	// CursorLayer.as:19-33
	public function new(param1:CursorControl) {
		if (param1 != null) {
			super(param1.getMsgCenter());
			this.m_cursorCtrl = param1;
			mouseEnabled = false;
			mouseChildren = false;
			this.name = Consts.LAYER_CURSOR;
			return;
		}
		throw new ArgumentError("Null parameter");
	}

	// CursorLayer.as:35+（init/光标装载：光标片翻译）
	override private function init():Void {
		super.init();
	}

	// CursorLayer.as:49-56（remove：摘除当前光标并置空，issue #43 光标片翻译）
	private function remove():Void {
		throw new openfl.errors.Error("not implemented");
	}

	// CursorLayer.as:123-139（setPosition：CROPSEED 光标按自身宽高居中，
	// 其余光标直接落位，issue #43 光标片翻译）
	private function setPosition(param1:Int, param2:Int):Void {
		throw new openfl.errors.Error("not implemented");
	}
}
