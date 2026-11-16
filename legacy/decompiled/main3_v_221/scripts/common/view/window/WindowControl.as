package common.view.window
{
   import events.WindowEvent;
   import interfaces.IMsgCenter;
   
   public class WindowControl
   {
      
      private var m_msgCenter:IMsgCenter;
      
      private var m_lib:Object;
      
      public function WindowControl(param1:IMsgCenter)
      {
         super();
         this.m_msgCenter = param1;
      }
      
      public function getMsgCenter() : IMsgCenter
      {
         return this.m_msgCenter;
      }
      
      public function open(param1:BaseWindow) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc2_.window = param1;
         this.m_msgCenter.dispatchEvent(_loc2_);
      }
      
      public function getClass(param1:String) : Class
      {
         if(this.m_lib == null)
         {
            return null;
         }
         return this.m_lib[param1];
      }
      
      public function openForName(param1:String, param2:Object = null) : void
      {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         var _loc3_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc3_.windowName = param1;
         _loc3_.windowArgument = param2;
         this.m_msgCenter.dispatchEvent(_loc3_);
      }
      
      public function register(param1:String, param2:Class) : void
      {
         if(this.m_lib == null)
         {
            this.m_lib = new Object();
         }
         this.m_lib[param1] = param2;
      }
      
      public function closeForName(param1:String) : void
      {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.windowName = param1;
         this.m_msgCenter.dispatchEvent(_loc2_);
      }
      
      public function close(param1:BaseWindow) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = param1;
         this.m_msgCenter.dispatchEvent(_loc2_);
      }
   }
}

