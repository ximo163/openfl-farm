package module.shop.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.styles.Style;
import com.qzone.qui.utils.FrameTimer;
import com.qzone.utils.AlignUtil;
import com.qzone.utils.DisplayUtil;
import common.Consts;
import common.Session;
import entities.Seed;
import framework.base.BaseTileItem;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import shim.As3;

/**
 * module.shop.widgets.CropItem —— CropItem.as 逐句对应（issue #35 功能
 * swf 翻译：商店）。种子页普通瓦片子项：图标位按 _isFood/_isRestaurant/
 * _isActivity 选标记符号（无标则空位），有机另盖绿标；红/黑土地种子换
 * ItemBgRed/ItemBgBlack 底；等级色 233195（可种）/其余默认 9211020。
 * 素材同样延迟 1 秒挂（FrameTimer 防滚动连发，照抄）。
 */
class CropItem extends BaseTileItem {
	// CropItem.as:9
	private var _timerID:Int;

	// CropItem.as:11
	private var _loaded:Bool;

	// CropItem.as:13
	private var _levelLabel:Label;

	// CropItem.as:15
	private var _priceText:TextField;

	// CropItem.as:17
	private var _icon:Sprite;

	// CropItem.as:19
	private var _noIcon:Bool = false;

	// CropItem.as:21-50
	public function new() {
		super();
		this._timerID = -1;
		this._loaded = false;
		this._priceText = new TextField();
		this._priceText.selectable = false;
		this._priceText.width = 70;
		this._priceText.height = 20;
		addChild(this._priceText);
		this._priceText.x = -5;
		this._priceText.y = 60 + 2;
		this._levelLabel = new Label("");
		this.addChild(this._levelLabel);
		this._levelLabel.textDefaultFormat = new TextFormat("Verdana", 12, 9211020);
		this._levelLabel.textField.filters = cast Style.getTextGlowFilter();
		this._levelLabel.y = AlignUtil.right(60, this._levelLabel.height) + 2;
		var _loc1_:Shape = new Shape();
		_loc1_.graphics.beginFill(16711680, 0);
		_loc1_.graphics.drawRect(0, 0, 10, 1);
		_loc1_.graphics.endFill();
		_loc1_.y = 100;
		addChild(_loc1_);
	}

	// CropItem.as:52-129
	override private function set_data(param1:Dynamic):Dynamic {
		if (param1 == null || param1 == this._item && this._loaded == true) {
			this.clearTimer();
			return param1;
		}
		super.set_data(param1);
		var _loc2_:Seed = Std.isOfType(this._item, Seed) ? cast(this._item, Seed) : null;
		if (_loc2_ == null) {
			this.clearTimer();
			return param1;
		}
		this.clearTimer();
		this._timerID = FrameTimer.setTimeout(this.delaySetCrop, 1000);
		if (_loc2_._isFood > 0) {
			this._icon = new ShopFoodMarkIcon();
			addChild(this._icon);
		} else if (_loc2_._isRestaurant == 1) {
			this._icon = new RestaurantMarkIcon();
			addChild(this._icon);
		} else if (_loc2_._isRestaurant == 2) {
			this._icon = new ShopSuperMarketIcon();
			addChild(this._icon);
		} else if (_loc2_._isActivity > 0) {
			this._icon = new ActivityMarkIcon();
			addChild(this._icon);
		} else {
			this._noIcon = true;
		}
		if (_loc2_._isGreen == true) {
			this.addGreenIcon();
			this._noIcon = false;
		}
		if (this._noIcon) {
			DisplayUtil.removeChild(this, this._icon);
		}
		if (_loc2_._isMill > 0) {
			DisplayUtil.removeChild(this, this._priceText);
		} else {
			this._priceText.htmlText = "<p align=\"center\"><font color=\"#CC3300\">金币<font/> <font color=\"#FF6600\" face=\"Verdana\" size=\"11\"><b>"
				+ Std.string(_loc2_._price) + "</b><font/></p>";
		}
		var _loc3_:TextFormat = this._levelLabel.textDefaultFormat;
		var _loc4_:Int = 0;
		var _loc5_:Session = Session.getInstance();
		if (_loc5_ != null && _loc5_.host != null) {
			_loc4_ = _loc5_.host.level;
		}
		if (_loc2_._lvl <= _loc4_) {
			_loc3_.color = 233195;
		}
		if (_loc2_._isRed == true) {
			_loc3_.color = 16737792;
			createBackground("ItemBgRed");
		} else if (_loc2_._isBlack == true) {
			_loc3_.color = 0;
			createBackground("ItemBgBlack");
		} else {
			createBackground("ItemBg");
		}
		this._levelLabel.textDefaultFormat = _loc3_;
		this._levelLabel.text = Std.string(_loc2_._lvl) + "级";
		registerListeners();
		return param1;
	}

	// CropItem.as:131-138
	private function delaySetCrop():Void {
		if (this._item == null) {
			return;
		}
		this._material.setContent(Consts.ITEM_TYPE_SEED, As3.intOf(Reflect.field(this._item, "_id")));
		this._loaded = true;
	}

	// CropItem.as:140-156（有机绿标：27x16 色块 + 白字「有机」）
	private function addGreenIcon():Void {
		var _loc1_:Sprite = new Sprite();
		_loc1_.graphics.beginFill(52224, 1);
		_loc1_.graphics.drawRect(0, 0, 27, 16);
		_loc1_.graphics.endFill();
		_loc1_.x = this.width - 36;
		_loc1_.y = 0;
		addChild(_loc1_);
		var _loc2_:TextField = new TextField();
		_loc2_.defaultTextFormat = new TextFormat("Verdana", 12, 16777215);
		_loc2_.text = "有机";
		_loc2_.selectable = false;
		_loc1_.addChild(_loc2_);
		this._icon = _loc1_;
		this._icon.mouseEnabled = false;
	}

	// CropItem.as:158-165
	private function clearTimer():Void {
		if (this._timerID > 0) {
			FrameTimer.clearTimeout(this._timerID);
		}
		this._timerID = -1;
	}
}
