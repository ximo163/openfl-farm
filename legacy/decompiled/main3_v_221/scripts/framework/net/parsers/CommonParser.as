package framework.net.parsers
{
   import framework.net.vo.ServiceResultVO;
   import interfaces.ILogicParser;
   
   public class CommonParser implements ILogicParser
   {
      
      private var _result:ServiceResultVO;
      
      public function CommonParser()
      {
         super();
         this._result = new ServiceResultVO();
      }
      
      public function parse(param1:Object) : ServiceResultVO
      {
         this._result.m_extra = param1;
         return this._result;
      }
   }
}

