package module.mainScene.farmLand
{
   import com.qzone.qfa.events.CommandEvent;
   import common.CommonData;
   import common.Consts;
   import common.FeartureManager;
   import common.GetCropID;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import entities.FarmLand;
   import entities.StartupData;
   import events.CommonEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.EventRecorder;
   
   public class FarmLandModel extends EventDispatcher
   {
      
      internal static const EVENT_INITIALZED:String = "DataInitialized";
      
      internal static const EVENT_HARVEST_DATA:String = "HarvestData";
      
      internal static const EVENT_ADD_HEALTH:String = "AddHealth";
      
      internal static const EVENT_OPERATE_INVALID:String = "FarmLandOperateError";
      
      internal static const EVENT_OPERATE_FAILED:String = "FarmLandOperateFailed";
      
      internal static const EVENT_LAND_CHANGED:String = "FarmLandChanged";
      
      internal static const EVENT_CONFIRM_SCARIFY:String = "ConfirmScarify";
      
      internal static const EVENT_ALERT_WINDOW:String = "AlertWindow";
      
      internal static const EVENT_SHOW_PICK_ICON:String = "ShowPickIcon";
      
      internal static const EVENT_DIG_OUT_ITEMS:String = "DigItems";
      
      internal static const EVENT_SHOW_TIP:String = "SendDogHitTip";
      
      internal static const EVENT_SHOW_GIFT_WINDOW:String = "ShowBigGift";
      
      internal static const EVENT_REFRESH_CROP_DATA:String = "RefreshCropData";
      
      internal static const EVENT_REMOVE_MYBAG_ITEM:String = "UpdateMyBag";
      
      internal static const EVENT_RECLAIM_CONDITION:String = "ReclaimCondition";
      
      internal static const EVENT_RECLAIM_RESULT:String = "ReclaimResult";
      
      internal static const EVENT_HEALTH_MODE_PROTECTED:String = "HealthModeProtectedNow";
      
      internal static const EVENT_CHECK_TASK:String = "CheckTaskComplete";
      
      internal static const EVENT_CHECK_STATUS:String = "CheckLandsStatus";
      
      internal static const EVENT_FUNCTION_FORBIDDEN:String = "ScroungeForbid";
      
      internal static const EVENT_LEVELUP:String = "LevelUp";
      
      internal static const EVENT_HARVEST_OVER:String = "FinishHarvesting";
      
      internal static const EVENT_PLAY_PLANE:String = "PlayPlanAnimation";
      
      public var tjShare:Array;
      
      private var m_farmlandData:Array;
      
      private var m_harvestAllFlag:Boolean;
      
      private var m_allFailedLost:int;
      
      private var m_reclaiming:Boolean;
      
      private var _refreshAllLands:Boolean;
      
      private var _refreshLands:Array;
      
      private var m_harvestAllTimer:Timer;
      
      private var m_requestFreq:Object;
      
      private var m_opQueue:OperationQueue;
      
      private var m_harvestRequesting:Boolean;
      
      private var m_showDogHitTipDelay:int;
      
      private var m_harvestAllArray:Array;
      
      private var m_allFailedLostTimes:int;
      
      private var firstHelpExpFull:Boolean = true;
      
      public function FarmLandModel(param1:IEventDispatcher = null)
      {
         super(param1);
         this.m_farmlandData = null;
         this.m_requestFreq = {};
         this.m_opQueue = new OperationQueue();
         this.m_opQueue.addEventListener(OperationQueue.EVENT_OPERATE_SUCCES,this.onDelayResponseSuccess);
         this.m_harvestRequesting = false;
         this.m_harvestAllFlag = false;
         this.m_allFailedLost = 0;
         this.m_allFailedLostTimes = 0;
         this.m_harvestAllTimer = null;
         this.m_harvestAllArray = null;
         this.m_showDogHitTipDelay = 0;
         this.m_reclaiming = false;
         this.tjShare = [];
      }
      
      public function reGetOutput() : void
      {
         var _loc2_:FarmLand = null;
         var _loc3_:Object = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_farmlandData)
         {
            if(_loc2_._step == 5 && _loc2_._output == 0)
            {
               _loc3_ = this.buildCommonPostParams(_loc1_.toString());
               NetHelper.sendRequest(CommandDefs.CMD_GET_OUTPUT,_loc3_,this.onReGetOutput,this.onReGetOutputFail);
            }
            _loc1_++;
         }
      }
      
      public function getOutput(param1:int) : void
      {
         var _loc2_:Object = this.buildCommonPostParams(param1.toString());
         NetHelper.sendRequest(CommandDefs.CMD_GET_OUTPUT,_loc2_,this.onGetOutput,this.onGetOutputFail);
      }
      
      public function get hasBlackLand() : Boolean
      {
         var _loc1_:FarmLand = this.getLandData(0);
         if(_loc1_ != null && _loc1_._bitmap == 2)
         {
            return true;
         }
         return false;
      }
      
      private function acceptHarvestGift(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Array = [];
         if(param1.hasOwnProperty("item") == true)
         {
            _loc2_ = _loc2_.concat(param1["item"]);
         }
         if(param1.hasOwnProperty("vipItem") == true && param1["vipItem"] != false)
         {
            _loc2_ = _loc2_.concat(param1["vipItem"]);
         }
         Session.getInstance().addReward(_loc2_);
      }
      
      public function operate_harvestAll(param1:int) : void
      {
         var _loc4_:* = undefined;
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return;
         }
         if(this.m_harvestRequesting == true)
         {
            return;
         }
         if(this.m_harvestAllFlag == true)
         {
            return;
         }
         var _loc2_:Array = this.getHarvestPlaces();
         if(_loc2_ == null || _loc2_.length == 0)
         {
            this.showLandTip("当前农田没有作物可摘取！",param1);
            return;
         }
         if(Session.getInstance().checkHealthMode() == true)
         {
            return;
         }
         if(this.checkRequestFreq("harvest",1) == false)
         {
            return;
         }
         this.m_harvestRequesting = true;
         var _loc3_:* = this.buildCommonPostParams(_loc2_.join(","));
         if(Session.getInstance().me == true)
         {
            EventRecorder.startARequest(EventRecorder.HF_HARVEST);
            NetHelper.sendRequest(CommandDefs.CMD_OPERATE_HARVEST,_loc3_,this.onHarvestAll,this.onNetError);
         }
         else
         {
            _loc4_ = FeartureManager.stealMod();
            if(_loc4_ != false)
            {
               this.alertWindow("tip",_loc4_);
               return;
            }
            _loc4_ = FeartureManager.stealOtherMod();
            if(_loc4_ != false)
            {
               this.alertWindow("tip",_loc4_);
               return;
            }
            if(FeartureManager.openByFlashVar())
            {
               this.alertWindow("tip",Settings.getInstance().getStringAttribute("steal_tips_2"));
               return;
            }
            EventRecorder.startARequest(EventRecorder.HF_SCROUNGE);
            NetHelper.sendRequest(CommandDefs.CMD_OPERATE_SCROUNGE_NEW,_loc3_,this.onHarvestAllScrounge,this.onNetError);
         }
      }
      
      private function onOperateSuccessWater(param1:CommandEvent) : void
      {
         this.checkRequestFreq("water",-1);
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ != null)
         {
            this.farmChange(_loc2_,"humidity",4);
            this.floatHandler(_loc2_);
            Session.getInstance().updateHostAccount(_loc2_["money"],_loc2_["exp"],0);
            dispatchEvent(new CommonEvent(EVENT_LEVELUP,_loc2_));
            dispatchEvent(new CommonEvent(EVENT_CHECK_TASK,{"water":_loc2_}));
            this.recordResp(EventRecorder.HF_WATER,true,"mod=farmlandstatus&act=water");
            dispatchEvent(new Event(EVENT_CHECK_STATUS));
         }
      }
      
      private function onHarvestAllScrounge(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Boolean = false;
         if(Boolean(_loc2_ is Array) && Boolean(_loc2_[0].hasOwnProperty("code")) && _loc2_[0]["code"] == 1)
         {
            _loc3_ = true;
         }
         else if(_loc2_ is Array == false && _loc2_["code"] == 1)
         {
            _loc3_ = true;
         }
         this.recordResp(EventRecorder.HF_SCROUNGE,_loc3_,"mod=farmlandstatus&act=scrounge");
         this.harvestAll(_loc2_);
      }
      
      private function onGetOutputFail(param1:CommandEvent) : void
      {
         EventRecorder.recordErrorEvent("160879",null,4);
      }
      
      public function updateLandData(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int) : void
      {
         var _loc7_:FarmLand = this.getLandData(param1);
         if(_loc7_ == null)
         {
            return;
         }
         if(param5 == 2 && param2 == 0 && param3 == 0)
         {
            this.getOutput(param1);
            return;
         }
         _loc7_._output = param2;
         _loc7_._left = param3;
         _loc7_._min = param4;
         if(param6 != 1)
         {
            _loc7_._bitmap = param5;
         }
         if(param6 >= 0)
         {
            _loc7_._goldLand = param6;
         }
         dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":param1}));
      }
      
      private function buildCommonPostParams(param1:String) : Object
      {
         var _loc2_:Session = Session.getInstance();
         var _loc3_:uint = 0;
         var _loc4_:String = "";
         if(_loc2_.currentUser != null)
         {
            _loc3_ = _loc2_.currentUser._uId;
            _loc4_ = _loc2_.currentUser._userName;
         }
         var _loc5_:String = "";
         if(_loc2_.host != null)
         {
            _loc5_ = _loc2_.host._userName;
         }
         var _loc6_:* = {
            "ownerId":_loc3_,
            "place":param1,
            "tName":_loc4_,
            "fName":_loc5_
         };
         if(_loc2_.friendKeys != null && _loc2_.friendKeys.hasOwnProperty(_loc3_.toString()) == true)
         {
            _loc6_["fkey"] = _loc2_.friendKeys[_loc3_];
         }
         return _loc6_;
      }
      
      public function operate_scarify(param1:int) : void
      {
         var _loc3_:* = undefined;
         if(Session.getInstance().me == false)
         {
            return;
         }
         if(this.m_harvestAllFlag == true)
         {
            return;
         }
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return;
         }
         var _loc2_:FarmLand = this.m_farmlandData[param1];
         if(this.canHandler(param1,_loc2_) == false)
         {
            return;
         }
         if(_loc2_._step == 6 || _loc2_._step == 7)
         {
            this.executeScarify(param1,_loc2_._step);
         }
         else
         {
            _loc3_ = {
               "place":param1,
               "step":_loc2_._step
            };
            dispatchEvent(new CommonEvent(EVENT_CONFIRM_SCARIFY,{
               "callback":this.executeScarify,
               "argument":_loc3_
            }));
         }
      }
      
      private function onOperateSuccessSacrify(param1:CommandEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:FarmLand = null;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["farmlandIndex"] != undefined)
         {
            _loc3_ = int(_loc2_["farmlandIndex"]);
            if(_loc3_ < 0 || _loc3_ >= this.m_farmlandData.length)
            {
               return;
            }
            _loc4_ = this.m_farmlandData[_loc3_];
            _loc4_._cId = 0;
            _loc4_._weed = 0;
            _loc4_._pest = 0;
            _loc4_._humidity = 1;
            _loc4_._cropStatus = 0;
            _loc4_._fertilize = false;
            _loc4_._step = 0;
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":_loc3_}));
         }
         if(_loc2_["randsend"] != undefined)
         {
            dispatchEvent(new CommonEvent(EVENT_DIG_OUT_ITEMS,_loc2_["randsend"]));
         }
         this.showPickIcon();
         this.recordResp(EventRecorder.HF_SCARIFY,true,"mod=farmlandstatus&act=scarify");
         Session.getInstance().updateHostAccount(_loc2_["money"],_loc2_["exp"],0);
         dispatchEvent(new CommonEvent(EVENT_LEVELUP,_loc2_));
         dispatchEvent(new CommonEvent(EVENT_CHECK_TASK,{"scarify":_loc2_}));
         this.setQQBrowserAlarm();
      }
      
      private function delayShowDogHitTip(param1:String) : void
      {
         var _loc2_:String = "<font color=\"#369937\">【农场语录】<br>路边的野花不要采，别人的果实不要摘！</font><br>您在摘取过程中被<font color=\"#009900\"><b>" + param1 + "</b></font>的狗发现<font color=\"#FF6600\"> <b>" + this.m_allFailedLostTimes + "</b></font>次，在逃跑过程中总共丢失<font color=\"#FF6600\"> <b>" + this.m_allFailedLost + "</b> </font>金币。";
         dispatchEvent(new CommonEvent(EVENT_SHOW_TIP,{
            "tip":"DogTip",
            "text":_loc2_
         }));
      }
      
      private function onCallPlaneInGame(param1:CommandEvent) : void
      {
         var onPaySuccess:Function = null;
         var e:CommandEvent = param1;
         onPaySuccess = function(param1:Object):void
         {
            dispatchEvent(new Event(EVENT_PLAY_PLANE));
         };
         var data:* = NetHelper.getVOData(e);
         if(data == null)
         {
            return;
         }
         if(data["ecode"] == 0)
         {
            EventRecorder.recordSueecssEvent("160885",null);
            QzoneJSAPI.getInGamePay(data["url_params"],onPaySuccess);
         }
         else
         {
            EventRecorder.recordErrorEvent("160885",null,4);
            this.alertWindow(Consts.ALERT_TYPE_ERROR,data["direction"]);
         }
      }
      
      private function changeHarvestAllSequence() : void
      {
         var seq:Array = null;
         var order:Function = null;
         order = function(param1:Object, param2:Object):int
         {
            if(param1["farmlandIndex"] == undefined || param2["farmlandIndex"] == undefined)
            {
               return 0;
            }
            return seq.indexOf(param1["farmlandIndex"]) < seq.indexOf(param2["farmlandIndex"]) ? -1 : 1;
         };
         if(this.m_harvestAllArray == null || this.m_harvestAllArray.length == 0)
         {
            return;
         }
         seq = [0,3,6,9,12,15,1,4,7,10,13,16,2,5,8,11,14,17,18,19,20,21,22,23];
         this.m_harvestAllArray.sort(order);
      }
      
      public function setQQBrowserAlarm() : void
      {
         var _loc17_:Object = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:String = null;
         var _loc1_:String = ExternalInterface.call("function BrowserAgent(){return navigator.userAgent;}");
         var _loc2_:RegExp = /QQBrowser\/\d{1,9}.\d{1,9}./;
         var _loc3_:Object = _loc2_.exec(_loc1_);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:RegExp = /\d{1,9}/g;
         var _loc5_:Object = _loc4_.exec(_loc3_[0]);
         var _loc6_:Object = _loc4_.exec(_loc3_[0]);
         if(int(_loc5_[0]) > Consts.QQBROWSER_VER1 || int(_loc5_[0]) == Consts.QQBROWSER_VER1 && int(_loc6_[0]) >= Consts.QQBROWSER_VER2)
         {
            var _loc7_:String = "";
            var _loc8_:FarmLand = null;
            var _loc9_:int = 0;
            var _loc10_:int = 0;
            var _loc11_:int = 0;
            var _loc12_:int = int(this.m_farmlandData.length);
            var _loc13_:Array = [];
            var _loc14_:int = 0;
            while(_loc14_ < _loc12_)
            {
               _loc8_ = this.m_farmlandData[_loc14_] as FarmLand;
               _loc11_ = CommonData.serverTime - _loc8_._plantTime;
               _loc9_ = parseInt(GetCropID.cropTime(_loc8_._cId.toString()).split(",")[4]);
               if(_loc8_._bitmap == 2)
               {
                  _loc18_ = Math.floor(_loc9_ * 0.8) as int;
                  _loc19_ = _loc18_ % 600;
                  if(_loc18_ > _loc19_)
                  {
                     _loc9_ = _loc18_ - _loc19_;
                  }
                  else
                  {
                     _loc9_ = _loc18_;
                  }
               }
               _loc10_ = _loc9_ - _loc11_;
               if(!(_loc8_._cId <= 0 || _loc10_ <= 0))
               {
                  _loc17_ = new Object();
                  _loc17_["name"] = Settings.getInstance().getCropByID(_loc8_._cId.toString())["name"];
                  _loc17_["remain"] = _loc10_;
                  _loc13_.push(_loc17_);
               }
               _loc14_++;
            }
            if(_loc13_.length <= 0)
            {
               _loc20_ = "var ret = window.external.delAlarm(1, " + Session.getInstance().host._uinLogin + ")";
               ExternalInterface.call("eval",_loc20_);
               return;
            }
            _loc13_.sort(this.alarmTimeSort);
            _loc14_ = 0;
            while(_loc14_ < _loc13_.length)
            {
               _loc7_ += _loc13_[_loc14_]["name"] + ",";
               _loc7_ = _loc7_ + (_loc13_[_loc14_]["remain"] + ";");
               _loc14_++;
            }
            _loc7_ = _loc7_.substr(0,_loc7_.length - 1);
            var _loc15_:String = Settings.getInstance().mode == "qzone" ? "" : "http://apps.pengyou.com/353?adtag=applist_shouye";
            var _loc16_:String = "var ret = window.external.setAlarm(1, " + Session.getInstance().host._uinLogin.toString() + ", \'" + (Session.getInstance().host._userName || "农场玩家") + "\', " + _loc13_[0]["remain"].toString() + ", \'农场闹钟\', \'" + _loc7_ + "\',\'" + _loc15_ + "\')";
            ExternalInterface.call("eval",_loc16_);
            return;
         }
      }
      
      public function operate_addBug(param1:int) : void
      {
         var _loc3_:* = undefined;
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return;
         }
         var _loc2_:FarmLand = this.m_farmlandData[param1];
         if(this.canHandler(param1,_loc2_) == false)
         {
            return;
         }
         if(_loc2_._pest >= 3)
         {
            this.showLandTip("这块地无法放虫啦！",param1);
         }
         else if(_loc2_._step != 3 && _loc2_._step != 4)
         {
            this.showLandTip("作物这个阶段不会生虫！",param1);
         }
         else
         {
            if(this.checkRequestFreq("pest",1) == false)
            {
               return;
            }
            if(Session.getInstance().host._canbad <= 0)
            {
               this.showLandTip("每天最多使坏50次哦。",param1);
               return;
            }
            _loc3_ = this.buildCommonPostParams(param1.toString());
            this.m_opQueue.delayRequest(OperationQueue.ADD_BUG,_loc3_);
            ++_loc2_._pest;
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":param1}));
         }
      }
      
      public function beastSteal(param1:int, param2:int) : void
      {
         var _loc3_:FarmLand = this.m_farmlandData[param1] as FarmLand;
         if(_loc3_ != null)
         {
            _loc3_._left -= param2;
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":param1}));
         }
      }
      
      public function operate_clearBug(param1:int) : void
      {
         var _loc3_:* = undefined;
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return;
         }
         var _loc2_:FarmLand = this.m_farmlandData[param1];
         if(_loc2_._pest == 0)
         {
            this.showLandTip("这块地不需要除虫啦！",param1);
         }
         else if(_loc2_._pest > 0)
         {
            if(this.checkRequestFreq("spraying",1) == false)
            {
               return;
            }
            _loc3_ = this.buildCommonPostParams(param1.toString());
            this.m_opQueue.delayRequest(OperationQueue.CLEAR_BUG,_loc3_);
            --_loc2_._pest;
            dispatchEvent(new CommonEvent(EVENT_ADD_HEALTH,{"index":param1}));
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":param1}));
         }
      }
      
      public function nextReclaimCondition() : void
      {
         if(this.m_reclaiming == false)
         {
            this.m_reclaiming = true;
            NetHelper.sendRequest(CommandDefs.CMD_RECLAIM_CONDITION,null,this.onReclaimConditionSuccess,this.onReclaimConditionFailed);
         }
      }
      
      private function floatHandler(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:FarmLand = null;
         if(param1 == null)
         {
            return;
         }
         if(param1.hasOwnProperty("direction") == true && param1["direction"] != "")
         {
            if(param1.hasOwnProperty("poptype") == true && param1["poptype"] == 1)
            {
               _loc2_ = param1["farmlandIndex"] as int;
               if(param1.hasOwnProperty("exp") && param1["exp"] <= 0 && this.firstHelpExpFull && (param1.hasOwnProperty("pest") || param1.hasOwnProperty("weed") || param1.hasOwnProperty("humidity")))
               {
                  _loc3_ = 300;
                  _loc4_ = Session.getInstance().myFairy;
                  if(_loc4_ != null && _loc4_["itemId"] == Consts.FAIRY_LADY)
                  {
                     _loc3_ = 600;
                  }
                  this.showLandTip("每天帮忙最多增加" + _loc3_ + "点经验,您已加满",_loc2_,-7);
                  this.firstHelpExpFull = false;
               }
               else
               {
                  this.showLandTip(param1["direction"],_loc2_);
               }
               if(param1["direction"].indexOf("证据是不能") == 0)
               {
                  _loc5_ = this.m_farmlandData[_loc2_] as FarmLand;
                  if(_loc5_ != null && param1.hasOwnProperty("weed") == true)
                  {
                     _loc5_._weed = param1["weed"];
                  }
                  if(_loc5_ != null && param1.hasOwnProperty("pest") == true)
                  {
                     _loc5_._pest = param1["pest"];
                  }
                  dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":_loc2_}));
               }
            }
         }
         if(param1.hasOwnProperty("canbad") == true)
         {
            Session.getInstance().host._canbad = parseInt(param1["canbad"]);
         }
      }
      
      private function onOperateSuccessAddBug(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.checkRequestFreq("pest",-1);
         this.farmChange(param1,"pest",1);
         this.floatHandler(param1);
         this.doBadFailed(param1);
      }
      
      private function showPickIcon() : void
      {
         dispatchEvent(new CommonEvent(EVENT_SHOW_PICK_ICON,null));
      }
      
      public function countNoneMatureLands() : int
      {
         var _loc5_:FarmLand = null;
         this._refreshLands = new Array();
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Number = Number(CommonData.serverTime);
         var _loc4_:Number = -1;
         for each(_loc5_ in this.m_farmlandData)
         {
            if(_loc5_._cId > 0 && _loc5_._step < 5)
            {
               this._refreshLands.push(_loc2_);
               _loc4_ = GetCropID.timeToMature(_loc3_,_loc5_._cId,_loc5_._plantTime,_loc5_._bitmap);
               _loc1_ += Math.ceil(_loc4_ / 3600) as int;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      private function canHandler(param1:int, param2:FarmLand) : Boolean
      {
         if(param2 == null)
         {
            return false;
         }
         if(param2._cId == 0)
         {
            this.showLandTip("不可以对空地进行这个操作啦！",param1);
            return false;
         }
         return true;
      }
      
      public function growLoop() : void
      {
         var _loc3_:FarmLand = null;
         if(this.m_farmlandData == null)
         {
            return;
         }
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_farmlandData)
         {
            _loc2_ = GetCropID.idState(_loc3_._cId,_loc3_._plantTime,_loc3_._cropStatus,_loc3_._bitmap,_loc3_._harvestTimes);
            if(_loc2_ != _loc3_._step)
            {
               if(_loc2_ == 5)
               {
                  this.getOutput(_loc1_);
               }
               _loc3_._step = _loc2_;
               _loc3_._fertilize = false;
               dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":_loc1_}));
            }
            _loc1_++;
         }
      }
      
      private function getHarvestPlaces() : Array
      {
         var _loc5_:FarmLand = null;
         var _loc6_:Object = null;
         var _loc1_:Boolean = Session.getInstance().me;
         var _loc2_:String = Session.getInstance().hostId;
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < this.m_farmlandData.length)
         {
            _loc5_ = this.m_farmlandData[_loc4_] as FarmLand;
            if(_loc5_._step == 5)
            {
               _loc6_ = _loc5_._thief;
               if(_loc6_ != null && _loc6_.hasOwnProperty(_loc2_) == false)
               {
                  if(_loc5_._left > 0 && (_loc5_._left > _loc5_._min || _loc1_ == true))
                  {
                     _loc3_.push(_loc4_);
                  }
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function onCallPlanePreChecked(param1:CommandEvent) : void
      {
         var _loc3_:* = undefined;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == 1)
         {
            _loc3_ = {
               "itemId":param1.body["__body"]["itemId"],
               "itemNum":param1.body["__body"]["itemNum"],
               "itemType":param1.body["__body"]["itemType"],
               "payType":1,
               "shopType":param1.body["__body"]["shopType"]
            };
            NetHelper.sendRequest(CommandDefs.CMD_BUY_INGAME_BUY,_loc3_,this.onCallPlaneInGame,this.onCallPlaneInGame);
            EventRecorder.recordSueecssEvent("160883",null);
         }
      }
      
      private function doBadFailed(param1:Object) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:FarmLand = null;
         var _loc7_:String = null;
         if(param1 == null)
         {
            return;
         }
         if(param1["poptype"] != undefined && param1["poptype"] == 3)
         {
            if(param1["direction"] == undefined)
            {
               return;
            }
            if(this.m_harvestAllFlag == true)
            {
               this.m_allFailedLost += Math.abs(param1["money"]);
               ++this.m_allFailedLostTimes;
               if(param1["money"] != undefined && param1["money"] <= 0)
               {
                  _loc2_ = {
                     "money":param1["money"],
                     "index":param1["farmlandIndex"]
                  };
                  dispatchEvent(new CommonEvent(EVENT_OPERATE_FAILED,_loc2_));
               }
            }
            else
            {
               _loc3_ = Session.getInstance().currentUser._userName || "他";
               _loc4_ = param1["direction"] || "";
               _loc4_ = _loc4_.split("他").join("<font color=\'#009900\'><b>" + _loc3_ + "</b></font>");
               dispatchEvent(new CommonEvent(EVENT_SHOW_TIP,{
                  "tip":"DogTip",
                  "text":_loc4_
               }));
            }
            if(param1["farmlandIndex"] != undefined)
            {
               _loc5_ = param1["farmlandIndex"] as int;
               if(_loc5_ >= 0 && _loc5_ < this.m_farmlandData.length)
               {
                  _loc6_ = this.m_farmlandData[_loc5_] as FarmLand;
                  _loc7_ = Session.getInstance().hostId;
                  if(_loc6_ != null)
                  {
                     _loc6_._thief[_loc7_] = 1;
                  }
               }
            }
            this.showPickIcon();
         }
      }
      
      private function harvest(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:FarmLand = null;
         var _loc5_:* = undefined;
         this.checkRequestFreq("harvest",-1);
         this.m_harvestRequesting = false;
         var _loc2_:Session = Session.getInstance();
         if(param1["status"] != undefined)
         {
            _loc3_ = int(param1["farmlandIndex"]);
            if(_loc3_ < 0 || _loc3_ >= this.m_farmlandData.length)
            {
               return;
            }
            _loc4_ = this.m_farmlandData[_loc3_] as FarmLand;
            if(_loc4_ == null)
            {
               return;
            }
            _loc4_.copyFrom(param1["status"]);
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":_loc3_}));
            if(param1["harvest"] > 0)
            {
               _loc5_ = {
                  "text":param1["harvest"],
                  "index":_loc3_,
                  "cId":param1["status"]["cId"],
                  "plus":param1["plus"]
               };
               dispatchEvent(new CommonEvent(EVENT_HARVEST_DATA,_loc5_));
               this.m_showDogHitTipDelay = 800;
            }
            else
            {
               this.showPickIcon();
            }
         }
         if(param1["fkey"] != undefined)
         {
            _loc2_.updateCurrentFriendsKeys(param1["fkey"]);
         }
         dispatchEvent(new Event(EVENT_REFRESH_CROP_DATA));
         if(param1["health"] == 1)
         {
            dispatchEvent(new Event(EVENT_HEALTH_MODE_PROTECTED));
         }
         else
         {
            this.doBadFailed(param1);
         }
         _loc2_.updateHostAccount(param1["money"],param1["exp"],0);
         dispatchEvent(new CommonEvent(EVENT_LEVELUP,param1));
         dispatchEvent(new CommonEvent(EVENT_CHECK_TASK,{"harvest":param1}));
         if(param1["gift"] != undefined)
         {
            param1["big"] = true;
            dispatchEvent(new CommonEvent(EVENT_SHOW_GIFT_WINDOW,param1["gift"]));
            this.acceptHarvestGift(param1["gift"]);
         }
         this.gainRandomGift(param1);
         if(Session.getInstance().me)
         {
            this.setQQBrowserAlarm();
         }
         if(param1["code"] == 1 && this.m_harvestAllFlag == false)
         {
            dispatchEvent(new Event(EVENT_HARVEST_OVER));
         }
         if(param1["nsid"] != undefined && param1["nsid"] > 0)
         {
            this.tjShare.push({
               "type":2,
               "id":param1["nsid"]
            });
         }
         else if(param1["ncid"] != undefined && param1["ncid"] > 0)
         {
            this.tjShare.push({
               "type":1,
               "id":param1["ncid"]
            });
         }
         else if(param1["star3"] != undefined && param1["star3"] > 0)
         {
            this.tjShare.push({
               "type":3,
               "id":param1["star3"]
            });
         }
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:FarmLand = null;
         var _loc6_:Number = NaN;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = param1.body["cmdID"] as int;
         if(_loc3_ == CommandDefs.CMD_OPERATE_WATER)
         {
            if(_loc2_.hasOwnProperty("humidity") == true && _loc2_.hasOwnProperty("farmlandIndex") == true)
            {
               _loc4_ = int(_loc2_["farmlandIndex"]);
               if(_loc4_ < 0 || _loc4_ >= this.m_farmlandData.length)
               {
                  return;
               }
               _loc5_ = this.m_farmlandData[_loc4_] as FarmLand;
               if(_loc5_ != null)
               {
                  _loc5_._humidity = _loc2_["humidity"];
                  dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":_loc4_}));
               }
            }
            this.recordResp(EventRecorder.HF_WATER,false,"mod=farmlandstatus&act=water");
            QzoneJSAPI.reportError("浇水操作失败",2);
         }
         else if(_loc3_ == CommandDefs.CMD_OPERATE_SCARIFY)
         {
            this.recordResp(EventRecorder.HF_SCARIFY,false,"mod=farmlandstatus&act=scarify");
            QzoneJSAPI.reportError("铲地操作失败",2);
         }
         else if(_loc3_ == CommandDefs.CMD_OPERATE_PLANT)
         {
            this.recordResp(EventRecorder.HF_PLANTING,false,"mod=farmlandstatus&act=planting");
            QzoneJSAPI.reportError("种植操作失败",2);
         }
         else if(_loc3_ == CommandDefs.CMD_OPERATE_FERTILIZE)
         {
            this.recordResp(EventRecorder.HF_FERTILIZE,false,"mod=farmlandstatus&act=fertilize");
            QzoneJSAPI.reportError("施肥操作失败",2);
         }
         else if(_loc3_ == CommandDefs.CMD_OPERATE_HARVEST)
         {
            this.recordResp(EventRecorder.HF_HARVEST,false,"mod=farmlandstatus&act=harvest");
            this.harvestAll(_loc2_);
            QzoneJSAPI.reportError("收获操作失败",2);
         }
         else if(_loc3_ == CommandDefs.CMD_OPERATE_SCROUNGE_NEW)
         {
            if(_loc2_.hasOwnProperty("errorType") == true)
            {
               if(_loc2_["errorType"] == "ErrFarmkey")
               {
                  this.recordResp(EventRecorder.HF_SCROUNGE,false,"mod=farmlandstatus&act=scrounge",11);
               }
               else if(_loc2_["errorType"] == "ErrFarmTime")
               {
                  this.recordResp(EventRecorder.HF_SCROUNGE,false,"mod=farmlandstatus&act=scrounge",12);
                  if(_loc2_["svrTime"] != undefined)
                  {
                     _loc6_ = parseFloat(_loc2_["svrTime"]);
                     if(isNaN(_loc6_) == false)
                     {
                        CommonData.serverTime = _loc6_;
                        NetHelper.reSendRequest(null);
                        return;
                     }
                  }
               }
            }
            else
            {
               this.recordResp(EventRecorder.HF_SCROUNGE,false,"mod=farmlandstatus&act=scrounge");
            }
            this.harvestAll(_loc2_);
            QzoneJSAPI.reportError("摘取操作失败",2);
         }
         else
         {
            if(_loc3_ == CommandDefs.CMD_BUY_PRECHECK)
            {
               this.alertWindow(Consts.ALERT_TYPE_ERROR,_loc2_["direction"]);
               EventRecorder.recordErrorEvent("160883",null,4);
               return;
            }
            if(_loc3_ == CommandDefs.CMD_RECLAIM_PAY)
            {
               this.alertWindow(Consts.ALERT_TYPE_ERROR,_loc2_["direction"]);
               EventRecorder.recordErrorEvent("160882",null,4);
               return;
            }
            if(_loc3_ == CommandDefs.CMD_RELOAD_GAME_DATA)
            {
               EventRecorder.recordErrorEvent("160884",null,4);
            }
         }
         if(_loc2_["errorType"] == undefined || _loc2_["errorType"] != undefined && _loc2_["errorType"] != Consts.MSG_REQUEST_NET_CLIENT_ERROR)
         {
            this.floatHandler(_loc2_);
         }
      }
      
      private function alertWindow(param1:String, param2:String) : void
      {
         if(param1 == "" || param2 == "")
         {
            return;
         }
         dispatchEvent(new CommonEvent(EVENT_ALERT_WINDOW,{
            "type":param1,
            "text":param2
         }));
      }
      
      public function setUserFarmData(param1:Array) : void
      {
         this.m_farmlandData = param1;
         dispatchEvent(new CommonEvent(EVENT_INITIALZED,this.m_farmlandData));
         this.reGetOutput();
      }
      
      private function gainRandomGift(param1:Object) : void
      {
         var _loc2_:String = null;
         if(param1["plus"] != undefined && param1["money"] != undefined && parseInt(param1["money"]) != 0)
         {
            if(param1["money"] > 0)
            {
               _loc2_ = "RedEventTipB";
            }
            else
            {
               _loc2_ = "RedEventTipA";
            }
            dispatchEvent(new CommonEvent(EVENT_SHOW_TIP,{
               "tip":_loc2_,
               "text":param1["plus"]
            }));
         }
      }
      
      private function onReloadLandsSuccess(param1:CommandEvent) : void
      {
         var _loc2_:StartupData = NetHelper.getVOData(param1) as StartupData;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_._landStatus == null)
         {
            return;
         }
         var _loc3_:FarmLand = null;
         var _loc4_:int = int(_loc2_._landStatus.length);
         var _loc5_:int = int(this.m_farmlandData.length);
         var _loc6_:int = -1;
         var _loc7_:int = 0;
         if(this._refreshAllLands == true)
         {
            _loc7_ = 0;
            while(_loc7_ < _loc4_)
            {
               if(_loc7_ < _loc5_)
               {
                  _loc3_ = _loc2_._landStatus[_loc7_] as FarmLand;
                  if(_loc3_ != null)
                  {
                     this.m_farmlandData[_loc7_] = _loc3_;
                     dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{
                        "index":_loc7_,
                        "animation":false
                     }));
                  }
               }
               _loc7_++;
            }
            this._refreshAllLands = false;
         }
         else
         {
            if(this._refreshLands == null)
            {
               return;
            }
            _loc7_ = 0;
            while(_loc7_ < this._refreshLands.length)
            {
               _loc6_ = int(this._refreshLands[_loc7_]);
               if(!(_loc6_ >= _loc4_ || _loc6_ >= _loc5_))
               {
                  _loc3_ = _loc2_._landStatus[_loc6_] as FarmLand;
                  if(_loc3_ != null)
                  {
                     this.m_farmlandData[_loc6_] = _loc3_;
                     dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{
                        "index":_loc6_,
                        "animation":true
                     }));
                  }
               }
               _loc7_++;
            }
         }
         EventRecorder.recordSueecssEvent("160884",null);
      }
      
      private function onOperateSuccessPlant(param1:CommandEvent) : void
      {
         var _loc5_:int = 0;
         var _loc6_:FarmLand = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc9_:* = undefined;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.hasOwnProperty("farmlandIndex") == true)
         {
            _loc5_ = int(_loc2_["farmlandIndex"]);
            _loc6_ = this.m_farmlandData[_loc5_];
            _loc6_._cId = _loc2_["cId"];
            _loc6_._step = 0;
            _loc6_._plantTime = CommonData.serverTime;
            _loc6_._harvestTimes = 0;
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":_loc5_}));
         }
         dispatchEvent(new CommonEvent(EVENT_REMOVE_MYBAG_ITEM,{
            "id":_loc2_["cId"],
            "type":parseInt(Consts.ITEM_TYPE_SEED)
         }));
         this.recordResp(EventRecorder.HF_PLANTING,true,"mod=farmlandstatus&act=planting");
         this.floatHandler(_loc2_);
         var _loc3_:int = 0;
         var _loc4_:Session = Session.getInstance();
         if(_loc2_.hasOwnProperty("exp") == true)
         {
            if(parseInt(_loc2_["exp"]) > 0)
            {
               _loc3_ = parseInt(_loc2_["exp"]);
               _loc4_.expFullToday = false;
            }
            else if(parseInt(_loc2_["exp"]) == 0)
            {
               if(_loc4_.expFullToday == false)
               {
                  _loc7_ = 150;
                  _loc8_ = Session.getInstance().myFairy;
                  if(_loc8_ != null && _loc8_["itemId"] == Consts.FAIRY_LADY)
                  {
                     _loc7_ = 350;
                  }
                  _loc9_ = {
                     "type":"tip",
                     "title":"提示",
                     "width":390,
                     "height":250,
                     "text":"您已经达到每天种植获得经验上限<font color=\'#ff0000\'>" + _loc7_ + "点</font>，今天以内您将无法通过种植获得经验。"
                  };
                  dispatchEvent(new CommonEvent(EVENT_ALERT_WINDOW,_loc9_));
                  _loc4_.expFullToday = true;
               }
            }
         }
         _loc4_.updateHostAccount(_loc2_["money"],_loc3_,0);
         dispatchEvent(new CommonEvent(EVENT_LEVELUP,_loc2_));
         dispatchEvent(new CommonEvent(EVENT_CHECK_TASK,{"planting":_loc2_}));
         this.setQQBrowserAlarm();
      }
      
      private function harvestAll(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.m_harvestRequesting = false;
         this.m_harvestAllFlag = false;
         if(param1["code"] != 0)
         {
            if(param1 is Array && param1.length > 1)
            {
               this.m_harvestAllFlag = true;
               Session.getInstance().harvestAnimationPlaying = true;
               this.m_allFailedLost = 0;
               this.m_allFailedLostTimes = 0;
               this.m_showDogHitTipDelay = 200;
               this.m_harvestAllArray = param1 as Array;
               this.changeHarvestAllSequence();
               this.onHarvestAllTimer(null);
               if(this.m_harvestAllTimer == null)
               {
                  this.m_harvestAllTimer = new Timer(400);
                  this.m_harvestAllTimer.addEventListener(TimerEvent.TIMER,this.onHarvestAllTimer);
               }
               this.m_harvestAllTimer.reset();
               this.m_harvestAllTimer.start();
            }
            else
            {
               this.harvest(param1);
            }
         }
         else
         {
            this.harvest(param1);
         }
      }
      
      public function operate_addWeed(param1:int) : void
      {
         var _loc3_:* = undefined;
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return;
         }
         var _loc2_:FarmLand = this.m_farmlandData[param1] as FarmLand;
         if(this.canHandler(param1,_loc2_) == false)
         {
            return;
         }
         if(_loc2_._weed >= 3)
         {
            this.showLandTip("这块地无法种草啦！",param1);
         }
         else if(_loc2_._step >= 5)
         {
            this.showLandTip("作物这个阶段不会长草！",param1);
         }
         else
         {
            if(this.checkRequestFreq("scatterWeed",1) == false)
            {
               return;
            }
            if(Session.getInstance().host._canbad <= 0)
            {
               this.showLandTip("每天最多使坏50次哦。",param1);
               return;
            }
            _loc3_ = this.buildCommonPostParams(param1.toString());
            this.m_opQueue.delayRequest(OperationQueue.ADD_WEED,_loc3_);
            ++_loc2_._weed;
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":param1}));
         }
      }
      
      private function onReGetOutputFail(param1:CommandEvent) : void
      {
         EventRecorder.recordErrorEvent("160880",null,4);
      }
      
      private function alarmTimeSort(param1:Object, param2:Object) : int
      {
         if(param1 == null || param2 == null)
         {
            return 0;
         }
         return param1.remain > param2.remain ? 1 : -1;
      }
      
      private function checkRequestFreq(param1:String, param2:int) : Boolean
      {
         if(param1 == "" || param2 == 0)
         {
            return false;
         }
         if(this.m_requestFreq.hasOwnProperty(param1) == false)
         {
            this.m_requestFreq["type"] = {
               "num":0,
               "time":getTimer()
            };
         }
         if(param2 > 0 && this.m_requestFreq["type"]["num"] > 1)
         {
            if(getTimer() - this.m_requestFreq["type"]["time"] < 10000)
            {
               this.m_requestFreq["type"]["time"] = getTimer();
               return false;
            }
            this.m_requestFreq["type"]["num"] = 0;
         }
         this.m_requestFreq["type"]["num"] += param2;
         this.m_requestFreq["type"]["time"] = getTimer();
         return true;
      }
      
      public function reloadAllLands(param1:Boolean) : void
      {
         var _loc2_:* = {
            "ownerId":0,
            "flag":"1"
         };
         this._refreshAllLands = param1;
         this._refreshLands = null;
         NetHelper.sendRequest(CommandDefs.CMD_RELOAD_GAME_DATA,_loc2_,this.onReloadLandsSuccess,this.onNetError);
      }
      
      public function reclaimNewLand() : void
      {
         NetHelper.sendRequest(CommandDefs.CMD_RECLAIM_PAY,null,this.onReclaimSuccess,this.onNetError);
      }
      
      private function farmChange(param1:Object, param2:String, param3:int = 0) : void
      {
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         if(param1 == null)
         {
            return;
         }
         var _loc4_:int = int(param1["farmlandIndex"]);
         if(_loc4_ < 0 || _loc4_ >= this.m_farmlandData.length)
         {
            return;
         }
         var _loc5_:FarmLand = this.m_farmlandData[_loc4_] as FarmLand;
         if(_loc5_ == null)
         {
            return;
         }
         if(param1.hasOwnProperty(param2) == true)
         {
            _loc6_ = -1;
            if(param2 == "humidity")
            {
               _loc6_ = _loc5_._humidity;
            }
            else if(param2 == "weed")
            {
               _loc6_ = _loc5_._weed;
            }
            else if(param2 == "pest")
            {
               _loc6_ = _loc5_._pest;
            }
            if(_loc6_ != param1[param2])
            {
               if(param1["code"] == 1)
               {
                  if(param3 != 0)
                  {
                     if(_loc5_._action is Array)
                     {
                        _loc5_._action = {};
                     }
                     _loc7_ = String(CommonData.serverTime);
                     _loc8_ = [];
                     _loc8_.push(param3);
                     _loc5_._action[_loc7_] = _loc8_;
                  }
               }
               if(param1.hasOwnProperty("humidity") == true)
               {
                  _loc5_._humidity = param1["humidity"];
               }
               if(param1.hasOwnProperty("weed") == true)
               {
                  _loc5_._weed = param1["weed"];
               }
               if(param1.hasOwnProperty("pest") == true)
               {
                  _loc5_._pest = param1["pest"];
               }
               dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":_loc4_}));
            }
         }
         else if(param1.hasOwnProperty("poptype") == true && param1["poptype"] == 1 && param1.hasOwnProperty("direction") == true && param1["direction"].indexOf("最多使坏") != -1)
         {
            if(param2 == "pest" && param3 == 1)
            {
               --_loc5_._pest;
               if(param1.hasOwnProperty("error_repeat") == true)
               {
                  _loc5_._weed -= param1["error_repeat"] as int;
               }
               _loc5_._pest = Math.max(0,_loc5_._pest);
            }
            else if(param2 == "weed" && param3 == 2)
            {
               --_loc5_._weed;
               if(param1.hasOwnProperty("error_repeat") == true)
               {
                  _loc5_._weed -= param1["error_repeat"] as int;
               }
               _loc5_._weed = Math.max(0,_loc5_._weed);
            }
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":_loc4_}));
         }
      }
      
      private function onReclaimConditionSuccess(param1:CommandEvent) : void
      {
         this.m_reclaiming = false;
         var _loc2_:* = NetHelper.getVOData(param1);
         dispatchEvent(new CommonEvent(EVENT_RECLAIM_CONDITION,_loc2_));
         EventRecorder.recordSueecssEvent("160881",null);
      }
      
      private function onReclaimSuccess(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         dispatchEvent(new CommonEvent(EVENT_RECLAIM_RESULT,_loc2_));
         EventRecorder.recordSueecssEvent("160882",null);
      }
      
      public function resetLoadingFlags() : void
      {
         if(this.m_harvestRequesting == true)
         {
            this.m_harvestRequesting = false;
         }
         if(this.m_reclaiming == true)
         {
            this.m_reclaiming = false;
         }
      }
      
      public function operate_water(param1:int) : void
      {
         var _loc3_:* = undefined;
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return;
         }
         var _loc2_:FarmLand = this.m_farmlandData[param1] as FarmLand;
         if(this.canHandler(param1,_loc2_) == false)
         {
            return;
         }
         if(_loc2_._humidity == 1)
         {
            this.showLandTip("这块地不需要浇水啦！",param1);
         }
         else
         {
            if(this.checkRequestFreq("water",1) == false)
            {
               return;
            }
            EventRecorder.startARequest(EventRecorder.HF_WATER);
            _loc3_ = this.buildCommonPostParams(param1.toString());
            NetHelper.sendRequest(CommandDefs.CMD_OPERATE_WATER,_loc3_,this.onOperateSuccessWater,this.onNetError);
         }
      }
      
      public function callPlane() : void
      {
         var _loc1_:int = this.countNoneMatureLands();
         var _loc2_:* = {
            "shopType":Consts.ITEM_TYPE_PLANE,
            "itemType":Consts.ITEM_TYPE_PLANE,
            "itemId":1,
            "itemNum":_loc1_
         };
         NetHelper.sendRequest(CommandDefs.CMD_BUY_PRECHECK,_loc2_,this.onCallPlanePreChecked,this.onNetError);
      }
      
      public function get isAllGoldLand() : int
      {
         var _loc1_:FarmLand = null;
         for each(_loc1_ in this.m_farmlandData)
         {
            if(_loc1_._goldLand != 1)
            {
               return 2;
            }
         }
         if(Boolean(this.m_farmlandData) && this.m_farmlandData.length < 24)
         {
            return 1;
         }
         return 3;
      }
      
      public function landIsFull() : Boolean
      {
         var _loc1_:FarmLand = null;
         for each(_loc1_ in this.m_farmlandData)
         {
            if(!_loc1_ || !_loc1_._cId)
            {
               return false;
            }
         }
         return true;
      }
      
      private function onOperateSuccessClearBug(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.checkRequestFreq("spraying",-1);
         this.farmChange(param1,"pest",5);
         this.floatHandler(param1);
         Session.getInstance().updateHostAccount(param1["money"],param1["exp"],0);
         dispatchEvent(new CommonEvent(EVENT_LEVELUP,param1));
         dispatchEvent(new CommonEvent(EVENT_CHECK_TASK,{"spraying":param1}));
      }
      
      private function executeScarify(param1:int, param2:int) : void
      {
         var _loc3_:Object = this.buildCommonPostParams(param1.toString());
         if(_loc3_ == null)
         {
            return;
         }
         _loc3_["cropStatus"] = param2;
         EventRecorder.startARequest(EventRecorder.HF_SCARIFY);
         NetHelper.sendRequest(CommandDefs.CMD_OPERATE_SCARIFY,_loc3_,this.onOperateSuccessSacrify,this.onNetError);
      }
      
      public function getLandData(param1:int) : FarmLand
      {
         if(this.m_farmlandData == null)
         {
            return null;
         }
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return null;
         }
         return this.m_farmlandData[param1];
      }
      
      public function operate_harvest(param1:int) : void
      {
         var _loc4_:* = undefined;
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return;
         }
         if(this.m_harvestAllFlag == true)
         {
            return;
         }
         if(Session.getInstance().checkHealthMode() == true)
         {
            return;
         }
         var _loc2_:FarmLand = this.m_farmlandData[param1];
         if(this.canHandler(param1,_loc2_) == false)
         {
            return;
         }
         if(this.canHavest(param1,_loc2_) == false)
         {
            return;
         }
         if(this.checkRequestFreq("harvest",1) == false)
         {
            return;
         }
         this.m_harvestRequesting = true;
         var _loc3_:* = null;
         if(Session.getInstance().me == true)
         {
            EventRecorder.startARequest(EventRecorder.HF_HARVEST);
            _loc3_ = this.buildCommonPostParams(param1.toString());
            NetHelper.sendRequest(CommandDefs.CMD_OPERATE_HARVEST,_loc3_,this.onHarvestAll,this.onNetError);
         }
         else
         {
            _loc4_ = FeartureManager.stealMod();
            if(_loc4_ != false)
            {
               this.alertWindow("tip",_loc4_);
               return;
            }
            _loc4_ = FeartureManager.stealOtherMod();
            if(_loc4_ != false)
            {
               this.alertWindow("tip",_loc4_);
               return;
            }
            if(FeartureManager.openByFlashVar())
            {
               this.alertWindow("tip",Settings.getInstance().getStringAttribute("steal_tips_2"));
               return;
            }
            EventRecorder.startARequest(EventRecorder.HF_SCROUNGE);
            _loc3_ = this.buildCommonPostParams(param1.toString());
            NetHelper.sendRequest(CommandDefs.CMD_OPERATE_SCROUNGE_NEW,_loc3_,this.onHarvestAllScrounge,this.onNetError);
         }
      }
      
      private function onOperateSuccessAddWeed(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.checkRequestFreq("scatterWeed",-1);
         this.farmChange(param1,"weed",2);
         this.floatHandler(param1);
         this.doBadFailed(param1);
      }
      
      private function onOperateSuccessFertilize(param1:CommandEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:FarmLand = null;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.hasOwnProperty("farmlandIndex") == true)
         {
            _loc3_ = _loc2_["farmlandIndex"] as int;
            _loc4_ = this.m_farmlandData[_loc3_] as FarmLand;
            if(_loc4_ != null)
            {
               _loc4_.copyFrom(_loc2_["status"]);
               dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{
                  "index":_loc3_,
                  "fertilize":true
               }));
            }
         }
         dispatchEvent(new CommonEvent(EVENT_REMOVE_MYBAG_ITEM,{
            "id":_loc2_["tId"],
            "type":parseInt(Consts.ITEM_TYPE_TOOL)
         }));
         this.recordResp(EventRecorder.HF_FERTILIZE,true,"mod=farmlandstatus&act=fertilize");
         Session.getInstance().updateHostAccount(_loc2_["money"],_loc2_["exp"],0);
         this.setQQBrowserAlarm();
      }
      
      private function onReGetOutput(param1:CommandEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:FarmLand = null;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["farmlandIndex"] != undefined)
         {
            _loc3_ = int(_loc2_["farmlandIndex"]);
            _loc4_ = this.m_farmlandData[_loc3_] as FarmLand;
            if(_loc4_ == null)
            {
               return;
            }
            _loc4_.copyFrom(_loc2_["status"]);
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":_loc3_}));
            EventRecorder.recordSueecssEvent("160880",null);
         }
      }
      
      public function operate_fertilize(param1:int, param2:int) : void
      {
         var _loc5_:Object = null;
         if(Session.getInstance().me == false)
         {
            return;
         }
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return;
         }
         if(param2 <= 0)
         {
            return;
         }
         var _loc3_:FarmLand = this.m_farmlandData[param1] as FarmLand;
         if(this.canHandler(param1,_loc3_) == false)
         {
            return;
         }
         if(_loc3_._step == 5 || _loc3_._step == 6 || _loc3_._step == 7)
         {
            this.showLandTip("作物这个阶段不需要施肥。",param1);
            return;
         }
         if(param2 < Consts.ORGANIC_FERTILIZER_ID)
         {
            if(_loc3_._fertilize == true)
            {
               this.showLandTip("施过肥了，下个阶段再施吧。",param1);
               return;
            }
            _loc5_ = Settings.getInstance().getCropByID(_loc3_._cId.toString());
            if(_loc5_ != null && _loc5_["isYouji"] == 1)
            {
               this.showLandTip("有机种子只能浇有机肥哦~",param1);
               return;
            }
         }
         else if(_loc3_._cId <= 0)
         {
            return;
         }
         var _loc4_:* = this.buildCommonPostParams(param1.toString());
         if(_loc4_ == null)
         {
            return;
         }
         _loc4_["tId"] = param2;
         EventRecorder.startARequest(EventRecorder.HF_FERTILIZE);
         NetHelper.sendRequest(CommandDefs.CMD_OPERATE_FERTILIZE,_loc4_,this.onOperateSuccessFertilize,this.onNetError);
      }
      
      private function onHarvestAll(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Boolean = false;
         if(_loc2_["code"] == 1 || Boolean(_loc2_ is Array && _loc2_[0].hasOwnProperty("code")) && Boolean(_loc2_[0]["code"] == 1))
         {
            _loc3_ = true;
         }
         this.recordResp(EventRecorder.HF_HARVEST,_loc3_,"mod=farmlandstatus&act=harvest");
         this.harvestAll(_loc2_);
      }
      
      private function canHavest(param1:int, param2:FarmLand) : Boolean
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         if(Session.getInstance().me == true)
         {
            if(param2._step == 5)
            {
               return true;
            }
            this.showLandTip("这块地没东西可收获！",param1);
         }
         else if(param2._step != 5)
         {
            this.showLandTip("这块地没东西可偷！",param1);
         }
         else
         {
            _loc3_ = param2._thief;
            _loc4_ = Session.getInstance().hostId;
            if(_loc3_ != null && _loc3_.hasOwnProperty(_loc4_) == true)
            {
               if(_loc3_[_loc4_] == 0)
               {
                  this.showLandTip("狗盯上了您，别做坏事了。",param1);
               }
               else
               {
                  this.showLandTip("做人不能贪得无厌！",param1);
               }
            }
            else
            {
               if(!(param2._left != 0 && param2._left <= param2._min))
               {
                  return true;
               }
               this.showLandTip("行行好吧，我所剩无几了！",param1);
            }
         }
         return false;
      }
      
      public function hasLandToScarify() : Boolean
      {
         var _loc2_:FarmLand = null;
         var _loc1_:Boolean = Session.getInstance().me;
         for each(_loc2_ in this.m_farmlandData)
         {
            if((_loc2_._step == 6 || _loc2_._step == 7) && _loc1_ == true)
            {
               return true;
            }
         }
         return false;
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
      
      public function get refreshLands() : Array
      {
         return this._refreshLands;
      }
      
      private function onHarvestAllTimer(param1:TimerEvent) : void
      {
         var _loc3_:String = null;
         if(this.m_harvestAllArray == null)
         {
            if(this.m_harvestAllTimer != null)
            {
               this.m_harvestAllTimer.stop();
            }
            this.m_harvestAllFlag = false;
            return;
         }
         var _loc2_:Object = null;
         if(this.m_harvestAllArray.length > 0)
         {
            _loc2_ = this.m_harvestAllArray.shift();
         }
         if(_loc2_ != null)
         {
            this.harvest(_loc2_);
         }
         if(this.m_harvestAllArray.length == 0)
         {
            if(this.m_harvestAllTimer != null)
            {
               this.m_harvestAllTimer.stop();
            }
            this.m_harvestAllFlag = false;
            if(this.m_allFailedLostTimes > 0)
            {
               _loc3_ = Session.getInstance().currentUser._userName || "TA";
               setTimeout(this.delayShowDogHitTip,this.m_showDogHitTipDelay,_loc3_);
            }
            Session.getInstance().harvestAnimationPlaying = false;
            dispatchEvent(new Event(EVENT_HARVEST_OVER));
         }
      }
      
      private function onReclaimConditionFailed(param1:CommandEvent) : void
      {
         this.m_reclaiming = false;
         EventRecorder.recordErrorEvent("160881",null,4);
      }
      
      private function onGetOutput(param1:CommandEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:FarmLand = null;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["farmlandIndex"] != undefined)
         {
            _loc3_ = int(_loc2_["farmlandIndex"]);
            if(_loc3_ < 0 || _loc3_ >= this.m_farmlandData.length)
            {
               return;
            }
            _loc4_ = this.m_farmlandData[_loc3_] as FarmLand;
            if(_loc4_ == null)
            {
               return;
            }
            _loc4_.copyFrom(_loc2_["status"]);
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":_loc3_}));
            this.reGetOutput();
            EventRecorder.recordSueecssEvent("160879",null);
         }
      }
      
      public function operate_clearWeed(param1:int) : void
      {
         var _loc3_:* = undefined;
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return;
         }
         var _loc2_:FarmLand = this.m_farmlandData[param1];
         if(_loc2_._weed == 0)
         {
            this.showLandTip("这块地不需要除草啦！",param1);
         }
         else if(_loc2_._weed > 0)
         {
            if(this.checkRequestFreq("clearWeed",1) == false)
            {
               return;
            }
            _loc3_ = this.buildCommonPostParams(param1.toString());
            this.m_opQueue.delayRequest(OperationQueue.CLEAR_WEED,_loc3_);
            --_loc2_._weed;
            dispatchEvent(new CommonEvent(EVENT_ADD_HEALTH,{"index":param1}));
            dispatchEvent(new CommonEvent(EVENT_LAND_CHANGED,{"index":param1}));
         }
      }
      
      private function onOperateSuccessClearWeed(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.checkRequestFreq("clearWeed",-1);
         this.farmChange(param1,"weed",6);
         this.floatHandler(param1);
         Session.getInstance().updateHostAccount(param1["money"],param1["exp"],0);
         dispatchEvent(new CommonEvent(EVENT_LEVELUP,param1));
         dispatchEvent(new CommonEvent(EVENT_CHECK_TASK,{"clearWeed":param1}));
      }
      
      public function operate_plant(param1:int, param2:int) : void
      {
         var _loc4_:* = undefined;
         if(Session.getInstance().me == false)
         {
            return;
         }
         if(param1 < 0 || param1 >= this.m_farmlandData.length)
         {
            return;
         }
         if(param2 <= 0)
         {
            return;
         }
         var _loc3_:FarmLand = this.m_farmlandData[param1] as FarmLand;
         if(_loc3_._cId != 0)
         {
            this.showLandTip("不可以种在这里哦！",param1);
         }
         else
         {
            EventRecorder.startARequest(EventRecorder.HF_PLANTING);
            _loc4_ = this.buildCommonPostParams(param1.toString());
            if(_loc4_ == null)
            {
               return;
            }
            _loc4_["cId"] = param2;
            NetHelper.sendRequest(CommandDefs.CMD_OPERATE_PLANT,_loc4_,this.onOperateSuccessPlant,this.onNetError);
         }
      }
      
      private function showLandTip(param1:String, param2:int, param3:int = 0) : void
      {
         if(param2 < 0 || param2 >= this.m_farmlandData.length)
         {
            return;
         }
         if(param1 == "")
         {
            return;
         }
         var _loc4_:* = {
            "text":param1,
            "index":param2,
            "yAdjust":param3
         };
         dispatchEvent(new CommonEvent(EVENT_OPERATE_INVALID,_loc4_));
      }
      
      public function hasLandToWater() : Boolean
      {
         var _loc1_:FarmLand = null;
         for each(_loc1_ in this.m_farmlandData)
         {
            if(_loc1_._humidity != 1)
            {
               return true;
            }
         }
         return false;
      }
      
      private function onDelayResponseSuccess(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["cmd"] as int;
         var _loc3_:* = param1.data["data"];
         if(_loc3_ == null)
         {
            return;
         }
         switch(_loc2_)
         {
            case OperationQueue.ADD_BUG:
               this.onOperateSuccessAddBug(_loc3_);
               break;
            case OperationQueue.CLEAR_BUG:
               this.onOperateSuccessClearBug(_loc3_);
               break;
            case OperationQueue.ADD_WEED:
               this.onOperateSuccessAddWeed(_loc3_);
               break;
            case OperationQueue.CLEAR_WEED:
               this.onOperateSuccessClearWeed(_loc3_);
         }
         dispatchEvent(new Event(EVENT_CHECK_STATUS));
      }
   }
}

