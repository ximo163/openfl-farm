package com.qzone.qfa.net
{
   import com.qzone.qfa.config.QFAError;
   import com.qzone.qfa.events.QFAEvent;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   
   public class HttpRequest extends URLLoader implements IRequest
   {
      
      protected var _urlReq:URLRequest;
      
      protected var _method:String;
      
      protected var _url:String;
      
      protected var _format:String;
      
      public function HttpRequest(param1:String = "", param2:String = "post")
      {
         super();
         this._url = param1;
         this._method = param2;
         addEventListener(IOErrorEvent.IO_ERROR,this.handleError);
         addEventListener(ErrorEvent.ERROR,this.handleError);
         addEventListener(Event.COMPLETE,this.handleComplete);
         addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError);
         addEventListener(HTTPStatusEvent.HTTP_STATUS,this.handleStatus);
      }
      
      protected function handleComplete(param1:Event) : void
      {
         dispatchEvent(new QFAEvent(QFAEvent.COMPLETE,data));
      }
      
      protected function handleError(param1:Event) : void
      {
         this.close();
         if(param1 is SecurityErrorEvent)
         {
            dispatchEvent(new QFAEvent(QFAEvent.ERROR,QFAError.ERR_SECURITY));
         }
         else
         {
            dispatchEvent(new QFAEvent(QFAEvent.ERROR,QFAError.ERR_IO));
         }
      }
      
      public function send(param1:Object = null) : void
      {
         var _loc2_:Object = null;
         var _loc3_:URLVariables = null;
         var _loc4_:String = null;
         this._urlReq = new URLRequest(this._url);
         this._urlReq.method = this._method;
         if(param1)
         {
            if(param1 is String || param1 is URLVariables)
            {
               _loc2_ = param1;
            }
            else
            {
               _loc3_ = new URLVariables();
               for(_loc4_ in param1)
               {
                  _loc3_[_loc4_] = param1[_loc4_];
               }
               _loc2_ = _loc3_;
            }
            this._urlReq.data = _loc2_;
         }
         load(this._urlReq);
      }
      
      override public function close() : void
      {
         super.close();
         removeEventListener(IOErrorEvent.IO_ERROR,this.handleError);
         removeEventListener(ErrorEvent.ERROR,this.handleError);
         removeEventListener(Event.COMPLETE,this.handleComplete);
         removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError);
         removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.handleStatus);
      }
      
      protected function handleStatus(param1:HTTPStatusEvent) : void
      {
         if(param1.status > 400 && param1.status < 510)
         {
            this.close();
            dispatchEvent(new QFAEvent(QFAEvent.ERROR,QFAError.ERR_HTTP_STATUS));
         }
      }
   }
}

