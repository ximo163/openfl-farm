package module.shop.widgets;

import com.qzone.qfa.events.CommandEvent;
import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.RadioButton;
import com.qzone.qui.makers.RadioGroup;
import com.qzone.qui.makers.StepperMaker;
import com.qzone.utils.AlignUtil;
import com.qzone.utils.DisplayUtil;
import common.Consts;
import common.Language;
import common.Session;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.MaterialProxyBig;
import common.view.window.BaseWindow;
import common.view.window.WindowLabelMaker;
import entities.Item;
import entities.Player;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import framework.net.vo.ServiceResultVO;
import interfaces.IMsgCenter;
import module.shop.ShopView;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;
import shim.QQOutlets;

/**
 * module.shop.widgets.BuyItemWindow —— BuyItemWindow.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。道具买入窗：金币/元宝直购、VIP 免费
 * （buyToolVIP）与 QQ 币预检（CMD_BUY_PRECHECK）三支路；藏獒（_isQDDog）
 * 换 1/6/12 月单价表；_vip 道具再挂 年费VIP/元宝/暂时无用 单选组。
 * ShopToolForm 的 toolName/toolDetail 时间轴子件经 As3.childOf 取出再读写；
 * QQ 币支路（onOKCFT 的 shopType=3）对应 cgi_farm_tool_vip，本部署不可达
 * （spec/modules/farm-shop-ui.json notes），照抄保留。
 *
 * PORT-NOTE: :737 原版把 `super.onClose` 方法闭包直传 addEventListener——
 * Haxe 不能把 super 调用当值，包具名方法 onCancelClick 等价转发；
 * ExternalInterface → QQOutlets；`toolDetail != undefined` → childOf 判空。
 */
class BuyItemWindow extends BaseWindow {
	// BuyItemWindow.as:38
	private var _cftButton:Button;

	// BuyItemWindow.as:40
	private var _material:MaterialProxyBig;

	// BuyItemWindow.as:42
	private var _specialDogPrice:TextField;

	// BuyItemWindow.as:44
	private var rbtnVip:RadioButton;

	// BuyItemWindow.as:46
	private var _confirmButton:Button;

	// BuyItemWindow.as:48
	private var _cancelButton:Button;

	// BuyItemWindow.as:50
	private var _dogTipText:TextField;

	// BuyItemWindow.as:52
	private var rbtnBuy1:RadioButton;

	// BuyItemWindow.as:54
	private var rbtnBuy2:RadioButton;

	// BuyItemWindow.as:56
	private var rbtnBuy3:RadioButton;

	// BuyItemWindow.as:58（SteperSkin 符号类，root 包直名引用）
	private var _steperSkin:Sprite;

	// BuyItemWindow.as:60
	private var rbtnQB:RadioButton;

	// BuyItemWindow.as:62
	private var radioGroup:RadioGroup;

	// BuyItemWindow.as:64
	private var linkText:TextField;

	// BuyItemWindow.as:66
	private var _parent:ShopView;

	// BuyItemWindow.as:68
	private var _directionText:TextField;

	// BuyItemWindow.as:70
	private var radioGroupDog:RadioGroup;

	// BuyItemWindow.as:72
	private var _errorText:TextField;

	// BuyItemWindow.as:74
	private var rbtnCFT:RadioButton;

	// BuyItemWindow.as:76
	private var textDefaultFormat:TextFormat;

	// BuyItemWindow.as:78
	private var _numbericStepper:StepperMaker;

	// BuyItemWindow.as:80
	private var _label:Label;

	// BuyItemWindow.as:82（ShopToolForm 符号，具名子件经 childOf 访问）
	private var _shopToolForm:Dynamic;

	// BuyItemWindow.as:84-92
	public function new(param1:ShopView) {
		super(Std.isOfType(param1.controller.module.app, IMsgCenter) ? cast(param1.controller.module.app, IMsgCenter) : null);
		width = 400;
		height = 320;
		title = Reflect.field(Language.L, "shopToolWindow");
		mode = true;
		this._parent = param1;
	}

	// BuyItemWindow.as:94-135
	private function overflow(param1:Int):Void {
		var _loc4_:Int = 0;
		var _loc5_:Float = Math.NaN;
		var _loc2_:Item = Std.isOfType(this.data, Item) ? cast(this.data, Item) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Player = Session.getInstance().host;
		if (_loc3_ != null) {
			_loc5_ = _loc3_._money;
			_loc4_ = _loc3_._fb;
		}
		if (_loc2_._price != 0) {
			if (_loc5_ < _loc2_._price * param1) {
				this._confirmButton.enabled = false;
				this._errorText.text = Reflect.field(Language.L, "对不起，您的金币不足。");
			} else {
				this._confirmButton.enabled = true;
				this._errorText.text = "";
			}
		} else if (_loc4_ > 0) {
			if (_loc4_ < _loc2_._fb * param1) {
				this._confirmButton.enabled = false;
				this._errorText.text = Reflect.field(Language.L, "您的元宝不足。");
			} else {
				this._confirmButton.enabled = true;
				this._errorText.text = "";
			}
		}
	}

	// BuyItemWindow.as:137-149
	override private function setSize():Void {
		super.setSize();
		var _loc1_:Item = Std.isOfType(this.data, Item) ? cast(this.data, Item) : null;
		if (_loc1_ == null) {
			return;
		}
		if (panelTitle != null) {
			panelTitle.x = AlignUtil.middle(width, panelTitle.width);
		}
	}

	// BuyItemWindow.as:151-187
	private function onOKCFT(param1:MouseEvent):Void {
		if (this._cftButton.enabled == false) {
			return;
		}
		var _loc2_:Item = Std.isOfType(this.data, Item) ? cast(this.data, Item) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Int = Std.int(this._numbericStepper.value);
		var _loc4_:Int = _loc2_._id;
		var _loc5_:Int = _loc2_._type;
		if (Std.string(_loc5_) == Consts.ITEM_TYPE_DOGFOOD) {
			_loc5_ = 4;
		}
		var _loc6_:Int = 3;
		if (_loc5_ == 4 || _loc5_ == 10 || _loc5_ == 24) {
			_loc6_ = _loc5_;
		}
		var _loc7_:Int = _loc5_ == 4 ? Std.int(As3.parseInt(Consts.ITEM_TYPE_DOGFOOD)) : _loc5_;
		if (_loc7_ == As3.parseInt(Consts.ITEM_TYPE_DOGFOOD) && _loc4_ < 9000) {
			_loc6_ = 7;
			_loc7_ = 4;
		}
		NetHelper.sendRequest(CommandDefs.CMD_BUY_PRECHECK, {
			"shopType": _loc6_,
			"itemType": _loc7_,
			"itemId": _loc4_,
			"itemNum": _loc3_
		}, this.qqBuyCFTPreChecked, this.onPreCheckedError);
		super.close();
	}

	// BuyItemWindow.as:189-197
	private function onNumChanged(param1:Event):Void {
		var _loc2_:Int = Std.int(this._numbericStepper.value);
		this.overflow(_loc2_);
		if (this._shopToolForm != null && As3.childOf(this._shopToolForm, "toolDetail") != null) {
			cast(As3.childOf(this._shopToolForm, "toolDetail"), TextField).htmlText = this.buildContent();
		}
	}

	// BuyItemWindow.as:199-218
	private function onPreCheckedError(param1:CommandEvent):Void {
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = _loc2_.m_extra;
		if (_loc3_ == null) {
			return;
		}
		if (As3.hasProp(_loc3_, "direction") == true) {
			this._parent.controller.openWindow(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_ERROR,
				"text": Reflect.field(_loc3_, "direction")
			});
		}
	}

	// BuyItemWindow.as:220-227
	private function getTextDisabledFormat():TextFormat {
		if (this.textDefaultFormat == null) {
			this.textDefaultFormat = new TextFormat("Verdana", 12, 8947848, null, null, null, null, null, "left");
		}
		return this.textDefaultFormat;
	}

	// BuyItemWindow.as:229-248
	private function qqBuyPreChecked(param1:CommandEvent):Void {
		var _loc4_:Item = null;
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = _loc2_.m_extra;
		if (_loc3_ == null) {
			return;
		}
		if (As3.eqString(Reflect.field(_loc3_, "code"), "1")) {
			_loc4_ = Std.isOfType(this.data, Item) ? cast(this.data, Item) : null;
			this._parent.controller.model.buyInGame(Reflect.field(param1.body, "__body"), 1, "Item", 0, Std.string(_loc4_._type));
			return;
		}
	}

	// BuyItemWindow.as:250-255
	private function setRaidoStyle(param1:RadioButton):Void {
		param1.textDefaultFormat = this.getTextDefaultFormat();
		param1.textDisabledFormat = this.getTextDisabledFormat();
		param1.textSelectedFormat = this.getTextDefaultFormat();
	}

	// BuyItemWindow.as:737（原版把 super.onClose 当值传 addEventListener，
	// 见类头 PORT-NOTE；转发事件参量）
	private function onCancelClick(param1:MouseEvent):Void {
		super.onClose(param1);
	}

	// BuyItemWindow.as:257-484
	override private function setData():Void {
		var _loc4_:Int = 0;
		var _loc5_:Player = null;
		height = 320;
		this._confirmButton.y = height - 55;
		this._cancelButton.y = height - 55;
		this._label.y = height - this._label.height - 4;
		if (this.isInit == false) {
			return;
		}
		var _loc1_:Item = Std.isOfType(this.data, Item) ? cast(this.data, Item) : null;
		if (_loc1_ == null) {
			return;
		}
		this.graphics.clear();
		if (_loc1_._renew) {
			title = "来自藏獒的一封信";
			this._dogTipText.htmlText = "续费有效期：";
			cast(As3.childOf(this._shopToolForm, "toolName"), TextField).visible = false;
			cast(As3.childOf(this._shopToolForm, "toolDetail"), TextField).y = 10;
			cast(As3.childOf(this._shopToolForm, "toolDetail"), TextField).width = 220;
		} else {
			title = Reflect.field(Language.L, "shopToolWindow");
			this._dogTipText.htmlText = "领养有效期：";
			cast(As3.childOf(this._shopToolForm, "toolName"), TextField).visible = true;
			cast(As3.childOf(this._shopToolForm, "toolDetail"), TextField).y = 40;
			cast(As3.childOf(this._shopToolForm, "toolDetail"), TextField).width = 240;
		}
		var _loc2_:Int = 1;
		if (this._numbericStepper != null) {
			this._numbericStepper.value = _loc2_;
		}
		var _loc3_:String = Std.string(_loc1_._type);
		if (this._material != null) {
			this._material.setContent(_loc3_, _loc1_._id);
		}
		if (this._shopToolForm != null) {
			_loc4_ = _loc1_._name.length > 8 ? 22 : 26;
			cast(As3.childOf(this._shopToolForm, "toolName"), TextField).defaultTextFormat = new TextFormat("Verdana", _loc4_, 3381555, true);
			cast(As3.childOf(this._shopToolForm, "toolName"), TextField).text = _loc1_._name;
			if (_loc3_ == Consts.ITEM_TYPE_TOOL || _loc3_ == Consts.ITEM_TYPE_WEAPON || _loc3_ == Consts.ITEM_TYPE_FISHFEED) {
				if (this._directionText != null) {
					this._directionText.visible = true;
				}
				if (this._steperSkin != null) {
					this._steperSkin.visible = true;
				}
			} else if (_loc3_ == Consts.ITEM_TYPE_DOGFOOD) {
				if (this._steperSkin != null) {
					this._steperSkin.visible = true;
				}
				if (this._directionText != null) {
					this._directionText.visible = true;
				}
			} else {
				if (this._directionText != null) {
					this._directionText.visible = false;
				}
				if (this._steperSkin != null) {
					this._steperSkin.visible = false;
				}
			}
			if (As3.childOf(this._shopToolForm, "toolDetail") != null) {
				cast(As3.childOf(this._shopToolForm, "toolDetail"), TextField).htmlText = this.buildContent();
			}
		}
		this._errorText.htmlText = "";
		this._confirmButton.enabled = true;
		this.overflow(_loc2_);
		if (_loc3_ == Consts.ITEM_TYPE_TOOL && _loc1_._saleOut == true) {
			if (this._errorText != null) {
				this._errorText.htmlText = "";
			}
			this._confirmButton.enabled = false;
		} else if (_loc3_ == Consts.ITEM_TYPE_DOGFOOD && _loc1_._saleOut == true) {
			if (this._errorText != null) {
				this._errorText.htmlText = "";
			}
			this._confirmButton.enabled = false;
		}
		if (_loc1_._fb != 0 && !_loc1_._isQDDog) {
			this._confirmButton.text = "用元宝购买";
			this._confirmButton.width = 85;
			if (_loc3_ == Consts.ITEM_TYPE_WEAPON) {
				this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
				this._cancelButton.x = width / 2 + 10;
				if (this._cftButton.parent != null) {
					this._cftButton.parent.removeChild(this._cftButton);
				}
			} else {
				this._confirmButton.x = width / 2 - this._confirmButton.width - 65;
				this._cancelButton.x = width / 2 + this._cancelButton.width;
				if (this._cftButton.parent == null) {
					addChild(this._cftButton);
				}
			}
		} else {
			this._confirmButton.text = Reflect.field(Language.L, "确定");
			this._confirmButton.width = 64;
			this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
			this._cancelButton.x = width / 2 + 10;
			if (this._cftButton.parent != null) {
				this._cftButton.parent.removeChild(this._cftButton);
			}
		}
		if (_loc1_._id <= 3 && _loc3_ == Consts.ITEM_TYPE_TOOL || _loc1_._id == 9001) {
			this._label.visible = true;
		} else {
			this._label.visible = false;
		}
		DisplayUtil.removeChild(this, this.rbtnVip);
		DisplayUtil.removeChild(this, this.rbtnQB);
		DisplayUtil.removeChild(this, this.rbtnCFT);
		DisplayUtil.removeChild(this, this.linkText);
		this.radioGroup = new RadioGroup();
		if (_loc1_._vip == 1 && _loc3_ == Consts.ITEM_TYPE_TOOL) {
			this.rbtnVip.selected = false;
			this.rbtnQB.selected = false;
			this.rbtnCFT.selected = false;
			this.radioGroup.addTarget(this.rbtnVip);
			this.radioGroup.addTarget(this.rbtnQB);
			this.radioGroup.addTarget(this.rbtnCFT);
			addChild(this.rbtnVip);
			addChild(this.rbtnQB);
			addChild(this.rbtnCFT);
			addChild(this.linkText);
			_loc5_ = Session.getInstance().host;
			if (_loc5_._yellowstatus != 2) {
				this.rbtnVip.enabled = false;
				this.rbtnQB.selected = true;
				this.radioGroup.selectedTarget = this.rbtnQB;
			} else {
				this.rbtnVip.enabled = true;
				this.rbtnVip.selected = true;
				this.radioGroup.selectedTarget = this.rbtnVip;
			}
			this._confirmButton.text = Reflect.field(Language.L, "确定");
			this._confirmButton.width = 64;
			this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
			this._cancelButton.x = width / 2 + 10;
			DisplayUtil.removeChild(this, this._cftButton);
			height = 360;
			this._confirmButton.y = height - 55;
			this._cancelButton.y = height - 55;
			this._label.y = height - this._label.height - 4;
		}
		if (_loc1_._shortage == true) {
			if (this._errorText != null) {
				this._errorText.htmlText = "";
			}
			this._confirmButton.enabled = false;
			this._cftButton.enabled = false;
		}
		DisplayUtil.removeChild(this, this.rbtnBuy1);
		DisplayUtil.removeChild(this, this.rbtnBuy2);
		DisplayUtil.removeChild(this, this.rbtnBuy3);
		if (_loc1_._isQDDog) {
			this.rbtnBuy1.selected = false;
			this.rbtnBuy2.selected = false;
			this.rbtnBuy3.selected = true;
			addChild(this.rbtnBuy1);
			addChild(this.rbtnBuy2);
			addChild(this.rbtnBuy3);
			this.radioGroupDog.selectedTarget = this.rbtnBuy3;
			this._confirmButton.text = Reflect.field(Language.L, "确定");
			this._confirmButton.width = 64;
			this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
			this._cancelButton.x = width / 2 + 10;
			DisplayUtil.removeChild(this, this._cftButton);
			height = 330;
			this._confirmButton.y = height - 55;
			this._cancelButton.y = height - 55;
			this._specialDogPrice.visible = true;
			this._specialDogPrice.htmlText = this.buildDogPriceText();
			this._dogTipText.visible = true;
		} else {
			this._specialDogPrice.visible = false;
			this._specialDogPrice.htmlText = "";
			this._dogTipText.visible = false;
		}
	}

	// BuyItemWindow.as:486-504
	private function qqBuyCFTPreChecked(param1:CommandEvent):Void {
		var _loc4_:Item = null;
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = _loc2_.m_extra;
		if (_loc3_ == null) {
			return;
		}
		if (As3.eqString(Reflect.field(_loc3_, "code"), "1")) {
			_loc4_ = Std.isOfType(this.data, Item) ? cast(this.data, Item) : null;
			this._parent.controller.model.buyInGame(Reflect.field(param1.body, "__body"), 2, "Item", 0, Std.string(_loc4_._type));
		}
	}

	// BuyItemWindow.as:506-509
	private function onRadioBtnChanged(param1:Event):Void {
		this._specialDogPrice.htmlText = this.buildDogPriceText();
	}

	// BuyItemWindow.as:511-579
	private function buildContent():String {
		var _loc1_:String = "";
		var _loc2_:Item = Std.isOfType(this.data, Item) ? cast(this.data, Item) : null;
		if (_loc2_ == null) {
			return _loc1_;
		}
		var _loc3_:String = Std.string(_loc2_._type);
		var _loc4_:Int = 0;
		if (_loc2_._renew) {
			return "亲爱的主人：<br>我的工作时间仅剩<font color = '#FF0000'size = '18'> " + _loc2_._timeLimit
				+ " </font>天，快为我续费吧，续费后我将能继续为您抓好多好多坏人，打跑好多好多野生动物，赚好多好多金币！<br><p align='right'>藏獒</p>";
		}
		if (this._numbericStepper != null && !_loc2_._isQDDog) {
			_loc4_ = Std.int(this._numbericStepper.value);
			if (_loc2_._price != 0) {
				_loc1_ += "金币价：<font size=\"11\" color=\"#FF6600\"><b>" + _loc2_._price * _loc4_ + "</b></font> <font color=\"#CC3300\">金币</font><br>";
			} else {
				_loc1_ += "<textformat indent=\"2\">元宝价</textformat>：普通 <font size=\"11\" color=\"#0099FF\"><b>" + _loc2_._fb * _loc4_
					+ "</b></font> <font color=\"#003366\">元宝</font><br>";
				_loc1_ += "特惠价：VIP <font size=\"11\" color=\"#FF6600\"><b>" + _loc2_._yfb * _loc4_
					+ "</b></font> <font color=\"#003366\">元宝</font> (节省 <font size=\"11\" color=\"#FF6600\"><b>";
				_loc1_ += _loc2_._fb * _loc4_ - _loc2_._yfb * _loc4_ + "</b></font> <font color=\"#003366\">元宝</font>)<br />";
				_loc1_ += "<p align=\"right\"><font size=\"12\" color=\"#666666\"></font></p>";
			}
		}
		if (_loc3_ == Consts.ITEM_TYPE_TOOL) {
			if (_loc2_._id == 34) {
				_loc1_ += "类　型：翻倍刷新<br />";
			} else {
				_loc1_ += "类　型：化肥<br />";
				if (_loc2_._id == 6 || _loc2_._id == 5) {
					_loc1_ += "道具类型：特殊道具<br />";
				}
			}
		} else if (_loc3_ == Consts.ITEM_TYPE_DOGFOOD) {
			_loc1_ += "类　型：狗粮<br />";
		} else if (_loc3_ == Consts.ITEM_TYPE_DOG) {
			if (_loc2_._isQDDog == true) {
				_loc1_ += "类　型：特供狗<br />";
			} else {
				_loc1_ += "类　型：狗<br />";
			}
			if (_loc2_._id <= 4) {
				_loc1_ += "<font size=\"12\" color=\"#BF7746\">购买此狗，即可获赠价值4 元宝 狗粮。</font><br />";
			}
		} else if (_loc3_ == Consts.ITEM_TYPE_FISHFEED) {
			_loc1_ += "类　型：鱼食<br />";
		}
		return _loc1_ + ("说　明：" + _loc2_._desc + "<br />");
	}

	// BuyItemWindow.as:581-614
	private function onOKGoldConfirm(param1:MouseEvent):Void {
		var _loc3_:Int = 0;
		if (this._confirmButton.enabled == false) {
			return;
		}
		var _loc2_:Item = Std.isOfType(this.data, Item) ? cast(this.data, Item) : null;
		if (_loc2_ == null) {
			return;
		}
		if (_loc2_._vip == 1 && Std.string(_loc2_._type) == Consts.ITEM_TYPE_TOOL) {
			if (this.radioGroup.selectedTarget == this.rbtnQB) {
				this.onOKGold(null);
			} else if (this.radioGroup.selectedTarget == this.rbtnCFT) {
				this.onOKCFT(null);
			} else if (this.radioGroup.selectedTarget == this.rbtnVip) {
				_loc3_ = Std.int(this._numbericStepper.value);
				this._parent.controller.model.buyToolVIP(_loc2_._id, _loc3_);
				super.onClose(param1);
			}
		} else {
			this.onOKGold(null);
		}
	}

	// BuyItemWindow.as:616-643
	private function buildDogPriceText():String {
		var _loc1_:String = "";
		var _loc2_:Item = Std.isOfType(this.data, Item) ? cast(this.data, Item) : null;
		if (_loc2_ == null || _loc2_._isQDDog == false) {
			return _loc1_;
		}
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		if (this.radioGroupDog.selectedTarget == this.rbtnBuy1) {
			_loc3_ = _loc2_._buy_1;
			_loc4_ = _loc2_._Ybuy_1;
		} else if (this.radioGroupDog.selectedTarget == this.rbtnBuy2) {
			_loc3_ = _loc2_._buy_6;
			_loc4_ = _loc2_._Ybuy_6;
		} else if (this.radioGroupDog.selectedTarget == this.rbtnBuy3) {
			_loc3_ = _loc2_._buy_12;
			_loc4_ = _loc2_._Ybuy_12;
		}
		_loc1_ += "<textformat indent=\"2\">元宝价</textformat>：普通 <font size=\"11\" color=\"#0099FF\"><b>" + _loc3_
			+ "</b></font> <font color=\"#003366\">元宝</font><br>";
		return _loc1_ + ("特惠价：VIP <font size=\"11\" color=\"#FF6600\"><b>" + _loc4_ + "</b></font> <font color=\"#003366\">元宝</font>");
	}

	// BuyItemWindow.as:645-648
	private function onLinkUpgradeClicked(param1:TextEvent):Void {
		QzoneJSAPI.openWindow("");
	}

	// BuyItemWindow.as:650-657
	private function getTextDefaultFormat():TextFormat {
		if (this.textDefaultFormat == null) {
			this.textDefaultFormat = new TextFormat("Verdana", 12, 0, null, null, null, null, null, "left");
		}
		return this.textDefaultFormat;
	}

	// BuyItemWindow.as:659-667
	private function onNavigateToURL(param1:TextEvent):Void {
		var _loc2_:String = param1.text;
		if (_loc2_ == "" || QQOutlets.available == false) {
			return;
		}
		QQOutlets.call("window.open", _loc2_);
	}

	// BuyItemWindow.as:669-805
	override private function addedToLayer():Void {
		super.addedToLayer();
		this._material = new MaterialProxyBig();
		this._material.x = 20;
		this._material.y = 50;
		addChild(this._material);
		this._numbericStepper = new StepperMaker();
		this._numbericStepper.maximum = 99;
		this._numbericStepper.minimum = 1;
		this._numbericStepper.value = 1;
		this._numbericStepper.addEventListener(Event.CHANGE, this.onNumChanged);
		this._steperSkin = new SteperSkin();
		this._steperSkin.x = 30;
		this._steperSkin.y = 182;
		this._numbericStepper.setSkin(this._steperSkin);
		addChild(this._steperSkin);
		this._shopToolForm = Utils.getMaterial("ShopToolForm");
		cast(this._shopToolForm, Sprite).x = 190;
		cast(this._shopToolForm, Sprite).y = 40;
		addChild(cast(this._shopToolForm, Sprite));
		this._errorText = new TextField();
		this._errorText.mouseEnabled = true;
		this._errorText.selectable = false;
		this._errorText.x = 0;
		this._errorText.y = this.height - 80;
		this._errorText.width = 400;
		this._errorText.height = 21;
		this._errorText.defaultTextFormat = new TextFormat("Verdana", 12, 13369344, null, null, null, null, null, TextFormatAlign.CENTER);
		this._errorText.text = "";
		this._errorText.addEventListener(TextEvent.LINK, this.onNavigateToURL);
		addChild(this._errorText);
		this._directionText = new TextField();
		this._directionText.selectable = false;
		this._directionText.x = 20;
		this._directionText.y = 210;
		this._directionText.width = 150;
		this._directionText.height = 22;
		this._directionText.defaultTextFormat = new TextFormat("Verdana", 12, 6710886);
		this._directionText.text = Language.replaceText("buyNum", {
			"minNum": 1,
			"maxNum": 99
		});
		addChild(this._directionText);
		this._confirmButton = new Button();
		this._confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
		this._confirmButton.width = 64;
		this._confirmButton.height = 25;
		this._confirmButton.text = Reflect.field(Language.L, "确定");
		this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
		this._confirmButton.y = height - 55;
		this._confirmButton.addEventListener(MouseEvent.CLICK, this.onOKGoldConfirm);
		addChild(this._confirmButton);
		this._cftButton = new Button();
		this._cftButton.defaultSkin = Utils.getClass("ButtonOrange");
		this._cftButton.width = 95;
		this._cftButton.height = 25;
		this._cftButton.x = (width - this._cftButton.width) / 2;
		this._cftButton.y = height - 55;
		this._cftButton.text = "暂时无用";
		this._cftButton.addEventListener(MouseEvent.CLICK, this.onOKCFT);
		this._cancelButton = new Button();
		this._cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
		this._cancelButton.width = 64;
		this._cancelButton.height = 25;
		this._cancelButton.x = width / 2 + 10;
		this._cancelButton.y = height - 55;
		this._cancelButton.text = Reflect.field(Language.L, "取消");
		this._cancelButton.addEventListener(MouseEvent.CLICK, this.onCancelClick);
		addChild(this._cancelButton);
		var _loc1_:String = "";
		this._label = new Label(_loc1_);
		this._label.addEventListener(TextEvent.LINK, this.onNavigateToURL);
		this._label.width = width - 3;
		this._label.x = 1;
		this._label.y = height - this._label.height - 4;
		this._label.mouseChildren = true;
		WindowLabelMaker.addTarget(this._label);
		var _loc2_:TextFormat = new TextFormat("Verdana", null, null, null, null, null, null, null, "center");
		this._label.textDefaultFormat = _loc2_;
		addChild(this._label);
		this.rbtnVip = new RadioButton("年费VIP免费使用");
		this.setRaidoStyle(this.rbtnVip);
		this.rbtnVip.x = 68;
		this.rbtnVip.y = this._directionText.y + this._directionText.height + 10;
		this.rbtnQB = new RadioButton("元宝买");
		this.setRaidoStyle(this.rbtnQB);
		this.rbtnQB.x = 68;
		this.rbtnQB.y = this.rbtnVip.y + 25;
		this.rbtnCFT = new RadioButton("暂时无用");
		this.setRaidoStyle(this.rbtnCFT);
		this.rbtnCFT.x = 148;
		this.rbtnCFT.y = this.rbtnVip.y + 25;
		this.linkText = new TextField();
		this.linkText.multiline = false;
		this.linkText.height = 20;
		this.linkText.htmlText = "";
		this.linkText.addEventListener(TextEvent.LINK, this.onLinkUpgradeClicked);
		this.linkText.x = this.rbtnVip.x + this.rbtnVip.width + 30;
		this.linkText.y = this.rbtnVip.y;
		addChild(this.linkText);
		this._specialDogPrice = new TextField();
		this._specialDogPrice.selectable = false;
		this._specialDogPrice.x = 10;
		this._specialDogPrice.y = 176;
		this._specialDogPrice.width = 150;
		this._specialDogPrice.height = 40;
		this._specialDogPrice.defaultTextFormat = new TextFormat("Verdana", 12);
		this._specialDogPrice.multiline = true;
		addChild(this._specialDogPrice);
		this._specialDogPrice.visible = false;
		this._dogTipText = new TextField();
		this._dogTipText.multiline = false;
		this._dogTipText.height = 20;
		this._dogTipText.htmlText = "领养有效期：";
		this._dogTipText.x = 48;
		this._dogTipText.y = this._directionText.y + this._directionText.height;
		addChild(this._dogTipText);
		this._dogTipText.visible = false;
		this.rbtnBuy1 = new RadioButton("1个月");
		this.setRaidoStyle(this.rbtnBuy1);
		this.rbtnBuy1.x = this._dogTipText.x + 75;
		this.rbtnBuy1.y = this._dogTipText.y;
		this.rbtnBuy2 = new RadioButton("6个月");
		this.setRaidoStyle(this.rbtnBuy2);
		this.rbtnBuy2.x = this.rbtnBuy1.x + 60;
		this.rbtnBuy2.y = this.rbtnBuy1.y;
		this.rbtnBuy3 = new RadioButton("12个月");
		this.setRaidoStyle(this.rbtnBuy3);
		this.rbtnBuy3.x = this.rbtnBuy1.x + 120;
		this.rbtnBuy3.y = this.rbtnBuy1.y;
		this.radioGroupDog = new RadioGroup();
		this.radioGroupDog.addTarget(this.rbtnBuy1);
		this.radioGroupDog.addTarget(this.rbtnBuy2);
		this.radioGroupDog.addTarget(this.rbtnBuy3);
		this.radioGroupDog.addEventListener(Event.CHANGE, this.onRadioBtnChanged);
	}

	// BuyItemWindow.as:807-879
	private function onOKGold(param1:MouseEvent):Void {
		var _loc8_:Int = 0;
		var _loc9_:Int = 0;
		if (this._confirmButton.enabled == false) {
			return;
		}
		var _loc2_:Player = Session.getInstance().host;
		var _loc3_:Item = Std.isOfType(this.data, Item) ? cast(this.data, Item) : null;
		if (_loc3_ == null) {
			return;
		}
		var _loc4_:Bool = false;
		if (_loc3_._price == 0) {
			_loc4_ = true;
		}
		var _loc5_:Int = _loc3_._type;
		var _loc6_:Int = Std.int(this._numbericStepper.value);
		if (_loc3_._isQDDog) {
			if (this.radioGroupDog.selectedTarget == this.rbtnBuy1) {
				_loc6_ = 1;
			} else if (this.radioGroupDog.selectedTarget == this.rbtnBuy2) {
				_loc6_ = 6;
			} else if (this.radioGroupDog.selectedTarget == this.rbtnBuy3) {
				_loc6_ = 12;
			}
		}
		if (!_loc4_ && Std.string(_loc5_) == Consts.ITEM_TYPE_WEAPON) {
			this._parent.controller.model.buyWeapon(_loc3_._id, _loc6_, _loc5_);
			super.onClose(param1);
			return;
		}
		if (Std.string(_loc5_) == Consts.ITEM_TYPE_DOGFOOD) {
			_loc5_ = 4;
		}
		var _loc7_:Int = _loc2_._yellowstatus >= 1 ? _loc3_._yfb : _loc3_._fb;
		if (_loc4_ == false) {
			this._parent.controller.model.buyTool(_loc3_._id, _loc6_, _loc5_, _loc4_, _loc3_._name, _loc7_);
		} else {
			_loc8_ = 3;
			if (_loc5_ == 4 || _loc5_ == 10 || _loc5_ == 24) {
				_loc8_ = _loc5_;
			}
			_loc9_ = _loc5_ == 4 ? Std.int(As3.parseInt(Consts.ITEM_TYPE_DOGFOOD)) : _loc5_;
			if (_loc9_ == As3.parseInt(Consts.ITEM_TYPE_DOGFOOD) && _loc3_._id < 9000) {
				_loc8_ = 7;
				_loc9_ = 4;
			}
			NetHelper.sendRequest(CommandDefs.CMD_BUY_PRECHECK, {
				"shopType": _loc8_,
				"itemType": _loc9_,
				"itemId": _loc3_._id,
				"itemNum": _loc6_
			}, this.qqBuyPreChecked, this.onPreCheckedError);
		}
		super.onClose(param1);
	}
}
