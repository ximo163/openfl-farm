package module.decorate
{
   import common.Consts;
   import events.CommonEvent;
   import framework.base.Controller;
   import interfaces.IMsgCenter;
   
   public class DecorateController extends Controller
   {
      
      public function DecorateController()
      {
         super(null);
      }
      
      private function onNotifyRefreshMainScene(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_REFRESH_SCENE,param1.data));
      }
      
      public function get view() : DecorateView
      {
         return m_view as DecorateView;
      }
      
      override public function finalize() : void
      {
         super.finalize();
      }
      
      public function get model() : DecorateModel
      {
         return m_model as DecorateModel;
      }
      
      private function onShowDecorate(param1:CommonEvent) : void
      {
         var _loc2_:String = null;
         if(m_view == null)
         {
            m_view = new DecorateView(this);
         }
         if(param1.data == null)
         {
            m_module.app.farmView.winCtrl.open(m_view);
            this.model.loadItems();
         }
         else if(param1.data["openBillBoard"] == true)
         {
            m_module.app.farmView.winCtrl.open(m_view);
            this.model.loadBoards();
            this.view.switchTab(1);
         }
         else if(param1.data["plugin_tab"] != undefined)
         {
            m_module.app.farmView.winCtrl.open(m_view);
            _loc2_ = param1.data["plugin_tab"] as String;
            this.view.switchTabByName(_loc2_);
         }
      }
      
      private function registerListeners() : void
      {
         if(m_module == null || m_module.app == null)
         {
            return;
         }
         if(m_model != null)
         {
            m_model.addEventListener(DecorateModel.NOTIFY_REFRESH_MAINSCENE,this.onNotifyRefreshMainScene,false,0,true);
         }
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_SHOW_DIY,this.onShowDecorate,false,0,true);
            _loc1_.addEventListener(Consts.DATA_DECORATE_RELOAD_FLAG,this.onNeedReload,false,0,true);
         }
      }
      
      private function onNeedReload(param1:CommonEvent) : void
      {
         if(this.model != null)
         {
            this.model.dirty = true;
         }
      }
      
      override public function initialze() : void
      {
         super.initialze();
         if(m_model == null)
         {
            m_model = new DecorateModel();
         }
         this.registerListeners();
      }
   }
}

