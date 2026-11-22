package module.shop.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.styles.Style;
import com.qzone.qui.utils.FrameTimer;
import com.qzone.utils.AlignUtil;
import common.Session;
import common.misc.Utils;
import entities.Seed;
import framework.base.BaseTileItem;
import openfl.display.MovieClip;
import openfl.display.Shape;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;

/**
 * module.shop.widgets.CropItemVip —— CropItemVip.as 逐句对应（issue #35
 * 功能 swf 翻译：商店）。种子页 VIP 专属瓦片（149x170 大格）：125 底 +
 * 名字/描述双行文字、VipSeedIcon 角标、素材 2 倍缩放偏移 -5 居中。
 * setContent("1", _id) 的 "1" 即 Consts.ITEM_TYPE_SEED 原字面量（照抄）。
 */
class CropItemVip extends BaseTileItem {
	// CropItemVip.as:11
	private var _timerID:Int;

	// CropItemVip.as:13
	private var _loaded:Bool;

	// CropItemVip.as:15
	private var _vipIcon:MovieClip;

	// CropItemVip.as:17
	private var _levelLabel:Label;

	// CropItemVip.as:19
	private var _nameText:TextField;

	// CropItemVip.as:21
	private var _descText:TextField;

	// CropItemVip.as:23-83
	public function new() {
		var _loc3_:Shape = null;
		super();
		createBackground("ItemBgRed", 125, 125);
		this._timerID = -1;
		this._loaded = false;
		var _loc1_:TextFormat = new TextFormat();
		_loc1_.size = 14;
		_loc1_.bold = true;
		_loc1_.color = 12284739;
		_loc1_.align = TextFormatAlign.CENTER;
		this._nameText = new TextField();
		this._nameText.width = 125;
		this._nameText.height = 20;
		this._nameText.defaultTextFormat = _loc1_;
		this._nameText.selectable = false;
		addChild(this._nameText);
		this._nameText.x = 0;
		this._nameText.y = this._bg.height;
		var _loc2_:TextFormat = new TextFormat();
		_loc2_.size = 12;
		_loc2_.bold = false;
		_loc2_.color = 13084462;
		_loc2_.align = TextFormatAlign.CENTER;
		this._descText = new TextField();
		this._descText.width = 125;
		this._descText.height = 19;
		this._descText.defaultTextFormat = _loc2_;
		this._descText.selectable = false;
		addChild(this._descText);
		this._descText.x = 0;
		this._descText.y = this._nameText.y + this._nameText.height;
		_loc3_ = new Shape();
		_loc3_.graphics.beginFill(16711680, 0);
		_loc3_.graphics.drawRect(0, 0, 10, 1);
		_loc3_.graphics.endFill();
		_loc3_.y = 100;
		addChild(_loc3_);
		this._material.scaleX = 2;
		this._material.scaleY = 2;
		this._material.x = (this._bg.width - this._material.width) / 2 - 5;
		this._material.hideLoading();
		this._vipIcon = Std.isOfType(Utils.getMaterial("VipSeedIcon"), MovieClip)
			? cast(Utils.getMaterial("VipSeedIcon"), MovieClip) : null;
		this._vipIcon.x = 2;
		this._vipIcon.y = 1;
		addChild(this._vipIcon);
		this._levelLabel = new Label("");
		this.addChild(this._levelLabel);
		this._levelLabel.textDefaultFormat = new TextFormat("Verdana", 14, 9211020);
		this._levelLabel.textField.filters = cast Style.getTextGlowFilter();
		this._levelLabel.y = AlignUtil.right(120, this._levelLabel.height) + 2;
		this._levelLabel.x = 3;
	}

	// CropItemVip.as:85-119
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
		var _loc3_:TextFormat = this._levelLabel.textDefaultFormat;
		var _loc4_:Int = 0;
		var _loc5_:Session = Session.getInstance();
		if (_loc5_ != null && _loc5_.host != null) {
			_loc4_ = _loc5_.host.level;
		}
		if (_loc2_._lvl <= _loc4_) {
			_loc3_.color = 16737792;
		}
		this.clearTimer();
		this._timerID = FrameTimer.setTimeout(this.delaySetCrop, 1000);
		this._nameText.htmlText = _loc2_._name;
		this._descText.htmlText = _loc2_._vipDesc;
		this._levelLabel.text = Std.string(_loc2_._lvl) + "级";
		registerListeners();
		return param1;
	}

	// CropItemVip.as:121-128
	private function delaySetCrop():Void {
		if (this._item == null) {
			return;
		}
		this._material.setContent("1", As3.intOf(Reflect.field(this._item, "_id")));
		this._loaded = true;
	}

	// CropItemVip.as:130-137
	private function clearTimer():Void {
		if (this._timerID > 0) {
			FrameTimer.clearTimeout(this._timerID);
		}
		this._timerID = -1;
	}
}
