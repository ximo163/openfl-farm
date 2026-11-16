package framework.net.parsers
{
   import entities.PoolFish;
   import framework.net.vo.ServiceResultVO;
   import interfaces.ILogicParser;
   
   public class FishIndexParser implements ILogicParser
   {
      
      protected var _vo:ServiceResultVO;
      
      protected var _result:Array;
      
      public function FishIndexParser()
      {
         super();
         this._vo = new ServiceResultVO();
         this._vo.m_result = "";
         this._vo.m_message = "";
         this._vo.m_extra = null;
         this._result = null;
      }
      
      public function parse(param1:Object) : ServiceResultVO
      {
         var _loc2_:* = undefined;
         if(param1 == null)
         {
            return null;
         }
         if(param1["open"] != undefined && parseInt(param1["open"]) == 0)
         {
            this._vo.m_extra = null;
            return this._vo;
         }
         if(param1["fish"] != undefined)
         {
            if(this._result == null)
            {
               this._result = new Array();
            }
            else
            {
               this._result.splice(0);
            }
            for each(_loc2_ in param1["fish"])
            {
               this._result.push(new PoolFish(_loc2_));
            }
            this._vo.m_extra = this._result;
         }
         return this._vo;
      }
   }
}

