package framework.net.parsers
{
   import entities.Item;
   import framework.base.BaseArrayParser;
   
   public class ItemsDataParser extends BaseArrayParser
   {
      
      public function ItemsDataParser()
      {
         super();
         super._class = Item;
      }
   }
}

