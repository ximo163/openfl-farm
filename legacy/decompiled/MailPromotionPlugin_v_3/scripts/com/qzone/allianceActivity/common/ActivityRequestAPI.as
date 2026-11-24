package com.qzone.allianceActivity.common
{
   import com.adobe.serialization.json.JSON;
   import com.qzone.allianceActivity.framewrok.manager.JSAPI;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   
   public class ActivityRequestAPI
   {
      
      private static var _callback:Function;
      
      private static var _url:String;
      
      private static var _ul:URLLoader = new URLLoader();
      
      public function ActivityRequestAPI()
      {
         super();
      }
      
      public static function getGift(param1:String, param2:int, param3:Function, param4:String = "") : void
      {
         _url = getURL() + "gift/gift_send";
         var _loc5_:URLVariables = new URLVariables();
         _loc5_.appid = param1;
         _loc5_.type = param2;
         if(param4 != "")
         {
            _loc5_.old_gifts = param4;
         }
         _callback = param3;
         sendRequst(_loc5_);
      }
      
      private static function sendRequst(param1:URLVariables = null) : void
      {
         var _loc2_:URLRequest = new URLRequest(JSAPI.attachDefParam(_url));
         _loc2_.method = URLRequestMethod.POST;
         _loc2_.data = param1;
         _ul.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
         _ul.addEventListener(Event.COMPLETE,loadComplete);
         _ul.load(_loc2_);
      }
      
      private static function errorHandler(param1:IOErrorEvent) : void
      {
         trace(param1);
      }
      
      public static function getGiftList(param1:String, param2:int, param3:Function) : void
      {
         _url = getURL() + "gift/gift_list";
         var _loc4_:URLVariables = new URLVariables();
         _loc4_.appid = param1;
         _loc4_.type = param2;
         _callback = param3;
         sendRequst(_loc4_);
      }
      
      public static function payGoods(param1:String, param2:int, param3:int, param4:String, param5:int, param6:Function, param7:int = 1, param8:String = "", param9:int = 3) : void
      {
         _url = getURL() + "activity/price_goods";
         var _loc10_:URLVariables = new URLVariables();
         _loc10_.appid = param1;
         _loc10_.type = param2;
         _loc10_.id = param3;
         _loc10_.name = param4;
         _loc10_.serviceid = param7;
         _loc10_.v = param9;
         _loc10_.num = param5;
         _callback = param6;
         sendRequst(_loc10_);
      }
      
      public static function getActivityInfo(param1:int, param2:String, param3:Function) : void
      {
         _url = getURL() + "activity/get_actinfo";
         var _loc4_:URLVariables = new URLVariables();
         _loc4_.actid = param1;
         _loc4_.appid = param2;
         _callback = param3;
         sendRequst(_loc4_);
      }
      
      public static function getGiftInfo(param1:String, param2:int, param3:Function, param4:int = 0) : void
      {
         _url = getURL() + "gift/gift_info";
         var _loc5_:URLVariables = new URLVariables();
         _loc5_.appid = param1;
         _loc5_.types = param2;
         _loc5_.level = param4;
         _callback = param3;
         sendRequst(_loc5_);
      }
      
      private static function getURL() : String
      {
         var _loc1_:String = "";
         if(JSAPI.isQzone)
         {
            _loc1_ = "";
         }
         else
         {
            _loc1_ = "";
         }
         return _loc1_;
      }
      
      public static function exchangeGift(param1:int, param2:String, param3:int, param4:Function, param5:int = 0) : void
      {
         _url = getURL() + "activity/exchange_gift";
         var _loc6_:URLVariables = new URLVariables();
         _loc6_.actid = param1;
         _loc6_.appid = param2;
         _loc6_.packid = param3;
         _loc6_.input = param5;
         _callback = param4;
         sendRequst(_loc6_);
      }
      
      public static function getScore(param1:int, param2:String, param3:Function) : void
      {
         _url = getURL() + "activity/get_score";
         var _loc4_:URLVariables = new URLVariables();
         _loc4_.actid = param1;
         _loc4_.appid = param2;
         _callback = param3;
         sendRequst(_loc4_);
      }
      
      private static function loadComplete(param1:Event) : void
      {
         var _loc2_:Object = null;
         if(_callback != null)
         {
            _loc2_ = com.adobe.serialization.json.JSON.decode(param1.target.data);
            _callback(_loc2_);
         }
      }
   }
}

