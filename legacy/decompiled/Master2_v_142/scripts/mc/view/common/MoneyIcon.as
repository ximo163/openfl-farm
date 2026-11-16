package mc.view.common
{
   import common.MaterialLib;
   import flash.display.Sprite;
   
   public class MoneyIcon extends Sprite
   {
      
      public static const GOLD:String = "gold";
      
      public static const FB:String = "fb";
      
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
      
      public function set type(param1:String) : void
      {
         if(this._type == X)
         {
            this.setIconType(param1);
         }
      }
      
      private function setIconType(param1:String) : void
      {
         var _loc2_:String = "";
         var _loc3_:String = "";
         _loc2_ = "GoldIcon";
         _loc3_ = "QB";
         if(param1 == GOLD)
         {
            addChild(MaterialLib.getInstance().getMaterial(_loc2_) as Sprite);
         }
         else if(param1 == FB)
         {
            addChild(MaterialLib.getInstance().getMaterial(_loc3_) as Sprite);
         }
         else if(param1 == RP)
         {
            addChild(MaterialLib.getInstance().getMaterial("RPIcon") as Sprite);
         }
         this._type = param1;
      }
      
      public function get type() : String
      {
         return this._type;
      }
   }
}

