package module.warehouse.house
{
   import com.qzone.farm.api.interfaces.IPluginProxy;
   import com.qzone.qfa.events.CommandEvent;
   import common.Consts;
   import common.GetCropID;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import entities.WarehouseCrop;
   import entities.WarehouseFish;
   import entities.WarehouseSeed;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import framework.api.PluginManager;
   import framework.api.beast.WildData;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.vo.ServiceResultVO;
   import report.EventRecorder;
   
   public class WarehouseModel extends EventDispatcher
   {
      
      internal static const EVENT_DATA_CHANGED:String = "DataChanged";
      
      internal static const EVENT_DATA_LOADING:String = "WarehouseDataLoading";
      
      internal static const EVENT_DATA_FAILED:String = "WarehouseDataFailed";
      
      public static const EVENT_NET_TRANSACTION_ERROR:String = "NetTransactionError";
      
      public static const EVENT_SELLALL_SUCCESS:String = "SellAllSuccess";
      
      public static const EVENT_SELLPLANT_SUCCESS:String = "SellPlantSuccess";
      
      public static const EVENT_SELLALLFISHS_SUCCESS:String = "SellAllFishsSuccess";
      
      public static const EVENT_SELLFISH_SUCCESS:String = "SellFishSuccess";
      
      public static const EVENT_SELLSEED_SUCCESS:String = "SellSeedSuccess";
      
      public static const EVENT_SELLALLSEEDS_SUCCESS:String = "SellAllSeedsSuccess";
      
      public static const EVENT_SENDFLOWER_SUCCESS:String = "SellFlowerSuccess";
      
      public static const EVENT_UPDATELOCK_SUCCESS:String = "UpdateLockSuccess";
      
      public static const EVENT_UPDATEFISHLOCK_SUCCESS:String = "UpdateFishLockSuccess";
      
      private var m_fishDirty:Boolean;
      
      private var m_allFlower:Array;
      
      private var m_seedDirty:Boolean;
      
      private var m_crops:Array;
      
      private var m_cards:Array;
      
      private var m_flowers:Array;
      
      private var m_flowerPath:String;
      
      private var m_myFlower:Array;
      
      private var m_fishs:Array;
      
      private var m_crystalDirty:Boolean;
      
      private var m_cropDirty:Boolean;
      
      private var m_seeds:Array;
      
      private var m_crystal:Array;
      
      private var m_flowerDirty:Boolean;
      
      private var m_sendFlowerID:int;
      
      private var _tempCards:Array;
      
      public function WarehouseModel(param1:IEventDispatcher = null)
      {
         super(param1);
         this.m_cropDirty = true;
         this.m_crystalDirty = true;
         this.m_seedDirty = true;
         this.m_flowerDirty = true;
         this.m_fishDirty = true;
         this.m_crops = null;
         this.m_flowers = null;
         this.m_seeds = null;
         this.m_cards = null;
         this.m_crystal = null;
         this.m_allFlower = null;
         this.m_myFlower = null;
         this.m_fishs = null;
         this.m_flowerPath = "";
         this.m_sendFlowerID = -1;
      }
      
      private function onLockSuccess(param1:CommandEvent) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:WarehouseCrop = null;
         var _loc6_:Object = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:* = _loc2_.m_extra;
         if(_loc3_["code"] == "1")
         {
            _loc4_ = false;
            _loc5_ = null;
            for each(_loc6_ in _loc3_["crop"])
            {
               _loc4_ = false;
               for each(_loc5_ in this.m_crops)
               {
                  if(_loc5_._id == _loc6_["cId"])
                  {
                     _loc5_._isLock = _loc6_["isLock"] == 1 ? 1 : 0;
                     _loc4_ = true;
                     break;
                  }
               }
               if(_loc4_ == false)
               {
                  for each(_loc5_ in this.m_flowers)
                  {
                     if(_loc5_._id == _loc6_["cId"])
                     {
                        _loc5_._isLock = _loc6_["isLock"] == 1 ? 1 : 0;
                        _loc4_ = true;
                        break;
                     }
                  }
               }
               if(_loc4_ == false)
               {
                  for each(_loc5_ in this.m_cards)
                  {
                     if(_loc5_._id == _loc6_["cId"])
                     {
                        _loc5_._isLock = _loc6_["isLock"] == 1 ? 1 : 0;
                        _loc4_ = true;
                        break;
                     }
                  }
               }
               if(_loc4_ == true)
               {
                  dispatchEvent(new CommonEvent(EVENT_UPDATELOCK_SUCCESS,_loc5_));
               }
            }
         }
         EventRecorder.recordSueecssEvent("160865",null);
      }
      
      private function onFishLockSuccess(param1:CommandEvent) : void
      {
         var _loc4_:WarehouseFish = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:* = _loc2_.m_extra;
         if(_loc3_["code"] == "1")
         {
            _loc4_ = null;
            for each(_loc4_ in this.m_fishs)
            {
               if(_loc4_._id == _loc3_["fid"])
               {
                  _loc4_._isLock = _loc3_["lock"] == 1 ? 1 : 0;
                  break;
               }
            }
            dispatchEvent(new CommonEvent(EVENT_UPDATEFISHLOCK_SUCCESS,_loc4_));
         }
         EventRecorder.recordSueecssEvent("160866",null);
      }
      
      private function onFishLockFail(param1:CommandEvent) : void
      {
         EventRecorder.recordErrorEvent("160866",null,4);
      }
      
      public function sendFlower(param1:String, param2:String, param3:Object) : void
      {
         if(param1 == "")
         {
            return;
         }
         if(param3 == null || param3["fId"] == undefined)
         {
            return;
         }
         var _loc4_:* = {
            "to":param1,
            "fId":param3["fId"],
            "w":param2
         };
         this.m_sendFlowerID = parseInt(param3["fId"]);
         NetHelper.sendRequest(CommandDefs.CMD_SEND_FLOWER,_loc4_,this.onFlowerSentSuccess,this.onTransactionFailed);
      }
      
      public function sellCrystal(param1:int, param2:int) : void
      {
         if(param1 < 0 || param2 < 0)
         {
            return;
         }
         var _loc3_:Object = {
            "id":param1,
            "num":param2
         };
         NetHelper.sendRequest(CommandDefs.CMD_SELL_CRYSTAL,_loc3_,this.onSellPlantSuccess,this.onTransactionFailed);
      }
      
      public function get flowers() : Array
      {
         return this.m_flowers;
      }
      
      private function onSellPlantSuccess(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_["num"] = param1.body["__body"]["number"];
         dispatchEvent(new CommonEvent(EVENT_SELLPLANT_SUCCESS,_loc2_));
         dispatchEvent(new EvtAPI(EvtAPI.REFRESH_CRYSTAL));
         this.recordResp(EventRecorder.HF_SELL_PLANT,true,"mod=repertory&act=sale");
      }
      
      public function removeSeed(param1:int, param2:int = 1) : Boolean
      {
         var _loc4_:WarehouseSeed = null;
         var _loc3_:int = 0;
         for each(_loc4_ in this.m_seeds)
         {
            if(_loc4_._id == param1)
            {
               _loc4_._amount -= param2;
               if(_loc4_._amount <= 0)
               {
                  this.m_seeds.splice(_loc3_,1);
                  dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
                     "index":1,
                     "data":this.m_seeds
                  }));
                  return true;
               }
               dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
                  "index":1,
                  "data":this.m_seeds
               }));
            }
            _loc3_++;
         }
         return false;
      }
      
      private function onLoadDataError(param1:CommandEvent) : void
      {
         var _loc5_:String = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = -1;
         if(param1.body != null && param1.body["cmdID"] != undefined)
         {
            if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_WAREHOUSE_CROPS)
            {
               _loc3_ = 0;
               QzoneJSAPI.reportError("仓库作物加载失败",2);
               this.recordResp(EventRecorder.HF_GET_WAREHOUSE_CROPS,false,"cgi_farm_getusercrop?f=1");
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_WAREHOUSE_SEEDS)
            {
               _loc3_ = 1;
               QzoneJSAPI.reportError("仓库种子加载失败",2);
               this.recordResp(EventRecorder.HF_GET_WAREHOUSE_SEEDS,false,"cgi_farm_seed_list");
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_GET_WAREHOUSE_CRYSTAL)
            {
               QzoneJSAPI.reportError("仓库材料加载失败",2);
               this.recordResp(EventRecorder.HF_GET_WAREHOUSE_CRYSTAL,false,"cgi_farm_get_usercrystal");
            }
            else if(param1.body["cmdId"] as int == CommandDefs.CMD_GET_WAREHOUSE_MYFLOWERS)
            {
               EventRecorder.recordErrorEvent("160867",null,4);
            }
         }
         if(_loc3_ != 0 || _loc3_ != 1)
         {
            return;
         }
         var _loc4_:String = _loc2_.m_extra["errorType"] as String;
         if(_loc4_ != "")
         {
            _loc5_ = Language.L["请求超时，"] + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>" + Language.L["点击重试"] + "</font></u></a>";
            dispatchEvent(new CommonEvent(EVENT_DATA_FAILED,{
               "index":_loc3_,
               "error":_loc5_
            }));
         }
      }
      
      public function get fishs() : Array
      {
         return this.m_fishs;
      }
      
      public function storeUserCropLockInfo(param1:WarehouseCrop, param2:Boolean) : void
      {
         if(param1 == null || param1._isLock == -1)
         {
            return;
         }
         var _loc3_:String = param1._id.toString() + ":" + (param2 ? "1" : "2");
         NetHelper.sendRequest(CommandDefs.CMD_UPDATE_LOCK,{"crop":_loc3_},this.onLockSuccess,this.onLockFail);
      }
      
      public function loadCrops() : void
      {
         if(this.m_cropDirty == true)
         {
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{
               "index":0,
               "show":true
            }));
            NetHelper.sendRequest(CommandDefs.CMD_GET_WAREHOUSE_CROPS,null,this.onCropsLoaded,this.onLoadDataError);
         }
      }
      
      private function onCrystalsLoaded(param1:CommandEvent) : void
      {
         var _loc3_:WarehouseCrop = null;
         var _loc4_:Object = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         WildData.reloadCrystal = false;
         this.m_crystal = [];
         for each(_loc4_ in _loc2_["info"])
         {
            _loc3_ = new WarehouseCrop(_loc4_);
            this.m_crystal.push(_loc3_);
         }
         if(!this._tempCards)
         {
            this._tempCards = [];
         }
         this.m_cards = this._tempCards.concat(this.m_crystal);
         dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
            "index":3,
            "show":true
         }));
         this.recordResp(EventRecorder.HF_GET_WAREHOUSE_CRYSTAL,true,"cgi_farm_get_usercrystal");
      }
      
      public function collectNotLockedIDs(param1:int) : Array
      {
         var _loc3_:WarehouseCrop = null;
         var _loc4_:WarehouseFish = null;
         var _loc2_:Array = [];
         if(param1 == Consts.WAREHOUSE_CROP)
         {
            for each(_loc3_ in this.m_crops)
            {
               if(_loc3_._id > 0 && _loc3_._isLock <= 0)
               {
                  _loc2_.push(_loc3_._id);
               }
            }
         }
         else if(param1 == Consts.WAREHOUSE_FLOWER)
         {
            for each(_loc3_ in this.m_flowers)
            {
               if(_loc3_._id > 0 && _loc3_._isLock <= 0)
               {
                  _loc2_.push(_loc3_._id);
               }
            }
         }
         else if(param1 == Consts.WAREHOUSE_FISH)
         {
            for each(_loc4_ in this.m_fishs)
            {
               if(_loc4_._id > 0 && _loc4_._isLock <= 0)
               {
                  _loc2_.push(_loc4_._id);
               }
            }
         }
         else
         {
            for each(_loc3_ in this.m_cards)
            {
               if(_loc3_._id > 0 && _loc3_._isLock <= 0)
               {
                  _loc2_.push(_loc3_._id);
               }
            }
         }
         return _loc2_;
      }
      
      private function onFishsLoaded(param1:CommandEvent) : void
      {
         var _loc4_:WarehouseFish = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_fishDirty = false;
         dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{
            "index":5,
            "show":false
         }));
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
               _loc4_._name = _loc3_["crop_name"];
               _loc4_._sale = _loc3_["sale"];
            }
         }
         dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
            "index":5,
            "data":this.m_fishs
         }));
      }
      
      private function onTransactionFailed(param1:CommandEvent) : void
      {
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null || _loc2_.m_message == "")
         {
            dispatchEvent(new CommonEvent(EVENT_NET_TRANSACTION_ERROR,{"error":Language.L["请求超时，稍后再试"]}));
         }
         else
         {
            dispatchEvent(new CommonEvent(EVENT_NET_TRANSACTION_ERROR,{"error":_loc2_.m_message}));
         }
         if(param1.body != null && param1.body["cmdID"] != undefined)
         {
            if(param1.body["cmdID"] as int == CommandDefs.CMD_SELL_ALL_PLANTS)
            {
               this.recordResp(EventRecorder.HF_SELL_ALL_PLANTS,false,"mod=repertory&act=saleAll");
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_SELL_PLANT)
            {
               this.recordResp(EventRecorder.HF_SELL_PLANT,false,"mod=repertory&act=sale");
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_SEND_FLOWER)
            {
               EventRecorder.recordErrorEvent("160868",null,4);
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_SELL_ALL_SEEDS)
            {
               EventRecorder.recordErrorEvent("160869",null,4);
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_SELL_WAREHOUSE_FISH)
            {
               EventRecorder.recordErrorEvent("160870",null,4);
            }
            else if(param1.body["cmdID"] as int == CommandDefs.CMD_SELL_SEED)
            {
               EventRecorder.recordErrorEvent("160871",null,4);
            }
         }
      }
      
      public function get myFlowers() : Array
      {
         return this.m_myFlower;
      }
      
      private function sort(param1:*, param2:*) : int
      {
         if(param1._lvl == param2._lvl)
         {
            return param1._id >= param2._id ? 1 : -1;
         }
         return param1._lvl >= param2._lvl ? 1 : -1;
      }
      
      private function onLockFail(param1:CommandEvent) : void
      {
         EventRecorder.recordErrorEvent("160865",null,4);
      }
      
      public function get flowerPath() : String
      {
         return this.m_flowerPath;
      }
      
      private function onSellAllSeedsSuccess(param1:CommandEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == 1)
         {
            _loc3_ = Language.replaceText("saleAllFnText2",{"money":_loc2_["money"]});
            _loc2_["direction"] = _loc3_;
            dispatchEvent(new CommonEvent(EVENT_SELLALLSEEDS_SUCCESS,_loc2_));
            EventRecorder.recordSueecssEvent("160869",null);
         }
      }
      
      public function set fishDirty(param1:Boolean) : void
      {
         this.m_fishDirty = param1;
      }
      
      public function set flowers(param1:Array) : void
      {
         this.m_flowers = param1;
      }
      
      public function sellPlant(param1:int, param2:int) : void
      {
         if(param1 < 0 || param2 < 0)
         {
            return;
         }
         var _loc3_:Object = {
            "cId":param1,
            "number":param2,
            "hw":1
         };
         _loc3_["onlineTime"] = QzoneJSAPI.getOnlineTime(Settings.getInstance().mode);
         NetHelper.sendRequest(CommandDefs.CMD_SELL_PLANT,_loc3_,this.onSellPlantSuccess,this.onTransactionFailed);
      }
      
      public function get cropDirty() : Boolean
      {
         return this.m_cropDirty;
      }
      
      private function getFlowerCount(param1:int) : int
      {
         var _loc2_:WarehouseCrop = null;
         for each(_loc2_ in this.m_flowers)
         {
            if(_loc2_._id == param1)
            {
               return _loc2_._amount;
            }
         }
         return 0;
      }
      
      private function onSellSeedSuccess(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == 1)
         {
            dispatchEvent(new CommonEvent(EVENT_SELLSEED_SUCCESS,_loc2_));
            EventRecorder.recordSueecssEvent("160871",null);
         }
      }
      
      public function set seedDirty(param1:Boolean) : void
      {
         this.m_seedDirty = param1;
      }
      
      public function isEmpty(param1:int) : Boolean
      {
         if(param1 == 0 || param1 == 1)
         {
            return this.m_crops == null || this.m_crops.length == 0 ? true : false;
         }
         if(param1 == 2)
         {
            return this.m_seeds == null || this.m_seeds.length == 0 ? true : false;
         }
         return this.m_cards == null || this.m_cards.length == 0 ? true : false;
      }
      
      public function set cropDirty(param1:Boolean) : void
      {
         this.m_cropDirty = param1;
      }
      
      public function removeMyFlower(param1:Object) : void
      {
         var _loc3_:* = undefined;
         if(param1 == null || param1["fId"] == undefined)
         {
            return;
         }
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_myFlower)
         {
            if(_loc3_["fId"] == param1["fId"])
            {
               this.m_myFlower.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
         dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
            "index":2,
            "data":this.m_myFlower
         }));
      }
      
      public function get seeds() : Array
      {
         return this.m_seeds;
      }
      
      public function sellFish(param1:int, param2:int) : void
      {
         var _loc3_:String = Session.getInstance().hostId;
         var _loc4_:Object = {
            "fIds":param1,
            "num":param2,
            "flag":"single"
         };
         NetHelper.sendRequest(CommandDefs.CMD_SELL_WAREHOUSE_FISH,_loc4_,this.onSellFishSuccess,this.onTransactionFailed);
      }
      
      private function onSellAllSuccess(param1:CommandEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["errorType"] != undefined)
         {
            _loc3_ = _loc2_["errorType"];
            if(_loc3_ == "IOError" || _loc3_ == "httpStatus" || _loc3_ == "timeOut" || _loc3_ == "PHPError")
            {
               dispatchEvent(new CommonEvent(EVENT_NET_TRANSACTION_ERROR,{"error":Language.L["请求超时，稍后再试"]}));
               return;
            }
         }
         else if(_loc2_["code"] == 1)
         {
            dispatchEvent(new CommonEvent(EVENT_SELLALL_SUCCESS,_loc2_));
            this.recordResp(EventRecorder.HF_SELL_ALL_PLANTS,true,"mod=repertory&act=saleAll");
         }
         else if(_loc2_.hasOwnProperty("direction") && _loc2_["direction"] != "")
         {
            dispatchEvent(new CommonEvent(EVENT_NET_TRANSACTION_ERROR,{"error":_loc2_["direction"]}));
         }
      }
      
      public function loadFishs() : void
      {
         if(this.m_fishDirty == true)
         {
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{
               "index":5,
               "show":true
            }));
            NetHelper.sendRequest(CommandDefs.CMD_GET_WAREHOUSE_FISH,null,this.onFishsLoaded,this.onLoadDataError);
         }
      }
      
      private function onFlowerSentSuccess(param1:CommandEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:uint = 0;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:WarehouseCrop = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == 1)
         {
            _loc3_ = null;
            for each(_loc4_ in this.m_allFlower)
            {
               if(_loc4_["fId"] == this.m_sendFlowerID)
               {
                  _loc3_ = _loc4_;
                  break;
               }
            }
            if(_loc3_ != null)
            {
               _loc5_ = this.m_flowers.length;
               for each(_loc6_ in _loc3_["need"])
               {
                  _loc7_ = 0;
                  while(_loc7_ < _loc5_)
                  {
                     _loc8_ = this.m_flowers[_loc7_];
                     if(_loc8_._id == _loc6_["cId"])
                     {
                        _loc8_._amount -= parseInt(_loc6_["amount"]);
                        if(_loc8_._amount <= 0)
                        {
                           this.m_flowers.splice(_loc7_,1);
                        }
                        break;
                     }
                     _loc7_++;
                  }
               }
               dispatchEvent(new CommonEvent(EVENT_SENDFLOWER_SUCCESS,{
                  "msg":_loc2_["direction"],
                  "data":this.m_flowers
               }));
            }
            EventRecorder.recordSueecssEvent("160868",null);
         }
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
      
      public function get fishDirty() : Boolean
      {
         return this.m_fishDirty;
      }
      
      private function onSellAllFishSuccess(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == 1)
         {
            dispatchEvent(new CommonEvent(EVENT_SELLALLFISHS_SUCCESS,_loc2_));
            EventRecorder.recordSueecssEvent("160870",null);
         }
      }
      
      public function loadSeeds() : void
      {
         if(this.m_seedDirty == true)
         {
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{
               "index":1,
               "show":true
            }));
            NetHelper.sendRequest(CommandDefs.CMD_GET_WAREHOUSE_SEEDS,null,this.onSeedsLoaded,this.onLoadDataError);
         }
      }
      
      public function storeUserFishLockInfo(param1:WarehouseFish, param2:Boolean) : void
      {
         if(param1 == null || param1._isLock == -1)
         {
            return;
         }
         var _loc3_:String = param2 ? "lock" : "unlock";
         NetHelper.sendRequest(CommandDefs.CMD_UPDATE_FISH_LOCK,{
            "fId":param1._id,
            "flag":_loc3_
         },this.onFishLockSuccess,this.onFishLockFail);
      }
      
      public function get seedDirty() : Boolean
      {
         return this.m_seedDirty;
      }
      
      public function sellSeed(param1:int, param2:int) : void
      {
         if(param1 < 0 || param2 < 0)
         {
            return;
         }
         var _loc3_:Object = {
            "cId":param1,
            "number":param2
         };
         _loc3_["onlineTime"] = QzoneJSAPI.getOnlineTime(Settings.getInstance().mode);
         NetHelper.sendRequest(CommandDefs.CMD_SELL_SEED,_loc3_,this.onSellSeedSuccess,this.onTransactionFailed);
      }
      
      public function loadMyFlowers() : void
      {
         if(this.m_flowerDirty == true)
         {
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{
               "index":2,
               "show":true
            }));
            NetHelper.sendRequest(CommandDefs.CMD_GET_WAREHOUSE_MYFLOWERS,null,this.onMyFlowersLoaded,this.onLoadDataError);
         }
      }
      
      public function sellAllFish(param1:int) : void
      {
         var _loc2_:String = Session.getInstance().hostId;
         var _loc3_:Array = this.collectNotLockedIDs(param1);
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return;
         }
         var _loc4_:Object = {"fIds":_loc3_.join(",")};
         NetHelper.sendRequest(CommandDefs.CMD_SELL_WAREHOUSE_FISH,_loc4_,this.onSellAllFishSuccess,this.onTransactionFailed);
      }
      
      private function onSeedsLoaded(param1:CommandEvent) : void
      {
         var _loc4_:WarehouseSeed = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_seedDirty = false;
         dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{
            "index":1,
            "show":false
         }));
         if(this.m_seeds == null)
         {
            this.m_seeds = new Array();
         }
         else
         {
            this.m_seeds.splice(0);
         }
         this.m_seeds = this.m_seeds.concat(_loc2_);
         this.m_seeds.sort(this.sort);
         var _loc3_:Object = null;
         for each(_loc4_ in this.m_seeds)
         {
            _loc3_ = Settings.getInstance().getCropByID(_loc4_._id.toString());
            if(_loc3_ != null)
            {
               if(_loc4_._isVip == -1 && _loc3_["isVIP"] != undefined)
               {
                  _loc4_._isVip = _loc3_["isVIP"] == 1 ? 1 : 0;
               }
            }
         }
         dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
            "index":1,
            "data":this.m_seeds
         }));
         this.recordResp(EventRecorder.HF_GET_WAREHOUSE_SEEDS,true,"cgi_farm_seed_list");
      }
      
      public function onCropsLoaded(param1:CommandEvent) : void
      {
         var _loc8_:WarehouseCrop = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_cropDirty = false;
         dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{
            "index":0,
            "show":false
         }));
         if(_loc2_["flowerPath"] != undefined)
         {
            this.m_flowerPath = _loc2_["flowerPath"];
         }
         var _loc3_:Array = new Array();
         if(_loc2_["crops"] != undefined)
         {
            _loc3_ = _loc3_.concat(_loc2_["crops"]);
         }
         var _loc4_:Array = null;
         var _loc5_:String = Settings.getInstance().getStringAttribute("crops_sort");
         if(_loc5_ != "")
         {
            _loc4_ = _loc5_.split(",");
         }
         var _loc6_:Object = null;
         var _loc7_:IPluginProxy = PluginManager.getInstance().getPluginByID(3);
         for each(_loc8_ in _loc3_)
         {
            if(_loc4_ != null)
            {
               _loc8_._sort = _loc4_.indexOf(_loc8_._id.toString());
            }
            _loc6_ = Settings.getInstance().getCropByID(_loc8_._id.toString());
            if(_loc6_ != null)
            {
               if(_loc8_._isFlower == -1 && _loc6_["isFlower"] != undefined)
               {
                  _loc8_._isFlower = _loc6_["isFlower"] == 1 ? 1 : 0;
               }
               if(_loc8_._isLock <= 0 && _loc6_["isLock"] != undefined)
               {
                  _loc8_._isLock = _loc6_["isLock"] == 1 ? 1 : 0;
               }
               if(_loc8_._isLock == 2)
               {
                  _loc8_._isLock = 0;
               }
               if(_loc8_._isFood == -1 && _loc6_["isFood"] != undefined)
               {
                  _loc8_._isFood = _loc6_["isFood"] == 1 ? 1 : 0;
               }
               if(_loc8_._isVip == -1 && _loc6_["isVIP"] != undefined)
               {
                  _loc8_._isVip = _loc6_["isVIP"] == 1 ? 1 : 0;
               }
            }
            if(_loc7_ != null)
            {
               _loc7_.executeCommand(2002,_loc8_);
            }
         }
         _loc3_.sort(this.sort);
         this.seperateFlowers(_loc3_);
         this.processAllFlowers(_loc2_);
         dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{"index":0}));
         this.recordResp(EventRecorder.HF_GET_WAREHOUSE_CROPS,true,"cgi_farm_getusercrop?f=1");
      }
      
      public function get crops() : Array
      {
         return this.m_crops;
      }
      
      private function processAllFlowers(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param1 == null || param1["allFlower"] == undefined || param1["flowerPath"] == undefined)
         {
            return;
         }
         var _loc2_:String = param1["flowerPath"] as String;
         if(_loc2_ == "")
         {
            return;
         }
         for each(_loc3_ in param1.allFlower)
         {
            _loc4_ = 0;
            for each(_loc5_ in _loc3_.need)
            {
               _loc5_["cName"] = GetCropID.getNameByIDType(Consts.ITEM_TYPE_SEED,_loc5_["cId"]);
               _loc6_ = this.getFlowerCount(_loc5_["cId"]);
               _loc7_ = _loc6_ >= _loc5_["amount"] ? 0 : int(_loc5_["amount"] - _loc6_);
               _loc5_["lack"] = _loc7_;
               _loc4_ += _loc7_;
            }
            _loc3_["pic"] = _loc2_ + "/" + _loc3_["fId"] + ".gif";
            _loc3_["swf"] = _loc2_ + "/" + _loc3_["fId"] + ".swf";
            _loc3_["canMake"] = _loc4_ == 0;
         }
         this.m_allFlower = param1["allFlower"];
      }
      
      public function sellAll(param1:int) : void
      {
         var _loc2_:String = Session.getInstance().hostId;
         var _loc3_:Array = this.collectNotLockedIDs(param1);
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return;
         }
         var _loc4_:Object = {
            "uId":_loc2_,
            "cIds":_loc3_.join(","),
            "hw":1,
            "onlineTime":QzoneJSAPI.getOnlineTime(Settings.getInstance().mode)
         };
         NetHelper.sendRequest(CommandDefs.CMD_SELL_ALL_PLANTS,_loc4_,this.onSellAllSuccess,this.onTransactionFailed);
      }
      
      public function sellAllSeeds() : void
      {
         var _loc2_:WarehouseSeed = null;
         var _loc3_:Object = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this.m_seeds)
         {
            _loc1_.push(_loc2_._id);
         }
         _loc3_ = {"cIds":_loc1_.join(",")};
         NetHelper.sendRequest(CommandDefs.CMD_SELL_ALL_SEEDS,_loc3_,this.onSellAllSeedsSuccess,this.onTransactionFailed);
      }
      
      public function get allFlower() : Array
      {
         return this.m_allFlower;
      }
      
      public function loadCrystal() : void
      {
         if(this.m_crystalDirty == true)
         {
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{
               "index":3,
               "show":true
            }));
            NetHelper.sendRequest(CommandDefs.CMD_GET_WAREHOUSE_CRYSTAL,{"type":9},this.onCrystalsLoaded,this.onLoadDataError);
         }
      }
      
      private function onMyFlowersLoaded(param1:CommandEvent) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_flowerDirty = false;
         dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{
            "index":2,
            "show":false
         }));
         if(_loc2_["myFlower"] == undefined || _loc2_["flowerPath"] == undefined)
         {
            return;
         }
         if(this.m_myFlower == null)
         {
            this.m_myFlower = new Array();
         }
         else
         {
            this.m_myFlower.splice(0);
         }
         this.m_myFlower = this.m_myFlower.concat(_loc2_["myFlower"]);
         for each(_loc3_ in this.m_myFlower)
         {
            _loc3_["pic"] = _loc2_["flowerPath"] + "/" + _loc3_["fId"] + ".gif";
         }
         dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
            "index":2,
            "data":this.m_myFlower
         }));
         EventRecorder.recordSueecssEvent("160867",null);
      }
      
      private function onSellFishSuccess(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == 1)
         {
            dispatchEvent(new CommonEvent(EVENT_SELLFISH_SUCCESS,_loc2_));
            EventRecorder.recordSueecssEvent("160870",null);
         }
      }
      
      public function get cards() : Array
      {
         return this.m_cards;
      }
      
      private function seperateFlowers(param1:Array) : void
      {
         var isFlower:Function = null;
         var isCrop:Function = null;
         var isCard:Function = null;
         var arr:Array = param1;
         isFlower = function(param1:WarehouseCrop, param2:int, param3:Array):Boolean
         {
            return param1._isFlower == 1;
         };
         isCrop = function(param1:WarehouseCrop, param2:int, param3:Array):Boolean
         {
            return param1._isFlower <= 0 && param1._type != 11;
         };
         isCard = function(param1:WarehouseCrop, param2:int, param3:Array):Boolean
         {
            return param1._type == 11;
         };
         if(arr == null)
         {
            return;
         }
         if(arr.length == 0)
         {
            this.m_flowers = [];
            this.m_crops = [];
            this.m_cards = [];
            return;
         }
         this.m_flowers = arr.filter(isFlower);
         this.m_crops = arr.filter(isCrop);
         this.m_cards = arr.filter(isCard);
         this._tempCards = this.m_cards;
         if(!this.m_crystal)
         {
            this.m_crystal = [];
         }
         this.m_cards = this._tempCards.concat(this.m_crystal);
      }
   }
}

