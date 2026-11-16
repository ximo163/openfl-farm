package com.qzone.qfa.events
{
   import com.qzone.qfa.data.Resource;
   import com.qzone.qfa.managers.LoadManager;
   import flash.events.Event;
   import flash.media.ID3Info;
   
   public class LoaderEvent extends Event
   {
      
      public static const STATUS_CHANGED:String = "STATUS_CHANGED";
      
      public static const ERROR:String = "ERROR";
      
      public static const START:String = "START";
      
      public static const PROGRESS:String = "PROGRESS";
      
      public static const COMPLETE:String = "COMPLETE";
      
      public static const QUEUE_CHANGED:String = "QUEUE_CHANGED";
      
      public static const QUEUE_START:String = "QUEUE_START";
      
      public static const QUEUE_PROGRESS:String = "QUEUE_PROGRESS";
      
      public static const QUEUE_COMPLETE:String = "QUEUE_COMPLETE";
      
      public var msg:String = "";
      
      public var id3Info:ID3Info;
      
      public var percentQueue:Number;
      
      public var bytesLoaded:Number;
      
      public var failCount:int;
      
      public var loadTime:int;
      
      public var queueLength:int;
      
      public var bytesTotal:Number;
      
      public var loader:LoadManager;
      
      public var item:Resource;
      
      public var percentItem:Number;
      
      public var queueCount:int;
      
      public function LoaderEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      override public function toString() : String
      {
         return formatToString("LoaderEvent","type","percentQueue","percentItem","item","queueCount","failCount","queueLength","loader","loadTime");
      }
   }
}

