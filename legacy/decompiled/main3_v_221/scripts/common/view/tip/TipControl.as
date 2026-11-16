package common.view.tip
{
   import events.TipEvent;
   import interfaces.IMsgCenter;
   
   public class TipControl
   {
      
      private var m_msgCenter:IMsgCenter;
      
      private var m_lib:Object;
      
      public function TipControl(param1:IMsgCenter)
      {
         super();
         this.m_lib = null;
         this.m_msgCenter = param1;
      }
      
      public function getMsgCenter() : IMsgCenter
      {
         return this.m_msgCenter;
      }
      
      public function update(param1:String, param2:Object) : void
      {
         var _loc3_:TipEvent = new TipEvent(TipEvent.TIP_UPDATE);
         _loc3_.tipArgument = param2;
         _loc3_.tipType = param1;
         this.m_msgCenter.dispatchEvent(_loc3_);
      }
      
      public function getClass(param1:String) : Class
      {
         if(this.m_lib == null)
         {
            return null;
         }
         return this.m_lib[param1];
      }
      
      public function hide() : void
      {
         var _loc1_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         this.m_msgCenter.dispatchEvent(_loc1_);
      }
      
      public function register(param1:String, param2:Class) : void
      {
         if(this.m_lib == null)
         {
            this.m_lib = new Object();
         }
         this.m_lib[param1] = param2;
      }
      
      public function show(param1:String, param2:Object, param3:int = 0, param4:int = 0) : void
      {
         var _loc5_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc5_.tipArgument = param2;
         _loc5_.tipType = param1;
         _loc5_.tX = param3;
         _loc5_.tY = param4;
         this.m_msgCenter.dispatchEvent(_loc5_);
      }
   }
}

