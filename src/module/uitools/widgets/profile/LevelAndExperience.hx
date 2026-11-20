package module.uitools.widgets.profile;

import com.qzone.qui.controls.Button;
import common.Consts;
import common.Language;
import common.misc.Utils;
import common.view.window.BaseWindow;
import interfaces.IMsgCenter;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * module.uitools.widgets.profile.LevelAndExperience —— LevelAndExperience.as
 * 逐句对应（issue #9）。等级与经验说明窗（WindowControl 注册名
 * LevelAndExp）：ButtonOrange 确定按钮 + LevelAndExperienss 素材文本。
 */
class LevelAndExperience extends BaseWindow {
	// LevelAndExperience.as:16
	private var m_actionBtn:Button;

	// LevelAndExperience.as:18
	private var m_text:openfl.display.Sprite;

	// LevelAndExperience.as:20-29
	public function new(param1:IMsgCenter = null) {
		super(param1);
		this.width = 455;
		this.height = 300;
		this.title = Reflect.field(Language.L, "等级和经验");
		this.windowName = Consts.WINDOW_NAME_LEVEL_EXP;
		this.m_actionBtn = null;
		this.m_text = null;
	}

	// LevelAndExperience.as:31-53（AS3 protected init → Haxe private，
	// 子类可见；override 锚在 UIComponent.init）
	private override function init():Void {
		if (this.m_actionBtn == null) {
			this.m_actionBtn = new Button();
			this.m_actionBtn.defaultSkin = Utils.getClass("ButtonOrange");
			this.m_actionBtn.text = Reflect.field(Language.L, "确定");
			this.m_actionBtn.width = 60;
			this.m_actionBtn.height = 25;
			this.m_actionBtn.x = (this.width - this.m_actionBtn.width) * 0.5;
			this.m_actionBtn.y = this.height - this.m_actionBtn.height - 15;
			this.addChild(this.m_actionBtn);
			this.m_actionBtn.addEventListener(MouseEvent.CLICK, this.onActionBtn);
		}
		if (this.m_text == null) {
			this.m_text = cast(Utils.getMaterial("LevelAndExperienss"), openfl.display.Sprite);
			this.m_text.y = 40;
			this.m_text.x = 20;
			this.m_text.mouseEnabled = false;
			this.addChild(this.m_text);
		}
	}

	// LevelAndExperience.as:55-58（原版 `super.close()`：close 在 TitleWindow
	// 链上为 protected，Haxe private 子类可见）
	private function onActionBtn(param1:Event):Void {
		super.close();
	}
}
