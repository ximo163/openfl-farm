package module.magicBaby
{
   import com.adobe.serialization.json.JSON;
   import common.CommonData;
   import common.INI;
   import mc.view.farm.GetCropID;
   
   public class MagicalBabyData
   {
      
      public static var config:XML;
      
      public static const ACTIVITY_ID:int = 1004;
      
      public static const REWARD_PACK_ID:int = 304;
      
      public static const PACK_ID_1:int = 42;
      
      public static const PACK_ID_2:int = 43;
      
      public static const PACK_ID_3:int = 44;
      
      public function MagicalBabyData()
      {
         super();
      }
      
      public static function getSalary() : Object
      {
         var _loc1_:String = config.salary;
         var _loc2_:Object = com.adobe.serialization.json.JSON.decode(_loc1_);
         return getItemData(_loc2_);
      }
      
      public static function getCost(param1:int) : int
      {
         var _loc2_:String = config.researchCost;
         var _loc3_:Object = com.adobe.serialization.json.JSON.decode(_loc2_);
         if(Boolean(_loc3_[String(param1)]) && _loc3_[String(param1)] > 0)
         {
            return _loc3_[String(param1)];
         }
         return 0;
      }
      
      private static function getItemData(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_["id"] = param1["id"];
         _loc2_["d"] = param1["description"];
         _loc2_["t"] = param1["type"];
         _loc2_["e"] = param1["effect"];
         _loc2_["n"] = param1["name"];
         _loc2_["l"] = param1["left"];
         _loc2_["p"] = param1["price"];
         _loc2_["qd"] = param1["qdprice"];
         _loc2_["y"] = param1["yqdprice"];
         _loc2_["o"] = param1["order"];
         _loc2_["lt"] = param1["limittips"];
         _loc2_["tips"] = param1["tips"];
         return _loc2_;
      }
      
      public static function isActive() : Boolean
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         config = INI.getInstance().data.magicalBaby[0];
         if(config)
         {
            _loc1_ = config.@start;
            _loc2_ = config.@end;
            _loc3_ = new Date(_loc1_).time;
            _loc4_ = new Date(_loc2_).time;
            _loc5_ = CommonData.serverTime * 1000;
            if(_loc3_ < _loc5_ && _loc5_ < _loc4_)
            {
               return true;
            }
            return false;
         }
         return false;
      }
      
      public static function getLink() : String
      {
         return config.@linkUrl;
      }
      
      public static function endDate() : Array
      {
         var _loc1_:String = config.@end;
         var _loc2_:Date = new Date(_loc1_);
         return [_loc2_.month + 1,_loc2_.date];
      }
      
      public static function getFood() : Object
      {
         var _loc1_:String = config.food;
         var _loc2_:Object = com.adobe.serialization.json.JSON.decode(_loc1_);
         return getItemData(_loc2_);
      }
      
      public function getTip() : String
      {
         return config.@tip;
      }
      
      public function getUIUrl() : String
      {
         return GetCropID.addPrefix(config.@uiUrl);
      }
      
      public function getReserchUIUrl() : String
      {
         return GetCropID.addPrefix(config.@reserchUIUrl);
      }
   }
}

