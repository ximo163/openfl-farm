package framework.net.parsers
{
   import framework.net.vo.ServiceResultVO;
   import interfaces.ILogicParser;
   
   public final class NullParser implements ILogicParser
   {
      
      public function NullParser()
      {
         super();
      }
      
      public function parse(param1:Object) : ServiceResultVO
      {
         return null;
      }
   }
}

