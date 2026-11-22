package module.shop
{
   import com.qzone.qfa.events.CommandEvent;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import entities.Seed;
   import entities.ShopFish;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.net.sendToURL;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.EventRecorder;
   
   public class ShopModel extends EventDispatcher
   {
      
      internal static const EVENT_SHOP_DATA_LOADED:String = "ShopDataLoaded";
      
      internal static const EVENT_SHOP_DATA_LOADING:String = "ShopDataLoading";
      
      internal static const EVENT_SHOP_DATA_FAILED:String = "ShopDataFailed";
      
      internal static const EVENT_BUY_SEED_SUCCESS:String = "BuySeedSuccess";
      
      internal static const EVENT_BUY_SEED_FAIL:String = "BuySeedFail";
      
      internal static const EVENT_BUY_FISH_SUCCESS:String = "BuyFishSuccess";
      
      internal static const EVENT_BUY_FISH_FAIL:String = "BuyFishFail";
      
      internal static const EVENT_BUY_TOOL_SUCCESS:String = "BuyToolSuccess";
      
      internal static const EVENT_BUY_TOOL_FAIL:String = "BuyToolFail";
      
      internal static const EVENT_BUY_DIY_SUCCESS:String = "BuyDiySuccess";
      
      internal static const EVENT_BUY_DIY_FAIL:String = "BuyDiyFail";
      
      internal static const EVENT_SHOP_DIY_OWN_LOADED:String = "ShopDiyOwnDataLoaded";
      
      internal static const EVENT_NORMAL_ERROR:String = "NormalErrorAlert";
      
      internal static const EVENT_UNLOCK_FISH_SUCCESS:String = "UnlockFishSuccess";
      
      internal static const EVENT_UNLOCK_FISH_FAIL:String = "UnlockFishFail";
      
      private var m_preBuyToolType:int;
      
      private var _diyExp:int;
      
      private var m_requestPending:Boolean;
      
      private var _buyType:String;
      
      private var m_advertisement:Array;
      
      private var m_decors:Array;
      
      private var m_fishs:Array;
      
      private var _itemType:String;
      
      private var m_seeds:Array;
      
      private var seedID:int;
      
      private var seedNum:int;
      
      private var m_adSeeds:Array;
      
      private var m_items:Array;
      
      public function ShopModel(param1:IEventDispatcher = null)
      {
         super(param1);
         this.m_seeds = null;
         this.m_items = null;
         this.m_decors = null;
         this.m_adSeeds = null;
         this.m_preBuyToolType = -1;
         this.m_requestPending = false;
      }
      
      public function loadDecorsInfo() : void
      {
         if(this.m_decors != null)
         {
            return;
         }
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
            "index":3,
            "show":true
         }));
         NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_DIY,null,this.onGetDecorsInfo,this.onLoadDataError);
      }
      
      private function endTransaction() : void
      {
         this.m_preBuyToolType = -1;
         this.m_requestPending = false;
      }
      
      public function loadAdvertisementInfo() : void
      {
         var _loc1_:String = "posid=72339074132595919&adposcount=1&count=6&siteset=1&datatype=2";
         var _loc2_:URLVariables = new URLVariables(_loc1_);
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
            "index":4,
            "show":true
         }));
         NetHelper.getRequest(CommandDefs.CMD_GET_SNS_AD,_loc2_,this.onGetAdvertisementInfo,this.onLoadDataError);
      }
      
      private function onUnlockFishSuccess(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == 1)
         {
            dispatchEvent(new CommonEvent(EVENT_UNLOCK_FISH_SUCCESS,_loc2_));
         }
         this.loadFishInfo(true);
      }
      
      private function onDecorsItemLoadedInfo(param1:CommandEvent) : void
      {
         var _loc4_:Object = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Array = [];
         for each(_loc4_ in _loc2_[1])
         {
            _loc3_.push(_loc4_._id);
         }
         dispatchEvent(new CommonEvent(EVENT_SHOP_DIY_OWN_LOADED,{"data":_loc3_}));
      }
      
      public function get advertisements() : Array
      {
         return this.m_advertisement;
      }
      
      private function fishSort(param1:ShopFish, param2:ShopFish) : int
      {
         if(param1 == null || param2 == null)
         {
            return 0;
         }
         var _loc3_:int = param1._output * param1._sale > param2._output * param2._sale ? 1 : -1;
         if(param1._output * param1._sale == param2._output * param2._sale)
         {
            _loc3_ = param1._id > param2._id ? 1 : -1;
         }
         return _loc3_;
      }
      
      private function onLoadDataError(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = -1;
         if(param1.body != null && param1.body["cmdID"] != undefined)
         {
            if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_SHOP_SEED)
            {
               _loc3_ = 0;
               this.recordResp(EventRecorder.HF_GET_SHOP_SEED,false,"mod=usertool&act=getSeedInfo");
               QzoneJSAPI.reportError("商店种子加载失败",2);
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_SHOP_ITEMS)
            {
               _loc3_ = 2;
               this.recordResp(EventRecorder.HF_GET_SHOP_ITEM,false,"mod=usertool&act=getTools");
               QzoneJSAPI.reportError("商店道具加载失败",2);
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_SHOP_DIY)
            {
               _loc3_ = 3;
               this.recordResp(EventRecorder.HF_GET_SHOP_DIY,false,"mod=item&act=shop");
               QzoneJSAPI.reportError("商店装饰加载失败",2);
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_SNS_AD)
            {
               this.recordResp(EventRecorder.HF_GET_SNS_AD,false,"i.gdt.qq.com");
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_SHOP_FISH)
            {
               _loc3_ = 1;
               EventRecorder.recordErrorEvent("160857",null,4);
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_SHOP_ADVERTISEMENT_SEED)
            {
               _loc3_ = 5;
            }
         }
         if(_loc3_ == -1)
         {
            return;
         }
         var _loc4_:String = Language.L["请求超时，"] + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>" + Language.L["点击重试"] + "</font></u></a>";
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_FAILED,{
            "index":_loc3_,
            "error":_loc4_
         }));
      }
      
      public function get fishs() : Array
      {
         return this.m_fishs;
      }
      
      private function onGetAdvertisementInfo(param1:CommandEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["ret"] != 0)
         {
            dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_FAILED,{
               "index":4,
               "error":_loc2_["msg"]
            }));
         }
         else if(_loc2_["data"]["72339074132595919"]["ret"] == 0)
         {
            dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
               "index":4,
               "show":false
            }));
            if(this.m_advertisement == null)
            {
               this.m_advertisement = new Array();
            }
            else
            {
               this.m_advertisement.splice(0);
            }
            this.m_advertisement = this.m_advertisement.concat(_loc2_["data"]["72339074132595919"]["list"]);
            dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED,{
               "index":4,
               "data":this.m_advertisement
            }));
            _loc3_ = _loc2_["data"]["72339074132595919"]["cfg"]["apurl"];
            if(_loc3_ != null && _loc3_ != "")
            {
               sendToURL(new URLRequest(_loc3_));
            }
         }
         else
         {
            dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED,{
               "index":4,
               "data":this.m_advertisement
            }));
         }
         this.recordResp(EventRecorder.HF_GET_SNS_AD,true,"i.gdt.qq.com");
      }
      
      public function get seeds() : Array
      {
         return this.m_seeds;
      }
      
      private function onBuyToolSuccess(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = {};
         if(param1.body["cmdID"] == CommandDefs.CMD_BUY_TOOLS || param1.body["cmdID"] == CommandDefs.CMD_BUY_WEAPONS || param1.body["cmdID"] == CommandDefs.CMD_BUY_TOOLS_VIP)
         {
            if(_loc2_["code"] == 1)
            {
               _loc2_["__buyType"] = "0";
               dispatchEvent(new CommonEvent(EVENT_BUY_TOOL_SUCCESS,_loc2_));
            }
         }
         this.endTransaction();
      }
      
      public function resetLoadingFlags() : void
      {
         if(this.m_requestPending == true)
         {
            this.m_requestPending = false;
         }
      }
      
      public function loadSeedsInfo() : void
      {
         if(this.m_seeds != null)
         {
            return;
         }
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
            "index":0,
            "show":true,
            "isact":0
         }));
         NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_SEED,null,this.onGetSeedsInfo,this.onLoadDataError);
      }
      
      private function onBuySeedSuccess(param1:CommandEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:URLVariables = null;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == 1)
         {
            dispatchEvent(new CommonEvent(EVENT_BUY_SEED_SUCCESS,_loc2_));
         }
         this.endTransaction();
         if(Boolean(param1["body"]["__body"].hasOwnProperty("isAdSeed")) && Boolean(param1["body"]["__body"]["isAdSeed"]))
         {
            _loc3_ = "actionid=6&targettype=18&tagetid=" + _loc2_["cId"].toString() + "&amt=" + _loc2_["num"].toString();
            _loc4_ = new URLVariables(_loc3_);
            this.postUrl("",_loc4_,URLRequestMethod.GET);
         }
         this.recordResp(EventRecorder.HF_BUY_SEEDS,true,"mod=repertory&act=buySeed");
      }
      
      public function loadFishInfo(param1:Boolean = false) : void
      {
         if(!Session.getInstance().m_waterPoolOpen)
         {
            return;
         }
         if(this.m_fishs != null && !param1)
         {
            return;
         }
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
            "index":1,
            "show":true
         }));
         NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_FISH,null,this.onGetFishInfo,this.onLoadDataError);
      }
      
      public function buyDiy(param1:int) : void
      {
         if(this.beginTransaction(parseInt(Consts.ITEM_TYPE_DIY)) == false)
         {
            return;
         }
         var _loc2_:Object = {"itemId":param1};
         NetHelper.sendRequest(CommandDefs.CMD_BUY_DIY,_loc2_,this.onBuyDIYSuccess,this.onTransactionError);
      }
      
      private function postUrl(param1:String, param2:URLVariables, param3:String) : void
      {
         param1 = QzoneJSAPI.addGToken(param1);
         var _loc4_:URLRequest = new URLRequest(param1);
         _loc4_.data = param2;
         _loc4_.method = param3;
         var _loc5_:URLLoader = new URLLoader();
         _loc5_.load(_loc4_);
      }
      
      private function onGetAdvertisementSeedsList(param1:CommandEvent) : void
      {
         var _loc6_:Seed = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(this.m_adSeeds == null)
         {
            this.m_adSeeds = new Array();
         }
         else
         {
            this.m_adSeeds.splice(0);
         }
         this.m_adSeeds = this.m_adSeeds.concat(_loc2_);
         var _loc3_:Array = null;
         var _loc4_:String = Settings.getInstance().getStringAttribute("crops_sort");
         if(_loc4_ != "")
         {
            _loc3_ = _loc4_.split(",");
         }
         var _loc5_:Object = null;
         for each(_loc6_ in this.m_adSeeds)
         {
            if(_loc3_ != null)
            {
               _loc6_._sort = _loc3_.indexOf(_loc6_._id.toString());
            }
            _loc5_ = Settings.getInstance().getCropByID(_loc6_._id.toString());
            if(_loc5_ != null)
            {
               if(_loc6_._isFood == -1 && _loc5_["isFood"] != undefined)
               {
                  _loc6_._isFood = _loc5_["isFood"] == "1" ? 1 : 0;
               }
               if(_loc6_._isRestaurant == -1 && _loc5_["isRestaurant"] != undefined)
               {
                  _loc6_._isRestaurant = _loc5_["isRestaurant"] == "1" ? 1 : 0;
               }
               if(_loc6_._isActivity == -1 && _loc5_["isActivity"] != undefined)
               {
                  _loc6_._isActivity = _loc5_["isActivity"] == "1" ? 1 : 0;
               }
               if(_loc6_._isMill == -1 && _loc5_["isMill"] != undefined)
               {
                  _loc6_._isMill = _loc5_["isMill"] == "1" ? 1 : 0;
               }
               if(_loc6_._isVip == -1 && _loc5_["isVIP"] != undefined)
               {
                  _loc6_._isVip = _loc5_["isVIP"] == "1" ? 1 : 0;
                  if(_loc5_["vipDesc"] != undefined)
                  {
                     _loc6_._vipDesc = _loc5_["vipDesc"];
                  }
               }
               if(_loc5_["isRed"] != undefined)
               {
                  _loc6_._isRed = _loc5_["isRed"] == "1" ? true : false;
               }
            }
         }
         if(_loc3_ != null)
         {
            this.m_adSeeds.sort(this.seedSort);
         }
         this.loadAdvertisementSeedsInfo();
      }
      
      public function buyFishs(param1:int, param2:int) : void
      {
         if(param1 <= 0 || param2 <= 0)
         {
            return;
         }
         if(this.beginTransaction(parseInt(Consts.ITEM_TYPE_FISH)) == false)
         {
            return;
         }
         var _loc3_:* = {
            "fid":param1,
            "num":param2
         };
         NetHelper.sendRequest(CommandDefs.CMD_BUY_FISHS,_loc3_,this.onBuyFishSuccess,this.onTransactionError);
      }
      
      private function seedSort(param1:Seed, param2:Seed) : int
      {
         if(param1 == null || param2 == null)
         {
            return 0;
         }
         var _loc3_:int = param1._lvl > param2._lvl ? 1 : -1;
         if(param1._lvl == param2._lvl)
         {
            _loc3_ = param1._id > param2._id ? 1 : -1;
         }
         return _loc3_;
      }
      
      private function onGetSeedsInfo(param1:CommandEvent) : void
      {
         var _loc6_:Seed = null;
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
            "index":0,
            "show":false
         }));
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(this.m_seeds == null)
         {
            this.m_seeds = new Array();
         }
         else
         {
            this.m_seeds.splice(0);
         }
         this.m_seeds = this.m_seeds.concat(_loc2_);
         var _loc3_:Array = null;
         var _loc4_:String = Settings.getInstance().getStringAttribute("crops_sort");
         if(_loc4_ != "")
         {
            _loc3_ = _loc4_.split(",");
         }
         var _loc5_:Object = null;
         for each(_loc6_ in this.m_seeds)
         {
            if(_loc3_ != null)
            {
               _loc6_._sort = _loc3_.indexOf(_loc6_._id.toString());
            }
            _loc5_ = Settings.getInstance().getCropByID(_loc6_._id.toString());
            if(_loc5_ != null)
            {
               if(_loc6_._isFood == -1 && _loc5_["isFood"] != undefined)
               {
                  _loc6_._isFood = _loc5_["isFood"] == "1" ? 1 : 0;
               }
               if(_loc6_._isRestaurant == -1 && _loc5_["isRestaurant"] != undefined)
               {
                  if(_loc5_["isRestaurant"] == "1")
                  {
                     _loc6_._isRestaurant = 1;
                  }
                  else if(_loc5_["isRestaurant"] == "2")
                  {
                     _loc6_._isRestaurant = 2;
                  }
                  else
                  {
                     _loc6_._isRestaurant = 0;
                  }
               }
               if(_loc6_._isMill == -1 && _loc5_["isMill"] != undefined)
               {
                  _loc6_._isMill = _loc5_["isMill"] == "1" ? 1 : 0;
               }
               if(_loc6_._isActivity == -1 && _loc5_["isActivity"] != undefined)
               {
                  _loc6_._isActivity = _loc5_["isActivity"] == "1" ? 1 : 0;
               }
               if(_loc6_._isVip == -1 && _loc5_["isVIP"] != undefined)
               {
                  _loc6_._isVip = _loc5_["isVIP"] == "1" ? 1 : 0;
                  if(_loc5_["vipDesc"] != undefined)
                  {
                     _loc6_._vipDesc = _loc5_["vipDesc"];
                  }
               }
               if(_loc5_["isRed"] != undefined)
               {
                  _loc6_._isRed = _loc5_["isRed"] == "1" ? true : false;
                  _loc6_._isBlack = _loc5_["isRed"] == "2" ? true : false;
               }
               _loc6_._isGreen = _loc5_["isYouji"] == 1 ? true : false;
            }
         }
         if(_loc3_ != null)
         {
            this.m_seeds.sort(this.seedSort);
         }
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED,{
            "index":0,
            "data":this.m_seeds
         }));
         this.recordResp(EventRecorder.HF_GET_SHOP_SEED,true,"mod=usertool&act=getSeedInfo");
      }
      
      public function buySeeds(param1:int, param2:int, param3:Boolean = false) : void
      {
         var _loc5_:String = null;
         var _loc6_:URLVariables = null;
         if(param1 == 0 || param2 <= 0)
         {
            return;
         }
         if(this.beginTransaction(parseInt(Consts.ITEM_TYPE_SEED)) == false)
         {
            return;
         }
         var _loc4_:* = {
            "cId":param1,
            "number":param2
         };
         if(param3)
         {
            this.seedID = param1;
            this.seedNum = param2;
            _loc5_ = Settings.getInstance().mode == "qzone" ? "dtype=qq" : "dtype=pengyou";
            _loc6_ = new URLVariables(_loc5_);
            NetHelper.getRequest(CommandDefs.CMD_SET_ADSEED_COOKIE,_loc6_,this.onSetCookie,this.onSetCookie);
            return;
         }
         NetHelper.sendRequest(CommandDefs.CMD_BUY_SEEDS,_loc4_,this.onBuySeedSuccess,this.onTransactionError);
      }
      
      private function onGetFishInfo(param1:CommandEvent) : void
      {
         var _loc4_:ShopFish = null;
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
            "index":1,
            "show":false
         }));
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(this.m_fishs == null)
         {
            this.m_fishs = new Array();
         }
         else
         {
            this.m_fishs.splice(0);
         }
         this.m_fishs = this.m_fishs.concat(_loc2_);
         var _loc3_:Object = null;
         for each(_loc4_ in this.m_fishs)
         {
            _loc3_ = Settings.getInstance().getFishByID(_loc4_._id.toString());
            if(_loc3_ != null)
            {
               _loc4_._pool_size = _loc3_["pool_size"];
               _loc4_._exp = _loc3_["exp"];
               _loc4_._name = _loc3_["crop_name"];
               _loc4_._output = _loc3_["output"];
               _loc4_._sale = _loc3_["sale"];
               _loc4_._price = _loc3_["price"];
               _loc4_._mature = _loc3_["mature"];
               if(_loc4_._lock_gold == 0 && _loc3_["lock_money"] != undefined)
               {
                  _loc4_._lock_gold = _loc3_["lock_money"];
               }
               if(_loc4_._lock_crystal == "" && _loc3_["lock_crystal"] != undefined)
               {
                  _loc4_._lock_crystal = _loc3_["lock_crystal"];
               }
            }
         }
         this.m_fishs.sort(this.fishSort);
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED,{
            "index":1,
            "data":this.m_fishs
         }));
         EventRecorder.recordSueecssEvent("160857",null);
      }
      
      public function buyTool(param1:int, param2:int, param3:int, param4:Boolean = false, param5:String = "", param6:int = 0) : void
      {
         if(this.beginTransaction(param3) == false)
         {
            return;
         }
         var _loc7_:* = {
            "tId":param1,
            "number":param2,
            "type":param3
         };
         NetHelper.sendRequest(CommandDefs.CMD_BUY_TOOLS,_loc7_,this.onBuyToolSuccess,this.onTransactionError);
      }
      
      private function recordResp(param1:String, param2:Boolean, param3:String, param4:int = 0) : void
      {
         if(param1 == "")
         {
            return;
         }
         if(param2 == true)
         {
            EventRecorder.recordSueecssEvent(param1,null,param3);
         }
         else if(param4 == 0)
         {
            EventRecorder.recordErrorEvent(param1,null,EventRecorder.FAULT_ERROR,param3);
         }
         else
         {
            EventRecorder.recordErrorEvent(param1,null,param4,param3);
         }
      }
      
      public function isEmpty(param1:int) : Boolean
      {
         if(param1 == 0)
         {
            return this.m_seeds == null || this.m_seeds.length == 0 ? true : false;
         }
         if(param1 == 1)
         {
            return this.m_items == null || this.m_items.length == 0 ? true : false;
         }
         if(param1 == 2)
         {
            return this.m_decors == null || this.m_decors.length == 0 ? true : false;
         }
         if(param1 == 4)
         {
            return this.m_fishs == null || this.m_fishs.length == 0 ? true : false;
         }
         return true;
      }
      
      public function get decors() : Array
      {
         return this.m_decors;
      }
      
      private function onSetCookie(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.hasOwnProperty("errorContent"))
         {
            ExternalInterface.call("eval",_loc2_["errorContent"].toString());
         }
         var _loc3_:Object = {
            "cId":this.seedID,
            "number":this.seedNum,
            "isAdSeed":true
         };
         NetHelper.sendRequest(CommandDefs.CMD_BUY_SEEDS,_loc3_,this.onBuySeedSuccess,this.onTransactionError);
      }
      
      public function loadItemsInfo() : void
      {
         if(this.m_items != null)
         {
            return;
         }
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
            "index":2,
            "show":true
         }));
         NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_ITEMS,null,this.onGetItemsInfo,this.onLoadDataError);
      }
      
      public function unlockFish(param1:int) : void
      {
         if(param1 <= 0)
         {
            return;
         }
         var _loc2_:* = {"fid":param1};
         NetHelper.sendRequest(CommandDefs.CMD_UNLOCK_SHOP_FISH,_loc2_,this.onUnlockFishSuccess,this.onTransactionError);
      }
      
      public function clear(param1:int) : void
      {
         if(param1 == 0)
         {
            if(this.m_seeds != null)
            {
               this.m_seeds.splice(0);
            }
            this.m_seeds = null;
         }
         else if(param1 == 1)
         {
            if(this.m_items != null)
            {
               this.m_items.splice(0);
            }
            this.m_items = null;
         }
         else if(param1 == 2)
         {
            if(this.m_decors != null)
            {
               this.m_decors.splice(0);
            }
            this.m_decors = null;
         }
         else if(param1 == 3)
         {
            if(this.m_advertisement != null)
            {
               this.m_advertisement.splice(0);
            }
            this.m_advertisement = null;
         }
      }
      
      private function onInGamePreCheckSuccess(param1:CommandEvent) : void
      {
         var onInGameBuySuccess:Function = null;
         var obj:Object = null;
         var e:CommandEvent = param1;
         onInGameBuySuccess = function(param1:Object):void
         {
            var _loc2_:Object = new Object();
            _loc2_["__buyType"] = 3;
            if(_buyType == "Item")
            {
               _loc2_["type"] = _itemType;
               dispatchEvent(new CommonEvent(EVENT_BUY_TOOL_SUCCESS,_loc2_));
            }
            else if(_buyType == "DIY")
            {
               if(_diyExp > 0)
               {
                  _loc2_["__exp"] = _diyExp;
               }
               dispatchEvent(new CommonEvent(EVENT_BUY_DIY_SUCCESS,_loc2_));
            }
         };
         var data:Object = NetHelper.getVOData(e);
         if(data["code"] == 1)
         {
            QzoneJSAPI.getInGamePay(data["url_params"],onInGameBuySuccess);
         }
         else
         {
            obj = new Object();
            obj["direction"] = data["direction"];
            dispatchEvent(new CommonEvent(EVENT_BUY_DIY_FAIL,obj));
         }
      }
      
      public function buyWeapon(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:* = {
            "tId":param1,
            "number":param2,
            "type":param3
         };
         NetHelper.sendRequest(CommandDefs.CMD_BUY_WEAPONS,_loc4_,this.onBuyToolSuccess,this.onTransactionError);
      }
      
      private function onBuyDIYSuccess(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = {};
         if(param1.body["cmdID"] == CommandDefs.CMD_BUY_DIY)
         {
            if(_loc2_["code"] == 1)
            {
               _loc2_["__buyType"] = "0";
               dispatchEvent(new CommonEvent(EVENT_BUY_DIY_SUCCESS,_loc2_));
               this.recordResp(EventRecorder.HF_BUY_DIY,true,"mod=cgi_farm_buyitem");
            }
         }
         this.endTransaction();
      }
      
      private function onGetItemsInfo(param1:CommandEvent) : void
      {
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
            "index":2,
            "show":false
         }));
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(this.m_items == null)
         {
            this.m_items = new Array();
         }
         else
         {
            this.m_items.splice(0);
         }
         this.m_items = this.m_items.concat(_loc2_);
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED,{
            "index":2,
            "data":this.m_items
         }));
         this.recordResp(EventRecorder.HF_GET_SHOP_ITEM,true,"mod=usertool&act=getTools");
      }
      
      private function onTransactionError(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = int(param1.body["cmdID"]);
         var _loc4_:Object = {};
         if(_loc3_ == CommandDefs.CMD_BUY_SEEDS)
         {
            _loc2_["__buyType"] = "0";
            dispatchEvent(new CommonEvent(EVENT_BUY_SEED_FAIL,_loc2_));
            this.recordResp(EventRecorder.HF_BUY_SEEDS,false,"mod=repertory&act=buySeed");
         }
         else if(_loc3_ == CommandDefs.CMD_BUY_FISHS || _loc3_ == CommandDefs.CMD_UNLOCK_SHOP_FISH)
         {
            _loc2_["__buyType"] = "0";
            dispatchEvent(new CommonEvent(EVENT_BUY_FISH_FAIL,_loc2_));
         }
         else if(_loc3_ == CommandDefs.CMD_BUY_TOOLS || _loc3_ == CommandDefs.CMD_BUY_TOOLS_VIP)
         {
            _loc2_["__buyType"] = "0";
            dispatchEvent(new CommonEvent(EVENT_BUY_TOOL_FAIL,_loc2_));
         }
         else if(_loc3_ == CommandDefs.CMD_BUY_DIY)
         {
            _loc2_["__buyType"] = "0";
            dispatchEvent(new CommonEvent(EVENT_BUY_DIY_FAIL,_loc2_));
            if(_loc2_["ecode"] != -30017)
            {
               this.recordResp(EventRecorder.HF_BUY_DIY,false,"mod=cgi_farm_buyitem");
            }
         }
         else if(_loc3_ == CommandDefs.CMD_BUY_INGAME_BUY)
         {
            dispatchEvent(new CommonEvent(EVENT_NORMAL_ERROR,_loc2_));
         }
         this.endTransaction();
      }
      
      public function buyInGame(param1:Object, param2:int, param3:String, param4:int = 0, param5:String = "") : void
      {
         if(param4 > 0)
         {
            this._diyExp = param4;
         }
         else
         {
            this._diyExp = 0;
         }
         this._buyType = param3;
         this._itemType = param5;
         param1["payType"] = param2;
         NetHelper.sendRequest(CommandDefs.CMD_BUY_INGAME_BUY,param1,this.onInGamePreCheckSuccess,this.onTransactionError);
      }
      
      public function loadAdvertisementSeedsList() : void
      {
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
            "index":5,
            "show":true
         }));
         var _loc1_:Object = {"isact":1};
         NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_SEED,_loc1_,this.onGetAdvertisementSeedsList,this.onLoadDataError);
      }
      
      private function onGetDecorsInfo(param1:CommandEvent) : void
      {
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
            "index":3,
            "show":false
         }));
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(this.m_decors == null)
         {
            this.m_decors = new Array();
         }
         else
         {
            this.m_decors.splice(0);
         }
         this.m_decors = this.m_decors.concat(_loc2_);
         this.m_decors.reverse();
         var _loc3_:* = null;
         var _loc4_:int = 0;
         while(_loc4_ < this.m_decors.length)
         {
            _loc3_ = this.m_decors[_loc4_];
            this.m_decors[_loc4_] = this.m_decors[_loc4_ + 3];
            this.m_decors[_loc4_ + 3] = _loc3_;
            _loc3_ = this.m_decors[_loc4_ + 1];
            this.m_decors[_loc4_ + 1] = this.m_decors[_loc4_ + 2];
            this.m_decors[_loc4_ + 2] = _loc3_;
            _loc4_ += 4;
         }
         dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED,{
            "index":3,
            "data":this.m_decors
         }));
         this.recordResp(EventRecorder.HF_GET_SHOP_DIY,true,"mod=item&act=shop");
      }
      
      private function onGetAdvertisementSeedsInfo(param1:CommandEvent) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:* = 0;
         var _loc10_:URLVariables = null;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:URLVariables = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["ret"] != 0)
         {
            dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_FAILED,{
               "index":5,
               "error":_loc2_["msg"]
            }));
         }
         else if(_loc2_["data"]["144396668170523855"]["ret"] == 0)
         {
            dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADING,{
               "index":5,
               "show":false
            }));
            _loc3_ = [];
            _loc3_ = _loc3_.concat(_loc2_["data"]["144396668170523855"]["list"]);
            _loc4_ = [];
            for each(_loc5_ in _loc3_)
            {
               _loc4_.push(_loc5_["targetid"]);
            }
            _loc6_ = 0;
            _loc7_ = "";
            _loc8_ = [];
            _loc9_ = int(this.m_adSeeds.length);
            while(_loc9_ > 0)
            {
               _loc9_--;
               if(_loc4_.indexOf(this.m_adSeeds[_loc6_]._id.toString()) == -1)
               {
                  this.m_adSeeds.splice(_loc6_,1);
               }
               else
               {
                  this.m_adSeeds[_loc6_]._isAdSeed = 1;
                  this.m_adSeeds[_loc6_]._rl = _loc3_[_loc4_.indexOf(this.m_adSeeds[_loc6_]._id.toString())]["rl"];
                  _loc7_ = _loc3_[_loc4_.indexOf(this.m_adSeeds[_loc6_]._id.toString())]["apurl"].toString();
                  _loc7_ = _loc7_.substr(_loc7_.indexOf("fcg?") + 4);
                  _loc13_ = new URLVariables(_loc7_);
                  _loc8_.push(_loc13_["viewid"]);
                  _loc6_++;
               }
            }
            dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED,{
               "index":5,
               "data":this.m_adSeeds
            }));
            _loc10_ = new URLVariables();
            _loc11_ = "";
            _loc12_ = 0;
            while(_loc12_ < _loc8_.length)
            {
               _loc11_ = "viewid" + _loc12_.toString();
               _loc10_[_loc11_] = _loc8_[_loc12_];
               _loc12_++;
            }
            _loc10_["count"] = _loc8_.length;
            this.postUrl("",_loc10_,URLRequestMethod.POST);
         }
         else
         {
            dispatchEvent(new CommonEvent(EVENT_SHOP_DATA_LOADED,{
               "index":5,
               "data":null
            }));
         }
      }
      
      private function onBuyFishSuccess(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == 1)
         {
            dispatchEvent(new CommonEvent(EVENT_BUY_FISH_SUCCESS,_loc2_));
         }
         this.endTransaction();
      }
      
      public function loadAdvertisementSeedsInfo() : void
      {
         var _loc1_:String = "posid=144396668170523855&adposcount=1&count=15&callback=_gdttxtbc&datatype=2";
         var _loc2_:URLVariables = new URLVariables(_loc1_);
         NetHelper.getRequest(CommandDefs.CMD_GET_SHOP_ADVERTISEMENT_SEED,_loc2_,this.onGetAdvertisementSeedsInfo,this.onGetAdvertisementSeedsInfo);
      }
      
      public function loadDecorsItemOwnInfo() : void
      {
         if(this.m_decors == null)
         {
            return;
         }
         NetHelper.sendRequest(CommandDefs.CMD_GET_DIY_ITEMS,null,this.onDecorsItemLoadedInfo,this.onLoadDataError);
      }
      
      private function beginTransaction(param1:int) : Boolean
      {
         if(this.m_requestPending == true)
         {
            return false;
         }
         this.m_preBuyToolType = param1;
         this.m_requestPending = true;
         return true;
      }
      
      public function get items() : Array
      {
         return this.m_items;
      }
      
      public function buyToolVIP(param1:int, param2:int) : void
      {
         if(param1 == 0 || param2 <= 0)
         {
            return;
         }
         var _loc3_:* = {
            "itemId":param1,
            "itemNum":param2
         };
         NetHelper.sendRequest(CommandDefs.CMD_BUY_TOOLS_VIP,_loc3_,this.onBuyToolSuccess,this.onTransactionError);
      }
   }
}

