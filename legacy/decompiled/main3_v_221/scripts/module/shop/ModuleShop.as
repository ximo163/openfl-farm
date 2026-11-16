package module.shop
{
   import common.Consts;
   import common.misc.Utils;
   import framework.base.BaseLayer;
   import framework.base.Controller;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleShop extends Module
   {
      
      private var _shopCtrl:Controller;
      
      public function ModuleShop(param1:FarmApplication)
      {
         super(param1);
         _reportID = "160591";
      }
      
      override public function onNetRequestStopped() : void
      {
         if(this._shopCtrl != null)
         {
            if(this._shopCtrl["model"] != undefined && this._shopCtrl["model"] != null)
            {
               this._shopCtrl["model"]["resetLoadingFlags"]();
            }
         }
      }
      
      override public function load(param1:BaseLayer) : void
      {
      }
      
      override public function unload() : void
      {
         if(this._shopCtrl != null)
         {
            this._shopCtrl.finalize();
            this._shopCtrl = null;
         }
      }
      
      override protected function onModuleLoadSuccess() : void
      {
         var _loc1_:Class = Utils.getClass("module.shop.ShopController");
         if(_loc1_ != null)
         {
            this._shopCtrl = new _loc1_();
            this._shopCtrl.module = this;
            this._shopCtrl.initialze();
         }
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_SHOP;
      }
   }
}

