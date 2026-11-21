package mc.view.main.leftInfo;

import common.MaterialLib;
import openfl.display.MovieClip;
import mc.view.farm.toolBar.ToolBase;

/**
 * mc.view.main.leftInfo.PostIcon —— PostIcon.as 逐句对应（issue #19）。
 * 公告入口图标：与 MsgIcon 同构（原版即两份雷同小类，不合并）。
 */
@:keep
class PostIcon extends ToolBase {
	private var _icon:MovieClip;

	public function new() {
		super();
		this._icon = cast MaterialLib.getInstance().getMaterial("PostIcon");
		this._icon.gotoAndStop(1);
		addChild(this._icon);
		buttonMode = true;
		useHandCursor = true;
	}

	// PostIcon.as:22-25
	public function stopIcon():Void {
		this._icon.gotoAndStop(1);
	}

	// PostIcon.as:27-30
	public function playIcon():Void {
		this._icon.play();
	}
}
