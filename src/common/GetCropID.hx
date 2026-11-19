package common;

import com.qzone.qfa.control.Application;

/**
 * common.GetCropID —— 闭包 stub（issue #7，后续模块翻译，stub 同 module/Main 先例）。
 * 原版 legacy/decompiled/main3_v_221/scripts/common/GetCropID.as（772 loc > 100，
 * issue 闭包规则）依赖 theApp.model 里的作物配置（cropstype），本片只保留被引用
 * 成员的签名与「无配置」侧的稳定返回：
 * - idState → 0（真身无作物配置时也归 0 档，FarmLand._step 用）；
 * - timeToMature → 0（真身查无作物返回 -1，GetCropID.as:204-207；两者过
 *   FarmLandModel.countNoneMatureLands 的 Math.ceil(x/3600)（:698）后都是 0）；
 * - cropTime → ""（仅 setQQBrowserAlarm 的 QQBrowser 分支用，本片不触达）。
 */
class GetCropID {
	// GetCropID.as:10
	public static var theApp:Application;

	public function new() {}

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
