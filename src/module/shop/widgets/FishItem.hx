package module.shop.widgets;

import com.qzone.qui.styles.Style;
import com.qzone.qui.utils.FrameTimer;
import common.Consts;
import common.misc.Utils;
import entities.ShopFish;
import framework.base.BaseTileItem;
import openfl.display.MovieClip;
import openfl.text.TextField;
import shim.As3;

/**
 * module.shop.widgets.FishItem —— FishItem.as 逐句对应（issue #35 功能
 * swf 翻译：商店）。鱼苗页瓦片子项：_lock 三档（0 锁定置灰 + FishLocked /
 * 1 可买 / 2 可解锁置灰 + FishUnlock），素材经 FrameTimer.setTimeout 延迟
 * 1 秒挂（原版防瓦片滚动时的连发加载，照抄）。setNameTimeout 原版即如此。
 */
class FishItem extends BaseTileItem {
	// FishItem.as:9
	private var _timerID:Int;

	// FishItem.as:11
	private var _lockIcon:MovieClip;

	// FishItem.as:13
	private var _loaded:Bool;

	// FishItem.as:15
	private var _nameText:TextField;

	// FishItem.as:17-32
	public function new() {
		super();
		this._timerID = -1;
		this._loaded = false;
		this._nameText = new TextField();
		this._nameText.selectable = false;
		this._nameText.width = 70;
		this._nameText.height = 20;
		addChild(this._nameText);
		this._nameText.x = -5;
		this._nameText.y = 60 + 2;
		createBackground("ItemBg");
	}

	// FishItem.as:34-41
	private function delaySetCrop():Void {
		if (this._item == null) {
			return;
		}
		this._material.setContent(Consts.ITEM_TYPE_FISH, As3.intOf(Reflect.field(this._item, "_id")));
		this._loaded = true;
	}

	// FishItem.as:43-79
	override private function set_data(param1:Dynamic):Dynamic {
		if (param1 == null || param1 == this._item && this._loaded == true) {
			this.clearTimer();
			return param1;
		}
		super.set_data(param1);
		var _loc2_:ShopFish = Std.isOfType(this._item, ShopFish) ? cast(this._item, ShopFish) : null;
		if (_loc2_ == null) {
			this.clearTimer();
			return param1;
		}
		this.clearTimer();
		this._timerID = FrameTimer.setTimeout(this.delaySetCrop, 1000);
		switch (_loc2_._lock) {
			case 0:
				this._material.filters = cast Style.getDisableFilter();
				this._lockIcon = Std.isOfType(Utils.getMaterial("FishLocked"), MovieClip)
					? cast(Utils.getMaterial("FishLocked"), MovieClip) : null;
				if (this._lockIcon != null) {
					addChild(this._lockIcon);
				}
			case 1:
				this._material.filters = null;
			case 2:
				this._material.filters = cast Style.getDisableFilter();
				this._lockIcon = Std.isOfType(Utils.getMaterial("FishUnlock"), MovieClip)
					? cast(Utils.getMaterial("FishUnlock"), MovieClip) : null;
				if (this._lockIcon != null) {
					addChild(this._lockIcon);
				}
		}
		this._nameText.htmlText = "<p align=\"center\"><font color=\"#FF6600\"><b>" + _loc2_._name + "</b><font/></p>";
		registerListeners();
		return param1;
	}

	// FishItem.as:81-88
	private function clearTimer():Void {
		if (this._timerID > 0) {
			FrameTimer.clearTimeout(this._timerID);
		}
		this._timerID = -1;
	}
}
