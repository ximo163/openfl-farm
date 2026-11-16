package mc.FBridge
{
   import common.CommonData;
   import common.LocalData;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class RequestManager extends EventDispatcher
   {
      
      private static var instance:RequestManager;
      
      public static const STEAL:String = "steal";
      
      public static const ENTER:String = "enter";
      
      private var actList:Object = {};
      
      private var _errInfo:String;
      
      private var localData:LocalData;
      
      private var uinList:Object = {};
      
      private var errTotal:Number = 3;
      
      public function RequestManager(param1:IEventDispatcher = null)
      {
         super(param1);
         this.localData = LocalData.getInstance();
      }
      
      public static function getInstance() : RequestManager
      {
         if(instance == null)
         {
            instance = new RequestManager();
         }
         return instance;
      }
      
      public function resetAction(param1:String) : void
      {
         var action:String = param1;
         try
         {
            if(this.actList[action])
            {
               this.actList[action]["errNum"] = 0;
               this.actList[action]["blocking"] = 0;
               delete this.actList[action]["record"];
               this.localData.setObject("requestManager_mc_action",this.actList,0,false);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function addAction(param1:String) : void
      {
         var _loc2_:Number = NaN;
         if(this.actList[param1])
         {
            ++this.actList[param1]["errNum"];
            if(this.actList[param1]["errNum"] >= this.errTotal && this.actList[param1]["blocking"] == 0)
            {
               _loc2_ = Math.floor(5 + Math.random() * 5);
               this.actList[param1]["blocking"] = CommonData.serverTime + _loc2_ * 60;
            }
            this.localData.setObject("requestManager_mc_action",this.actList,0,false);
         }
      }
      
      public function resetUin(param1:String) : void
      {
         if(this.uinList[param1])
         {
            delete this.uinList[param1];
            this.localData.setObject("requestManager_mc_uin",this.uinList,0,false);
         }
      }
      
      public function checkAction(param1:String, param2:String = null) : String
      {
         var _loc3_:Number = NaN;
         if(param1 == RequestManager.ENTER)
         {
            if(Boolean(this.uinList[param2]) && CommonData.serverTime < this.uinList[param2]["blocking"])
            {
               _loc3_ = Math.ceil((this.uinList[param2]["blocking"] - CommonData.serverTime) / 60);
               this._errInfo = "系统太忙，建议" + _loc3_ + "分钟后再访问该好友。";
               if(!this.uinList[param2]["record"])
               {
                  this.uinList[param2]["record"] = true;
                  EventRecorder.recordErrorEvent(EventRecorder.MC_SNOW,0,EventRecorder.FAULT_SNOW_ENTER);
               }
               return this._errInfo;
            }
            if(Boolean(this.uinList[param2]) && Boolean(CommonData.serverTime >= this.uinList[param2]["blocking"]) && this.uinList[param2]["errNum"] >= this.errTotal)
            {
               this.resetUin(param2);
            }
            return null;
         }
         if(Boolean(this.actList[param1]) && CommonData.serverTime < this.actList[param1]["blocking"])
         {
            _loc3_ = Math.ceil((this.actList[param1]["blocking"] - CommonData.serverTime) / 60);
            this._errInfo = "系统太忙，建议" + _loc3_ + "分钟后再试。";
            if(!this.actList[param1]["record"])
            {
               this.actList[param1]["record"] = true;
               EventRecorder.recordErrorEvent(EventRecorder.MC_SNOW,0,EventRecorder.FAULT_SNOW_STEAL);
            }
            return this._errInfo;
         }
         if(Boolean(this.actList[param1]) && Boolean(CommonData.serverTime >= this.actList[param1]["blocking"]) && this.actList[param1]["errNum"] >= this.errTotal)
         {
            this.resetAction(param1);
         }
         return null;
      }
      
      public function addUin(param1:String) : void
      {
         var _loc2_:Number = NaN;
         if(this.uinList[param1])
         {
            ++this.uinList[param1]["errNum"];
            if(this.uinList[param1]["errNum"] >= this.errTotal && this.uinList[param1]["blocking"] == 0)
            {
               _loc2_ = Math.floor(5 + Math.random() * 5);
               this.uinList[param1]["blocking"] = CommonData.serverTime + _loc2_ * 60;
            }
         }
         else
         {
            this.uinList[param1] = {
               "errNum":1,
               "blocking":0
            };
         }
         this.localData.setObject("requestManager_mc_uin",this.uinList,0,false);
      }
      
      public function registerAction() : void
      {
         this.errTotal = Number(LocalData.parameters["snowslide"]) || this.errTotal;
         if(!this.localData.getObject("requestManager_mc_action"))
         {
            this.actList["steal"] = {
               "action":"steal",
               "errNum":0,
               "blocking":0
            };
            this.localData.setObject("requestManager_mc_action",this.actList,0,false);
         }
         else
         {
            this.actList = LocalData.getInstance().getObject("requestManager_mc_action");
         }
         if(!this.localData.getObject("requestManager_mc_uin"))
         {
            this.localData.setObject("requestManager_mc_uin",this.uinList,0,false);
         }
         else
         {
            this.uinList = this.localData.getObject("requestManager_mc_uin");
         }
      }
   }
}

