package mc.api;

import mc.view.common.BaseWindow;
import openfl.display.Sprite;
import openfl.errors.Error;

/**
 * mc.api.EmptyWindow —— EmptyWindow.as 的签名面 stub（原类 37 loc，issue
 * #87「API」片充真身）。空窗壳：ctor 按 param1 取 titleIMG 类 + 记宽高，
 * setContent 装内容并把 windowName 拨为内容 name，init 把 _content 挂树，
 * onScale 跟 EvtAPI 载荷宽高改窗尺寸。成员签名逐字取自反编译原文，方法体
 * 随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/api/EmptyWindow.as。
 */
@:keep
class EmptyWindow extends BaseWindow {
	// EmptyWindow.as:10
	private var _content:Sprite;

	// EmptyWindow.as:12-18（ctor 读 MaterialLib 取 titleIMG——有依赖副作用，
	// 入 stub 掷）
	public function new(param1:String, param2:Int, param3:Int) {
		super();
		throw new Error("not implemented");
	}

	// EmptyWindow.as:20-23
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		throw new Error("not implemented");
	}

	// EmptyWindow.as:25-29（EvtAPI 为根包事件类，src/EvtAPI.hx 已有真身）
	private function onScale(param1:EvtAPI):Void {
		throw new Error("not implemented");
	}

	// EmptyWindow.as:31-35
	public function setContent(param1:Sprite):Void {
		throw new Error("not implemented");
	}
}
