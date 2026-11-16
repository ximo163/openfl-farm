package module.messages
{
   import common.Consts;
   import framework.base.BaseLayer;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleMessages extends Module
   {
      
      private var m_msgSystem:MessageController;
      
      public function ModuleMessages(param1:FarmApplication)
      {
         super(param1);
         this.m_msgSystem = null;
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_MESSAGES;
      }
      
      override public function load(param1:BaseLayer) : void
      {
         super.load(param1);
         this.m_msgSystem = new MessageController(this);
         this.m_msgSystem.initialze();
      }
      
      override public function unload() : void
      {
         if(this.m_msgSystem != null)
         {
            this.m_msgSystem.finalize();
            this.m_msgSystem = null;
         }
      }
   }
}

