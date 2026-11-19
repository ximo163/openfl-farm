package common;

import com.qzone.qfa.control.Application;
import common.misc.Utils;
import entities.StartupData;
import shim.As3;

/**
 * common.GetCropID —— 闭包成员补齐（issue #8，V3b 场景渲染片）。
 * 原版 legacy/decompiled/main3_v_221/scripts/common/GetCropID.as（772 loc > 100，
 * issue 闭包规则整类不翻）；本片用到的成员按行号逐句照抄：
 * - SG_*（:12-18）、idToDiyUrl2（:81-107）、getCropUrl（:142-178）、
 *   timeToMature（:201-228）、getCropByID（:267-287）、getAssetUrl（:299-341）、
 *   getInsectPosition（:356-373）、specialGrow（:559-587）、idState（:589-664）、
 *   idToDogUrl（:666-701）、idToBoardUrl（:739-772）。
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
		// PORT-NOTE: 原版只判 `theApp.model == null`，theApp 未设置时 AS3 直接
		// NPE（TypeError #1009）。真机不可达：Main 启动（Main.hx:246 / 原版
		// Main.as 同位置）先于任何 FarmLand 导入设置 theApp。这里补判
		// `theApp == null`：eval 单测进程不跑 Main 启动链，已通过的
		// FarmLandTest/FarmLandModelTest/StartupDataParserTest 在无 app 实例下
		// 构造 FarmLand，其类头明确的期望就是「无 app 数据 → null → idState 0 /
		// timeToMature -1」。行为差异仅在原版会崩的缺 app 状态，生产等价；
		// deviations 候选（待人登记，见 PR 说明）
		if (theApp == null || theApp.model == null) {
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

	// GetCropID.as:589-664（idState：cropGrow 档位表按已生长秒数从高往低
	// 首个命中档 +1；param4==2（红土地）的非红作物档位 *0.8 提速、末两档再
	// 削去 %600 余数；param5>0（收获过）时低于 3 的显示档抬到 3）
	public static function idState(param1:Int, param2:Float, param3:Int, param4:Int, param5:Int):Int {
		var _loc8_:Array<Dynamic> = null;
		var _loc15_:Int = 0;
		var _loc16_:Int = 0;
		if (param1 == 0) {
			return 0;
		}
		if (param3 == 7) {
			return 7;
		}
		var _loc6_:Dynamic = getCropByID(Std.string(param1));
		if (_loc6_ == null) {
			return 0;
		}
		var _loc7_:String = Reflect.field(_loc6_, "cropGrow");
		if (_loc7_ == "") {
			return 0;
		}
		_loc8_ = _loc7_.split(",");
		var _loc9_:Float;
		// AS3 `if(CommonData.serverTime)`：Number 真值判定（0 为假）。getter
		// 恒回 0 或已设值 + 整秒漂移（无 NaN），!= 0 即同语义
		if (CommonData.serverTime != 0) {
			_loc9_ = CommonData.serverTime;
		} else {
			_loc9_ = StartupData.serverTime;
		}
		var _loc10_:Float = _loc9_;
		var _loc11_:Float = _loc10_ - param2;
		var _loc12_:Int = _loc8_.length;
		var _loc13_:Int = 0;
		var _loc14_:Int = _loc12_ - 1;
		while (_loc14_ >= 0) {
			if (param4 != 2) {
				_loc13_ = As3.intOf(_loc8_[_loc14_]);
			} else if (As3.eqString(Reflect.field(_loc6_, "isRed"), "2")) {
				// AS3 `== "2"` 松等：isRed 数值/字符串双形态（nc_data.php
				// "isRed": 2 与 "isRed": "2" 并存），As3.eqString（lessons #8）
				_loc13_ = As3.intOf(_loc8_[_loc14_]);
			} else if (_loc14_ < _loc12_ - 2) {
				// AS3 `Math.floor(x * 0.8) as int`：字符串元素先经 Number 参与
				// 乘法，As3.floatOf 显式复刻该隐式转换
				_loc13_ = Std.int(Math.floor(As3.floatOf(_loc8_[_loc14_]) * 0.8));
			} else {
				_loc13_ = Std.int(Math.floor(As3.floatOf(_loc8_[_loc14_]) * 0.8));
				_loc15_ = _loc13_ % 600;
				if (_loc13_ > _loc15_) {
					_loc13_ -= _loc15_;
				}
			}
			if (_loc11_ >= _loc13_) {
				_loc16_ = _loc14_ + 1;
				if (param5 > 0) {
					if (_loc16_ < 3) {
						return 3;
					}
				}
				return _loc16_;
			}
			_loc14_--;
		}
		return 0;
	}

	// GetCropID.as:201-228（timeToMature：距成熟剩余秒数，成熟线取倒数第二档
	// 位值；param4==2 的非红作物成熟线 *0.8 再减原值 %600；已熟/查无作物回 -1）
	public static function timeToMature(param1:Float, param2:Int, param3:Float, param4:Int):Float {
		var _loc8_:Array<Dynamic> = null;
		var _loc5_:Dynamic = getCropByID(Std.string(param2));
		if (_loc5_ == null) {
			return -1;
		}
		// AS3 `== 2` 数值松等（isRed 双形态，见上）→ As3.floatOf 数值比较
		var _loc6_:Bool = As3.floatOf(Reflect.field(_loc5_, "isRed")) == 2 ? true : false;
		var _loc7_:String = Reflect.field(_loc5_, "cropGrow");
		if (_loc7_ == "") {
			return -1;
		}
		_loc8_ = _loc7_.split(",");
		var _loc9_:UInt = _loc8_.length;
		var _loc10_:Float = As3.floatOf(_loc8_[_loc9_ - 2]);
		if (param4 == 2 && _loc6_ == false) {
			_loc10_ = _loc10_ * 0.8 - _loc10_ % 600;
		}
		var _loc11_:Float = _loc10_ - (param1 - param3);
		if (_loc11_ < 0) {
			return -1;
		}
		return _loc11_;
	}

	// GetCropID.as:725-（签名照抄；stub 返回 ""）
	public static function cropTime(param1:String):String {
		return "";
	}
}
