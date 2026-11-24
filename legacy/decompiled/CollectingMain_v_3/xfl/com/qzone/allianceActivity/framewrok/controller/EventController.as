package com.qzone.allianceActivity.framewrok.controller
{
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import flash.events.EventDispatcher;
   
   public class EventController extends EventDispatcher implements IEventController
   {
      
      public function EventController()
      {
         super();
      }
      
      public function addHandler(param1:String, param2:Function, param3:Boolean = true) : void
      {
         this.addEventListener(param1,param2,false,0,param3);
      }
      
      public function handleEvent(param1:MVCEvent) : Boolean
      {
         return this.dispatchEvent(param1);
      }
      
      public function hasHandler(param1:String) : Boolean
      {
         return this.hasEventListener(param1);
      }
      
      public function removeHandler(param1:String, param2:Function) : void
      {
         this.removeEventListener(param1,param2);
      }
   }
}

