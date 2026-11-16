package mc.control
{
   import common.INI;
   
   public class Version
   {
      
      public static var _sns:String;
      
      public static const QQ:String = "qq";
      
      public static const :String = "";
      
      public static const QZONE:String = "qzone";
      
      public function Version()
      {
         super();
      }
      
      public static function set SNS(param1:String) : void
      {
         _sns = param1;
      }
      
      public static function get value() : String
      {
         var _loc1_:XML = INI.getInstance().data;
         return _loc1_.version.@value;
      }
      
      public static function get SNS() : String
      {
         var _loc1_:XML = INI.getInstance().data;
         var _loc2_:String = _loc1_.version.@value;
         var _loc3_:String = "xiaonei";
         if(_loc2_ == "51" || _loc2_ == "xiaonei" || _loc2_ == "manyou" || _loc2_ == "facebook")
         {
            _loc3_ = "xiaonei";
         }
         else if(_loc2_ == "" || _loc2_ == "qzone")
         {
            _loc3_ = "qq";
         }
         return _loc3_;
      }
   }
}

