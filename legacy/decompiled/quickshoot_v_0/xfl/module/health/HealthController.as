package module.health
{
   import com.qzone.utils.StringUtil;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.misc.time.CountDown;
   import common.view.window.BaseWindow;
   import entities.Player;
   import events.CommonEvent;
   import flash.events.TextEvent;
   import framework.base.Controller;
   import interfaces.IMsgCenter;
   
   public class HealthController extends Controller
   {
      
      private var m_updateFreq:CountDown;
      
      public function HealthController()
      {
         super(null);
      }
      
      private function onHealthModeTimeout(param1:CommonEvent) : void
      {
         module.app.dispatchEvent(new CommonEvent(Consts.MSG_HEALTHMODE_TIMEOUT,null));
         module.app.dispatchEvent(new CommonEvent(Consts.MSG_HEALTH_MODE_OPEN_CHANGED,{"open":this.model.healthModeOpened}));
      }
      
      private function onCheckHealthMode(param1:CommonEvent) : void
      {
         var _loc12_:String = null;
         var _loc2_:Date = new Date();
         _loc2_.setTime(CommonData.serverTime * 1000);
         var _loc3_:String = StringUtil.getZeroString(_loc2_.getHours()) + ":" + StringUtil.getZeroString(_loc2_.getMinutes());
         var _loc4_:Array = this.model.healthModeTime.split("|");
         var _loc5_:int = (parseFloat(_loc4_[0]) + Consts.HEALTH_MODE_TOTAL_HOURS) % 24;
         var _loc6_:String = _loc4_[0] + ":" + _loc4_[1] + "-" + StringUtil.getZeroString(_loc5_) + ":" + _loc4_[1];
         var _loc7_:String = "";
         var _loc8_:String = this.model.healthModePeriod;
         if(_loc8_ != "")
         {
            _loc7_ = _loc8_.split("-")[1];
            _loc12_ = _loc6_.split("-")[1];
            _loc12_ = _loc12_.replace(/^\s*|\s*$/g,"");
            _loc7_ = _loc7_ + "&nbsp;" + _loc12_;
         }
         var _loc9_:Boolean = false;
         if(param1 != null && param1.data != null && param1.data["sync"] == true)
         {
            _loc9_ = true;
         }
         var _loc10_:Session = Session.getInstance();
         var _loc11_:String = "";
         if(_loc10_.me == true)
         {
            _loc11_ = Language.L["HM_SELF_PICK"];
            _loc11_ = _loc11_.replace(/@time/g,_loc6_);
            if(_loc7_ != "")
            {
               _loc11_ = _loc11_.replace(/@endDate/g,_loc7_);
            }
            _loc11_ = _loc11_.replace(/@now/g,_loc3_);
            openWindow(Consts.WINDOW_NAME_ALERT,{
               "text":_loc11_,
               "type":Consts.ALERT_TYPE_TEXT,
               "width":440,
               "title":Language.L["HM_TITLE"]
            });
            if(_loc9_ == true)
            {
               _loc10_.healthModeValid = true;
            }
         }
         else if(this.model.healthModeOpened == true)
         {
            _loc11_ = Language.L["HM_TO_PICK_FRIEND"];
            _loc11_ = _loc11_.replace(/@time/g,_loc6_);
            if(_loc7_ != "")
            {
               _loc11_ = _loc11_.replace(/@endDate/g,_loc7_);
            }
            _loc11_ = _loc11_.replace(/@now/g,_loc3_);
            openWindow(Consts.WINDOW_NAME_ALERT,{
               "text":_loc11_,
               "type":Consts.ALERT_TYPE_TEXT,
               "width":440,
               "title":Language.L["HM_TITLE"]
            });
         }
         else
         {
            _loc4_ = this.model.currentFarmhealthModeTime.split("|");
            _loc8_ = this.model.currentFarmHealthModePeriod;
            _loc5_ = (parseFloat(_loc4_[0]) + Consts.HEALTH_MODE_TOTAL_HOURS) % 24;
            _loc6_ = _loc4_[0] + ":" + _loc4_[1] + "-" + StringUtil.getZeroString(_loc5_) + ":" + _loc4_[1];
            _loc11_ = Language.L["HM_FRIEND_PICK"];
            _loc11_ = _loc11_.replace(/@time/g,_loc6_);
            _loc11_ = _loc11_.replace(/@now/g,_loc3_);
            openWindow(Consts.WINDOW_NAME_ALERT,{
               "text":_loc11_,
               "type":Consts.ALERT_TYPE_TEXT,
               "width":410,
               "textLinkHandle":this.onWhatsHealthMode,
               "title":Language.L["HM_TITLE"]
            });
            if(_loc9_ == true)
            {
               _loc10_.currentFarmHealthModeValid = true;
            }
         }
      }
      
      public function get model() : HealthModel
      {
         return m_model as HealthModel;
      }
      
      private function onHealthModelResult(param1:CommonEvent) : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:String = "";
         var _loc3_:* = param1.data;
         if(_loc3_["mode"] == 0)
         {
            if(_loc3_["success"] == true)
            {
               _loc2_ = Language.L["HM_CLOSE_SUCCESS"];
               openWindow(Consts.WINDOW_NAME_ALERT,{
                  "text":_loc2_,
                  "type":Consts.ALERT_TYPE_TEXT,
                  "width":400,
                  "title":Language.L["HM_TITLE"]
               });
               module.app.dispatchEvent(new CommonEvent(Consts.MSG_HEALTH_MODE_OPEN_CHANGED,{"open":this.model.healthModeOpened}));
            }
            else
            {
               _loc2_ = Language.L["HM_SET_FAILED"];
               openWindow(Consts.WINDOW_NAME_ALERT,{
                  "text":_loc2_,
                  "type":Consts.ALERT_TYPE_ERROR,
                  "title":Language.L["HM_TITLE"]
               });
            }
         }
         else if(_loc3_["mode"] == 1)
         {
            if(_loc3_["success"] == true)
            {
               _loc2_ = Language.L["HM_OPEN_SUCCESS"];
               _loc4_ = this.model.healthModeTime.split("|");
               if(_loc4_.length != 2)
               {
                  return;
               }
               _loc5_ = (parseFloat(_loc4_[0]) + Consts.HEALTH_MODE_TOTAL_HOURS) % 24;
               _loc6_ = _loc4_[0] + ":" + _loc4_[1] + "-" + StringUtil.getZeroString(_loc5_) + ":" + _loc4_[1];
               _loc2_ = _loc2_.replace(/@period/g,this.model.healthModePeriod);
               _loc2_ = _loc2_.replace(/@time/g,_loc6_);
               openWindow(Consts.WINDOW_NAME_ALERT,{
                  "text":_loc2_,
                  "type":Consts.ALERT_TYPE_TEXT,
                  "width":400,
                  "title":Language.L["HM_TITLE"]
               });
               module.app.dispatchEvent(new CommonEvent(Consts.MSG_HEALTH_MODE_OPEN_CHANGED,{"open":this.model.healthModeOpened}));
            }
            else
            {
               _loc2_ = Language.L["HM_SET_FAILED"];
               openWindow(Consts.WINDOW_NAME_ALERT,{
                  "text":_loc2_,
                  "type":Consts.ALERT_TYPE_ERROR,
                  "tile":Language.L["HM_TITLE"]
               });
            }
         }
      }
      
      private function onWhatsHealthMode(param1:TextEvent) : void
      {
         this.onOpenWindow(null);
      }
      
      public function onGameLoop(param1:Number) : void
      {
         if(this.m_updateFreq.isReady() == false)
         {
            return;
         }
         this.m_updateFreq.reset(Consts.HEALTH_MODE_COUNTDOWN);
         this.model.updateHealthMode();
      }
      
      private function onCurrentUserChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Player = param1.data as Player;
         if(_loc2_ == null)
         {
            return;
         }
         this.model.healthMode = _loc2_._healthMode;
      }
      
      private function onOpenWindow(param1:CommonEvent) : void
      {
         var _loc7_:Player = null;
         var _loc2_:String = "";
         if(this.model.needLevel > 0)
         {
            _loc7_ = Session.getInstance().host;
            if(_loc7_._yellowlevel < this.model.needLevel || _loc7_._yellowstatus == 0)
            {
               _loc2_ = Language.L["HM_UPDATING"];
               _loc2_ = _loc2_.replace(/@healModeTotalHour/g,Consts.HEALTH_MODE_TOTAL_HOURS);
               _loc2_ = _loc2_.replace(/@hmv2Level/g,this.model.needLevel);
               openWindow(Consts.WINDOW_NAME_ALERT,{
                  "type":Consts.ALERT_TYPE_TEXT,
                  "text":_loc2_,
                  "title":Language.L["HM_TITLE"],
                  "width":500
               });
               return;
            }
         }
         var _loc3_:Array = this.model.healthModeTime.split("|");
         var _loc4_:String = this.model.healthModePeriod;
         var _loc5_:int = (parseFloat(_loc3_[0]) + Consts.HEALTH_MODE_TOTAL_HOURS) % 24;
         var _loc6_:String = _loc3_[0] + ":" + _loc3_[1] + "-" + StringUtil.getZeroString(_loc5_) + ":" + _loc3_[1];
         if(Session.getInstance().healthModeValid == true)
         {
            _loc2_ = Language.L["HM_VALID"];
            _loc2_ = _loc2_.replace(/@healModeTotalHour/g,Consts.HEALTH_MODE_TOTAL_HOURS);
            _loc2_ = _loc2_.replace(/@totalDay/g,Consts.HEALTH_MODE_TOTAL_DAYS);
            _loc2_ = _loc2_.replace(/@time/g,_loc6_);
            _loc2_ = _loc2_.replace(/@period/g,this.model.healthModePeriod);
            openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_TEXT,
               "text":_loc2_,
               "title":Language.L["HM_TITLE"],
               "width":535
            });
            return;
         }
         if(this.model.healthModeOpened == true)
         {
            if(this.model.canCancelHealthMode == true)
            {
               if(m_view == null)
               {
                  m_view = new HealthView(this);
               }
               m_view.data = {"mode":0};
               module.app.farmView.winCtrl.open(m_view as BaseWindow);
               return;
            }
            _loc2_ = Language.L["HM_VALID"];
            _loc2_ = _loc2_.replace(/@healModeTotalHour/g,Consts.HEALTH_MODE_TOTAL_HOURS);
            _loc2_ = _loc2_.replace(/@totalDay/g,Consts.HEALTH_MODE_TOTAL_DAYS);
            _loc2_ = _loc2_.replace(/@time/g,_loc6_);
            _loc2_ = _loc2_.replace(/@period/g,this.model.healthModePeriod);
            openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_TEXT,
               "text":_loc2_,
               "title":Language.L["HM_TITLE"],
               "width":535
            });
            return;
         }
         if(m_view == null)
         {
            m_view = new HealthView(this);
         }
         m_view.data = {"mode":1};
         module.app.farmView.winCtrl.open(m_view as BaseWindow);
      }
      
      private function onHostStatusChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Player = param1.data as Player;
         if(_loc2_ == null)
         {
            return;
         }
         this.model.healthMode = _loc2_._healthMode;
      }
      
      override public function initialze() : void
      {
         var _loc2_:Player = null;
         if(m_model == null)
         {
            m_model = new HealthModel();
            _loc2_ = Session.getInstance().currentUser;
            if(_loc2_ != null)
            {
               this.model.healthMode = _loc2_._healthMode;
            }
            m_model.addEventListener(HealthModel.EVENT_HEALTH_MODE_TIMEOUT,this.onHealthModeTimeout,false,0,true);
            m_model.addEventListener(HealthModel.EVENT_RESULT,this.onHealthModelResult,false,0,true);
         }
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_HOST_CHANGED,this.onHostStatusChanged,false,0,true);
            _loc1_.addEventListener(Consts.MSG_CURRENT_USER_CHANGED,this.onCurrentUserChanged,false,0,true);
            _loc1_.addEventListener(Consts.MSG_SHOW_HEALTHMODE,this.onOpenWindow,false,0,true);
            _loc1_.addEventListener(Consts.MSG_CHECK_HEALTHMODE,this.onCheckHealthMode,false,0,true);
         }
         this.m_updateFreq = new CountDown(Consts.HEALTH_MODE_COUNTDOWN);
      }
   }
}

