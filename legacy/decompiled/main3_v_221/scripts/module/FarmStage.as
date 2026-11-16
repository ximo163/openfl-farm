package module
{
   import com.greensock.TweenLite;
   import com.qzone.qfa.interfaces.IApplication;
   import com.qzone.qfa.view.AppStage;
   import com.qzone.qui.managers.PopUpManager;
   import common.Consts;
   import common.Session;
   import common.misc.Utils;
   import common.view.cursor.CursorControl;
   import common.view.cursor.CursorCropSeed;
   import common.view.cursor.CursorTool;
   import common.view.floating.AddExpFloating;
   import common.view.floating.AddHealthAnimation;
   import common.view.floating.AddMoneyFloating;
   import common.view.floating.FarmOperateFloating;
   import common.view.floating.FloatControl;
   import common.view.floating.HarvestAnimation;
   import common.view.floating.HarvestAnimationCustom;
   import common.view.floating.HarvestAnimationPlus;
   import common.view.floating.TextTipFloating;
   import common.view.tip.CropInfoTip;
   import common.view.tip.DiyMouseTip;
   import common.view.tip.LandInfoTip;
   import common.view.tip.MouseTip;
   import common.view.tip.TipControl;
   import common.view.window.AddButtonWindow;
   import common.view.window.AlertWindow;
   import common.view.window.ConfirmWindow;
   import common.view.window.GiftWindow;
   import common.view.window.PickupGiftWindow;
   import common.view.window.REGiftWindow;
   import common.view.window.RedUpWindow;
   import common.view.window.RequestErrorWindow;
   import common.view.window.ValidateCodeWindow;
   import common.view.window.WindowControl;
   import cursor.CursorWildArrow;
   import cursor.CursorWildGun;
   import cursor.CursorWildHand;
   import cursor.CursorWildTools;
   import events.CommonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import framework.api.beast.BeastAPI;
   import framework.base.BaseLayer;
   import framework.layers.CursorLayer;
   import framework.layers.FarmLayer;
   import framework.layers.FloatingLayer;
   import framework.layers.TipLayer;
   import framework.layers.WindowLayer;
   import interfaces.IMsgCenter;
   import module.load.UserChangingBar;
   import module.messages.widgets.HistoryItemTip;
   
   public class FarmStage extends AppStage
   {
      
      private var m_tipCtrl:TipControl;
      
      private var wildStage:FarmLayer;
      
      private var m_floatCtrl:FloatControl;
      
      private var _api:BeastAPI = BeastAPI.getInstance();
      
      private var m_winCtrl:WindowControl;
      
      private var m_layers:Array;
      
      private var farmStage:FarmLayer;
      
      private var m_cursorCtrl:CursorControl;
      
      private var toolBarLayer:BaseLayer;
      
      public function FarmStage(param1:IApplication)
      {
         super(param1);
         this.m_layers = new Array();
         this.m_winCtrl = null;
         this.m_tipCtrl = null;
         this.m_floatCtrl = null;
         this.m_cursorCtrl = null;
      }
      
      private function createLayerControls(param1:Boolean = false) : void
      {
         var _loc2_:IMsgCenter = this.owner as IMsgCenter;
         if(_loc2_ == null)
         {
            throw new Error("Unable to create layer controls");
         }
         if(param1 == false && this.m_winCtrl == null)
         {
            this.m_winCtrl = new WindowControl(_loc2_);
            this.m_winCtrl.register(Consts.WINDOW_NAME_ALERT,AlertWindow);
            this.m_winCtrl.register(Consts.WINDOW_NAME_CONFIRM,ConfirmWindow);
            this.m_winCtrl.register(Consts.WINDOW_NAME_ABUTTON,AddButtonWindow);
            this.m_winCtrl.register(Consts.WINDOW_NAME_REGIFT,PickupGiftWindow);
            this.m_winCtrl.register(Consts.WINDOW_NAME_GIFT,GiftWindow);
            this.m_winCtrl.register(Consts.WINDOW_NAME_REGIFT_CARD,REGiftWindow);
            this.m_winCtrl.register(Consts.WINDOW_NAME_UPGRADE_RED,RedUpWindow);
            this.m_winCtrl.register(Consts.WINDOW_NAME_REQUEST_ERROR,RequestErrorWindow);
            this.m_winCtrl.register(Consts.WINDOW_NAME_VALIDATE,ValidateCodeWindow);
         }
         if(param1 == false && this.m_tipCtrl == null)
         {
            this.m_tipCtrl = new TipControl(_loc2_);
            this.m_tipCtrl.register(Consts.TIP_NAME_MOUSE,MouseTip);
            this.m_tipCtrl.register(Consts.TIP_NAME_DIY_MOUSE,DiyMouseTip);
            this.m_tipCtrl.register(Consts.TIP_NAME_CROPINFO_MOUSE,CropInfoTip);
            this.m_tipCtrl.register(Consts.TIP_NAME_LAND_INFOR,LandInfoTip);
            this.m_tipCtrl.register(Consts.TIP_NAME_PROFILE_HISTORY,HistoryItemTip);
         }
         if(param1 == false && this.m_floatCtrl == null)
         {
            this.m_floatCtrl = new FloatControl(_loc2_);
            this.m_floatCtrl.register(Consts.FLOAT_TYPE_HA,HarvestAnimation);
            this.m_floatCtrl.register(Consts.FLOAT_TYPE_HAC,HarvestAnimationCustom);
            this.m_floatCtrl.register(Consts.FLOAT_TYPE_HAP,HarvestAnimationPlus);
            this.m_floatCtrl.register(Consts.FLOAT_TYPE_OPERATE,FarmOperateFloating);
            this.m_floatCtrl.register(Consts.FLOAT_TYPE_HEALTH,AddHealthAnimation);
            this.m_floatCtrl.register(Consts.FLOAT_TYPE_TEXTTIP,TextTipFloating);
            this.m_floatCtrl.register(Consts.FLOAT_TYPE_MONEY,AddMoneyFloating);
            this.m_floatCtrl.register(Consts.FLOAT_TYPE_EXP,AddExpFloating);
         }
         if(param1 == false && this.m_cursorCtrl == null)
         {
            this.m_cursorCtrl = new CursorControl(_loc2_);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_TOOL,CursorTool);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_ARROW,CursorArrow);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_WEED,CursorWeed);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_INSET,CursorInsect);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_HOE,CursorHoe);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_HOOK,CursorHook);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_PESTICIDE,CursorPesticide);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_WATER,CursorWater);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_HAND,CursorHand);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_ONEHAND,CursorOneClickHand);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_CROPSEED,CursorCropSeed);
            this.m_cursorCtrl.register(Consts.CURSOR_WILD_GUN,CursorWildGun);
            this.m_cursorCtrl.register(Consts.CURSOR_WILD_TOOL,CursorWildTools);
            this.m_cursorCtrl.register(Consts.CURSOR_WILD_ARROW,CursorWildArrow);
            this.m_cursorCtrl.register(Consts.CURSOR_WILD_HAND,CursorWildHand);
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_FISHNET,Utils.getClass("CursorFishNet"));
            this.m_cursorCtrl.register(Consts.CURSOR_STYLE_FISHNET_ALL,Utils.getClass("CursorFishNetAll"));
         }
      }
      
      private function buildLayers(param1:Boolean = false) : void
      {
         var _loc4_:* = undefined;
         var _loc2_:IMsgCenter = this.owner as IMsgCenter;
         if(_loc2_ == null)
         {
            throw new Error("Unable to build layers");
         }
         var _loc3_:BaseLayer = null;
         if(param1 != true)
         {
            _loc3_ = new FarmLayer(_loc2_);
            (_loc3_ as FarmLayer).maxWidth = Consts.SCENE_WIDTH;
            (_loc3_ as FarmLayer).maxHeight = Consts.SCENE_HEIGHT;
            (_loc3_ as FarmLayer).width = stage.stageWidth;
            (_loc3_ as FarmLayer).height = stage.stageHeight;
            (_loc3_ as FarmLayer).top = 190;
            (_loc3_ as FarmLayer).left = 50;
            (_loc3_ as FarmLayer).reRoll();
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            _loc3_ = new FarmLayer(_loc2_);
            _loc3_.name = Consts.LAYER_WILD;
            (_loc3_ as FarmLayer).maxWidth = 1000;
            (_loc3_ as FarmLayer).maxHeight = 768;
            (_loc3_ as FarmLayer).width = stage.stageWidth;
            (_loc3_ as FarmLayer).height = stage.stageHeight;
            (_loc3_ as FarmLayer).top = 100;
            (_loc3_ as FarmLayer).x = -stage.stageWidth;
            (_loc3_ as FarmLayer).reRoll();
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            _loc3_ = new BaseLayer(_loc2_);
            _loc3_.name = Consts.LAYER_TOOLS;
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            _loc3_ = new BaseLayer(_loc2_);
            _loc3_.name = Consts.LAYER_STRONG_GUIDE;
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            _loc3_ = new BaseLayer(_loc2_);
            _loc3_.name = Consts.LAYER_TASK;
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            _loc3_ = new BaseLayer(_loc2_);
            _loc3_.name = Consts.LAYER_DAILYMISSION;
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            _loc3_ = new BaseLayer(_loc2_);
            _loc3_.name = Consts.LAYER_FRIEND;
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            _loc3_ = new WindowLayer(this.m_winCtrl);
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            PopUpManager.init(this as DisplayObjectContainer);
            _loc4_ = PopUpManager.getInstance();
            _loc3_.addChild(_loc4_);
            _loc3_ = new TipLayer(this.m_tipCtrl);
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            _loc3_ = new FloatingLayer(this.m_floatCtrl);
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            _loc3_ = new CursorLayer(this.m_cursorCtrl);
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            _loc3_ = new BaseLayer(_loc2_);
            _loc3_.name = Consts.LAYER_TOPMOST;
            this.m_layers.push(_loc3_);
            this.addChild(_loc3_);
            this.farmStage = this.getLayerByName(Consts.LAYER_SCENE_CONTENT) as FarmLayer;
            this.wildStage = this.getLayerByName(Consts.LAYER_WILD) as FarmLayer;
            this.toolBarLayer = this.getLayerByName(Consts.LAYER_TOOLS) as BaseLayer;
            this._api.wildStageContainer = this.wildStage;
            this._api.animalContainer = this.farmStage;
            this._api.wildToolBarContainer = this.toolBarLayer;
            this._api.addEventListener(EvtAPI.SHOW_WILD_STAGE,this.showWildStage);
            this._api.addEventListener(EvtAPI.SHOW_FARM_STAGE,this.showFarmStage);
         }
      }
      
      private function showWildStage(param1:Event) : void
      {
         var completeFn:Function = null;
         var e:Event = param1;
         completeFn = function(param1:FarmStage):void
         {
            var _loc2_:IMsgCenter = param1.owner as IMsgCenter;
            _loc2_.dispatchEvent(new CommonEvent(Consts.MSG_TRUNK_SYSTEM_TOOLBAR,true));
            Session.getInstance().isInWildStage = true;
         };
         TweenLite.to(this.wildStage,0.5,{"x":0});
         TweenLite.to(this.farmStage,0.5,{
            "x":stage.stageWidth,
            "onComplete":completeFn,
            "onCompleteParams":[this]
         });
      }
      
      override public function init() : void
      {
         super.init();
         this.createLayerControls();
         this.buildLayers();
         this.initTopLayer();
      }
      
      public function get cursorCtrl() : CursorControl
      {
         return this.m_cursorCtrl;
      }
      
      public function get winCtrl() : WindowControl
      {
         return this.m_winCtrl;
      }
      
      private function showFarmStage(param1:Event) : void
      {
         var completeFn:Function = null;
         var e:Event = param1;
         completeFn = function(param1:FarmStage):void
         {
            var _loc2_:IMsgCenter = param1.owner as IMsgCenter;
            _loc2_.dispatchEvent(new CommonEvent(Consts.MSG_TRUNK_SYSTEM_TOOLBAR,false));
            Session.getInstance().isInWildStage = false;
            _loc2_.dispatchEvent(new CommonEvent(Consts.MSG_WILD_TO_FARMSTAGE,null));
            if(cursorCtrl.name == Consts.CURSOR_WILD_GUN || cursorCtrl.name == Consts.CURSOR_WILD_TOOL || cursorCtrl.name == Consts.CURSOR_WILD_ARROW)
            {
               cursorCtrl.setCursor(Consts.CURSOR_STYLE_ARROW);
            }
         };
         TweenLite.to(this.wildStage,0.5,{"x":-stage.stageWidth});
         TweenLite.to(this.farmStage,0.5,{
            "x":0,
            "onComplete":completeFn,
            "onCompleteParams":[this]
         });
      }
      
      public function get tipCtrl() : TipControl
      {
         return this.m_tipCtrl;
      }
      
      public function get floatCtrl() : FloatControl
      {
         return this.m_floatCtrl;
      }
      
      private function initTopLayer() : void
      {
         var _loc1_:IMsgCenter = this.owner as IMsgCenter;
         var _loc2_:UserChangingBar = new UserChangingBar(_loc1_);
         var _loc3_:BaseLayer = this.getLayerByName(Consts.LAYER_TOPMOST);
         if(_loc3_ != null)
         {
            _loc3_.addChild(_loc2_);
         }
      }
      
      public function getLayerByName(param1:String) : BaseLayer
      {
         var _loc2_:BaseLayer = null;
         if(param1 == null || param1 == "")
         {
            return null;
         }
         if(this.m_layers == null)
         {
            return null;
         }
         for each(_loc2_ in this.m_layers)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
   }
}

