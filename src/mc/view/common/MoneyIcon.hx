package mc.view.common;

import openfl.display.Sprite;

/**
 * mc.view.common.MoneyIcon —— MoneyIcon.as 的签名面 stub（原类 65 loc，
 * issue #87「通用视图」片充真身）。币种图标：gold/fb/rp 三型各取素材，
 * unknown 型构造时跳过、set type 时补装且仅补一次（type==X 门）。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/MoneyIcon.as。
 */
@:keep
class MoneyIcon extends Sprite {
	// MoneyIcon.as:9-15
	public static final GOLD:String = "gold";
	public static final FB:String = "fb";
	public static final X:String = "unknown";
	public static final RP:String = "rp";

	// MoneyIcon.as:17
	private var _type:String = "";

	// MoneyIcon.as:19-28
	public function new(param1:String = "gold") {
		super();
		throw new openfl.errors.Error("not implemented");
	}

	// MoneyIcon.as:30-36/:59-63（type 存取——setter 仅 _type==X 时补装）
	public var type(get, set):String;

	private function get_type():String {
		return this._type;
	}

	private function set_type(param1:String):String {
		throw new openfl.errors.Error("not implemented");
	}
}
