package module.task
{
   import common.Consts;
   import framework.base.BaseLayer;
   import framework.base.Module;
   import module.FarmApplication;
   import module.task.welcome.WelcomeController;
   
   public class ModuleTask extends Module
   {
      
      private var m_welcomeSystem:WelcomeController;
      
      public function ModuleTask(param1:FarmApplication)
      {
         super(param1);
         this.m_welcomeSystem = null;
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_TASK;
      }
      
      override public function onNetRequestStopped() : void
      {
         if(this.m_welcomeSystem != null)
         {
            if(this.m_welcomeSystem.model != null)
            {
               this.m_welcomeSystem.model.resetLoadingFlags();
            }
         }
      }
      
      override public function load(param1:BaseLayer) : void
      {
         super.load(param1);
         this.m_welcomeSystem = new WelcomeController(this);
         this.m_welcomeSystem.initialze();
      }
      
      override public function unload() : void
      {
         if(this.m_welcomeSystem != null)
         {
            this.m_welcomeSystem.finalize();
            this.m_welcomeSystem = null;
         }
      }
   }
}

