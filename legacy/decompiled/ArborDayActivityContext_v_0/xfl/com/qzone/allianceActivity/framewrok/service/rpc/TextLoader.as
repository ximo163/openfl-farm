package com.qzone.allianceActivity.framewrok.service.rpc
{
   import com.qzone.allianceActivity.framewrok.manager.JSAPI;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   
   public class TextLoader extends URLLoader implements IRemoteLoader
   {
      
      private var _paramNames:Array;
      
      private var _method:String;
      
      private var _responder:IResponder;
      
      private var _requestMethond:String = "GET";
      
      public function TextLoader(param1:String = null, param2:Array = null)
      {
         super(null);
         this.dataFormat = URLLoaderDataFormat.TEXT;
         this.method = param1;
         this.paramNames = param2;
      }
      
      public function send(param1:Array = null) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:* = undefined;
         var _loc2_:URLVariables = new URLVariables();
         if(Boolean(this.paramNames) && this.paramNames.length > 0)
         {
            _loc2_ = new URLVariables();
            _loc4_ = 0;
            while(_loc4_ < this.paramNames.length)
            {
               _loc5_ = this.paramNames[_loc4_];
               if(Boolean(param1) && _loc4_ < param1.length)
               {
                  _loc6_ = param1[_loc4_];
               }
               _loc2_[_loc5_] = _loc6_;
               _loc4_++;
            }
         }
         _loc2_.g_tk = JSAPI.getToken();
         if(this._requestMethond == URLRequestMethod.POST)
         {
            this.method = JSAPI.attachDefParam(this.method);
         }
         var _loc3_:URLRequest = new URLRequest(this.method);
         _loc3_.method = this._requestMethond;
         if(_loc2_)
         {
            _loc3_.data = _loc2_;
         }
         addEventListener(Event.COMPLETE,this.resultHandler);
         addEventListener(IOErrorEvent.IO_ERROR,this.faultHandler);
         addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.faultHandler);
         load(_loc3_);
      }
      
      private function resultHandler(param1:Event) : void
      {
         this._responder.resultHandler(data);
      }
      
      private function faultHandler(param1:Event) : void
      {
         this._responder.faultHandler(param1);
      }
      
      public function addResponder(param1:Function, param2:Function = null) : void
      {
         this._responder = new RemoteResponder(this,param1,param2);
      }
      
      public function get method() : String
      {
         return this._method;
      }
      
      public function set method(param1:String) : void
      {
         this._method = param1;
      }
      
      public function get paramNames() : Array
      {
         return this._paramNames;
      }
      
      public function set paramNames(param1:Array) : void
      {
         this._paramNames = param1;
      }
      
      public function get requestMethond() : String
      {
         return this._requestMethond;
      }
      
      public function set requestMethond(param1:String) : void
      {
         this._requestMethond = param1;
      }
   }
}

