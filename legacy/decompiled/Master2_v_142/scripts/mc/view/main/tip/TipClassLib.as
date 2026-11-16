package mc.view.main.tip
{
   import mc.view.farm.animals.HunterInfo;
   import mc.view.farm.land.AnimalInfo;
   import mc.view.farm.land.HouseTip;
   import mc.view.farm.land.ProductInfo;
   
   public class TipClassLib
   {
      
      private static var _lib:Object = {
         "MouseTip":MouseTip,
         "AnimalInfo":AnimalInfo,
         "HunterInfo":HunterInfo,
         "ProductInfo":ProductInfo,
         "HouseTip":HouseTip
      };
      
      public function TipClassLib()
      {
         super();
      }
      
      public static function getClass(param1:String) : Class
      {
         if(_lib == null)
         {
            return null;
         }
         return _lib[param1];
      }
      
      public static function register(param1:String, param2:Class) : void
      {
         if(_lib == null)
         {
            _lib = new Object();
         }
         _lib[param1] = param2;
      }
   }
}

