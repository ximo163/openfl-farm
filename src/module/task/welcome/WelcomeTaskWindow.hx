package module.task.welcome;

import com.qzone.qui.controls.Button;
import com.qzone.utils.AlignUtil;
import common.CommonData;
import common.Consts;
import common.Language;
import common.Settings;
import common.misc.Utils;
import common.view.window.ConfirmWindow;
import interfaces.IMsgCenter;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import shim.As3;

/**
 * module.task.welcome.WelcomeTaskWindow —— WelcomeTaskWindow.as（225 loc）
 * 逐句对应（issue #21）。任务窗口（领取 mode=0 双按钮 / 进行中 mode=1 单
 * 按钮 + 「(此任务进行中)」尾标）：任务插图按 id 取 fresherTask 库的
 * task&lt;id&gt; 符号（缺号经 rslManager.requestClass 按需拉库后 rslCallBack
 * 重取），窗高随插图高（&lt;155 固定 245 否则 +90）。init 建的按钮 CLICK 挂
 * super.confirmButtonClick——Haxe 不允许 super 方法取闭包，本类未覆写该
 * 方法、this. 与 super. 同一实现，等价改写（PORT-NOTE）。
 */
class WelcomeTaskWindow extends ConfirmWindow {
	// WelcomeTaskWindow.as:21
	private var _awokeText:TextField;

	// WelcomeTaskWindow.as:23
	private var _res:Sprite;

	// WelcomeTaskWindow.as:25。PORT-NOTE(shadow)：原类以 private var
	// _mode:int 遮蔽基类 BaseWindow._mode:Boolean 的存储位（AS3 private 不
	// 进子类作用域，两个 _mode 是互不相干的槽；本类从未碰基类 mode 属性的
	// 存储位）。Haxe private 对子类可见、同名异型字段禁绝重定义——改名
	// m_mode 拆槽，读写点与原类一一对应
	private var m_mode:Int;

	// WelcomeTaskWindow.as:27
	private var _id:Int;

	// WelcomeTaskWindow.as:29-40
	public function new(param1:IMsgCenter) {
		super(param1);
		mode = true;
		width = 360;
		height = 240;
		windowName = Consts.WINDOW_NAME_TASK_ACCEPT;
		this._res = null;
		this._id = -1;
		this._awokeText = null;
		this.m_mode = 0;
	}

	// WelcomeTaskWindow.as:42-57
	private override function setSize():Void {
		super.setSize();
		if (this.m_mode == 0) {
			_confirmButton.x = width * 0.5 - _confirmButton.width - 10;
		} else {
			_confirmButton.x = (width - _confirmButton.width) * 0.5;
		}
		if (panelTitle != null) {
			panelTitle.x = AlignUtil.middle(width, panelTitle.width);
		}
	}

	// WelcomeTaskWindow.as:59-112
	private function changeMode(param1:Int):Void {
		var _loc2_:DisplayObject = null;
		if (_inited == false) {
			return;
		}
		graphics.clear();
		this.m_mode = param1;
		if (param1 == 0) {
			_confirmButton.text = Reflect.field(Language.L, "接受");
			_confirmButton.visible = true;
			_cancelButton.visible = true;
			if (this._awokeText != null && this._awokeText.parent != null) {
				this._awokeText.parent.removeChild(this._awokeText);
			}
		} else {
			_confirmButton.text = Reflect.field(Language.L, "确定");
			_confirmButton.visible = true;
			_cancelButton.visible = false;
			if (this._awokeText == null) {
				this._awokeText = new TextField();
				this._awokeText.text = Reflect.field(Language.L, "(此任务进行中)");
				this._awokeText.selectable = false;
				this._awokeText.mouseEnabled = false;
				this._awokeText.width = 150;
				this._awokeText.height = 25;
				this._awokeText.setTextFormat(new TextFormat("Verdana", 14, 13369344, true));
			}
			if (this._res != null) {
				this._res.addChild(this._awokeText);
				_loc2_ = this._res.getChildAt(0);
				if (_loc2_ != null) {
					this._awokeText.x = _loc2_.x + _loc2_.width;
					this._awokeText.y = -3;
				}
			}
		}
		if (this.m_mode == 0) {
			_confirmButton.x = width * 0.5 - _confirmButton.width - 10;
		} else {
			_confirmButton.x = (width - _confirmButton.width) * 0.5;
		}
	}

	// WelcomeTaskWindow.as:114-163。`super.data[...] != undefined` →
	// Reflect 判空；`as int` → As3.intOf
	private override function setData():Void {
		var _loc2_:String = null;
		this.graphics.clear();
		if (Reflect.field(super.data, "title") != null) {
			this.title = Reflect.field(super.data, "title");
		}
		if (Reflect.field(super.data, "confirmFn") != null) {
			_confirmFn = Reflect.field(data, "confirmFn");
		} else {
			_confirmFn = null;
		}
		if (Reflect.field(super.data, "mode") != null) {
			this.changeMode(As3.intOf(Reflect.field(super.data, "mode")));
		}
		var _loc1_:Int = As3.intOf(Reflect.field(super.data, "id"));
		if (_loc1_ == this._id && this._res != null) {
			return;
		}
		if (_loc1_ >= 0) {
			if (this._res != null && this._res.parent != null) {
				this._res.parent.removeChild(this._res);
			}
			this._res = cast(Utils.getMaterial("task" + _loc1_), Sprite);
			if (this._res != null) {
				this._res.x = 20;
				this._res.y = 40;
				addChild(this._res);
				this.height = this._res.height < 155 ? 245 : this._res.height + 90;
			} else {
				_loc2_ = Settings.getInstance().getSecondUrl("fresherTask");
				if (_loc2_ != "") {
					CommonData.rslManager.requestClass("task" + _loc1_, this.rslCallBack, _loc2_);
				}
			}
			this._id = _loc1_;
		}
	}

	// WelcomeTaskWindow.as:165-189。`super.confirmButtonClick` 取闭包在
	// Haxe 非法（Cannot create closure on super method）；本类未覆写，
	// this. 与 super. 同一实现，等价（见类头注）
	private override function init():Void {
		if (_inited == true) {
			return;
		}
		_confirmButton = new Button();
		_confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
		_confirmButton.width = 64;
		_confirmButton.height = 25;
		_confirmButton.y = height - 30;
		_confirmButton.text = Reflect.field(Language.L, "接受");
		_confirmButton.addEventListener(MouseEvent.CLICK, this.confirmButtonClick);
		_confirmButton.visible = false;
		addChild(_confirmButton);
		_cancelButton = new Button();
		_cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
		_cancelButton.width = 64;
		_cancelButton.height = 25;
		_cancelButton.y = height - 30;
		_cancelButton.text = Reflect.field(Language.L, "取消");
		_cancelButton.addEventListener(MouseEvent.CLICK, this.cancelButtonClick);
		_cancelButton.visible = false;
		addChild(_cancelButton);
	}

	// WelcomeTaskWindow.as:191-195
	private override function addedToLayer():Void {
		super.addedToLayer();
		_inited = true;
	}

	// WelcomeTaskWindow.as:197-216
	private function rslCallBack():Void {
		if (this._id <= 0) {
			return;
		}
		this.graphics.clear();
		if (this._res != null && this._res.parent != null) {
			this._res.parent.removeChild(this._res);
		}
		this._res = cast(Utils.getMaterial("task" + this._id), Sprite);
		if (this._res != null) {
			this._res.x = 20;
			this._res.y = 40;
			addChild(this._res);
			this.height = this._res.height < 155 ? 245 : this._res.height + 90;
		}
	}

	// WelcomeTaskWindow.as:218-221（PopUpLayer 经 hasProp 探测、基类无此
	// 属性，ContentWindow 同款）
	public var disableAnimation(get, never):Bool;

	private function get_disableAnimation():Bool {
		return true;
	}
}
