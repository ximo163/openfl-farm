package com.qzone.qui.events
{
   import flash.events.Event;
   
   public class ScrollEvent extends Event
   {
      
      public static const SCROLL:String = "scroll";
      
      private var _direction:String;
      
      private var _position:Number;
      
      private var _detail:String;
      
      private var _delta:Number;
      
      public function ScrollEvent(param1:String, param2:String = null, param3:Number = NaN, param4:String = null, param5:Number = NaN, param6:Boolean = false, param7:Boolean = false)
      {
         this._position = param3;
         this._direction = param4;
         this._detail = param2;
         this._delta = param5;
         super(param1,param6,param7);
      }
      
      public function get position() : Number
      {
         return this._position;
      }
      
      override public function toString() : String
      {
         return "[ScrollEvent type=\"" + super.type + "\" position=" + this._position + " direction=\"" + this._direction + "\" bubbles=" + super.bubbles + " cancelable=" + super.cancelable + " eventPhase=" + super.eventPhase + "]";
      }
      
      public function get detail() : String
      {
         return this._detail;
      }
      
      public function get delta() : Number
      {
         return this._delta;
      }
      
      public function get direction() : String
      {
         return this._direction;
      }
   }
}

