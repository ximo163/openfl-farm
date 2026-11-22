package module.warehouse.house.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import com.qzone.qui.makers.StepperMaker;
import com.qzone.utils.AlignUtil;
import com.qzone.utils.DisplayUtil;
import common.Consts;
import common.Language;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.MaterialProxyBig;
import common.view.window.BaseWindow;
import entities.WarehouseSeed;
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
 * module.warehouse.house.widgets.SellToolWindow —— SellToolWindow.as 逐句
 * 对应（issue #36 功能 swf 翻译：仓库）。种子（工具）卖出窗：WarehouseForm
 * 版式（lock_mc 藏起）+ MaterialProxyBig 种子图 + StepperMaker 数量；种子
 * id==28（薰衣草类活动种子）带外链广告行。
 *
 * PORT-NOTE: 原版构造器在 super() 前落 _parentWin——Haxe super() 必须先行
 * （结果同形）；`_form.xxx` 时间轴具名子件 → As3.childOf；`super.data` 属性
 * 取值照写；ExternalInterface → QQOutlets（html5-only 收口）；`.text =
 * Number/int` 隐式串化 → Std.string；`unescape(_ext || "")` 的 AS3 空值假值
 * → null/空串同取 ""；AS3 sellSeed(int,int) 收 Number → 隐式截断 → Std.int；
 * init 原文 protected → private 覆写（不调 super.init()，原版如此）。
 */
class SellToolWindow extends BaseWindow {
	// SellToolWindow.as:31（WarehouseForm 符号，具名子件经 childOf 访问）
	private var _form:MovieClip;

	// SellToolWindow.as:33
	private var _material:MaterialProxyBig;

	// SellToolWindow.as:35
	private var _directionText:TextField;

	// SellToolWindow.as:37
	private var _numbericStepper:StepperMaker;

	// SellToolWindow.as:39
	private var _parentWin:BaseWindow;

	// SellToolWindow.as:41
	private var _adText:Label;

	// SellToolWindow.as:43
	private var _vipIcon:MovieClip;

	// SellToolWindow.as:45-55
	public function new(param1:BaseWindow) {
		var _loc2_:WarehouseView = Std.isOfType(param1, WarehouseView) ? cast(param1, WarehouseView) : null;
		super(Std.isOfType(_loc2_.controller.module.app, IMsgCenter) ? cast(_loc2_.controller.module.app, IMsgCenter) : null);
		this._parentWin = param1;
		width = 380;
		height = 280;
		title = "种子管理";
		windowName = Consts.WINDOW_NAME_SELLSEED;
		mode = true;
	}

	// SellToolWindow.as:57-60
	private function onCancel(param1:MouseEvent):Void {
		super.onClose(param1);
	}

	// SellToolWindow.as:62-70
	private function onNavigateToURL(param1:TextEvent):Void {
		var _loc2_:String = param1.text;
		if (_loc2_ == "" || QQOutlets.available == false) {
			return;
		}
		QQOutlets.call("window.open", _loc2_);
	}

	// SellToolWindow.as:72-84
	private function onOK(param1:MouseEvent = null):Void {
		var _loc2_:String = "当前回收种子的总价值：<br/><font color=\'#FF6600\'>" + cast(As3.childOf(this._form, "income"), TextField).text
			+ "</font> 金币<br/><font color=\'#FF0000\'>您确定要低价出售来之不易的种子？</font>";
		var _loc3_:Dynamic = {
			"width": 327,
			"height": 270,
			"title": "确定",
			"text": _loc2_,
			"confirmFn": this.sellSeed
		};
		var _loc4_:WarehouseView = Std.isOfType(this._parentWin, WarehouseView) ? cast(this._parentWin, WarehouseView) : null;
		_loc4_.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM, _loc3_);
	}

	// SellToolWindow.as:86-140（AS3 protected → private 覆写，不调
	// super.init()：原版如此）
	override private function init():Void {
		var _loc1_:SteperSkin = null;
		var _loc2_:Button = null;
		this._form = new WarehouseForm();
		this._form.x = 190;
		this._form.y = 45;
		addChild(this._form);
		this._material = new MaterialProxyBig();
		this._material.x = 20;
		this._material.y = 40;
		addChild(this._material);
		this._numbericStepper = new StepperMaker();
		this._numbericStepper.addEventListener(Event.CHANGE, this.onNumChange);
		_loc1_ = new SteperSkin();
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
		_loc2_ = new Button();
		_loc2_.defaultSkin = Utils.getClass("ButtonOrange");
		_loc2_.width = 64;
		_loc2_.height = 25;
		_loc2_.x = width / 2 - _loc2_.width - 10;
		_loc2_.y = height - 50;
		_loc2_.text = Reflect.field(Language.L, "卖出");
		_loc2_.addEventListener(MouseEvent.CLICK, this.onSell);
		_loc2_.name = "confirm_btn";
		addChild(_loc2_);
		var _loc3_:Button = new Button();
		_loc3_.defaultSkin = Utils.getClass("ButtonBlue");
		_loc3_.width = 64;
		_loc3_.height = 25;
		_loc3_.x = width / 2 + 10;
		_loc3_.y = height - 50;
		_loc3_.text = Reflect.field(Language.L, "关闭");
		_loc3_.addEventListener(MouseEvent.CLICK, this.onCancel);
		addChild(_loc3_);
		cast(As3.childOf(this._form, "lock_mc"), MovieClip).visible = false;
		var vipMat:Dynamic = Utils.getMaterial("VipSeedIcon");
		this._vipIcon = Std.isOfType(vipMat, MovieClip) ? cast(vipMat, MovieClip) : null;
		this._vipIcon.x = this._material.x + 2;
		this._vipIcon.y = this._material.y + 1;
	}

	// SellToolWindow.as:142-172
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

	// SellToolWindow.as:174-187
	private function sellSeed(param1:MouseEvent = null):Void {
		var _loc2_:WarehouseSeed = Std.isOfType(super.data, WarehouseSeed) ? cast(super.data, WarehouseSeed) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:WarehouseView = Std.isOfType(this._parentWin, WarehouseView) ? cast(this._parentWin, WarehouseView) : null;
		if (_loc3_ != null) {
			// AS3 sellSeed(int,int) 收 Number → 隐式截断 → Std.int
			_loc3_.controller.model.sellSeed(_loc2_._id, Std.int(this._numbericStepper.value));
		}
		super.onClose(param1);
	}

	// SellToolWindow.as:189-197
	private function onNumChange(param1:Event):Void {
		var _loc2_:WarehouseSeed = Std.isOfType(super.data, WarehouseSeed) ? cast(super.data, WarehouseSeed) : null;
		if (_loc2_ == null) {
			return;
		}
		cast(As3.childOf(this._form, "income"), TextField).text = Std.string(_loc2_._price * this._numbericStepper.value);
	}

	// SellToolWindow.as:199-252
	override private function setData():Void {
		var _loc2_:TextFormat = null;
		this.graphics.clear();
		var _loc1_:WarehouseSeed = Std.isOfType(super.data, WarehouseSeed) ? cast(super.data, WarehouseSeed) : null;
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
			cast(As3.childOf(this._form, "price"), TextField).text = Std.string(_loc1_._price);
			cast(As3.childOf(this._form, "income"), TextField).width = 150;
			cast(As3.childOf(this._form, "income"), TextField).text = Std.string(_loc1_._price * this._numbericStepper.value);
			this._directionText.text = Language.replaceText("sellNum", {
				"minNum": 1,
				"maxNum": _loc1_._amount
			});
			if (_loc1_._id == 28) {
				if (this._adText == null) {
					this._adText = new Label();
					this._adText.y = 205;
					this._adText.textField.addEventListener(TextEvent.LINK, this.onNavigateToURL);
					this._adText.textDefaultFormat = new TextFormat();
				}
				this._adText.text = As3.unescape(As3.truthy(_loc1_._ext) ? Std.string(_loc1_._ext) : "");
				this._adText.x = AlignUtil.right(380, this._adText.width) - 10;
				this.addChild(this._adText);
			} else {
				DisplayUtil.removeChild(this, this._adText);
			}
		}
		if (_loc1_._isVip == 1) {
			addChild(this._vipIcon);
		}
	}
}
