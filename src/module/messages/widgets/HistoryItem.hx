package module.messages.widgets;

import common.Consts;
import common.Settings;
import com.qzone.qui.utils.FrameTimer;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import shim.As3;
import framework.base.BaseTileItem;

/**
 * module.messages.widgets.HistoryItem —— HistoryItem.as 逐句对应（issue #19）。
 * 成果/成鱼瓦片：ItemBg 背景 + 延迟 _setIconDelay 毫秒才落素材（防瓦片快速
 * 刷过时抢图），harvestNumber 缺位走鱼 cid、有则走种子 cId；角标文本 =
 * 收获数+偷菜数。
 */
class HistoryItem extends BaseTileItem {
	// HistoryItem.as:13
	private var _setCropInter:Int;

	// HistoryItem.as:15
	private var _setIconDelay:Int;

	// HistoryItem.as:17
	private var _text:TextField;

	// HistoryItem.as:19
	private var _hasSetCrop:Bool;

	public function new() {
		super();
		this._setCropInter = -1;
		var _loc1_:String = Settings.getInstance().getStringAttribute("setIconDelay");
		if (_loc1_ != "") {
			// PORT-NOTE: AS3 int 字段落 NaN 归 0（isNaN 分支靠它进默认值）
			var _parsed:Float = As3.parseInt(_loc1_);
			this._setIconDelay = Math.isNaN(_parsed) ? 0 : Std.int(_parsed);
		}
		// Math.isNaN(int) 恒 false，照抄原句形态
		if (this._setIconDelay == 0 || Math.isNaN(this._setIconDelay) == true) {
			this._setIconDelay = 1000;
		}
		this.init();
	}

	// HistoryItem.as:33-50
	private function onDelayShowPic():Void {
		if (this._setCropInter != -1) {
			FrameTimer.clearTimeout(this._setCropInter);
		}
		this._setCropInter = -1;
		this._hasSetCrop = true;
		// `super.data["harvestNumber"] == undefined`：键缺位或值 null 都算
		if (!(As3.hasProp(super.data, "harvestNumber")
			&& Reflect.field(super.data, "harvestNumber") != null)) {
			this._material.setContent(Consts.ITEM_TYPE_FISH, As3.intOf(Reflect.field(_item, "cid")));
		} else {
			this._material.setContent(Consts.ITEM_TYPE_SEED, As3.intOf(Reflect.field(_item, "cId")));
		}
		this._material.hideLoading();
	}

	// HistoryItem.as:52-67
	private function init():Void {
		createBackground("ItemBg");
		this._text = new TextField();
		this._text.selectable = false;
		this._text.width = 60;
		this._text.height = 22;
		this._text.defaultTextFormat = new TextFormat("embedFontA", 14, 16737792, null, null, null, null, null,
			TextFormatAlign.CENTER);
		this._text.embedFonts = true;
		this._text.x = 0;
		this._text.y = 60;
		this._text.text = "0";
		addChild(this._text);
		registerListeners();
	}

	// HistoryItem.as:69-97
	override private function set_data(param1:Dynamic):Dynamic {
		super.data = param1;
		if (param1 == null || param1 == _item && this._hasSetCrop == true) {
			if (this._setCropInter != -1) {
				FrameTimer.clearTimeout(this._setCropInter);
			}
			this._setCropInter = -1;
			return param1;
		}
		FrameTimer.clearTimeout(this._setCropInter);
		this._setCropInter = FrameTimer.setTimeout(this.onDelayShowPic, this._setIconDelay);
		var _loc2_:Int = 0;
		if (!(As3.hasProp(super.data, "harvestNumber")
			&& Reflect.field(super.data, "harvestNumber") != null)) {
			// 原文 :87 `var _loc2_:int`：parseInt 缺位得 NaN、赋回 int 走
			// ToInt32（NaN→0），角标印 "0" 不印 "NaN"
			_loc2_ = As3.intOf(As3.parseInt(Reflect.field(param1, "hn")) + As3.parseInt(Reflect.field(param1, "sn")));
		} else {
			_loc2_ = As3.intOf(As3.parseInt(Reflect.field(param1, "harvestNumber"))
				+ As3.parseInt(Reflect.field(param1, "scroungeNumber")));
		}
		this._text.text = Std.string(_loc2_);
		return param1;
	}
}
