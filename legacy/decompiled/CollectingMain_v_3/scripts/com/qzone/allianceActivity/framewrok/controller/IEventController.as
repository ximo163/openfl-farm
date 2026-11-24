package com.qzone.allianceActivity.framewrok.controller
{
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import flash.events.IEventDispatcher;
   
   public interface IEventController extends IEventDispatcher
   {
      
      function hasHandler(param1:String) : Boolean;
      
      function addHandler(param1:String, param2:Function, param3:Boolean = true) : void;
      
      function handleEvent(param1:MVCEvent) : Boolean;
      
      function removeHandler(param1:String, param2:Function) : void;
   }
}

