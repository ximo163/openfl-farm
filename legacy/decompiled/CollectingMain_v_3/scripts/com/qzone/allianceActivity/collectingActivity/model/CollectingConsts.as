package com.qzone.allianceActivity.collectingActivity.model
{
   import flash.filters.GlowFilter;
   
   public final class CollectingConsts
   {
      
      private static var _textGlowFilter:Array;
      
      public static const APPHELPER:String = "Collecting.AppHelper";
      
      public static const MODEL:String = "Collecting.Model";
      
      public static const SERVICE:String = "Collecting.Service";
      
      public static const MEDIATOR:String = "Collecting.ViewMediator";
      
      public static const NORMAL_SERIAL_START:uint = 51;
      
      public static const CMD_PULL_HISTORY:String = "getHistory";
      
      public static const CMD_PULL_FRIEND_COLLECT:String = "getFriendCollection";
      
      public static const CMD_PULL_FRIEND_LIST:String = "getFriendList";
      
      public function CollectingConsts()
      {
         super();
      }
      
      public static function get textGlowFilter() : Array
      {
         if(_textGlowFilter == null)
         {
            _textGlowFilter = [new GlowFilter(16763904,1,6,6,3)];
         }
         return _textGlowFilter;
      }
   }
}

