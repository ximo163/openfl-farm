package module.mainScene
{
   import common.Consts;
   import common.misc.Cookies;
   import entities.FarmLand;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import framework.api.PluginManager;
   import framework.base.BaseLayer;
   import framework.base.Module;
   import framework.layers.FarmLayer;
   import module.FarmApplication;
   import module.mainScene.background.BackgroundController;
   import module.mainScene.farmLand.FarmLandController;
   import module.mainScene.farmLand.FarmLandModel;
   import module.mainScene.npc.NPCController;
   
   public class ModuleMainScene extends Module
   {
      
      private var m_backgroundCtrl:BackgroundController;
      
      private var _bigScaleMode:Boolean;
      
      private var m_npcCtrl:NPCController;
      
      private var m_farmLandCtrl:FarmLandController;
      
      public function ModuleMainScene(param1:FarmApplication)
      {
         super(param1);
         this.m_backgroundCtrl = null;
         this.m_farmLandCtrl = null;
         this.m_npcCtrl = null;
         this._bigScaleMode = false;
         param1.addEventListener(Consts.MSG_ZOOM,this.onZoom,false,0,true);
      }
      
      override public function onNetRequestStopped() : void
      {
         if(this.m_farmLandCtrl != null)
         {
            if(this.m_farmLandCtrl.model != null)
            {
               this.m_farmLandCtrl.model.resetLoadingFlags();
            }
         }
         if(this.m_npcCtrl != null)
         {
            if(this.m_npcCtrl.model != null)
            {
               this.m_npcCtrl.model.resetLoadingFlags();
            }
         }
      }
      
      public function set bigMode(param1:Boolean) : void
      {
         var _loc4_:FarmLayer = null;
         this._bigScaleMode = param1;
         this.m_backgroundCtrl.switchMode(param1);
         this.m_farmLandCtrl.switchMode(param1);
         var _loc2_:Number = param1 == true ? 1.3 : 1;
         super.container["maxWidth"] = Consts.SCENE_WIDTH * _loc2_;
         super.container["maxHeight"] = Consts.SCENE_HEIGHT * _loc2_;
         var _loc3_:DisplayObject = super.container.getChildByName(Consts.SCENE_ZINDEX_MIDDLE);
         if(_loc3_ != null)
         {
            _loc3_.scaleX = _loc3_.scaleY = _loc2_;
         }
         _loc3_ = super.container.getChildByName(Consts.SCENE_ZINDEX_FOREGROUND);
         if(_loc3_ != null)
         {
            _loc3_.scaleX = _loc3_.scaleY = _loc2_;
         }
         if(param1 == false)
         {
            _loc4_ = super.container as FarmLayer;
            if(_loc4_ != null)
            {
               if(_loc4_.top < 0)
               {
                  _loc4_.top = 0;
               }
               else if(_loc4_.top + _loc4_.height > _loc4_.maxHeight)
               {
                  _loc4_.top = _loc4_.maxHeight - _loc4_.height - 60;
               }
               if(_loc4_.left < 0)
               {
                  _loc4_.left = 0;
               }
               else if(_loc4_.left + _loc4_.width > _loc4_.maxWidth)
               {
                  _loc4_.left = _loc4_.maxWidth - _loc4_.width;
               }
               _loc4_.reRoll();
            }
         }
      }
      
      public function get bigMode() : Boolean
      {
         return this._bigScaleMode;
      }
      
      override public function load(param1:BaseLayer) : void
      {
         super.load(param1);
         this.m_backgroundCtrl = new BackgroundController(this);
         this.m_backgroundCtrl.initialze();
         var _loc2_:Sprite = new Sprite();
         _loc2_.name = Consts.SCENE_ZINDEX_MIDDLE;
         if(param1 != null)
         {
            param1.addChild(_loc2_);
         }
         this.m_farmLandCtrl = new FarmLandController(this);
         this.m_farmLandCtrl.initialze();
         this.m_npcCtrl = new NPCController(this);
         this.m_npcCtrl.initialze();
         PluginManager.getInstance().amountPlugins(Consts.PLUGIN_AMOUNT_BG,param1,null);
         if(Cookies.Get("bigmode") == "1")
         {
            this.bigMode = true;
         }
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_MAINSCENE;
      }
      
      private function onZoom(param1:CommonEvent) : void
      {
         this.bigMode = param1.data as Boolean;
      }
      
      override public function onGameLoop(param1:Number) : void
      {
         if(this.m_farmLandCtrl != null)
         {
            this.m_farmLandCtrl.onGameLoop(param1);
         }
      }
      
      public function get isAllBlack() : Boolean
      {
         var _loc1_:FarmLandModel = this.m_farmLandCtrl.model;
         if(_loc1_ == null)
         {
            return false;
         }
         var _loc2_:FarmLand = null;
         var _loc3_:int = 0;
         while(_loc3_ < 24)
         {
            _loc2_ = _loc1_.getLandData(_loc3_);
            if(_loc2_ == null)
            {
               return false;
            }
            if(_loc2_._bitmap != 2)
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      override public function unload() : void
      {
         if(this.m_backgroundCtrl != null)
         {
            this.m_backgroundCtrl.finalize();
            this.m_backgroundCtrl = null;
         }
         if(this.m_farmLandCtrl != null)
         {
            this.m_farmLandCtrl.finalize();
            this.m_farmLandCtrl = null;
         }
         if(this.m_npcCtrl != null)
         {
            this.m_npcCtrl.finalize();
            this.m_npcCtrl = null;
         }
      }
   }
}

