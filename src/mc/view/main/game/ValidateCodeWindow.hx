package mc.view.main.game;

import common.MaterialLib;
import mc.control.Command;
import mc.view.common.AddButtonWindow;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.TextEvent;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * mc.view.main.game.ValidateCodeWindow —— ValidateCodeWindow.as 逐句对应
 * （issue #87「游戏窗」片）。图形验证码窗：init 取 "ValidateCodeContent"
 * 素材摆位（y=_headHeight+_padding、x=_padding），input_txt 焦点进出切
 * 占位文本与边框色，renew_txt LINK 换图（imgrequest.url 置随机串重载
 * Loader），KEY_UP 13 或确定钮把 lipiT.text 送 mainCommand.validateCode
 * 后关窗。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/game/ValidateCodeWindow.as。
 *
 * PORT-NOTE(跨片依赖)：MainCommand.validateCode（控制/命令片）在本片开工
 * 时 stub 无签名面——按原样直引，所属片充真身后编译链闭合（本轮并行片
 * 既定做法）。
 */
@:keep
class ValidateCodeWindow extends AddButtonWindow {
	// ValidateCodeWindow.as:18。PORT-NOTE(shadow)：原类以 private var
	// _headHeight:int=30 遮蔽基类链 LipiPanel._headHeight（AS3 private 不进
	// 子类作用域，两个槽互不相干；本类 init 摆位用的是自己的 30）。Haxe
	// private 对子类可见、同名禁绝重定义——改名 m_headHeight 拆槽，
	// WelcomeTaskWindow.hx m_mode 同款先例
	private var m_headHeight:Int = 30;

	// ValidateCodeWindow.as:20-30
	private var imgrequest:URLRequest = new URLRequest();
	private var postText:TextField;
	private var _text:String;
	private var img_loader:Loader;
	private var _padding:Int = 20;
	private var lipiT:TextField;

	// ValidateCodeWindow.as:32-39
	public function new() {
		super();
		width = 320;
		height = 250;
		mode = true;
		titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
	}

	// ValidateCodeWindow.as:41-47
	private function _KEY_UP(param1:KeyboardEvent):Void {
		if (param1.charCode == 13) {
			this.confirmFn();
		}
	}

	// ValidateCodeWindow.as:49-52
	private function cancelFn():Void {
		closeHandler();
	}

	// ValidateCodeWindow.as:54-61
	private function confirmFn():Void {
		if (this.lipiT.text.length > 0) {
			Command.getInstance().mainCommand.validateCode(this.lipiT.text);
			closeHandler();
		}
	}

	// ValidateCodeWindow.as:63-70/:123-126
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

	// ValidateCodeWindow.as:72-77
	private function imgRenew(param1:TextEvent):Void {
		this.img_loader.unload();
		this.imgrequest.url = "" + Math.random();
		this.img_loader.load(this.imgrequest);
	}

	// ValidateCodeWindow.as:79-121
	// PORT-NOTE(as 语义)：`getMaterial(...) as Sprite` / `getChildByName(...) as TextField`
	// ——AS3 as 失配得 null，isOfType 门 + 直取等价；content null 门是原文有
	// 的 `if(content)` 守卫（素材缺失整个装配段跳过）
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		var renew_txt:TextField = null;
		var img_mc:Sprite = null;
		var _content:Dynamic = MaterialLib.getInstance().getMaterial("ValidateCodeContent");
		var content:Sprite = Std.isOfType(_content, Sprite) ? cast _content : null;
		if (content != null) {
			content.y = this.m_headHeight + this._padding;
			content.x = this._padding;
			addChild(content);
			addButton("确定", "ButtonOrange", 65, 25, this.confirmFn);
			this.addEventListener(KeyboardEvent.KEY_UP, this._KEY_UP);
			super.init(param1);
			var _postText:Dynamic = content.getChildByName("postText");
			this.postText = Std.isOfType(_postText, TextField) ? cast _postText : null;
			var _lipiT:Dynamic = content.getChildByName("input_txt");
			this.lipiT = Std.isOfType(_lipiT, TextField) ? cast _lipiT : null;
			this.lipiT.borderColor = 3381759;
			this.lipiT.defaultTextFormat = new TextFormat("Verdana", 12, 10855845, null, null, null, null, null, "left");
			this.lipiT.text = "请输入图形验证码";
			this.lipiT.maxChars = 8;
			this.lipiT.restrict = "a-z A-Z 0-9";
			this.lipiT.addEventListener(FocusEvent.FOCUS_IN, function(param1:FocusEvent):Void {
				lipiT.text = "";
				lipiT.defaultTextFormat = new TextFormat("Verdana", 12, 3355443, null, null, null, null, null, "left");
			});
			this.lipiT.addEventListener(FocusEvent.FOCUS_OUT, function(param1:FocusEvent):Void {
				if (lipiT.text == "") {
					lipiT.borderColor = 3381759;
					lipiT.defaultTextFormat = new TextFormat("Verdana", 12, 10855845, null, null, null, null, null, "left");
					lipiT.text = "请输入图形验证码";
				}
			});
			this.stage.focus = this.lipiT;
			var _renew_txt:Dynamic = content.getChildByName("renew_txt");
			renew_txt = Std.isOfType(_renew_txt, TextField) ? cast _renew_txt : null;
			renew_txt.addEventListener(TextEvent.LINK, this.imgRenew);
			var _img_mc:Dynamic = content.getChildByName("img_mc");
			img_mc = Std.isOfType(_img_mc, Sprite) ? cast _img_mc : null;
			this.img_loader = new Loader();
			img_mc.addChild(this.img_loader);
			this.imgRenew(null);
		}
	}

	// ValidateCodeWindow.as:128-137（`param1["code"] == 1`——Dynamic 与数字
	// 字面量的松等比较走 As3.floatOf（lessons #35），原文 code 为 JSON 数值
	// 但按仓内防线统一处理；`!= null` 键缺位守卫同原文）
	private function getPostDataFn(param1:Dynamic):Void {
		if (shim.As3.floatOf(Reflect.field(param1, "code")) == 1) {
			if (Reflect.field(param1, "content") != null) {
				this.text = Reflect.field(param1, "content");
			}
		}
	}
}
