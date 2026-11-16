package framework.net.parsers
{
   import entities.BagItem;
   import framework.base.BaseArrayParser;
   
   public class BagDataParser extends BaseArrayParser
   {
      
      public function BagDataParser()
      {
         super();
         super._class = BagItem;
      }
   }
}

