package common.view.window;

import com.qzone.utils.AlignUtil;
import interfaces.IMsgCenter;
import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import shim.As3;

/**
 * common.view.window.ContentWindow —— ContentWindow.as 逐句对应（issue #18
 * qui 收尾：通用窗口片）。自定义内容窗口：把外部 DisplayObjectContainer 挂
 * 进面板（对齐标题栏下沿），data 里的 width/height/title/yellowTip 驱动
 * 窗口尺寸与黄条排版。disableAnimation 恒真（PopUpLayer 据此跳过开关窗
 * 动效直接回调）。
 * PORT-NOTE: `_loc1_["width"] != undefined` —— AS3 null==undefined 宽松等，
 * 等价 Reflect.field(...) != null（Player.hx 先例）。
 */
@:keep
class ContentWindow extends AddButtonWindow {
	// ContentWindow.as:11-13
	private var _customContent:DisplayObjectContainer;

	private var _spaceHeight:Int;

	// :15-27
	public function new(param1:IMsgCenter, param2:String, param3:DisplayObjectContainer, param4:Int = 0,
			param5:Bool = false) {
		super(param1);
		windowName = param2;
		autoLayout = false;
		this._customContent = param3;
		this.name = param3.name;
		if (param5) {
			windowName = param3.name;
		}
		this._spaceHeight = param4;
	}

	// :29-32
	public var disableAnimation(get, never):Bool;

	private function get_disableAnimation():Bool {
		return true;
	}

	// :34-43
	private override function addedToLayer():Void {
		if (this._customContent != null) {
			this._customContent.scaleX = 1;
			this._customContent.scaleY = 1;
			this._customContent.y = panelTitle.height - this._spaceHeight;
			addChild(this._customContent);
		}
	}

	// :45-52
	private override function setSize():Void {
		super.setSize();
		if (panelTitle != null) {
			panelTitle.x = AlignUtil.middle(width, panelTitle.width);
		}
	}

	// :54-78
	private override function setData():Void {
		var _loc1_:Dynamic = this.data;
		if (_loc1_ == null) {
			return;
		}
		if (Reflect.field(_loc1_, "width") != null) {
			this.width = As3.intOf(Reflect.field(_loc1_, "width"));
		}
		if (Reflect.field(_loc1_, "height") != null) {
			this.height = As3.intOf(Reflect.field(_loc1_, "height"));
		}
		if (Reflect.field(_loc1_, "title") != null) {
			this.title = Reflect.field(_loc1_, "title");
		}
		if (Reflect.field(_loc1_, "yellowTip") != null
			&& Std.isOfType(Reflect.field(_loc1_, "yellowTip"), TextField)) {
			cast(Reflect.field(_loc1_, "yellowTip"), TextField).width = this.width - 4;
			cast(Reflect.field(_loc1_, "yellowTip"), TextField).x = 1;
		}
	}
}
