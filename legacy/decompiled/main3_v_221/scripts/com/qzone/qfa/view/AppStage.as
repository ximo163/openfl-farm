package com.qzone.qfa.view
{
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qfa.interfaces.IApplication;
   import com.qzone.qfa.managers.ResourceManager;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class AppStage extends Sprite
   {
      
      protected var resources:ResourceManager = ResourceManager.gi();
      
      protected var _owner:IApplication;
      
      public function AppStage(param1:IApplication = null)
      {
         super();
         if(param1)
         {
            this._owner = param1;
         }
         this.addEventListener(Event.ADDED_TO_STAGE,this.__init);
      }
      
      protected function handleRequestCommand(param1:CommandEvent) : void
      {
         if(param1.command)
         {
            if(param1.body is Object)
            {
               param1.body.requester = param1.target;
            }
            this.owner.run(param1.command,param1.body,param1.dataBindStr,param1.dataBindCall,param1.completeHandler,param1.errorHandler);
         }
      }
      
      public function set owner(param1:IApplication) : void
      {
         this._owner = param1;
      }
      
      protected function removeEventListeners() : void
      {
         this.removeEventListener(CommandEvent.REQUEST,this.handleRequestCommand);
         stage.removeEventListener(Event.RESIZE,this.handleResized);
      }
      
      protected function addEventListeners() : void
      {
         this.addEventListener(CommandEvent.REQUEST,this.handleRequestCommand,true);
         stage.addEventListener(Event.RESIZE,this.handleResized);
      }
      
      protected function handleResized(param1:Event) : void
      {
      }
      
      private function __init(param1:Event) : void
      {
         this.removeEventListener(Event.ADDED_TO_STAGE,this.__init);
         this.addEventListeners();
      }
      
      public function init() : void
      {
      }
      
      protected function handleRemoved(param1:Event) : void
      {
      }
      
      public function get owner() : IApplication
      {
         return this._owner;
      }
      
      public function destory() : void
      {
         this.removeEventListeners();
         this._owner = null;
      }
      
      protected function handleAdded(param1:Event) : void
      {
      }
   }
}

