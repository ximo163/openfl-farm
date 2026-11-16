package com.qzone.qfa.model
{
   public class DebugLog
   {
      
      public static const LOG:int = 0;
      
      public static const WARNING:int = 1;
      
      public static const ERROR:int = 2;
      
      public static const TRAFFIC:int = 3;
      
      public var msg:String;
      
      public var type:int;
      
      public var time:String;
      
      public function DebugLog(param1:String, param2:int = 0, param3:String = "")
      {
         var _loc4_:Date = null;
         super();
         this.type = param2;
         this.msg = param1;
         if(!this.time)
         {
            _loc4_ = new Date();
            this.time = _loc4_.getHours() + ":" + _loc4_.getMinutes() + ":" + _loc4_.getSeconds() + ":" + _loc4_.getMilliseconds();
         }
      }
      
      public function toStringWithoutFormat() : String
      {
         return this.time + " : \n" + this.msg;
      }
      
      public function toString() : String
      {
         return "<p class=\'t\'>" + this.time + ":</p><p class=\'m\'>" + this.msg.replace(/\</g,"&lt;").replace(/\>/g,"&gt;") + "</p>";
      }
   }
}

