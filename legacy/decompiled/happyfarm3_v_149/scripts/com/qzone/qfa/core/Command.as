package com.qzone.qfa.core
{
   import com.qzone.qfa.events.CommandEvent;
   import flash.events.EventDispatcher;
   
   public class Command extends EventDispatcher implements ICommand
   {
      
      protected var _running:Boolean;
      
      private var _body:*;
      
      public function Command()
      {
         super();
         this.init();
      }
      
      public function set body(param1:*) : void
      {
         this._body = param1;
      }
      
      protected function error(param1:* = null) : void
      {
         this._running = false;
         var _loc2_:CommandEvent = new CommandEvent(CommandEvent.ERROR);
         if(param1)
         {
            _loc2_.result = param1;
         }
         if(this._body != null)
         {
            _loc2_.body = this._body;
         }
         dispatchEvent(_loc2_);
      }
      
      public function get body() : *
      {
         return this._body;
      }
      
      protected function finish(param1:* = null) : void
      {
         this._running = false;
         var _loc2_:CommandEvent = new CommandEvent(CommandEvent.COMPLETE);
         if(param1)
         {
            _loc2_.result = param1;
         }
         if(this._body != null)
         {
            _loc2_.body = this._body;
         }
         dispatchEvent(_loc2_);
      }
      
      public function init() : void
      {
      }
      
      public function execute(param1:* = null) : void
      {
         this._running = true;
         this.finish();
      }
      
      public function destroy() : void
      {
         this._running = false;
      }
      
      public function get running() : Boolean
      {
         return this._running;
      }
   }
}

