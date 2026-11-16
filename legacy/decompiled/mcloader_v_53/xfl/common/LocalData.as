package common
{
   import flash.display.Sprite;
   import flash.net.SharedObject;
   import flash.net.SharedObjectFlushStatus;
   import flash.text.StyleSheet;
   
   public class LocalData
   {
      
      public static var textGlowFilter:Array;
      
      public static var friendTxt:String;
      
      private static var _parameters:Object;
      
      public static var showCdkeyEntry:Boolean;
      
      public static var commonUrl:String;
      
      private static var instance:LocalData;
      
      public static var cardMaterialConfig:String;
      
      public static var updateView:Function;
      
      public static var lastRequestHandle:Function;
      
      public static var lastRequestUrl:String;
      
      public static var shengShanAnimal:Sprite;
      
      public static var onJSsetUrl:Function;
      
      private static var _useflag:String;
      
      public static var stealTxt:String;
      
      public static var ownerHeadUrl:String;
      
      public static var reclaimType:int;
      
      public static var loginTxt:String;
      
      public static var lastRequestFn:Function;
      
      public static var houseLevel:int;
      
      public static var useExpressUser:Boolean;
      
      public static var expressUser:Object;
      
      public static var animalConfig:String;
      
      public static var lastRequestValue:Object;
      
      public static var isMe:Boolean;
      
      public static var friendListFlag:Boolean;
      
      public static var stealFlag:Boolean;
      
      public static var loginFlag:Boolean;
      
      public static var farmlands:Sprite;
      
      public static var rollCollection:Sprite;
      
      public static var initTime:int;
      
      public static var plands:Sprite;
      
      public static var YD_FONT_COLOR:int = 3355443;
      
      public static var CSS_A_HOVER:String = "a:link {color: #333333;font-family:\"Arial Black\";} a:hover{text-decoration:underline; color:#FF6600;}";
      
      public static var CSS_A_HOVER_AD:String = "a:link {color:#FF0000;font-family:\"Arial Black\";} a:hover{text-decoration:underline;color:#FF0000;}";
      
      public static var YD_SHEET:StyleSheet = new StyleSheet();
      
      public static var AD_SHEET:StyleSheet = new StyleSheet();
      
      public static var app_key:String = "happyfarm";
      
      public static var mode:String = "";
      
      public static var limitedTimes:int = 3;
      
      public static var getFriendListDelay:int = 3000;
      
      public static var module:String = "";
      
      public static var playingAnimation:Boolean = false;
      
      public static var xymode:String = "";
      
      public static var saveQuickShootUrl:String = "cgi_upload_post";
      
      private var localDataName:String;
      
      public function LocalData(param1:String = "FarmWorld")
      {
         super();
         if(instance == null)
         {
            this.localDataName = param1;
            return;
         }
         throw new Error("实例化单例类出错-LocalData");
      }
      
      public static function getInstance(param1:String = "FarmWorld") : LocalData
      {
         if(!instance)
         {
            instance = new LocalData(param1);
         }
         return instance;
      }
      
      public static function set parameters(param1:Object) : void
      {
         _parameters = param1;
      }
      
      public static function set useflag(param1:String) : void
      {
         _useflag = param1;
         if(mode == "qzone" || xymode == "")
         {
            friendListFlag = _useflag.substr(7,1) == "1" ? true : false;
         }
         else
         {
            friendListFlag = _useflag.substr(6,1) == "1" ? true : false;
         }
         stealFlag = _useflag.substr(5,1) == "1" ? true : false;
         loginFlag = _useflag.substr(4,1) == "1" ? true : false;
      }
      
      public static function get parameters() : Object
      {
         return _parameters;
      }
      
      public function setObject(param1:String, param2:Object, param3:Number = 0, param4:Boolean = false) : Boolean
      {
         var _loc6_:Boolean = false;
         var _loc5_:SharedObject = SharedObject.getLocal(this.localDataName);
         if(param3 == 0)
         {
            param3 = new Date(2038,12,31).time;
         }
         _loc5_.data[param1] = {
            "value":param2,
            "time":param3
         };
         if(param4)
         {
            _loc6_ = this.flush(_loc5_);
            if(_loc6_ == false)
            {
               delete _loc5_.data[param1];
            }
            return _loc6_;
         }
         return param4;
      }
      
      private function flush(param1:SharedObject) : Boolean
      {
         var flushResult:String = null;
         var so:SharedObject = param1;
         try
         {
            flushResult = so.flush();
            if(flushResult == SharedObjectFlushStatus.PENDING)
            {
               trace("PENDING -- 数据超出限制");
            }
            else if(flushResult == SharedObjectFlushStatus.FLUSHED)
            {
               trace("FlUSHED -- 成功写入");
            }
            return true;
         }
         catch(e:Error)
         {
            trace("ERROR -- 写入失败");
         }
         return false;
      }
      
      public function getObject(param1:String, param2:Number = 0) : Object
      {
         var returnValue:Object = null;
         var so:SharedObject = null;
         var dif:Number = NaN;
         var name:String = param1;
         var time:Number = param2;
         try
         {
            so = SharedObject.getLocal(this.localDataName);
            if(time == 0)
            {
               time = new Date().time;
            }
            if(so.data[name])
            {
               if(so.data[name].hasOwnProperty("time"))
               {
                  dif = so.data[name].time - time;
                  if(dif >= 0)
                  {
                     returnValue = so.data[name].value;
                  }
               }
               else
               {
                  returnValue = so.data[name];
               }
            }
         }
         catch(e:Error)
         {
            trace(e);
         }
         return returnValue;
      }
      
      public function hasObject(param1:String) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc5_:int = 0;
         var _loc2_:SharedObject = SharedObject.getLocal(this.localDataName);
         var _loc4_:int = new Date().time;
         if(_loc2_.data.hasOwnProperty(param1))
         {
            _loc5_ = _loc2_.data[param1].time - _loc4_;
            if(_loc5_ > 0)
            {
               _loc3_ = true;
            }
         }
         return _loc3_;
      }
      
      public function clearObject(param1:String) : void
      {
         var _loc2_:SharedObject = SharedObject.getLocal(this.localDataName);
         delete _loc2_.data[param1];
      }
   }
}

