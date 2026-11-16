package module.recall
{
   import common.Consts;
   import framework.base.BaseLayer;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleRecall extends Module
   {
      
      private var m_recallCtrl:RecallController;
      
      public function ModuleRecall(param1:FarmApplication)
      {
         super(param1);
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_RECALL;
      }
      
      override public function onNetRequestStopped() : void
      {
         if(this.m_recallCtrl != null)
         {
            if(this.m_recallCtrl.model != null)
            {
               this.m_recallCtrl.model.resetLoadingFlags();
            }
         }
      }
      
      override public function load(param1:BaseLayer) : void
      {
         super.load(param1);
         this.m_recallCtrl = new RecallController(this);
         this.m_recallCtrl.initialze();
      }
      
      override public function unload() : void
      {
         if(this.m_recallCtrl != null)
         {
            this.m_recallCtrl.finalize();
            this.m_recallCtrl = null;
         }
      }
   }
}

