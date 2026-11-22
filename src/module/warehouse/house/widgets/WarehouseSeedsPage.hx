package module.warehouse.house.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import common.Consts;
import common.Language;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.window.WindowLabelMaker;
import entities.WarehouseSeed;
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
 * module.warehouse.house.widgets.WarehouseSeedsPage —— WarehouseSeedsPage.as
 * 逐句对应（issue #36 功能 swf 翻译：仓库）。种子页：顶部回收价提示 +
 * 底部总价值（PropertyText goldValue）+「卖出种子」按钮（疲劳时段确认
 * 框）。瓦片复用 PlantRenderItem。
 *
 * PORT-NOTE: `Language.L["sellSomeSeeds"]` → Reflect.field；`as WarehouseView`
 * → Std.isOfType 判型；for-each → 外层 var + 循环内回填；onCreateTile/
 * setData 原文 protected → private 覆写；`int(goldValue)` 的 Number→int
 * 截断 → Std.int。
 */
class WarehouseSeedsPage extends BasePage {
	// WarehouseSeedsPage.as:26
	private var _sellBtn:Button;

	// WarehouseSeedsPage.as:28
	private var _sumPrice:PropertyText;

	// WarehouseSeedsPage.as:30-61
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		var _loc4_:Label = null;
		super(param1, param2, param3);
		_loc4_ = new Label();
		_loc4_.text = "当前种子回收价低于原售价，请慎重选择";
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
		this._sellBtn.text = Reflect.field(Language.L, "sellSomeSeeds");
		this._sellBtn.addEventListener(MouseEvent.CLICK, this.onSellBtnClicked);
		addChild(this._sellBtn);
		var _loc5_:TextField = new TextField();
		_loc5_.selectable = false;
		_loc5_.defaultTextFormat = new TextFormat("Verdana", 12, 39423, true);
		_loc5_.autoSize = TextFieldAutoSize.LEFT;
		_loc5_.text = "当前种子总价值：";
		_loc5_.x = 15;
		_loc5_.y = param3 - _loc5_.height - 4;
		addChild(_loc5_);
		this._sumPrice = new PropertyText();
		this._sumPrice.x = _loc5_.width + _loc5_.x + 10;
		this._sumPrice.y = param3 - this._sumPrice.height;
		addChild(this._sumPrice);
	}

	// WarehouseSeedsPage.as:63-71
	private var controller(get, never):WarehouseController;

	private function get_controller():WarehouseController {
		var _loc1_:WarehouseView = Std.isOfType(this._view, WarehouseView) ? cast(this._view, WarehouseView) : null;
		if (_loc1_ == null) {
			return null;
		}
		return _loc1_.controller;
	}

	// WarehouseSeedsPage.as:73-83
	private function sumUp():Void {
		var _loc3_:WarehouseSeed = null;
		var _loc3In:Dynamic = null;
		var _loc1_:Float = 0;
		var _loc2_:Array<Dynamic> = this.dataList;
		for (_loc3In in _loc2_) {
			_loc3_ = _loc3In;
			_loc1_ += _loc3_._price * _loc3_._amount;
		}
		this._sumPrice.goldValue = _loc1_;
	}

	// WarehouseSeedsPage.as:85-102（AS3 protected → private 覆写）
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
			_tile.itemRenderer = PlantRenderItem;
			_tile.y = 22;
			_tile.width = _preferedWidth - 2;
			_tile.height = 260;
		}
	}

	// WarehouseSeedsPage.as:104-116（AS3 protected → private 覆写）
	override private function setData():Void {
		this.sumUp();
		var _loc1_:Array<Dynamic> = this.dataList;
		if (_loc1_ == null || _loc1_.length == 0) {
			this._sellBtn.enabled = false;
		} else {
			this._sellBtn.enabled = true;
		}
	}

	// WarehouseSeedsPage.as:118-121
	private function sellAllConfirmed():Void {
		this.controller.model.sellAllSeeds();
	}

	// WarehouseSeedsPage.as:123-148
	private function sellAllSeeds():Void {
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		var _loc4_:String = null;
		var _loc1_:Array<Dynamic> = this.dataList;
		if (_loc1_ != null && _loc1_.length > 0) {
			_loc2_ = QzoneJSAPI.getOnlineTime(Settings.getInstance().mode);
			_loc3_ = Std.int(this._sumPrice.goldValue);
			if (_loc2_ > 5 * 3600) {
				_loc3_ = 0;
			} else if (_loc2_ > 3 * 3600) {
				_loc3_ = Std.int(Math.ceil(_loc3_ / 2));
			}
			_loc4_ = Language.replaceText("allSellSeedsText", {"goldValue": _loc3_});
			this.controller.openWindow(Consts.WINDOW_NAME_CONFIRM, {
				"text": _loc4_,
				"confirmEnable": true,
				"confirmFn": this.sellAllConfirmed
			});
		}
	}

	// WarehouseSeedsPage.as:150-178
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
