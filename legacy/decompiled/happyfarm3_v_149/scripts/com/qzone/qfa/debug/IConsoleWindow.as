package com.qzone.qfa.debug
{
   import flash.events.IEventDispatcher;
   
   public interface IConsoleWindow extends IEventDispatcher
   {
      
      function hide() : void;
      
      function get isHidden() : Boolean;
      
      function set dataProvider(param1:Array) : void;
      
      function set logType(param1:int) : void;
      
      function get logType() : int;
   }
}

