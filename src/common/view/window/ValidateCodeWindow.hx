package common.view.window;

import common.Consts;
import common.Language;
import common.misc.Utils;
import openfl.display.DisplayObjectContainer;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.TextEvent;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;

/**
 * common.view.window.ValidateCodeWindow —— ValidateCodeWindow.as 逐句对应
 * （issue #41 替换 #7 的闭包 stub）。图形验证码输入窗：ValidateCodeContent
 * 素材做窗体（提示文/输入框/验证码图/换一张），onOK 过 /^[a-z0-9]*$/ig 门
 * 后关窗并回调验证码文本。
 */
@:keep
class ValidateCodeWindow extends AddButtonWindow {
	// ValidateCodeWindow.as:22
	private var imgrequest:URLRequest;

	// ValidateCodeWindow.as:24
	private var _text:String;

	// ValidateCodeWindow.as:26
	private var img_loader:Loader;

	// ValidateCodeWindow.as:28
	private var lipiT:TextField;

	// ValidateCodeWindow.as:30（Function → Dynamic）
	private var _callback:Dynamic;

	// ValidateCodeWindow.as:32（const → static final）
	private static final INPUT_TIP:String = "输入图形验证码";

	// ValidateCodeWindow.as:34
	private var postText:TextField;

	// ValidateCodeWindow.as:36（const → static final）
	private static final HEADHEIGTH:Int = 30;

	// ValidateCodeWindow.as:38（const → static final）
	private static final PADDING:Int = 20;

	// ValidateCodeWindow.as:40-53
	public function new(param1:interfaces.IMsgCenter) {
		super(param1);
		width = 320;
		height = 250;
		mode = true;
		title = this.INPUT_TIP;
		windowName = Consts.WINDOW_NAME_VALIDATE;
		this.img_loader = null;
		this.imgrequest = new URLRequest();
		this.postText = null;
		this.lipiT = null;
		this._callback = null;
	}

	// ValidateCodeWindow.as:55-73。`"" + Math.random()` 的 Number→字符串
	// 照 AS3 显式 Std.string
	private function onOK():Void {
		var _loc1_:String = this.lipiT.text;
		if (_loc1_ == "") {
			return;
		}
		var _loc2_:EReg = ~/^[a-z0-9]*$/ig;
		if (_loc2_.match(_loc1_) == false) {
			return;
		}
		this.removePicture();
		super.close();
		if (this._callback != null) {
			this._callback(_loc1_);
		}
	}

	// ValidateCodeWindow.as:75-79。FFDec 的 `super.panelTitle` 是父类私有
	// 字段的冗余前缀，panelTitle 即同一对象
	override private function setSize():Void {
		super.setSize();
		panelTitle.x = (this.width - panelTitle.width) * 0.5;
	}

	// ValidateCodeWindow.as:81-90
	private function imgRenew(param1:TextEvent):Void {
		if (this.img_loader == null) {
			return;
		}
		this.img_loader.unload();
		this.imgrequest.url = Std.string(Math.random());
		this.img_loader.load(this.imgrequest);
	}

	// ValidateCodeWindow.as:92-107
	private function loadCodePicture():Void {
		var _loc1_:DisplayObjectContainer = Std.isOfType(getChildByName("__content__"),
			DisplayObjectContainer) ? cast(getChildByName("__content__"), DisplayObjectContainer) : null;
		if (_loc1_ == null) {
			return;
		}
		this.removePicture();
		this.img_loader = new Loader();
		this.imgRenew(null);
		var _loc2_:Sprite = Std.isOfType(_loc1_.getChildByName("img_mc"),
			Sprite) ? cast(_loc1_.getChildByName("img_mc"), Sprite) : null;
		if (_loc2_ != null) {
			_loc2_.addChild(this.img_loader);
		}
	}

	// ValidateCodeWindow.as:109-150。AS3 的匿名闭包原样翻成局部函数表达式
	// （捕获 lipiT/INPUT_TIP 等价于实例域捕获）
	override private function init():Void {
		var content:Sprite = null;
		var renew_txt:TextField = null;
		content = Std.isOfType(Utils.getMaterial("ValidateCodeContent"),
			Sprite) ? cast(Utils.getMaterial("ValidateCodeContent"), Sprite) : null;
		if (content != null) {
			content.y = this.HEADHEIGTH + this.PADDING;
			content.x = this.PADDING;
			content.name = "__content__";
			addChild(content);
			addButton(Language.L["确定"], "ButtonOrange", 65, 25, this.onOK);
			this.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
			super.init();
			this.postText = Std.isOfType(content.getChildByName("postText"),
				TextField) ? cast(content.getChildByName("postText"), TextField) : null;
			this.lipiT = Std.isOfType(content.getChildByName("input_txt"),
				TextField) ? cast(content.getChildByName("input_txt"), TextField) : null;
			this.lipiT.defaultTextFormat = new TextFormat("Verdana", 12, 10855845, null, null, null, null, null,
				TextFormatAlign.LEFT);
			this.lipiT.text = this.INPUT_TIP;
			this.lipiT.maxChars = 8;
			this.lipiT.restrict = "a-zA-Z0-9";
			this.lipiT.addEventListener(FocusEvent.FOCUS_IN, function(param1:FocusEvent):Void {
				if (lipiT.text == INPUT_TIP) {
					lipiT.text = "";
				}
				lipiT.defaultTextFormat = new TextFormat("Verdana", 12, 3355443, null, null, null, null, null,
					TextFormatAlign.LEFT);
			});
			this.lipiT.addEventListener(FocusEvent.FOCUS_OUT, function(param1:FocusEvent):Void {
				if (lipiT.text == "") {
					lipiT.borderColor = 3381759;
					lipiT.defaultTextFormat = new TextFormat("Verdana", 12, 10855845, null, null, null, null, null,
						TextFormatAlign.LEFT);
					lipiT.text = INPUT_TIP;
				}
			});
			this.stage.focus = this.lipiT;
			renew_txt = Std.isOfType(content.getChildByName("renew_txt"),
				TextField) ? cast(content.getChildByName("renew_txt"), TextField) : null;
			renew_txt.addEventListener(TextEvent.LINK, this.imgRenew);
		}
	}

	// ValidateCodeWindow.as:152-156
	override private function onClose(param1:Event):Void {
		this.removePicture();
		super.onClose(param1);
	}

	// ValidateCodeWindow.as:158-165
	private function removePicture():Void {
		if (this.img_loader != null && this.img_loader.parent != null) {
			this.img_loader.parent.removeChild(this.img_loader);
			this.img_loader = null;
		}
	}

	// ValidateCodeWindow.as:167-174（AS3 setter 无返回值，Haxe 属性 setter
	// 返回入参）
	private function set_text(param1:String):String {
		this._text = param1;
		if (this.postText != null) {
			this.postText.text = param1;
		}
		return param1;
	}

	// ValidateCodeWindow.as:176-191
	override private function setData():Void {
		if (this.lipiT != null && this.lipiT.text != this.INPUT_TIP) {
			this.lipiT.text = "";
		}
		this.loadCodePicture();
		if (super.data != null && As3.hasProp(super.data, "callback")) {
			this._callback = Reflect.isFunction(Reflect.field(super.data,
				"callback")) ? Reflect.field(super.data, "callback") : null;
		} else {
			this._callback = null;
		}
	}

	// ValidateCodeWindow.as:193-196
	private function get_text():String {
		return this._text;
	}

	public var text(get, set):String;

	// ValidateCodeWindow.as:198-204
	private function onKeyUp(param1:KeyboardEvent):Void {
		if (param1.charCode == 13) {
			this.onOK();
		}
	}
}
