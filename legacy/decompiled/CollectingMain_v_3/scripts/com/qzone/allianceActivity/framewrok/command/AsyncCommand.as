package com.qzone.allianceActivity.framewrok.command
{
   import com.qzone.allianceActivity.framewrok.events.CommandEvent;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AsyncCommand extends EventDispatcher implements IAsyncCommand
   {
      
      protected var _timer:Timer;
      
      protected var _error:*;
      
      protected var _event:MVCEvent;
      
      protected var _timeout:Number = -1;
      
      public var faultContinue:Boolean = true;
      
      protected var _result:*;
      
      public function AsyncCommand()
      {
         super();
         this.addResultHandler(this.__completeHandler);
         this.addErrorHandler(this.__errorHandler);
      }
      
      protected function __completeHandler(param1:CommandEvent) : void
      {
         this.removeTimeoutHandler();
      }
      
      public function dispatchCompleteEvent() : Boolean
      {
         return this.dispatchEvent(new CommandEvent(CommandEvent.COMMAND_COMPLETE));
      }
      
      public function get error() : *
      {
         return this._error;
      }
      
      public function removeErrorHandler(param1:Function) : void
      {
         this.removeEventListener(CommandEvent.COMMAND_ERROR,param1);
      }
      
      public function removeResultHandler(param1:Function) : void
      {
         this.removeEventListener(CommandEvent.COMMAND_COMPLETE,param1);
      }
      
      public function addResultHandler(param1:Function, param2:Boolean = false) : void
      {
         this.addEventListener(CommandEvent.COMMAND_COMPLETE,param1,false,0,param2);
      }
      
      protected function removeTimeoutHandler() : void
      {
         if(Boolean(this._timer) && this._timer.hasEventListener(TimerEvent.TIMER))
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.timeoutHandler);
            this._timer = null;
         }
      }
      
      public function exec(param1:MVCEvent = null) : void
      {
         this._event = param1;
         this.__exec(param1);
      }
      
      public function set timeout(param1:Number) : void
      {
         this._timeout = param1;
         if(this._timeout > 0)
         {
            if(this._timer)
            {
               if(this._timer.running)
               {
                  this._timer.removeEventListener(TimerEvent.TIMER,this.timeoutHandler);
                  this._timer.stop();
               }
               this._timer = null;
            }
            this._timer = new Timer(this._timeout,1);
            this._timer.addEventListener(TimerEvent.TIMER,this.timeoutHandler);
            this._timer.start();
         }
      }
      
      public function get timeout() : Number
      {
         return this._timeout;
      }
      
      public function addErrorHandler(param1:Function, param2:Boolean = false) : void
      {
         this.addEventListener(CommandEvent.COMMAND_ERROR,param1,false,0,param2);
      }
      
      public function get result() : *
      {
         return this._result;
      }
      
      protected function __errorHandler(param1:CommandEvent) : void
      {
         this.removeTimeoutHandler();
      }
      
      protected function timeoutHandler(param1:TimerEvent) : void
      {
         this.removeTimeoutHandler();
         this.dispatchErrorEvent();
      }
      
      protected function __exec(param1:MVCEvent) : void
      {
      }
      
      public function dispatchErrorEvent() : Boolean
      {
         return this.dispatchEvent(new CommandEvent(CommandEvent.COMMAND_ERROR));
      }
   }
}

