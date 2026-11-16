package wild.com.Shell.business.analyzer.setup
{
   import wild.com.Shell.business.analyzer.IParser;
   import wild.com.Shell.model.beast.BeastBase;
   
   public class ParserBeast implements IParser
   {
      
      public function ParserBeast()
      {
         super();
      }
      
      public function parse(param1:Object) : Object
      {
         var _loc2_:BeastBase = new BeastBase();
         _loc2_.info.parse(param1["info"]);
         _loc2_.bReturn.parse(param1["return"]);
         _loc2_.drop.parse(param1["drop"]);
         return _loc2_;
      }
      
      public function get msgName() : String
      {
         return "ParserBeast";
      }
   }
}

