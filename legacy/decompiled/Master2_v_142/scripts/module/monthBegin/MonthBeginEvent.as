package module.monthBegin
{
   import flash.events.Event;
   
   public class MonthBeginEvent extends Event
   {
      
      public static const MONTHBEGIN_LIST:String = "monthbegin_list";
      
      public static const MONTHBEGIN_GETGIFT:String = "monthbegin_getgift";
      
      public static const MONTHBEGIN_PRICE:String = "monthbegin_price";
      
      public static const MONTHBEGIN_LASTBUYTIME:String = "monthbegin_lastbuytime";
      
      public static const EVENT_BUY_GIFT_SUCCESS:String = "eventbuygiftsuccess";
      
      public static const EVENT_BUY_MONTHBEGIN_FAIL:String = "eventbuygiftfail";
      
      private var _data:*;
      
      public function MonthBeginEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function set data(param1:*) : void
      {
         this._data = param1;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

