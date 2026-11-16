package com.qzone.qfa.commands
{
   import com.qzone.qfa.core.Command;
   import com.qzone.qfa.debug.Debugger;
   import com.qzone.qfa.events.QFAEvent;
   import com.qzone.qfa.net.HttpRequest;
   
   public class CmdHttpRequest extends Command
   {
      
      private var _errorHandler:Function;
      
      private var _params:*;
      
      private var _completeHandler:Function;
      
      private var _req:HttpRequest;
      
      public function CmdHttpRequest()
      {
         super();
      }
      
      private function handleError(param1:QFAEvent) : void
      {
         this._req.removeEventListener(QFAEvent.COMPLETE,this.handleEvents);
         this._req.removeEventListener(QFAEvent.ERROR,this.handleError);
         if(this._errorHandler != null)
         {
            this._errorHandler(param1);
         }
         finish();
      }
      
      private function handleEvents(param1:QFAEvent) : void
      {
         this._req.removeEventListener(QFAEvent.COMPLETE,this.handleEvents);
         this._req.removeEventListener(QFAEvent.ERROR,this.handleError);
         if(this._completeHandler != null)
         {
            this._completeHandler(param1);
         }
         finish();
      }
      
      override public function execute(param1:* = null) : void
      {
         if(param1 == null)
         {
            param1 = super.body;
         }
         Debugger.log("[QFA]request, url:" + param1.url);
         this._req = new HttpRequest(param1.url,param1.method);
         this._errorHandler = param1.error;
         this._completeHandler = param1.complete;
         this._req.addEventListener(QFAEvent.COMPLETE,this.handleEvents);
         this._req.addEventListener(QFAEvent.ERROR,this.handleError);
         this._params = param1.params;
         this._req.send(this._params);
         super._running = true;
      }
   }
}

