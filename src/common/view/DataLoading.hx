package common.view;

import com.qzone.qfa.managers.ResourceManager;
import events.ViewEvent;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 * common.view.DataLoading —— DataLoading.as 逐句对应（issue #18 qui 收尾：
 * 通用视图片）。数据加载转圈层：visible=true 挂 DataLoading_mc 并 play，
 * false 时 stop 摘除；errorText 覆盖显示 HTML 错误文案（居中），链接点击
 * 转 ViewEvent.LINK_CLICK 冒泡。
 */
@:keep
class DataLoading extends Sprite {
	// DataLoading.as:15-19
	private var _errorTextField:TextField;

	private var _dataLoading:MovieClip;

	private var _errorText:String;

	// :21-30（DataLoading_mc 是根包符号 shim，dceAnchor 锚住）
	public function new() {
		super();
		this._dataLoading = ResourceManager.gi().getClassInstance("DataLoading_mc");
		if (this._dataLoading != null) {
			this._dataLoading.stop();
		}
		this._errorText = "";
	}

	// :32-51 + :99-102（AS3 public get/set errorText 对）
	public var errorText(get, set):String;

	private function set_errorText(param1:String):String {
		if (param1 == null || param1 == "") {
			return param1;
		}
		this._errorText = param1;
		if (this._errorTextField == null) {
			this.createTextField();
		}
		this._errorTextField.htmlText = param1;
		this._errorTextField.visible = true;
		this._errorTextField.x = -this._errorTextField.textWidth / 2;
		this._errorTextField.y = -this._errorTextField.textHeight / 2;
		if (this._dataLoading != null) {
			this._dataLoading.visible = false;
		}
		return param1;
	}

	// :53-80（覆写显示属性 visible 的 setter：挂/摘转圈剪辑）
	override private function set_visible(param1:Bool):Bool {
		super.set_visible(param1);
		if (this._errorTextField != null) {
			this._errorTextField.visible = false;
		}
		if (param1 == true) {
			if (this._dataLoading != null) {
				if (contains(this._dataLoading) == false) {
					addChild(this._dataLoading);
				}
				this._dataLoading.play();
				this._dataLoading.visible = true;
			}
		} else if (this._dataLoading != null) {
			this._dataLoading.stop();
			if (contains(this._dataLoading) == true) {
				removeChild(this._dataLoading);
			}
		}
		return param1;
	}

	// :82-87
	private function linkClick(param1:TextEvent):Void {
		var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
		_loc2_.data = param1.text;
		dispatchEvent(_loc2_);
	}

	// :89-97
	private function createTextField():Void {
		this._errorTextField = new TextField();
		this._errorTextField.defaultTextFormat = new TextFormat("Verdana");
		this._errorTextField.autoSize = TextFieldAutoSize.LEFT;
		this._errorTextField.visible = false;
		addChild(this._errorTextField);
		this._errorTextField.addEventListener(TextEvent.LINK, this.linkClick);
	}

	// :99-102
	private function get_errorText():String {
		return this._errorText;
	}
}
