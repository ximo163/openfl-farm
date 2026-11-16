package module.mainScene.npc
{
   import common.Consts;
   import common.Session;
   import entities.Dog;
   import entities.StartupData;
   import events.CommonEvent;
   import framework.base.Controller;
   import interfaces.IModule;
   import interfaces.IMsgCenter;
   
   public class NPCController extends Controller
   {
      
      private var _session:Session;
      
      public function NPCController(param1:IModule)
      {
         super(param1);
      }
      
      private function onRefreshView(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = int(param1.data["type"]);
         var _loc3_:int = int(param1.data["id"]);
         if(_loc2_ != Consts.DECOR_DOG)
         {
            return;
         }
         this.model.changeDog(_loc3_);
      }
      
      override public function finalize() : void
      {
         if(m_model != null)
         {
            m_model = null;
         }
      }
      
      private function onStartupData(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:StartupData = param1.data as StartupData;
         if(_loc2_ != null)
         {
            this.model.setDogData(_loc2_._dog);
         }
      }
      
      public function get model() : NPCModel
      {
         return m_model as NPCModel;
      }
      
      public function get view() : NPCView
      {
         return m_view as NPCView;
      }
      
      override public function initialze() : void
      {
         if(m_model == null)
         {
            m_model = new NPCModel();
         }
         this.registerListeners();
         if(m_view == null)
         {
            m_view = new NPCView(this);
            if(m_module != null && m_module.container != null)
            {
               m_module.container.addChild(m_view);
            }
         }
         this._session = Session.getInstance();
      }
      
      private function onInstallActivityNPC(param1:CommonEvent) : void
      {
         var _loc2_:Object = param1.data as Object;
         if(_loc2_ == null)
         {
            return;
         }
         this.view.installNPC(_loc2_);
      }
      
      private function onGameDataReloaded(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:StartupData = param1.data as StartupData;
         if(_loc2_ != null)
         {
            this.model.setDogData(_loc2_._dog);
         }
         m_view.switchNPC();
      }
      
      private function registerListeners() : void
      {
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_STARTUP_DATA,this.onStartupData,false,0,true);
            _loc1_.addEventListener(Consts.MSG_RELOAD_GAME_RESULT,this.onGameDataReloaded,false,0,true);
            _loc1_.addEventListener(Consts.DATA_DOG_CHANGED,this.onDogUpdated,false,0,true);
            _loc1_.addEventListener(Consts.MSG_REFRESH_SCENE,this.onRefreshView,false,0,true);
            _loc1_.addEventListener(Consts.MSG_INSTALL_NPC,this.onInstallActivityNPC,false,0,true);
         }
      }
      
      private function onDogUpdated(param1:CommonEvent) : void
      {
         var _loc2_:Dog = param1.data as Dog;
         if(_loc2_ != null)
         {
            this.model.setDogData(_loc2_);
         }
      }
   }
}

