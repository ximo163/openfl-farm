package mc.model
{
   import flash.events.EventDispatcher;
   
   public final class TinItemsData extends EventDispatcher
   {
      
      public static const LOAD_TINS_ERROR:String = "Load_failed";
      
      public static const LOAD_TINS_SUCCESS:String = "Load_success";
      
      public static const LOAD_STATUS_CHANGED:String = "Load_status_changed";
      
      private var m_shopTinInfoErr:String;
      
      private var m_tins:Array;
      
      private var m_loadingData:Boolean;
      
      public function TinItemsData()
      {
         super();
         this.m_tins = [];
         this.m_shopTinInfoErr = "";
         this.m_loadingData = false;
      }
      
      public function get allTinItems() : Array
      {
         var _loc1_:Array = this.m_tins.concat();
         _loc1_.sortOn("o",Array.NUMERIC);
         var _loc2_:Array = _loc1_.splice(-4,4);
         return _loc2_.concat(_loc1_);
      }
      
      public function get loadingData() : Boolean
      {
         return this.m_loadingData;
      }
      
      public function set loadingData(param1:Boolean) : void
      {
         this.m_loadingData = param1;
         dispatchEvent(new ModelEvent(LOAD_STATUS_CHANGED));
      }
      
      public function set shopTinInfoErr(param1:String) : void
      {
         this.m_shopTinInfoErr = param1;
         dispatchEvent(new ModelEvent(LOAD_TINS_ERROR));
      }
      
      public function addTinItems(param1:Array) : void
      {
         var _loc3_:* = undefined;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         if(param1 == null || param1.length == 0)
         {
            this.m_tins = [];
            dispatchEvent(new ModelEvent(LOAD_TINS_SUCCESS));
            return;
         }
         this.m_tins = [];
         var _loc2_:* = null;
         for each(_loc3_ in param1)
         {
            if(!(_loc3_["id"] == undefined || _loc3_["type"] == undefined))
            {
               _loc2_ = {};
               _loc2_["id"] = _loc3_["id"];
               _loc2_["d"] = _loc3_["description"];
               _loc2_["t"] = _loc3_["type"];
               _loc2_["e"] = _loc3_["effect"];
               _loc2_["n"] = _loc3_["name"];
               _loc2_["l"] = _loc3_["left"];
               _loc2_["p"] = _loc3_["price"];
               _loc2_["qd"] = _loc3_["qdprice"];
               _loc2_["y"] = _loc3_["yqdprice"];
               _loc2_["o"] = _loc3_["order"];
               _loc2_["lt"] = _loc3_["limittips"];
               _loc2_["tips"] = _loc3_["tips"];
               _loc2_["appid"] = _loc3_["appid"];
               _loc2_["shortage"] = _loc3_["shortage"];
               _loc4_ = [];
               if(_loc3_.hasOwnProperty("setprice"))
               {
                  _loc6_ = _loc3_["setprice"].split(";");
                  _loc5_ = 0;
                  while(_loc5_ < _loc6_.length)
                  {
                     if(_loc6_[_loc5_] != "")
                     {
                        _loc7_ = _loc6_[_loc5_].split("-");
                        _loc4_.push({
                           "month":_loc7_[0],
                           "money":_loc7_[1]
                        });
                     }
                     _loc5_++;
                  }
                  _loc2_["setprice"] = _loc4_;
               }
               if(_loc3_.hasOwnProperty("ysetprice"))
               {
                  _loc4_ = [];
                  _loc6_ = [];
                  _loc6_ = _loc3_["ysetprice"].split(";");
                  _loc5_ = 0;
                  while(_loc5_ < _loc6_.length)
                  {
                     if(_loc6_[_loc5_] != "")
                     {
                        _loc7_ = _loc6_[_loc5_].split("-");
                        _loc4_.push({
                           "month":_loc7_[0],
                           "money":_loc7_[1]
                        });
                     }
                     _loc5_++;
                  }
                  _loc2_["ysetprice"] = _loc4_;
               }
               this.m_tins.push(_loc2_);
            }
         }
         dispatchEvent(new ModelEvent(LOAD_TINS_SUCCESS));
      }
      
      public function get shopTinInfoErr() : String
      {
         return this.m_shopTinInfoErr;
      }
   }
}

