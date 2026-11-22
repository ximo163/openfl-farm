package module.warehouse.house.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import com.qzone.qui.makers.ButtonMaker;
import com.qzone.qui.makers.StepperMaker;
import com.qzone.utils.DisplayUtil;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.MaterialProxyBig;
import common.view.window.BaseWindow;
import entities.WarehouseCrop;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
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
 * module.warehouse.house.widgets.SellPlantWindow —— SellPlantWindow.as 逐句
 * 对应（issue #36 功能 swf 翻译：仓库）。蔬果/材料卖出窗：WarehouseForm
 * 版式 + MaterialProxyBig 物料 + StepperMaker 数量 + 收入实时合计（财神爷/
 * 仙皇加成行）+ 锁定开关（lock_mc.lock_btn，isMaterial 时卡片半缩）。
 *
 * PORT-NOTE: 原版构造器在 super() 前落 _isMaterial/_parentWin——Haxe
 * super() 必须先行，字段赋值移到其后（结果同形）；`_form.xxx` 时间轴具名
 * 子件 → As3.childOf 取出再处理（BuySeedWindow 先例，无守卫处保持无守卫）；
 * `super.data` 属性取值照写（Haxe 属性 super 直落父 getter）；:391 原版把
 * super.onClose 当值传 addEventListener，Haxe 不能把 super 调用当值，包具名
 * 方法 onCancelClick 等价转发（BuyItemWindow 先例）；ExternalInterface →
 * QQOutlets（html5-only 收口）；unescape → As3.unescape；`x || ""` 的 AS3
 * 空串假值 → 空串时同样取 ""（结果同形）；`.text = Number/int` 的隐式串化
 * → Std.string；`as int` → Std.int。
 */
class SellPlantWindow extends BaseWindow {
	// SellPlantWindow.as:33
	private var _directionText:TextField;

	// SellPlantWindow.as:35
	private var _adText:Label;

	// SellPlantWindow.as:37
	private var _isMaterial:Bool;

	// SellPlantWindow.as:39
	private var _parentWin:BaseWindow;

	// SellPlantWindow.as:41
	private var _material:MaterialProxyBig;

	// SellPlantWindow.as:43
	private var _confirmBtn:Button;

	// SellPlantWindow.as:45（WarehouseForm 符号，具名子件经 childOf 访问）
	private var _form:MovieClip;

	// SellPlantWindow.as:47
	private var _extraText:TextField;

	// SellPlantWindow.as:49
	private var _numbericStepper:StepperMaker;

	// SellPlantWindow.as:51
	private var label:Label;

	// SellPlantWindow.as:53
	private var _vipIcon:MovieClip;

	// SellPlantWindow.as:55
	private var _rate:Float;

	// SellPlantWindow.as:57-84
	public function new(param1:BaseWindow, param2:Bool = false) {
		var _loc3_:WarehouseView = Std.isOfType(param1, WarehouseView) ? cast(param1, WarehouseView) : null;
		super(Std.isOfType(_loc3_.controller.module.app, IMsgCenter) ? cast(_loc3_.controller.module.app, IMsgCenter) : null);
		this._isMaterial = param2;
		this._parentWin = param1;
		width = 380;
		height = 280;
		if (!param2) {
			title = Reflect.field(Language.L, "sellCropWindow");
		} else {
			title = Reflect.field(Language.L, "sellMaterialWindow");
		}
		windowName = Consts.WINDOW_NAME_SELLPLANT;
		mode = true;
		var _loc4_:Dynamic = Session.getInstance().myFairy;
		if (_loc4_ != null && (As3.floatOf(Reflect.field(_loc4_, "itemId")) == Consts.FAIRY_MONEY || As3.floatOf(Reflect.field(_loc4_, "itemId")) == Consts.FAIRY_GOD)) {
			this._rate = As3.floatOf(Reflect.field(_loc4_, "rate")) / 100 + 1;
		} else {
			this._rate = 1;
		}
	}

	// SellPlantWindow.as:86-116
	private function onSell(param1:MouseEvent = null):Void {
		var _loc2_:WarehouseView = null;
		var _loc5_:Dynamic = null;
		var _loc3_:Int = QzoneJSAPI.getOnlineTime(Settings.getInstance().mode);
		var _loc4_:String = "";
		if (_loc3_ > 5 * 3600) {
			_loc4_ = "您现在处于长时间游戏的不健康时间段，适当休息一下吧。本次卖出将无法获得任何收益，您确定要卖出吗？";
		} else if (_loc3_ > 3 * 3600) {
			_loc4_ = "您现在处于疲劳时间段，适当休息一下吧。本次卖出将只能获得正常收益的一半，您确定要卖出吗？";
		} else {
			this.onOK(param1);
		}
		if (_loc4_ != "") {
			_loc5_ = {
				"width": 327,
				"height": 270,
				"title": "确定",
				"text": _loc4_,
				"confirmFn": this.onOK
			};
			_loc2_ = Std.isOfType(this._parentWin, WarehouseView) ? cast(this._parentWin, WarehouseView) : null;
			_loc2_.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM, _loc5_);
		}
	}

	// SellPlantWindow.as:118-121
	public function updateLock():Void {
		this.updateLockStatus();
	}

	// SellPlantWindow.as:123-145
	private function onNumChange(param1:Event):Void {
		var _loc2_:WarehouseCrop = Std.isOfType(super.data, WarehouseCrop) ? cast(super.data, WarehouseCrop) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Float = 0;
		if (_loc2_._high_price > 0) {
			_loc3_ = _loc2_._high_price * this._numbericStepper.value;
			cast(As3.childOf(this._form, "income"), TextField).text = Std.string(_loc3_);
		} else {
			_loc3_ = _loc2_._price * this._numbericStepper.value;
			cast(As3.childOf(this._form, "income"), TextField).text = Std.string(_loc3_);
		}
		if (this._rate > 1 && this._extraText.htmlText != null && this._extraText.htmlText.indexOf("收入加成") != -1) {
			this._extraText.htmlText = "<font color=\'#333333\'>收入加成：</font>" + "<font color=\'#CC3300\'>金币&nbsp;&nbsp;</font><font color=\'#FF6600\'>"
				+ Std.string(Std.int(_loc3_ * (this._rate - 1))) + "</font>";
		}
	}

	// SellPlantWindow.as:147-155
	private function onNavigateToURL(param1:TextEvent):Void {
		var _loc2_:String = param1.text;
		if (_loc2_ == "" || QQOutlets.available == false) {
			return;
		}
		QQOutlets.call("window.open", _loc2_);
	}

	// SellPlantWindow.as:157-178
	private function onLock(param1:MouseEvent):Void {
		var _loc2_:WarehouseCrop = null;
		var _loc3_:Int = 0;
		var _loc4_:WarehouseView = null;
		if (cast(param1.target, openfl.display.DisplayObject).name == "lock_btn") {
			_loc2_ = Std.isOfType(super.data, WarehouseCrop) ? cast(super.data, WarehouseCrop) : null;
			if (_loc2_ == null) {
				return;
			}
			_loc3_ = _loc2_._isLock;
			_loc2_._isLock = _loc2_._isLock > 0 ? 0 : 1;
			_loc4_ = Std.isOfType(this._parentWin, WarehouseView) ? cast(this._parentWin, WarehouseView) : null;
			if (_loc4_ != null) {
				_loc4_.refreshItemLockStatus(Std.isOfType(super.data, WarehouseCrop) ? cast(super.data, WarehouseCrop) : null, _loc2_._isLock > 0);
			}
			_loc2_._isLock = _loc3_;
		}
	}

	// SellPlantWindow.as:180-279
	override private function setData():Void {
		var _loc2_:TextFormat = null;
		var _loc3_:Int = 0;
		var _loc4_:String = null;
		var _loc5_:Array<Dynamic> = null;
		this.graphics.clear();
		var _loc1_:WarehouseCrop = Std.isOfType(super.data, WarehouseCrop) ? cast(super.data, WarehouseCrop) : null;
		if (_loc1_ == null) {
			return;
		}
		if (this._material != null) {
			if (!this._isMaterial) {
				this._material.setContent(Consts.ITEM_TYPE_SEED, _loc1_._id);
			} else {
				this._material.setContent(Std.string(_loc1_._type), _loc1_._id);
				if (Std.string(_loc1_._type) == Consts.ITEM_TYPE_CARD) {
					this._material.scaleX = this._material.scaleY = 0.5;
					this._material.x = 52;
					this._material.y = 70;
				} else {
					this._material.scaleX = this._material.scaleY = 1;
					this._material.x = 20;
					this._material.y = 40;
				}
			}
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
			cast(As3.childOf(this._form, "price"), TextField).text = Std.string(_loc1_._price);
			_loc3_ = 0;
			if (_loc1_._high_price > 0) {
				cast(As3.childOf(this._form, "price"), TextField).text = Std.string(_loc1_._high_price);
				cast(As3.childOf(this._form, "sprice"), TextField).text = "（原价：金币 " + Std.string(_loc1_._price) + "）";
				_loc3_ = Std.int(_loc1_._high_price * this._numbericStepper.value);
				cast(As3.childOf(this._form, "income"), TextField).text = Std.string(_loc3_);
			} else {
				cast(As3.childOf(this._form, "price"), TextField).text = Std.string(_loc1_._price);
				cast(As3.childOf(this._form, "sprice"), TextField).text = "";
				_loc3_ = Std.int(_loc1_._price * this._numbericStepper.value);
				cast(As3.childOf(this._form, "income"), TextField).text = Std.string(_loc3_);
			}
			if (this._rate > 1 && this._extraText != null) {
				_loc4_ = Settings.getInstance().getStringAttribute("exclude_seeds");
				_loc5_ = _loc4_.split(",");
				if (_loc5_ != null && _loc5_.indexOf(Std.string(_loc1_._id)) == -1) {
					this._extraText.htmlText = "<font color=\'#333333\'>收入加成：</font>" + "<font color=\'#CC3300\'>金币&nbsp;&nbsp;</font><font color=\'#FF6600\' size=\'16\'>"
						+ Std.string(Std.int(_loc3_ * (this._rate - 1))) + "</font>";
				}
			}
			this._directionText.text = Language.replaceText("sellNum", {
				"minNum": 1,
				"maxNum": _loc1_._amount
			});
			if (_loc1_._ext != null) {
				if (this._adText == null) {
					this._adText = new Label();
					this._adText.mouseChildren = true;
					this._adText.y = 220;
					this._adText.textField.addEventListener(TextEvent.LINK, this.onNavigateToURL);
					this._adText.textDefaultFormat = new TextFormat();
				}
				this._adText.text = As3.unescape(As3.truthy(Std.string(_loc1_._ext)) ? Std.string(_loc1_._ext) : "");
				this._adText.x = 18;
				this.addChild(this._adText);
			} else {
				DisplayUtil.removeChild(this, this._adText);
			}
			this.updateLockStatus();
			this._material.y = 40;
		}
		if (_loc1_._isVip == 1) {
			addChild(this._vipIcon);
		}
	}

	// SellPlantWindow.as:281-307
	private function updateLockStatus():Void {
		var _loc1_:WarehouseCrop = Std.isOfType(super.data, WarehouseCrop) ? cast(super.data, WarehouseCrop) : null;
		if (_loc1_ == null) {
			return;
		}
		if (Std.string(_loc1_._type) == Consts.ITEM_TYPE_CRYSTAL) {
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).visible = false;
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).gotoAndStop("unlock");
			this._confirmBtn.enabled = true;
			return;
		}
		if (_loc1_._isLock > 0) {
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).visible = true;
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).gotoAndStop("lock");
			this._confirmBtn.enabled = false;
		} else {
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).visible = true;
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).gotoAndStop("unlock");
			this._confirmBtn.enabled = true;
		}
	}

	// SellPlantWindow.as:309-321
	override public function keyEnter(param1:KeyboardEvent):Void {
		var _loc2_:WarehouseCrop = Std.isOfType(super.data, WarehouseCrop) ? cast(super.data, WarehouseCrop) : null;
		if (_loc2_ == null) {
			return;
		}
		if (_loc2_._isLock == 1) {
			return;
		}
		this.onOK();
	}

	// SellPlantWindow.as:323-343
	private function onOK(param1:MouseEvent = null):Void {
		var _loc2_:WarehouseCrop = Std.isOfType(super.data, WarehouseCrop) ? cast(super.data, WarehouseCrop) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:WarehouseView = Std.isOfType(this._parentWin, WarehouseView) ? cast(this._parentWin, WarehouseView) : null;
		if (_loc3_ != null) {
			// AS3 sellCrystal/sellPlant(int,int) 收 Number → 隐式截断 → Std.int
			if (Std.string(_loc2_._type) == Consts.ITEM_TYPE_CRYSTAL) {
				_loc3_.controller.model.sellCrystal(_loc2_._id, Std.int(this._numbericStepper.value));
			} else {
				_loc3_.controller.model.sellPlant(_loc2_._id, Std.int(this._numbericStepper.value));
			}
		}
		super.onClose(param1);
	}

	// SellPlantWindow.as:391（原版把 super.onClose 当值传 addEventListener，
	// Haxe 限制见类头 PORT-NOTE；转发事件参量）
	private function onCancelClick(param1:MouseEvent):Void {
		super.onClose(param1);
	}

	// SellPlantWindow.as:345-410（原版不调 super.addedToLayer()，照抄）
	override private function addedToLayer():Void {
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
		this._confirmBtn = new Button();
		this._confirmBtn.defaultSkin = Utils.getClass("ButtonOrange");
		this._confirmBtn.width = 64;
		this._confirmBtn.height = 25;
		this._confirmBtn.x = width / 2 - this._confirmBtn.width - 10;
		this._confirmBtn.y = height - 40;
		this._confirmBtn.text = Reflect.field(Language.L, "卖出");
		this._confirmBtn.addEventListener(MouseEvent.CLICK, this.onSell);
		this._confirmBtn.name = "confirm_btn";
		addChild(this._confirmBtn);
		var _loc2_:Button = new Button();
		_loc2_.defaultSkin = Utils.getClass("ButtonBlue");
		_loc2_.width = 64;
		_loc2_.height = 25;
		_loc2_.x = width / 2 + 10;
		_loc2_.y = height - 40;
		_loc2_.text = Reflect.field(Language.L, "关闭");
		_loc2_.addEventListener(MouseEvent.CLICK, this.onCancelClick);
		addChild(_loc2_);
		if (As3.childOf(this._form, "lock_mc") != null) {
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).addEventListener(MouseEvent.CLICK, this.onLock);
			ButtonMaker.addTarget(cast(As3.childOf(As3.childOf(this._form, "lock_mc"), "lock_btn"), openfl.display.Sprite));
			cast(As3.childOf(As3.childOf(this._form, "lock_mc"), "lock_btn"), MovieClip).useHandCursor = false;
			cast(As3.childOf(this._form, "lock_mc"), MovieClip).y += 40;
		}
		var vipMat:Dynamic = Utils.getMaterial("VipSeedIcon");
		this._vipIcon = Std.isOfType(vipMat, MovieClip) ? cast(vipMat, MovieClip) : null;
		this._vipIcon.x = this._material.x + 2;
		this._vipIcon.y = this._material.y + 1;
		this._extraText = new TextField();
		this._extraText.x = cast(As3.childOf(this._form, "income"), TextField).x - 93;
		this._extraText.y = cast(As3.childOf(this._form, "income"), TextField).y + 43;
		this._extraText.width = 150;
		this._extraText.selectable = false;
		this._extraText.mouseEnabled = false;
		this._form.addChild(this._extraText);
	}
}
