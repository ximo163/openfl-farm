package framework.layers
{
   import com.qzone.qui.managers.PopUpManager;
   import common.Consts;
   import common.misc.Utils;
   import common.view.window.BaseWindow;
   import common.view.window.WindowControl;
   import events.CommonEvent;
   import events.CursorEvent;
   import events.WindowEvent;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import framework.base.BaseLayer;
   
   public class WindowLayer extends BaseLayer
   {
      
      private var m_windowCtrl:WindowControl;
      
      private var m_winInstances:Dictionary;
      
      public function WindowLayer(param1:WindowControl)
      {
         if(param1 != null)
         {
            super(param1.getMsgCenter());
            this.m_windowCtrl = param1;
            this.m_winInstances = new Dictionary();
            this.name = Consts.LAYER_WINDOW;
            return;
         }
         throw new ArgumentError("Null parameter");
      }
      
      private function openWindowForName(param1:String, param2:Object) : void
      {
         if(param1 == "")
         {
            return;
         }
         var _loc3_:BaseWindow = this.m_winInstances[param1];
         if(_loc3_ == null)
         {
            _loc3_ = this.createWindow(param1);
            if(_loc3_ == null)
            {
               return;
            }
            this.openWindow(_loc3_);
            _loc3_.data = param2;
         }
         else
         {
            _loc3_.data = param2;
            this.openWindow(_loc3_);
         }
      }
      
      private function onEnterPreviewDIY(param1:CommonEvent) : void
      {
         var _loc2_:BaseWindow = this.m_winInstances[Consts.WINDOW_NAME_BUYDIY] as BaseWindow;
         PopUpManager.hidePopUp(_loc2_);
         _loc2_ = this.m_winInstances[Consts.WINDOW_NAME_SHOP] as BaseWindow;
         PopUpManager.hidePopUp(_loc2_);
      }
      
      private function onWindowClose(param1:WindowEvent) : void
      {
         var _loc2_:BaseWindow = param1.window;
         if(_loc2_ == null && param1.windowName != null && param1.windowName != "")
         {
            _loc2_ = this.m_winInstances[param1.windowName] as BaseWindow;
         }
         if(_loc2_ != null)
         {
            PopUpManager.removePopUp(_loc2_);
         }
      }
      
      private function createWindow(param1:String) : BaseWindow
      {
         if(param1 == "")
         {
            return null;
         }
         if(this.m_windowCtrl == null)
         {
            return null;
         }
         var _loc2_:BaseWindow = null;
         var _loc3_:Class = this.m_windowCtrl.getClass(param1);
         if(_loc3_ == null)
         {
            return null;
         }
         return new _loc3_(m_msgCenter) as BaseWindow;
      }
      
      override protected function init() : void
      {
         super.init();
         if(Utils.isSafariOnMac() == true)
         {
            addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         }
         m_msgCenter.addEventListener(WindowEvent.OPEN,this.onWindowOpen,false,0,true);
         m_msgCenter.addEventListener(WindowEvent.CLOSE,this.onWindowClose,false,0,true);
         m_msgCenter.addEventListener(Consts.MSG_ENTER_PREVIEW,this.onEnterPreviewDIY,false,0,true);
         m_msgCenter.addEventListener(Consts.MSG_EXIT_PREVIEW,this.onExitPreviewDIY,false,0,true);
      }
      
      private function openWindow(param1:BaseWindow) : void
      {
         if(param1 == null)
         {
            return;
         }
         PopUpManager.addPopUp(param1,param1.mode);
         if(param1.windowName == Consts.WINDOW_NAME_ALERT || param1.windowName == Consts.WINDOW_NAME_CONFIRM)
         {
            return;
         }
         if(param1.windowName == null || param1.windowName == "")
         {
            return;
         }
         this.m_winInstances[param1.windowName] = param1;
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         var _loc2_:CursorEvent = new CursorEvent(CursorEvent.SWITCH_CURSOR);
         _loc2_.cursorName = Consts.CURSOR_SYSTEM;
         m_msgCenter.dispatchEvent(_loc2_);
      }
      
      private function onExitPreviewDIY(param1:CommonEvent) : void
      {
         var _loc2_:BaseWindow = this.m_winInstances[Consts.WINDOW_NAME_SHOP] as BaseWindow;
         PopUpManager.showPopUp(_loc2_);
         _loc2_ = this.m_winInstances[Consts.WINDOW_NAME_BUYDIY] as BaseWindow;
         PopUpManager.showPopUp(_loc2_);
      }
      
      private function onWindowOpen(param1:WindowEvent) : void
      {
         var _loc2_:String = param1["windowName"] as String;
         var _loc3_:* = param1["windowArgument"];
         if(_loc2_ == Consts.WINDOW_NAME_SHOP || _loc2_ == Consts.WINDOW_NAME_WAREHOUSE || _loc2_ == Consts.WINDOW_NAME_PROFILE)
         {
            throw new ArgumentError("Window can not be initialized.");
         }
         if(param1["window"] != undefined)
         {
            this.openWindow(param1["window"] as BaseWindow);
         }
         else
         {
            this.openWindowForName(_loc2_,_loc3_);
         }
      }
   }
}

