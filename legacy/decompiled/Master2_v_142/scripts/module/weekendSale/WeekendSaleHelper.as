package module.weekendSale
{
   public class WeekendSaleHelper
   {
      
      public static var products:Array;
      
      public static var model:WeekendSaleModel;
      
      public static var freeCard:Boolean;
      
      public static var cards:int;
      
      public static var ids:Array;
      
      public static var activityName:String = "weekendSale";
      
      public static var cardId:int = 34;
      
      public static var freeDardId:int = 35;
      
      public static var cardType:int = 7;
      
      public static var cardCategory:String = "items";
      
      public static var shareUrl:String = "cgi_qzshare_onekey";
      
      public static var avaliable:Boolean = false;
      
      public function WeekendSaleHelper()
      {
         super();
      }
      
      public static function getProductPrice(param1:Object, param2:String = "price", param3:int = 0) : Number
      {
         var _loc4_:Object = null;
         if(!param1)
         {
            return 0;
         }
         if(avaliable && model.canSell)
         {
            for each(_loc4_ in products)
            {
               if(Boolean(_loc4_) && Boolean(param1) && _loc4_.cId + param3 == param1.cId)
               {
                  return param1[param2] * _loc4_.times;
               }
            }
         }
         return param1[param2];
      }
      
      public static function weekendSaleProdFilter(param1:*, param2:int, param3:Array) : Boolean
      {
         var _loc4_:* = undefined;
         var _loc5_:Boolean = false;
         if(avaliable)
         {
            if(ids)
            {
               for each(_loc4_ in ids)
               {
                  _loc5_ = _loc4_ == param1.cId;
                  if(Boolean(_loc4_) && Boolean(param1) && _loc5_)
                  {
                     return false;
                  }
               }
            }
         }
         return true;
      }
   }
}

