package module.shop.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.qui.makers.StepperMaker;
import com.qzone.utils.AlignUtil;
import common.Consts;
import common.GetCropID;
import common.Language;
import common.Session;
import common.misc.Utils;
import common.view.MaterialProxyBig;
import common.view.MoneyIcon;
import common.view.window.BaseWindow;
import entities.Player;
import entities.ShopFish;
import interfaces.IMsgCenter;
import module.GameGuide;
import module.shop.ShopView;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;
import shim.QQOutlets;

/**
 * module.shop.widgets.BuyFishWindow —— BuyFishWindow.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。鱼苗买入窗：ShopSeedForm 符号具名
 * 子件（cropName/cropDetail/cropTip）经 As3.childOf 取出再读写；可买上限
 * = floor(金币/单价) 三段夹（99 / 1..99 / 1）。
 *
 * PORT-NOTE: ExternalInterface（available/call）→ QQOutlets（html5-only
 * 通道，CLAUDE.md shim 规则）；`ShopSeedForm.cropX != undefined` 的
 * 时间轴子件存在性探测 → As3.childOf + null 判。
 */
class BuyFishWindow extends BaseWindow {
	// BuyFishWindow.as:10
	private var money:MoneyIcon;

	// BuyFishWindow.as:12
	private var _material:MaterialProxyBig;

	// BuyFishWindow.as:14
	private var _parent:ShopView;

	// BuyFishWindow.as:16（ShopSeedForm 符号，具名子件经 childOf 访问）
	private var _shopSeedForm:Dynamic;

	// BuyFishWindow.as:18
	private var cancelButton:Button;

	// BuyFishWindow.as:20
	private var _directionText:TextField;

	// BuyFishWindow.as:22
	private var _errorText:TextField;

	// BuyFishWindow.as:24
	private var _cropPrice:TextField;

	// BuyFishWindow.as:26
	private var _confirmButton:Button;

	// BuyFishWindow.as:28
	private var stepperSkin:DisplayObject;

	// BuyFishWindow.as:30
	private var _numbericStepper:StepperMaker;

	// BuyFishWindow.as:32（Number）
	private var _userMoney:Float;

	// BuyFishWindow.as:34-44
	public function new(param1:ShopView) {
		super(Std.isOfType(param1.controller.module.app, IMsgCenter) ? cast(param1.controller.module.app, IMsgCenter) : null);
		width = 400;
		height = 390;
		title = "购买鱼苗";
		windowName = Consts.WINDOW_NAME_BUYFISH;
		mode = true;
		this._parent = param1;
	}

	// BuyFishWindow.as:46-57
	private function onOK(param1:MouseEvent):Void {
		var _loc2_:ShopFish = null;
		if (this._confirmButton.enabled == true) {
			_loc2_ = Std.isOfType(this.data, ShopFish) ? cast(this.data, ShopFish) : null;
			if (_loc2_ == null) {
				return;
			}
			// AS3 buyFishs(int,int) 收 Number → 隐式截断 → Std.int
			this._parent.controller.model.buyFishs(_loc2_._id, Std.int(this._numbericStepper.value));
			super.onClose(param1);
		}
	}

	// BuyFishWindow.as:59-63
	override private function setSize():Void {
		super.setSize();
		panelTitle.x = AlignUtil.middle(_width, panelTitle.width);
	}

	// BuyFishWindow.as:65-137
	override private function setData():Void {
		if (this.isInit == false) {
			return;
		}
		var _loc1_:ShopFish = Std.isOfType(this.data, ShopFish) ? cast(this.data, ShopFish) : null;
		if (_loc1_ == null) {
			return;
		}
		this.graphics.clear();
		var _loc2_:Player = Session.getInstance().host;
		if (_loc2_ != null) {
			this._userMoney = _loc2_._money;
		}
		if (this._shopSeedForm == null) {
			this._shopSeedForm = Utils.getMaterial("ShopSeedForm");
			if (this._shopSeedForm == null) {
				return;
			}
			cast(this._shopSeedForm, DisplayObject).x = 190;
			cast(this._shopSeedForm, DisplayObject).y = 40;
			addChild(cast(this._shopSeedForm, DisplayObject));
			cast(As3.childOf(this._shopSeedForm, "cropTip"), TextField).addEventListener(TextEvent.LINK, this.onNavigateToURL);
		}
		if (this._cropPrice != null) {
			this._cropPrice.text = Std.string(_loc1_._price);
		}
		if (this._material != null) {
			this._material.setContent(Consts.ITEM_TYPE_FISH, _loc1_._id);
		}
		this._numbericStepper.value = 1;
		if (As3.childOf(this._shopSeedForm, "cropName") != null) {
			var cropName:TextField = cast(As3.childOf(this._shopSeedForm, "cropName"), TextField);
			cropName.text = _loc1_._name;
			if (cropName.width < cropName.textWidth) {
				cropName.width = cropName.textWidth + 10;
			}
		}
		if (As3.childOf(this._shopSeedForm, "cropDetail") != null) {
			var cropDetail:TextField = cast(As3.childOf(this._shopSeedForm, "cropDetail"), TextField);
			cropDetail.width += 10;
			cropDetail.htmlText = this.buildContent();
		}
		if (As3.childOf(this._shopSeedForm, "cropTip") != null) {
			cast(As3.childOf(this._shopSeedForm, "cropTip"), TextField).htmlText = GetCropID.fishTip(Std.string(_loc1_._id));
		}
		var _loc3_:Int = _loc1_._price;
		var _loc4_:Int = _loc3_ > 0 ? Std.int(Math.floor(this._userMoney / _loc3_)) : 1;
		if (_loc4_ >= 100) {
			this._directionText.text = Language.replaceText("buyNum", {
				"minNum": 1,
				"maxNum": 99
			});
			this._numbericStepper.maximum = 99;
		} else if (_loc4_ < 100 && _loc4_ >= 1) {
			this._directionText.text = Language.replaceText("buyNum", {
				"minNum": 1,
				"maxNum": _loc4_
			});
			this._numbericStepper.maximum = _loc4_;
		} else if (_loc4_ <= 1) {
			this._directionText.text = Language.replaceText("buyNum", {
				"minNum": 1,
				"maxNum": 1
			});
			this._numbericStepper.maximum = 1;
		}
		if (this._userMoney < _loc3_) {
			this._confirmButton.enabled = false;
			this._errorText.text = Reflect.field(Language.L, "对不起，您的金币不足。");
		} else {
			this._errorText.text = "";
			this._confirmButton.enabled = true;
		}
		GameGuide.instance().showStep(GameGuide.WATER_BUY_FISH);
		GameGuide.instance().autoHide(5);
	}

	// BuyFishWindow.as:139-147
	private function onNavigateToURL(param1:TextEvent):Void {
		var _loc2_:String = param1.text;
		if (_loc2_ == "" || QQOutlets.available == false) {
			return;
		}
		QQOutlets.call("window.open", _loc2_);
	}

	// BuyFishWindow.as:149-166
	private function onNumChanged(param1:Event):Void {
		var _loc2_:ShopFish = Std.isOfType(this.data, ShopFish) ? cast(this.data, ShopFish) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = Std.int(_loc2_._price * this._numbericStepper.value);
		if (this._userMoney < _loc3_) {
			this._errorText.text = Reflect.field(Language.L, "对不起，您的金币不足。");
			this._confirmButton.enabled = false;
		} else {
			this._errorText.text = "";
			this._confirmButton.enabled = true;
		}
		this._cropPrice.text = Std.string(_loc3_);
	}

	// BuyFishWindow.as:168-185
	private function buildContent():String {
		var _loc1_:String = "";
		var _loc2_:ShopFish = Std.isOfType(this.data, ShopFish) ? cast(this.data, ShopFish) : null;
		if (_loc2_ == null) {
			return _loc1_;
		}
		_loc1_ += "占用容量：<font color=\"#FF6600\">" + Std.string(_loc2_._pool_size) + "</font>";
		_loc1_ += "<br>成熟时间：<font color=\"#0099FF\">" + Std.string(_loc2_._mature) + "</font> 小时";
		_loc1_ += "<br>预计产量：<font color=\"#0099FF\">" + Std.string(_loc2_._output) + "</font> 条";
		_loc1_ += "<br>成鱼售价：<font color=\"#CC3300\">金币</font><font color=\"#FF6600\">" + Std.string(_loc2_._sale)
			+ "</font>";
		_loc1_ += "<br>预计收入：<font color=\"#CC3300\">金币</font><font color=\"#FF6600\">"
			+ Std.string(_loc2_._sale * _loc2_._output) + "</font>";
		_loc1_ += "<br>收获经验：<font color=\"#0099FF\">" + Std.string(_loc2_._exp) + "</font>";
		return _loc1_ + "<br>特殊用途：观赏<br>";
	}

	// BuyFishWindow.as:187-191
	override private function close():Void {
		super.close();
		GameGuide.instance().hide();
	}

	// BuyFishWindow.as:193-196（原版 `super.onClose(param1)` 直落父类）
	private function onCancel(param1:MouseEvent):Void {
		super.onClose(param1);
	}

	// BuyFishWindow.as:198-285
	override private function addedToLayer():Void {
		super.addedToLayer();
		this._material = new MaterialProxyBig();
		this._material.x = 25;
		this._material.y = 40;
		addChild(this._material);
		this.money = new MoneyIcon();
		addChild(this.money);
		this.money.x = 40;
		this.money.y = 170;
		this._cropPrice = new TextField();
		this._cropPrice.selectable = false;
		this._cropPrice.defaultTextFormat = new TextFormat("Verdana", 11, 16737792, true);
		this._cropPrice.text = "0";
		this._cropPrice.width = 100;
		this._cropPrice.height = 22;
		addChild(this._cropPrice);
		this._cropPrice.x = 70;
		this._cropPrice.y = 170;
		this._numbericStepper = new StepperMaker();
		this._numbericStepper.maximum = 99;
		this._numbericStepper.minimum = 1;
		this._numbericStepper.value = 1;
		this._numbericStepper.addEventListener(Event.CHANGE, this.onNumChanged);
		this.stepperSkin = Std.isOfType(Utils.getMaterial("SteperSkin"), DisplayObject)
			? cast(Utils.getMaterial("SteperSkin"), DisplayObject) : null;
		if (this.stepperSkin != null) {
			this.stepperSkin.x = 30;
			this.stepperSkin.y = 200;
			this._numbericStepper.setSkin(Std.isOfType(this.stepperSkin, Sprite) ? cast(this.stepperSkin, Sprite) : null);
			addChild(this.stepperSkin);
		}
		this._directionText = new TextField();
		this._directionText.mouseEnabled = false;
		this._directionText.selectable = false;
		this._directionText.x = 25;
		this._directionText.y = 225;
		this._directionText.autoSize = TextFieldAutoSize.LEFT;
		this._directionText.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		this._directionText.text = Language.replaceText("buyNum", {
			"minNum": 1,
			"maxNum": 99
		});
		addChild(this._directionText);
		this._errorText = new TextField();
		this._errorText.mouseEnabled = false;
		this._errorText.selectable = false;
		this._errorText.x = 0;
		this._errorText.y = this.height - 65;
		this._errorText.width = 400;
		this._errorText.height = 21;
		this._errorText.defaultTextFormat = new TextFormat("Verdana", 12, 13369344, null, null, null, null, null,
			TextFormatAlign.CENTER);
		this._errorText.text = "";
		addChild(this._errorText);
		this._confirmButton = new Button();
		this._confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
		this._confirmButton.width = 64;
		this._confirmButton.height = 25;
		this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
		this._confirmButton.y = height - 40;
		this._confirmButton.text = Reflect.field(Language.L, "确定");
		this._confirmButton.addEventListener(MouseEvent.CLICK, this.onOK);
		addChild(this._confirmButton);
		this.cancelButton = new Button();
		this.cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
		this.cancelButton.width = 64;
		this.cancelButton.height = 25;
		this.cancelButton.x = width / 2 + 10;
		this.cancelButton.y = height - 40;
		this.cancelButton.text = Reflect.field(Language.L, "取消");
		this.cancelButton.addEventListener(MouseEvent.CLICK, this.onCancel);
		addChild(this.cancelButton);
	}
}
