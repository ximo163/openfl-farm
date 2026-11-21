package module.task.welcome;

import com.qzone.qui.controls.Button;
import com.qzone.utils.AlignUtil;
import common.Consts;
import common.misc.Utils;
import common.view.MaterialProxy;
import common.view.window.ConfirmWindow;
import interfaces.IMsgCenter;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/**
 * module.task.welcome.TaskOverWindow —— TaskOverWindow.as（181 loc）逐句对应
 * （issue #21）。任务完成领奖窗：direction 文案（_alertText）+ item 奖品横排
 * （MaterialProxy 图标 50px 等比缩放 + embedFontA 数字标签，每列宽 100）+
 * confirmFn 回调（WelcomeView 塞的 onNextTask/onTaskAllOver）；「全部完成」
 * 时经 confirmBtnText 换按钮文案并按长度切 120/64 宽。
 */
class TaskOverWindow extends ConfirmWindow {
	// TaskOverWindow.as:19
	private var _giftContent:Sprite;

	// TaskOverWindow.as:21-32
	public function new(param1:IMsgCenter) {
		super(param1);
		width = 360;
		height = 240;
		title = "完成任务";
		windowName = Consts.WINDOW_NAME_TASK_OVER;
		mode = true;
		_hideIcon = true;
		_confirmEnable = true;
		_confirmFn = null;
	}

	// TaskOverWindow.as:34-68
	private override function init():Void {
		if (_inited == true) {
			return;
		}
		_alertText = new TextField();
		_alertText.x = 20;
		_alertText.y = 20;
		_alertText.width = 315;
		_alertText.height = 40;
		_alertText.wordWrap = true;
		_alertText.defaultTextFormat = new TextFormat("Verdana", 14, 39423, true);
		addChild(_alertText);
		_confirmButton = new Button();
		_confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
		_confirmButton.width = 120;
		_confirmButton.height = 25;
		_confirmButton.y = height - 36;
		_confirmButton.text = "进行下一个任务";
		_confirmButton.addEventListener(MouseEvent.CLICK, confirmButtonClick);
		addChild(_confirmButton);
		_cancelButton = new Button();
		_cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
		_cancelButton.width = 64;
		_cancelButton.height = 25;
		_cancelButton.y = height - 36;
		_cancelButton.text = "取消";
		_cancelButton.addEventListener(MouseEvent.CLICK, cancelButtonClick);
		addChild(_cancelButton);
		this._giftContent = new Sprite();
		this._giftContent.x = 4;
		this._giftContent.y = 84;
		addChild(this._giftContent);
	}

	// TaskOverWindow.as:70-85（AS3 int 变量收 Number 表达式隐式截断 → Std.int）
	private override function setSize():Void {
		var _loc1_:Int = 0;
		super.setSize();
		if (_inited == true) {
			_loc1_ = Std.int((this.width - _confirmButton.width - _cancelButton.width - 20) * 0.5);
			_confirmButton.x = _loc1_;
			_cancelButton.x = _loc1_ + _confirmButton.width + 20;
			this._giftContent.x = (this.width - this._giftContent.width) * 0.5;
			if (panelTitle != null) {
				panelTitle.x = AlignUtil.middle(width, panelTitle.width);
			}
		}
	}

	// TaskOverWindow.as:87-91
	private override function addedToLayer():Void {
		super.addedToLayer();
		_inited = true;
	}

	// TaskOverWindow.as:93-111
	public var confirmBtnText(never, set):String;

	private function set_confirmBtnText(param1:String):String {
		if (param1 == null || param1 == "") {
			return param1;
		}
		if (_confirmButton != null) {
			_confirmButton.text = param1;
			if (param1.length > 2) {
				_confirmButton.width = 120;
			} else {
				_confirmButton.width = 64;
			}
		}
		return param1;
	}

	// TaskOverWindow.as:113-177。`super.data[...] != undefined` → Reflect
	// 判空；eNum 是 JSON 数字（haxe.Json.parse 后为 Int），AS3 在 htmlText
	// setter 边界隐式 String()，Haxe 的 Dynamic→String 赋值不做转换，裸 Int
	// 进 openfl HTMLParser 会抛异常，须显式 Std.string（同 ProfileHead.hx:253）
	private override function setData():Void {
		var _loc1_:Array<Dynamic> = null;
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		var _loc5_:Int = 0;
		var _loc6_:MaterialProxy = null;
		var _loc7_:Float = Math.NaN;
		var _loc8_:TextField = null;
		this.graphics.clear();
		if (Reflect.field(super.data, "direction") != null && Reflect.field(super.data, "direction") != "") {
			if (_alertText != null) {
				_alertText.text = Reflect.field(super.data, "direction");
			}
		}
		if (Reflect.field(super.data, "item") != null) {
			while (this._giftContent.numChildren > 0) {
				this._giftContent.removeChildAt(0);
			}
			_loc1_ = cast(Reflect.field(super.data, "item"), Array<Dynamic>);
			if (_loc1_ == null || _loc1_.length == 0) {
				return;
			}
			_loc2_ = 100;
			_loc3_ = _loc1_.length;
			_loc4_ = 0;
			_loc5_ = 0;
			while (_loc5_ < _loc3_) {
				_loc6_ = new MaterialProxy();
				_loc6_.setContent(Reflect.field(_loc1_[_loc5_], "eType"), Reflect.field(_loc1_[_loc5_], "eParam"));
				_loc7_ = 50 / _loc6_.width;
				_loc6_.scaleX = _loc7_;
				_loc6_.scaleY = _loc7_;
				this._giftContent.addChild(_loc6_);
				_loc6_.x = _loc4_ + (_loc2_ - _loc6_.width) * 0.5;
				_loc6_.y = 5;
				_loc8_ = new TextField();
				_loc8_.height = 40;
				_loc8_.wordWrap = true;
				_loc8_.htmlText = Std.string(Reflect.field(_loc1_[_loc5_], "eNum"));
				_loc8_.setTextFormat(new TextFormat("embedFontA", 20, 16737792, false, null, null, null, null, TextFormatAlign.CENTER));
				_loc8_.embedFonts = true;
				this._giftContent.addChild(_loc8_);
				_loc8_.x = _loc6_.x + (_loc6_.width - _loc8_.width) * 0.5;
				_loc8_.y = _loc6_.y + 60;
				_loc4_ += _loc2_;
				_loc5_++;
			}
		}
		if (Reflect.field(super.data, "confirmFn") != null) {
			_confirmFn = Reflect.field(super.data, "confirmFn");
		} else {
			_confirmFn = null;
		}
	}
}
