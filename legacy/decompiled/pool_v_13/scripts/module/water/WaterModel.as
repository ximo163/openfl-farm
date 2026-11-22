package module.water
{
   import com.qzone.qfa.events.CommandEvent;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import entities.PoolFish;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.EventRecorder;
   
   public class WaterModel extends EventDispatcher
   {
      
      internal static const EVENT_DATA_LOADED:String = "Fish Data Loaded";
      
      internal static const EVENT_FISH_PLANTED:String = "Fish Planted";
      
      internal static const EVENT_FISH_HARVESTED:String = "Fish Harvested";
      
      internal static const EVENT_ERROR_MSG:String = "Error Message";
      
      internal static const EVENT_FISH_CHANGED:String = "Fish Data Changed";
      
      internal static const EVENT_NOT_WHITELIST:String = "Not in Whitelist";
      
      internal static const EVENT_WATER_OPENED:String = "Water Pool is Open";
      
      internal static const EVENT_LEVELUP:String = "LevelUp";
      
      internal static const EVENT_GROW_UP:String = "GrowUp";
      
      internal static const EVENT_BATCH_FISH:String = "BatchProcessFish";
      
      internal static const EVENT_UPDATE_MATURE_FLAG:String = "UpdateMatureFlag";
      
      private var _batchFlag:int;
      
      private var _requestOutputRecord:Dictionary;
      
      public var whited:Boolean;
      
      private var _fishes:Array;
      
      private var _requestPending:Boolean;
      
      public var opened:Boolean;
      
      private var _requestOutput:int;
      
      private var _batchFish:Array;
      
      public function WaterModel(param1:IEventDispatcher = null)
      {
         super(param1);
         this.opened = false;
         this.whited = false;
         this._fishes = null;
         this._requestPending = false;
         this._requestOutput = -1;
         this._requestOutputRecord = null;
         this._batchFish = null;
         this._batchFlag = 0;
      }
      
      private function onWaterOpened(param1:CommandEvent) : void
      {
         this.opened = true;
         dispatchEvent(new CommonEvent(EVENT_WATER_OPENED,null));
         EventRecorder.recordSueecssEvent("160759",0,null);
      }
      
      private function onHarvestFish(param1:CommandEvent) : void
      {
         this._requestPending = false;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_ is Array)
         {
            this._batchFish = _loc2_ as Array;
            this._batchFlag = 1;
            dispatchEvent(new CommonEvent(EVENT_BATCH_FISH,2));
         }
         else
         {
            this._batchFish = null;
            this._batchFlag = 0;
            this.processHarvestFish(_loc2_);
         }
         EventRecorder.recordSueecssEvent("160761",0,null);
      }
      
      public function findFishByID(param1:int) : PoolFish
      {
         var _loc2_:int = int(this._fishes.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if((this._fishes[_loc3_] as PoolFish)._id == param1)
            {
               return this._fishes[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      private function processStealFish(param1:Object) : void
      {
         var _loc5_:int = 0;
         if(param1["code"] != 1)
         {
            return;
         }
         var _loc2_:int = parseInt(param1["index"]);
         var _loc3_:PoolFish = this.findFishByID(_loc2_);
         if(_loc3_ != null)
         {
            _loc5_ = parseInt(Session.getInstance().hostId);
            if(param1["harvest"] > 0 && _loc3_._thief.indexOf(_loc5_) == -1)
            {
               _loc3_._thief.push(_loc5_);
            }
            _loc3_._left = param1["status"]["l"];
            _loc3_._output = param1["status"]["o"];
            _loc3_._plantTime = param1["status"]["p"];
         }
         var _loc4_:Boolean = false;
         if(_loc3_._output > 0 && _loc3_._left == 0)
         {
            _loc4_ = true;
         }
         dispatchEvent(new CommonEvent(EVENT_FISH_HARVESTED,{
            "count":param1["harvest"],
            "id":param1["index"],
            "remove":_loc4_
         }));
      }
      
      public function get poolFishes() : Array
      {
         return this._fishes;
      }
      
      public function loadFishes() : void
      {
         if(this._requestPending == true)
         {
            return;
         }
         this._requestPending = true;
         EventRecorder.startARequest("160613");
         NetHelper.sendRequest(CommandDefs.CMD_GET_FISHES,{"ownerId":Session.getInstance().currentUser._uId},this.onDataLoaded,this.onNetError);
      }
      
      public function harvestAll() : int
      {
         if(this.canOperate() == false)
         {
            return -3;
         }
         var _loc1_:int = parseInt(Session.getInstance().hostId);
         var _loc2_:Boolean = Boolean(Session.getInstance().me);
         var _loc3_:Array = [];
         var _loc4_:uint = this._fishes.length;
         var _loc5_:PoolFish = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         while(_loc7_ < _loc4_)
         {
            _loc5_ = this._fishes[_loc7_] as PoolFish;
            if(_loc5_ != null && _loc5_.canHarvest == true && _loc5_._left > 0)
            {
               if(_loc2_ == true)
               {
                  _loc3_.push(_loc5_._id);
               }
               else if(_loc5_._thief.indexOf(_loc1_) != -1)
               {
                  _loc6_ = true;
               }
               else if(_loc5_._left > _loc5_.min)
               {
                  _loc3_.push(_loc5_._id);
               }
               else
               {
                  _loc6_ = true;
               }
            }
            _loc7_++;
         }
         if(_loc3_.length == 0)
         {
            return _loc6_ ? -1 : -2;
         }
         var _loc8_:* = null;
         if(_loc2_ == true)
         {
            _loc8_ = {
               "index":_loc3_.join(","),
               "flag":2
            };
            this._requestPending = true;
            NetHelper.sendRequest(CommandDefs.CMD_HARVEST_FISH,_loc8_,this.onHarvestFish,this.onNetError);
         }
         else
         {
            _loc8_ = {
               "index":_loc3_.join(","),
               "flag":1,
               "ownerId":Session.getInstance().currentUser._uId
            };
            this._requestPending = true;
            NetHelper.sendRequest(CommandDefs.CMD_STEAL_FISH,_loc8_,this.onStealFish,this.onNetError);
         }
         return 0;
      }
      
      private function onGrowFish(param1:CommandEvent) : void
      {
         this._requestPending = false;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["exp"] != undefined)
         {
            Session.getInstance().updateHostAccount(0,_loc2_["exp"]);
            dispatchEvent(new CommonEvent(EVENT_LEVELUP,_loc2_));
         }
         var _loc3_:PoolFish = new PoolFish(_loc2_);
         _loc3_.calcNextStepTime();
         if(this._fishes == null)
         {
            this._fishes = new Array();
         }
         this._fishes.push(_loc3_);
         dispatchEvent(new CommonEvent(EVENT_FISH_PLANTED,_loc3_));
         EventRecorder.recordSueecssEvent("160763",0,null);
      }
      
      public function grow(param1:int) : void
      {
         if(this.canOperate() == false)
         {
            return;
         }
         if(Session.getInstance().me == false)
         {
            return;
         }
         this._requestPending = true;
         NetHelper.sendRequest(CommandDefs.CMD_GROW_FISH,{"fid":param1},this.onGrowFish,this.onNetError);
      }
      
      private function canOperate() : Boolean
      {
         if(this._requestPending == true)
         {
            return false;
         }
         return true;
      }
      
      public function growLoop() : void
      {
         var _loc3_:PoolFish = null;
         if(this._fishes == null || this._fishes.length == 0)
         {
            return;
         }
         var _loc1_:uint = uint(Session.getInstance().currentUser._uId);
         var _loc2_:Number = Number(CommonData.serverTime);
         for each(_loc3_ in this._fishes)
         {
            if(_loc2_ >= _loc3_._nextStepTime)
            {
               _loc3_.calcNextStepTime();
            }
            if(_loc3_._nextStepTime == Number.POSITIVE_INFINITY && _loc3_._output <= 0)
            {
               if(!(this._requestOutputRecord[_loc3_._id] != undefined && this._requestOutputRecord[_loc3_._id] >= 2))
               {
                  if(this._requestOutput == -1 && this._requestOutput != _loc3_._id)
                  {
                     this._requestOutput = _loc3_._id;
                     NetHelper.sendRequest(CommandDefs.CMD_FISH_OUTPUT,{
                        "index":_loc3_._id,
                        "ownerId":_loc1_
                     },this.onGetOutput,this.onNetError);
                     if(this._requestOutputRecord[_loc3_._id] == undefined)
                     {
                        this._requestOutputRecord[_loc3_._id] = 1;
                     }
                     else
                     {
                        ++this._requestOutputRecord[_loc3_._id];
                     }
                  }
               }
            }
         }
      }
      
      private function onGetOutput(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_ == null || _loc2_["i"] != this._requestOutput)
         {
            this._requestOutput = -1;
            return;
         }
         var _loc3_:PoolFish = this.findFishByID(_loc2_["i"]);
         if(_loc3_ != null)
         {
            _loc3_._left = _loc2_["l"] as int;
            _loc3_._output = _loc2_["o"] as int;
            this._requestOutput = -1;
            dispatchEvent(new CommonEvent(EVENT_FISH_CHANGED,_loc3_));
            EventRecorder.recordSueecssEvent("160872",0,null);
         }
      }
      
      public function resetLoadingFlags() : void
      {
         if(this._requestPending == true)
         {
            this._requestPending = false;
         }
      }
      
      private function onFeedFish(param1:CommandEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this._requestPending = false;
         var _loc3_:PoolFish = this.findFishByID(_loc2_["i"]);
         if(_loc3_ != null)
         {
            _loc3_.refreshStatus(_loc2_);
            _loc4_ = int(param1.body["__body"]["tid"]);
            dispatchEvent(new CommonEvent(EVENT_GROW_UP,{
               "fish":_loc3_,
               "food":_loc4_
            }));
         }
         EventRecorder.recordSueecssEvent("160762",0,null);
      }
      
      private function onDataLoaded(param1:CommandEvent) : void
      {
         var _loc3_:PoolFish = null;
         this._requestPending = false;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            this.opened = false;
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADED,null));
            return;
         }
         this.opened = true;
         this._fishes = _loc2_ as Array;
         this._requestOutputRecord = new Dictionary();
         for each(_loc3_ in this._fishes)
         {
            _loc3_.calcNextStepTime();
         }
         dispatchEvent(new CommonEvent(EVENT_DATA_LOADED,this._fishes));
         EventRecorder.recordSueecssEvent("160613",0,null);
      }
      
      public function feed(param1:int, param2:int) : void
      {
         var _loc3_:Object = {
            "index":param1,
            "tid":param2
         };
         this._requestPending = true;
         NetHelper.sendRequest(CommandDefs.CMD_FEED_FISH,_loc3_,this.onFeedFish,this.onNetError);
      }
      
      public function canSteal(param1:Boolean) : Boolean
      {
         if(this._fishes == null || this._fishes.length == 0)
         {
            return false;
         }
         var _loc2_:int = parseInt(Session.getInstance().hostId);
         var _loc3_:uint = this._fishes.length;
         var _loc4_:PoolFish = null;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_ = this._fishes[_loc5_] as PoolFish;
            if(_loc4_ != null && _loc4_.canHarvest == true && _loc4_._left > 0)
            {
               if(param1 == true)
               {
                  return true;
               }
               if(_loc4_._thief.indexOf(_loc2_) == -1)
               {
                  if(_loc4_._left > _loc4_.min)
                  {
                     return true;
                  }
               }
            }
            _loc5_++;
         }
         return false;
      }
      
      private function onStealFish(param1:CommandEvent) : void
      {
         this._requestPending = false;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_ is Array)
         {
            this._batchFish = _loc2_ as Array;
            this._batchFlag = 2;
            dispatchEvent(new CommonEvent(EVENT_BATCH_FISH,2));
         }
         else
         {
            this._batchFish = null;
            this.processStealFish(_loc2_);
         }
         EventRecorder.recordSueecssEvent("160760",0,null);
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         var _loc5_:String = null;
         var _loc6_:PoolFish = null;
         if(param1 == null)
         {
            return;
         }
         this._requestPending = false;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = param1.body["cmdID"] as int;
         var _loc4_:int = 0;
         if(_loc3_ == CommandDefs.CMD_GET_FISHES)
         {
            EventRecorder.recordErrorEvent("160613",null,0,null);
            if(_loc2_["open"] == 0)
            {
               this.opened = false;
               dispatchEvent(new CommonEvent(EVENT_DATA_LOADED,null));
            }
         }
         else if(_loc3_ == CommandDefs.CMD_FISH_OUTPUT)
         {
            _loc4_ = int(param1.body["__body"]["index"]);
            this._requestOutputRecord[_loc4_] = 2;
            this._requestOutput = -1;
            EventRecorder.recordErrorEvent("160872",null,4);
         }
         else if(_loc3_ == CommandDefs.CMD_WATER_OPEN)
         {
            _loc5_ = _loc2_["direction"] as String;
            if(_loc5_ == null || _loc5_ == "")
            {
               _loc5_ = "服务器错误.";
            }
            dispatchEvent(new CommonEvent(EVENT_WATER_OPENED,_loc5_));
            EventRecorder.recordErrorEvent("160759",null,0,null);
         }
         else if(_loc3_ == CommandDefs.CMD_STEAL_FISH)
         {
            _loc4_ = int(param1.body["__body"]["index"]);
            if(_loc2_["direction"] != undefined)
            {
               dispatchEvent(new CommonEvent(EVENT_ERROR_MSG,{
                  "id":_loc4_,
                  "msg":_loc2_["direction"]
               }));
            }
            if(_loc2_["l"] != undefined && _loc2_["o"] != undefined)
            {
               _loc6_ = this.findFishByID(_loc4_);
               if(_loc6_ != null)
               {
                  _loc6_._output = _loc2_["o"];
                  _loc6_._left = _loc2_["l"];
                  dispatchEvent(new CommonEvent(EVENT_FISH_CHANGED,_loc6_));
               }
            }
            EventRecorder.recordErrorEvent("160760",null,0,null);
         }
         else if(_loc3_ == CommandDefs.CMD_HARVEST_FISH)
         {
            _loc4_ = int(param1.body["__body"]["index"]);
            if(_loc2_["direction"] != undefined)
            {
               dispatchEvent(new CommonEvent(EVENT_ERROR_MSG,{
                  "id":_loc4_,
                  "msg":_loc2_["direction"]
               }));
            }
            EventRecorder.recordErrorEvent("160761",null,0,null);
         }
         else if(_loc3_ == CommandDefs.CMD_FEED_FISH)
         {
            _loc4_ = int(param1.body["__body"]["index"]);
            dispatchEvent(new CommonEvent(EVENT_ERROR_MSG,{
               "id":_loc4_,
               "msg":_loc2_["direction"]
            }));
            EventRecorder.recordErrorEvent("160762",null,0,null);
         }
         else if(_loc3_ == CommandDefs.CMD_GROW_FISH)
         {
            EventRecorder.recordErrorEvent("160763",null,0,null);
         }
      }
      
      public function openWater() : void
      {
         if(this.whited == true && this.opened == false)
         {
            NetHelper.sendRequest(CommandDefs.CMD_WATER_OPEN,{"yellow":Session.getInstance().host._yellowstatus},this.onWaterOpened,this.onNetError);
         }
      }
      
      public function checkSize() : Boolean
      {
         if(this.poolSize >= Consts.FISH_MAX_SIZE)
         {
            return false;
         }
         return true;
      }
      
      private function processHarvestFish(param1:Object) : void
      {
         if(param1 == null || param1["code"] != 1)
         {
            return;
         }
         if(param1["exp"] != undefined)
         {
            Session.getInstance().updateHostAccount(0,param1["exp"]);
            dispatchEvent(new CommonEvent(EVENT_LEVELUP,param1));
         }
         var _loc2_:int = int(this._fishes.length);
         var _loc3_:PoolFish = null;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ = this._fishes[_loc4_] as PoolFish;
            if(_loc3_ != null)
            {
               if(_loc3_._id == param1["i"])
               {
                  this._fishes.splice(_loc4_,1);
                  break;
               }
            }
            _loc4_++;
         }
         dispatchEvent(new CommonEvent(EVENT_FISH_HARVESTED,{
            "count":param1["o"],
            "id":param1["i"],
            "remove":true
         }));
      }
      
      public function harvest(param1:int, param2:Boolean) : void
      {
         if(this.canOperate() == false)
         {
            return;
         }
         var _loc3_:* = null;
         if(Session.getInstance().me == true)
         {
            _loc3_ = {"index":param1};
            if(param2 == false)
            {
               _loc3_["flag"] = 1;
            }
            this._requestPending = true;
            NetHelper.sendRequest(CommandDefs.CMD_HARVEST_FISH,_loc3_,this.onHarvestFish,this.onNetError);
         }
         else
         {
            if(param2 == false)
            {
               return;
            }
            this._requestPending = true;
            _loc3_ = {
               "index":param1,
               "ownerId":Session.getInstance().currentUser._uId
            };
            NetHelper.sendRequest(CommandDefs.CMD_STEAL_FISH,_loc3_,this.onStealFish,this.onNetError);
         }
      }
      
      public function processBatchFish() : Boolean
      {
         if(this._batchFish == null || this._batchFish.length == 0)
         {
            return false;
         }
         var _loc1_:Object = this._batchFish.shift();
         if(_loc1_ == null)
         {
            return false;
         }
         if(this._batchFlag == 1)
         {
            this.processHarvestFish(_loc1_);
         }
         else if(this._batchFlag == 2)
         {
            this.processStealFish(_loc1_);
         }
         dispatchEvent(new CommonEvent(EVENT_BATCH_FISH,1));
         if(this._batchFish.length > 0)
         {
            _loc1_ = this._batchFish[0];
            if(_loc1_["harvest"] > 0)
            {
               dispatchEvent(new CommonEvent(EVENT_UPDATE_MATURE_FLAG,_loc1_["index"]));
            }
            return true;
         }
         dispatchEvent(new CommonEvent(EVENT_BATCH_FISH,0));
         return false;
      }
      
      public function get poolSize() : int
      {
         var _loc2_:PoolFish = null;
         if(this._fishes == null)
         {
            return 0;
         }
         var _loc1_:int = 0;
         for each(_loc2_ in this._fishes)
         {
            _loc1_ += _loc2_.poolSize;
         }
         return _loc1_;
      }
      
      public function checkWhiteList() : void
      {
         this.whited = true;
         this.loadFishes();
      }
   }
}

