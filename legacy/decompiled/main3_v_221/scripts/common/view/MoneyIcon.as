package common.view
{
   import common.misc.Utils;
   import flash.display.Sprite;
   
   public class MoneyIcon extends Sprite
   {
      
      public static const FB:String = "fb";
      
      public static const GOLD:String = "gold";
      
      public static const X:String = "unknown";
      
      public static const RP:String = "rp";
      
      private var _type:String = "";
      
      public function MoneyIcon(param1:String = "gold")
      {
         super();
         if(param1 == X)
         {
            this._type = param1;
            return;
         }
         this.setIconType(param1);
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      private function setIconType(param1:String) : void
      {
         var _loc2_:String = "GoldIcon";
         var _loc3_:String = "QB";
         var _loc4_:String = "RPIcon";
         if(param1 == GOLD)
         {
            addChild(Utils.getMaterial(_loc2_) as Sprite);
         }
         else if(param1 == FB)
         {
            addChild(Utils.getMaterial(_loc3_) as Sprite);
         }
         else if(param1 == RP && Boolean(Utils.getMaterial(_loc4_)))
         {
            addChild(Utils.getMaterial(_loc4_) as Sprite);
         }
         this._type = param1;
      }
      
      public function set type(param1:String) : void
      {
         if(this._type == X)
         {
            this.setIconType(param1);
         }
      }
   }
}

