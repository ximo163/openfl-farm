package framework.net.parsers
{
   import entities.ShopFish;
   import framework.base.BaseArrayParser;
   
   public class FishDataParser extends BaseArrayParser
   {
      
      public function FishDataParser()
      {
         super();
         super._class = ShopFish;
      }
   }
}

