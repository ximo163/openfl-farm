package mc.fBridge;

import com.adobe.utils.StringUtil;
import common.LocalData;
import mc.model.MData;
import shim.As3;

/**
 * mc.fBridge.FeartureManager —— FeartureManager.as 逐句对应（issue #87
 * 「网络」片）。按 uin 取模分桶的功能灰度开关：enter/steal/friendList
 * 三通道各查 LocalData.parameters 的 pasture_<名>（逗号分隔的 a-b 区间表）
 * 与 pasture_<名>_mod（模数），命中返回 pasture_<名>_tips 文案。
 * legacy/decompiled/Master2_v_142/scripts/mc/FBridge/FeartureManager.as。
 * 注意与 main3 的 common.FeartureManager 是两个不同的类。
 *
 * PORT-NOTE（parameters/host 动态键读）：`LocalData.parameters.pasture_enter`
 * 与 `mainData.host["uin"]` 是 AS3 Object 动态键——Reflect.field 通道。
 * `int(x)` 强转 → As3.intOf（数字串解析、undefined/null → 0，缺键的
 * mod 落 0 使 Boolean(mod) 门为假——test_missing_params 所钉语义）；
 * `parseInt(...)` → As3.parseInt（前缀整数段解析，trim 后空白吸收）。
 * PORT-NOTE（Boolean 三门，:45）：range 串非空、uin 非零、mod 非零——
 * 形参是 String/Int 类型通道但运行时可 null，As3.truthy 复刻 AS3 真值
 * 规则（""/0/null 皆假）。
 */
@:keep
class FeartureManager {
	// FeartureManager.as:10-13
	public function new() {}

	// FeartureManager.as:15-25
	public static function enterMod():String {
		var _loc1_:String = Reflect.field(LocalData.parameters, "pasture_enter");
		var _loc2_:Int = As3.intOf(Reflect.field(LocalData.parameters, "pasture_enter_mod"));
		var _loc3_:Int = As3.intOf(Reflect.field(MData.getInstance().mainData.host, "uin"));
		if (checkRange(_loc3_, _loc1_, _loc2_)) {
			return Reflect.field(LocalData.parameters, "pasture_enter_tips");
		}
		return null;
	}

	// FeartureManager.as:27-37
	public static function stealMod():String {
		var _loc1_:String = Reflect.field(LocalData.parameters, "pasture_steal");
		var _loc2_:Int = As3.intOf(Reflect.field(LocalData.parameters, "pasture_steal_mod"));
		var _loc3_:Int = As3.intOf(Reflect.field(MData.getInstance().mainData.host, "uin"));
		if (checkRange(_loc3_, _loc1_, _loc2_)) {
			return Reflect.field(LocalData.parameters, "pasture_steal_tips");
		}
		return null;
	}

	// FeartureManager.as:39-60（`param1 %= param3` 取模落桶后逐段闭区间
	// 比较；段内 "a-b" split 两端经 StringUtil.trim 后 parseInt）
	private static function checkRange(param1:Int, param2:String, param3:Int):Bool {
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:Array<Dynamic> = null;
		var _loc6_:String = null;
		var _loc7_:Array<Dynamic> = null;
		if (As3.truthy(param2) && As3.truthy(param1) && As3.truthy(param3)) {
			_loc4_ = [];
			_loc5_ = param2.split(",");
			param1 = param1 % param3;
			for (_loc6_ in _loc5_) {
				_loc7_ = _loc6_.split("-");
				if (param1 >= As3.parseInt(StringUtil.trim(_loc7_[0])) && param1 <= As3.parseInt(StringUtil.trim(_loc7_[1]))) {
					return true;
				}
			}
		}
		return false;
	}

	// FeartureManager.as:62-72
	public static function friendListMod():String {
		var _loc1_:String = Reflect.field(LocalData.parameters, "pasture_friend_list");
		var _loc2_:Int = As3.intOf(Reflect.field(LocalData.parameters, "pasture_friend_list_mod"));
		var _loc3_:Int = As3.intOf(Reflect.field(MData.getInstance().mainData.host, "uin"));
		if (checkRange(_loc3_, _loc1_, _loc2_)) {
			return Reflect.field(LocalData.parameters, "pasture_friend_list_tips");
		}
		return null;
	}
}
