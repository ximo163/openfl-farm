package module.shop.widgets;

import com.qzone.corelib.controls.ExtLoader;
import com.qzone.qui.controls.Button;
import com.qzone.qui.makers.StepperMaker;
import com.qzone.utils.AlignUtil;
import com.qzone.utils.DisplayUtil;
import com.qzone.utils.StringUtil;
import common.GetCropID;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.MaterialProxyBig;
import common.view.MoneyIcon;
import common.view.window.BaseWindow;
import entities.Player;
import entities.Seed;
import interfaces.IMsgCenter;
import module.shop.ShopView;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.SimpleButton;
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

/**
 * module.shop.widgets.BuySeedWindow —— BuySeedWindow.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。普通种子买入窗：ShopSeedForm 布局
 * + 新品角标/有机角标互斥；VIP 种子支路加 VipSeedBuyBg 背景与「续费」
 * SimpleButton、非 VIP 时钉死数量 1。
 *
 * PORT-NOTE: `form.cropX != undefined` → As3.childOf + null 判；
 * :340-342 对 form/cropName 的**无守卫**读写保持无守卫（原版同样依赖
 * ShopSeedForm 必带该具名子件）；`Boolean(x)` → As3.truthy。
 * onGotoMill 在本类只被 removeEventListener 引用（原版死代码，照抄）。
 */
class BuySeedWindow extends BaseWindow {
	// BuySeedWindow.as:38
	private var _cLevel:Int;

	// BuySeedWindow.as:40
	private var _green:Sprite;

	// BuySeedWindow.as:42
	private var _material:MaterialProxyBig;

	// BuySeedWindow.as:44
	private var _parent:ShopView;

	// BuySeedWindow.as:46（ShopSeedForm 符号，具名子件经 childOf 访问）
	private var _shopSeedForm:Dynamic;

	// BuySeedWindow.as:48
	private var _directionText:TextField;

	// BuySeedWindow.as:50
	private var money:MoneyIcon;

	// BuySeedWindow.as:52
	private var _confirmButton:Button;

	// BuySeedWindow.as:54
	private var _errorText:TextField;

	// BuySeedWindow.as:56
	private var _cropPrice:TextField;

	// BuySeedWindow.as:58
	private var _loader2:ExtLoader;

	// BuySeedWindow.as:60
	private var _newMarkIcon:MovieClip;

	// BuySeedWindow.as:62
	private var _cancelButton:Button;

	// BuySeedWindow.as:64
	private var stepperSkin:DisplayObject;

	// BuySeedWindow.as:66
	private var _numbericStepper:StepperMaker;

	// BuySeedWindow.as:68
	private var _loader:ExtLoader;

	// BuySeedWindow.as:70（Number）
	private var _userMoney:Float;

	// BuySeedWindow.as:72
	private var _vipIcon:MovieClip;

	// BuySeedWindow.as:74
	private var vipRenewalButton:SimpleButton;

	// BuySeedWindow.as:76-84
	public function new(param1:ShopView) {
		super(Std.isOfType(param1.controller.module.app, IMsgCenter) ? cast(param1.controller.module.app, IMsgCenter) : null);
		width = 400;
		height = 390;
		title = Reflect.field(Language.L, "shopSeedWindow");
		mode = true;
		this._parent = param1;
	}

	// BuySeedWindow.as:86-99
	private function onOK(param1:MouseEvent):Void {
		var _loc2_:Seed = null;
		if (this._confirmButton.enabled == true) {
			_loc2_ = Std.isOfType(this.data, Seed) ? cast(this.data, Seed) : null;
			if (_loc2_ == null) {
				return;
			}
			// AS3 buySeeds(int,int) 收 Number → 隐式截断 → Std.int
			this._parent.controller.model.buySeeds(_loc2_._id, Std.int(this._numbericStepper.value));
			super.onClose(param1);
		}
	}

	// BuySeedWindow.as:101-105
	override private function setSize():Void {
		super.setSize();
		panelTitle.x = AlignUtil.middle(_width, panelTitle.width);
	}

	// BuySeedWindow.as:107-110
	private function onNavigateToURL(param1:TextEvent):Void {
		QzoneJSAPI.openWindow(param1.text);
	}

	// BuySeedWindow.as:112-116
	private function onNavigateToURL2(param1:MouseEvent):Void {
		var _loc2_:String = Settings.getInstance().getStringAttribute("vipSeedLink");
		QzoneJSAPI.openWindow(_loc2_);
	}

	// BuySeedWindow.as:118-121
	private function onCancel(param1:MouseEvent):Void {
		super.onClose(param1);
	}

	// BuySeedWindow.as:123-126（原版死代码：本类从未 addEventListener 此函数，照抄）
	private function onGotoMill(param1:MouseEvent):Void {
		QzoneJSAPI.toApp(376, "");
	}

	// BuySeedWindow.as:128-144
	private function addGreenIcon():Void {
		var _loc1_:Sprite = new Sprite();
		_loc1_.graphics.beginFill(52224, 1);
		_loc1_.graphics.drawRect(0, 0, 32, 22);
		_loc1_.graphics.endFill();
		_loc1_.x = 113;
		_loc1_.y = 40;
		addChild(_loc1_);
		var _loc2_:TextField = new TextField();
		_loc2_.defaultTextFormat = new TextFormat("Verdana", 14, 16777215, true);
		_loc2_.text = "有机";
		_loc2_.selectable = false;
		_loc1_.addChild(_loc2_);
		this._green = _loc1_;
		this._green.mouseEnabled = false;
	}

	// BuySeedWindow.as:146-168
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

	// BuySeedWindow.as:170-216
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
			// 越界读走 arrAt/intSub（cropTime 拆分可能不足 5 段，cpp 裸读会崩；
			// AS3 undefined 相减 NaN、int() 截 0，arrAt 的 null→intSub 的 0 同语义）
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
		return _loc1_;
	}

	// BuySeedWindow.as:218-221
	override public function keyEnter(param1:KeyboardEvent):Void {
		this.onOK(null);
	}

	// BuySeedWindow.as:223-432
	override private function setData():Void {
		var _loc6_:String = null;
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
			cast(this._shopSeedForm, DisplayObject).y = 40;
			addChild(cast(this._shopSeedForm, DisplayObject));
			cast(As3.childOf(this._shopSeedForm, "cropTip"), TextField).addEventListener(TextEvent.LINK, this.onNavigateToURL);
		}
		if (this._cropPrice != null) {
			this._cropPrice.text = Std.string(_loc1_._price);
		}
		if (this._material != null) {
			this._material.setContent("1", _loc1_._id);
		}
		if (_loc1_._isNew > 0) {
			this._newMarkIcon.visible = true;
		} else {
			this._newMarkIcon.visible = false;
			if (_loc1_._isGreen == true) {
				this.addGreenIcon();
			} else {
				DisplayUtil.removeChild(this, this._green);
			}
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
		if (!(_loc1_._isMill == 1 && _loc1_._isVip != 1)) {
			// BuySeedWindow.as:340-342（原版无守卫，保持无守卫，见类头 PORT-NOTE）
			cast(this._shopSeedForm, DisplayObject).y = 40;
			cast(As3.childOf(this._shopSeedForm, "cropName"), TextField).x = 0;
			cast(As3.childOf(this._shopSeedForm, "cropName"), TextField).y = 0;
			this.height = 390;
			this._directionText.visible = true;
			this._cropPrice.visible = true;
			this.money.visible = true;
			this._errorText.y = this.height - 65;
			this._confirmButton.y = height - 40;
			this._cancelButton.y = height - 40;
			title = Reflect.field(Language.L, "shopSeedWindow");
			this._confirmButton.text = Reflect.field(Language.L, "确定");
			this._confirmButton.removeEventListener(MouseEvent.CLICK, this.onGotoMill);
			this._confirmButton.addEventListener(MouseEvent.CLICK, this.onOK);
			this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
			this._cancelButton.x = width / 2 + 10;
			if (this.stepperSkin != null) {
				this.stepperSkin.visible = true;
			}
			if (_loc1_._isVip == 1) {
				this._vipIcon.visible = true;
				this._confirmButton.text = "确认购买";
				title = "购买VIP专属种子";
				this._confirmButton.x += 55;
				this._cancelButton.x += 55;
				if (_loc2_._yellowstatus == 0) {
					if (this.stepperSkin != null) {
						this._numbericStepper.maximum = 1;
					}
					this._directionText.text = Language.replaceText("buyNum", {
						"minNum": 1,
						"maxNum": 1
					});
					this._errorText.text = "对不起，您不是VIP用户。";
					this._confirmButton.enabled = false;
				}
				if (this._loader == null) {
					this._loader = new ExtLoader();
					this._loader.y = 25;
					this._loader.x = 1;
					this._loader.load(Settings.getInstance().getSecondUrl("VipSeedBuyBg"));
					addChildAt(this._loader, 1);
				} else {
					this._loader.visible = true;
				}
				if (this._loader2 == null) {
					_loc6_ = _loc2_._yellowstatus != 0 ? Settings.getInstance().getSecondUrl("VipSeedButtonVip") : Settings.getInstance()
						.getSecondUrl("VipSeedButtonNonVip");
					this._loader2 = new ExtLoader();
					this._loader2.load(Utils.addPrefix(_loc6_));
				}
				if (this.vipRenewalButton == null) {
					this.vipRenewalButton = new SimpleButton();
					this.vipRenewalButton.hitTestState = this._loader2;
					this.vipRenewalButton.upState = this._loader2;
					this.vipRenewalButton.downState = this._loader2;
					this.vipRenewalButton.overState = this._loader2;
					this.vipRenewalButton.x = this._confirmButton.x - 117;
					this.vipRenewalButton.y = height - 46;
					this.vipRenewalButton.addEventListener(MouseEvent.CLICK, this.onNavigateToURL2);
					addChild(this.vipRenewalButton);
				} else {
					this.vipRenewalButton.visible = true;
				}
			} else {
				if (As3.truthy(this._loader) && this._loader.visible == true) {
					this._loader.visible = false;
				}
				if (As3.truthy(this.vipRenewalButton) && this.vipRenewalButton.visible == true) {
					this.vipRenewalButton.visible = false;
				}
				if (this._vipIcon.visible == true) {
					this._vipIcon.visible = false;
				}
			}
		}
		this.setSize();
	}

	// BuySeedWindow.as:434-516
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
		this._cancelButton = new Button();
		this._cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
		this._cancelButton.width = 64;
		this._cancelButton.height = 25;
		this._cancelButton.x = width / 2 + 10;
		this._cancelButton.y = height - 40;
		this._cancelButton.text = Reflect.field(Language.L, "取消");
		this._cancelButton.addEventListener(MouseEvent.CLICK, this.onCancel);
		addChild(this._cancelButton);
		this._vipIcon = Std.isOfType(Utils.getMaterial("VipSeedIcon"), MovieClip) ? cast(Utils.getMaterial("VipSeedIcon"), MovieClip) : null;
		this._vipIcon.x = this._material.x + 2;
		this._vipIcon.y = this._material.y + 1;
		this._vipIcon.visible = false;
		addChild(this._vipIcon);
		this._newMarkIcon = Std.isOfType(Utils.getMaterial("ShopNewMarkIcon"), MovieClip)
			? cast(Utils.getMaterial("ShopNewMarkIcon"), MovieClip) : null;
		this._newMarkIcon.x = 85;
		this._newMarkIcon.y = 40;
		addChild(this._newMarkIcon);
	}
}
