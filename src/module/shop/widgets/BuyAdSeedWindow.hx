package module.shop.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.qui.makers.StepperMaker;
import com.qzone.utils.AlignUtil;
import com.qzone.utils.StringUtil;
import common.GetCropID;
import common.Language;
import common.Session;
import common.misc.Utils;
import common.view.MaterialProxyBig;
import common.view.MoneyIcon;
import common.view.window.BaseWindow;
import entities.Player;
import entities.Seed;
import interfaces.IMsgCenter;
import module.shop.ShopView;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;
import shim.QQOutlets;

/**
 * module.shop.widgets.BuyAdSeedWindow —— BuyAdSeedWindow.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。合作专区种子买入窗：布局复用
 * ShopSeedForm 符号（y=120、cropDetail 提高到 288），买入走 buySeeds 的
 * adSeed=true 支路，末尾补一次 setSize()。
 *
 * PORT-NOTE: ExternalInterface → QQOutlets；`form.cropX != undefined` 的
 * 时间轴子件探测 → As3.childOf + null 判；:236-239 四行对 cropName/
 * cropDetail 的**无守卫**读写保持无守卫（原版对缺失子件同样在 .y 处抛错；
 * ShopSeedForm 符号带这两个具名子件）。buildContent 里 cropTime 拆分
 * 后的 `_loc4_[4] - _loc4_[2]` 越界读（_matureTime>1 而 parts<5 时）
 * → As3.arrAt/intSub：AS3 undefined 相减得 NaN、int() 截成 0，arrAt 的
 * null→intSub 的 0 同语义（cpp 裸越界读会崩，见 As3.arrAt 注）。
 */
class BuyAdSeedWindow extends BaseWindow {
	// BuyAdSeedWindow.as:33
	private var _cLevel:Int;

	// BuyAdSeedWindow.as:35
	private var _material:MaterialProxyBig;

	// BuyAdSeedWindow.as:37
	private var money:MoneyIcon;

	// BuyAdSeedWindow.as:39
	private var _parent:ShopView;

	// BuyAdSeedWindow.as:41（ShopSeedForm 符号，具名子件经 childOf 访问）
	private var _shopSeedForm:Dynamic;

	// BuyAdSeedWindow.as:43
	private var cancelButton:Button;

	// BuyAdSeedWindow.as:45
	private var _directionText:TextField;

	// BuyAdSeedWindow.as:47
	private var _errorText:TextField;

	// BuyAdSeedWindow.as:49
	private var _cropPrice:TextField;

	// BuyAdSeedWindow.as:51
	private var _confirmButton:Button;

	// BuyAdSeedWindow.as:53
	private var stepperSkin:DisplayObject;

	// BuyAdSeedWindow.as:55
	private var _numbericStepper:StepperMaker;

	// BuyAdSeedWindow.as:57（Number）
	private var _userMoney:Float;

	// BuyAdSeedWindow.as:59-67
	public function new(param1:ShopView) {
		super(Std.isOfType(param1.controller.module.app, IMsgCenter) ? cast(param1.controller.module.app, IMsgCenter) : null);
		width = 400;
		height = 490;
		title = Reflect.field(Language.L, "shopSeedWindow");
		mode = true;
		this._parent = param1;
	}

	// BuyAdSeedWindow.as:69-82
	private function onOK(param1:MouseEvent):Void {
		var _loc2_:Seed = null;
		if (this._confirmButton.enabled == true) {
			_loc2_ = Std.isOfType(this.data, Seed) ? cast(this.data, Seed) : null;
			if (_loc2_ == null) {
				return;
			}
			// AS3 buySeeds(int,int[,bool]) 收 Number → 隐式截断 → Std.int
			this._parent.controller.model.buySeeds(_loc2_._id, Std.int(this._numbericStepper.value), true);
			super.onClose(param1);
		}
	}

	// BuyAdSeedWindow.as:84-88
	override private function setSize():Void {
		super.setSize();
		panelTitle.x = AlignUtil.middle(_width, panelTitle.width);
	}

	// BuyAdSeedWindow.as:90-93
	private function onCancel(param1:MouseEvent):Void {
		super.onClose(param1);
	}

	// BuyAdSeedWindow.as:95-103
	private function onNavigateToURL(param1:TextEvent):Void {
		var _loc2_:String = param1.text;
		if (_loc2_ == "" || QQOutlets.available == false) {
			return;
		}
		QQOutlets.call("window.open", _loc2_);
	}

	// BuyAdSeedWindow.as:105-127
	private function onNumChanged(param1:Event):Void {
		var _loc2_:Seed = Std.isOfType(this.data, Seed) ? cast(this.data, Seed) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = Std.int(_loc2_._price * this._numbericStepper.value);
		if (this._cLevel >= _loc2_._lvl) {
			if (this._userMoney < _loc3_) {
				this._errorText.text = Reflect.field(Language.L, "对不起，您的金币不足。");
				this._confirmButton.enabled = false;
			} else {
				this._errorText.text = "";
				this._confirmButton.enabled = true;
			}
		}
		this._cropPrice.text = Std.string(_loc3_);
	}

	// BuyAdSeedWindow.as:129-190
	private function buildContent():String {
		var _loc5_:Float = Math.NaN;
		var _loc1_:String = "";
		var _loc2_:Seed = Std.isOfType(this.data, Seed) ? cast(this.data, Seed) : null;
		if (_loc2_ == null) {
			return _loc1_;
		}
		_loc1_ = "作物类型：" + StringUtil.getChineseNum(_loc2_._matureTime);
		var _loc3_:String = GetCropID.cropTime(Std.string(_loc2_._id));
		var _loc4_:Array<Dynamic> = cast _loc3_.split(",");
		if (_loc4_ != null && _loc4_.length > 4) {
			_loc1_ += "季作物<br>成熟时间：<font color=\"#0099FF\">" + Std.int(As3.intOf(_loc4_[4]) / 3600)
				+ "</font> 小时<br>";
		}
		if (_loc2_._matureTime > 1) {
			// 越界读走 arrAt/intSub（见类头 PORT-NOTE）；length>4 时同下标直读
			_loc5_ = Std.int(As3.intSub(As3.arrAt(_loc4_, 4), As3.arrAt(_loc4_, 2)) / 3600);
			_loc1_ += "再次成熟：<font color=\"#0099FF\">" + _loc5_ + "</font> 小时<br>";
		}
		_loc1_ += "预计产量：<font color=\"#0099FF\">" + _loc2_._output + "</font> 个";
		_loc1_ += "<br>果实售价：<font color=\"#CC3300\">金币</font><font color=\"#FF6600\">";
		if (_loc2_._high_sale > 0) {
			_loc1_ += _loc2_._high_sale + "<font color=\"#777777\">(原价:金币 " + _loc2_._sale + ")</font>";
		} else {
			_loc1_ += _loc2_._sale;
		}
		_loc1_ += "</font><br>预计收入：<font color=\"#CC3300\">金币</font><font color=\"#FF6600\">";
		_loc1_ += _loc2_._expect + "</font><br>收获经验：<font color=\"#0099FF\">";
		_loc1_ += _loc2_._exp + "</font> / 季<br>种植等级：<font color=\"#0099FF\">" + _loc2_._lvl + "</font> 级<br/>";
		// `_isFood == true`（Int 与 Boolean 松散比，true→1）
		if (_loc2_._isFood == 1) {
			if (_loc2_._id == 3) {
				_loc1_ += "特殊用途：喂养动物(减少生长时间)<br/>";
			} else {
				_loc1_ += "特殊用途：喂养动物<br/>";
			}
		}
		if (_loc2_._isAdSeed == 1) {
			if (_loc2_._sellTime != "") {
				_loc1_ += "供应时间：" + _loc2_._sellTime + "<br/>";
			}
			if (_loc2_._sellLimitDaily != "") {
				_loc1_ += "每天供应量：<font color=\"#0099FF\">" + _loc2_._sellLimitDaily + "</font> 个<br/>";
			}
			if (_loc2_._sellLimit != "") {
				_loc1_ += "总供应量：<font color=\"#0099FF\">" + _loc2_._sellLimit + "</font> 个<br/>";
			}
		}
		return _loc1_;
	}

	// BuyAdSeedWindow.as:192-195
	override public function keyEnter(param1:KeyboardEvent):Void {
		this.onOK(null);
	}

	// BuyAdSeedWindow.as:197-300
	override private function setData():Void {
		if (this.isInit == false) {
			return;
		}
		var _loc1_:Seed = Std.isOfType(this.data, Seed) ? cast(this.data, Seed) : null;
		if (_loc1_ == null) {
			return;
		}
		this.graphics.clear();
		var _loc2_:Player = Session.getInstance().host;
		if (_loc2_ != null) {
			this._cLevel = _loc2_.level;
			this._userMoney = _loc2_._money;
		}
		if (this._shopSeedForm == null) {
			this._shopSeedForm = Utils.getMaterial("ShopSeedForm");
			if (this._shopSeedForm == null) {
				return;
			}
			cast(this._shopSeedForm, DisplayObject).x = 190;
			cast(this._shopSeedForm, DisplayObject).y = 120;
			addChild(cast(this._shopSeedForm, DisplayObject));
			cast(As3.childOf(this._shopSeedForm, "cropTip"), TextField).addEventListener(TextEvent.LINK, this.onNavigateToURL);
		}
		if (this._cropPrice != null) {
			this._cropPrice.text = Std.string(_loc1_._price);
		}
		if (this._material != null) {
			this._material.setContent("1", _loc1_._id);
		}
		this._numbericStepper.value = 1;
		// BuyAdSeedWindow.as:236-239（原版无守卫，保持无守卫，见类头 PORT-NOTE）
		cast(As3.childOf(this._shopSeedForm, "cropName"), TextField).y = -90;
		cast(As3.childOf(this._shopSeedForm, "cropDetail"), TextField).y = -55;
		cast(As3.childOf(this._shopSeedForm, "cropDetail"), TextField).height = 288;
		cast(As3.childOf(this._shopSeedForm, "cropDetail"), TextField).width = 170;
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
			cast(As3.childOf(this._shopSeedForm, "cropTip"), TextField).htmlText = GetCropID.cropTip(Std.string(_loc1_._id));
		}
		var _loc3_:Int = _loc1_._lvl;
		var _loc4_:Int = _loc1_._price;
		var _loc5_:Int = _loc4_ > 0 ? Std.int(Math.floor(this._userMoney / _loc4_)) : 1;
		if (_loc5_ >= 100) {
			this._directionText.text = Language.replaceText("buyNum", {
				"minNum": 1,
				"maxNum": 99
			});
			this._numbericStepper.maximum = 99;
		} else if (_loc5_ < 100 && _loc5_ >= 1) {
			this._directionText.text = Language.replaceText("buyNum", {
				"minNum": 1,
				"maxNum": _loc5_
			});
			this._numbericStepper.maximum = _loc5_;
		} else if (_loc5_ <= 1) {
			this._directionText.text = Language.replaceText("buyNum", {
				"minNum": 1,
				"maxNum": 1
			});
			this._numbericStepper.maximum = 1;
		}
		if (this._cLevel < _loc3_) {
			this._confirmButton.enabled = false;
			this._errorText.text = Reflect.field(Language.L, "对不起，您的等级不足。");
		} else if (this._userMoney < _loc4_) {
			this._confirmButton.enabled = false;
			this._errorText.text = Reflect.field(Language.L, "对不起，您的金币不足。");
		} else {
			this._errorText.text = "";
			this._confirmButton.enabled = true;
		}
		this.setSize();
	}

	// BuyAdSeedWindow.as:302-375
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
