package com.qzone.allianceActivity.framewrok.operation
{
   import flash.events.IEventDispatcher;
   
   public interface IOperation extends IEventDispatcher
   {
      
      function get result() : *;
      
      function get error() : *;
      
      function get timeout() : Number;
      
      function set timeout(param1:Number) : void;
      
      function addResultHandler(param1:Function, param2:Boolean = false) : void;
      
      function removeResultHandler(param1:Function) : void;
      
      function addErrorHandler(param1:Function, param2:Boolean = false) : void;
      
      function removeErrorHandler(param1:Function) : void;
   }
}

