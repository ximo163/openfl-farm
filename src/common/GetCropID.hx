package common;

import com.qzone.qfa.control.Application;
import common.misc.Utils;
import shim.As3;

/**
 * common.GetCropID —— 闭包成员补齐（issue #8，V3b 场景渲染片）。
 * 原版 legacy/decompiled/main3_v_221/scripts/common/GetCropID.as（772 loc > 100，
 * issue 闭包规则整类不翻）；本片用到的成员按行号逐句照抄：
 * - SG_*（:12-18）、idToDiyUrl2（:81-107）、getCropUrl（:142-178）、
 *   getCropByID（:267-287）、getAssetUrl（:299-341）、getInsectPosition
 *   （:356-373）、specialGrow（:559-587）、idToBoardUrl（:739-772）。
 * 其余成员保持 stub 返回值（见各方法头）。
 */
class GetCropID {
	// GetCropID.as:10
	public static var theApp:Application;

	// GetCropID.as:12-18（specialGrow 的四档组合）
	public static final SG_PUBLIC_SEED_PUBLIC_DEAD:Int = 0;
	public static final SG_SPECIAL_SEED:Int = 1;
	public static final SG_SPECIAL_DEAD:Int = 2;
	public static final SG_SPECIAL_SEED_SPECIAL_DEAD:Int = 3;

	public function new() {}

	// GetCropID.as:81-107（idToDiyUrl2：item_info 里按道具 id 查装饰素材 URL）
	public static function idToDiyUrl2(param1:String):String {
		var _loc4_:Dynamic = null;
		var _loc2_:String = "";
		if (theApp.model == null || param1 == "" || param1 == null) {
			return _loc2_;
		}
		var _loc3_:Array<Dynamic> = theApp.model.getData("item_info");
		if (_loc3_ == null) {
			return _loc2_;
		}
		for (_loc4_ in (_loc3_ : Array<Dynamic>)) {
			if (As3.eqString(Reflect.field(_loc4_, "id"), param1)) {
				var _loc5_:Dynamic = Reflect.field(_loc4_, "asset_id");
				// 原版 `_loc4_["asset_id"] == undefined || _loc4_["asset_id"]["m"] == undefined`
				if (_loc5_ == null || Reflect.field(_loc5_, "m") == null) {
					break;
				}
				_loc2_ = getAssetUrl(Reflect.field(_loc5_, "m"));
				return Utils.addPrefix(_loc2_);
			}
		}
		return _loc2_;
	}

	// GetCropID.as:142-178（getCropUrl：作物 id+生长档 → Crop_<id>_<n> 的 URL；
	// 档位折叠 2<step<6→3、step==6→4 与 assets 缺档回退 cropUrl+publicCropPrefix）
	public static function getCropUrl(param1:Int, param2:Int):String {
		var _loc3_:String = null;
		var _loc6_:String = null;
		var _loc7_:String = null;
		if (theApp.model == null || param1 <= 0) {
			return _loc3_;
		}
		var _loc4_:Dynamic = getCropByID(Std.string(param1));
		if (_loc4_ == null || !Reflect.hasField(_loc4_, "asset_id")) {
			return _loc3_;
		}
		if (param2 > 2 && param2 < 6) {
			param2 = 3;
		} else if (param2 == 6) {
			param2 = 4;
		}
		_loc3_ = getAssetUrl(Reflect.field(Reflect.field(_loc4_, "asset_id"), "m" + param2));
		if (!As3.truthy(_loc3_)) {
			_loc6_ = Settings.getInstance().getStringAttribute("cropUrl");
			_loc7_ = Settings.getInstance().getStringAttribute("publicCropPrefix");
			_loc3_ = _loc6_ + _loc7_ + param2 + ".swf";
		}
		var _loc5_:String = Settings.getInstance().appImgPrefix;
		if (_loc3_ != "" && _loc5_ != "") {
			_loc3_ = Utils.addPrefix(_loc3_);
			_loc3_ += "?domain=" + _loc5_ + ".appimg";
		}
		return _loc3_;
	}

	// GetCropID.as:267-287（getCropByID：crops 配置里按字符串 id 查条目）
	private static function getCropByID(param1:String):Dynamic {
		var _loc3_:Dynamic = null;
		if (theApp.model == null) {
			return null;
		}
		var _loc2_:Array<Dynamic> = theApp.model.getData("crops");
		if (_loc2_ == null) {
			return null;
		}
		for (_loc3_ in (_loc2_ : Array<Dynamic>)) {
			if (As3.eqString(Reflect.field(_loc3_, "id"), param1)) {
				return _loc3_;
			}
		}
		return null;
	}

	// GetCropID.as:299-341（getAssetUrl：assets 配置的 src → 部署相对路径）
	private static function getAssetUrl(param1:String):String {
		if (param1 == null || param1.length == 0) {
			return "";
		}
		if (theApp.model == null) {
			return "";
		}
		var _loc2_:Dynamic = theApp.model.getData("assets");
		if (_loc2_ == null || Reflect.field(_loc2_, param1) == null) {
			return "";
		}
		var _loc3_:String = Reflect.field(Reflect.field(_loc2_, param1), "src");
		if (_loc3_ == null || _loc3_ == "") {
			return "";
		}
		// PORT-NOTE: 原版常量确实是空串（swf.xml 字符串池里 "" 紧挨 "/diy/"，
		// FFDec 导出的 indexOf("") 非反编译噪声），`"任意串".indexOf("") == 0`
		// 恒成立 → 这里永远提前返回 src 原样；后面 /diy//fish//Card//Crop//Dog
		// 的前缀拼接在本部署里是死代码，照抄保留
		if (_loc3_.indexOf("") != -1) {
			return _loc3_;
		}
		if (_loc3_.indexOf("/diy/") != -1 || _loc3_.indexOf("/fish/") != -1) {
			_loc3_ = "module/ui/farm" + _loc3_;
		}
		if (_loc3_.indexOf("/Card") != -1) {
			_loc3_ = "module/ui/allcards" + _loc3_;
		}
		if (_loc3_.indexOf("/Crop") != -1) {
			_loc3_ = "module/ui/allcrops" + _loc3_;
		}
		if (_loc3_.indexOf("/Dog") != -1 || _loc3_.indexOf("/FDog") != -1) {
			_loc3_ = "module/ui/dogs" + _loc3_;
		}
		return _loc3_;
	}

	// GetCropID.as:356-373（getInsectPosition：crops.insect 的 "x1,y1,x2,y2,x3,y3|…"
	// 按虫序取位；返回的坐标仍是字符串，调用方（Byproduct.updateInsect）当数用）
	public static function getInsectPosition(param1:String, param2:Int = 1):Array<Dynamic> {
		var _loc4_:String = null;
		var _loc5_:Array<Dynamic> = null;
		var _loc3_:Dynamic = getCropByID(param1);
		if (_loc3_ == null) {
			return null;
		}
		_loc4_ = Reflect.field(_loc3_, "insect");
		if (_loc4_ == "") {
			return null;
		}
		_loc5_ = (_loc4_.split("|")[param2] : String).split(",");
		return [[_loc5_[0], _loc5_[1]], [_loc5_[2], _loc5_[3]], [_loc5_[4], _loc5_[5]]];
	}

	// GetCropID.as:559-587（specialGrow：按 m0/m4 有无素材判定特殊种子/特殊枯苗档）
	public static function specialGrow(param1:String):Int {
		if (param1 == "0") {
			return SG_PUBLIC_SEED_PUBLIC_DEAD;
		}
		var _loc2_:Dynamic = getCropByID(param1);
		if (_loc2_ == null) {
			return SG_PUBLIC_SEED_PUBLIC_DEAD;
		}
		var _loc3_:Dynamic = Reflect.field(_loc2_, "asset_id");
		if (!As3.truthy(getAssetUrl(Reflect.field(_loc3_, "m0"))) && !As3.truthy(getAssetUrl(Reflect.field(_loc3_, "m4")))) {
			return SG_PUBLIC_SEED_PUBLIC_DEAD;
		}
		if (As3.truthy(getAssetUrl(Reflect.field(_loc3_, "m0"))) && !As3.truthy(getAssetUrl(Reflect.field(_loc3_, "m4")))) {
			return SG_SPECIAL_SEED;
		}
		if (!As3.truthy(getAssetUrl(Reflect.field(_loc3_, "m0"))) && As3.truthy(getAssetUrl(Reflect.field(_loc3_, "m4")))) {
			return SG_SPECIAL_DEAD;
		}
		if (As3.truthy(getAssetUrl(Reflect.field(_loc3_, "m0"))) && As3.truthy(getAssetUrl(Reflect.field(_loc3_, "m4")))) {
			return SG_SPECIAL_SEED_SPECIAL_DEAD;
		}
		return SG_PUBLIC_SEED_PUBLIC_DEAD;
	}

	// GetCropID.as:666-701（idToDogUrl：dog_info 里按 "FDog<id>" 查狗素材 URL；
	// param2 选 s（小店立绘）/b（场景矢量）档）
	public static function idToDogUrl(param1:String, param2:Bool):String {
		var _loc5_:Dynamic = null;
		var _loc3_:String = "";
		if (theApp.model == null || param1 == "" || param1 == null) {
			return _loc3_;
		}
		var _loc4_:Array<Dynamic> = theApp.model.getData("dog_info");
		if (_loc4_ == null) {
			return _loc3_;
		}
		for (_loc5_ in (_loc4_ : Array<Dynamic>)) {
			if (As3.eqString(Reflect.field(_loc5_, "id"), param1)) {
				var _loc6_:Dynamic = Reflect.field(_loc5_, "asset_id");
				if (_loc6_ == null) {
					break;
				}
				if (param2 == true && Reflect.hasField(_loc6_, "s")) {
					_loc3_ = getAssetUrl(Reflect.field(_loc6_, "s"));
					return Utils.addPrefix(_loc3_);
				}
				if (param2 == false && Reflect.hasField(_loc6_, "b")) {
					_loc3_ = getAssetUrl(Reflect.field(_loc6_, "b"));
					return Utils.addPrefix(_loc3_);
				}
				break;
			}
		}
		return _loc3_;
	}

	// GetCropID.as:739-772（idToBoardUrl：boards 配置里查看板素材 URL）
	public static function idToBoardUrl(param1:String):String {
		var _loc4_:Dynamic = null;
		if (theApp.model == null) {
			return "";
		}
		var _loc2_:Array<Dynamic> = theApp.model.getData("boards");
		if (_loc2_ == null) {
			return "";
		}
		var _loc3_:String = "";
		for (_loc4_ in (_loc2_ : Array<Dynamic>)) {
			if (As3.eqString(Reflect.field(_loc4_, "id"), param1)) {
				var _loc5_:Dynamic = Reflect.field(_loc4_, "asset_id");
				if (_loc5_ != null && !As3.eqString(_loc5_, "")) {
					_loc3_ = getAssetUrl(_loc5_);
					break;
				}
			}
		}
		if (_loc3_ != "") {
			_loc3_ = Utils.addPrefix(_loc3_);
		}
		return _loc3_;
	}

	// GetCropID.as:589-（签名照抄；stub 返回 0）
	public static function idState(param1:Int, param2:Float, param3:Int, param4:Int, param5:Int):Int {
		return 0;
	}

	// GetCropID.as:201-（签名照抄；stub 返回 0）
	public static function timeToMature(param1:Float, param2:Int, param3:Float, param4:Int):Float {
		return 0;
	}

	// GetCropID.as:725-（签名照抄；stub 返回 ""）
	public static function cropTime(param1:String):String {
		return "";
	}
}
