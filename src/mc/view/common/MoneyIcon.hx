package mc.view.common;

import common.MaterialLib;
import openfl.display.Sprite;

/**
 * mc.view.common.MoneyIcon —— MoneyIcon.as 逐句对应（issue #87 牧场
 * 「通用视图」片；#19 签名面 stub 充真身）。币种图标：gold/fb/rp 三型
 * 各取素材（GoldIcon/QB/RPIcon），unknown 型构造时跳过、set type 时
 * 补装且仅补一次（type==X 门）。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/MoneyIcon.as。
 *
 * PORT-NOTE（`getMaterial(...) as Sprite` 三处）：as 失配-null 语义走
 * isOfType 门 + 直取（lessons #7）。原文无 null 守卫——素材表为空时
 * addChild(null) 在 openfl 抛 Error #2007（单测环境所以 gold/fb/rp
 * 构造面不可钉，见 MoneyIconTest 类头），原版生产环境素材先行装载、
 * 该路径永不 null，行为一致。
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
		if (param1 == X) {
			this._type = param1;
			return;
		}
		this.setIconType(param1);
	}

	// MoneyIcon.as:30-36/:59-63（type 存取——setter 仅 _type==X 时补装）
	public var type(get, set):String;

	private function set_type(param1:String):String {
		if (this._type == X) {
			this.setIconType(param1);
		}
		return param1;
	}

	// MoneyIcon.as:38-57（_loc2_/_loc3_ 的串字面量赋值两行是原文顺序
	// ——_loc2_ "GoldIcon"、_loc3_ "QB"，随后按型取用；"RPIcon" 是
	// 行内字面量。_type 无条件覆写 param1——未识别型也落 _type）
	private function setIconType(param1:String):Void {
		var _loc2_:String = "";
		var _loc3_:String = "";
		_loc2_ = "GoldIcon";
		_loc3_ = "QB";
		if (param1 == GOLD) {
			addChild(asSprite(MaterialLib.getInstance().getMaterial(_loc2_)));
		} else if (param1 == FB) {
			addChild(asSprite(MaterialLib.getInstance().getMaterial(_loc3_)));
		} else if (param1 == RP) {
			addChild(asSprite(MaterialLib.getInstance().getMaterial("RPIcon")));
		}
		this._type = param1;
	}

	private function get_type():String {
		return this._type;
	}

	// `x as Sprite`（isOfType ? cast : null，本文件三处素材通道共用）
	private static function asSprite(param1:Dynamic):Sprite {
		return Std.isOfType(param1, Sprite) ? cast(param1, Sprite) : null;
	}
}
