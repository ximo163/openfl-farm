package framework.net
{
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import flash.utils.Dictionary;
   import framework.net.parsers.*;
   import framework.net.protocol.Protocol;
   import framework.net.vo.ServiceResultVO;
   import interfaces.ILogicParser;
   
   public final class ServerServices
   {
      
      private static var _instance:ServerServices;
      
      private var m_parsers:Dictionary;
      
      private var m_defaultParser:ILogicParser;
      
      private var m_cmdMap:Dictionary;
      
      public function ServerServices()
      {
         super();
         this.m_defaultParser = new CommonParser();
         this.m_cmdMap = new Dictionary();
         this.m_parsers = new Dictionary();
         var _loc1_:Settings = Settings.getInstance();
         var _loc2_:String = _loc1_.mode;
         if(_loc2_ == "qplus")
         {
            _loc2_ = "qzone";
         }
         var _loc3_:String = _loc2_;
         if(_loc3_ == "qzone")
         {
            _loc3_ = "qzone.qq";
         }
         else if(_loc3_ == "")
         {
            _loc3_ = _loc1_.xymode;
         }
         this.m_cmdMap[CommandDefs.CMD_GET_BOOT_DATA] = "" + _loc3_ + "mod=user&act=run";
         this.m_cmdMap[CommandDefs.CMD_CHECK_MILL_RIGHTS] = "mod=cgi_ws_com";
         this.m_cmdMap[CommandDefs.CMD_OPERATE_WATER] = "" + _loc3_ + "mod=farmlandstatus&act=water";
         this.m_cmdMap[CommandDefs.CMD_OPERATE_CLEARWEED] = "" + _loc3_ + "mod=farmlandstatus&act=clearWeed";
         this.m_cmdMap[CommandDefs.CMD_OPERATE_ADDWEED] = "" + _loc3_ + "mod=farmlandstatus&act=scatterSeed";
         this.m_cmdMap[CommandDefs.CMD_OPERATE_ADDBUG] = "" + _loc3_ + "mod=farmlandstatus&act=pest";
         this.m_cmdMap[CommandDefs.CMD_OPERATE_CLEARBUG] = "" + _loc3_ + "mod=farmlandstatus&act=spraying";
         if(QzoneJSAPI.WB == true)
         {
            this.m_cmdMap[CommandDefs.CMD_OPERATE_SCROUNGE_NEW] = "" + _loc3_ + "mod=farmlandstatus&act=scrounge";
         }
         else
         {
            this.m_cmdMap[CommandDefs.CMD_OPERATE_SCROUNGE_NEW] = "" + _loc3_ + "mod=farmlandstatus&act=scrounge";
         }
         this.m_cmdMap[CommandDefs.CMD_OPERATE_HARVEST] = "" + _loc3_ + "mod=farmlandstatus&act=harvest";
         this.m_cmdMap[CommandDefs.CMD_OPERATE_SCARIFY] = "" + _loc3_ + "mod=farmlandstatus&act=scarify";
         this.m_cmdMap[CommandDefs.CMD_OPERATE_PLANT] = "" + _loc3_ + "mod=farmlandstatus&act=planting";
         this.m_cmdMap[CommandDefs.CMD_OPERATE_FERTILIZE] = "" + _loc3_ + "mod=farmlandstatus&act=fertilize";
         this.m_cmdMap[CommandDefs.CMD_OPERATE_CHECKSTATUS] = "" + _loc3_ + "mod=user&act=checkStatus";
         this.m_cmdMap[CommandDefs.CMD_GET_OUTPUT] = "" + _loc3_ + "mod=farmlandstatus&act=getOutput";
         this.m_cmdMap[CommandDefs.CMD_GET_BAG_DATA] = "mod=repertory&act=getUserSeed";
         this.m_cmdMap[CommandDefs.CMD_GET_SHOP_SEED] = "mod=usertool&act=getSeedInfo";
         this.m_cmdMap[CommandDefs.CMD_GET_SHOP_ITEMS] = "mod=usertool&act=getTools";
         this.m_cmdMap[CommandDefs.CMD_GET_SHOP_FISH] = "mod=cgi_fish_list";
         this.m_cmdMap[CommandDefs.CMD_UNLOCK_SHOP_FISH] = "mod=cgi_fish_unlock";
         this.m_cmdMap[CommandDefs.CMD_GET_SHOP_DIY] = "mod=item&act=shop";
         this.m_cmdMap[CommandDefs.CMD_GET_WAREHOUSE_CROPS] = "" + _loc3_ + "mod=cgi_farm_getusercrop";
         this.m_cmdMap[CommandDefs.CMD_GET_WAREHOUSE_CRYSTAL] = "" + _loc3_ + "cgi_farm_get_usercrystal&phpye=phpye";
         this.m_cmdMap[CommandDefs.CMD_SELL_CRYSTAL] = "cgi_farm_sell_crystal";
         this.m_cmdMap[CommandDefs.CMD_GET_WAREHOUSE_SEEDS] = "" + _loc3_ + "mod=cgi_farm_seed_list";
         this.m_cmdMap[CommandDefs.CMD_GET_WAREHOUSE_FISH] = "" + _loc3_ + "mod=cgi_fish_user_rep";
         this.m_cmdMap[CommandDefs.CMD_SELL_WAREHOUSE_FISH] = "" + _loc3_ + "mod=cgi_fish_sale";
         this.m_cmdMap[CommandDefs.CMD_SELL_ALL_PLANTS] = "" + _loc3_ + "mod=repertory&act=saleAll";
         this.m_cmdMap[CommandDefs.CMD_GET_DIY_ITEMS] = "mod=item&act=getUserItems";
         this.m_cmdMap[CommandDefs.CMD_ACTIVE_DECORATE] = "mod=item&act=activeItem";
         this.m_cmdMap[CommandDefs.CMD_DEACTIVE_DECORATE] = "mod=item&act=deactiveItem";
         this.m_cmdMap[CommandDefs.CMD_SELL_PLANT] = "" + _loc3_ + "mod=repertory&act=sale";
         this.m_cmdMap[CommandDefs.CMD_SELL_SEED] = "" + _loc3_ + "mod=cgi_farm_seed_sell";
         this.m_cmdMap[CommandDefs.CMD_GET_DOG_FOOD_STATUS] = "mod=dog&act=feedMoney";
         this.m_cmdMap[CommandDefs.CMD_RECLAIM_CONDITION] = "mod=user&act=reclaimPay";
         this.m_cmdMap[CommandDefs.CMD_RECLAIM_PAY] = "mod=user&act=reclaim";
         this.m_cmdMap[CommandDefs.CMD_UPGRADE_RED] = "" + _loc3_ + "mod=cgi_farm_upgrade";
         this.m_cmdMap[CommandDefs.CMD_GET_FRIENDLIST] = "" + _loc3_ + "mod=friend";
         this.m_cmdMap[CommandDefs.CMD_GET_FRIENDLIST_STATUS] = "" + _loc3_ + "mod=cgi_farm_getstatus_filter";
         this.m_cmdMap[CommandDefs.CMD_GET_FRIEND_FILTER] = "" + _loc3_ + "mod=friend&act=listFilter";
         this.m_cmdMap[CommandDefs.CMD_ADD_FRIEND_FILTER] = "mod=friend&act=addFilter";
         this.m_cmdMap[CommandDefs.CMD_REMOVE_FRIEND_FILTER] = "mod=friend&act=delFilter";
         this.m_cmdMap[CommandDefs.CMD_GET_SYSTEM_POST_MSG] = "" + _loc2_ + "mod=user&act=getNotice";
         this.m_cmdMap[CommandDefs.CMD_GET_EVERYDAY_GIFT] = "mod=Feast&act=getPackageList";
         this.m_cmdMap[CommandDefs.CMD_ACCEPT_EVERYDAY_GIFT] = "mod=Feast&act=getPackage";
         this.m_cmdMap[CommandDefs.CMD_GET_PROFILE_ALL_INFO] = "" + _loc3_ + "mod=chat&act=getAllInfo";
         this.m_cmdMap[CommandDefs.CMD_CLEAR_ALL_LOG] = "mod=chat&act=clearLog";
         this.m_cmdMap[CommandDefs.CMD_CLEAR_ALL_CHAT] = "mod=chat&act=clearChat";
         this.m_cmdMap[CommandDefs.CMD_GET_BILL_DATA] = "" + _loc3_ + "mod=cgi_farm_exchange";
         this.m_cmdMap[CommandDefs.CMD_GET_BILL_WS_DATA] = "mod=fcg_ws_get_costfeeds";
         this.m_cmdMap[CommandDefs.CMD_SEND_CHAT] = "mod=chat&act=sendChat";
         this.m_cmdMap[CommandDefs.CMD_BUY_SEEDS] = "mod=repertory&act=buySeed";
         this.m_cmdMap[CommandDefs.CMD_BUY_FISHS] = "mod=cgi_fish_buy";
         this.m_cmdMap[CommandDefs.CMD_BUY_TOOLS] = "mod=usertool&act=buyTool";
         this.m_cmdMap[CommandDefs.CMD_BUY_TOOLS_VIP] = "mod=cgi_farm_tool_vip";
         this.m_cmdMap[CommandDefs.CMD_BUY_WEAPONS] = "mod=cgi_farm_buyweapon";
         this.m_cmdMap[CommandDefs.CMD_GET_FISH_ALL] = "" + _loc3_ + "mod=cgi_fish_getall";
         this.m_cmdMap[CommandDefs.CMD_WB_PROFILE] = "mod=cgi_farm_get_userprofile";
         var _loc4_:String = _loc1_.mode;
         if(_loc4_ == "")
         {
            _loc4_ = "pengyou.qq";
         }
         else
         {
            _loc4_ = "qzone.qq";
         }
         this.m_cmdMap[CommandDefs.CMD_GAME_REQUEST_GET] = "" + _loc4_ + "mod=request_get";
         this.m_cmdMap[CommandDefs.CMD_REQUEST_ZHAO] = "" + _loc3_ + "mod=cgi_farm_sendrequest";
         this.m_cmdMap[CommandDefs.CMD_REQUEST_SELECT] = "" + _loc3_ + "mod=cgi_farm_acceptrequest";
         this.m_cmdMap[CommandDefs.CMD_REQUEST_COUNT] = "" + _loc4_ + "mod=request_get_count";
         this.m_cmdMap[CommandDefs.CMD_BUY_DIY] = "mod=cgi_farm_buyitem";
         this.m_cmdMap[CommandDefs.CMD_OPEN_HEALTH] = "mod=item&act=healthMode";
         this.m_cmdMap[CommandDefs.CMD_LEVEL_UP] = "mod=feast&act=levelup";
         this.m_cmdMap[CommandDefs.CMD_WELCOME_END] = "mod=user&act=welcome";
         this.m_cmdMap[CommandDefs.CMD_ACCEPT_TASK] = "mod=task&act=accept";
         this.m_cmdMap[CommandDefs.CMD_UPDATE_TASK] = "mod=task&act=update";
         this.m_cmdMap[CommandDefs.CMD_BUY_PRECHECK] = "mod=cgi_farm_shop_verify";
         this.m_cmdMap[CommandDefs.CMD_BUY_INGAME_BUY] = "mod=cgi_farm_shop_pay";
         this.m_cmdMap[CommandDefs.CMD_PASTURE_VEERFY] = "mod=cgi_pasture_shop_verify";
         this.m_cmdMap[CommandDefs.CMD_PASTURE_PAY] = "mod=cgi_pasture_shop_pay";
         this.m_cmdMap[CommandDefs.CMD_GET_WAREHOUSE_MYFLOWERS] = "" + _loc3_ + "mod=cgi_farm_flower_received";
         this.m_cmdMap[CommandDefs.CMD_GET_FLOWER_WORDS] = "" + _loc3_ + "mod=cgi_farm_flower_get_card";
         this.m_cmdMap[CommandDefs.CMD_ITEM_VIP] = "" + _loc3_ + "mod=cgi_farm_item_vip";
         this.m_cmdMap[CommandDefs.CMD_DEL_MYFLOWER] = "" + _loc3_ + "mod=cgi_farm_flower_del_msg";
         this.m_cmdMap[CommandDefs.CMD_SEND_FLOWER] = "" + _loc3_ + "mod=cgi_farm_flower_send";
         this.m_cmdMap[CommandDefs.CMD_UPDATE_LOCK] = "" + _loc3_ + "mod=cgi_farm_set_lock";
         this.m_cmdMap[CommandDefs.CMD_UPDATE_FISH_LOCK] = "" + _loc3_ + "mod=cgi_fish_rep_lock";
         this.m_cmdMap[CommandDefs.CMD_SELL_ALL_SEEDS] = "" + _loc3_ + "mod=cgi_farm_seed_sell";
         this.m_cmdMap[CommandDefs.CMD_GET_CARDSGAME_DATA] = "" + _loc3_ + "mod=cgi_farm_login_home";
         this.m_cmdMap[CommandDefs.CMD_REFRESH_CARDSGAME_DATA] = "" + _loc3_ + "mod=cgi_farm_login_click";
         this.m_cmdMap[CommandDefs.CMD_GET_CARDSGAME_REWARD] = "" + _loc3_ + "mod=cgi_pasture_signin";
         this.m_cmdMap[CommandDefs.CMD_OPEN_MC] = "" + _loc3_ + "mod=cgi_register";
         this.m_cmdMap[CommandDefs.CMD_GET_VIPRETURN_GIFT] = "" + _loc3_ + "mod=cgi_return_gift";
         this.m_cmdMap[CommandDefs.CMD_NPC_ACTIVITY] = "" + _loc3_ + "mod=cgi_farm_2years";
         this.m_cmdMap[CommandDefs.CMD_NPC_WEIBO] = "" + _loc3_ + "mod=cgi_farm_twoyear_mblog";
         this.m_cmdMap[CommandDefs.CMD_NPC_BLOG] = "" + _loc3_ + "mod=cgi_farm_twoyear_blog";
         this.m_cmdMap[CommandDefs.CMD_NPC_WEIBO_FLAG] = "" + _loc3_ + "mod=cgi_farm_twoyear_flag";
         this.m_cmdMap[CommandDefs.CMD_GET_SYSTEM_MSG] = "" + _loc2_ + "mod=sysmsg_select";
         this.m_cmdMap[CommandDefs.CMD_GET_FEEDS] = "" + _loc2_ + "mod=hydra_feeds_select";
         this.m_cmdMap[CommandDefs.CMD_CLEAR_ALL_FEEDS] = "" + _loc2_ + "mod=hydra_feeds_delete";
         this.m_cmdMap[CommandDefs.CMD_DAILYMISSION_GET_REFRESH] = "" + _loc3_ + "mod=cgi_farm_mission_num";
         this.m_cmdMap[CommandDefs.CMD_DOLPHIN_FUND] = "" + _loc3_ + "mod=cgi_farm_landext_fund";
         this.m_cmdMap[CommandDefs.CMD_HOUSE_KEEPER] = "" + _loc3_ + "mod=cgi_farm_housekeeper";
         this.m_cmdMap[CommandDefs.CMD_SINGLE_FES] = "" + _loc3_ + "mod=cgi_farm_guang_gun";
         this.m_cmdMap[CommandDefs.CMD_GET_SNS_AD] = "mod=view_fcg&";
         this.m_cmdMap[CommandDefs.CMD_GET_SHOP_ADVERTISEMENT_SEED] = "mod=view_fcg&";
         this.m_cmdMap[CommandDefs.CMD_SET_ADSEED_COOKIE] = "http://c.gdt.qq.com/gdt_cookie.fcg";
         this.m_cmdMap[CommandDefs.CMD_GET_FISHES] = "" + _loc2_ + "mod=cgi_fish_index";
         this.m_cmdMap[CommandDefs.CMD_GROW_FISH] = "" + _loc2_ + "mod=cgi_fish_plant";
         this.m_cmdMap[CommandDefs.CMD_HARVEST_FISH] = "" + _loc2_ + "mod=cgi_fish_harvest";
         this.m_cmdMap[CommandDefs.CMD_STEAL_FISH] = "" + _loc2_ + "mod=cgi_fish_steal";
         this.m_cmdMap[CommandDefs.CMD_FISH_OUTPUT] = "" + _loc2_ + "mod=cgi_fish_output";
         this.m_cmdMap[CommandDefs.CMD_WATER_OPEN] = "" + _loc2_ + "mod=cgi_fish_register";
         this.m_cmdMap[CommandDefs.CMD_FEED_FISH] = "" + _loc2_ + "mod=cgi_fish_fertilize";
         this.m_cmdMap[CommandDefs.WHITE_LIST] = "" + _loc2_ + "mod=cgi_farm_whitelist";
         this.m_cmdMap[CommandDefs.CMD_FREE_COUNT] = "" + _loc3_ + "mod=cgi_farm_request_count";
         this.m_cmdMap[CommandDefs.CMD_FREE_LIST] = "" + _loc3_ + "mod=cgi_farm_request_list";
         this.m_cmdMap[CommandDefs.CMD_FREE_GIFT] = "" + _loc3_ + "mod=cgi_farm_request_gift_send";
         this.m_cmdMap[CommandDefs.CMD_FREE_GIFT_RECV] = "" + _loc3_ + "mod=cgi_farm_request_gift_recv";
         this.m_cmdMap[CommandDefs.CMD_UPGRADE_BLACK] = "" + _loc2_ + "mod=cgi_farm_upgrade_black";
         this.m_cmdMap[CommandDefs.CMD_FEEDS_NPC_GET_FRIEND_DATA] = "" + _loc2_ + "mod=cgi_farm_get_basic";
         this.m_cmdMap[CommandDefs.CMD_ALLIANCE_GRAY] = "" + _loc2_ + "mod=cgi_farm_tree";
         this.m_cmdMap[CommandDefs.CMD_MONTHEND_LIST] = "" + _loc2_ + "mod=cgi_farm_month_list";
         this.m_cmdMap[CommandDefs.CMD_MONTHEND_REFRESH] = "" + _loc2_ + "mod=cgi_farm_month_refresh";
         this.m_cmdMap[CommandDefs.CMD_MONTHEND_GET_GIFT] = "mod=cgi_farm_month_get";
         this.m_cmdMap[CommandDefs.CMD_GET_CARDSGAME_ACTIVITY] = "" + _loc2_ + "mod=cgi_farm_login_draw";
         this.m_cmdMap[CommandDefs.CMD_ACTIVITY_GRAY] = "mod=cgi_farm_get_bit?bit=6";
         this.m_cmdMap[CommandDefs.CMD_ALLIANCE_PRICE] = "mod=price_goods";
         this.m_cmdMap[CommandDefs.CMD_UP_GOLD_LAND] = "" + _loc2_ + "mod=cgi_farm_upgrade_gold";
         this.m_cmdMap[CommandDefs.REFRESH_UP_GOLD_TIME] = "" + _loc2_ + "mod=cgi_farm_olympic_game";
         this.m_cmdMap[CommandDefs.AUTO_POP] = "" + _loc2_ + "mod=cgi_fetch_strategy_rules";
         this.m_parsers[CommandDefs.CMD_GET_BOOT_DATA] = new StartupDataParser();
         this.m_parsers[CommandDefs.CMD_OPERATE_CHECKSTATUS] = new NullParser();
         this.m_parsers[CommandDefs.CMD_GET_BAG_DATA] = new BagDataParser();
         this.m_parsers[CommandDefs.CMD_GET_SHOP_SEED] = new SeedDataParser();
         this.m_parsers[CommandDefs.CMD_GET_SHOP_ITEMS] = new ItemsDataParser();
         this.m_parsers[CommandDefs.CMD_GET_SHOP_DIY] = new DIYDataParser();
         this.m_parsers[CommandDefs.CMD_GET_WAREHOUSE_CROPS] = new WarehouseCropsParser();
         this.m_parsers[CommandDefs.CMD_GET_WAREHOUSE_SEEDS] = new WarehouseSeedsParser();
         this.m_parsers[CommandDefs.CMD_GET_WAREHOUSE_FISH] = new WarehouseFishParser();
         this.m_parsers[CommandDefs.CMD_GET_DIY_ITEMS] = new DecorateItemsParser();
         this.m_parsers[CommandDefs.CMD_GET_FRIENDLIST] = new FriendsDataParser();
         this.m_parsers[CommandDefs.CMD_ADD_FRIEND_FILTER] = new NullParser();
         this.m_parsers[CommandDefs.CMD_REMOVE_FRIEND_FILTER] = new NullParser();
         this.m_parsers[CommandDefs.CMD_WELCOME_END] = new NullParser();
         this.m_parsers[CommandDefs.CMD_GET_SHOP_FISH] = new FishDataParser();
         this.m_parsers[CommandDefs.CMD_GET_FISHES] = new FishIndexParser();
      }
      
      public static function getInstance() : ServerServices
      {
         if(_instance != null)
         {
            return _instance;
         }
         _instance = new ServerServices();
         return _instance;
      }
      
      public function registerCmdMap(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Object = null;
         var _loc3_:int = int(param1.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = param1[_loc2_];
            if(_loc4_ != null)
            {
               this.m_cmdMap[_loc4_["id"]] = _loc4_["url"];
            }
            _loc2_++;
         }
      }
      
      public function decodeResult(param1:Protocol) : ServiceResultVO
      {
         var _loc4_:ILogicParser = null;
         var _loc5_:ServiceResultVO = null;
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:uint = param1.cmdID;
         if(_loc2_ == 0)
         {
            return null;
         }
         var _loc3_:Object = param1.decodeForHttp();
         if(_loc3_ == null)
         {
            return null;
         }
         if(this.checkResponseError(_loc3_) == true)
         {
            _loc4_ = this.m_parsers[_loc2_] as ILogicParser;
            if(_loc4_ != null)
            {
               return _loc4_.parse(_loc3_);
            }
            return this.m_defaultParser.parse(_loc3_);
         }
         _loc5_ = new ServiceResultVO();
         _loc5_.m_result = _loc3_["errorType"] || _loc3_["code"];
         _loc5_.m_message = _loc3_["errorContent"] || _loc3_["direction"] || _loc3_["msg"];
         _loc5_.m_extra = _loc3_;
         return _loc5_;
      }
      
      public function getRequestUrl(param1:uint) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = this.m_cmdMap[param1];
         if(/^http.*/.test(_loc3_))
         {
            if(QzoneJSAPI.WB == true)
            {
               _loc3_ = _loc3_.replace(/farm.qzone.qq.com|nc.qzone.qq.com/i,"farm.mblog.qq.com");
            }
            _loc2_ = QzoneJSAPI.addGToken(_loc3_);
            if(_loc2_ != null && _loc2_ != "")
            {
               return _loc2_;
            }
            return _loc3_;
         }
         var _loc4_:Settings = Settings.getInstance();
         var _loc5_:String = "";
         if(_loc4_.mode == "qzone" || _loc4_.mode == "qplus")
         {
            _loc5_ = "postUrl_qz";
         }
         else if(_loc4_.xymode == "")
         {
            _loc5_ = "postUrl_xy_qq";
         }
         else
         {
            _loc5_ = "postUrl_xy_pengyou";
         }
         _loc5_ = Settings.getInstance().getUrlConfigByName(_loc5_);
         if(_loc5_ == "")
         {
            return _loc3_;
         }
         if(QzoneJSAPI.WB == true)
         {
            _loc5_ = "";
         }
         _loc3_ = _loc5_ + _loc3_;
         _loc2_ = QzoneJSAPI.addGToken(_loc3_);
         if(_loc2_ != null && _loc2_ != "")
         {
            return _loc2_;
         }
         return _loc3_;
      }
      
      public function registerCmd(param1:uint, param2:String, param3:ILogicParser = null) : void
      {
         if(param1 == 0)
         {
            return;
         }
         if(param2 == null || param2 == "")
         {
            return;
         }
         if(this.m_cmdMap[param1] != null && this.m_cmdMap[param1] != undefined)
         {
            throw new ArgumentError("Command already exists.");
         }
         this.m_cmdMap[param1] = param2;
         if(param3 != null)
         {
            this.m_parsers[param1] = param3;
         }
      }
      
      public function encodeRequest(param1:uint, param2:Object = null) : Protocol
      {
         if(param1 == 0)
         {
            throw new ArgumentError("Invalid server service command");
         }
         var _loc3_:String = this.m_cmdMap[param1];
         if(_loc3_ == null || _loc3_.length == 0)
         {
            throw new ArgumentError("Invalid server service url");
         }
         var _loc4_:Protocol = new Protocol(param1);
         _loc4_.importRequestObject(param2);
         return _loc4_;
      }
      
      public function checkResponseError(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return true;
         }
         if(param1["errorType"] != undefined)
         {
            return false;
         }
         if(param1["code"] != undefined)
         {
            if(param1["code"] == "1")
            {
               return true;
            }
            if(param1["code"] == "888")
            {
               return true;
            }
            return false;
         }
         return true;
      }
   }
}

