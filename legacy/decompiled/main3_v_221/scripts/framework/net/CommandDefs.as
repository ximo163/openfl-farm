package framework.net
{
   public final class CommandDefs
   {
      
      public static const HTTP_ERR_IOERROR:int = -100;
      
      public static const HTTP_ERR_HTTPSTATUS:int = -101;
      
      public static const HTTP_ERR_TIMEOUT:int = -102;
      
      public static const CMD_GET_BOOT_DATA:uint = 1;
      
      public static const CMD_RELOAD_GAME_DATA:uint = 1;
      
      public static const CMD_CHECK_MILL_RIGHTS:uint = 2;
      
      public static const CMD_OPERATE_WATER:uint = 10;
      
      public static const CMD_OPERATE_CLEARWEED:uint = 11;
      
      public static const CMD_OPERATE_ADDWEED:uint = 12;
      
      public static const CMD_OPERATE_ADDBUG:uint = 13;
      
      public static const CMD_OPERATE_CLEARBUG:uint = 14;
      
      public static const CMD_OPERATE_HARVEST:uint = 16;
      
      public static const CMD_OPERATE_SCARIFY:uint = 17;
      
      public static const CMD_OPERATE_PLANT:uint = 18;
      
      public static const CMD_OPERATE_FERTILIZE:uint = 19;
      
      public static const CMD_OPERATE_CHECKSTATUS:uint = 20;
      
      public static const CMD_OPERATE_SCROUNGE_NEW:uint = 21;
      
      public static const CMD_GET_OUTPUT:uint = 31;
      
      public static const CMD_GET_BAG_DATA:uint = 32;
      
      public static const CMD_GET_SHOP_SEED:uint = 33;
      
      public static const CMD_GET_SHOP_ITEMS:uint = 34;
      
      public static const CMD_GET_SHOP_DIY:uint = 35;
      
      public static const CMD_GET_WAREHOUSE_CROPS:uint = 36;
      
      public static const CMD_GET_WAREHOUSE_SEEDS:uint = 37;
      
      public static const CMD_GET_DIY_ITEMS:uint = 38;
      
      public static const CMD_GET_DOG_FOOD_STATUS:uint = 39;
      
      public static const CMD_GET_FRIENDLIST:uint = 40;
      
      public static const CMD_GET_FRIENDLIST_STATUS:uint = 41;
      
      public static const CMD_GET_FRIEND_FILTER:uint = 42;
      
      public static const CMD_GET_SYSTEM_POST_MSG:uint = 43;
      
      public static const CMD_GET_EVERYDAY_GIFT:uint = 44;
      
      public static const CMD_GET_PROFILE_ALL_INFO:uint = 45;
      
      public static const CMD_GET_BILL_DATA:uint = 46;
      
      public static const CMD_GET_WAREHOUSE_MYFLOWERS:uint = 47;
      
      public static const CMD_GET_FLOWER_WORDS:uint = 48;
      
      public static const CMD_DEL_MYFLOWER:uint = 49;
      
      public static const CMD_SEND_FLOWER:uint = 50;
      
      public static const CMD_GET_BILL_WS_DATA:uint = 51;
      
      public static const CMD_GET_SYSTEM_MSG:uint = 53;
      
      public static const CMD_GET_FEEDS:uint = 54;
      
      public static const CMD_GET_WAREHOUSE_CRYSTAL:uint = 55;
      
      public static const CMD_SELL_CRYSTAL:uint = 56;
      
      public static const CMD_GET_VIPRETURN_GIFT:uint = 57;
      
      public static const CMD_GET_CARDSGAME_DATA:uint = 58;
      
      public static const CMD_GET_CARDSGAME_REWARD:uint = 59;
      
      public static const CMD_REFRESH_CARDSGAME_DATA:uint = 60;
      
      public static const CMD_GET_SHOP_FISH:uint = 61;
      
      public static const CMD_GET_WAREHOUSE_FISH:uint = 62;
      
      public static const CMD_UNLOCK_SHOP_FISH:uint = 63;
      
      public static const CMD_SELL_WAREHOUSE_FISH:uint = 64;
      
      public static const CMD_SELL_ALL_PLANTS:uint = 80;
      
      public static const CMD_SELL_PLANT:uint = 81;
      
      public static const CMD_SELL_SEED:uint = 82;
      
      public static const CMD_RECLAIM_CONDITION:uint = 83;
      
      public static const CMD_RECLAIM_PAY:uint = 84;
      
      public static const CMD_UPGRADE_RED:uint = 85;
      
      public static const CMD_ACTIVE_DECORATE:uint = 86;
      
      public static const CMD_DEACTIVE_DECORATE:uint = 87;
      
      public static const CMD_ADD_FRIEND_FILTER:uint = 88;
      
      public static const CMD_REMOVE_FRIEND_FILTER:uint = 89;
      
      public static const CMD_ACCEPT_EVERYDAY_GIFT:uint = 90;
      
      public static const CMD_CLEAR_ALL_LOG:uint = 91;
      
      public static const CMD_CLEAR_ALL_CHAT:uint = 92;
      
      public static const CMD_SEND_CHAT:uint = 93;
      
      public static const CMD_BUY_SEEDS:uint = 94;
      
      public static const CMD_BUY_TOOLS:uint = 95;
      
      public static const CMD_BUY_DIY:uint = 98;
      
      public static const CMD_BUY_PRECHECK:uint = 101;
      
      public static const CMD_ITEM_VIP:uint = 102;
      
      public static const CMD_SELL_ALL_SEEDS:uint = 103;
      
      public static const CMD_CLEAR_ALL_FEEDS:uint = 104;
      
      public static const CMD_BUY_INGAME_BUY:uint = 105;
      
      public static const CMD_BUY_TOOLS_VIP:uint = 106;
      
      public static const CMD_BUY_FISHS:uint = 107;
      
      public static const CMD_OPEN_HEALTH:uint = 110;
      
      public static const CMD_LEVEL_UP:uint = 111;
      
      public static const CMD_WELCOME_END:uint = 112;
      
      public static const CMD_ACCEPT_TASK:uint = 113;
      
      public static const CMD_UPDATE_TASK:uint = 114;
      
      public static const CMD_UPDATE_LOCK:uint = 120;
      
      public static const CMD_UPDATE_FISH_LOCK:uint = 122;
      
      public static const CMD_DAILYMISSION_GET_REFRESH:int = 140;
      
      public static const CMD_BUY_WEAPONS:int = 151;
      
      public static const CMD_GAME_REQUEST_GET:int = 188;
      
      public static const CMD_REQUEST_ZHAO:int = 199;
      
      public static const CMD_REQUEST_SELECT:int = 200;
      
      public static const CMD_UPGRADE_BLACK:int = 203;
      
      public static const CMD_MONTHEND_LIST:int = 205;
      
      public static const CMD_MONTHEND_REFRESH:int = 206;
      
      public static const CMD_MONTHEND_GET_GIFT:int = 207;
      
      public static const CMD_GET_FISH_ALL:int = 210;
      
      public static const CMD_REQUEST_COUNT:int = 260;
      
      public static const CMD_GET_FISHES:int = 300;
      
      public static const CMD_GROW_FISH:int = 301;
      
      public static const CMD_HARVEST_FISH:int = 302;
      
      public static const CMD_STEAL_FISH:int = 303;
      
      public static const CMD_FISH_OUTPUT:int = 304;
      
      public static const CMD_WATER_OPEN:int = 305;
      
      public static const CMD_FEED_FISH:int = 306;
      
      public static const WHITE_LIST:int = 400;
      
      public static const CMD_ACTIVITY_GRAY:int = 501;
      
      public static const CMD_WB_PROFILE:int = 500;
      
      public static const CMD_FREE_COUNT:int = 602;
      
      public static const CMD_FREE_LIST:int = 603;
      
      public static const CMD_FREE_GIFT:int = 604;
      
      public static const CMD_FREE_GIFT_RECV:int = 605;
      
      public static const CMD_ALLIANCE_GRAY:int = 651;
      
      public static const CMD_ALLIANCE_PRICE:int = 653;
      
      public static const CMD_GET_CARDSGAME_ACTIVITY:uint = 652;
      
      public static const CMD_NPC_ACTIVITY:uint = 131;
      
      public static const CMD_NPC_WEIBO:uint = 133;
      
      public static const CMD_NPC_BLOG:uint = 135;
      
      public static const CMD_NPC_WEIBO_FLAG:uint = 134;
      
      public static const CMD_DOLPHIN_FUND:int = 201;
      
      public static const CMD_HOUSE_KEEPER:int = 202;
      
      public static const CMD_SINGLE_FES:int = 204;
      
      public static const CMD_THANKS_INITVIEW:int = 208;
      
      public static const CMD_THANKS_PRESENT:int = 209;
      
      public static const CMD_PASTURE_VEERFY:int = 267;
      
      public static const CMD_PASTURE_PAY:int = 268;
      
      public static const CMD_OPEN_MC:uint = 121;
      
      public static const CMD_FEEDS_NPC_GET_FRIEND_DATA:int = 650;
      
      public static const CMD_GET_SNS_AD:uint = 52;
      
      public static const CMD_GET_SHOP_ADVERTISEMENT_SEED:uint = 65;
      
      public static const CMD_SET_ADSEED_COOKIE:uint = 66;
      
      public static const CMD_BUY_TOOLS_QB:uint = 96;
      
      public static const CMD_BUY_TOOLS_CFT:uint = 97;
      
      public static const CMD_BUY_DIY_QB:uint = 99;
      
      public static const CMD_BUY_DIY_CFT:uint = 100;
      
      public static const CMD_UP_GOLD_LAND:uint = 654;
      
      public static const REFRESH_UP_GOLD_TIME:uint = 655;
      
      public static const AUTO_POP:uint = 666;
      
      public function CommandDefs()
      {
         super();
      }
   }
}

