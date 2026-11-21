package mc.view.farm.toolBar;

import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.errors.IllegalOperationError;
import openfl.filters.ColorMatrixFilter;

/**
 * mc.view.farm.toolBar.ToolBase —— ToolBase.as 逐句对应（issue #19 Master2
 * 闭包顺手译）。工具条项基类：置灰走灰度 ColorMatrixFilter。
 */
@:keep
class ToolBase extends Sprite {
	private var _enabled:Bool = true;

	private var _tipText:String = "";

	private var _forbiddenMc:MovieClip;

	public function new() {
		super();
	}

	public var enabled(get, set):Bool;

	private function get_enabled():Bool {
		return this._enabled;
	}

	private function set_enabled(param1:Bool):Bool {
		this._enabled = param1;
		if (!this._enabled) {
			filters = [new ColorMatrixFilter([
				0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086,
				0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0
			])];
		} else {
			filters = null;
		}
		return param1;
	}

	public var tipText(get, set):String;

	private function get_tipText():String {
		return this._tipText;
	}

	private function set_tipText(param1:String):String {
		this._tipText = param1;
		return param1;
	}

	// ToolBase.as:32-35
	public function AddNewIconMC():Void {
		throw new IllegalOperationError("AddNewIconMC not supported!");
	}

	// ToolBase.as:55-71
	public function forbidden(param1:Bool, param2:MovieClip = null):Void {
		if (param1) {
			if (this._forbiddenMc == null) {
				this._forbiddenMc = param2;
				this._forbiddenMc.x = this.width - this._forbiddenMc.width + 5;
				this._forbiddenMc.y = this.height - this._forbiddenMc.height;
			}
			addChild(this._forbiddenMc);
		} else if (this._forbiddenMc != null && contains(this._forbiddenMc)) {
			removeChild(this._forbiddenMc);
		}
	}
}
