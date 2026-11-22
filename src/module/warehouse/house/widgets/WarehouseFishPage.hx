package module.warehouse.house.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import common.Consts;
import common.Language;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.window.WindowLabelMaker;
import entities.WarehouseFish;
import openfl.display.DisplayObjectContainer;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import framework.base.BasePage;
import module.uitools.widgets.profile.PropertyText;
import module.warehouse.house.WarehouseController;
import module.warehouse.house.WarehouseView;
import shim.As3;

/**
 * module.warehouse.house.widgets.WarehouseFishPage —— WarehouseFishPage.as
 * 逐句对应（issue #36 功能 swf 翻译：仓库）。成鱼页：底部总价值（财神爷/
 * 仙皇按 myFairy 加成，int 合计）+「卖出成鱼」按钮（疲劳时段确认框）。
 *
 * PORT-NOTE: `_sum` 原文 int、合计过程 Number——`this._sum = Number` 与
 * `*=` 的 AS3 隐式 ToInt32 截断 → Std.int（机械等价）；`Language.L["…"]` →
 * Reflect.field；`["itemId"] == 数` 宽松等值 → As3.floatOf；for-each →
 * 外层 var + 循环内回填；onCreateTile/setData 原文 protected → private 覆写。
 */
class WarehouseFishPage extends BasePage {
	// WarehouseFishPage.as:27
	private var _sellBtn:Button;

	// WarehouseFishPage.as:29
	private var _sum:Int;

	// WarehouseFishPage.as:31
	private var _sumPrice:PropertyText;

	// WarehouseFishPage.as:33-73
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		var _loc4_:Label = null;
		super(param1, param2, param3);
		_loc4_ = new Label();
		_loc4_.text = "卖成鱼";
		_loc4_.x = 2;
		_loc4_.width = param2 - 3;
		WindowLabelMaker.addTarget(_loc4_);
		addChild(_loc4_);
		this._sellBtn = new Button();
		this._sellBtn.width = 85;
		this._sellBtn.height = 25;
		this._sellBtn.defaultSkin = Utils.getClass("ButtonGreen");
		this._sellBtn.x = param2 - this._sellBtn.width - 15;
		this._sellBtn.y = param3 - this._sellBtn.height - 4;
		this._sellBtn.text = "卖出成鱼";
		this._sellBtn.addEventListener(MouseEvent.CLICK, this.onSellBtnClicked);
		addChild(this._sellBtn);
		var _loc5_:TextField = new TextField();
		_loc5_.selectable = false;
		_loc5_.defaultTextFormat = new TextFormat("Verdana", 12, 39423, true);
		_loc5_.autoSize = TextFieldAutoSize.LEFT;
		_loc5_.text = "当前成鱼总价值：";
		_loc5_.x = 15;
		_loc5_.y = param3 - _loc5_.height - 4;
		addChild(_loc5_);
		var _loc6_:Dynamic = Session.getInstance().myFairy;
		if (_loc6_ != null && (As3.floatOf(Reflect.field(_loc6_, "itemId")) == Consts.FAIRY_MONEY || As3.floatOf(Reflect.field(_loc6_, "itemId")) == Consts.FAIRY_GOD)) {
			this._sumPrice = new PropertyText("gold", 180, false);
			this._sumPrice.x = _loc5_.width + _loc5_.x - 7;
		} else {
			this._sumPrice = new PropertyText("gold", 180, true);
			this._sumPrice.x = _loc5_.width + _loc5_.x;
		}
		this._sumPrice.y = param3 - this._sumPrice.height;
		addChild(this._sumPrice);
	}

	// WarehouseFishPage.as:75-114（方法名 sellAllSeeds：原版从种子页复制
	// 留下的名字，照抄不改）
	private function sellAllSeeds():Void {
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		var _loc1_:Array<Dynamic> = this.controller.model.collectNotLockedIDs(Consts.WAREHOUSE_FISH);
		var _loc2_:String = "";
		if (_loc1_ != null && _loc1_.length > 0) {
			_loc3_ = QzoneJSAPI.getOnlineTime(Settings.getInstance().mode);
			_loc4_ = this._sum;
			if (_loc3_ > 5 * 3600) {
				_loc4_ = 0;
			} else if (_loc3_ > 3 * 3600) {
				_loc4_ = Std.int(Math.ceil(_loc4_ / 2));
			}
			_loc2_ = Language.replaceText("allFishSellText", {"goldValue": _loc4_});
			this.controller.openWindow(Consts.WINDOW_NAME_CONFIRM, {
				"width": 336,
				"height": 270,
				"title": "确认",
				"text": _loc2_,
				"confirmEnable": true,
				"confirmFn": this.sellAllConfirmed
			});
		} else {
			_loc2_ = Reflect.field(Language.L, "allFishSellText2");
			this.controller.openWindow(Consts.WINDOW_NAME_CONFIRM, {
				"width": 336,
				"height": 270,
				"title": "确认",
				"text": _loc2_,
				"confirmEnable": false
			});
		}
	}

	// WarehouseFishPage.as:116-124
	private var controller(get, never):WarehouseController;

	private function get_controller():WarehouseController {
		var _loc1_:WarehouseView = Std.isOfType(this._view, WarehouseView) ? cast(this._view, WarehouseView) : null;
		if (_loc1_ == null) {
			return null;
		}
		return _loc1_.controller;
	}

	// WarehouseFishPage.as:126-146
	public function refreshLock(param1:WarehouseFish):Void {
		var _loc2_:FishRenderItem = null;
		var _loc2In:Dynamic = null;
		if (param1 == null) {
			return;
		}
		if (_tile == null || _tile.items == null) {
			return;
		}
		for (_loc2In in _tile.items) {
			_loc2_ = _loc2In;
			if (_loc2_.data == param1) {
				_loc2_.refreshLock();
				this.sumUp();
				break;
			}
		}
	}

	// WarehouseFishPage.as:148-165（AS3 protected → private 覆写）
	override private function onCreateTile():Void {
		if (_tile != null) {
			_tile.paddingH = 23;
			_tile.paddingV = 10;
			_tile.gapH = 0;
			_tile.gapV = 0;
			_tile.tileWidth = 90;
			_tile.tileHeight = 98;
			_tile.defaultSkin = null;
			_tile.horizontalScrollPolicy = ScrollPolicy.OFF;
			_tile.itemRenderer = FishRenderItem;
			_tile.y = 22;
			_tile.width = _preferedWidth - 2;
			_tile.height = 260;
		}
	}

	// WarehouseFishPage.as:167-179（AS3 protected → private 覆写）
	override private function setData():Void {
		this.sumUp();
		var _loc1_:Array<Dynamic> = this.dataList;
		if (_loc1_ == null || _loc1_.length == 0) {
			this._sellBtn.enabled = false;
		} else {
			this._sellBtn.enabled = true;
		}
	}

	// WarehouseFishPage.as:181-205
	private function sumUp():Void {
		var _loc3_:WarehouseFish = null;
		var _loc3In:Dynamic = null;
		var _loc4_:Dynamic = null;
		var _loc1_:Float = 0;
		var _loc2_:Array<Dynamic> = this.dataList;
		for (_loc3In in _loc2_) {
			_loc3_ = _loc3In;
			if (_loc3_._isLock <= 0) {
				_loc1_ += _loc3_._sale * _loc3_._amount;
			}
		}
		// Number → int 的 AS3 隐式截断 → Std.int
		this._sum = Std.int(_loc1_);
		_loc4_ = Session.getInstance().myFairy;
		if (_loc4_ != null && (As3.floatOf(Reflect.field(_loc4_, "itemId")) == Consts.FAIRY_MONEY || As3.floatOf(Reflect.field(_loc4_, "itemId")) == Consts.FAIRY_GOD)) {
			this._sum = Std.int(this._sum * (1 + As3.floatOf(Reflect.field(_loc4_, "rate")) / 100));
			this._sumPrice.text = Std.string(this._sum)
				+ (As3.floatOf(Reflect.field(_loc4_, "itemId")) == Consts.FAIRY_MONEY ? "  财神爷加成" : " 仙皇加成")
				+ Std.string(Reflect.field(_loc4_, "rate")) + "%";
		} else {
			this._sumPrice.text = Std.string(this._sum);
		}
	}

	// WarehouseFishPage.as:207-210
	private function sellAllConfirmed():Void {
		this.controller.model.sellAllFish(Consts.WAREHOUSE_FISH);
	}

	// WarehouseFishPage.as:212-240
	private function onSellBtnClicked(param1:MouseEvent):Void {
		var _loc4_:Dynamic = null;
		var _loc2_:Int = QzoneJSAPI.getOnlineTime(Settings.getInstance().mode);
		var _loc3_:String = "";
		if (_loc2_ > 5 * 3600) {
			_loc3_ = "您现在处于长时间游戏的不健康时间段，适当休息一下吧。本次卖出将无法获得任何收益，您确定要卖出吗？";
		} else if (_loc2_ > 3 * 3600) {
			_loc3_ = "您现在处于疲劳时间段，适当休息一下吧。本次卖出将只能获得正常收益的一半，您确定要卖出吗？";
		} else {
			this.sellAllSeeds();
		}
		if (_loc3_ != "") {
			_loc4_ = {
				"width": 327,
				"height": 270,
				"title": "温馨提示",
				"text": _loc3_,
				"confirmFn": this.sellAllSeeds
			};
			this.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM, _loc4_);
		}
	}
}
