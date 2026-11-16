package module.mainScene.farmLand
{
   import com.qzone.qfa.events.CommandEvent;
   import common.Session;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.vo.ServiceResultVO;
   import report.EventRecorder;
   
   public class OperationQueue extends EventDispatcher
   {
      
      internal static const EVENT_OPERATE_SUCCES:String = "OperateSuccess";
      
      internal static const EVENT_OPERATE_ERROR:String = "OperateError";
      
      internal static const ADD_WEED:int = 0;
      
      internal static const CLEAR_WEED:int = 1;
      
      internal static const ADD_BUG:int = 2;
      
      internal static const CLEAR_BUG:int = 3;
      
      internal static const QUEUE_LEN:int = 4;
      
      private var m_delayRequestTimer:Timer;
      
      private var m_requestQueue:Array;
      
      private var m_responseQueue:Array;
      
      private var m_showByTimer:Timer;
      
      public function OperationQueue(param1:uint = 1000, param2:IEventDispatcher = null)
      {
         super(param2);
         this.m_requestQueue = new Array(QUEUE_LEN);
         this.m_responseQueue = new Array(QUEUE_LEN);
         this.m_delayRequestTimer = new Timer(param1,0);
         this.m_delayRequestTimer.addEventListener(TimerEvent.TIMER,this.delayRequestNow);
         this.m_showByTimer = new Timer(400,0);
         this.m_showByTimer.addEventListener(TimerEvent.TIMER,this.onProcessResponseTimer);
      }
      
      private function recordResp(param1:String, param2:Boolean, param3:String) : void
      {
         if(param2 == true)
         {
            EventRecorder.recordSueecssEvent(param1,null,param3);
         }
         else
         {
            EventRecorder.recordErrorEvent(param1,null,EventRecorder.FAULT_ERROR,param3);
         }
      }
      
      private function onOperateResponse(param1:CommandEvent) : void
      {
         var _loc10_:* = undefined;
         if(param1 == null)
         {
            Session.getInstance().isExpLocked = false;
            return;
         }
         var _loc2_:int = param1.body["cmdID"] as int;
         var _loc3_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc3_ == null || _loc3_.m_extra == null)
         {
            Session.getInstance().isExpLocked = false;
            return;
         }
         var _loc4_:Boolean = false;
         if(_loc3_.m_extra.hasOwnProperty("errorType") == true)
         {
            _loc4_ = true;
         }
         var _loc5_:int = -1;
         if(_loc2_ == CommandDefs.CMD_OPERATE_ADDWEED)
         {
            this.recordResp(EventRecorder.HF_SCATTERSEED,!_loc4_,"mod=farmlandstatus&act=scatterSeed");
            _loc5_ = ADD_WEED;
         }
         else if(_loc2_ == CommandDefs.CMD_OPERATE_CLEARWEED)
         {
            this.recordResp(EventRecorder.HF_CLEARWEED,!_loc4_,"mod=farmlandstatus&act=clearWeed");
            _loc5_ = CLEAR_WEED;
         }
         else if(_loc2_ == CommandDefs.CMD_OPERATE_ADDBUG)
         {
            this.recordResp(EventRecorder.HF_PEST,!_loc4_,"mod=farmlandstatus&act=pest");
            _loc5_ = ADD_BUG;
         }
         else if(_loc2_ == CommandDefs.CMD_OPERATE_CLEARBUG)
         {
            this.recordResp(EventRecorder.HF_SPRAYING,!_loc4_,"mod=farmlandstatus&act=spraying");
            _loc5_ = CLEAR_BUG;
         }
         if(_loc5_ == -1 || _loc4_ == true)
         {
            Session.getInstance().isExpLocked = false;
            return;
         }
         if(this.m_responseQueue[_loc5_] == null)
         {
            this.m_responseQueue[_loc5_] = new Array();
         }
         var _loc6_:Array = new Array();
         _loc6_ = _loc6_.concat(_loc3_.m_extra);
         var _loc7_:Array = this.m_responseQueue[_loc5_];
         var _loc8_:* = null;
         var _loc9_:Boolean = false;
         for each(_loc10_ in _loc6_)
         {
            if(_loc10_["code"] == 0)
            {
               _loc9_ = false;
               for each(_loc8_ in _loc7_)
               {
                  if(_loc10_["farmlandIndex"] == _loc8_["farmlandIndex"])
                  {
                     if(_loc10_["code"] == _loc8_["code"] && _loc10_["poptype"] == _loc8_["poptype"])
                     {
                        _loc9_ = true;
                        if(_loc8_["error_repeat"] != undefined)
                        {
                           ++_loc8_["error_repeat"];
                        }
                        else
                        {
                           _loc8_["error_repeat"] = 1;
                        }
                     }
                  }
               }
               if(_loc9_ == false)
               {
                  _loc7_.push(_loc10_);
               }
            }
            else
            {
               _loc9_ = false;
               for each(_loc8_ in _loc7_)
               {
                  if(_loc10_["farmlandIndex"] == _loc8_["farmlandIndex"])
                  {
                     switch(_loc5_)
                     {
                        case ADD_WEED:
                           if(_loc10_["weed"] >= _loc8_["weed"])
                           {
                              _loc9_ = true;
                              _loc8_["weed"] = _loc10_["weed"];
                           }
                           break;
                        case CLEAR_WEED:
                           if(_loc10_["weed"] <= _loc8_["weed"])
                           {
                              _loc9_ = true;
                              _loc8_["weed"] = _loc10_["weed"];
                           }
                           break;
                        case ADD_BUG:
                           if(_loc10_["pest"] >= _loc8_["pest"])
                           {
                              _loc9_ = true;
                              _loc8_["pest"] = _loc10_["pest"];
                           }
                           break;
                        case CLEAR_BUG:
                           if(_loc10_["pest"] <= _loc8_["pest"])
                           {
                              _loc9_ = true;
                              _loc8_["pest"] = _loc10_["pest"];
                           }
                     }
                     if(_loc9_ == true)
                     {
                        _loc8_["money"] += _loc10_["money"] as int;
                        _loc8_["exp"] += _loc10_["exp"] as int;
                        if(_loc8_["levelUp"] == false && _loc10_["levelUp"] == true)
                        {
                           _loc8_["levelUp"] = true;
                        }
                     }
                  }
               }
               if(_loc9_ == false)
               {
                  _loc7_.push(_loc10_);
               }
            }
         }
         if(this.m_showByTimer.running == false)
         {
            this.m_showByTimer.start();
         }
      }
      
      private function delayRequestNow(param1:TimerEvent) : void
      {
         var _loc2_:* = null;
         if(this.m_requestQueue[ADD_WEED] != null)
         {
            EventRecorder.startARequest(EventRecorder.HF_SCATTERSEED);
            NetHelper.sendRequest(CommandDefs.CMD_OPERATE_ADDWEED,this.m_requestQueue[ADD_WEED],this.onOperateResponse,this.onOperateResponse);
            this.m_requestQueue[ADD_WEED] = null;
         }
         if(this.m_requestQueue[CLEAR_WEED] != null)
         {
            EventRecorder.startARequest(EventRecorder.HF_CLEARWEED);
            NetHelper.sendRequest(CommandDefs.CMD_OPERATE_CLEARWEED,this.m_requestQueue[CLEAR_WEED],this.onOperateResponse,this.onOperateResponse);
            this.m_requestQueue[CLEAR_WEED] = null;
            Session.getInstance().isExpLocked = true;
         }
         if(this.m_requestQueue[ADD_BUG] != null)
         {
            EventRecorder.startARequest(EventRecorder.HF_PEST);
            NetHelper.sendRequest(CommandDefs.CMD_OPERATE_ADDBUG,this.m_requestQueue[ADD_BUG],this.onOperateResponse,this.onOperateResponse);
            this.m_requestQueue[ADD_BUG] = null;
         }
         if(this.m_requestQueue[CLEAR_BUG] != null)
         {
            EventRecorder.startARequest(EventRecorder.HF_SPRAYING);
            NetHelper.sendRequest(CommandDefs.CMD_OPERATE_CLEARBUG,this.m_requestQueue[CLEAR_BUG],this.onOperateResponse,this.onOperateResponse);
            this.m_requestQueue[CLEAR_BUG] = null;
            Session.getInstance().isExpLocked = true;
         }
         this.m_delayRequestTimer.stop();
      }
      
      public function delayRequest(param1:int, param2:Object) : void
      {
         if(this.m_requestQueue[param1] == null)
         {
            this.m_requestQueue[param1] = param2;
         }
         else
         {
            this.m_requestQueue[param1]["place"] += "," + param2["place"];
         }
         if(this.m_delayRequestTimer.running == false)
         {
            this.m_delayRequestTimer.start();
         }
      }
      
      private function onProcessResponseTimer(param1:TimerEvent) : void
      {
         var _loc4_:* = undefined;
         if(this.m_responseQueue == null || this.m_responseQueue.length == 0)
         {
            return;
         }
         Session.getInstance().harvestAnimationPlaying = true;
         var _loc2_:Boolean = true;
         var _loc3_:int = 0;
         while(_loc3_ < this.m_responseQueue.length)
         {
            if(this.m_responseQueue[_loc3_] != null)
            {
               if(this.m_responseQueue[_loc3_].length == 0)
               {
                  this.m_responseQueue[_loc3_] = null;
               }
               else
               {
                  _loc4_ = this.m_responseQueue[_loc3_].shift();
                  dispatchEvent(new CommonEvent(EVENT_OPERATE_SUCCES,{
                     "cmd":_loc3_,
                     "data":_loc4_
                  }));
                  _loc2_ = false;
               }
            }
            _loc3_++;
         }
         if(_loc2_ == true)
         {
            this.m_showByTimer.stop();
            Session.getInstance().harvestAnimationPlaying = false;
            Session.getInstance().isExpLocked = false;
         }
      }
   }
}

