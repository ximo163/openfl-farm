package module.decorate
{
   import common.Consts;
   import common.misc.Utils;
   import framework.base.BaseLayer;
   import framework.base.Controller;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleDecorate extends Module
   {
      
      private var _diyCtrl:Controller;
      
      public function ModuleDecorate(param1:FarmApplication)
      {
         super(param1);
         _reportID = "160593";
      }
      
      override public function onNetRequestStopped() : void
      {
         if(this._diyCtrl != null)
         {
            if(this._diyCtrl["model"] != null)
            {
               this._diyCtrl["model"]["resetLoadingFlags"]();
            }
         }
      }
      
      override public function load(param1:BaseLayer) : void
      {
      }
      
      override public function unload() : void
      {
         if(this._diyCtrl != null)
         {
            this._diyCtrl.finalize();
            this._diyCtrl = null;
         }
      }
      
      override protected function onModuleLoadSuccess() : void
      {
         var _loc1_:Class = Utils.getClass("module.decorate.DecorateController");
         if(_loc1_ != null)
         {
            this._diyCtrl = new _loc1_();
            this._diyCtrl.module = this;
            this._diyCtrl.initialze();
         }
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_DIY;
      }
   }
}

