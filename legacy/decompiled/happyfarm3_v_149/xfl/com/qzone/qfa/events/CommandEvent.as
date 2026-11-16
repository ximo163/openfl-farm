package com.qzone.qfa.events
{
   import flash.events.Event;
   
   public class CommandEvent extends Event
   {
      
      public static const REQUEST:String = "RequestCommand";
      
      public static const COMPLETE:String = "CommandComplete";
      
      public static const ERROR:String = "CommandError";
      
      public var body:*;
      
      public var dataBindCall:Function;
      
      public var command:Class;
      
      public var completeHandler:Function;
      
      public var dataBindStr:String;
      
      public var errorHandler:Function;
      
      public var result:*;
      
      public function CommandEvent(param1:String, param2:Class = null, param3:* = null, param4:String = "", param5:Function = null, param6:Function = null, param7:Function = null, param8:Boolean = false, param9:Boolean = false)
      {
         this.command = param2;
         this.body = param3;
         this.dataBindStr = param4;
         this.dataBindCall = param5;
         this.completeHandler = param6;
         this.errorHandler = param7;
         super(param1,param8,param9);
      }
   }
}

