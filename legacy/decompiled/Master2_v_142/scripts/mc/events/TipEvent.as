package mc.events
{
   import flash.events.Event;
   
   public class TipEvent extends Event
   {
      
      public static const TIP_SHOW:String = "tipShow";
      
      public static const TIP_HIDE:String = "tipHide";
      
      private var _tX:Number = 0;
      
      private var _tY:Number = 0;
      
      private var _tipType:String = "";
      
      private var _tipArgument:Object;
      
      public function TipEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function get tX() : Number
      {
         return this._tX;
      }
      
      public function get tY() : Number
      {
         return this._tY;
      }
      
      public function set tX(param1:Number) : void
      {
         this._tX = param1;
      }
      
      public function set tY(param1:Number) : void
      {
         this._tY = param1;
      }
      
      public function set tipArgument(param1:Object) : void
      {
         this._tipArgument = param1;
      }
      
      public function set tipType(param1:String) : void
      {
         this._tipType = param1;
      }
      
      public function get tipType() : String
      {
         return this._tipType;
      }
      
      public function get tipArgument() : Object
      {
         return this._tipArgument;
      }
   }
}

