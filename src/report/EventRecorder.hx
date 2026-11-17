package report;

import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.Lib.getTimer;
import shim.As3;
import shim.QQOutlets;

// EventRecorder.as 逐句对应。
// PORT-NOTE: 上报出口 → shim.QQOutlets.sendToURL / call（spec/deviations.json：
// no-qq-telemetry——独立部署不做 QQ 相关上报，出口不发；DISABLED 同时置 true，
// record* 在入口即返回）。DISABLED 原版默认 false，这是有登记的偏差。
class EventRecorder {
	// EventRecorder.as:13
	public static var recordUrl:String = "nmc.php?";

	// EventRecorder.as:15
	public static var successRecordProbability:Int = 500;

	// EventRecorder.as:17
	public static var errorRecordProbability:Int = 1;

	// EventRecorder.as:19-33（原版 var，非 const）
	public static var MC_ENTER:String = "19112";

	public static var MC_GET_EXP:String = "19113";

	public static var MC_REPERTORY_ANIMAl:String = "19114";

	public static var MC_REPERTORY_PCAKAGE:String = "19116";

	public static var MC_ANIMAL:String = "19115";

	public static var MC_STEAL_PRODUCT:String = "19117";

	public static var MC_POST_PRODUCT:String = "19118";

	public static var MC_HARVEST_PRODUCT:String = "19119";

	// EventRecorder.as:35-147
	public static final HF_SCROUNGE:String = "160190";

	public static final HF_HARVEST:String = "160191";

	public static final HF_CLEARWEED:String = "160015";

	public static final HF_SPRAYING:String = "160016";

	public static final HF_SHOP:String = "160017";

	public static final HF_LIB:String = "160018";

	public static final HF_DIY:String = "160019";

	public static final HF_PEST:String = "160020";

	public static final HF_SCATTERSEED:String = "160021";

	public static final HF_WATER:String = "160022";

	public static final HF_SCARIFY:String = "160023";

	public static final HF_PLANTING:String = "160024";

	public static final HF_FERTILIZE:String = "160025";

	public static final HF_SNOW:String = "160026";

	public static final HF_POSTCLICK:String = "160027";

	public static final HF_POSTVIEW:String = "160028";

	public static final HF_SWFLOAD:String = "160187";

	public static final HF_ONLINETIME:String = "160090";

	public static final HF_ENTERMUCHANG:String = "160091";

	public static final HF_CGI_ENTER:String = "160200";

	public static final HF_GET_BAG_DATA:String = "160201";

	public static final HF_GET_SHOP_SEED:String = "160202";

	public static final HF_GET_SHOP_DIY:String = "160203";

	public static final HF_GET_SHOP_ITEM:String = "160204";

	public static final HF_GET_SNS_AD:String = "160205";

	public static final HF_GET_WAREHOUSE_CROPS:String = "160206";

	public static final HF_GET_WAREHOUSE_SEEDS:String = "160207";

	public static final HF_GET_WAREHOUSE_CRYSTAL:String = "160208";

	public static final HF_SELL_ALL_PLANTS:String = "160209";

	public static final HF_SELL_PLANT:String = "160210";

	public static final HF_GET_DIY_ITEMS:String = "160211";

	public static final HF_GET_FRIENDLIST:String = "160212";

	public static final HF_GET_FRIENDLIST_STATUS:String = "160213";

	public static final HF_GET_SYSTEM_MSG:String = "160214";

	public static final HF_GET_FEEDS:String = "160215";

	public static final HF_GET_BILL_DATA:String = "160216";

	public static final HF_BUY_SEEDS:String = "160217";

	public static final HF_BUY_DIY:String = "160218";

	public static final CHEAT_FARM:String = "160224";

	public static final HF_ZOOMIN:String = "160245";

	public static final HF_ZOOMOUT:String = "160246";

	public static final HF_PHOTO_BIG:String = "160364";

	public static final HF_PHOTO_SMALL:String = "160365";

	public static final HF_THANKS_GG:String = "160456";

	public static final HF_THANKS_BD:String = "160457";

	public static final HF_THANKS_SF:String = "160458";

	public static final HF_THANKS_DJ:String = "160459";

	public static final HF_THANKS_ZS:String = "160460";

	public static final HF_THANKS_CX:String = "160461";

	public static final MONTHEND_CLICKBUY:String = "160499";

	public static final MONTHEND_BUYSUCCESS:String = "160500";

	public static final MONTHEND_GETGIFT:String = "160501";

	public static final MONTHEND_REFRESHTYPE:String = "160502";

	public static final MONTHEND_REFRESHNUMBER:String = "160503";

	public static final QDSEED_BUYCLICK:String = "160587";

	public static final QDSEED_BUYSUCCESS:String = "160588";

	public static final PGVID_TOSUPERMARKET:String = "ISD.SNSAPP.HAPPYFARM.TOSUPERMARKET";

	// EventRecorder.as:149-159
	public static final SUEECSS:Int = 1;

	public static final FAULT_ERROR:Int = 4;

	public static final FAULT_SESSION:Int = 5;

	public static final DATA_ERROR:Int = 1;

	public static final TIME_OUT:Int = 3;

	public static final DOMAIN_ERROR:Int = 2;

	// EventRecorder.as:161
	public static var STARTUP_SPEED_INFO:Dynamic = null;

	// EventRecorder.as:163。原版默认 false；no-qq-telemetry 偏差置 true
	public static var DISABLED:Bool = true;

	// EventRecorder.as:165
	private static var _list:Array<Dynamic> = [];

	// EventRecorder.as:167
	private static var _startTime:Dynamic = {};

	public function new() {
	}

	// EventRecorder.as:174-181。URLVariables 是 abstract(Dynamic)，动态下标写
	// 落 Reflect.setField
	public static function initStartupSpeed():Void {
		var _loc1_:URLVariables = new URLVariables();
		Reflect.setField(_loc1_, "flag1", 7721);
		Reflect.setField(_loc1_, "flag2", 1);
		Reflect.setField(_loc1_, "flag3", 1);
		STARTUP_SPEED_INFO = _loc1_;
	}

	// EventRecorder.as:183-197。原版不检查 DISABLED（恒发）；出口已是 no-op，
	// 翻译保持原形态
	public static function pgvSendClick(param1:String):Void {
		var _loc3_:String = QQOutlets.call("function getPvid(){var t;t = document.cookie.match((new RegExp(\";?pgv_pvid=([^;]*)\")));if(t && t.length && t.length > 1){return unescape(t[1])}else{return 0};}");
		var _loc2_:String = "";
		_loc2_ += "dm=appbase.qzone.qq.com.hot";
		_loc2_ += "&url=/qz/353/normal";
		_loc2_ += "&tt=-";
		_loc2_ += "&hottag=" + param1;
		_loc2_ += "&hotx=9999";
		_loc2_ += "&hoty=9999";
		_loc2_ += "&rand=" + Math.random().toString();
		_loc2_ += "&pvid=" + _loc3_;
		QQOutlets.sendToURL(new URLRequest(_loc2_));
	}

	// EventRecorder.as:199-209
	public static function record(param1:URLVariables):Void {
		if (DISABLED) {
			return;
		}
		var _loc2_:URLRequest = new URLRequest(recordUrl);
		_loc2_.data = param1;
		_loc2_.method = URLRequestMethod.GET;
		QQOutlets.sendToURL(_loc2_);
	}

	// EventRecorder.as:211-214
	public static function startARequest(param1:String):Void {
		Reflect.setField(_startTime, param1, getTimer());
	}

	// EventRecorder.as:216-236
	public static function recordSueecssEvent(param1:String, param2:Dynamic, param3:String = null):Void {
		var _loc4_:URLVariables = null;
		if (DISABLED) {
			return;
		}
		if (Std.int(Math.random() * successRecordProbability) == 0) {
			_loc4_ = new URLVariables();
			Reflect.setField(_loc4_, "flag1", param1);
			Reflect.setField(_loc4_, "flag2", 1);
			Reflect.setField(_loc4_, "1", successRecordProbability);
			Reflect.setField(_loc4_, "2", As3.or(param2, getTimer() - Reflect.field(_startTime, param1)));
			if (As3.truthy(param3)) {
				Reflect.setField(_loc4_, "flag5", param3);
			}
			record(_loc4_);
		}
	}

	// EventRecorder.as:238-259
	public static function recordErrorEvent(param1:String, param2:Dynamic, param3:Int, param4:String = null):Void {
		var _loc5_:URLVariables = null;
		if (DISABLED) {
			return;
		}
		if (Std.int(Math.random() * errorRecordProbability) == 0) {
			_loc5_ = new URLVariables();
			Reflect.setField(_loc5_, "flag1", param1);
			Reflect.setField(_loc5_, "flag2", 2);
			Reflect.setField(_loc5_, "flag3", param3);
			Reflect.setField(_loc5_, "1", errorRecordProbability);
			Reflect.setField(_loc5_, "2", As3.or(param2, getTimer() - Reflect.field(_startTime, param1)));
			if (As3.truthy(param4)) {
				Reflect.setField(_loc5_, "flag5", param4);
			}
			record(_loc5_);
		}
	}

	// EventRecorder.as:261-277
	public static function recordMultiValueInCode(param1:String, param2:String):Void {
		var _loc3_:URLVariables = null;
		if (DISABLED) {
			return;
		}
		if (Std.int(Math.random() * successRecordProbability) == 0) {
			_loc3_ = new URLVariables();
			Reflect.setField(_loc3_, "flag1", param1);
			Reflect.setField(_loc3_, "flag2", 1);
			Reflect.setField(_loc3_, "flag3", param2);
			Reflect.setField(_loc3_, "1", successRecordProbability);
			record(_loc3_);
		}
	}
}
