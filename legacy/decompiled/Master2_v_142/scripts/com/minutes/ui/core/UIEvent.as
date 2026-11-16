package com.minutes.ui.core
{
   import flash.events.Event;
   
   public class UIEvent extends Event
   {
      
      public static const RESIZE:String = "resize";
      
      public static const SCROLL_CONTENT_CHANGE:String = "scrollContentChange";
      
      public static const TEXT_CHANGE:String = "textChange";
      
      public static const CLOSE:String = "close";
      
      private var _data:Object;
      
      public function UIEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
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

