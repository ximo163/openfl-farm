package com.qzone.allianceActivity.framewrok.command
{
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import flash.events.IEventDispatcher;
   
   public interface ICommand extends IEventDispatcher
   {
      
      function exec(param1:MVCEvent = null) : void;
   }
}

