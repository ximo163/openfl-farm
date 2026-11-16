package common
{
   import com.adobe.utils.StringUtil;
   
   public final class FeartureManager
   {
      
      public function FeartureManager()
      {
         super();
      }
      
      public static function openByFlashVar() : Boolean
      {
         var _loc1_:String = Settings.getInstance().getStringAttribute("useflag");
         var _loc2_:int = parseInt(_loc1_) / 100 % 10;
         return !Boolean(_loc2_);
      }
      
      public static function stealOtherMod() : *
      {
         var _loc1_:String = Settings.getInstance().getStringAttribute("steal");
         var _loc2_:String = Settings.getInstance().getStringAttribute("steal_mod");
         var _loc3_:int = int(Session.getInstance().currentUser._uId);
         if(checkRange(_loc3_,_loc1_,parseInt(_loc2_)))
         {
            return Settings.getInstance().getStringAttribute("steal_tips_other");
         }
         return false;
      }
      
      public static function stealMod() : *
      {
         var _loc1_:String = Settings.getInstance().getStringAttribute("steal");
         var _loc2_:String = Settings.getInstance().getStringAttribute("steal_mod");
         var _loc3_:int = parseInt(Session.getInstance().hostId);
         if(checkRange(_loc3_,_loc1_,parseInt(_loc2_)))
         {
            return Settings.getInstance().getStringAttribute("steal_tips");
         }
         return false;
      }
      
      private static function checkRange(param1:int, param2:String, param3:int) : Boolean
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         if(param2)
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
      
      public static function friendListMod() : *
      {
         var _loc1_:Settings = Settings.getInstance();
         var _loc2_:String = _loc1_.getStringAttribute("friend_list");
         var _loc3_:String = "";
         if(_loc1_.mode == "qzone")
         {
            _loc3_ = _loc1_.getStringAttribute("friend_list_mod_qz");
         }
         else
         {
            _loc3_ = _loc1_.getStringAttribute("friend_list_mod_xy");
         }
         var _loc4_:int = parseInt(Session.getInstance().hostId);
         if(checkRange(_loc4_,_loc2_,parseInt(_loc3_)))
         {
            return Settings.getInstance().getStringAttribute("friend_list_tips");
         }
         return false;
      }
   }
}

