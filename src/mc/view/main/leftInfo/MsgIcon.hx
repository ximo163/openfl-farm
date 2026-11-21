package mc.view.main.leftInfo;

import common.MaterialLib;
import openfl.display.MovieClip;
import mc.view.farm.toolBar.ToolBase;

/**
 * mc.view.main.leftInfo.MsgIcon —— MsgIcon.as 逐句对应（issue #19）。
 * 站内信入口图标：新消息时 playIcon 循环闪、读完后 stopIcon 归位第 1 帧。
 */
@:keep
class MsgIcon extends ToolBase {
	private var _icon:MovieClip;

	public function new() {
		super();
		this._icon = cast MaterialLib.getInstance().getMaterial("MsgIcon");
		this._icon.gotoAndStop(1);
		addChild(this._icon);
		buttonMode = true;
		useHandCursor = true;
	}

	// MsgIcon.as:22-25
	public function stopIcon():Void {
		this._icon.gotoAndStop(1);
	}

	// MsgIcon.as:27-30
	public function playIcon():Void {
		this._icon.play();
	}
}
