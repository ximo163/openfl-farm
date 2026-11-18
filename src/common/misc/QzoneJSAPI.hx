package common.misc;

import common.CommonData;
import common.Settings;
import shim.QQOutlets;

// QzoneJSAPI.as 逐句对应。
// PORT-NOTE: ExternalInterface → shim.QQOutlets（spec/deviations.json：
// no-qzone-jsapi——独立部署没有 QZone 宿主 JS，available 恒 false，取值型调用
// 落到各自的「宿主不可用」分支，与原版在非 QZone 页面的兜底一致）。
class QzoneJSAPI {
	// QzoneJSAPI.as:10
	public static var DEFAULT_DEBUG_QQ:Float;

	// QzoneJSAPI.as:12。Settings.loadFromFlashVars:520-521 写
	public static var WB:Bool;

	// QzoneJSAPI.as:14
	public static var QPLUS:Bool;

	// QzoneJSAPI.as:16
	public static final APP_ID:Int = 372;

	// QzoneJSAPI.as:18
	private static final APP_INVITE:String = "SwfAppLib.method.inviteFriend";

	// QzoneJSAPI.as:20
	private static final GET_NICKNAME:String = "SwfAppLib.method.getNickName";

	// QzoneJSAPI.as:22
	private static final GET_SEX:String = "SwfAppLib.method.getSex";

	// QzoneJSAPI.as:24
	private static final GET_VIP_INFO:String = "SwfAppLib.method.getVipInfo";

	// QzoneJSAPI.as:26
	private static final SET_COOKIES_METHOD:String = "SwfAppLib.method.setCookie";

	// QzoneJSAPI.as:28
	private static final GET_COOKIES_METHOD:String = "SwfAppLib.method.getCookie";

	// QzoneJSAPI.as:30
	private static final SHOW_LOGIN_BOX:String = "SwfAppLib.method.showLoginBox";

	// QzoneJSAPI.as:32
	private static final SELECT_FRIENDS:String = "SwfAppLib.method.selectFriend";

	// QzoneJSAPI.as:34
	private static final GET_HEAD:String = "SwfAppLib.method.getHead";

	// QzoneJSAPI.as:36
	private static final GET_HEADLIST:String = "SwfAppLib.method.getHeadList";

	// QzoneJSAPI.as:38
	private static final GET_UPURL:String = "SwfAppLib.method.getUploadUrl";

	// QzoneJSAPI.as:40
	private static final IS_APP_INSTALL:String = "SwfAppLib.method.isAppInstalled";

	// QzoneJSAPI.as:42
	private static final QQ_PLATFORM_PAY:String = "SwfAppLib.pay.showBuy";

	// QzoneJSAPI.as:44
	private static final ADD_GTK:String = "SwfAppLib.method.attachDefParam";

	// QzoneJSAPI.as:46
	private static final SEND_REQUEST:String = "fusion2.api.sendRequest";

	// QzoneJSAPI.as:48
	private static final TO_APP:String = "C.util.toApp";

	// QzoneJSAPI.as:50
	private static final GET_APP_PARAMS:String = "C.util.getAppParams";

	// QzoneJSAPI.as:52
	private static final SHOW_VIP_PACKAGE:String = "C.canvas.showYellowPackage";

	// QzoneJSAPI.as:54
	private static final REPORT_PROBLEM:String = "Clinic.log.report";

	public function new() {
	}

	// QzoneJSAPI.as:61-68
	public static function isAppInstall(param1:Int, param2:Dynamic):Void {
		if (QQOutlets.available) {
			CommonData.addCallBackProxy("setAppInstalled", param2);
			QQOutlets.call(IS_APP_INSTALL, param1);
		}
	}

	// QzoneJSAPI.as:70-76
	public static function sendGameRequest(param1:Float, param2:String, param3:String, param4:Dynamic, param5:Dynamic,
			param6:String = "", param7:String = "喊你回来种菜"):Void {
		if (QQOutlets.available) {
			QQOutlets.call("fusion2.api.sendRequest({appid:353,type:\'request\',stat:\'action_id\',receiver:"
				+ [Std.string(param1)] + ",title:\'" + param6 + "\',desc:\'免费礼物\',msg:\'" + param7
				+ "\',img:\'" + param2 + "\',button:\'" + param3
				+ "\',callback:\'http://app353.qzoneapp.com/receive_request?id=353\',context:\'1315885819:3375731104e6ed2fb9d23e\'})");
		}
	}

	// QzoneJSAPI.as:78-85
	public static function getHeadList(param1:Array<Dynamic>, param2:Int, param3:Dynamic):Void {
		if (QQOutlets.available) {
			CommonData.addCallBackProxy("setHeadList", param3);
			QQOutlets.call(GET_HEADLIST, param1, param2);
		}
	}

	// QzoneJSAPI.as:87-96
	public static function getUpUrl(param1:Dynamic):Dynamic {
		if (QQOutlets.available) {
			CommonData.addCallBackProxy("setUploadUrl", param1);
			return QQOutlets.call(GET_UPURL);
		}
		return null;
	}

	// QzoneJSAPI.as:98-104
	public static function inviteFriend():Void {
		if (QQOutlets.available) {
			QQOutlets.call(APP_INVITE, APP_ID, 520, 520, "邀请好友开通QQ餐厅");
		}
	}

	// QzoneJSAPI.as:106-115
	public static function toApp(param1:Int, param2:String):Void {
		if (QQOutlets.available) {
			// 原版 /\\/g 全局替换为 "\\\\"，等价于 StringTools 全局替换
			param2 = StringTools.replace(param2, "\\", "\\\\");
			QQOutlets.call(TO_APP, param1, param2);
		}
	}

	// QzoneJSAPI.as:117-123
	public static function flashInit():Void {
		if (QQOutlets.available) {
			QQOutlets.call("SwfAppLib.method.flashInit");
		}
	}

	// QzoneJSAPI.as:125-132
	public static function getVipInfo(param1:Bool, param2:Int, param3:Bool, param4:Dynamic):Void {
		if (QQOutlets.available) {
			CommonData.addCallBackProxy("setYellowInfo", param4);
			QQOutlets.call(GET_VIP_INFO, param1, param2, param3);
		}
	}

	// QzoneJSAPI.as:134-149
	public static function getOnlineTime(param1:String):Int {
		var _loc2_:Int = 0;
		if (QQOutlets.available == true) {
			if (param1 == "qzone") {
				_loc2_ = QQOutlets.call("QZONE.FP.getAppDuration");
			} else {
				_loc2_ = QQOutlets.call("parent.XY_APP.getAppDuration");
			}
		}
		return _loc2_;
	}

	// QzoneJSAPI.as:151-158
	public static function selectFriend(param1:Dynamic):Void {
		if (QQOutlets.available) {
			CommonData.addCallBackProxy("friendSelected", param1);
			QQOutlets.call(SELECT_FRIENDS);
		}
	}

	// QzoneJSAPI.as:160-172
	public static function reportError(param1:String, param2:Float):Void {
		if (QPLUS == true || WB == true) {
			return;
		}
		var _loc3_:String = "";
		_loc3_ += param1;
		if (QQOutlets.available) {
			QQOutlets.call(REPORT_PROBLEM, param2, _loc3_);
		}
	}

	// QzoneJSAPI.as:174-180
	public static function showLoginBox():Void {
		if (QQOutlets.available) {
			QQOutlets.call(SHOW_LOGIN_BOX);
		}
	}

	// QzoneJSAPI.as:182-195
	public static function getInGamePay(param1:String, param2:Dynamic):Void {
		var _loc3_:Bool = false;
		if (QPLUS == true) {
			return;
		}
		if (QQOutlets.available) {
			CommonData.addCallBackProxy("setBoughtRes", param2);
			_loc3_ = Settings.getInstance().getStringAttribute("sandbox") == "1";
			QQOutlets.call(QQ_PLATFORM_PAY, param1, _loc3_);
		}
	}

	// QzoneJSAPI.as:197-203
	public static function showVIPPackage(param1:Int, param2:Bool, param3:String, param4:Int, param5:Int):Void {
		if (QQOutlets.available) {
			QQOutlets.call(SHOW_VIP_PACKAGE, param1, param2, param3, param4, param5);
		}
	}

	// QzoneJSAPI.as:205-212
	public static function getAppParams():String {
		if (QQOutlets.available) {
			return QQOutlets.call(GET_APP_PARAMS);
		}
		return "";
	}

	// QzoneJSAPI.as:214-221。QQOutlets.available 恒 false → 原样返回传入 URL，
	// FarmLite.startCGIUrl 因此仍拼出可用的 mync.php 地址
	public static function addGToken(param1:String):String {
		if (QQOutlets.available) {
			return QQOutlets.call(ADD_GTK, param1);
		}
		return param1;
	}

	// QzoneJSAPI.as:223-232
	public static function sendRequestOpen(param1:String, param2:String, param3:Dynamic, param4:Dynamic,
			param5:Dynamic, param6:String = "", param7:String = "喊你回来种菜"):Void {
		CommonData.addCallBackProxy("onSuccess", param3);
		CommonData.addCallBackProxy("onCancel", param4);
		CommonData.addCallBackProxy("onClose", param5);
		if (QQOutlets.available) {
			QQOutlets.call("fusion2.dialog.sendRequest({appid:353,type:\'freegift\',stat:\'action_id\',title:\'"
				+ param6 + "\',desc:\'免费礼物\',msg:\'" + param7 + "\',img:\'" + param1 + "\',button:\'" + param2
				+ "\',context:\'1315885819:86933d85682a0bbc318616d90fa641bb\',"
				+ "callback:\'http://app24341.qzoneapp.com/receive_gift?id=12345\',"
				+ "onSuccess:function (opt){swfAppObject.onSuccess(opt);},"
				+ "onCancel:function (opt){swfAppObject.onCancel(opt);},"
				+ "onClose:function (opt){swfAppObject.onClose(opt);}})");
		}
	}

	// QzoneJSAPI.as:234-241
	public static function getHead(param1:String, param2:Int):String {
		if (QQOutlets.available) {
			return QQOutlets.call(GET_HEAD, param1, param2);
		}
		return "";
	}

	// QzoneJSAPI.as:243-253
	public static function share(param1:String, param2:String, param3:String, param4:String = "",
			param5:String = "进入应用", param6:String = ""):Void {
		QQOutlets.call("fusion2.dialog.sendStory", {
			"title": param1,
			"summary": param2,
			"img": param3,
			"msg": param4,
			"button": param5,
			"source": param6
		});
	}

	// QzoneJSAPI.as:255-262
	public static function getNickname():String {
		if (QQOutlets.available) {
			return QQOutlets.call(GET_NICKNAME);
		}
		return "";
	}

	// QzoneJSAPI.as:264-271
	public static function getCookie(param1:String):String {
		if (QQOutlets.available) {
			return QQOutlets.call(GET_COOKIES_METHOD, param1);
		}
		return "";
	}

	// QzoneJSAPI.as:273-279
	public static function setCookie(param1:String, param2:String, param3:String, param4:String, param5:Int):Void {
		if (QQOutlets.available) {
			QQOutlets.call(SET_COOKIES_METHOD, param1, param2);
		}
	}

	// QzoneJSAPI.as:281-291
	public static function openWindow(param1:String):Void {
		if (param1 == "" || param1 == null) {
			return;
		}
		if (QQOutlets.available) {
			QQOutlets.call("window.open", param1);
		}
	}

	// QzoneJSAPI.as:293-299
	public static function sendRequestOne(param1:Float, param2:String, param3:String, param4:Dynamic, param5:Dynamic,
			param6:String = "", param7:String = "喊你回来种菜", param8:String = "常来看看，别错过收礼唷！"):Void {
		if (QQOutlets.available) {
			QQOutlets.call("fusion2.api.sendRequest({appid:353,type:\'freegift\',stat:\'action_id\',receiver:"
				+ [Std.string(param1)] + ",title:\'" + param6 + "\',desc:\'" + param8 + "\',msg:\'" + param7
				+ "\',img:\'" + param2 + "\',button:\'" + param3
				+ "\',callback:\'http://app353.qzoneapp.com/receive_request?id=353\',"
				+ "context:\'1315885819:3375731104e6ed2fb9d23e\'})");
		}
	}
}
