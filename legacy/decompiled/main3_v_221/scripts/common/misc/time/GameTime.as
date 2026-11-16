package common.misc.time
{
   import flash.utils.getTimer;
   
   public class GameTime
   {
      
      private var m_tStart:Number;
      
      private var m_LastTimeElapsed:Number;
      
      private var m_bSmoothUpdates:Boolean;
      
      private var m_bStarted:Boolean;
      
      private var m_tLast:Number;
      
      private var m_TimeElapsed:Number;
      
      public function GameTime(param1:Boolean)
      {
         super();
         this.m_bStarted = false;
         this.m_tStart = 0;
         this.m_LastTimeElapsed = 0;
         this.m_TimeElapsed = 0;
         this.m_bSmoothUpdates = param1;
      }
      
      public function get started() : Boolean
      {
         return this.m_bStarted;
      }
      
      public function stop() : void
      {
         this.m_bStarted = false;
         this.m_LastTimeElapsed = this.m_TimeElapsed = 0;
      }
      
      public function start() : void
      {
         this.m_bStarted = true;
         this.m_tStart = getTimer();
         this.m_tLast = this.m_tStart;
         this.m_LastTimeElapsed = this.m_TimeElapsed = 0;
      }
      
      public function get smooth() : Boolean
      {
         return this.m_bSmoothUpdates;
      }
      
      public function timeElapsed() : Number
      {
         if(this.m_bStarted == false)
         {
            return 0;
         }
         this.m_LastTimeElapsed = this.m_TimeElapsed;
         var _loc1_:Number = getTimer();
         this.m_TimeElapsed = _loc1_ - this.m_tLast;
         this.m_tLast = _loc1_;
         var _loc2_:Number = 2.5;
         if(this.m_bSmoothUpdates)
         {
            if(this.m_TimeElapsed < this.m_LastTimeElapsed * _loc2_)
            {
               return this.m_TimeElapsed;
            }
            return 0;
         }
         return this.m_TimeElapsed;
      }
      
      public function getCurrentTime() : Number
      {
         return getTimer() - this.m_tStart;
      }
      
      public function set smooth(param1:Boolean) : void
      {
         this.m_bSmoothUpdates = param1;
      }
   }
}

