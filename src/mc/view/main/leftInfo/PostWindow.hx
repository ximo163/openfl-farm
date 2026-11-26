package mc.view.main.leftInfo;

import common.MaterialLib;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import mc.view.common.AddButtonWindow;
import shim.As3;

/**
 * mc.view.main.leftInfo.PostWindow —— PostWindow.as 逐句对应（issue #19）。
 * 公告窗：正文超文本 + 单个「确定」钮，点钮或点链接都关窗。
 */
@:keep
class PostWindow extends AddButtonWindow {
	private var _text:String = "";

	private var postText:TextField;

	public function new() {
		super();
		width = 370;
		height = 280;
		mode = true;
		titleIMG = MaterialLib.getInstance().getClass("NoticeWindowTitle");
	}

	// PostWindow.as:25-43
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		this.postText = new TextField();
		this.postText.wordWrap = true;
		this.postText.multiline = true;
		var _loc1_:TextFormat = new TextFormat("Verdana");
		_loc1_.leading = 4;
		this.postText.defaultTextFormat = _loc1_;
		this.postText.y = 45;
		this.postText.x = 15;
		this.postText.width = 340;
		this.postText.height = 200;
		this.postText.htmlText = As3.or(this.text, "");
		this.postText.selectable = false;
		this.postText.addEventListener(TextEvent.LINK, this._LINK);
		addChild(this.postText);
		addButton("确定", "ButtonOrange", 65, 25, this.confirmFn);
		super.init(param1);
	}

	// PostWindow.as:45-57
	public var text(get, set):String;

	private function set_text(param1:String):String {
		this._text = param1;
		if (this.postText != null) {
			this.postText.text = param1;
		}
		return param1;
	}

	private function get_text():String {
		return this._text;
	}

	// PostWindow.as:59-68
	private function getPostDataFn(param1:Dynamic):Void {
		if (As3.floatOf(Reflect.field(param1, "code")) == 1) {
			if (Reflect.field(param1, "content") != null) {
				this.text = Reflect.field(param1, "content");
			}
		}
	}

	// PostWindow.as:70-73
	private function _LINK(param1:TextEvent):Void {
		this.closeHandler();
	}

	// PostWindow.as:75-78
	private function confirmFn():Void {
		this.closeHandler();
	}
}
