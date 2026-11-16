package mc.view.main.leftInfo.FebruaryGift
{
   import flash.events.Event;
   
   public class FebruaryGiftEvent extends Event
   {
      
      public static const OPEN_FEBRUARYGIFT1:String = "OPEN_FEBRUARYGIFT1";
      
      public static const OPEN_FEBRUARYGIFT2:String = "OPEN_FEBRUARYGIFT2";
      
      private var _data:Object;
      
      public function FebruaryGiftEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
   }
}

