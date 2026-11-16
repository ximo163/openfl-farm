package com.qzone.qfa.managers.events
{
   import com.qzone.qfa.managers.LoadManager;
   import com.qzone.qfa.managers.resource.Resource;
   import flash.events.Event;
   import flash.media.ID3Info;
   
   public class LoaderEvent extends Event
   {
      
      public static const STATUS_CHANGED:String = "qfa.LoaderEvent.STATUS_CHANGED";
      
      public static const ID3_COMPLETE:String = "qfa.LoaderEvent.ID3_COMPLETE";
      
      public static const ERROR:String = "qfa.LoaderEvent.ERROR";
      
      public static const START:String = "qfa.LoaderEvent.START";
      
      public static const INIT:String = "qfa.LoaderEvent.INIT";
      
      public static const PROGRESS:String = "qfa.LoaderEvent.PROGRESS";
      
      public static const COMPLETE:String = "qfa.LoaderEvent.COMPLETE";
      
      public static const QUEUE_CHANGED:String = "qfa.LoaderEvent.QUEUE_CHANGED";
      
      public static const QUEUE_START:String = "qfa.LoaderEvent.QUEUE_START";
      
      public static const QUEUE_PROGRESS:String = "qfa.LoaderEvent.QUEUE_PROGRESS";
      
      public static const QUEUE_COMPLETE:String = "qfa.LoaderEvent.QUEUE_COMPLETE";
      
      public static const COMPATIBLE_COMPLETE:String = "qfa.LoaderEvent.COMPATIBLE_COMPLETE";
      
      public var msg:String = "";
      
      public var queue_count:int;
      
      public var percentQueue:Number;
      
      public var fail_count:int;
      
      public var loader:LoadManager;
      
      public var queue_length:int;
      
      public var id3Info:ID3Info;
      
      public var bytesLoaded:Number;
      
      public var bytesTotal:Number;
      
      public var item:Resource;
      
      public var percentItem:Number;
      
      public function LoaderEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      override public function toString() : String
      {
         var _loc1_:Array = ["LoaderEvent","type","percentQueue","percentItem","item","queue_count","fail_count","queue_length","loader"];
         if(this.msg)
         {
            _loc1_.push("msg");
         }
         return formatToString.apply(this,_loc1_);
      }
      
      override public function clone() : Event
      {
         return new LoaderEvent(type,bubbles,cancelable);
      }
   }
}

