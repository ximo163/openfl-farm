package com.qzone.corelib.controls.interfaces
{
   import flash.events.IEventDispatcher;
   
   public interface IController extends IEventDispatcher
   {
      
      function get enabled() : Boolean;
      
      function set enabled(param1:Boolean) : void;
   }
}

