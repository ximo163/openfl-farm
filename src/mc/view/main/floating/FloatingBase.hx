package mc.view.main.floating;

import openfl.display.Sprite;

/**
 * mc.view.main.floating.FloatingBase —— FloatingBase.as 的最小编译 stub
 * （issue #86 范围外「飘字」子系统类的依赖占位：FloatingEvent 的类型形参
 * 需要它存在。真身归牧场拆分后续片的「飘字」子系统翻译——原文 30 行，
 * 本 stub 成员面照原文抄全：fid 存取 + start() 空实现，方法体本就如此，
 * 故本文件与真身等价）。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/floating/FloatingBase.as。
 */
@:keep
class FloatingBase extends Sprite {
	// FloatingBase.as:8
	private var _fid:Int = -1;

	// :10-13
	public function new() {
		super();
	}

	// :15-18/:24-27
	public var fid(get, set):Int;

	private function get_fid():Int {
		return this._fid;
	}

	private function set_fid(param1:Int):Int {
		this._fid = param1;
		return param1;
	}

	// :20-22（原文即空方法体）
	public function start():Void {}
}
