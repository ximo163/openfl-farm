package mc.model
{
   import common.CommonData;
   import common.INI;
   
   public class OpenControl
   {
      
      public function OpenControl()
      {
         super();
      }
      
      public static function checkTime2(param1:String) : Boolean
      {
         var _loc2_:Number = CommonData.serverTime * 1000;
         var _loc3_:Array = OpenControl.getOpenTime(param1).split("|");
         var _loc4_:Number = new Date(_loc3_[0]).time;
         var _loc5_:Number = new Date(_loc3_[1]).time;
         if(_loc2_ >= _loc4_ && _loc2_ <= _loc5_)
         {
            return true;
         }
         return false;
      }
      
      public static function checkTime(param1:String) : Boolean
      {
         var _loc2_:Date = new Date(CommonData.serverTime * 1000);
         var _loc3_:Array = OpenControl.getOpenTime(param1).split("|");
         var _loc4_:Number = _loc2_.hours;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            if(_loc3_[_loc5_] == _loc4_)
            {
               return true;
            }
            _loc5_++;
         }
         return false;
      }
      
      public static function getOpenExpLv(param1:String) : Number
      {
         var explv:Number = NaN;
         var val:String = param1;
         var xmlData:XML = INI.getInstance().data;
         if(xmlData != null)
         {
            explv = Number(xmlData.openControl.item.(@name == val).@openexp);
            return explv;
         }
         return 9999;
      }
      
      public static function open(param1:String) : Boolean
      {
         var val:String = param1;
         var openBoolean:Boolean = false;
         var xmlData:XML = INI.getInstance().data;
         if(xmlData != null)
         {
            if(xmlData.openControl.item.(@name == val).@open == "true")
            {
               openBoolean = true;
            }
            else
            {
               openBoolean = false;
            }
         }
         return openBoolean;
      }
      
      public static function getOpenTime(param1:String) : String
      {
         var timeArray:String = null;
         var val:String = param1;
         var xmlData:XML = INI.getInstance().data;
         if(xmlData != null)
         {
            timeArray = xmlData.openControl.item.(@name == val).@time;
            return timeArray;
         }
         return "";
      }
      
      public static function getOpenYellowLv(param1:String) : Number
      {
         var lv:Number = NaN;
         var val:String = param1;
         var xmlData:XML = INI.getInstance().data;
         if(xmlData != null)
         {
            lv = Number(xmlData.openControl.item.(@name == val).@openlv);
            return lv;
         }
         return 9999;
      }
   }
}

