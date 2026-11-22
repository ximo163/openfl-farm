package module.warehouse.house.widgets;

import com.qzone.qui.controls.Label;
import com.qzone.qui.styles.Style;
import com.qzone.qui.utils.FrameTimer;
import com.qzone.utils.AlignUtil;
import common.Consts;
import common.Settings;
import common.misc.Utils;
import entities.WarehouseCrop;
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
 * module.warehouse.house.widgets.PlantRenderItem —— PlantRenderItem.as
 * 逐句对应（issue #36 功能 swf 翻译：仓库）。蔬果/鲜花/材料瓦格子项：
 * ItemBg 底 + 数量角标 + 锁图标（SellLockIcon，点击冒 LOCK_ICON_CLICKED）
 * + 等级角标 + VIP 种子角标；物料图延迟 setIconDelay 毫秒挂（FrameTimer
 * 防滚动连发，与商店瓦片同款）。
 *
 * PORT-NOTE: `super._item` 的超类字段限定 → this.（Haxe 禁 super.field，
 * 无遮蔽语义同形）；`x as T` → 取一次素材再 isOfType 门 + 直取（BaseTileItem
 * 先例，别双调 getMaterial——符号壳会构造两份）；`k != undefined` /
 * `hasOwnProperty(k) == true` → As3.hasProp；`_id as int` → As3.intOf；
 * `param1._lvl + "级"` 的 Dynamic 串接 → Std.string；override set data 的
 * Haxe 覆写须带返回值（回写后返 param1，机械）。
 */
class PlantRenderItem extends BaseTileItem {
	// PlantRenderItem.as:23
	public static final LOCK_ICON_CLICKED:String = "LockIconClicked";

	// PlantRenderItem.as:25
	private var _setCropTime:Int;

	// PlantRenderItem.as:27
	private var _lockIcon:MovieClip;

	// PlantRenderItem.as:29
	private var _amountText:TextField;

	// PlantRenderItem.as:31
	private var _levelLabel:Label;

	// PlantRenderItem.as:33
	private var _vipIcon:MovieClip;

	// PlantRenderItem.as:35-75
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
		this._levelLabel = new Label("");
		addChild(this._levelLabel);
		this._levelLabel.textField.defaultTextFormat = new TextFormat("Verdana", 12, 233195);
		this._levelLabel.textField.filters = cast Style.getTextGlowFilter();
		this._levelLabel.x = 1;
		this._levelLabel.y = AlignUtil.right(_bg.height, this._levelLabel.height) + 1;
		this._setCropTime = -1;
		// 原版不判空直用（VipSeedIcon 缺符号时此处即 NPE，照抄）
		var vipMat:Dynamic = Utils.getMaterial("VipSeedIcon");
		this._vipIcon = Std.isOfType(vipMat, MovieClip) ? cast(vipMat, MovieClip) : null;
		this._vipIcon.x = 1;
		this._vipIcon.y = 1;
		this._vipIcon.scaleX = 0.6;
		this._vipIcon.scaleY = 0.6;
	}

	// PlantRenderItem.as:77-105
	private function onTimeout():Void {
		var _loc1_:WarehouseCrop = null;
		this.stopFrameTimer();
		if (this._item != null && As3.hasProp(this._item, "_id")) {
			if (Std.isOfType(this._item, WarehouseCrop)) {
				_loc1_ = cast(this._item, WarehouseCrop);
				if (Std.string(_loc1_._type) == Consts.ITEM_TYPE_CARD) {
					_material.setContent(Consts.ITEM_TYPE_CARD, As3.intOf(Reflect.field(this._item, "_id")));
					_material.scaleX = _material.scaleY = 0.51;
					_material.x = 15;
					_material.y = 15;
				} else if (Std.string(_loc1_._type) == Consts.ITEM_TYPE_CRYSTAL) {
					_material.setContent(Consts.ITEM_TYPE_CRYSTAL, As3.intOf(Reflect.field(this._item, "_id")));
				} else {
					_material.setContent(Consts.ITEM_TYPE_SEED, As3.intOf(Reflect.field(this._item, "_id")));
				}
				return;
			}
			_material.setContent(Consts.ITEM_TYPE_SEED, As3.intOf(Reflect.field(this._item, "_id")));
		}
	}

	// PlantRenderItem.as:107-121
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

	// PlantRenderItem.as:123-177
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
		if (this._levelLabel != null && As3.hasProp(param1, "_lvl") && Std.string(Reflect.field(param1, "_type")) != Consts.ITEM_TYPE_CARD) {
			this._levelLabel.text = Std.string(Reflect.field(param1, "_lvl")) + "级";
		} else if (Std.string(Reflect.field(param1, "_type")) != Consts.ITEM_TYPE_CARD) {
			this._levelLabel.text = "0级";
		} else {
			this._levelLabel.text = "";
		}
		if (As3.floatOf(Reflect.field(param1, "_isVip")) == 1) {
			addChild(this._vipIcon);
		}
		registerListeners();
		return param1;
	}

	// PlantRenderItem.as:179-186
	private function stopFrameTimer():Void {
		if (this._setCropTime != -1) {
			FrameTimer.clearTimeout(this._setCropTime);
		}
		this._setCropTime = -1;
	}

	// PlantRenderItem.as:188-208
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
}
