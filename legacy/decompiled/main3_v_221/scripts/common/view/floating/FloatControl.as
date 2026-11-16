package common.view.floating
{
   import events.FloatingEvent;
   import interfaces.IMsgCenter;
   
   public class FloatControl
   {
      
      private var m_msgCenter:IMsgCenter;
      
      private var m_lib:Object;
      
      public function FloatControl(param1:IMsgCenter)
      {
         super();
         this.m_lib = null;
         this.m_msgCenter = param1;
      }
      
      public function open(param1:String, param2:int = 0, param3:Object = null) : void
      {
         var _loc4_:FloatingEvent = new FloatingEvent(FloatingEvent.FLOATING_OPEN);
         _loc4_.floating = param1;
         _loc4_.fid = param2;
         _loc4_.data = param3;
         this.m_msgCenter.dispatchEvent(_loc4_);
      }
      
      public function getMsgControl() : IMsgCenter
      {
         return this.m_msgCenter;
      }
      
      public function getClass(param1:String) : Class
      {
         if(this.m_lib == null)
         {
            return null;
         }
         return this.m_lib[param1];
      }
      
      public function register(param1:String, param2:Class) : void
      {
         if(this.m_lib == null)
         {
            this.m_lib = new Object();
         }
         this.m_lib[param1] = param2;
      }
      
      public function close(param1:String) : void
      {
         var _loc2_:FloatingEvent = new FloatingEvent(FloatingEvent.FLOATING_CLOSE);
         _loc2_.floating = param1;
         this.m_msgCenter.dispatchEvent(_loc2_);
      }
   }
}

