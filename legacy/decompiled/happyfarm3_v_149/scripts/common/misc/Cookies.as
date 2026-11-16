package common.misc
{
   import flash.events.NetStatusEvent;
   import flash.net.SharedObject;
   import flash.net.SharedObjectFlushStatus;
   
   public class Cookies
   {
      
      private static var Cookie:SharedObject = null;
      
      public function Cookies()
      {
         super();
      }
      
      public static function hasObject(param1:String) : Boolean
      {
         var _loc4_:int = 0;
         if(Cookie == null)
         {
            return false;
         }
         var _loc2_:Boolean = false;
         var _loc3_:int = new Date().time;
         if(Cookie.data[param1] != undefined)
         {
            if(Cookie.data[param1].hasOwnProperty("time"))
            {
               _loc4_ = Cookie.data[param1].time - _loc3_;
               if(_loc4_ > 0)
               {
                  _loc2_ = true;
               }
            }
         }
         return _loc2_;
      }
      
      public static function setObject(param1:String, param2:Object, param3:Number = 0, param4:Boolean = false) : Boolean
      {
         var _loc5_:Boolean = false;
         if(Cookie == null)
         {
            return false;
         }
         if(param3 == 0)
         {
            param3 = new Date(2038,12,31).time;
         }
         Cookie.data[param1] = {
            "value":param2,
            "time":param3
         };
         if(param4)
         {
            _loc5_ = flush();
            if(_loc5_ == false)
            {
               delete Cookie.data[param1];
            }
            return _loc5_;
         }
         return param4;
      }
      
      public static function Set(param1:String, param2:String) : Boolean
      {
         if(Cookie == null)
         {
            return false;
         }
         if(param1 == null || param1 == "")
         {
            return false;
         }
         if(param2 == null || param2 == "")
         {
            return false;
         }
         Cookie.data[param1] = param2;
         return flush();
      }
      
      public static function getObject(param1:String, param2:Number = 0) : Object
      {
         var returnValue:Object;
         var diff:Number = NaN;
         var name:String = param1;
         var time:Number = param2;
         if(Cookie == null)
         {
            return null;
         }
         returnValue = null;
         try
         {
            if(time == 0)
            {
               time = new Date().time;
            }
            if(Cookie.data[name] != undefined)
            {
               if(Cookie.data[name].hasOwnProperty("time"))
               {
                  diff = Cookie.data[name].time - time;
                  if(diff >= 0)
                  {
                     returnValue = Cookie.data[name].value;
                  }
               }
               else
               {
                  returnValue = Cookie.data[name];
               }
            }
         }
         catch(e:Error)
         {
            trace("Cookies exception: " + e);
         }
         return returnValue;
      }
      
      public static function Get(param1:String) : String
      {
         if(Cookie == null)
         {
            return null;
         }
         if(param1 == null || param1 == "")
         {
            return null;
         }
         return Cookie.data[param1];
      }
      
      private static function onNetStatusError(param1:NetStatusEvent) : void
      {
         trace("Cookies exception: " + param1);
      }
      
      private static function flush() : Boolean
      {
         var flushResult:String = null;
         if(Cookie == null)
         {
            return false;
         }
         try
         {
            flushResult = Cookie.flush();
            if(flushResult == SharedObjectFlushStatus.PENDING)
            {
               trace("Cookies: PENDING -- 数据超出限制");
            }
            else if(flushResult == SharedObjectFlushStatus.FLUSHED)
            {
               trace("Cookies: FlUSHED -- 成功写入");
            }
         }
         catch(e:Error)
         {
            trace("Cookies exception: " + e);
            return false;
         }
         return true;
      }
      
      public static function clear() : void
      {
         if(Cookie == null)
         {
            return;
         }
         try
         {
            Cookie.clear();
         }
         catch(e:Error)
         {
            trace("Cookies exception: " + e);
         }
      }
      
      public static function intialize(param1:String) : void
      {
         var game:String = param1;
         try
         {
            Cookie = SharedObject.getLocal(game);
            Cookie.addEventListener(NetStatusEvent.NET_STATUS,onNetStatusError,false,0,true);
         }
         catch(e:Error)
         {
            trace("Cookies exception: " + e);
         }
      }
   }
}

