package module.warehouse.house.widgets;

import com.qzone.qui.utils.FrameTimer;
import common.Consts;
import common.Settings;
import common.misc.Utils;
import entities.WarehouseFish;
import events.CommonEvent;
import openfl.display.MovieClip;
import openfl.display.Shape;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import framework.base.BaseTileItem;
import shim.As3;

/**
 * module.warehouse.house.widgets.FishRenderItem —— FishRenderItem.as 逐句
 * 对应（issue #36 功能 swf 翻译：仓库）。成鱼瓦格子项：ItemBg 底 + 数量角标
 * + 锁图标（SellLockIcon，点击冒 LOCK_ICON_CLICKED）；物料图延迟
 * setIconDelay 毫秒挂（FrameTimer，同 PlantRenderItem）。
 *
 * PORT-NOTE: `super._item` → this.（Haxe 禁 super.field）；`x as T` → 取一次
 * 素材再 isOfType 门 + 直取；`k != undefined` / `hasOwnProperty(k) == true` →
 * As3.hasProp；override set data 的 Haxe 覆写须带返回值（机械）。
 */
class FishRenderItem extends BaseTileItem {
	// FishRenderItem.as:20
	public static final LOCK_ICON_CLICKED:String = "LockIconClicked";

	// FishRenderItem.as:22
	private var _lockIcon:MovieClip;

	// FishRenderItem.as:24
	private var _amountText:TextField;

	// FishRenderItem.as:26
	private var _setCropTime:Int;

	// FishRenderItem.as:28-57
	public function new() {
		super();
		createBackground("ItemBg");
		this._amountText = new TextField();
		this._amountText.defaultTextFormat = new TextFormat("embedFontA", 14, 39423, true, null, null, null, null, TextFormatAlign.CENTER);
		this._amountText.embedFonts = true;
		this._amountText.selectable = false;
		this._amountText.mouseEnabled = false;
		this._amountText.width = _bg.width;
		this._amountText.height = 23;
		this._amountText.x = 0;
		this._amountText.y = _bg.height;
		this._amountText.text = "20";
		addChild(this._amountText);
		var _loc1_:Shape = new Shape();
		_loc1_.graphics.beginFill(0, 0);
		_loc1_.graphics.drawRect(0, 0, 10, 1);
		_loc1_.graphics.endFill();
		_loc1_.y = 90;
		addChild(_loc1_);
		var lockMat:Dynamic = Utils.getMaterial("SellLockIcon");
		this._lockIcon = Std.isOfType(lockMat, MovieClip) ? cast(lockMat, MovieClip) : null;
		if (this._lockIcon != null) {
			this.mouseChildren = true;
			this._lockIcon.addEventListener(MouseEvent.CLICK, this.onLockClicked, false, 0, true);
			addChild(this._lockIcon);
		}
		this._setCropTime = -1;
	}

	// FishRenderItem.as:59-66
	private function stopFrameTimer():Void {
		if (this._setCropTime != -1) {
			FrameTimer.clearTimeout(this._setCropTime);
		}
		this._setCropTime = -1;
	}

	// FishRenderItem.as:68-77。`_item as WarehouseFish` 结果未用（原版照抄）
	private function onTimeout():Void {
		var _loc1_:WarehouseFish = null;
		this.stopFrameTimer();
		if (this._item != null && As3.hasProp(this._item, "_id")) {
			_loc1_ = Std.isOfType(this._item, WarehouseFish) ? cast(this._item, WarehouseFish) : null;
			_material.setContent(Consts.ITEM_TYPE_FISH, As3.intOf(Reflect.field(this._item, "_id")));
		}
	}

	// FishRenderItem.as:79-117
	override private function set_data(param1:Dynamic):Dynamic {
		var _loc2_:String = null;
		var _loc3_:Int = 0;
		if (param1 == null || param1 == this._item) {
			this.stopFrameTimer();
			return param1;
		}
		super.set_data(param1);
		this.stopFrameTimer();
		if (As3.hasProp(param1, "_id")) {
			_loc2_ = Settings.getInstance().getStringAttribute("setIconDelay");
			_loc3_ = 1000;
			if (_loc2_ != "") {
				_loc3_ = As3.intOf(As3.parseInt(_loc2_));
			}
			this._setCropTime = FrameTimer.setTimeout(this.onTimeout, _loc3_);
		}
		if (this._amountText != null && As3.hasProp(param1, "_amount")) {
			this._amountText.text = Std.string(Reflect.field(param1, "_amount"));
		} else {
			this._amountText.text = "0";
		}
		if (this._lockIcon != null && As3.hasProp(param1, "_isLock")) {
			this._lockIcon.gotoAndStop(As3.floatOf(Reflect.field(param1, "_isLock")) > 0 ? "lock" : "unlock");
		} else {
			this._lockIcon.gotoAndStop("unlock");
		}
		registerListeners();
		return param1;
	}

	// FishRenderItem.as:119-139
	private function onLockClicked(param1:MouseEvent):Void {
		if (this._lockIcon == null) {
			return;
		}
		var _loc2_:Bool = false;
		if (this._lockIcon.currentLabel == "lock") {
			_loc2_ = false;
		} else if (this._lockIcon.currentLabel == "unlock") {
			_loc2_ = true;
		}
		dispatchEvent(new CommonEvent(LOCK_ICON_CLICKED, {
			"item": this._item,
			"lock": _loc2_
		}));
		param1.stopImmediatePropagation();
	}

	// FishRenderItem.as:141-155
	public function refreshLock():Void {
		if (this._lockIcon == null || this._item == null) {
			return;
		}
		if (As3.floatOf(Reflect.field(this._item, "_isLock")) > 0) {
			this._lockIcon.gotoAndStop("lock");
		} else {
			this._lockIcon.gotoAndStop("unlock");
		}
	}
}
