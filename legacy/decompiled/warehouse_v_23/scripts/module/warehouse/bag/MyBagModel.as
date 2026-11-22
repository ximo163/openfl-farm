package module.warehouse.bag
{
   import com.qzone.qfa.debug.Debugger;
   import com.qzone.qfa.events.CommandEvent;
   import common.Consts;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import entities.BagItem;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.vo.ServiceResultVO;
   import report.EventRecorder;
   
   public class MyBagModel extends EventDispatcher
   {
      
      internal static const EVENT_INITIALZED:String = "DataInitialized";
      
      internal static const EVENT_LOAD_FAILED:String = "LoadFailed";
      
      internal static const EVENT_LOADING:String = "LoadingProcess";
      
      internal static const EVENT_UPDATED:String = "DataUpdated";
      
      private var m_bDirty:Boolean;
      
      private var m_items:Array;
      
      public function MyBagModel()
      {
         super();
         this.m_items = null;
         this.m_bDirty = true;
      }
      
      public function getItem(param1:int, param2:int) : BagItem
      {
         var _loc3_:BagItem = null;
         for each(_loc3_ in this.m_items)
         {
            if(_loc3_._cId == param1 && _loc3_._type == param2)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function set dirty(param1:Boolean) : void
      {
         this.m_bDirty = param1;
      }
      
      private function onGetMyBagDataFailed(param1:CommandEvent) : void
      {
         dispatchEvent(new CommonEvent(EVENT_LOADING,false));
         dispatchEvent(new CommonEvent(EVENT_LOAD_FAILED,null));
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ != null && _loc2_.m_message != "")
         {
            Debugger.log("[MyBag] get data failed: " + _loc2_.m_message);
         }
         QzoneJSAPI.reportError("背包物品加载失败",2);
         EventRecorder.recordErrorEvent(EventRecorder.HF_GET_BAG_DATA,null,EventRecorder.FAULT_ERROR,"cgi_farm_getuserseed");
      }
      
      public function get empty() : Boolean
      {
         if(this.m_items == null || this.m_items.length == 0)
         {
            return true;
         }
         return false;
      }
      
      private function cropSort(param1:BagItem, param2:BagItem) : int
      {
         if(int(param1._sort) < int(param2._sort))
         {
            return -1;
         }
         return 1;
      }
      
      private function onGetMyBagData(param1:CommandEvent) : void
      {
         var _loc5_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Array = null;
         var _loc2_:* = NetHelper.getVOData(param1);
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
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         if(_loc2_ is Array)
         {
            _loc5_ = int((_loc2_ as Array).length);
            _loc9_ = 0;
            while(_loc9_ < _loc5_)
            {
               if(_loc2_[_loc9_]["_type"] == 1)
               {
                  _loc3_.push(_loc2_[_loc9_]);
               }
               else
               {
                  _loc4_.push(_loc2_[_loc9_]);
               }
               _loc9_++;
            }
         }
         this.m_items = this.m_items.concat(_loc4_);
         var _loc6_:String = Settings.getInstance().getStringAttribute("crops_sort");
         var _loc7_:BagItem = null;
         if(_loc6_ != "")
         {
            _loc10_ = _loc6_.split(",");
            for each(_loc7_ in this.m_items)
            {
               if(_loc7_._cId != 0)
               {
                  _loc7_._sort = _loc10_.indexOf(_loc7_._cId.toString());
               }
               else
               {
                  _loc7_._sort = 99;
               }
            }
            this.m_items.sort(this.cropSort);
         }
         _loc3_.sortOn("_cId",Array.NUMERIC | Array.DESCENDING);
         this.m_items = _loc3_.concat(this.m_items);
         _loc3_ = null;
         _loc4_ = null;
         var _loc8_:Object = null;
         for each(_loc7_ in this.m_items)
         {
            if(_loc7_._type.toString() == Consts.ITEM_TYPE_FISH)
            {
               _loc8_ = Settings.getInstance().getFishByID(_loc7_._cId.toString());
               if(_loc8_ != null)
               {
                  _loc7_._name = _loc8_["crop_name"];
                  _loc7_._lifeCycle = _loc8_["mature"];
               }
            }
         }
         this.dirty = false;
         dispatchEvent(new CommonEvent(EVENT_INITIALZED,this.m_items));
         EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_BAG_DATA,null,"cgi_farm_getuserseed");
      }
      
      public function get dirty() : Boolean
      {
         return this.m_bDirty;
      }
      
      private function fishFoodSort(param1:BagItem, param2:BagItem) : int
      {
         if(param1._type.toString() == Consts.ITEM_TYPE_FISHFEED)
         {
            return param1._cId < param2._cId ? -1 : 1;
         }
         return 1;
      }
      
      public function fillterType(param1:String = "normal") : Array
      {
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:BagItem = null;
         var _loc2_:Array = [];
         if(this.empty)
         {
            return _loc2_;
         }
         var _loc3_:Array = [];
         var _loc4_:Number = 0;
         while(this.m_items[_loc4_])
         {
            _loc5_ = this.m_items[_loc4_];
            if(param1 == "normal" && _loc5_._type == Consts.ITEM_TYPE_SEED)
            {
               _loc2_.push(_loc5_);
            }
            else if(param1 == "fish" && _loc5_._type == Consts.ITEM_TYPE_FISH)
            {
               _loc2_.push(_loc5_);
            }
            else if(param1 == "tool" && _loc5_._type != Consts.ITEM_TYPE_SEED && _loc5_._type != Consts.ITEM_TYPE_FISH)
            {
               if(_loc5_._type == Consts.ITEM_TYPE_FISHFEED)
               {
                  _loc3_.push(_loc5_);
               }
               else
               {
                  _loc2_.push(_loc5_);
               }
            }
            _loc4_++;
         }
         if(param1 == "tool" && _loc3_.length > 0)
         {
            _loc6_ = 0;
            _loc7_ = false;
            for each(_loc8_ in _loc2_)
            {
               if(_loc8_._type.toString() == Consts.ITEM_TYPE_WEAPON)
               {
                  while(_loc3_.length > 0)
                  {
                     _loc2_.splice(_loc6_,0,_loc3_.pop());
                  }
                  _loc7_ = true;
                  break;
               }
               _loc6_++;
            }
            if(_loc7_ == false)
            {
               _loc2_ = _loc2_.concat(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function reload() : void
      {
         if(this.m_items != null && this.m_bDirty == false)
         {
            return;
         }
         NetHelper.sendRequest(CommandDefs.CMD_GET_BAG_DATA,null,this.onGetMyBagData,this.onGetMyBagDataFailed);
         dispatchEvent(new CommonEvent(EVENT_LOADING,true));
      }
      
      public function deleteItem(param1:int, param2:int) : void
      {
         var _loc3_:BagItem = null;
         var _loc4_:int = 0;
         for each(_loc3_ in this.m_items)
         {
            if(_loc3_._cId == param1 && _loc3_._type == param2)
            {
               _loc4_ = this.m_items.indexOf(_loc3_);
               this.m_items.splice(_loc4_,1);
               return;
            }
         }
      }
   }
}

