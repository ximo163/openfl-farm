package framework.net.parsers
{
   import entities.DecorateItem;
   import framework.net.vo.ServiceResultVO;
   import interfaces.ILogicParser;
   
   public class DecorateItemsParser implements ILogicParser
   {
      
      private var _currDiy:Array;
      
      private var _vo:ServiceResultVO;
      
      private var _result:Array;
      
      private var _buyedDiy:Array;
      
      public function DecorateItemsParser()
      {
         super();
         this._vo = new ServiceResultVO();
         this._vo.m_result = "";
         this._vo.m_message = "";
         this._vo.m_extra = null;
         this._result = null;
         this._currDiy = [];
         this._buyedDiy = [];
      }
      
      public function parse(param1:Object) : ServiceResultVO
      {
         var _loc2_:* = undefined;
         var _loc3_:DecorateItem = null;
         var _loc4_:* = undefined;
         var _loc5_:DecorateItem = null;
         if(param1 == null)
         {
            return null;
         }
         if(this._result == null)
         {
            this._result = new Array();
         }
         else
         {
            this._result.splice(0);
         }
         this._currDiy.splice(0);
         this._buyedDiy.splice(0);
         if(param1["current"] is Array == true)
         {
            for each(_loc2_ in param1["current"])
            {
               _loc3_ = new DecorateItem(_loc2_);
               this._currDiy.push(_loc3_);
            }
         }
         this._result.push(this._currDiy);
         if(param1["items"] is Array == true)
         {
            for each(_loc4_ in param1["items"])
            {
               _loc5_ = new DecorateItem(_loc4_);
               this._buyedDiy.push(_loc5_);
            }
         }
         this._result.push(this._buyedDiy);
         this._vo.m_extra = this._result;
         return this._vo;
      }
   }
}

