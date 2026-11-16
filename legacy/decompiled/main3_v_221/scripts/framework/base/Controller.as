package framework.base
{
   import common.view.cursor.CursorControl;
   import common.view.floating.FloatControl;
   import interfaces.IModule;
   
   public class Controller
   {
      
      protected var m_view:*;
      
      protected var m_module:IModule;
      
      protected var m_model:*;
      
      public function Controller(param1:IModule)
      {
         super();
         this.m_module = param1;
         this.m_model = null;
         this.m_view = null;
      }
      
      public function showTip(param1:String, param2:*) : void
      {
         if(param1 == "" || param2 == null || param2 is String && param2.length == 0)
         {
            return;
         }
         if(this.m_module != null && this.m_module.app != null)
         {
            this.m_module.app.showTip(param1,param2);
         }
      }
      
      public function useSystemCursor(param1:Boolean) : void
      {
         if(this.m_module != null && this.m_module.app != null)
         {
            this.m_module.app.useSystemCursor(param1);
         }
      }
      
      public function initialze() : void
      {
      }
      
      public function openFloat(param1:String, param2:Object) : void
      {
         if(param1 == "" || param2 == null)
         {
            return;
         }
         var _loc3_:FloatControl = this.m_module.app.farmView.floatCtrl;
         if(_loc3_ != null)
         {
            _loc3_.open(param1,0,param2);
         }
      }
      
      public function setCursor(param1:String, param2:String) : void
      {
         var _loc3_:CursorControl = null;
         if(param1 == "")
         {
            return;
         }
         if(this.m_module != null && this.m_module.app != null)
         {
            _loc3_ = this.m_module.app.farmView.cursorCtrl;
            if(_loc3_ == null)
            {
               return;
            }
            _loc3_.setCursor(param1,param2);
         }
      }
      
      public function hideTip() : void
      {
         if(this.m_module != null && this.m_module.app != null)
         {
            this.m_module.app.hideTip();
         }
      }
      
      public function openWindow(param1:String, param2:Object) : void
      {
         if(param1 == "")
         {
            return;
         }
         if(this.m_module != null && this.m_module.app != null)
         {
            this.m_module.app.openWindowByName(param1,param2);
         }
      }
      
      public function get module() : IModule
      {
         return this.m_module;
      }
      
      public function finalize() : void
      {
         this.m_model = null;
         this.m_view = null;
         this.m_module = null;
      }
      
      public function set module(param1:IModule) : void
      {
         this.m_module = param1;
      }
   }
}

