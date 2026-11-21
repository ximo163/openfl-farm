package mc.view.common;

import common.MaterialLib;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import mc.view.ViewEvent;

/**
 * mc.view.common.DataLoading —— DataLoading.as（Master2 片，与 main3 的
 * common.view.DataLoading 同名不同类）逐句对应，issue #19 Master2 闭包顺手译。
 */
@:keep
class DataLoading extends Sprite {
	private var errorTextField:TextField;

	private var _dataLoading:MovieClip;

	private var _errorText:String = "";

	public function new() {
		super();
		this._dataLoading = cast MaterialLib.getInstance().getMaterial("DataLoading");
		this._dataLoading.stop();
	}

	// DataLoading.as:28-52
	override private function set_visible(param1:Bool):Bool {
		super.set_visible(param1);
		if (this.errorTextField != null) {
			this.errorTextField.visible = false;
		}
		if (param1) {
			if (!contains(this._dataLoading)) {
				addChild(this._dataLoading);
			}
			this._dataLoading.play();
			this._dataLoading.visible = true;
		} else {
			this._dataLoading.stop();
			if (contains(this._dataLoading)) {
				removeChild(this._dataLoading);
			}
		}
		return param1;
	}

	// DataLoading.as:54-68（原版连续两次给 errorTextField.x 赋值，照抄）
	public var errorText(get, set):String;

	private function set_errorText(param1:String):String {
		this._errorText = param1;
		if (this.errorTextField == null) {
			this.createTextField();
		}
		this.errorTextField.htmlText = param1;
		this._dataLoading.visible = false;
		this.errorTextField.visible = true;
		this.errorTextField.selectable = false;
		this.errorTextField.x = 0;
		this.errorTextField.x = -this.width / 2;
		this.errorTextField.y = -10;
		return param1;
	}

	// DataLoading.as:70-75
	private function linkClick(param1:TextEvent):Void {
		var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
		_loc2_.data = param1.text;
		dispatchEvent(_loc2_);
	}

	// DataLoading.as:77-85
	private function createTextField():Void {
		this.errorTextField = new TextField();
		this.errorTextField.defaultTextFormat = new TextFormat("Verdana");
		this.errorTextField.autoSize = TextFieldAutoSize.LEFT;
		this.errorTextField.visible = false;
		addChild(this.errorTextField);
		this.errorTextField.addEventListener(TextEvent.LINK, this.linkClick);
	}

	private function get_errorText():String {
		return this._errorText;
	}
}
