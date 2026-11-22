package module.warehouse.house.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import common.Settings;
import common.view.window.WindowLabelMaker;
import entities.WarehouseCrop;
import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import framework.base.BasePage;
import module.uitools.widgets.profile.PropertyText;
import module.warehouse.house.WarehouseController;
import module.warehouse.house.WarehouseView;
import shim.As3;

/**
 * module.warehouse.house.widgets.CardsPage —— CardsPage.as 逐句对应
 * （issue #36 功能 swf 翻译：仓库）。材料（卡片/水晶）页：顶部材料区说明 +
 * 底部总价值；锁定的条目不计入合计。瓦片复用 PlantRenderItem。
 *
 * PORT-NOTE: `as WarehouseView` → Std.isOfType 判型；for-each → 外层 var +
 * 循环内回填；onCreateTile/setData 原文 protected → private 覆写。
 */
class CardsPage extends BasePage {
	// CardsPage.as:20
	private var _tfEmpty:TextField;

	// CardsPage.as:22
	private var _sumPrice:PropertyText;

	// CardsPage.as:24-46
	public function new(param1:DisplayObjectContainer, param2:Int, param3:Int) {
		var _loc4_:Label = null;
		super(param1, param2, param3);
		_loc4_ = new Label();
		_loc4_.text = "农场和牧场的材料统一存放在材料专区，卡片可用于兑换礼包或在加工坊加工";
		_loc4_.x = 2;
		_loc4_.width = param2 - 3;
		WindowLabelMaker.addTarget(_loc4_);
		addChild(_loc4_);
		var _loc5_:TextField = new TextField();
		_loc5_.selectable = false;
		_loc5_.defaultTextFormat = new TextFormat("Verdana", 12, 39423, true);
		_loc5_.autoSize = TextFieldAutoSize.LEFT;
		_loc5_.text = "当前材料总价值：";
		_loc5_.x = 15;
		_loc5_.y = param3 - _loc5_.height - 4;
		addChild(_loc5_);
		this._sumPrice = new PropertyText();
		this._sumPrice.x = _loc5_.width + _loc5_.x + 10;
		this._sumPrice.y = param3 - this._sumPrice.height;
		addChild(this._sumPrice);
	}

	// CardsPage.as:48-56
	private var controller(get, never):WarehouseController;

	private function get_controller():WarehouseController {
		var _loc1_:WarehouseView = Std.isOfType(this._view, WarehouseView) ? cast(this._view, WarehouseView) : null;
		if (_loc1_ == null) {
			return null;
		}
		return _loc1_.controller;
	}

	// CardsPage.as:58-78
	private function sumUp():Void {
		var _loc3_:WarehouseCrop = null;
		var _loc3In:Dynamic = null;
		var _loc1_:Float = 0;
		var _loc2_:Array<Dynamic> = this.dataList;
		for (_loc3In in _loc2_) {
			_loc3_ = _loc3In;
			if (_loc3_._isLock != 1) {
				if (_loc3_._high_price > 0) {
					_loc1_ += _loc3_._high_price * _loc3_._amount;
				} else {
					_loc1_ += _loc3_._price * _loc3_._amount;
				}
			}
		}
		this._sumPrice.goldValue = _loc1_;
	}

	// CardsPage.as:80-100
	public function refreshLock(param1:WarehouseCrop):Void {
		var _loc2_:PlantRenderItem = null;
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

	// CardsPage.as:102-119（AS3 protected → private 覆写）
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

	// CardsPage.as:121-139（AS3 protected → private 覆写）
	override private function setData():Void {
		var _loc1_:Array<Dynamic> = super.dataList;
		if (_loc1_ == null || _loc1_.length == 0) {
			this.createEmptyView();
			_tile.visible = false;
			this._tfEmpty.visible = true;
		} else {
			if (this._tfEmpty != null) {
				this._tfEmpty.visible = false;
			}
			_tile.visible = true;
		}
		this.sumUp();
	}

	// CardsPage.as:141-160
	private function createEmptyView():Void {
		var _loc1_:TextFormat = null;
		if (this._tfEmpty == null) {
			this._tfEmpty = new TextField();
			this._tfEmpty.selectable = false;
			this._tfEmpty.visible = false;
			_loc1_ = new TextFormat("Verdana", 16, 3355443);
			_loc1_.leading = 8;
			this._tfEmpty.defaultTextFormat = _loc1_;
			this._tfEmpty.width = 350;
			this._tfEmpty.height = 76;
			this._tfEmpty.text = Settings.getInstance().getStringAttribute("WarehouseEmpty");
			this._tfEmpty.wordWrap = true;
			this._tfEmpty.x = (_preferedWidth - this._tfEmpty.width) / 2;
			this._tfEmpty.y = (_preferedHeight - this._tfEmpty.height) / 2;
			addChild(this._tfEmpty);
		}
	}
}
