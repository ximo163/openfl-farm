package module.warehouse.house.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.qui.makers.ButtonMaker;
import com.qzone.qui.makers.StepperMaker;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.MaterialProxyBig;
import common.view.window.BaseWindow;
import entities.WarehouseFish;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import interfaces.IMsgCenter;
import module.warehouse.house.WarehouseView;
import shim.As3;
import shim.QQOutlets;

/**
 * module.warehouse.house.widgets.SellFishWindow —— SellFishWindow.as 逐句
 * 对应（issue #36 功能 swf 翻译：仓库）。成鱼卖出窗：WarehouseForm 版式 +
 * MaterialProxyBig 成鱼图 + StepperMaker 数量 + 收入实时合计（财神爷/仙皇
 * 加成行）+ 锁定开关。onNavigateToURL 在本类无人挂接（原版死代码，照抄）。
 *
 * PORT-NOTE: 原版构造器在 super() 前落 _parentWin——Haxe super() 必须先行
 * （结果同形）；`_form.xxx` 时间轴具名子件 → As3.childOf；`super.data` 属性
 * 取值照写；ExternalInterface → QQOutlets（html5-only 收口）；`.text =
 * Number/int` 隐式串化 → Std.string；AS3 sellFish(int,int) 收 Number → 隐式
 * 截断 → Std.int；init 原文 protected → private 覆写（不调 super.init()，
 * 原版如此）。
 */
class SellFishWindow extends BaseWindow {
	// SellFishWindow.as:30
	private var _directionText:TextField;

	// SellFishWindow.as:32
	private var confirmButton:Button;

	// SellFishWindow.as:34
	private var _parentWin:BaseWindow;

	// SellFishWindow.as:36
	private var _material:MaterialProxyBig;

	// SellFishWindow.as:38
	private var _extraText:TextField;

	// SellFishWindow.as:40（WarehouseForm 符号，具名子件经 childOf 访问）
	private var _form:MovieClip;

	// SellFishWindow.as:42
	private var _numbericStepper:StepperMaker;

	// SellFishWindow.as:44
	private var _rate:Float;

	// SellFishWindow.as:46-65
	public function new(param1:BaseWindow) {
		var _loc2_:WarehouseView = Std.isOfType(param1, WarehouseView) ? cast(param1, WarehouseView) : null;
		super(Std.isOfType(_loc2_.controller.module.app, IMsgCenter) ? cast(_loc2_.controller.module.app, IMsgCenter) : null);
		this._parentWin = param1;
		width = 380;
		height = 280;
		title = "卖出成鱼";
		windowName = Consts.WINDOW_NAME_SELLFISH;
		mode = true;
		var _loc3_:Dynamic = Session.getInstance().myFairy;
		if (_loc3_ != null && (As3.floatOf(Reflect.field(_loc3_, "itemId")) == Consts.FAIRY_MONEY || As3.floatOf(Reflect.field(_loc3_, "itemId")) == Consts.FAIRY_GOD)) {
			this._rate = As3.floatOf(Reflect.field(_loc3_, "rate")) / 100 + 1;
		} else {
			this._rate = 1;
		}
	}

	// SellFishWindow.as:67-129（AS3 protected → private 覆写，不调
	// super.init()：原版如此）
	override private function init():Void {
		this._form = new WarehouseForm();
		this._form.x = 190;
		this._form.y = 32;
		addChild(this._form);
		this._material = new MaterialProxyBig();
		this._material.x = 20;
		this._material.y = 40;
		addChild(this._material);
		this._numbericStepper = new StepperMaker();
		this._numbericStepper.addEventListener(Event.CHANGE, this.onNumChange);
		var _loc1_:SteperSkin = new SteperSkin();
		_loc1_.x = 40;
		_loc1_.y = 170;
		addChild(_loc1_);
		this._numbericStepper.setSkin(_loc1_);
		this._directionText = new TextField();
		this._directionText.mouseEnabled = false;
		this._directionText.selectable = false;
		this._directionText.x = 25;
		this._directionText.y = 195;
		this._directionText.autoSize = TextFieldAutoSize.LEFT;
		this._directionText.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		this._directionText.text = Language.replaceText("sellNum", {
			"minNum": 1,
			"maxNum": 99
		});
		addChild(this._directionText);
		this.confirmButton = new Button();
		this.confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
		this.confirmButton.width = 64;
		this.confirmButton.height = 25;
		this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
		this.confirmButton.y = height - 50;
		this.confirmButton.text = Reflect.field(Language.L, "卖出");
		this.confirmButton.addEventListener(MouseEvent.CLICK, this.onSell);
		this.confirmButton.name = "confirm_btn";
		addChild(this.confirmButton);
		var _loc2_:Button = new Button();
		_loc2_.defaultSkin = Utils.getClass("ButtonBlue");
		_loc2_.width = 64;
		_loc2_.height = 25;
		_loc2_.x = width / 2 + 10;
		_loc2_.y = height - 50;
		_loc2_.text = Reflect.field(Language.L, "关闭");
		_loc2_.addEventListener(MouseEvent.CLICK, this.onCancel);
		addChild(_loc2_);
		if (As3.childOf(this._form, "lock_mc") != null) {
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).addEventListener(MouseEvent.CLICK, this.onLock);
			ButtonMaker.addTarget(cast(As3.childOf(As3.childOf(this._form, "lock_mc"), "lock_btn"), openfl.display.Sprite));
			cast(As3.childOf(As3.childOf(this._form, "lock_mc"), "lock_btn"), MovieClip).useHandCursor = false;
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).y += 40;
		}
		this._extraText = new TextField();
		this._extraText.x = cast(As3.childOf(this._form, "income"), TextField).x - 93;
		this._extraText.y = cast(As3.childOf(this._form, "income"), TextField).y + 43;
		this._extraText.width = 150;
		this._extraText.selectable = false;
		this._extraText.mouseEnabled = false;
		this._form.addChild(this._extraText);
	}

	// SellFishWindow.as:131-161
	private function onSell(param1:MouseEvent):Void {
		var _loc4_:Dynamic = null;
		var _loc5_:WarehouseView = null;
		var _loc2_:Int = QzoneJSAPI.getOnlineTime(Settings.getInstance().mode);
		var _loc3_:String = "";
		if (_loc2_ > 5 * 3600) {
			_loc3_ = "您现在处于长时间游戏的不健康时间段，适当休息一下吧。本次卖出将无法获得任何收益，您确定要卖出吗？";
		} else if (_loc2_ > 3 * 3600) {
			_loc3_ = "您现在处于疲劳时间段，适当休息一下吧。本次卖出将只能获得正常收益的一半，您确定要卖出吗？";
		} else {
			this.onOK(param1);
		}
		if (_loc3_ != "") {
			_loc4_ = {
				"width": 327,
				"height": 270,
				"title": "确定",
				"text": _loc3_,
				"confirmFn": this.onOK
			};
			_loc5_ = Std.isOfType(this._parentWin, WarehouseView) ? cast(this._parentWin, WarehouseView) : null;
			_loc5_.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM, _loc4_);
		}
	}

	// SellFishWindow.as:163-166
	public function updateLock():Void {
		this.updateLockStatus();
	}

	// SellFishWindow.as:168-189
	private function onLock(param1:MouseEvent):Void {
		var _loc2_:WarehouseFish = null;
		var _loc3_:Int = 0;
		var _loc4_:WarehouseView = null;
		if (cast(param1.target, openfl.display.DisplayObject).name == "lock_btn") {
			_loc2_ = Std.isOfType(super.data, WarehouseFish) ? cast(super.data, WarehouseFish) : null;
			if (_loc2_ == null) {
				return;
			}
			_loc3_ = _loc2_._isLock;
			_loc2_._isLock = _loc2_._isLock > 0 ? 0 : 1;
			_loc4_ = Std.isOfType(this._parentWin, WarehouseView) ? cast(this._parentWin, WarehouseView) : null;
			if (_loc4_ != null) {
				_loc4_.refreshFishLockStatus(Std.isOfType(super.data, WarehouseFish) ? cast(super.data, WarehouseFish) : null, _loc2_._isLock > 0);
			}
			_loc2_._isLock = _loc3_;
		}
	}

	// SellFishWindow.as:191-199（本类无人挂接：原版死代码，照抄）
	private function onNavigateToURL(param1:TextEvent):Void {
		var _loc2_:String = param1.text;
		if (_loc2_ == "" || QQOutlets.available == false) {
			return;
		}
		QQOutlets.call("window.open", _loc2_);
	}

	// SellFishWindow.as:201-238
	override private function setData():Void {
		var _loc2_:TextFormat = null;
		this.graphics.clear();
		var _loc1_:WarehouseFish = Std.isOfType(super.data, WarehouseFish) ? cast(super.data, WarehouseFish) : null;
		if (_loc1_ == null) {
			return;
		}
		if (this._material != null) {
			this._material.setContent(Std.string(_loc1_._type), _loc1_._id);
		}
		if (this._form != null) {
			this._numbericStepper.maximum = _loc1_._amount;
			this._numbericStepper.value = _loc1_._amount;
			_loc2_ = new TextFormat("Verdana", 26, 3381555, true);
			_loc2_.align = TextFormatAlign.CENTER;
			cast(As3.childOf(this._form, "cropName"), TextField).setTextFormat(_loc2_);
			cast(As3.childOf(this._form, "cropName"), TextField).width = 238;
			cast(As3.childOf(this._form, "cropName"), TextField).x = -50;
			cast(As3.childOf(this._form, "cropName"), TextField).text = _loc1_._name;
			cast(As3.childOf(this._form, "price"), TextField).width = 150;
			cast(As3.childOf(this._form, "price"), TextField).text = Std.string(_loc1_._sale);
			cast(As3.childOf(this._form, "income"), TextField).width = 150;
			cast(As3.childOf(this._form, "income"), TextField).text = Std.string(_loc1_._sale * this._numbericStepper.value);
			if (this._rate > 1 && this._extraText != null) {
				this._extraText.htmlText = "<font color=\'#333333\'>收入加成：</font>" + "<font color=\'#CC3300\'>金币&nbsp;&nbsp;</font><font color=\'#FF6600\' size=\'16\'>"
					+ Std.string(Math.ceil(_loc1_._sale * this._numbericStepper.value * (this._rate - 1))) + "</font>";
			}
			this._directionText.text = Language.replaceText("sellNum", {
				"minNum": 1,
				"maxNum": _loc1_._amount
			});
			this.updateLockStatus();
		}
	}

	// SellFishWindow.as:240-259
	private function updateLockStatus():Void {
		var _loc1_:WarehouseFish = Std.isOfType(super.data, WarehouseFish) ? cast(super.data, WarehouseFish) : null;
		if (_loc1_ == null) {
			return;
		}
		if (_loc1_._isLock > 0) {
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).visible = true;
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).gotoAndStop("lock");
			this.confirmButton.enabled = false;
		} else {
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).visible = true;
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).gotoAndStop("unlock");
			this.confirmButton.enabled = true;
		}
	}

	// SellFishWindow.as:261-273
	private function onNumChange(param1:Event):Void {
		var _loc2_:WarehouseFish = Std.isOfType(super.data, WarehouseFish) ? cast(super.data, WarehouseFish) : null;
		if (_loc2_ == null) {
			return;
		}
		cast(As3.childOf(this._form, "income"), TextField).text = Std.string(_loc2_._sale * this._numbericStepper.value);
		if (this._rate > 1) {
			this._extraText.htmlText = "<font color=\'#333333\'>收入加成：</font>" + "<font color=\'#CC3300\'>金币&nbsp;&nbsp;</font><font color=\'#FF6600\' size=\'16\'>"
				+ Std.string(Math.ceil(_loc2_._sale * this._numbericStepper.value * (this._rate - 1))) + "</font>";
		}
	}

	// SellFishWindow.as:275-278
	private function onCancel(param1:MouseEvent):Void {
		super.onClose(param1);
	}

	// SellFishWindow.as:280-293
	private function onOK(param1:MouseEvent = null):Void {
		var _loc2_:WarehouseFish = Std.isOfType(super.data, WarehouseFish) ? cast(super.data, WarehouseFish) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:WarehouseView = Std.isOfType(this._parentWin, WarehouseView) ? cast(this._parentWin, WarehouseView) : null;
		if (_loc3_ != null) {
			// AS3 sellFish(int,int) 收 Number → 隐式截断 → Std.int
			_loc3_.controller.model.sellFish(_loc2_._id, Std.int(this._numbericStepper.value));
		}
		super.onClose(param1);
	}
}
