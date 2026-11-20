package module.uitools.widgets;

import com.qzone.qui.styles.Style;
import openfl.display.MovieClip;
import openfl.display.Sprite;

/**
 * module.uitools.widgets.ToolBase —— ToolBase.as 逐句对应（issue #9）。
 * 工具按钮基类：enabled 置灰走 Style.getDisableFilter，forbidden 挂角标。
 */
class ToolBase extends Sprite {
	// ToolBase.as:10
	private var _enabled:Bool = true;

	// ToolBase.as:12
	private var _tipText:String = "";

	// ToolBase.as:14
	private var _forbiddenMc:MovieClip;

	// ToolBase.as:16-19
	public function new() {
		super();
	}

	// ToolBase.as:21-24
	public var enabled(get, set):Bool;

	private function get_enabled():Bool {
		return this._enabled;
	}

	// ToolBase.as:36-47
	private function set_enabled(param1:Bool):Bool {
		this._enabled = param1;
		if (!this._enabled) {
			// Array<Dynamic> → filters 的数组合变，cast 对齐（BackgroundScreen 先例）
			this.filters = cast Style.getDisableFilter();
		} else {
			this.filters = null;
		}
		return param1;
	}

	// ToolBase.as:26-29
	public var tipText(get, set):String;

	private function get_tipText():String {
		return this._tipText;
	}

	// ToolBase.as:31-34
	private function set_tipText(param1:String):String {
		this._tipText = param1;
		return param1;
	}

	// ToolBase.as:49-65（forbidden：挂/摘禁用角标；原版 `Boolean(this._forbiddenMc)`
	// 对象真值 → 非空判定）
	public function forbidden(param1:Bool, param2:MovieClip = null):Void {
		if (param1) {
			if (this._forbiddenMc == null) {
				this._forbiddenMc = param2;
				this._forbiddenMc.x = this.width - this._forbiddenMc.width + 5;
				this._forbiddenMc.y = this.height - this._forbiddenMc.height;
			}
			this.addChild(this._forbiddenMc);
		} else if (this._forbiddenMc != null && this.contains(this._forbiddenMc)) {
			this.removeChild(this._forbiddenMc);
		}
	}
}
