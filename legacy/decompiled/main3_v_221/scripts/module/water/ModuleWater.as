package module.water
{
   import common.Consts;
   import common.misc.Cookies;
   import common.misc.Utils;
   import events.CommonEvent;
   import flash.display.MovieClip;
   import framework.base.BaseLayer;
   import framework.base.Controller;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleWater extends Module
   {
      
      private var _waterCtrl:Controller;
      
      private var _loading:MovieClip;
      
      public function ModuleWater(param1:FarmApplication)
      {
         super(param1);
         _reportID = "160619";
         param1.addEventListener(Consts.MSG_ZOOM,this.onZoom,false,0,true);
      }
      
      override public function onGameLoop(param1:Number) : void
      {
         if(this._waterCtrl != null)
         {
            if(this._waterCtrl["onGameLoop"] != undefined && this._waterCtrl["onGameLoop"] != null)
            {
               this._waterCtrl["onGameLoop"](param1);
            }
         }
         else
         {
            if(m_container == null)
            {
               m_container = app.farmView.getLayerByName(Consts.LAYER_SCENE_CONTENT);
            }
            if(this._loading == null)
            {
               this._loading = new FarmLoading();
               this._loading.x = 700 + 46;
               this._loading.y = 300 + 320;
               this._loading.mouseEnabled = false;
               this._loading.mouseChildren = false;
               if(Cookies.Get("bigmode") == "1")
               {
                  this._loading.x = 1.3 * (700 + 46);
                  this._loading.y = 1.3 * (300 + 320);
               }
               if(m_container != null)
               {
                  m_container.addChild(this._loading);
               }
            }
         }
      }
      
      override public function load(param1:BaseLayer) : void
      {
      }
      
      override public function unload() : void
      {
         if(this._waterCtrl != null)
         {
            this._waterCtrl.finalize();
            this._waterCtrl = null;
         }
      }
      
      override protected function onModuleLoadSuccess() : void
      {
         var _loc1_:Class = Utils.getClass("module.water.WaterController");
         if(_loc1_ != null)
         {
            this._waterCtrl = new _loc1_();
            this._waterCtrl.module = this;
            this._waterCtrl.initialze();
            if(Cookies.Get("bigmode") == "1")
            {
               this._waterCtrl["switchMode"](true);
            }
         }
         if(m_container != null && this._loading != null && m_container.contains(this._loading) == true)
         {
            m_container.removeChild(this._loading);
         }
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_WATER;
      }
      
      private function onZoom(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Boolean = param1.data as Boolean;
         if(this._waterCtrl != null)
         {
            this._waterCtrl["switchMode"](_loc2_);
         }
      }
      
      override public function onNetRequestStopped() : void
      {
         if(this._waterCtrl != null)
         {
            if(this._waterCtrl["model"] != undefined && this._waterCtrl["model"] != null)
            {
               this._waterCtrl["model"]["resetLoadingFlags"]();
            }
         }
      }
   }
}

