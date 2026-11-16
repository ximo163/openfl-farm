package framework.net.parsers
{
   import entities.Seed;
   import framework.base.BaseArrayParser;
   
   public class SeedDataParser extends BaseArrayParser
   {
      
      public function SeedDataParser()
      {
         super();
         super._class = Seed;
      }
   }
}

