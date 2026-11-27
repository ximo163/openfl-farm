package mc.view.common;

import common.MaterialLib;
import openfl.text.TextField;
import openfl.text.TextFormat;
import shim.As3;

/**
 * mc.view.common.HtmlTextWindow —— HtmlTextWindow.as 逐句对应（issue #87
 * 牧场「通用视图」片；#19 签名面 stub 充真身）。HTML 文本确认窗：
 * type 2/4/6 决定装「确定/取消」哪些钮，未显式设高时
 * height=textHeight+27+padding*2+45，关窗经 _closeFn(_detail) 回报
 * OK/CANCEL。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/HtmlTextWindow.as。
 *
 * PORT-NOTE（`this.textFormat || new TextFormat(...)`，:56）：AS3 对象
 * 真值短路——textFormat 为 null 取右值。As3.or 等价（对象非 null 即真）。
 * PORT-NOTE（`Language.L["取消"]`，:85）：L 是 Object 多语表、串键动态
 * 下标——cpp 禁 Dynamic 串键下标，统一 Reflect.field（lessons #8 通道）。
 * PORT-NOTE（`int(height/2-textHeight/2)`，:70）：AS3 int() 向零截断，
 * Std.int 等价。
 * PORT-NOTE（确定/取消钮的匿名闭包，:74-78/:82-86）：AS3 闭包捕获本
 * 实例写 _detail 再调 closeHandler——Haxe 闭包直译，this 绑定一致。
 */
@:keep
class HtmlTextWindow extends AddButtonWindow {
	// HtmlTextWindow.as:10-12
	public static final OK:Int = 2;
	public static final CANCEL:Int = 4;

	// HtmlTextWindow.as:14-32
	private var _closeFn:Dynamic;
	public var okLabel:String = "确定";
	private var _padding:Int;
	public var vMiddle:Bool = false;
	private var _text:String;
	private var _detail:Int;
	private var _txt:TextField;
	public var textFormat:TextFormat;
	private var _type:Int;
	public var isSetHeight:Bool = false;

	// HtmlTextWindow.as:34-45
	public function new(param1:String = "", param2:Int = 2, param3:Int = 12, param4:Dynamic = null) {
		super();
		this._text = param1;
		this._padding = param3;
		this._txt = new TextField();
		addChild(this._txt);
		this._type = param2;
		this._detail = CANCEL;
		this._closeFn = param4;
		titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle");
	}

	// HtmlTextWindow.as:47-51（先回报后上行——_closeFn 无 null 守卫，
	// 未传 closeFn 关窗 NPE 与原版一致）
	override private function closeHandler():Void {
		this._closeFn(this._detail);
		super.closeHandler();
	}

	// HtmlTextWindow.as:53-90
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		this._txt.selectable = false;
		this._txt.mouseWheelEnabled = false;
		this.textFormat = cast As3.or(this.textFormat, new TextFormat("Verdana", 12, 3355443));
		this.textFormat.leading = 6;
		this._txt.defaultTextFormat = this.textFormat;
		this._txt.wordWrap = true;
		this._txt.multiline = true;
		this._txt.autoSize = "left";
		this._txt.x = this._padding + 2;
		this._txt.y = 27 + this._padding;
		this._txt.htmlText = this._text;
		this._txt.width = width - (this._padding + 2) * 2;
		this._txt.defaultTextFormat = this.textFormat;
		if (!this.isSetHeight) {
			height = this._txt.textHeight + 27 + this._padding * 2 + 45;
		}
		if (this.vMiddle) {
			this._txt.y = Std.int(height / 2 - this._txt.textHeight / 2) - 13;
		}
		if (this._type == 2 || this._type == 6) {
			addButton(this.okLabel, "ButtonOrange", 68, 25, function():Void {
				this._detail = OK;
				this.closeHandler();
			});
		}
		if (this._type == 4 || this._type == 6) {
			addButton(Reflect.field(Language.L, "取消"), "ButtonBlue", 68, 25, function():Void {
				this._detail = CANCEL;
				this.closeHandler();
			});
		}
		super.init(param1);
	}
}
