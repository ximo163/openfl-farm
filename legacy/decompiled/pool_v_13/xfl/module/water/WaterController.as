package module.water
{
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.misc.Cookies;
   import common.misc.Utils;
   import common.misc.time.CountDown;
   import common.view.cursor.CursorControl;
   import entities.PoolFish;
   import events.CommonEvent;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import framework.base.Controller;
   import interfaces.IMsgCenter;
   import module.GameGuide;
   
   public class WaterController extends Controller
   {
      
      private var m_updateFreq:CountDown;
      
      private const ITEM_HEIGHT:Number = 76.5;
      
      private var _infoWindow:PoolInfoWindow;
      
      private var _batchProcessTime:Number;
      
      private var _disableInfoWin:Boolean;
      
      private var _grayOpen:WaterGrayOpen;
      
      private const ITEM_WIDTH:Number = 153;
      
      public function WaterController()
      {
         super(null);
         this.m_updateFreq = new CountDown(Consts.FARM_LAND_COUNTDOWN);
         this._grayOpen = null;
         this._batchProcessTime = -1;
         this._disableInfoWin = false;
      }
      
      private function onFishLoaded(param1:CommonEvent) : void
      {
         var _loc4_:Array = null;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:Boolean = false;
         var _loc8_:Object = null;
         var _loc9_:CursorControl = null;
         var _loc2_:Session = Session.getInstance();
         var _loc3_:Boolean = Boolean(_loc2_.me);
         if(this.model.opened == true)
         {
            _loc4_ = param1.data as Array;
            if(_loc4_ == null || _loc4_.length == 0)
            {
               this.view.reset();
            }
            else
            {
               this.view.fillFishes(_loc4_);
            }
            if(_loc3_ == true)
            {
               _loc7_ = Boolean(_loc2_.m_waterPoolOpen);
               if(_loc7_ == false)
               {
                  _loc2_.m_waterPoolOpen = true;
                  m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_POOL_OPEN,true));
               }
            }
            this.updatePoolInfoBtn();
            _loc5_ = uint(_loc2_.currentUser._uId);
            _loc6_ = uint(_loc2_.currentUserIdByUinMode);
            if(this.model.canSteal(_loc3_) == false)
            {
               if(_loc3_ == false)
               {
                  Cookies.setObject("f_" + _loc6_,CommonData.serverTime);
               }
               else
               {
                  this.adjustCursorFirstTime();
               }
               m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_FISH_FRIENDLIST,{
                  "uId":_loc2_.currentUserIdByUinMode,
                  "ownerId":_loc5_,
                  "hasFish":false,
                  "check":true
               }));
            }
            else
            {
               _loc8_ = {"harvest":false};
               m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_LAND_CURSOR,null,_loc8_));
               if(_loc8_["harvest"] == false)
               {
                  _loc9_ = m_module.app.farmView.cursorCtrl;
                  if(_loc9_ != null)
                  {
                     _loc9_.setCursor(Consts.CURSOR_STYLE_FISHNET_ALL);
                  }
               }
               m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_FISH_FRIENDLIST,{
                  "uId":_loc2_.currentUserIdByUinMode,
                  "ownerId":_loc5_,
                  "hasFish":true,
                  "check":true
               }));
            }
         }
         else if(_loc3_ == true)
         {
            if(this._grayOpen == null)
            {
               this._grayOpen = new WaterGrayOpen(this,this.view);
            }
            this._grayOpen.flag = this.model.whited;
         }
      }
      
      private function onShowErrorMsg(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.view.showErrorMsg(param1.data["msg"],param1.data["id"]);
      }
      
      private function onShowPoolInfo(param1:Event) : void
      {
         if(this._disableInfoWin == true)
         {
            return;
         }
         if(this._infoWindow == null)
         {
            this._infoWindow = new PoolInfoWindow(m_module.app);
         }
         this._infoWindow.data = {"fishes":this.model.poolFishes};
         m_module.app.farmView.winCtrl.open(this._infoWindow);
      }
      
      private function onShowGuideArrow(param1:CommonEvent) : void
      {
         if(param1.data["step"] == GameGuide.WATER_POOL_CENTER)
         {
            this.view.showGuideArrow(param1.data["step"]);
         }
      }
      
      private function onBatchProcessFish(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.view.disableMouse = param1.data >= 1;
         this._disableInfoWin = true;
         if(param1.data == 0)
         {
            m_module.app.useSystemCursor(false);
         }
         else if(param1.data == 2)
         {
            this._batchProcessTime = 1200;
         }
      }
      
      private function onGrowUp(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:PoolFish = param1.data["fish"] as PoolFish;
         var _loc3_:int = param1.data["food"] as int;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc4_:FishMover = this.view.findFishByID(_loc2_._id);
         if(_loc4_ != null)
         {
            _loc4_.grow();
            this.view.refreshInfoTip(_loc2_);
            this.view.refreshMatureFlag(false);
         }
         m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_DATA_REMOVE,{
            "type":parseInt(Consts.ITEM_TYPE_FISHFEED),
            "id":_loc3_
         }));
      }
      
      public function restoreLandCursor() : void
      {
         m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_LAND_CURSOR,null));
      }
      
      private function updatePoolInfoBtn() : void
      {
         var _loc1_:Boolean = Boolean(Session.getInstance().me);
         m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_POOLINFO,{"size":(_loc1_ ? this.model.poolSize : -1)}));
      }
      
      private function onFishHarvest(param1:CommonEvent) : void
      {
         var _loc7_:uint = 0;
         if(param1.data == null)
         {
            return;
         }
         if(param1 != null && param1.data != null && param1.data["count"] > 0)
         {
            m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_FISH_RELOAD_FLAG,null));
         }
         this.updatePoolInfoBtn();
         var _loc2_:int = param1.data["count"] as int;
         var _loc3_:int = param1.data["id"] as int;
         var _loc4_:Boolean = param1.data["remove"] as Boolean;
         this.view.harvestFish(_loc3_,_loc2_,_loc4_);
         var _loc5_:Session = Session.getInstance();
         var _loc6_:Boolean = Boolean(_loc5_.me);
         if(this.model.canSteal(_loc6_) == false)
         {
            if(_loc6_ == false)
            {
               Cookies.setObject("f_" + _loc5_.currentUserIdByUinMode,CommonData.serverTime);
            }
            _loc7_ = uint(_loc5_.currentUser._uId);
            m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_FISH_FRIENDLIST,{
               "uId":_loc5_.currentUserIdByUinMode,
               "ownerId":_loc7_,
               "remove":true
            }));
         }
      }
      
      private function onGameDataReloaded(param1:CommonEvent) : void
      {
         this.view.reset();
         var _loc2_:Boolean = Boolean(Session.getInstance().me);
         if(this._grayOpen != null)
         {
            this._grayOpen.myHome = _loc2_;
         }
         this.onInitialized(param1);
      }
      
      private function onUpdateMatureFlag(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data as int;
         this.view.updateMatureFlag(_loc2_);
      }
      
      private function onFishPlanted(param1:CommonEvent) : void
      {
         var _loc2_:PoolFish = param1.data as PoolFish;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Point = this.view.findNearPos();
         if(_loc3_ != null)
         {
            this.view.addFish(_loc2_,_loc3_.x,_loc3_.y);
         }
         m_module.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_DATA_REMOVE,{
            "id":_loc2_._type,
            "type":parseInt(Consts.ITEM_TYPE_FISH)
         }));
         this.updatePoolInfoBtn();
         var _loc4_:int = Math.max(0,Consts.FISH_MAX_SIZE - this.model.poolSize);
         var _loc5_:int = int(_loc2_.poolSize);
         var _loc6_:String = Language.replaceText("plantFishTip",{
            "size":_loc5_,
            "num":_loc4_
         });
         openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":_loc6_,
            "parent":this.view.stage
         });
         if(_loc4_ <= 0)
         {
            m_module.app.dispatchEvent(new Event(Consts.CLOSE_MY_BAG));
         }
         GameGuide.instance().hide();
      }
      
      private function registerListeners() : void
      {
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_RELOAD_GAME_RESULT,this.onGameDataReloaded,false,0,true);
            _loc1_.addEventListener(Consts.MSG_FISH_GUIDE,this.onShowGuideArrow,false,0,true);
            _loc1_.addEventListener(Consts.MSG_SHOW_WATER_CURSOR,this.onShowFishCursor,false,0,true);
            _loc1_.addEventListener(Consts.MSG_SHOW_POOLINFO,this.onShowPoolInfo,false,0,true);
         }
         this.model.addEventListener(WaterModel.EVENT_DATA_LOADED,this.onFishLoaded,false,0,true);
         this.model.addEventListener(WaterModel.EVENT_FISH_PLANTED,this.onFishPlanted,false,0,true);
         this.model.addEventListener(WaterModel.EVENT_FISH_HARVESTED,this.onFishHarvest,false,0,true);
         this.model.addEventListener(WaterModel.EVENT_FISH_CHANGED,this.onFishChanged,false,0,true);
         this.model.addEventListener(WaterModel.EVENT_ERROR_MSG,this.onShowErrorMsg,false,0,true);
         this.model.addEventListener(WaterModel.EVENT_LEVELUP,this.onLevelUp,false,0,true);
         this.model.addEventListener(WaterModel.EVENT_GROW_UP,this.onGrowUp,false,0,true);
         this.model.addEventListener(WaterModel.EVENT_BATCH_FISH,this.onBatchProcessFish,false,0,true);
         this.model.addEventListener(WaterModel.EVENT_UPDATE_MATURE_FLAG,this.onUpdateMatureFlag,false,0,true);
      }
      
      override public function finalize() : void
      {
         if(m_model != null)
         {
            m_model = null;
         }
         this._grayOpen = null;
         this._infoWindow = null;
      }
      
      private function adjustCursorFirstTime() : void
      {
         setTimeout(function():void
         {
            restoreLandCursor();
         },3000);
      }
      
      private function onLevelUp(param1:CommonEvent) : void
      {
         if(param1 != null && param1.data != null)
         {
            m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_LEVELUP,param1.data));
         }
      }
      
      private function onFishChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.view.refreshInfoTip(param1.data as PoolFish);
         this.view.refreshMatureFlag(true);
      }
      
      public function get model() : WaterModel
      {
         return m_model as WaterModel;
      }
      
      private function onShowFishCursor(param1:CommonEvent) : void
      {
         var _loc4_:CursorControl = null;
         if(param1.result == null)
         {
            return;
         }
         var _loc2_:Boolean = Boolean(Session.getInstance().me);
         var _loc3_:Boolean = this.model.canSteal(_loc2_);
         param1.result["fish"] = _loc3_;
         if(_loc3_ == true)
         {
            _loc4_ = m_module.app.farmView.cursorCtrl;
            _loc4_.setCursor(Consts.CURSOR_STYLE_FISHNET_ALL);
         }
      }
      
      override public function initialze() : void
      {
         var _loc1_:WaterPool = null;
         if(m_model == null)
         {
            m_model = new WaterModel();
         }
         this.registerListeners();
         if(m_view == null)
         {
            _loc1_ = new WaterPool(this);
            m_view = _loc1_;
            if(m_module != null && m_module.container != null)
            {
               m_view.x = 46 + 6 * this.ITEM_WIDTH / 2;
               m_view.y = 320 + 4 * this.ITEM_HEIGHT / 2;
               m_module.container.addChild(m_view);
            }
            this.onInitialized(null);
         }
      }
      
      private function onInitialized(param1:CommonEvent) : void
      {
         var _loc2_:Boolean = Boolean(Session.getInstance().me);
         if(_loc2_ == true)
         {
            this.model.checkWhiteList();
         }
         else
         {
            this.model.loadFishes();
         }
         this._batchProcessTime = -1;
         this.view.disableMouse = false;
         var _loc3_:CursorControl = null;
         if(m_module != null && m_module.app != null)
         {
            _loc3_ = m_module.app.farmView.cursorCtrl;
         }
         if(_loc3_ != null)
         {
            _loc3_.register(Consts.CURSOR_STYLE_FISHNET,Utils.getClass("CursorFishNet"));
            _loc3_.register(Consts.CURSOR_STYLE_FISHNET_ALL,Utils.getClass("CursorFishNetAll"));
         }
      }
      
      public function switchMode(param1:Boolean) : void
      {
         this.view.hideInfoTip();
         if(param1 == true)
         {
            this.view.scaleX = this.view.scaleY = 1.3;
            this.view.x = 46 * 1.3 + 6 * this.ITEM_WIDTH * 1.3 / 2;
            this.view.y = 320 * 1.3 + 4 * this.ITEM_HEIGHT * 1.3 / 2;
         }
         else
         {
            this.view.scaleX = this.view.scaleY = 1;
            this.view.x = 46 + 6 * this.ITEM_WIDTH / 2;
            this.view.y = 320 + 4 * this.ITEM_HEIGHT / 2;
         }
      }
      
      public function onGameLoop(param1:Number) : void
      {
         if(this._batchProcessTime >= 0)
         {
            this._batchProcessTime += param1;
            if(this._batchProcessTime >= 700)
            {
               if(this.model.processBatchFish() == false)
               {
                  this._batchProcessTime = -1;
               }
               else
               {
                  this._batchProcessTime = 0;
               }
            }
         }
         if(this.m_updateFreq.isReady() == false)
         {
            return;
         }
         this.m_updateFreq.reset(Consts.WATER_POOL_COUNTDOWN);
         this.model.growLoop();
         if(this._batchProcessTime == -1)
         {
            this.view.refreshMatureFlag(false);
            this._disableInfoWin = false;
         }
         FishAnimationMgr.getInstance().onGameLoop(param1);
      }
      
      public function get view() : WaterPool
      {
         return m_view as WaterPool;
      }
   }
}

