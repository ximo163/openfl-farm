package plugins.external.promotions
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.farm.api.interfaces.IPluginProxy;
   import com.qzone.sns.entities.Payment;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import framework.api.PluginManager;
   
   public class PromotionsModel extends EventDispatcher
   {
      
      internal static const CMD_INIT:uint = 13001;
      
      internal static const DATA_INITIALIZED1:String = "DataLoaded1";
      
      internal static const DATA_INITIALIZED2:String = "DataLoaded2";
      
      public static const CLICK_REPORT_CODE:String = "160646";
      
      public static const REPORT_VALUE1:String = "11";
      
      public static const REPORT_VALUE2:String = "12";
      
      public static const REPORT_VALUE3:String = "13";
      
      public static const REPORT_VALUE4:String = "14";
      
      public static const REPORT_VALUE5:String = "15";
      
      public static const REPORT_VALUE6:String = "16";
      
      internal static const NORMAL_PACK_TYPE:int = 1;
      
      internal static const ADV_PACK_TYPE:int = 2;
      
      private var _packDataCollection:Array = new Array();
      
      private var _dataInitialized1:Boolean;
      
      public var decorName:String = "";
      
      private var _dataInitialized2:Boolean;
      
      private var _api:IFarmAPI;
      
      private var _config:Object;
      
      private var _requestPending:Boolean;
      
      public var showTipsFlag:Boolean = true;
      
      public function PromotionsModel(param1:IFarmAPI, param2:Object)
      {
         super(null);
         this._api = param1;
         this._config = param2;
         this._dataInitialized1 = false;
         this._dataInitialized2 = false;
         this._requestPending = false;
         this.decorName = this._config.decorName;
         this._packDataCollection = new Array();
         var _loc3_:Settings = Settings.getInstance();
         var _loc4_:String = _loc3_.mode;
         if(_loc4_ == "qplus")
         {
            _loc4_ = "qzone";
         }
         if(param1)
         {
            this._api.registerNetCommand(CMD_INIT,"" + _loc4_ + "mod=cgi_farm_discount_list",null);
         }
      }
      
      public function getYellowPromotionsData() : Boolean
      {
         var params:Object;
         var onSuccess:Function = null;
         onSuccess = function(param1:int, param2:*):void
         {
            _requestPending = false;
            _dataInitialized2 = true;
            parserRawData(param2.list,true);
            dispatchEvent(new CommonEvent(DATA_INITIALIZED2,null));
         };
         if(this._requestPending)
         {
            return false;
         }
         if(this._dataInitialized2)
         {
            return true;
         }
         this._requestPending = true;
         params = new Object();
         params.yellow = 1;
         this._api.sendRequest(CMD_INIT,params,onSuccess,this.onNetError);
         return false;
      }
      
      public function getAdvPackData(param1:Boolean) : PromotionsPackData
      {
         var _loc2_:PromotionsPackData = null;
         var _loc3_:PromotionsPackData = null;
         for each(_loc2_ in this._packDataCollection)
         {
            if(_loc2_.type == ADV_PACK_TYPE && _loc2_.isYellow == param1)
            {
               return _loc2_;
            }
         }
         _loc3_ = new PromotionsPackData();
         _loc3_.item = [];
         _loc3_.type = ADV_PACK_TYPE;
         _loc3_.isYellow = param1;
         return _loc3_;
      }
      
      public function parserRawData(param1:Array, param2:Boolean) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:PromotionsPackData = null;
         var _loc6_:int = 0;
         var _loc3_:Array = param1 || [];
         if(_loc3_.length >= 0)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc5_ = new PromotionsPackData();
               _loc5_.isYellow = param2;
               _loc5_.item = _loc3_[_loc4_].item;
               _loc6_ = 0;
               while(_loc6_ < _loc5_.item.length)
               {
                  _loc5_.item[_loc6_].type = parseInt(Session.getInstance().transType(_loc5_.item[_loc6_].type));
                  _loc6_++;
               }
               _loc5_.f_price = _loc3_[_loc4_].f_price;
               _loc5_.pack_id = _loc3_[_loc4_].pack_id;
               _loc5_.price = _loc3_[_loc4_].price;
               _loc5_.s_price = _loc3_[_loc4_].s_price;
               _loc5_.type = parseInt(Session.getInstance().transType(_loc3_[_loc4_].type));
               this._packDataCollection.push(_loc5_);
               _loc4_++;
            }
         }
         return this._packDataCollection;
      }
      
      public function getNormalPackData(param1:Boolean) : PromotionsPackData
      {
         var _loc2_:PromotionsPackData = null;
         var _loc3_:PromotionsPackData = null;
         for each(_loc2_ in this._packDataCollection)
         {
            if(_loc2_.type == NORMAL_PACK_TYPE && _loc2_.isYellow == param1)
            {
               return _loc2_;
            }
         }
         _loc3_ = new PromotionsPackData();
         _loc3_.item = [];
         _loc3_.type = NORMAL_PACK_TYPE;
         _loc3_.isYellow = param1;
         return _loc3_;
      }
      
      private function onNetError(param1:int, param2:*) : void
      {
         this._requestPending = false;
         var _loc3_:String = "促销礼包";
         if(param1 == CMD_INIT)
         {
            this._api.alert(2,_loc3_,"加载促销礼包数据失败，请稍后再试。",0,0,null);
         }
      }
      
      public function get dataInitialized1() : Boolean
      {
         return this._dataInitialized1;
      }
      
      public function getPromotionsData() : Boolean
      {
         var params:Object;
         var onSuccess:Function = null;
         onSuccess = function(param1:int, param2:*):void
         {
            _requestPending = false;
            _dataInitialized1 = true;
            parserRawData(param2.list,false);
            dispatchEvent(new CommonEvent(DATA_INITIALIZED1,null));
         };
         if(this._requestPending)
         {
            return false;
         }
         if(this._dataInitialized1)
         {
            return true;
         }
         this._requestPending = true;
         params = new Object();
         params.yellow = 0;
         this._api.sendRequest(CMD_INIT,params,onSuccess,this.onNetError);
         return false;
      }
      
      public function get dataInitialized2() : Boolean
      {
         return this._dataInitialized2;
      }
      
      public function IsMeVip() : Boolean
      {
         return Session.getInstance().isMeVIP;
      }
      
      public function buyPack(param1:PromotionsPackData) : Boolean
      {
         var buyResult:Function = null;
         var packData:PromotionsPackData = param1;
         buyResult = function(param1:int, param2:Boolean, param3:Payment, param4:*):void
         {
            var _loc5_:Boolean = false;
            var _loc6_:int = 0;
            var _loc7_:Object = null;
            var _loc8_:IPluginProxy = null;
            if(param1 == 1 && param2 == true)
            {
               Session.getInstance().addReward(packData.item);
               _loc5_ = false;
               _loc6_ = -1;
               for each(_loc7_ in packData.item)
               {
                  if(_loc7_.type == Consts.ITEM_TYPE_FAIRY)
                  {
                     _loc5_ = true;
                     _loc6_ = int(_loc7_.id);
                  }
               }
               if(_loc5_)
               {
                  _loc8_ = PluginManager.getInstance().getPluginByID(2);
                  if(_loc8_ != null)
                  {
                     _loc8_.executeCommand(2103,{
                        "id":_loc6_,
                        "lv":1,
                        "rate":5,
                        "time":60 * 60 * 24
                     });
                  }
               }
            }
         };
         this._api.payByPlatform(packData.pack_id,18,1,18,buyResult);
         return true;
      }
   }
}

