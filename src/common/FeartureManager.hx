package common;

import com.adobe.utils.StringUtil;
import common.Session;
import shim.As3;

// common.FeartureManager —— FeartureManager.as 逐句对应。
// PORT-NOTE: `return false`（Boolean）与 `return String`（steal_tips）混用的 `*`
// 返回 → Dynamic，照原样。
@:final
class FeartureManager {
	public function new() {}

	// FeartureManager.as:11-16
	// PORT-NOTE: Haxe 的 % 优先级高于 /（AS3 同级左结合），`x/100%10`
	// 会解析成 x/(100%10) 即 x/0，必须显式括号（同 FarmLite.openByFlashVar
	// 的坑；修正前恒 0 → 恒「关」）
	public static function openByFlashVar():Bool {
		var _loc1_:String = Settings.getInstance().getStringAttribute("useflag");
		var _loc2_:Int = As3.intOf((As3.parseInt(_loc1_) / 100) % 10);
		return _loc2_ == 0;
	}

	// FeartureManager.as:18-30
	public static function stealOtherMod():Dynamic {
		var _loc1_:String = Settings.getInstance().getStringAttribute("steal");
		var _loc2_:String = Settings.getInstance().getStringAttribute("steal_mod");
		var _loc3_:Int = Std.int(Session.getInstance().currentUser._uId);
		if (checkRange(_loc3_, _loc1_, As3.intOf(_loc2_))) {
			return Settings.getInstance().getStringAttribute("steal_tips_other");
		}
		return false;
	}

	// FeartureManager.as:32-44
	public static function stealMod():Dynamic {
		var _loc1_:String = Settings.getInstance().getStringAttribute("steal");
		var _loc2_:String = Settings.getInstance().getStringAttribute("steal_mod");
		var _loc3_:Int = As3.intOf(Session.getInstance().hostId);
		if (checkRange(_loc3_, _loc1_, As3.intOf(_loc2_))) {
			return Settings.getInstance().getStringAttribute("steal_tips");
		}
		return false;
	}

	// FeartureManager.as:46-66
	private static function checkRange(param1:Int, param2:String, param3:Int):Bool {
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:Array<Dynamic> = null;
		var _loc6_:String = null;
		var _loc7_:Array<Dynamic> = null;
		if (As3.truthy(param2)) {
			_loc4_ = [];
			_loc5_ = param2.split(",");
			param1 %= param3;
			for (_loc6_ in (_loc5_:Array<Dynamic>)) {
				_loc7_ = _loc6_.split("-");
				if (param1 >= As3.intOf(StringUtil.trim(_loc7_[0])) && param1 <= As3.intOf(StringUtil.trim(_loc7_[1]))) {
					return true;
				}
			}
		}
		return false;
	}

	// FeartureManager.as:68-83
	public static function friendListMod():Dynamic {
		var _loc1_:Settings = Settings.getInstance();
		var _loc2_:String = _loc1_.getStringAttribute("friend_list");
		var _loc3_:String = "";
		if (_loc1_.mode == "qzone") {
			_loc3_ = _loc1_.getStringAttribute("friend_list_mod_qz");
		} else {
			_loc3_ = _loc1_.getStringAttribute("friend_list_mod_xy");
		}
		var _loc4_:Int = As3.intOf(Session.getInstance().hostId);
		if (checkRange(_loc4_, _loc2_, As3.intOf(_loc3_))) {
			return Settings.getInstance().getStringAttribute("friend_list_tips");
		}
		return false;
	}
}
