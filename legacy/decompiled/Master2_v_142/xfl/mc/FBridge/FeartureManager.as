package mc.FBridge
{
   import com.adobe.utils.StringUtil;
   import common.LocalData;
   import mc.model.MData;
   
   public class FeartureManager
   {
      
      public function FeartureManager()
      {
         super();
      }
      
      public static function enterMod() : String
      {
         var _loc1_:String = LocalData.parameters.pasture_enter;
         var _loc2_:int = int(LocalData.parameters.pasture_enter_mod);
         var _loc3_:int = int(MData.getInstance().mainData.host["uin"]);
         if(checkRange(_loc3_,_loc1_,_loc2_))
         {
            return LocalData.parameters.pasture_enter_tips;
         }
         return null;
      }
      
      public static function stealMod() : String
      {
         var _loc1_:String = LocalData.parameters.pasture_steal;
         var _loc2_:int = int(LocalData.parameters.pasture_steal_mod);
         var _loc3_:int = int(MData.getInstance().mainData.host["uin"]);
         if(checkRange(_loc3_,_loc1_,_loc2_))
         {
            return LocalData.parameters.pasture_steal_tips;
         }
         return null;
      }
      
      private static function checkRange(param1:int, param2:String, param3:int) : Boolean
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         if(Boolean(param2) && Boolean(param1) && Boolean(param3))
         {
            _loc4_ = [];
            _loc5_ = param2.split(",");
            param1 %= param3;
            for each(_loc6_ in _loc5_)
            {
               _loc7_ = _loc6_.split("-");
               if(param1 >= parseInt(StringUtil.trim(_loc7_[0])) && param1 <= parseInt(StringUtil.trim(_loc7_[1])))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public static function friendListMod() : String
      {
         var _loc1_:String = LocalData.parameters.pasture_friend_list;
         var _loc2_:int = int(LocalData.parameters.pasture_friend_list_mod);
         var _loc3_:int = int(MData.getInstance().mainData.host["uin"]);
         if(checkRange(_loc3_,_loc1_,_loc2_))
         {
            return LocalData.parameters.pasture_friend_list_tips;
         }
         return null;
      }
   }
}

