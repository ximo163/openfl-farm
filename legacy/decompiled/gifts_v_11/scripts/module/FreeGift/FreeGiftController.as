package module.FreeGift
{
   import common.Consts;
   import events.CommonEvent;
   import framework.base.Controller;
   import interfaces.IMsgCenter;
   
   public class FreeGiftController extends Controller
   {
      
      public function FreeGiftController()
      {
         super(null);
      }
      
      public function get view() : FreeGiftView
      {
         return m_view as FreeGiftView;
      }
      
      private function onShowFreeGift(param1:CommonEvent) : void
      {
         var _loc2_:int = 0;
         if(param1.data == null)
         {
            _loc2_ = this.view.currentPageIndex;
            if(_loc2_ == -1)
            {
               _loc2_ = 0;
            }
            if(this.model.isEmpty(_loc2_) == true)
            {
               this.model.loadBackInfo();
            }
            m_module.app.farmView.winCtrl.open(m_view);
         }
         else
         {
            m_module.app.farmView.winCtrl.open(m_view);
            _loc2_ = int(param1.data["openIndex"]);
            if(this.model.isEmpty(_loc2_) == true)
            {
               this.model.loadBackInfo();
            }
            FreeGiftView(m_view).createView();
            FreeGiftView(m_view).currentPageIndex = _loc2_;
         }
      }
      
      public function get model() : FreeGiftModel
      {
         return m_model as FreeGiftModel;
      }
      
      private function registerListeners() : void
      {
         if(m_module == null || m_module.app == null)
         {
            return;
         }
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_SHOW_FREEGIFT,this.onShowFreeGift,false,0,true);
         }
      }
      
      override public function finalize() : void
      {
         super.finalize();
      }
      
      override public function initialze() : void
      {
         super.initialze();
         if(m_model == null)
         {
            m_model = new FreeGiftModel();
         }
         this.registerListeners();
         if(m_view == null)
         {
            m_view = new FreeGiftView(this);
         }
      }
   }
}

