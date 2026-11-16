package module.uitools
{
   import common.Consts;
   import framework.base.BaseLayer;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleUITools extends Module
   {
      
      private var m_uiCtrl:UIController;
      
      public function ModuleUITools(param1:FarmApplication)
      {
         super(param1);
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_UITOOLS;
      }
      
      override public function onNetRequestStopped() : void
      {
         if(this.m_uiCtrl != null)
         {
            if(this.m_uiCtrl.model != null)
            {
               this.m_uiCtrl.model.resetLoadingFlags();
            }
         }
      }
      
      override public function load(param1:BaseLayer) : void
      {
         super.load(param1);
         this.m_uiCtrl = new UIController(this);
         this.m_uiCtrl.initialze();
      }
      
      override public function unload() : void
      {
         if(this.m_uiCtrl != null)
         {
            this.m_uiCtrl.finalize();
            this.m_uiCtrl = null;
         }
      }
   }
}

