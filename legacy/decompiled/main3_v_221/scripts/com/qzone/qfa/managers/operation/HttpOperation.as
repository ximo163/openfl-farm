package com.qzone.qfa.managers.operation
{
   import com.qzone.qfa.managers.errors.ConnectionError;
   import com.qzone.qfa.managers.events.RequestEvent;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   
   public class HttpOperation extends Operation implements IOperation
   {
      
      public static const GET_METHOD:String = "get";
      
      public static const POST_METHOD:String = "post";
      
      protected var _urlLoader:URLLoader;
      
      protected var _method:String;
      
      protected var _urlReq:URLRequest;
      
      protected var _format:String;
      
      public function HttpOperation(param1:String = "", param2:Object = null)
      {
         super();
         this._method = Boolean(param2) && param2.method != null ? param2.method : POST_METHOD;
         this._format = Boolean(param2) && param2.format != null ? param2.format : URLLoaderDataFormat.TEXT;
         this.url = param1;
         this.open();
      }
      
      protected function handleError(param1:Event) : void
      {
         if(param1 is SecurityErrorEvent)
         {
            dispatchEvent(new RequestEvent(RequestEvent.FAULT,ConnectionError.ERR_SECURITY));
         }
         else
         {
            dispatchEvent(new RequestEvent(RequestEvent.FAULT,ConnectionError.ERR_IO));
         }
      }
      
      protected function handleComplete(param1:Event) : void
      {
         dispatchEvent(new RequestEvent(RequestEvent.RESULT,this._urlLoader.data));
      }
      
      override public function send(param1:Object = null) : void
      {
         var _loc2_:Object = null;
         var _loc3_:URLVariables = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(this._urlReq == null)
         {
            this._urlReq = new URLRequest(_url);
         }
         else if(_url != this._urlReq.url)
         {
            this._urlReq.url = _url;
         }
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
            this._urlReq.method = this._method;
            this._urlReq.data = _loc2_;
            if(this._method.toLowerCase() == GET_METHOD && _loc2_ != null)
            {
               _loc5_ = _url;
               if(_loc5_.indexOf("?") == -1)
               {
                  _loc5_ += "?";
               }
               else
               {
                  _loc7_ = _loc5_.charAt(_loc5_.length - 1);
                  if(_loc7_ != "?" && _loc7_ != "&")
                  {
                     _loc5_ += "&";
                  }
               }
               for(_loc6_ in _loc2_)
               {
                  if(_loc6_ != "" && _loc6_ != null)
                  {
                     _loc5_ += _loc6_ + "=" + _loc2_[_loc6_] + "&";
                  }
               }
               this._urlReq.url = _loc5_;
               this._urlReq.data = null;
            }
         }
         this._urlLoader.load(this._urlReq);
      }
      
      public function set method(param1:String) : void
      {
         this._method = param1;
      }
      
      public function open() : void
      {
         if(this._urlLoader)
         {
            this.close();
         }
         this._urlLoader = new URLLoader();
         this._urlLoader.dataFormat = this._format;
         this._urlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.handleError);
         this._urlLoader.addEventListener(ErrorEvent.ERROR,this.handleError);
         this._urlLoader.addEventListener(Event.COMPLETE,this.handleComplete);
         this._urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError);
      }
      
      override public function get url() : String
      {
         return super.url;
      }
      
      public function get method() : String
      {
         return this._method;
      }
      
      override public function set url(param1:String) : void
      {
         if(param1.indexOf("") == -1)
         {
            param1 = "" + param1;
         }
         super.url = param1;
      }
      
      override public function close() : void
      {
         if(this._urlLoader)
         {
            this._urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.handleError);
            this._urlLoader.removeEventListener(ErrorEvent.ERROR,this.handleError);
            this._urlLoader.removeEventListener(Event.COMPLETE,this.handleComplete);
            this._urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError);
            this._urlLoader = null;
         }
      }
   }
}

