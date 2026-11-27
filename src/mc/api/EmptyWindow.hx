package mc.api;

import common.MaterialLib;
import mc.view.common.BaseWindow;
import openfl.display.Sprite;

/**
 * mc.api.EmptyWindow —— EmptyWindow.as 逐句对应（issue #87「API」片）。空窗
 * 壳：ctor 按 param1 取 titleIMG 类 + 记宽高，setContent 装内容并把
 * windowName 拨为内容 name，init 把 _content 挂树，onScale 跟 EvtAPI 载荷
 * 宽高改窗尺寸。
 * legacy/decompiled/Master2_v_142/scripts/mc/api/EmptyWindow.as。
 */
@:keep
class EmptyWindow extends BaseWindow {
	// EmptyWindow.as:10
	private var _content:Sprite;

	// EmptyWindow.as:12-18
	public function new(param1:String, param2:Int, param3:Int) {
		super();
		titleIMG = MaterialLib.getInstance().getClass(param1);
		width = param2;
		height = param3;
	}

	// EmptyWindow.as:20-23
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		addChild(this._content);
	}

	// EmptyWindow.as:25-29（`param1.data["width"]`——Dynamic 键取走
	// Reflect.field；赋进 width/height 是 Number 属性直收）
	private function onScale(param1:EvtAPI):Void {
		width = Reflect.field(param1.data, "width");
		height = Reflect.field(param1.data, "height");
	}

	// EmptyWindow.as:31-35
	public function setContent(param1:Sprite):Void {
		this._content = param1;
		windowName = this._content.name;
	}
}
