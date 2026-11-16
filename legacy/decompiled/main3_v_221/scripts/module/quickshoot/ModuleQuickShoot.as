package module.quickshoot
{
   import common.Consts;
   import common.misc.Utils;
   import framework.base.BaseLayer;
   import framework.base.Controller;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleQuickShoot extends Module
   {
      
      private var _qsCtrl:Controller;
      
      private var _healthMode:Controller;
      
      public function ModuleQuickShoot(param1:FarmApplication)
      {
         super(param1);
         _reportID = "160615";
      }
      
      override public function load(param1:BaseLayer) : void
      {
      }
      
      override protected function onModuleLoadSuccess() : void
      {
         var _loc1_:Class = Utils.getClass("module.quickshoot.QuickShootController");
         if(_loc1_ != null)
         {
            this._qsCtrl = new _loc1_();
            this._qsCtrl.module = this;
            this._qsCtrl.initialze();
         }
         _loc1_ = Utils.getClass("module.health.HealthController");
         if(_loc1_ != null)
         {
            this._healthMode = new _loc1_();
            this._healthMode.module = this;
            this._healthMode.initialze();
         }
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_QUICK_SHOOT;
      }
      
      override public function onGameLoop(param1:Number) : void
      {
         if(this._healthMode != null && this._healthMode.hasOwnProperty("onGameLoop") == true)
         {
            this._healthMode["onGameLoop"](param1);
         }
      }
   }
}

