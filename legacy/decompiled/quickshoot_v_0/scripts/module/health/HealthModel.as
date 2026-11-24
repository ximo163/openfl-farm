package module.health
{
   import com.qzone.qfa.events.CommandEvent;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import entities.HealthMode;
   import events.CommonEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.vo.ServiceResultVO;
   
   public class HealthModel extends EventDispatcher
   {
      
      internal static const EVENT_RESULT:String = "OpenCloseResult";
      
      internal static const EVENT_HEALTH_MODE_TIMEOUT:String = "HealthModeTimeout";
      
      private var m_session:Session;
      
      internal var healthModePeriod:String;
      
      internal var healthModeTime:String;
      
      private var m_toBeSet:String;
      
      private var m_needLvl:int;
      
      internal var currentFarmhealthModeTime:String;
      
      internal var healthModeOpened:Boolean;
      
      internal var canCancelHealthMode:Boolean;
      
      internal var currentFarmHealthModePeriod:String;
      
      internal var healthModeEndTime:Number;
      
      public function HealthModel()
      {
         super();
         this.m_needLvl = 0;
         var _loc1_:String = Settings.getInstance().getStringAttribute("hmv2level");
         if(_loc1_ != null)
         {
            this.m_needLvl = parseInt(_loc1_);
         }
         this.m_toBeSet = "";
         this.healthModeEndTime = 0;
         this.canCancelHealthMode = false;
         this.healthModeOpened = false;
         this.m_session = Session.getInstance();
      }
      
      public function openHealthMode(param1:String, param2:String) : void
      {
         if(param1 == "" || param2 == "")
         {
            return;
         }
         this.m_toBeSet = param1 + "|" + param2;
         NetHelper.sendRequest(CommandDefs.CMD_OPEN_HEALTH,{"time":this.m_toBeSet},this.onOpened,this.onError);
      }
      
      private function onOpened(param1:CommandEvent) : void
      {
         var _loc4_:String = null;
         if(param1 == null || param1.result == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:* = _loc2_.m_extra;
         if(_loc3_["code"] == 1)
         {
            _loc4_ = _loc3_["date"].split("|")[0];
            this.healthModePeriod = _loc4_.substr(0,4) + "年" + _loc4_.substr(5,2) + "月" + _loc4_.substr(8,2) + "日";
            _loc4_ = _loc3_["date"].split("|")[1];
            this.healthModePeriod += "-" + _loc4_.substr(0,4) + "年" + _loc4_.substr(5,2) + "月" + _loc4_.substr(8,2) + "日";
            this.canCancelHealthMode = true;
            this.healthModeOpened = true;
            this.healthModeTime = this.m_toBeSet;
            dispatchEvent(new CommonEvent(EVENT_RESULT,{
               "mode":1,
               "success":true
            }));
            this.m_toBeSet = "";
         }
      }
      
      public function get needLevel() : int
      {
         return this.m_needLvl;
      }
      
      public function updateHealthMode() : void
      {
         var _loc1_:Date = null;
         var _loc2_:Array = null;
         if(this.checkTimeCanPick() == true)
         {
            if(this.m_session.healthModeValid == true || this.m_session.currentFarmHealthModeValid == true)
            {
               if(this.m_session.me == true)
               {
                  if(CommonData.serverTime >= this.healthModeEndTime)
                  {
                     this.healthModeOpened = false;
                     this.canCancelHealthMode = true;
                  }
                  this.m_session.healthModeValid = false;
                  this.m_session.healthModeTimeOut = true;
               }
               else
               {
                  this.m_session.currentFarmHealthModeValid = false;
                  this.m_session.healthModeTimeOut = true;
               }
               dispatchEvent(new Event(EVENT_HEALTH_MODE_TIMEOUT));
            }
         }
         if(this.healthModeOpened == true && this.canCancelHealthMode == true && this.healthModeTime != "")
         {
            _loc1_ = new Date(CommonData.serverTime * 1000);
            _loc2_ = this.healthModeTime.split("|");
            if(_loc1_.hours == _loc2_[0] && _loc1_.minutes >= _loc2_[1] || _loc1_.hours > _loc2_[0])
            {
               this.canCancelHealthMode = false;
            }
         }
      }
      
      private function checkTimeCanPick() : Boolean
      {
         var _loc1_:Array = null;
         if(this.m_session.healthModeValid == true && this.healthModeTime != "")
         {
            _loc1_ = this.healthModeTime.split("|");
         }
         else if(this.m_session.currentFarmHealthModeValid == true && this.currentFarmhealthModeTime != "")
         {
            _loc1_ = this.currentFarmhealthModeTime.split("|");
         }
         if(_loc1_ == null)
         {
            return true;
         }
         var _loc2_:Number = parseFloat(_loc1_[0]);
         var _loc3_:Number = parseFloat(_loc1_[1]);
         var _loc4_:Date = new Date(2009,11,1,_loc2_,_loc3_);
         _loc4_.setHours(_loc2_ + Consts.HEALTH_MODE_TOTAL_HOURS);
         var _loc5_:Number = _loc4_.getHours();
         var _loc6_:Date = new Date(CommonData.serverTime * 1000);
         var _loc7_:int = _loc6_.getHours();
         var _loc8_:Boolean = true;
         var _loc9_:Number = _loc2_;
         var _loc10_:Number = _loc2_ + Consts.HEALTH_MODE_TOTAL_HOURS;
         while(_loc9_ < _loc10_)
         {
            if(_loc9_ % 24 == _loc7_)
            {
               _loc8_ = false;
            }
            _loc9_++;
         }
         if(_loc7_ == _loc5_)
         {
            if(_loc6_.getMinutes() < _loc3_)
            {
               _loc8_ = false;
            }
         }
         return _loc8_;
      }
      
      private function onClosed(param1:CommandEvent) : void
      {
         if(param1 == null || param1.result == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.m_extra["code"] == 1)
         {
            this.canCancelHealthMode = false;
            this.healthModeOpened = false;
            dispatchEvent(new CommonEvent(EVENT_RESULT,{
               "mode":0,
               "success":true
            }));
         }
      }
      
      public function closeHealthMode() : void
      {
         NetHelper.sendRequest(CommandDefs.CMD_OPEN_HEALTH,{"close":1},this.onClosed,this.onError);
      }
      
      private function onError(param1:CommandEvent) : void
      {
         if(param1 == null || param1.body == null)
         {
            return;
         }
         if(param1.body["cmdID"] == CommandDefs.CMD_OPEN_HEALTH)
         {
            dispatchEvent(new CommonEvent(EVENT_RESULT,{
               "mode":1,
               "success":false
            }));
            this.m_toBeSet = "";
         }
         else
         {
            dispatchEvent(new CommonEvent(EVENT_RESULT,{
               "mode":0,
               "success":false
            }));
         }
      }
      
      public function set healthMode(param1:HealthMode) : void
      {
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc2_:Boolean = param1._valid == 1;
         var _loc3_:String = "";
         if(param1._date != "")
         {
            _loc4_ = param1._date.split("|");
            if(_loc4_ == null || _loc4_.length < 2)
            {
               return;
            }
            _loc5_ = _loc4_[0];
            _loc3_ = _loc5_.substr(0,4) + "年" + _loc5_.substr(5,2) + "月" + _loc5_.substr(8,2) + "日";
            _loc6_ = _loc4_[1];
            _loc3_ += "-";
            _loc3_ += _loc6_.substr(0,4) + "年" + _loc6_.substr(5,2) + "月" + _loc6_.substr(8,2) + "日";
         }
         if(this.m_session.me == true)
         {
            this.m_session.healthModeValid = _loc2_;
            this.healthModeTime = param1._time;
            this.healthModePeriod = _loc3_;
            this.healthModeOpened = param1._set == 1 || _loc2_;
            this.healthModeEndTime = param1._endTime;
            if(param1._set == 1 && param1._canClose == 1)
            {
               this.canCancelHealthMode = true;
            }
            else
            {
               this.canCancelHealthMode = false;
            }
         }
         this.currentFarmhealthModeTime = param1._time;
         this.currentFarmHealthModePeriod = _loc3_;
         this.m_session.currentFarmHealthModeValid = _loc2_;
         this.m_session.healthModeTimeOut = false;
      }
   }
}

