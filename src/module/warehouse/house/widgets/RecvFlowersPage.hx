package module.warehouse.house.widgets;

import com.qzone.qui.controls.Button;
import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import common.Consts;
import common.misc.Utils;
import events.ViewEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import framework.base.BasePage;
import module.warehouse.house.WarehouseController;
import module.warehouse.house.WarehouseView;
import shim.As3;

/**
 * module.warehouse.house.widgets.RecvFlowersPage —— RecvFlowersPage.as 逐句
 * 对应（issue #36 功能 swf 翻译：仓库）。「收到的花束」页：空态文案 +
 * 底部回赠按钮（跳仓库鲜花页的送花视图）；SEND_FLOWER 打开花束卡片并
 * 全屏播放花束动画，PREVIEW（含小写 "preview" 字串事件）只播放。
 *
 * PORT-NOTE: `as WarehouseView`/`fId as int` → Std.isOfType/As3.intOf；
 * `fId != undefined` → As3.hasProp；onCreateTile/setData 原文 protected →
 * private 覆写。
 */
class RecvFlowersPage extends BasePage {
	// RecvFlowersPage.as:19
	private var _infoTxt:Label;

	// RecvFlowersPage.as:21
	private var _emptyText:TextField;

	// RecvFlowersPage.as:23-56
	public function new(param1:WarehouseView, param2:Int, param3:Int) {
		var _loc5_:Button = null;
		super(param1, param2, param3);
		this._emptyText = new TextField();
		this._emptyText.selectable = false;
		this._emptyText.visible = false;
		var _loc4_:TextFormat = new TextFormat("Verdana", 16, 3355443);
		_loc4_.leading = 8;
		this._emptyText.defaultTextFormat = _loc4_;
		this._emptyText.width = 230;
		this._emptyText.height = 80;
		this._emptyText.text = "当前还没有收到好友的花束哦！";
		this._emptyText.wordWrap = true;
		this._emptyText.x = (param2 - this._emptyText.width) / 2;
		this._emptyText.y = (param3 - this._emptyText.height) / 2;
		addChild(this._emptyText);
		this._infoTxt = new Label();
		this._infoTxt.y = 295;
		addChild(this._infoTxt);
		_loc5_ = new Button();
		_loc5_.defaultSkin = Utils.getClass("ButtonBlue");
		_loc5_.cacheAsBitmap = true;
		_loc5_.text = "送给好友花束";
		_loc5_.width = 85;
		_loc5_.height = 25;
		_loc5_.x = 335;
		_loc5_.y = 295;
		addChild(_loc5_);
		_loc5_.clickFn = this.onSendFlowerBtn;
		addEventListener(FlowerRenderItem.SEND_FLOWER, this.onShowFlowerCard, false, 0, true);
		addEventListener(FlowerRenderItem.PREVIEW, this.onPreviewFlower, false, 0, true);
		addEventListener("preview", this.onPreviewFlower, false, 0, true);
	}

	// RecvFlowersPage.as:58-66
	private function onSendFlowerBtn(param1:MouseEvent):Void {
		param1.stopPropagation();
		var _loc2_:WarehouseView = Std.isOfType(this._view, WarehouseView) ? cast(this._view, WarehouseView) : null;
		if (_loc2_ != null) {
			_loc2_.gotoSendFlower();
		}
	}

	// RecvFlowersPage.as:68-75
	private function onPreviewFlower(param1:ViewEvent):Void {
		if (param1 == null || param1.data == null || !As3.hasProp(param1.data, "fId")) {
			return;
		}
		FlowerPlayer.play(this.controller.module.app.farmView, this.controller.model.flowerPath, As3.intOf(Reflect.field(param1.data, "fId")));
	}

	// RecvFlowersPage.as:77-89
	private function onShowFlowerCard(param1:ViewEvent):Void {
		var _loc2_:Dynamic = param1.data;
		if (_loc2_ == null) {
			return;
		}
		this.controller.openWindow(Consts.WINDOW_NAME_FLOWER_CARD, {
			"parent": this,
			"flower": _loc2_
		});
		FlowerPlayer.play(this.controller.module.app.farmView, this.controller.model.flowerPath, As3.intOf(Reflect.field(_loc2_, "fId")));
	}

	// RecvFlowersPage.as:91-108（AS3 protected → private 覆写）
	override private function onCreateTile():Void {
		if (_tile != null) {
			_tile.paddingH = 23;
			_tile.paddingV = 10;
			_tile.gapH = 0;
			_tile.gapV = 0;
			_tile.tileWidth = 115;
			_tile.tileHeight = 112;
			_tile.defaultSkin = null;
			_tile.horizontalScrollPolicy = ScrollPolicy.OFF;
			_tile.itemRenderer = FlowerRenderItem;
			_tile.y = 2;
			_tile.width = _preferedWidth - 2;
			_tile.height = 260;
		}
	}

	// RecvFlowersPage.as:110-124（AS3 protected → private 覆写）
	override private function setData():Void {
		if (super.dataList == null || super.dataList.length == 0) {
			this._emptyText.visible = true;
			this._infoTxt.text = "您是否想送给好友一份祝福呢?";
			this._infoTxt.x = 85;
		} else {
			this._emptyText.visible = false;
			this._infoTxt.text = "收到好友的花束高兴吗?您是否也想回送一份祝福呢?";
			this._infoTxt.x = 25;
		}
	}

	// RecvFlowersPage.as:126-134
	private var controller(get, never):WarehouseController;

	private function get_controller():WarehouseController {
		var _loc1_:WarehouseView = Std.isOfType(this._view, WarehouseView) ? cast(this._view, WarehouseView) : null;
		if (_loc1_ == null) {
			return null;
		}
		return _loc1_.controller;
	}
}
