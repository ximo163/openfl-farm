package framework.net.core
{
   import com.qzone.qfa.managers.events.RequestEvent;
   import com.qzone.qfa.managers.operation.HttpOperation;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import framework.net.CommandDefs;
   
   public class HttpOperationEx extends HttpOperation
   {
      
      private static var _timer:Timer;
      
      private var m_isHandled:Boolean;
      
      private var m_requestNum:int;
      
      private var m_reload:Boolean;
      
      private var m_timeout:int;
      
      private var m_timerValue:int;
      
      public function HttpOperationEx(param1:String = "", param2:Object = null)
      {
         super(param1,param2);
         this.m_timerValue = 0;
         this.m_timeout = 60 * 1000;
         this.m_requestNum = 0;
         this.m_reload = false;
         this.m_isHandled = false;
         if(_timer == null)
         {
            _timer = new Timer(1000);
            _timer.start();
         }
      }
      
      override protected function handleComplete(param1:Event) : void
      {
         var _loc2_:Object = null;
         if(this.m_isHandled == false)
         {
            _loc2_ = param1.currentTarget.data;
            dispatchEvent(new RequestEvent(RequestEvent.RESULT,_loc2_));
            this.m_isHandled = true;
         }
         this.clearAll();
      }
      
      override protected function handleError(param1:Event) : void
      {
         this.clearAll();
      }
      
      override public function send(param1:Object = null) : void
      {
         var ev:IOErrorEvent = null;
         var arg:Object = param1;
         try
         {
            super.send(arg);
         }
         catch(e:Error)
         {
            ev = new IOErrorEvent(IOErrorEvent.NETWORK_ERROR);
            ev.text = e.message;
            ioerrorHandler(ev);
            return;
         }
         this.m_timerValue = getTimer();
         this.m_requestNum = 0;
         this.m_isHandled = false;
         _timer.addEventListener(TimerEvent.TIMER,this.timerFn,false,0,true);
      }
      
      override public function open() : void
      {
         var ev:IOErrorEvent = null;
         try
         {
            if(_urlLoader != null)
            {
               this.close();
            }
            _urlLoader = new URLLoader();
            _urlLoader.dataFormat = _format;
            _urlLoader.addEventListener(Event.COMPLETE,this.handleComplete,false,0,true);
            _urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError,false,0,true);
            _urlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.ioerrorHandler,false,0,true);
            _urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler,false,0,true);
         }
         catch(e:Error)
         {
            ev = new IOErrorEvent(IOErrorEvent.NETWORK_ERROR);
            ev.text = e.message;
            ioerrorHandler(ev);
         }
      }
      
      private function timerFn(param1:TimerEvent) : void
      {
         var _loc2_:int = getTimer();
         var _loc3_:Object = null;
         if(this.m_reload == true)
         {
            if(_loc2_ - this.m_timerValue > this.m_timeout && this.m_requestNum == 0)
            {
               _urlLoader.load(_urlReq);
               this.m_timerValue = _loc2_;
               this.m_requestNum = 1;
            }
            else if(_loc2_ - this.m_timerValue > this.m_timeout && this.m_requestNum == 1)
            {
               if(this.m_isHandled == false)
               {
                  _loc3_ = {
                     "errorType":CommandDefs.HTTP_ERR_TIMEOUT,
                     "content":""
                  };
                  dispatchEvent(new RequestEvent(RequestEvent.FAULT,_loc3_));
                  this.m_isHandled = true;
               }
               this.clearAll();
            }
         }
         else if(_loc2_ - this.m_timerValue > this.m_timeout)
         {
            if(this.m_isHandled == false)
            {
               _loc3_ = {
                  "errorType":CommandDefs.HTTP_ERR_TIMEOUT,
                  "content":""
               };
               dispatchEvent(new RequestEvent(RequestEvent.FAULT,_loc3_));
               this.m_isHandled = true;
            }
            this.clearAll();
         }
      }
      
      private function httpStatusHandler(param1:HTTPStatusEvent) : void
      {
         var _loc2_:Object = null;
         if(param1.status > 400 && param1.status <= 510)
         {
            if(this.m_isHandled == false)
            {
               _loc2_ = {
                  "errorType":CommandDefs.HTTP_ERR_HTTPSTATUS,
                  "errorContent":param1.status
               };
               dispatchEvent(new RequestEvent(RequestEvent.FAULT,_loc2_));
               this.m_isHandled = true;
            }
            if(_timer != null)
            {
               _timer.stop();
               _timer.removeEventListener(TimerEvent.TIMER,this.timerFn);
            }
            if(_urlLoader != null)
            {
               _urlLoader.removeEventListener(Event.COMPLETE,this.handleComplete);
               _urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError);
               _urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler);
            }
         }
      }
      
      public function get reload() : Boolean
      {
         return this.m_reload;
      }
      
      private function clearAll() : void
      {
         this.close();
         if(_timer != null)
         {
            _timer.stop();
            _timer.removeEventListener(TimerEvent.TIMER,this.timerFn);
         }
      }
      
      private function ioerrorHandler(param1:IOErrorEvent) : void
      {
         var _loc2_:Object = null;
         if(this.m_isHandled == false)
         {
            _loc2_ = {
               "errorType":CommandDefs.HTTP_ERR_IOERROR,
               "errorContent":param1.text
            };
            dispatchEvent(new RequestEvent(RequestEvent.FAULT,_loc2_));
            this.m_isHandled = true;
         }
         this.clearAll();
      }
      
      override public function close() : void
      {
         if(_urlLoader == null)
         {
            return;
         }
         _urlLoader.removeEventListener(Event.COMPLETE,this.handleComplete);
         _urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError);
         _urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.ioerrorHandler);
         _urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler);
         _urlLoader = null;
      }
      
      public function set reload(param1:Boolean) : void
      {
         this.m_reload = param1;
      }
   }
}

