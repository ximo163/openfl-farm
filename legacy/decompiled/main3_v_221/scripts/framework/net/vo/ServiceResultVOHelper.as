package framework.net.vo
{
   import com.qzone.qfa.events.CommandEvent;
   
   public class ServiceResultVOHelper
   {
      
      public function ServiceResultVOHelper()
      {
         super();
      }
      
      public static function getVOData(param1:CommandEvent) : Object
      {
         if(param1 == null || param1.result == null)
         {
            return null;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return null;
         }
         return _loc2_.m_extra;
      }
   }
}

