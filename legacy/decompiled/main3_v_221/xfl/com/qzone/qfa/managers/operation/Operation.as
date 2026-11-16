package com.qzone.qfa.managers.operation
{
   import flash.events.EventDispatcher;
   
   public class Operation extends EventDispatcher implements IOperation
   {
      
      protected var _url:String;
      
      public function Operation()
      {
         super();
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function send(param1:Object = null) : void
      {
      }
      
      public function set url(param1:String) : void
      {
         this._url = param1;
      }
      
      public function close() : void
      {
      }
   }
}

