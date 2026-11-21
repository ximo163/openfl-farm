package common.view.floating;

import common.Consts;
import common.Session;
import interfaces.IMsgCenter;
import shim.As3;

/**
 * common.view.floating.AddExpFloating —— AddExpFloating.as 逐句对应
 * （issue #9）。加经验飘字：宿主精灵（花仙/花神）加成时文本追加 "(↑rate%)"。
 * `super._data["value"]` 落 int 的取值链同 AddMoneyFloating.start。
 */
@:keep
class AddExpFloating extends AddMoneyFloating {
	// AddExpFloating.as:10-14
	public function new(param1:IMsgCenter) {
		super(param1);
		this.floatName = Consts.FLOAT_TYPE_EXP;
	}

	// AddExpFloating.as:16-26（value 在 (2,100) 开区间且宿主精灵是
	// FAIRY_LADY/FAIRY_GOD 时追加加成后缀；`== 常量` 是 AS3 松等，itemId
	// 数值/字符串双形态经 As3.floatOf）
	override public function start(param1:Dynamic):Void {
		super.start(param1);
		var _loc2_:Int = As3.intOf(Reflect.field(this._data, "value"));
		var _loc3_:Dynamic = Session.getInstance().myFairy;
		if (_loc2_ > 2 && _loc2_ < 100 && _loc3_ != null
			&& (As3.floatOf(Reflect.field(_loc3_, "itemId")) == Consts.FAIRY_LADY
				|| As3.floatOf(Reflect.field(_loc3_, "itemId")) == Consts.FAIRY_GOD)) {
			var _loc4_:Dynamic = As3.childOf(this._addAddAnimation, "addValueBox");
			var addValue:Dynamic = As3.childOf(_loc4_, "addValue");
			addValue.text = addValue.text + "(↑" + Std.string(Reflect.field(_loc3_, "rate")) + "%)";
		}
	}
}
