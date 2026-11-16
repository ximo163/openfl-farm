package framework.base
{
   import framework.net.vo.ServiceResultVO;
   import interfaces.ILogicParser;
   
   public class BaseArrayParser implements ILogicParser
   {
      
      protected var _vo:ServiceResultVO;
      
      protected var _class:Class;
      
      protected var _result:Array;
      
      public function BaseArrayParser()
      {
         super();
         this._class = null;
         this._vo = new ServiceResultVO();
         this._vo.m_result = "";
         this._vo.m_message = "";
         this._vo.m_extra = null;
         this._result = null;
      }
      
      public function parse(param1:Object) : ServiceResultVO
      {
         var _loc2_:* = undefined;
         var _loc3_:* = undefined;
         if(param1 == null)
         {
            return null;
         }
         if(this._class == null)
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
         if(param1 is Array == true)
         {
            for each(_loc2_ in param1)
            {
               _loc3_ = new this._class(_loc2_);
               this._result.push(_loc3_);
            }
         }
         else
         {
            this._result.push(new this._class(param1));
         }
         this._vo.m_extra = this._result;
         return this._vo;
      }
   }
}

