package mc.view.common;

import openfl.errors.Error;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * mc.view.common.HtmlTextWindow —— HtmlTextWindow.as 的签名面 stub（原类
 * 91 loc，issue #87「通用视图」片充真身）。HTML 文本确认窗：type 2/4/6
 * 决定装「确定/取消」哪些钮，未显式设高时 height=textHeight+27+padding*2+45，
 * 关窗经 _closeFn(_detail) 回报 OK/CANCEL。成员签名逐字取自反编译原文，
 * 方法体随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/HtmlTextWindow.as。
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

	// HtmlTextWindow.as:34-45（ctor 逐字入 stub：装 _txt、_detail 缺省
	// CANCEL、titleIMG 查表——MaterialLib 空表返回 null 不炸）
	public function new(param1:String = "", param2:Int = 2, param3:Int = 12, param4:Dynamic = null) {
		super();
		this._text = param1;
		this._padding = param3;
		this._txt = new TextField();
		addChild(this._txt);
		this._type = param2;
		this._detail = CANCEL;
		this._closeFn = param4;
		this.titleIMG = common.MaterialLib.getInstance().getClass("AlertWindowTitle");
	}

	// HtmlTextWindow.as:47-51
	override private function closeHandler():Void {
		throw new Error("not implemented");
	}

	// HtmlTextWindow.as:53-90（文本排版 + 高度公式 + 钮装配）
	override public function init(param1:openfl.geom.Rectangle = null):Void {
		throw new Error("not implemented");
	}
}
