package common.view;

import common.misc.Utils;
import openfl.display.Sprite;
import shim.As3;

/**
 * common.view.MoneyIcon —— MoneyIcon.as 逐句对应（issue #9）。货币图标：
 * gold→GoldIcon、fb→QB、rp→RPIcon（素材存在才挂）；X（unknown）态只记
 * 类型等待 type setter 补挂。
 */
@:keep
class MoneyIcon extends Sprite {
	// MoneyIcon.as:9-15
	public static final FB:String = "fb";
	public static final GOLD:String = "gold";
	public static final X:String = "unknown";
	public static final RP:String = "rp";

	// MoneyIcon.as:17
	private var _type:String = "";

	// MoneyIcon.as:19-28
	public function new(param1:String = "gold") {
		super();
		if (param1 == X) {
			this._type = param1;
			return;
		}
		this.setIconType(param1);
	}

	// MoneyIcon.as:30-32/:55-61
	public var type(get, set):String;

	private function get_type():String {
		return this._type;
	}

	// MoneyIcon.as:56-60（只有 X 态接受补挂；其余静默忽略）
	private function set_type(param1:String):String {
		if (this._type == X) {
			this.setIconType(param1);
		}
		return param1;
	}

	// MoneyIcon.as:35-53（rp 分支判素材存在（Boolean() 真值）才 addChild；
	// 素材缺位时 addChild(null) 与原版同样抛错，不加判空）
	private function setIconType(param1:String):Void {
		var _loc2_:String = "GoldIcon";
		var _loc3_:String = "QB";
		var _loc4_:String = "RPIcon";
		if (param1 == GOLD) {
			addChild(cast Utils.getMaterial(_loc2_));
		} else if (param1 == FB) {
			addChild(cast Utils.getMaterial(_loc3_));
		} else if (param1 == RP && As3.truthy(Utils.getMaterial(_loc4_))) {
			addChild(cast Utils.getMaterial(_loc4_));
		}
		this._type = param1;
	}
}
