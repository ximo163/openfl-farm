package framework.net.parsers
{
   import entities.WarehouseCrop;
   import framework.base.BaseArrayParser;
   import framework.net.vo.ServiceResultVO;
   
   public class WarehouseCropsParser extends BaseArrayParser
   {
      
      public function WarehouseCropsParser()
      {
         super();
         super._class = WarehouseCrop;
      }
      
      override public function parse(param1:Object) : ServiceResultVO
      {
         if(param1["crop"] != undefined)
         {
            super.parse(param1["crop"]);
         }
         if(param1["flowerPath"] != undefined)
         {
            _vo.m_extra = {
               "flowerPath":param1["flowerPath"],
               "crops":_result,
               "allFlower":param1["allFlower"]
            };
         }
         else
         {
            _vo.m_extra = {
               "flowerPath":"",
               "crops":_result,
               "allFlower":param1["allFlower"]
            };
         }
         return _vo;
      }
   }
}

