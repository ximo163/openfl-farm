package module.mainScene.background
{
   import common.Consts;
   import common.view.window.BaseWindow;
   import entities.DIYDecor;
   import entities.Player;
   import entities.StartupData;
   import events.CommonEvent;
   import flash.events.Event;
   import framework.base.Controller;
   import interfaces.IModule;
   import interfaces.IMsgCenter;
   
   public class BackgroundController extends Controller
   {
      
      private var m_oldDecorItem:Object;
      
      private var m_previewWindow:BaseWindow;
      
      private var m_openWarehouse:Boolean;
      
      public function BackgroundController(param1:IModule)
      {
         super(param1);
         this.m_oldDecorItem = null;
         this.m_openWarehouse = false;
      }
      
      private function onGameDataReloaded(param1:CommonEvent) : void
      {
         this.onStartupData(param1);
         if(this.m_openWarehouse == true)
         {
            module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_DIY,null));
            this.m_openWarehouse = false;
         }
      }
      
      public function get view() : BackgroundScreen
      {
         return m_view as BackgroundScreen;
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
            this.model.setDecors(_loc2_._decors);
            this.view.updatePastureBoard();
         }
      }
      
      private function onRefreshDecorate(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = int(param1.data["type"]);
         var _loc3_:int = int(param1.data["id"]);
         this.model.changeDecor(_loc3_,_loc2_);
      }
      
      private function onExitPreview(param1:CommonEvent) : void
      {
         if(this.m_oldDecorItem == null || this.m_oldDecorItem["id"] == undefined || this.m_oldDecorItem["type"] == undefined)
         {
            return;
         }
         this.model.changeDecor(this.m_oldDecorItem["id"],this.m_oldDecorItem["type"]);
         this.m_oldDecorItem = null;
      }
      
      override public function initialze() : void
      {
         if(m_model == null)
         {
            m_model = new BackgroundModel();
         }
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_STARTUP_DATA,this.onStartupData,false,0,true);
            _loc1_.addEventListener(Consts.MSG_RELOAD_GAME_RESULT,this.onGameDataReloaded,false,0,true);
            _loc1_.addEventListener(Consts.MSG_CURRENT_USER_CHANGED,this.onCurrentUserChanged,false,0,true);
            _loc1_.addEventListener(Consts.MSG_ENTER_PREVIEW,this.onEnterPreview,false,0,true);
            _loc1_.addEventListener(Consts.MSG_EXIT_PREVIEW,this.onExitPreview,false,0,true);
            _loc1_.addEventListener(Consts.MSG_REFRESH_SCENE,this.onRefreshDecorate,false,0,true);
            _loc1_.addEventListener(Consts.MSG_OPEN_WAREHOUSE_AFTER_BACK,this.onOpenWarehouseAfterBack,false,0,true);
         }
         if(m_view == null)
         {
            m_view = new BackgroundScreen(this);
            if(m_module != null && m_module.container != null)
            {
               m_module.container.addChild(m_view);
            }
         }
      }
      
      private function onOpenWarehouseAfterBack(param1:Event) : void
      {
         this.m_openWarehouse = true;
      }
      
      private function onEnterPreview(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:DIYDecor = param1.data as DIYDecor;
         if(_loc2_ == null)
         {
            return;
         }
         this.m_oldDecorItem = this.model.changeDecor(_loc2_._id,_loc2_._type);
         if(this.m_previewWindow == null)
         {
            this.m_previewWindow = new PreviewDiyWindow(module.app as IMsgCenter);
         }
         module.app.farmView.winCtrl.open(this.m_previewWindow);
      }
      
      private function onCurrentUserChanged(param1:CommonEvent) : void
      {
         this.view.updatePastureBoard();
         var _loc2_:Player = param1.data as Player;
         if(_loc2_ != null)
         {
            this.view.enableBillboard(_loc2_.me == true ? true : false);
         }
      }
      
      public function switchMode(param1:Boolean) : void
      {
         if(param1 == true)
         {
            this.view.scaleX = this.view.scaleY = 1.3;
         }
         else
         {
            this.view.scaleX = this.view.scaleY = 1;
         }
      }
      
      public function get model() : BackgroundModel
      {
         return m_model as BackgroundModel;
      }
      
      public function openDiyWindow() : void
      {
         m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_DIY,{"openBillBoard":true}));
      }
      
      override public function finalize() : void
      {
         if(m_model != null)
         {
            m_model = null;
         }
      }
   }
}

