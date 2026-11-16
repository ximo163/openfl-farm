package common.misc.time
{
   public class CountDown
   {
      
      private var m_counter:int;
      
      public function CountDown(param1:uint)
      {
         super();
         this.reset(param1);
      }
      
      public function isReady() : Boolean
      {
         --this.m_counter;
         if(this.m_counter <= 0)
         {
            return true;
         }
         return false;
      }
      
      public function toString() : String
      {
         return "count down left : " + this.m_counter;
      }
      
      public function reset(param1:uint) : void
      {
         if(param1 == 0)
         {
            throw new ArgumentError("Invalid argument for a counter.");
         }
         this.m_counter = param1;
      }
   }
}

