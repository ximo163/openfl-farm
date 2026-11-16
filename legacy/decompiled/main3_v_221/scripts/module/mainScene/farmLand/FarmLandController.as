package module.mainScene.farmLand
{
   import com.greensock.TweenLite;
   import com.qzone.allianceActivity.AllianceActivityManager;
   import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
   import com.qzone.qui.effects.Move;
   import com.qzone.qui.managers.PopUpManager;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.AlignUtil;
   import com.qzone.utils.GraphicsUtil;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import common.misc.time.CountDown;
   import common.view.cursor.CursorControl;
   import entities.FarmLand;
   import entities.Player;
   import entities.StartupData;
   import events.CommonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.utils.getTimer;
   import framework.base.Controller;
   import interfaces.IModule;
   import interfaces.IMsgCenter;
   import module.mainScene.farmLand.widgets.LandItemRender;
   import report.EventRecorder;
   
   public class FarmLandController extends Controller
   {
      
      private var m_confirmScarifyArg:Object;
      
      private var _beginLoadCrops:uint;
      
      private var _firecracker:MovieClip;
      
      private var m_isInit:Boolean = true;
      
      private var m_confirmScarifyCallback:Function;
      
      private var m_updateFreq:CountDown;
      
      public function FarmLandController(param1:IModule)
      {
         super(param1);
         this.m_confirmScarifyArg = null;
         this.m_confirmScarifyCallback = null;
         this.m_updateFreq = new CountDown(Consts.FARM_LAND_COUNTDOWN);
         this._beginLoadCrops = 0;
      }
      
      private function onUpdateGoldLandTime(param1:CommonEvent) : void
      {
         var _loc2_:int = (m_model as FarmLandModel).isAllGoldLand;
         param1.data.updateGoldLandTimeShow(_loc2_);
      }
      
      private function onSetLandCursor(param1:Event) : void
      {
         this.view.showPickIcon(true);
         var _loc2_:String = module.app.farmView.cursorCtrl.name;
         if(_loc2_ == null || _loc2_ == "")
         {
            module.app.farmView.cursorCtrl.setCursor(Consts.CURSOR_STYLE_ARROW);
         }
      }
      
      public function setNextAction(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:CursorControl = null;
         if(m_module != null && m_module.app != null)
         {
            _loc4_ = m_module.app.farmView.cursorCtrl;
         }
         if(_loc4_ == null)
         {
            return;
         }
         var _loc5_:Boolean = Session.getInstance().me;
         if(_loc5_ == true)
         {
            if(_loc4_.name == Consts.CURSOR_STYLE_HOE)
            {
               if(this.model.hasLandToScarify() == true)
               {
                  return;
               }
            }
         }
         if(param1 == true)
         {
            if(this.m_isInit)
            {
               this.m_isInit = false;
            }
            if(_loc5_ == false)
            {
               if(_loc4_.name == Consts.CURSOR_STYLE_WEED || _loc4_.name == Consts.CURSOR_STYLE_INSET)
               {
                  return;
               }
            }
            if(_loc4_.name != Consts.CURSOR_STYLE_PESTICIDE && _loc4_.name != Consts.CURSOR_STYLE_WATER)
            {
               _loc4_.setCursor(Consts.CURSOR_STYLE_HOOK);
            }
         }
         else if(param2 == true)
         {
            if(this.m_isInit)
            {
               this.m_isInit = false;
            }
            if(_loc5_ == false)
            {
               if(_loc4_.name == Consts.CURSOR_STYLE_WEED || _loc4_.name == Consts.CURSOR_STYLE_INSET)
               {
                  return;
               }
            }
            if(_loc4_.name != Consts.CURSOR_STYLE_WATER)
            {
               _loc4_.setCursor(Consts.CURSOR_STYLE_PESTICIDE);
            }
         }
         else if(param3 == true)
         {
            if(this.m_isInit)
            {
               this.m_isInit = false;
            }
            if(_loc4_.name != Consts.CURSOR_STYLE_WATER)
            {
               _loc4_.setCursor(Consts.CURSOR_STYLE_WATER);
            }
         }
         else if(this.m_isInit == true && this.model.hasLandToScarify() == true)
         {
            this.m_isInit = false;
            if(_loc4_.name != Consts.CURSOR_STYLE_HOE)
            {
               _loc4_.setCursor(Consts.CURSOR_STYLE_HOE);
            }
            return;
         }
      }
      
      private function onSetQQBrowserAlarm(param1:CommonEvent) : void
      {
         this.model.setQQBrowserAlarm();
      }
      
      private function onAlertWindow(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         m_module.app.openWindowByName(Consts.WINDOW_NAME_ALERT,param1.data);
      }
      
      public function showWaterCursor() : Boolean
      {
         var _loc1_:Object = {"fish":false};
         m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_WATER_CURSOR,null,_loc1_));
         if(_loc1_["fish"] == true)
         {
            this.view.loseMouse();
         }
         return _loc1_["fish"];
      }
      
      private function onGoldLandUpdateFail(param1:CommonEvent) : void
      {
         if(param1.data)
         {
            if(param1.data["direction"] != undefined)
            {
               openWindow(Consts.WINDOW_NAME_ALERT,{
                  "icon":Consts.ALERT_TYPE_ERROR,
                  "text":param1.data["direction"]
               });
            }
            else
            {
               openWindow(Consts.WINDOW_NAME_ALERT,{
                  "icon":Consts.ALERT_TYPE_ERROR,
                  "text":"购买失败!"
               });
            }
         }
      }
      
      public function clickOnLand(param1:LandItemRender) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:String = "";
         if(m_module != null && m_module.app != null)
         {
            _loc2_ = m_module.app.farmView.cursorCtrl.name;
         }
         if(_loc2_ == "")
         {
            return;
         }
         var _loc3_:Array = null;
         var _loc4_:String = m_module.app.farmView.cursorCtrl.cursorArgument;
         switch(_loc2_)
         {
            case Consts.CURSOR_STYLE_WATER:
               m_model.operate_water(param1.index);
               break;
            case Consts.CURSOR_STYLE_HOOK:
               m_model.operate_clearWeed(param1.index);
               this.preCheckNextOperate(0);
               break;
            case Consts.CURSOR_STYLE_WEED:
               m_model.operate_addWeed(param1.index);
               break;
            case Consts.CURSOR_STYLE_INSET:
               m_model.operate_addBug(param1.index);
               break;
            case Consts.CURSOR_STYLE_PESTICIDE:
               m_model.operate_clearBug(param1.index);
               this.preCheckNextOperate(1);
               break;
            case Consts.CURSOR_STYLE_HAND:
               m_model.operate_harvest(param1.index);
               break;
            case Consts.CURSOR_STYLE_ONEHAND:
               m_model.operate_harvestAll(param1.index);
               break;
            case Consts.CURSOR_STYLE_HOE:
               m_model.operate_scarify(param1.index);
               break;
            case Consts.CURSOR_STYLE_CROPSEED:
               _loc3_ = _loc4_.split(",");
               if(_loc3_.length < 2 || _loc3_[0] != Consts.ITEM_TYPE_SEED)
               {
                  return;
               }
               m_model.operate_plant(param1.index,parseInt(_loc3_[1]));
               break;
            case Consts.CURSOR_STYLE_TOOL:
               _loc3_ = _loc4_.split(",");
               if(_loc3_.length < 2 || _loc3_[0] != Consts.ITEM_TYPE_TOOL)
               {
                  return;
               }
               m_model.operate_fertilize(param1.index,parseInt(_loc3_[1]));
         }
      }
      
      private function onConfirmScarifyOK() : void
      {
         if(this.m_confirmScarifyArg == null)
         {
            return;
         }
         if(this.m_confirmScarifyCallback == null)
         {
            return;
         }
         if(this.m_confirmScarifyArg["place"] != undefined && this.m_confirmScarifyArg["step"] != undefined)
         {
            this.m_confirmScarifyCallback(this.m_confirmScarifyArg["place"] as int,this.m_confirmScarifyArg["step"] as int);
         }
         this.m_confirmScarifyArg = null;
         this.m_confirmScarifyCallback = null;
      }
      
      private function confirmReclaim() : void
      {
         m_model.reclaimNewLand();
      }
      
      private function onCropDataChanged(param1:Event) : void
      {
         if(m_module != null && m_module.app != null)
         {
            m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG,null));
         }
      }
      
      override public function finalize() : void
      {
         if(m_model != null)
         {
            m_model = null;
         }
      }
      
      private function onReclaimSuccess(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         if(_loc2_["code"] == 1)
         {
            Session.getInstance().updateHostAccount(_loc2_["money"],0,0);
            if(m_module != null && m_module.app != null)
            {
               m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER,null));
            }
         }
         else
         {
            openWindow(Consts.WINDOW_NAME_ALERT,{
               "icon":Consts.ALERT_TYPE_ERROR,
               "text":_loc2_["direction"]
            });
         }
      }
      
      private function onPlaneLoaded() : void
      {
         var _loc1_:MovieClip = null;
         m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG,{"showLoading":false}));
         _loc1_ = Utils.getMaterial("PlaneWindow") as MovieClip;
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:Stage = CommonData.root["stage"] as Stage;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Sprite = new Sprite();
         GraphicsUtil.draw(_loc3_,Style.popUpModalColor,Style.popUpModalAlpha,new Rectangle(0,0,_loc2_.stageWidth,_loc2_.stageHeight),true);
         _loc2_.addChild(_loc3_);
         _loc1_.name = "__plane__";
         _loc1_["__mask__"] = _loc3_;
         _loc1_.x = AlignUtil.middle(_loc2_.stageWidth,_loc1_.width) + 65;
         _loc1_.y = AlignUtil.middle(_loc2_.stageHeight,_loc1_.height);
         _loc1_.filters = Style.getShadowFilter();
         _loc2_.addChild(_loc1_);
         var _loc4_:int = this.model.countNoneMatureLands();
         var _loc5_:int = _loc4_ * 3;
         _loc1_["tfHrs"].text = _loc4_;
         _loc1_["tfQD"].text = _loc5_;
         var _loc6_:String = "";
         if(Settings.getInstance().getStringAttribute("PlaneDiscount") != "1")
         {
            _loc1_["tf1"].text = "仅年费VIP尊享此功能";
         }
         if(Session.getInstance().isMeVIP == true)
         {
            _loc6_ += "&nbsp;x&nbsp;0.8";
            _loc5_ *= 0.8;
         }
         else
         {
            _loc6_ += "&nbsp;x&nbsp;1.0";
         }
         _loc5_ = Math.floor(_loc5_) as int;
         _loc1_["tfSum"].htmlText = "<font color=\'#E17204\'>" + (_loc4_ * 3).toString() + "</font>&nbsp;元宝" + _loc6_ + "&nbsp;=&nbsp;<font color=\'#E17204\'>" + _loc5_ + "</font>&nbsp;元宝";
         if(_loc4_ == 0)
         {
            _loc1_["btnOK"].mouseEnabled = false;
            _loc1_["btnOK"].filters = Style.getDisableFilter();
         }
         else
         {
            _loc1_["btnOK"].mouseEnabled = true;
            _loc1_["btnOK"].filters = null;
         }
         _loc1_.addEventListener(MouseEvent.CLICK,this.onPlaneWindowClicked,false,0,true);
      }
      
      private function onHealthModeTimeout(param1:CommonEvent) : void
      {
         hideTip();
         this.view.showPickIcon(false);
      }
      
      public function get view() : FarmLandsView
      {
         return m_view as FarmLandsView;
      }
      
      public function setHandCursor() : void
      {
         var _loc1_:CursorControl = null;
         if(m_module != null && m_module.app != null)
         {
            _loc1_ = m_module.app.farmView.cursorCtrl;
         }
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:Session = Session.getInstance();
         if(this.isOneClickMode() == true || !_loc2_.currentUser.me)
         {
            if(_loc1_.name != Consts.CURSOR_STYLE_ONEHAND && _loc1_.name != Consts.CURSOR_STYLE_HAND && _loc1_.name != Consts.CURSOR_STYLE_HOE)
            {
               _loc1_.setCursor(Consts.CURSOR_STYLE_ONEHAND);
            }
         }
         else if(_loc1_.name != Consts.CURSOR_STYLE_HAND && _loc1_.name != Consts.CURSOR_STYLE_HOE)
         {
            _loc1_.setCursor(Consts.CURSOR_STYLE_HAND);
         }
      }
      
      public function get model() : FarmLandModel
      {
         return m_model as FarmLandModel;
      }
      
      private function onPlaneClicked(param1:Event) : void
      {
         var _loc2_:String = Settings.getInstance().getSecondUrl("plane");
         if(_loc2_ == null || _loc2_ == "")
         {
            return;
         }
         m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG,{"showLoading":true}));
         CommonData.rslManager.requestClass("PlaneWindow",this.onPlaneLoaded,_loc2_);
      }
      
      private function preCheckNextOperate(param1:int) : void
      {
         var _loc2_:CursorControl = null;
         if(m_module != null && m_module.app != null)
         {
            _loc2_ = m_module.app.farmView.cursorCtrl;
         }
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:FarmLand = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:int = this.view.landNum;
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            _loc3_ = this.model.getLandData(_loc8_);
            if(_loc3_ != null)
            {
               if(_loc4_ == false)
               {
                  _loc4_ = _loc3_.hasPest;
               }
               if(_loc5_ == false)
               {
                  _loc5_ = _loc3_.hasWeed;
               }
               if(_loc6_ == false)
               {
                  _loc6_ = _loc3_.needWater;
               }
            }
            _loc8_++;
         }
         if(param1 == 0)
         {
            if(_loc5_ == false)
            {
               if(_loc4_ == true)
               {
                  _loc2_.setCursor(Consts.CURSOR_STYLE_PESTICIDE);
               }
               else if(_loc6_ == true)
               {
                  _loc2_.setCursor(Consts.CURSOR_STYLE_WATER);
               }
            }
         }
         else if(param1 == 1)
         {
            if(_loc4_ == false)
            {
               if(_loc5_ == true)
               {
                  _loc2_.setCursor(Consts.CURSOR_STYLE_HOOK);
               }
               else if(_loc6_ == true)
               {
                  _loc2_.setCursor(Consts.CURSOR_STYLE_WATER);
               }
            }
         }
      }
      
      public function onGameLoop(param1:Number) : void
      {
         var _loc2_:IAllianceActivityContext = null;
         var _loc3_:Number = NaN;
         if(this.m_updateFreq.isReady() == false)
         {
            return;
         }
         this.m_updateFreq.reset(Consts.FARM_LAND_COUNTDOWN);
         if(this.model != null)
         {
            this.model.growLoop();
            if(this.model.tjShare != null && this.model.tjShare.length > 0)
            {
               _loc2_ = AllianceActivityManager.getInstance().getActivityContext("collecting");
               if(_loc2_ != null)
               {
                  _loc2_.execute("10004",this.model.tjShare);
                  this.model.tjShare = [];
               }
            }
         }
         if(this.view != null)
         {
            this.view.talkRandom();
         }
         if(this._beginLoadCrops > 0)
         {
            _loc3_ = getTimer() - this._beginLoadCrops;
            if(this.view.checkCropLoaded() == true)
            {
               EventRecorder.recordSueecssEvent("160452",_loc3_);
               this._beginLoadCrops = 0;
            }
            else if(_loc3_ > 7)
            {
               EventRecorder.recordErrorEvent("160452",_loc3_,EventRecorder.TIME_OUT);
               this._beginLoadCrops = 0;
            }
         }
      }
      
      private function onConfirmScarify(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Function = param1.data["callback"] as Function;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = param1.data["argument"] as Object;
         if(_loc3_ == null)
         {
            return;
         }
         this.m_confirmScarifyArg = _loc3_;
         this.m_confirmScarifyCallback = _loc2_;
         var _loc4_:* = {
            "title":"铲除作物",
            "text":"作物还没有收获，真的要铲除吗？",
            "confirmFn":this.onConfirmScarifyOK
         };
         m_module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM,_loc4_);
      }
      
      private function onPlayUpgradeRedLandAnimatin(param1:CommonEvent) : void
      {
         var redUpLoader:Loader;
         var url:String;
         var data:* = undefined;
         var e:CommonEvent = param1;
         if(e == null || e.data == null)
         {
            return;
         }
         data = e.data;
         if(data["black"] == true && data["error"] != undefined)
         {
            if(data["error"] != "" && data["place"] != undefined)
            {
               this.view.openLandFloatTip(data["error"],data["place"]);
            }
            return;
         }
         url = Settings.getInstance().getSecondUrl("redup");
         if(url == "")
         {
            return;
         }
         redUpLoader = new Loader();
         redUpLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function(param1:Event):void
         {
            var _loc2_:int = data["red"] == true ? 1 : 0;
            _loc2_ = data["black"] == true ? 2 : _loc2_;
            var _loc3_:String = _loc2_ == 1 ? "红土地升级成功!" : "";
            _loc3_ = _loc2_ == 2 ? "黑土地升级成功!" : _loc3_;
            if(data["gold"])
            {
               _loc3_ = "金牌土地升级成功!";
            }
            openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc3_,
               "parent":m_view.stage
            });
            model.updateLandData(data["place"] as int,data["output"] as int,data["leavings"] as int,data["min"] as int,_loc2_,data["gold"] ? 1 : 0);
         });
         redUpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(param1:Event):void
         {
            param1.currentTarget.removeEventListener(Event.COMPLETE,arguments.callee);
            view.playUpgradeRed(data["place"] as int,param1.currentTarget.content as Sprite,data);
         });
         redUpLoader.load(new URLRequest(url),new LoaderContext(true));
      }
      
      private function onShowLandCursor(param1:CommonEvent) : void
      {
         var _loc2_:CursorControl = null;
         this.view.showPickIcon(true,true);
         if(param1.result != null)
         {
            _loc2_ = m_module.app.farmView.cursorCtrl;
            if(_loc2_ != null && _loc2_.name == Consts.CURSOR_STYLE_HAND || _loc2_.name == Consts.CURSOR_STYLE_ONEHAND)
            {
               param1.result["harvest"] = true;
            }
            else
            {
               this.view.loseMouse();
            }
         }
      }
      
      private function onReclaimResult(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         var _loc3_:Player = Session.getInstance().host;
         var _loc4_:int = Math.sqrt((_loc3_._exp + 25) / 100) - 0.5;
         var _loc5_:Number = _loc3_._money;
         var _loc6_:int = parseInt(_loc2_["level"]);
         var _loc7_:int = parseInt(_loc2_["money"]);
         var _loc8_:String = "";
         if(_loc4_ < _loc6_ && _loc5_ < _loc7_)
         {
            _loc8_ = Language.L["对不起，您的金币和等级均不足。"];
         }
         else if(_loc4_ < _loc6_)
         {
            _loc8_ = Language.L["对不起，您的等级不足。"];
         }
         else if(_loc5_ < _loc7_)
         {
            _loc8_ = Language.L["对不起，您的金币不足。"];
         }
         var _loc9_:Object = {
            "level":_loc6_,
            "money":_loc7_
         };
         var _loc10_:String = Language.replaceText("reclaimPayText",_loc9_);
         var _loc11_:* = {
            "title":Language.L["扩建农场"],
            "text":_loc10_,
            "confirmFn":this.confirmReclaim
         };
         if(_loc8_ != "")
         {
            _loc11_["confirmEnable"] = false;
            _loc11_["error"] = _loc8_;
         }
         openWindow(Consts.WINDOW_NAME_CONFIRM,_loc11_);
      }
      
      private function onGetLandData(param1:CommonEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:FarmLand = null;
         while(_loc4_ < 24)
         {
            _loc3_ = this.model.getLandData(_loc4_);
            if(_loc3_ != null && _loc3_._cId > 0 && _loc3_._step < 6)
            {
               _loc2_.push(_loc3_._cId);
            }
            _loc4_++;
         }
         param1.result = _loc2_;
      }
      
      private function onPopupTip(param1:CommonEvent = null) : void
      {
         var tip:String;
         var text:String;
         var dogTip:* = undefined;
         var e:CommonEvent = param1;
         if(e == null || e.data == null)
         {
            return;
         }
         tip = e.data["tip"] as String;
         text = e.data["text"] as String;
         if(tip == "" || text == "")
         {
            return;
         }
         dogTip = Utils.getMaterial(tip);
         if(dogTip != null)
         {
            dogTip.effect = Move;
            dogTip.mouseChildren = false;
            dogTip.mouseEnabled = false;
            dogTip.cacheAsBitmp = true;
            if(dogTip["tipText"] != undefined)
            {
               dogTip["tipText"].htmlText = text;
            }
            else if(dogTip["txt"] != undefined)
            {
               dogTip["txt"].htmlText = text;
            }
            PopUpManager.addPopUp(dogTip);
            TweenLite.delayedCall(2,function():void
            {
               PopUpManager.removePopUp(dogTip);
            });
         }
      }
      
      private function isOneClickMode() : Boolean
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:Array = null;
         var _loc1_:Date = new Date();
         _loc1_.setTime(CommonData.serverTime * 1000);
         var _loc2_:int = _loc1_.getHours();
         var _loc3_:String = Settings.getInstance().getStringAttribute("batchStealHour");
         if(_loc3_ != "")
         {
            _loc4_ = [];
            _loc5_ = _loc3_.split(",");
            for each(_loc6_ in _loc5_)
            {
               _loc8_ = _loc6_.split("-");
               _loc4_.push({
                  "from":_loc8_[0],
                  "to":_loc8_[1]
               });
            }
            for each(_loc7_ in _loc4_)
            {
               if(_loc2_ >= _loc7_["from"] && _loc2_ < _loc7_["to"])
               {
                  return true;
               }
            }
         }
         if(_loc2_ >= 6 && _loc2_ < 10)
         {
            return true;
         }
         return false;
      }
      
      private function onGameDataReloaded(param1:CommonEvent) : void
      {
         this.onStartupData(param1);
         this.view.hideTalkTip();
         this._beginLoadCrops = 0;
      }
      
      private function onFarmLandChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         if(_loc2_ < 0)
         {
            return;
         }
         var _loc3_:FarmLand = this.model.getLandData(_loc2_);
         if(_loc3_ == null)
         {
            return;
         }
         if(m_module.app != null && m_module.app.farmView != null)
         {
            m_module.app.farmView.tipCtrl.update(Consts.TIP_NAME_LAND_INFOR,_loc3_);
         }
         if(Boolean(m_module.app) && this.model.landIsFull())
         {
            if(m_module.app.farmView.cursorCtrl.name == Consts.CURSOR_STYLE_CROPSEED)
            {
               m_module.app.dispatchEvent(new Event(Consts.CLOSE_MY_BAG));
            }
         }
      }
      
      private function onDigOutItems(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data == undefined)
         {
            return;
         }
         m_module.app.openWindowByName(Consts.WINDOW_NAME_REGIFT,{
            "send":param1.data,
            "dig":true
         });
      }
      
      private function showPickIcon(param1:CommonEvent) : void
      {
         this.view.showPickIcon(true);
      }
      
      private function onPlaneWindowClicked(param1:MouseEvent) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:DisplayObjectContainer = CommonData.root["stage"] as DisplayObjectContainer;
         if(_loc2_ == null)
         {
            return;
         }
         if(param1.target.name == "btnOK")
         {
            this.model.callPlane();
         }
         if(param1.target.name == "btnClose" || param1.target.name == "btnOK")
         {
            _loc3_ = _loc2_.getChildByName("__plane__") as MovieClip;
            if(_loc3_ != null)
            {
               _loc2_.removeChild(_loc3_);
               if(_loc3_["__mask__"] != undefined)
               {
                  _loc2_.removeChild(_loc3_["__mask__"]);
               }
               _loc3_["__mask__"] = null;
               _loc3_ = null;
            }
         }
      }
      
      private function registerListeners() : void
      {
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_STARTUP_DATA,this.onStartupData,false,0,true);
            _loc1_.addEventListener(Consts.MSG_RELOAD_GAME_RESULT,this.onGameDataReloaded,false,0,true);
            _loc1_.addEventListener(Consts.MSG_PLAY_UPGRADE_RED_LAND,this.onPlayUpgradeRedLandAnimatin,false,0,true);
            _loc1_.addEventListener(Consts.MSG_HEALTHMODE_TIMEOUT,this.onHealthModeTimeout,false,0,true);
            _loc1_.addEventListener(Consts.MSG_WILD_BEAST_STEAL,this.onBeastSteal,false,0,true);
            _loc1_.addEventListener(Consts.MSG_WILD_TO_FARMSTAGE,this.showPickIcon,false,0,true);
            _loc1_.addEventListener(Consts.MSG_SET_LAND_CURSOR,this.onSetLandCursor,false,0,true);
            _loc1_.addEventListener(Consts.MSG_SET_QQBROWSER_ALARM,this.onSetQQBrowserAlarm,false,0,true);
            _loc1_.addEventListener(Consts.MSG_SHOW_LAND_CURSOR,this.onShowLandCursor,false,0,true);
            _loc1_.addEventListener(Consts.MSG_CALL_PLANE,this.onPlaneClicked,false,0,true);
            _loc1_.addEventListener(Consts.MSG_REFRESH_LANDS_DATA,this.onRefreshAllLands,false,0,true);
            _loc1_.addEventListener(Consts.MSG_GET_LAND_DATA,this.onGetLandData,false,0,true);
            _loc1_.addEventListener(Consts.GOLD_LAND_UPDATE_TIME,this.onUpdateGoldLandTime,false,0,true);
            _loc1_.addEventListener(Consts.GOLD_LAND_BUY_FAIL,this.onGoldLandUpdateFail,false,0,true);
         }
         if(m_model != null)
         {
            m_model.addEventListener(FarmLandModel.EVENT_DIG_OUT_ITEMS,this.onDigOutItems,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_SHOW_TIP,this.onPopupTip,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_SHOW_GIFT_WINDOW,this.onGiftWindow,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_ALERT_WINDOW,this.onAlertWindow,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_CONFIRM_SCARIFY,this.onConfirmScarify,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_LAND_CHANGED,this.onFarmLandChanged,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_REFRESH_CROP_DATA,this.onCropDataChanged,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_REMOVE_MYBAG_ITEM,this.onMyBagDataRemoved,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_RECLAIM_CONDITION,this.onReclaimResult,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_RECLAIM_RESULT,this.onReclaimSuccess,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_HEALTH_MODE_PROTECTED,this.onHealthModeProtected,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_CHECK_TASK,this.onCheckTaskComplete,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_LEVELUP,this.onLevelUp,false,0,true);
            m_model.addEventListener(FarmLandModel.EVENT_HARVEST_OVER,this.onHarvestOver,false,0,true);
         }
      }
      
      private function onLevelUp(param1:CommonEvent) : void
      {
         if(param1 != null && param1.data != null)
         {
            m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_LEVELUP,param1.data));
         }
      }
      
      private function onRefreshAllLands(param1:CommonEvent) : void
      {
         this.model.reloadAllLands(true);
      }
      
      private function onCheckTaskComplete(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         module.app.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_TASK,param1.data));
      }
      
      private function onStartupData(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:StartupData = param1.data as StartupData;
         if(_loc2_ == null)
         {
            return;
         }
         this.model.setUserFarmData(_loc2_._landStatus);
         if(param1.type == Consts.MSG_STARTUP_DATA)
         {
            this._beginLoadCrops = getTimer();
         }
      }
      
      override public function initialze() : void
      {
         if(m_model == null)
         {
            m_model = new FarmLandModel();
         }
         this.registerListeners();
         if(m_view == null)
         {
            m_view = new FarmLandsView(this);
            if(m_module != null && m_module.container != null)
            {
               m_module.container.addChild(m_view);
            }
         }
      }
      
      private function onHealthModeProtected(param1:Event) : void
      {
         module.app.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_HEALTHMODE,{"sync":true}));
      }
      
      private function onBeastSteal(param1:CommonEvent) : void
      {
         var _loc2_:int = param1.data.farmIdx as int;
         var _loc3_:int = param1.data.num as int;
         this.model.beastSteal(_loc2_,_loc3_);
      }
      
      public function switchMode(param1:Boolean) : void
      {
         this.view.hideTalkTip();
         if(param1 == true)
         {
            this.view.scaleX = this.view.scaleY = 1.3;
         }
         else
         {
            this.view.scaleX = this.view.scaleY = 1;
         }
      }
      
      private function onMyBagDataRemoved(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(m_module != null && m_module.app != null)
         {
            m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_DATA_REMOVE,param1.data));
         }
      }
      
      private function onHarvestOver(param1:Event) : void
      {
         var _loc7_:Object = null;
         this.view.showPickIcon(true);
         var _loc2_:Session = Session.getInstance();
         var _loc3_:String = _loc2_.hostId;
         var _loc4_:FarmLand = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         while(_loc6_ < 24)
         {
            _loc4_ = this.model.getLandData(_loc6_);
            if(_loc4_ != null)
            {
               if(_loc4_._step == 5 && !(_loc2_.healthModeValid == true || _loc2_.currentFarmHealthModeValid == true))
               {
                  _loc7_ = _loc4_._thief;
                  if(_loc7_ != null && _loc7_.hasOwnProperty(_loc3_) == false)
                  {
                     if(_loc4_._left > 0 && (_loc4_._left > _loc4_._min || _loc2_.me == true))
                     {
                        _loc5_ = true;
                     }
                  }
               }
            }
            _loc6_++;
         }
         if(_loc5_ == false)
         {
            this.showWaterCursor();
         }
      }
      
      private function onGiftWindow(param1:CommonEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1 == null || param1.data == null || param1.data == "")
         {
            return;
         }
         param1.data["big"] = true;
         if(param1.data is Array && param1.data.length == 1 && param1.data[0]["eType"] == Consts.ITEM_TYPE_CARD)
         {
            m_module.app.openWindowByName(Consts.WINDOW_NAME_REGIFT_CARD,param1.data);
         }
         else
         {
            _loc2_ = param1.data["item"] as Array;
            if(_loc2_ == null)
            {
               return;
            }
            if(_loc2_[0]["eType"] == "6" && (_loc2_[0]["eNum"] == "66" || _loc2_[0]["eNum"] == "666"))
            {
               param1.data["title"] = "温馨提示";
               _loc3_ = _loc2_[0]["eNum"] + "金币";
               param1.data["direction"] = "\n哇！幸运哦！！\n<font color=\"#FF0000\">获得奖励：</font ><font color=\"#FF0000\">" + _loc3_ + "</font>";
            }
            else
            {
               _loc4_ = "红土地";
               if(this.model.hasBlackLand == true)
               {
                  _loc4_ = "红黑土地";
               }
               param1.data["title"] = _loc4_ + "事件";
               param1.data["direction"] = "\n哇！在" + _loc4_ + "上进行收获时发现了宝贝！" + _loc4_ + "不仅可以培育奇珍异草，珍贵名药，还有更多普通土地没有的幸运哦！！\n";
            }
            m_module.app.openWindowByName(Consts.WINDOW_NAME_GIFT,param1.data);
         }
      }
   }
}

