package framework.net;

import common.Settings;
import common.misc.QzoneJSAPI;
import framework.net.parsers.BagDataParser;
import framework.net.parsers.CommonParser;
import framework.net.parsers.DIYDataParser;
import framework.net.parsers.DecorateItemsParser;
import framework.net.parsers.FishDataParser;
import framework.net.parsers.FishIndexParser;
import framework.net.parsers.FriendsDataParser;
import framework.net.parsers.ItemsDataParser;
import framework.net.parsers.NullParser;
import framework.net.parsers.SeedDataParser;
import framework.net.parsers.StartupDataParser;
import framework.net.parsers.WarehouseCropsParser;
import framework.net.parsers.WarehouseFishParser;
import framework.net.parsers.WarehouseSeedsParser;
import framework.net.protocol.Protocol;
import framework.net.vo.ServiceResultVO;
import interfaces.ILogicParser;
import shim.As3;

// framework.net.ServerServices —— ServerServices.as 逐句对应。
// PORT-NOTE: flash.utils.Dictionary（uint 键）→ Map<UInt, …>；
// `param1["code"] == "1"` 的 AS3 松散相等 → As3.eqString；
// `_loc3_["errorType"] || _loc3_["code"]` → As3.or。
@:final
class ServerServices {
	// ServerServices.as:15
	private static var _instance:ServerServices;

	// ServerServices.as:17-21
	private var m_parsers:Map<UInt, ILogicParser>;
	private var m_defaultParser:ILogicParser;
	private var m_cmdMap:Map<UInt, String>;

	// ServerServices.as:23-196
	public function new() {
		m_defaultParser = new CommonParser();
		m_cmdMap = new Map<UInt, String>();
		m_parsers = new Map<UInt, ILogicParser>();
		var _loc1_:Settings = Settings.getInstance();
		var _loc2_:String = _loc1_.mode;
		if (_loc2_ == "qplus") {
			_loc2_ = "qzone";
		}
		var _loc3_:String = _loc2_;
		if (_loc3_ == "qzone") {
			_loc3_ = "qzone.qq";
		} else if (_loc3_ == "") {
			_loc3_ = _loc1_.xymode;
		}
		m_cmdMap.set(CommandDefs.CMD_GET_BOOT_DATA, "" + _loc3_ + "mod=user&act=run");
		m_cmdMap.set(CommandDefs.CMD_CHECK_MILL_RIGHTS, "mod=cgi_ws_com");
		m_cmdMap.set(CommandDefs.CMD_OPERATE_WATER, "" + _loc3_ + "mod=farmlandstatus&act=water");
		m_cmdMap.set(CommandDefs.CMD_OPERATE_CLEARWEED, "" + _loc3_ + "mod=farmlandstatus&act=clearWeed");
		m_cmdMap.set(CommandDefs.CMD_OPERATE_ADDWEED, "" + _loc3_ + "mod=farmlandstatus&act=scatterSeed");
		m_cmdMap.set(CommandDefs.CMD_OPERATE_ADDBUG, "" + _loc3_ + "mod=farmlandstatus&act=pest");
		m_cmdMap.set(CommandDefs.CMD_OPERATE_CLEARBUG, "" + _loc3_ + "mod=farmlandstatus&act=spraying");
		if (QzoneJSAPI.WB == true) {
			m_cmdMap.set(CommandDefs.CMD_OPERATE_SCROUNGE_NEW, "" + _loc3_ + "mod=farmlandstatus&act=scrounge");
		} else {
			m_cmdMap.set(CommandDefs.CMD_OPERATE_SCROUNGE_NEW, "" + _loc3_ + "mod=farmlandstatus&act=scrounge");
		}
		m_cmdMap.set(CommandDefs.CMD_OPERATE_HARVEST, "" + _loc3_ + "mod=farmlandstatus&act=harvest");
		m_cmdMap.set(CommandDefs.CMD_OPERATE_SCARIFY, "" + _loc3_ + "mod=farmlandstatus&act=scarify");
		m_cmdMap.set(CommandDefs.CMD_OPERATE_PLANT, "" + _loc3_ + "mod=farmlandstatus&act=planting");
		m_cmdMap.set(CommandDefs.CMD_OPERATE_FERTILIZE, "" + _loc3_ + "mod=farmlandstatus&act=fertilize");
		m_cmdMap.set(CommandDefs.CMD_OPERATE_CHECKSTATUS, "" + _loc3_ + "mod=user&act=checkStatus");
		m_cmdMap.set(CommandDefs.CMD_GET_OUTPUT, "" + _loc3_ + "mod=farmlandstatus&act=getOutput");
		m_cmdMap.set(CommandDefs.CMD_GET_BAG_DATA, "mod=repertory&act=getUserSeed");
		m_cmdMap.set(CommandDefs.CMD_GET_SHOP_SEED, "mod=usertool&act=getSeedInfo");
		m_cmdMap.set(CommandDefs.CMD_GET_SHOP_ITEMS, "mod=usertool&act=getTools");
		m_cmdMap.set(CommandDefs.CMD_GET_SHOP_FISH, "mod=cgi_fish_list");
		m_cmdMap.set(CommandDefs.CMD_UNLOCK_SHOP_FISH, "mod=cgi_fish_unlock");
		m_cmdMap.set(CommandDefs.CMD_GET_SHOP_DIY, "mod=item&act=shop");
		m_cmdMap.set(CommandDefs.CMD_GET_WAREHOUSE_CROPS, "" + _loc3_ + "mod=cgi_farm_getusercrop");
		m_cmdMap.set(CommandDefs.CMD_GET_WAREHOUSE_CRYSTAL, "" + _loc3_ + "cgi_farm_get_usercrystal&phpye=phpye");
		m_cmdMap.set(CommandDefs.CMD_SELL_CRYSTAL, "cgi_farm_sell_crystal");
		m_cmdMap.set(CommandDefs.CMD_GET_WAREHOUSE_SEEDS, "" + _loc3_ + "mod=cgi_farm_seed_list");
		m_cmdMap.set(CommandDefs.CMD_GET_WAREHOUSE_FISH, "" + _loc3_ + "mod=cgi_fish_user_rep");
		m_cmdMap.set(CommandDefs.CMD_SELL_WAREHOUSE_FISH, "" + _loc3_ + "mod=cgi_fish_sale");
		m_cmdMap.set(CommandDefs.CMD_SELL_ALL_PLANTS, "" + _loc3_ + "mod=repertory&act=saleAll");
		m_cmdMap.set(CommandDefs.CMD_GET_DIY_ITEMS, "mod=item&act=getUserItems");
		m_cmdMap.set(CommandDefs.CMD_ACTIVE_DECORATE, "mod=item&act=activeItem");
		m_cmdMap.set(CommandDefs.CMD_DEACTIVE_DECORATE, "mod=item&act=deactiveItem");
		m_cmdMap.set(CommandDefs.CMD_SELL_PLANT, "" + _loc3_ + "mod=repertory&act=sale");
		m_cmdMap.set(CommandDefs.CMD_SELL_SEED, "" + _loc3_ + "mod=cgi_farm_seed_sell");
		m_cmdMap.set(CommandDefs.CMD_GET_DOG_FOOD_STATUS, "mod=dog&act=feedMoney");
		m_cmdMap.set(CommandDefs.CMD_RECLAIM_CONDITION, "mod=user&act=reclaimPay");
		m_cmdMap.set(CommandDefs.CMD_RECLAIM_PAY, "mod=user&act=reclaim");
		m_cmdMap.set(CommandDefs.CMD_UPGRADE_RED, "" + _loc3_ + "mod=cgi_farm_upgrade");
		m_cmdMap.set(CommandDefs.CMD_GET_FRIENDLIST, "" + _loc3_ + "mod=friend");
		m_cmdMap.set(CommandDefs.CMD_GET_FRIENDLIST_STATUS, "" + _loc3_ + "mod=cgi_farm_getstatus_filter");
		m_cmdMap.set(CommandDefs.CMD_GET_FRIEND_FILTER, "" + _loc3_ + "mod=friend&act=listFilter");
		m_cmdMap.set(CommandDefs.CMD_ADD_FRIEND_FILTER, "mod=friend&act=addFilter");
		m_cmdMap.set(CommandDefs.CMD_REMOVE_FRIEND_FILTER, "mod=friend&act=delFilter");
		m_cmdMap.set(CommandDefs.CMD_GET_SYSTEM_POST_MSG, "" + _loc2_ + "mod=user&act=getNotice");
		m_cmdMap.set(CommandDefs.CMD_GET_EVERYDAY_GIFT, "mod=Feast&act=getPackageList");
		m_cmdMap.set(CommandDefs.CMD_ACCEPT_EVERYDAY_GIFT, "mod=Feast&act=getPackage");
		m_cmdMap.set(CommandDefs.CMD_GET_PROFILE_ALL_INFO, "" + _loc3_ + "mod=chat&act=getAllInfo");
		m_cmdMap.set(CommandDefs.CMD_CLEAR_ALL_LOG, "mod=chat&act=clearLog");
		m_cmdMap.set(CommandDefs.CMD_CLEAR_ALL_CHAT, "mod=chat&act=clearChat");
		m_cmdMap.set(CommandDefs.CMD_GET_BILL_DATA, "" + _loc3_ + "mod=cgi_farm_exchange");
		m_cmdMap.set(CommandDefs.CMD_GET_BILL_WS_DATA, "mod=fcg_ws_get_costfeeds");
		m_cmdMap.set(CommandDefs.CMD_SEND_CHAT, "mod=chat&act=sendChat");
		m_cmdMap.set(CommandDefs.CMD_BUY_SEEDS, "mod=repertory&act=buySeed");
		m_cmdMap.set(CommandDefs.CMD_BUY_FISHS, "mod=cgi_fish_buy");
		m_cmdMap.set(CommandDefs.CMD_BUY_TOOLS, "mod=usertool&act=buyTool");
		m_cmdMap.set(CommandDefs.CMD_BUY_TOOLS_VIP, "mod=cgi_farm_tool_vip");
		m_cmdMap.set(CommandDefs.CMD_BUY_WEAPONS, "mod=cgi_farm_buyweapon");
		m_cmdMap.set(CommandDefs.CMD_GET_FISH_ALL, "" + _loc3_ + "mod=cgi_fish_getall");
		m_cmdMap.set(CommandDefs.CMD_WB_PROFILE, "mod=cgi_farm_get_userprofile");
		var _loc4_:String = _loc1_.mode;
		if (_loc4_ == "") {
			_loc4_ = "pengyou.qq";
		} else {
			_loc4_ = "qzone.qq";
		}
		m_cmdMap.set(CommandDefs.CMD_GAME_REQUEST_GET, "" + _loc4_ + "mod=request_get");
		m_cmdMap.set(CommandDefs.CMD_REQUEST_ZHAO, "" + _loc3_ + "mod=cgi_farm_sendrequest");
		m_cmdMap.set(CommandDefs.CMD_REQUEST_SELECT, "" + _loc3_ + "mod=cgi_farm_acceptrequest");
		m_cmdMap.set(CommandDefs.CMD_REQUEST_COUNT, "" + _loc4_ + "mod=request_get_count");
		m_cmdMap.set(CommandDefs.CMD_BUY_DIY, "mod=cgi_farm_buyitem");
		m_cmdMap.set(CommandDefs.CMD_OPEN_HEALTH, "mod=item&act=healthMode");
		m_cmdMap.set(CommandDefs.CMD_LEVEL_UP, "mod=feast&act=levelup");
		m_cmdMap.set(CommandDefs.CMD_WELCOME_END, "mod=user&act=welcome");
		m_cmdMap.set(CommandDefs.CMD_ACCEPT_TASK, "mod=task&act=accept");
		m_cmdMap.set(CommandDefs.CMD_UPDATE_TASK, "mod=task&act=update");
		m_cmdMap.set(CommandDefs.CMD_BUY_PRECHECK, "mod=cgi_farm_shop_verify");
		m_cmdMap.set(CommandDefs.CMD_BUY_INGAME_BUY, "mod=cgi_farm_shop_pay");
		m_cmdMap.set(CommandDefs.CMD_PASTURE_VEERFY, "mod=cgi_pasture_shop_verify");
		m_cmdMap.set(CommandDefs.CMD_PASTURE_PAY, "mod=cgi_pasture_shop_pay");
		m_cmdMap.set(CommandDefs.CMD_GET_WAREHOUSE_MYFLOWERS, "" + _loc3_ + "mod=cgi_farm_flower_received");
		m_cmdMap.set(CommandDefs.CMD_GET_FLOWER_WORDS, "" + _loc3_ + "mod=cgi_farm_flower_get_card");
		m_cmdMap.set(CommandDefs.CMD_ITEM_VIP, "" + _loc3_ + "mod=cgi_farm_item_vip");
		m_cmdMap.set(CommandDefs.CMD_DEL_MYFLOWER, "" + _loc3_ + "mod=cgi_farm_flower_del_msg");
		m_cmdMap.set(CommandDefs.CMD_SEND_FLOWER, "" + _loc3_ + "mod=cgi_farm_flower_send");
		m_cmdMap.set(CommandDefs.CMD_UPDATE_LOCK, "" + _loc3_ + "mod=cgi_farm_set_lock");
		m_cmdMap.set(CommandDefs.CMD_UPDATE_FISH_LOCK, "" + _loc3_ + "mod=cgi_fish_rep_lock");
		m_cmdMap.set(CommandDefs.CMD_SELL_ALL_SEEDS, "" + _loc3_ + "mod=cgi_farm_seed_sell");
		m_cmdMap.set(CommandDefs.CMD_GET_CARDSGAME_DATA, "" + _loc3_ + "mod=cgi_farm_login_home");
		m_cmdMap.set(CommandDefs.CMD_REFRESH_CARDSGAME_DATA, "" + _loc3_ + "mod=cgi_farm_login_click");
		m_cmdMap.set(CommandDefs.CMD_GET_CARDSGAME_REWARD, "" + _loc3_ + "mod=cgi_pasture_signin");
		m_cmdMap.set(CommandDefs.CMD_OPEN_MC, "" + _loc3_ + "mod=cgi_register");
		m_cmdMap.set(CommandDefs.CMD_GET_VIPRETURN_GIFT, "" + _loc3_ + "mod=cgi_return_gift");
		m_cmdMap.set(CommandDefs.CMD_NPC_ACTIVITY, "" + _loc3_ + "mod=cgi_farm_2years");
		m_cmdMap.set(CommandDefs.CMD_NPC_WEIBO, "" + _loc3_ + "mod=cgi_farm_twoyear_mblog");
		m_cmdMap.set(CommandDefs.CMD_NPC_BLOG, "" + _loc3_ + "mod=cgi_farm_twoyear_blog");
		m_cmdMap.set(CommandDefs.CMD_NPC_WEIBO_FLAG, "" + _loc3_ + "mod=cgi_farm_twoyear_flag");
		m_cmdMap.set(CommandDefs.CMD_GET_SYSTEM_MSG, "" + _loc2_ + "mod=sysmsg_select");
		m_cmdMap.set(CommandDefs.CMD_GET_FEEDS, "" + _loc2_ + "mod=hydra_feeds_select");
		m_cmdMap.set(CommandDefs.CMD_CLEAR_ALL_FEEDS, "" + _loc2_ + "mod=hydra_feeds_delete");
		m_cmdMap.set(CommandDefs.CMD_DAILYMISSION_GET_REFRESH, "" + _loc3_ + "mod=cgi_farm_mission_num");
		m_cmdMap.set(CommandDefs.CMD_DOLPHIN_FUND, "" + _loc3_ + "mod=cgi_farm_landext_fund");
		m_cmdMap.set(CommandDefs.CMD_HOUSE_KEEPER, "" + _loc3_ + "mod=cgi_farm_housekeeper");
		m_cmdMap.set(CommandDefs.CMD_SINGLE_FES, "" + _loc3_ + "mod=cgi_farm_guang_gun");
		m_cmdMap.set(CommandDefs.CMD_GET_SNS_AD, "mod=view_fcg&");
		m_cmdMap.set(CommandDefs.CMD_GET_SHOP_ADVERTISEMENT_SEED, "mod=view_fcg&");
		m_cmdMap.set(CommandDefs.CMD_SET_ADSEED_COOKIE, "http://c.gdt.qq.com/gdt_cookie.fcg");
		m_cmdMap.set(CommandDefs.CMD_GET_FISHES, "" + _loc2_ + "mod=cgi_fish_index");
		m_cmdMap.set(CommandDefs.CMD_GROW_FISH, "" + _loc2_ + "mod=cgi_fish_plant");
		m_cmdMap.set(CommandDefs.CMD_HARVEST_FISH, "" + _loc2_ + "mod=cgi_fish_harvest");
		m_cmdMap.set(CommandDefs.CMD_STEAL_FISH, "" + _loc2_ + "mod=cgi_fish_steal");
		m_cmdMap.set(CommandDefs.CMD_FISH_OUTPUT, "" + _loc2_ + "mod=cgi_fish_output");
		m_cmdMap.set(CommandDefs.CMD_WATER_OPEN, "" + _loc2_ + "mod=cgi_fish_register");
		m_cmdMap.set(CommandDefs.CMD_FEED_FISH, "" + _loc2_ + "mod=cgi_fish_fertilize");
		m_cmdMap.set(CommandDefs.WHITE_LIST, "" + _loc2_ + "mod=cgi_farm_whitelist");
		m_cmdMap.set(CommandDefs.CMD_FREE_COUNT, "" + _loc3_ + "mod=cgi_farm_request_count");
		m_cmdMap.set(CommandDefs.CMD_FREE_LIST, "" + _loc3_ + "mod=cgi_farm_request_list");
		m_cmdMap.set(CommandDefs.CMD_FREE_GIFT, "" + _loc3_ + "mod=cgi_farm_request_gift_send");
		m_cmdMap.set(CommandDefs.CMD_FREE_GIFT_RECV, "" + _loc3_ + "mod=cgi_farm_request_gift_recv");
		m_cmdMap.set(CommandDefs.CMD_UPGRADE_BLACK, "" + _loc2_ + "mod=cgi_farm_upgrade_black");
		m_cmdMap.set(CommandDefs.CMD_FEEDS_NPC_GET_FRIEND_DATA, "" + _loc2_ + "mod=cgi_farm_get_basic");
		m_cmdMap.set(CommandDefs.CMD_ALLIANCE_GRAY, "" + _loc2_ + "mod=cgi_farm_tree");
		m_cmdMap.set(CommandDefs.CMD_MONTHEND_LIST, "" + _loc2_ + "mod=cgi_farm_month_list");
		m_cmdMap.set(CommandDefs.CMD_MONTHEND_REFRESH, "" + _loc2_ + "mod=cgi_farm_month_refresh");
		m_cmdMap.set(CommandDefs.CMD_MONTHEND_GET_GIFT, "mod=cgi_farm_month_get");
		m_cmdMap.set(CommandDefs.CMD_GET_CARDSGAME_ACTIVITY, "" + _loc2_ + "mod=cgi_farm_login_draw");
		m_cmdMap.set(CommandDefs.CMD_ACTIVITY_GRAY, "mod=cgi_farm_get_bit?bit=6");
		m_cmdMap.set(CommandDefs.CMD_ALLIANCE_PRICE, "mod=price_goods");
		m_cmdMap.set(CommandDefs.CMD_UP_GOLD_LAND, "" + _loc2_ + "mod=cgi_farm_upgrade_gold");
		m_cmdMap.set(CommandDefs.REFRESH_UP_GOLD_TIME, "" + _loc2_ + "mod=cgi_farm_olympic_game");
		m_cmdMap.set(CommandDefs.AUTO_POP, "" + _loc2_ + "mod=cgi_fetch_strategy_rules");
		m_parsers.set(CommandDefs.CMD_GET_BOOT_DATA, new StartupDataParser());
		m_parsers.set(CommandDefs.CMD_OPERATE_CHECKSTATUS, new NullParser());
		m_parsers.set(CommandDefs.CMD_GET_BAG_DATA, new BagDataParser());
		m_parsers.set(CommandDefs.CMD_GET_SHOP_SEED, new SeedDataParser());
		m_parsers.set(CommandDefs.CMD_GET_SHOP_ITEMS, new ItemsDataParser());
		m_parsers.set(CommandDefs.CMD_GET_SHOP_DIY, new DIYDataParser());
		m_parsers.set(CommandDefs.CMD_GET_WAREHOUSE_CROPS, new WarehouseCropsParser());
		m_parsers.set(CommandDefs.CMD_GET_WAREHOUSE_SEEDS, new WarehouseSeedsParser());
		m_parsers.set(CommandDefs.CMD_GET_WAREHOUSE_FISH, new WarehouseFishParser());
		m_parsers.set(CommandDefs.CMD_GET_DIY_ITEMS, new DecorateItemsParser());
		m_parsers.set(CommandDefs.CMD_GET_FRIENDLIST, new FriendsDataParser());
		m_parsers.set(CommandDefs.CMD_ADD_FRIEND_FILTER, new NullParser());
		m_parsers.set(CommandDefs.CMD_REMOVE_FRIEND_FILTER, new NullParser());
		m_parsers.set(CommandDefs.CMD_WELCOME_END, new NullParser());
		m_parsers.set(CommandDefs.CMD_GET_SHOP_FISH, new FishDataParser());
		m_parsers.set(CommandDefs.CMD_GET_FISHES, new FishIndexParser());
	}

	// ServerServices.as:198-206
	public static function getInstance():ServerServices {
		if (_instance != null) {
			return _instance;
		}
		_instance = new ServerServices();
		return _instance;
	}

	// ServerServices.as:208-224。PORT-NOTE: Dictionary 整表覆写 → Map.set
	public function registerCmdMap(param1:Array<Dynamic>):Void {
		var _loc2_:Int = 0;
		var _loc4_:Dynamic = null;
		var _loc3_:Int = param1.length;
		_loc2_ = 0;
		while (_loc2_ < _loc3_) {
			_loc4_ = param1[_loc2_];
			if (_loc4_ != null) {
				m_cmdMap.set(Reflect.field(_loc4_, "id"), Reflect.field(_loc4_, "url"));
			}
			_loc2_++;
		}
	}

	// ServerServices.as:226-258
	public function decodeResult(param1:Protocol):ServiceResultVO {
		var _loc4_:ILogicParser = null;
		var _loc5_:ServiceResultVO = null;
		if (param1 == null) {
			return null;
		}
		var _loc2_:UInt = param1.cmdID;
		if (_loc2_ == 0) {
			return null;
		}
		var _loc3_:Dynamic = param1.decodeForHttp();
		if (_loc3_ == null) {
			return null;
		}
		if (checkResponseError(_loc3_) == true) {
			_loc4_ = m_parsers.get(_loc2_);
			if (_loc4_ != null) {
				return _loc4_.parse(_loc3_);
			}
			return m_defaultParser.parse(_loc3_);
		}
		_loc5_ = new ServiceResultVO();
		_loc5_.m_result = As3.or(Reflect.field(_loc3_, "errorType"), Reflect.field(_loc3_, "code"));
		_loc5_.m_message = As3.or(As3.or(Reflect.field(_loc3_, "errorContent"), Reflect.field(_loc3_, "direction")),
			Reflect.field(_loc3_, "msg"));
		_loc5_.m_extra = _loc3_;
		return _loc5_;
	}

	// ServerServices.as:260-307
	public function getRequestUrl(param1:UInt):String {
		var _loc2_:String = null;
		var _loc3_:String = m_cmdMap.get(param1);
		if (_loc3_ == null) {
			_loc3_ = "null"; // AS3 对 null 串做正则匹配（String(null)=="null"）
		}
		if (new EReg("^http.*", "").match(_loc3_)) {
			if (QzoneJSAPI.WB == true) {
				// String.replace(正则) 只换第一处（非全局），matchedPos 等价复刻
				var wb:EReg = new EReg("farm\\.qzone\\.qq\\.com|nc\\.qzone\\.qq\\.com", "i");
				if (wb.match(_loc3_)) {
					var pos = wb.matchedPos();
					_loc3_ = _loc3_.substr(0, pos.pos) + "farm.mblog.qq.com" + _loc3_.substr(pos.pos + pos.len);
				}
			}
			_loc2_ = QzoneJSAPI.addGToken(_loc3_);
			if (_loc2_ != null && _loc2_ != "") {
				return _loc2_;
			}
			return _loc3_;
		}
		var _loc4_:Settings = Settings.getInstance();
		var _loc5_:String = "";
		if (_loc4_.mode == "qzone" || _loc4_.mode == "qplus") {
			_loc5_ = "postUrl_qz";
		} else if (_loc4_.xymode == "") {
			_loc5_ = "postUrl_xy_qq";
		} else {
			_loc5_ = "postUrl_xy_pengyou";
		}
		_loc5_ = Settings.getInstance().getUrlConfigByName(_loc5_);
		if (_loc5_ == "") {
			return m_cmdMap.get(param1);
		}
		if (QzoneJSAPI.WB == true) {
			_loc5_ = "";
		}
		_loc3_ = _loc5_ + _loc3_;
		_loc2_ = QzoneJSAPI.addGToken(_loc3_);
		if (_loc2_ != null && _loc2_ != "") {
			return _loc2_;
		}
		return _loc3_;
	}

	// ServerServices.as:309-328
	public function registerCmd(param1:UInt, param2:String, param3:ILogicParser = null):Void {
		if (param1 == 0) {
			return;
		}
		if (param2 == null || param2 == "") {
			return;
		}
		if (m_cmdMap.get(param1) != null) {
			throw new openfl.errors.ArgumentError("Command already exists.");
		}
		m_cmdMap.set(param1, param2);
		if (param3 != null) {
			m_parsers.set(param1, param3);
		}
	}

	// ServerServices.as:330-344
	public function encodeRequest(param1:UInt, param2:Dynamic = null):Protocol {
		if (param1 == 0) {
			throw new openfl.errors.ArgumentError("Invalid server service command");
		}
		var _loc3_:String = m_cmdMap.get(param1);
		if (_loc3_ == null || _loc3_.length == 0) {
			throw new openfl.errors.ArgumentError("Invalid server service url");
		}
		var _loc4_:Protocol = new Protocol(param1);
		_loc4_.importRequestObject(param2);
		return _loc4_;
	}

	// ServerServices.as:346-369
	public function checkResponseError(param1:Dynamic):Bool {
		if (param1 == null) {
			return true;
		}
		if (Reflect.field(param1, "errorType") != null) {
			return false;
		}
		if (Reflect.field(param1, "code") != null) {
			// AS3 松散相等（1 == "1"）→ As3.eqString
			if (As3.eqString(Reflect.field(param1, "code"), "1")) {
				return true;
			}
			if (As3.eqString(Reflect.field(param1, "code"), "888")) {
				return true;
			}
			return false;
		}
		return true;
	}
}
