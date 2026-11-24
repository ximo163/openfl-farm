package com.qzone.allianceActivity.framewrok.operation
{
   import flash.events.IEventDispatcher;
   
   public interface IOperation extends IEventDispatcher
   {
      
      function get timeout() : Number;
      
      function set timeout(param1:Number) : void;
      
      function addErrorHandler(param1:Function, param2:Boolean = false) : void;
      
      function removeErrorHandler(param1:Function) : void;
      
      function get error() : *;
      
      function removeResultHandler(param1:Function) : void;
      
      function addResultHandler(param1:Function, param2:Boolean = false) : void;
      
      function get result() : *;
   }
}

