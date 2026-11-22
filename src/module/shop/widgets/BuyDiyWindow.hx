package module.shop.widgets;

import com.qzone.qfa.events.CommandEvent;
import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.RadioButton;
import com.qzone.qui.makers.RadioGroup;
import com.qzone.utils.AlignUtil;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.MaterialProxy;
import common.view.window.AddButtonWindow;
import common.view.window.WindowLabelMaker;
import entities.DIYDecor;
import entities.Player;
import events.CommonEvent;
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

/**
 * module.shop.widgets.BuyDiyWindow —— BuyDiyWindow.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。装饰买入窗（AddButtonWindow 骨架）：
 * VIP免费/金币/元宝/暂时无用四路单选，金币/元宝预检走 CMD_BUY_PRECHECK，
 * QQ 币支路（useCFTBuy）保留原样但对应 cgi 在本部署不可达（cgi_farm_tool_vip
 * 未配置）。
 *
 * PORT-NOTE: :136 原版把 `super.close` 方法闭包直传 addButton——Haxe 不能
 * 把 super 调用当值，包具名方法 onSuperCloseClick 等价转发。
 * `_form.diyName as TextField` 等时间轴子件 → As3.childOf + cast；
 * `new _loc4_() as Sprite`（Class 变量实例化）→ Type.createInstance +
 * isOfType 判；AS3 链式赋值 `a = b = c` Haxe 无此表达式，按求值序
 * （先 b=c、再 a=b 的新值）拆开。
 */
class BuyDiyWindow extends AddButtonWindow {
	// BuyDiyWindow.as:37
	private var _postCache:Dynamic;

	// BuyDiyWindow.as:39
	private var radioGroup:RadioGroup;

	// BuyDiyWindow.as:41
	private var linkText:TextField;

	// BuyDiyWindow.as:43
	private var _parent:ShopView;

	// BuyDiyWindow.as:45
	private var rbtnDiy:RadioButton;

	// BuyDiyWindow.as:47
	private var _material:MaterialProxy;

	// BuyDiyWindow.as:49
	private var _directionText:TextField;

	// BuyDiyWindow.as:51
	private var rbtnJB:RadioButton;

	// BuyDiyWindow.as:53（ShopDiyForm 符号，具名子件经 childOf 访问）
	private var _form:Dynamic;

	// BuyDiyWindow.as:55
	private var rbtnCFT:RadioButton;

	// BuyDiyWindow.as:57
	private var _btnConfirm:Button;

	// BuyDiyWindow.as:59
	private var textDefaultFormat:TextFormat;

	// BuyDiyWindow.as:61
	private var _label:Label;

	// BuyDiyWindow.as:63
	private var rbtnQB:RadioButton;

	// BuyDiyWindow.as:65-79
	public function new(param1:ShopView) {
		super(Std.isOfType(param1.controller.module.app, IMsgCenter) ? cast(param1.controller.module.app, IMsgCenter) : null);
		width = 430;
		height = 340;
		title = Reflect.field(Language.L, "购买装饰");
		windowName = Consts.WINDOW_NAME_BUYDIY;
		mode = true;
		this._form = null;
		this._directionText = null;
		this._material = null;
		this._parent = param1;
		this._postCache = null;
		this._btnConfirm = null;
	}

	// BuyDiyWindow.as:81-154
	private function createView():Void {
		var _loc6_:Sprite = null;
		var _loc7_:Sprite = null;
		removeAllButton();
		// AS3 的 `||` 作用在 getDynamicTip 的返回值上 → As3.or
		var _loc1_:String = As3.or(Settings.getInstance().getDynamicTip("shopVipDIYTip"), "稀有装扮限时购买");
		this._label = new Label(_loc1_);
		this._label.width = width - 5;
		this._label.x = 1;
		this._label.y = 27;
		this._label.mouseChildren = true;
		WindowLabelMaker.addTarget(this._label);
		var _loc2_:TextFormat = new TextFormat("Verdana", null, null, null, null, null, null, null, "center");
		this._label.textDefaultFormat = _loc2_;
		addChild(this._label);
		var _loc3_:Button = new Button();
		_loc3_.defaultSkin = Utils.getClass("ButtonBlue");
		_loc3_.text = "预览";
		_loc3_.width = 60;
		_loc3_.height = 25;
		_loc3_.x = 50;
		_loc3_.y = 182;
		this.addChild(_loc3_);
		_loc3_.addEventListener(MouseEvent.CLICK, this.onPreview);
		this._form = Utils.getMaterial("ShopDiyForm");
		if (this._form != null) {
			cast(this._form, Sprite).x = 190;
			cast(this._form, Sprite).y = 40;
			addChild(cast(this._form, Sprite));
		}
		this._directionText = new TextField();
		this._directionText.defaultTextFormat = new TextFormat("Verdana", 12, 13369344, false, null, null, null, null,
			TextFormatAlign.CENTER);
		this._directionText.width = 400;
		this._directionText.height = 21;
		this._directionText.x = 0;
		this._directionText.y = this.height - 65;
		this._directionText.selectable = false;
		addWindowChild(this._directionText);
		var _loc4_:Class<Dynamic> = Utils.getClass("ItemBorder");
		if (_loc4_ != null) {
			_loc6_ = Std.isOfType(Type.createInstance(_loc4_, []), Sprite) ? cast(Type.createInstance(_loc4_, []), Sprite) : null;
			_loc7_ = Std.isOfType(Type.createInstance(_loc4_, []), Sprite) ? cast(Type.createInstance(_loc4_, []), Sprite) : null;
			// AS3 链式赋值（_loc7_.width = _loc6_.width = 120）按求值序拆开
			_loc6_.width = 120;
			_loc7_.width = _loc6_.width;
			_loc6_.height = 120;
			_loc7_.height = _loc6_.height;
			this._material = new MaterialProxy(MaterialProxy.BIG);
			_loc6_.x = 20;
			_loc7_.x = _loc6_.x;
			this._material.x = _loc7_.x;
			_loc6_.y = 50;
			_loc7_.y = _loc6_.y;
			this._material.y = _loc7_.y;
			this._material.mask = _loc6_;
			addWindowChild(this._material);
			addWindowChild(_loc6_);
			addWindowChild(_loc7_);
		}
		this._btnConfirm = addButton(Reflect.field(Language.L, "确定"), "ButtonOrange", 60, 25, this.onOK);
		addButton(Reflect.field(Language.L, "取消"), "ButtonBlue", 60, 25, this.onSuperCloseClick);
		var _loc5_:Int = 4;
		this.rbtnDiy = new RadioButton("VIP LV" + _loc5_ + "及以上免费装扮（无期限，不获得经验值）");
		this.setRaidoStyle(this.rbtnDiy);
		this.rbtnDiy.x = 68;
		this.rbtnDiy.y = this.height - 115;
		this.rbtnJB = new RadioButton("金币买");
		this.setRaidoStyle(this.rbtnJB);
		this.rbtnJB.x = 68;
		this.rbtnJB.y = this.height - 90;
		this.rbtnQB = new RadioButton("元宝买");
		this.setRaidoStyle(this.rbtnQB);
		this.rbtnQB.x = 148;
		this.rbtnQB.y = this.height - 90;
		this.rbtnCFT = new RadioButton("暂时无用");
		this.setRaidoStyle(this.rbtnCFT);
		this.rbtnCFT.x = 228;
		this.rbtnCFT.y = this.height - 90;
	}

	// BuyDiyWindow.as:156-174
	private function onOK():Void {
		if (this.radioGroup.selectedTarget == this.rbtnDiy) {
			this.diyByYellowLvl();
		} else if (this.radioGroup.selectedTarget == this.rbtnJB) {
			this.useGoldBuy();
		} else if (this.radioGroup.selectedTarget == this.rbtnQB) {
			this.useQDBuy();
		} else if (this.radioGroup.selectedTarget == this.rbtnCFT) {
			this.useCFTBuy();
		}
	}

	// BuyDiyWindow.as:136（原版把 super.close 当值传 addButton，见类头 PORT-NOTE）
	private function onSuperCloseClick():Void {
		super.close();
	}

	// BuyDiyWindow.as:176-196
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
		this._postCache = null;
	}

	// BuyDiyWindow.as:198-216
	private function useCFTBuy():Void {
		var _loc1_:DIYDecor = Std.isOfType(this.data, DIYDecor) ? cast(this.data, DIYDecor) : null;
		if (_loc1_ == null) {
			return;
		}
		var _loc2_:Int = Std.int(As3.parseInt(Consts.ITEM_TYPE_DECORATE));
		var _loc3_:Int = _loc1_._type;
		var _loc4_:Int = _loc1_._id;
		var _loc5_:Int = 1;
		NetHelper.sendRequest(CommandDefs.CMD_BUY_PRECHECK, {
			"shopType": _loc2_,
			"itemType": _loc3_,
			"itemId": _loc4_,
			"itemNum": _loc5_
		}, this.qqBuyCFTPreChecked, this.onPreCheckedError);
		super.close();
	}

	// BuyDiyWindow.as:218-221
	private function onLinkUpgradeClicked(param1:TextEvent):Void {
		QzoneJSAPI.openWindow("");
	}

	// BuyDiyWindow.as:223-228
	private function setRaidoStyle(param1:RadioButton):Void {
		param1.textDefaultFormat = this.getTextDefaultFormat();
		param1.textDisabledFormat = this.getTextDisabledFormat();
		param1.textSelectedFormat = this.getTextDefaultFormat();
	}

	// BuyDiyWindow.as:230-246
	private function useQDBuy():Void {
		var _loc1_:DIYDecor = Std.isOfType(this.data, DIYDecor) ? cast(this.data, DIYDecor) : null;
		if (_loc1_ == null) {
			return;
		}
		var _loc2_:Int = 2;
		var _loc3_:Int = _loc1_._type;
		NetHelper.sendRequest(CommandDefs.CMD_BUY_PRECHECK, {
			"shopType": _loc2_,
			"itemType": _loc3_,
			"itemId": _loc1_._id,
			"itemNum": 1
		}, this.qqBuyPreChecked, this.onPreCheckedError);
		super.close();
	}

	// BuyDiyWindow.as:248-252
	override private function setSize():Void {
		super.setSize();
		panelTitle.x = AlignUtil.middle(_width, panelTitle.width);
	}

	// BuyDiyWindow.as:254-281
	private function yellowLvlDiyFn(param1:CommandEvent):Void {
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = _loc2_.m_extra;
		if (_loc3_ == null) {
			return;
		}
		if (As3.eqString(Reflect.field(_loc3_, "code"), "1")) {
			this._parent.controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER, null));
			this._parent.controller.openWindow(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_SUCCESS,
				"text": "免费装饰成功！"
			});
		} else if (As3.hasProp(_loc3_, "direction") == true) {
			this._parent.controller.openWindow(Consts.WINDOW_NAME_ALERT, {
				"type": Consts.ALERT_TYPE_ERROR,
				"text": Reflect.field(_loc3_, "direction")
			});
		}
	}

	// BuyDiyWindow.as:283-286
	private function onPreview(param1:Event):Void {
		m_msgCenter.dispatchEvent(new CommonEvent(Consts.MSG_ENTER_PREVIEW, this.data));
	}

	// BuyDiyWindow.as:288-461
	override private function setData():Void {
		var _loc3_:TextField = null;
		var _loc4_:Int = 0;
		var _loc7_:Int = 0;
		var _loc8_:Float = Math.NaN;
		this.graphics.clear();
		if (this.isInit == false) {
			return;
		}
		super.init();
		var _loc1_:Player = Session.getInstance().host;
		if (_loc1_ == null) {
			return;
		}
		var _loc2_:DIYDecor = Std.isOfType(this.data, DIYDecor) ? cast(this.data, DIYDecor) : null;
		if (_loc2_ == null) {
			return;
		}
		_loc3_ = new TextField();
		_loc3_.text = "请选择：";
		_loc3_.selectable = false;
		_loc3_.x = 20;
		_loc3_.y = this.height - 115;
		_loc3_.width = 50;
		addChild(_loc3_);
		this.radioGroup = new RadioGroup();
		_loc4_ = 4;
		this.radioGroup.removeTarget(this.rbtnDiy);
		this.radioGroup.removeTarget(this.rbtnJB);
		this.radioGroup.removeTarget(this.rbtnQB);
		this.radioGroup.removeTarget(this.rbtnCFT);
		this.rbtnDiy.selected = false;
		this.rbtnJB.selected = false;
		this.rbtnQB.selected = false;
		this.rbtnCFT.selected = false;
		if (this.rbtnDiy.parent == null) {
			addChild(this.rbtnDiy);
		}
		if (this.rbtnJB.parent == null) {
			addChild(this.rbtnJB);
		}
		this.radioGroup.addTarget(this.rbtnDiy);
		this.radioGroup.addTarget(this.rbtnJB);
		this.linkText = new TextField();
		this.linkText.htmlText = "";
		this.linkText.addEventListener(TextEvent.LINK, this.onLinkUpgradeClicked);
		this.linkText.x = _loc3_.width + this.rbtnDiy.width + 20;
		this.linkText.y = this.height - 115;
		addChild(this.linkText);
		var _loc5_:Bool = false;
		var _loc6_:Bool = false;
		if (_loc1_._yellowstatus >= 1 && _loc1_._yellowlevel >= _loc4_) {
			this.rbtnDiy.enabled = true;
			this.radioGroup.selectedTarget = this.rbtnDiy;
			this.rbtnDiy.selected = true;
		} else {
			this.rbtnDiy.enabled = false;
		}
		if (_loc1_._money < _loc2_._price) {
			_loc5_ = true;
			this.rbtnJB.enabled = false;
		} else {
			this.rbtnJB.enabled = true;
			this.radioGroup.selectedTarget = this.rbtnJB;
			this.rbtnJB.selected = true;
		}
		if (_loc2_._fb != 0) {
			_loc7_ = _loc2_._fb;
			if (_loc1_._yellowstatus >= 1) {
				_loc7_ = _loc2_._yfb;
			}
			if (this.rbtnQB.parent == null) {
				addChild(this.rbtnQB);
			}
			this.radioGroup.addTarget(this.rbtnQB);
			this.radioGroup.selectedTarget = this.rbtnQB;
			this.rbtnQB.selected = true;
			_loc8_ = _loc2_._fb * 0.88 * 0.1;
			if (_loc1_._yellowstatus >= 1) {
				_loc8_ = _loc2_._yfb * 0.88 * 0.1;
			}
			if (this.rbtnCFT.parent == null) {
				addChild(this.rbtnCFT);
			}
			this.radioGroup.addTarget(this.rbtnCFT);
			if (!this.rbtnDiy.selected && !this.rbtnJB.selected && !this.rbtnQB.selected) {
				this.radioGroup.selectedTarget = this.rbtnCFT;
				this.rbtnCFT.selected = true;
			}
		} else {
			if (this.rbtnQB.parent != null) {
				this.rbtnQB.parent.removeChild(this.rbtnQB);
			}
			if (this.rbtnCFT.parent != null) {
				this.rbtnCFT.parent.removeChild(this.rbtnCFT);
			}
		}
		if (_loc2_._price <= 0) {
			// BuyDiyWindow.as:409-411（原版无 parent 判空，照抄）
			this.rbtnJB.parent.removeChild(this.rbtnJB);
			this.radioGroup.removeTarget(this.rbtnJB);
			this.rbtnDiy.parent.removeChild(this.rbtnDiy);
			this.radioGroup.removeTarget(this.rbtnDiy);
			this.rbtnQB.x = 68;
			this.rbtnCFT.x = 148;
			this.rbtnQB.y = this.height - 115;
			this.rbtnCFT.y = this.rbtnQB.y;
			this._label.visible = true;
			cast(this._form, Sprite).y = 48;
		} else {
			this.rbtnQB.x = 148;
			this.rbtnCFT.x = 228;
			this.rbtnQB.y = this.height - 90;
			this.rbtnCFT.y = this.rbtnQB.y;
			this._label.visible = false;
			cast(this._form, Sprite).y = 40;
		}
		if (_loc1_._yellowlevel < _loc4_ && _loc2_._fb == 0 && _loc5_) {
			this._btnConfirm.enabled = false;
		} else {
			this._btnConfirm.enabled = true;
		}
		this._directionText.text = "";
		if (_loc5_ && !_loc6_) {
			this._directionText.text = Reflect.field(Language.L, "您的金币不足。");
		} else if (!_loc5_ && _loc6_) {
			this._directionText.text = Reflect.field(Language.L, "您的元宝不足。");
		} else if (_loc5_ && _loc6_) {
			this._directionText.text = Reflect.field(Language.L, "您的元宝和金币都不足。");
		}
		if (this._form != null) {
			cast(As3.childOf(this._form, "diyName"), TextField).defaultTextFormat = new TextFormat("Verdana", 26, 3381555, true);
			cast(As3.childOf(this._form, "diyName"), TextField).text = _loc2_._name;
			if (As3.childOf(this._form, "diyDetail") != null) {
				cast(As3.childOf(this._form, "diyDetail"), TextField).htmlText = this.buildContent();
			}
		}
		if (this._material != null) {
			this._material.setContent("2", _loc2_._id, true);
		}
	}

	// BuyDiyWindow.as:463-470
	private function getTextDisabledFormat():TextFormat {
		if (this.textDefaultFormat == null) {
			this.textDefaultFormat = new TextFormat("Verdana", 12, 8947848, null, null, null, null, null, "left");
		}
		return this.textDefaultFormat;
	}

	// BuyDiyWindow.as:472-490
	private function qqBuyCFTPreChecked(param1:CommandEvent):Void {
		var _loc4_:DIYDecor = null;
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = _loc2_.m_extra;
		if (_loc3_ == null) {
			return;
		}
		if (As3.eqString(Reflect.field(_loc3_, "code"), "1")) {
			_loc4_ = Std.isOfType(this.data, DIYDecor) ? cast(this.data, DIYDecor) : null;
			this._parent.controller.model.buyInGame(Reflect.field(param1.body, "__body"), 2, "DIY", _loc4_._exp);
		}
	}

	// BuyDiyWindow.as:492-498
	private function diyByYellowLvl():Void {
		var _loc1_:DIYDecor = Std.isOfType(this.data, DIYDecor) ? cast(this.data, DIYDecor) : null;
		var _loc2_:Int = _loc1_._id;
		NetHelper.sendRequest(CommandDefs.CMD_ITEM_VIP, {
			"itemId": _loc2_
		}, this.yellowLvlDiyFn, this.onPreCheckedError);
		super.close();
	}

	// BuyDiyWindow.as:500-521
	private function buildContent():String {
		var _loc1_:DIYDecor = Std.isOfType(this.data, DIYDecor) ? cast(this.data, DIYDecor) : null;
		if (_loc1_ == null) {
			return "";
		}
		var _loc2_:String = "";
		if (_loc1_._price > 0) {
			_loc2_ += "金币价：<font size=\"11\" color=\"#FF6600\"><b>" + _loc1_._price + "</b></font> <font color=\"#CC3300\">金币</font><br>";
		}
		var _loc3_:Int = -60;
		if (_loc1_._fb != 0) {
			_loc2_ += "<textformat indent=\"2\">元宝价</textformat>：普通 <font size=\"11\" color=\"#0099FF\"><b>" + _loc1_._fb
				+ "</b></font> <font color=\"#003366\">元宝</font><br>";
			_loc2_ += "特惠价：VIP <font size=\"11\" color=\"#FF6600\"><b>" + _loc1_._yfb
				+ "</b></font> <font color=\"#003366\">元宝</font> (节省 <font size=\"11\" color=\"#FF6600\"><b>";
			_loc2_ += _loc1_._fb - _loc1_._yfb + "</b></font> <font color=\"#003366\">元宝</font>)<br />";
			_loc2_ += "<p align=\"right\"><font size=\"12\" color=\"#666666\"></font></p>";
		}
		return _loc2_ + ("有效期：" + _loc1_._validTime / 86400 + " 天，可获得经验值：" + _loc1_._exp + "<br />");
	}

	// BuyDiyWindow.as:523-541
	private function qqBuyPreChecked(param1:CommandEvent):Void {
		var _loc4_:DIYDecor = null;
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result, ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = _loc2_.m_extra;
		if (_loc3_ == null) {
			return;
		}
		if (As3.eqString(Reflect.field(_loc3_, "code"), "1")) {
			_loc4_ = Std.isOfType(this.data, DIYDecor) ? cast(this.data, DIYDecor) : null;
			this._parent.controller.model.buyInGame(Reflect.field(param1.body, "__body"), 1, "DIY", _loc4_._exp);
		}
	}

	// BuyDiyWindow.as:543-550
	private function getTextDefaultFormat():TextFormat {
		if (this.textDefaultFormat == null) {
			this.textDefaultFormat = new TextFormat("Verdana", 12, 0, null, null, null, null, null, "left");
		}
		return this.textDefaultFormat;
	}

	// BuyDiyWindow.as:552-556
	override private function addedToLayer():Void {
		super.addedToLayer();
		this.createView();
	}

	// BuyDiyWindow.as:558-567
	private function useGoldBuy():Void {
		var _loc1_:DIYDecor = Std.isOfType(this.data, DIYDecor) ? cast(this.data, DIYDecor) : null;
		if (_loc1_ == null) {
			return;
		}
		this._parent.controller.model.buyDiy(_loc1_._id);
		super.close();
	}
}
