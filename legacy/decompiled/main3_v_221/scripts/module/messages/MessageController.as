package module.messages
{
   import common.Consts;
   import common.view.window.BaseWindow;
   import entities.Player;
   import events.CommonEvent;
   import framework.base.Controller;
   import interfaces.IModule;
   import interfaces.IMsgCenter;
   
   public class MessageController extends Controller
   {
      
      public function MessageController(param1:IModule)
      {
         super(param1);
      }
      
      public function get model() : MessageModel
      {
         return m_model as MessageModel;
      }
      
      private function onOpenWindow(param1:CommonEvent) : void
      {
         if(m_view == null)
         {
            m_view = new MessageView(this);
         }
         module.app.farmView.winCtrl.open(m_view as BaseWindow);
         var _loc2_:int = 0;
         var _loc3_:Player = null;
         if(param1.data != null)
         {
            _loc2_ = param1.data["index"] as int;
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            if(param1.data["player"] != undefined)
            {
               _loc3_ = param1.data["player"] as Player;
            }
         }
         this.model.currentPlayer = _loc3_;
         this.model.loadData(_loc2_);
         (m_view as MessageView).switchPage(_loc2_,this.model.me);
      }
      
      override public function initialze() : void
      {
         if(m_model == null)
         {
            m_model = new MessageModel();
         }
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_SHOW_PROFILE,this.onOpenWindow,false,0,true);
         }
      }
   }
}

