package report;

import common.misc.QzoneJSAPI;
import shim.As3;
import shim.QQOutlets;

// report.ClickReportManager —— ClickReportManager.as 逐句对应（83 loc ≤ 100，
// 闭包规则整类翻译）。ExternalInterface.available/call 按 deviations 的
// no-qq-telemetry 指到 shim.QQOutlets（available=false，上报分支自然不发送，
// 与原版在无宿主页面里的行为一致）。
class ClickReportManager {
	// ClickReportManager.as:9-17
	private static final CT_DOMAIN:String = "happyfarm.qzone.qq.com";
	private static final CT_PAGE_URL:String = "/app/happyfarm";
	private static final CLICK_REPORT_DOMAIN:String = "";
	private static final PV_REPORT_DOMAIN:String = "";

	// ClickReportManager.as:19
	private static var PV_REPORTED:Bool = false;

	public function new() {
		super();
	}

	// ClickReportManager.as:26-64。`_loc4_ ||= {}`：null 时建空对象；
	// `CT_DOMAIN || "-"` 恒取非空的 CT_DOMAIN，照抄成条件式保持形状
	public static function reportPv(param1:Int = 20):Void {
		var _loc2_:String = null;
		var _loc3_:String = null;
		var _loc4_:Dynamic = null;
		var _loc5_:Array<Dynamic> = null;
		var _loc6_:String = null;
		var _loc7_:String = null;
		var _loc8_:String = null;
		var _loc9_:Array<Dynamic> = null;
		var _loc10_:String = null;
		if (!PV_REPORTED && checkRan(param1)) {
			_loc2_ = CT_DOMAIN == "" ? "-" : CT_DOMAIN;
			_loc3_ = CT_PAGE_URL;
			if (_loc4_ == null) {
				_loc4_ = {};
			}
			Reflect.setField(_loc4_, "referURL", "http://ct0.xiaoyou.qq.com");
			// split(/[\?\#]/)——Haxe 的 String.split 接受 EReg
			_loc5_ = String(Reflect.field(_loc4_, "referURL")).split(~/[?#]/);
			_loc6_ = _loc5_[0];
			_loc5_ = _loc6_.split("/");
			_loc7_ = _loc5_.length >= 2 ? _loc5_[2] : "-";
			_loc8_ = "/" + _loc5_.slice(3).join("/");
			if (!As3.truthy(Reflect.field(_loc4_, "referDomain"))) {
				Reflect.setField(_loc4_, "referDomain", _loc7_);
			}
			if (!As3.truthy(Reflect.field(_loc4_, "referPath"))) {
				Reflect.setField(_loc4_, "referPath", _loc8_);
			}
			_loc7_ = QzoneJSAPI.getCookie("pgv_pvid");
			if (!As3.truthy(_loc7_)) {
				_loc7_ = Std.string(Math.round(Math.random() * 2147483647) * new Date().getUTCMilliseconds() % 10000000000);
				QzoneJSAPI.setCookie("pgv_pvid", _loc7_, "qq.com", "/", 10000);
			}
			_loc9_ = [PV_REPORT_DOMAIN, "?cc=-&ct=-&java=1&lang=-&pf=-&scl=-&scr=-&tt=-&tz=-8&vs=3.3&", "dm=", _loc2_, "&", "url=", _loc3_, "&", "rdm=",
				Reflect.field(_loc4_, "referDomain"), "&", "rurl=", Reflect.field(_loc4_, "referPath"), "&", "pgv_pvid=", _loc7_, "&", "sds=", Math.random()];
			_loc10_ = _loc9_.join("");
			if (QQOutlets.available) {
				QQOutlets.call("eval", "(function(){window._flash_img = new Image();window._flash_img.src=\"" + _loc10_ + "\"})()");
			}
			PV_REPORTED = true;
		}
	}

	// ClickReportManager.as:66-79
	public static function reportClick(param1:String, param2:Int = 20):Void {
		var _loc3_:String = null;
		if (checkRan(param2)) {
			_loc3_ = CLICK_REPORT_DOMAIN + "?dm=" + CT_DOMAIN + ".hot" + "&url=" + CT_PAGE_URL + "&tt=-" + "&hottag=" + param1 + "&hotx=9999" + "&hoty=9999"
				+ "&rand=" + Std.string(Math.random());
			if (QQOutlets.available) {
				QQOutlets.call("eval", "(function(){window._flash_img = new Image();window._flash_img.src=\"" + _loc3_ + "\"})()");
			}
		}
	}

	// ClickReportManager.as:81-84
	private static function checkRan(param1:Int = 20):Bool {
		return Std.int(Math.random() * param1) == 0;
	}
}
