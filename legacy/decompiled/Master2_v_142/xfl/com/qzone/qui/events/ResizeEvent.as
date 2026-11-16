package com.qzone.qui.events
{
   import flash.events.Event;
   
   public class ResizeEvent extends Event
   {
      
      public static const RESIZE:String = "resize";
      
      public var oldHeight:Number;
      
      public var oldWidth:Number;
      
      public function ResizeEvent(param1:String, param2:Number = NaN, param3:Number = NaN, param4:Boolean = false, param5:Boolean = false)
      {
         this.oldHeight = param3;
         this.oldWidth = param2;
         super(param1,param4,param5);
      }
      
      override public function toString() : String
      {
         return "[ResizeEvent type=\"" + super.type + "\" oldWidth=" + this.oldWidth + " oldHeight=" + this.oldHeight + " bubbles=" + super.bubbles + " cancelable=" + super.cancelable + " eventPhase=" + super.eventPhase + "]";
      }
   }
}

