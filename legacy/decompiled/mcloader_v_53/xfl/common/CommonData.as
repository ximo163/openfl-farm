package common
{
   import com.qzone.corelib.net.RSLLoader;
   import com.qzone.corelib.net.RSLManager;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.system.ApplicationDomain;
   import flash.utils.getTimer;
   
   public class CommonData extends EventDispatcher
   {
      
      public static var _root:Sprite;
      
      public static var APP_DOMAIN:ApplicationDomain;
      
      public static var rslManager:RSLManager;
      
      public static var applicationDomain:ApplicationDomain;
      
      public static var getKey:Function;
      
      public static var rslLoader:RSLLoader;
      
      private static var _serverTime:Number = 0;
      
      private static var _clientTime:Number = 0;
      
      public static var shopVScroll:Number = 0;
      
      public static var shopTinPage:Boolean = false;
      
      public function CommonData()
      {
         super();
      }
      
      public static function set root(param1:Sprite) : void
      {
         _root = param1;
      }
      
      public static function getFormatNumber(param1:Number) : String
      {
         var _loc4_:String = null;
         var _loc2_:String = param1.toString();
         var _loc3_:String = "";
         while(_loc2_.length != 0)
         {
            if(_loc2_.length < 3)
            {
               _loc4_ = _loc2_.substr(0,_loc2_.length);
            }
            else
            {
               _loc4_ = _loc2_.substr(_loc2_.length - 3,_loc2_.length);
            }
            if(_loc3_ != "")
            {
               _loc3_ = _loc4_ + "," + _loc3_;
            }
            else
            {
               _loc3_ += _loc4_;
            }
            _loc2_ = _loc2_.replace(_loc4_,"");
         }
         return _loc3_;
      }
      
      public static function set serverTime(param1:Number) : void
      {
         _serverTime = param1;
         _clientTime = int(getTimer() / 1000);
      }
      
      public static function get root() : Sprite
      {
         return _root;
      }
      
      public static function get serverTime() : Number
      {
         if(_serverTime == 0)
         {
            return Math.floor(new Date().getTime() / 1000);
         }
         return _serverTime + (Math.floor(getTimer() / 1000) - _clientTime);
      }
   }
}

