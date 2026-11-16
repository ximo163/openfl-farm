package module.friend
{
   import common.Consts;
   import framework.base.BaseLayer;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleFriends extends Module
   {
      
      private var m_firendsCtrl:FriendsController;
      
      public function ModuleFriends(param1:FarmApplication)
      {
         super(param1);
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_FRIENDS;
      }
      
      override public function load(param1:BaseLayer) : void
      {
         super.load(param1);
         this.m_firendsCtrl = new FriendsController(this);
         this.m_firendsCtrl.initialze();
      }
      
      override public function unload() : void
      {
         if(this.m_firendsCtrl != null)
         {
            this.m_firendsCtrl.finalize();
            this.m_firendsCtrl = null;
         }
      }
   }
}

