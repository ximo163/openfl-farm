package module.FreeGift
{
   import common.Consts;
   import common.misc.Utils;
   import framework.base.BaseLayer;
   import framework.base.Controller;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleFreeGift extends Module
   {
      
      private var m_freeCtrl:Controller;
      
      public function ModuleFreeGift(param1:FarmApplication)
      {
         super(param1);
         _reportID = "160616";
      }
      
      override protected function onModuleLoadSuccess() : void
      {
         var _loc1_:Class = Utils.getClass("module.FreeGift.FreeGiftController");
         if(_loc1_ != null)
         {
            this.m_freeCtrl = new _loc1_();
            this.m_freeCtrl.module = this;
            this.m_freeCtrl.initialze();
         }
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_FREE_GIFT;
      }
      
      override public function load(param1:BaseLayer) : void
      {
      }
      
      override public function unload() : void
      {
         if(this.m_freeCtrl != null)
         {
            this.m_freeCtrl.finalize();
            this.m_freeCtrl = null;
         }
      }
   }
}

