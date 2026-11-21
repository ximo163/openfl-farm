package mc.view.farm.land;

import common.LocalData;
import common.MaterialLib;
import openfl.display.MovieClip;
import mc.view.main.tip.Tip;
import shim.As3;

/**
 * mc.view.farm.land.HouseTip —— HouseTip.as 逐句对应（issue #19 Master2
 * 闭包顺手译）。畜舍提示：定位相对滚动视口。LocalData 为 mcloader 片 stub。
 */
@:keep
class HouseTip extends Tip {
	private var _tip:MovieClip;

	public function new() {
		super();
		this._tip = cast MaterialLib.getInstance().getMaterial("HouseTip");
		addChild(this._tip);
	}

	// HouseTip.as:20-29（AS3 `param1.name == "house1"` 为宽松等，经 eqString）
	override public function set_data(param1:Dynamic):Dynamic {
		this.x = Reflect.field(param1, "x") - LocalData.rollCollection.scrollRect.x;
		this.y = Reflect.field(param1, "y") - LocalData.rollCollection.scrollRect.y;
		if (As3.eqString(Reflect.field(param1, "name"), "house1")) {
			this.x += 140;
			this.y += -80;
		}
		return param1;
	}
}
